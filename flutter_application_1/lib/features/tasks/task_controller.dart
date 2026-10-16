import 'package:flutter/foundation.dart';

import '../../core/services/local_notification_service.dart';
import '../../data/models/task_model.dart';
import '../../data/repositories/task_repository.dart';

enum TaskSort {
  deadlineNearest,
  deadlineFarthest,
  titleAsc,
  titleDesc,
  courseAsc,
}

enum TaskStatusFilter { all, belumDikerjakan, sedangDikerjakan, selesai }

class TaskController extends ChangeNotifier {
  TaskController({TaskRepository? repository, this.userId})
    : _repository = repository ?? TaskRepository(),
      _notificationService = LocalNotificationService.instance;

  final TaskRepository _repository;
  final LocalNotificationService _notificationService;

  int? userId;
  List<Task> _tasks = [];
  bool _isLoading = false;
  String _searchQuery = '';
  TaskStatusFilter _statusFilter = TaskStatusFilter.all;
  TaskSort _sort = TaskSort.deadlineNearest;

  void setUserId(int? newUserId) {
    userId = newUserId;
    loadTasks();
  }

  Future<void> loadTasks() async {
    _isLoading = true;
    notifyListeners();

    try {
      if (userId == null) {
        _tasks = [];
        return;
      }
      _tasks = await _repository.getTasksByUserId(userId!);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addTask(Task task) async {
    if (userId == null) {
      return;
    }

    final now = DateTime.now();
    final newTask = task.copyWith(
      userId: userId,
      createdAt: now,
      updatedAt: now,
    );

    final insertedId = await _repository.insertTask(newTask);
    final savedTask = newTask.copyWith(id: insertedId);
    await _notificationService.scheduleTaskReminders(savedTask);
    await loadTasks();
  }

  Future<void> updateTask(Task task) async {
    final updatedTask = task.copyWith(
      userId: userId ?? task.userId,
      updatedAt: DateTime.now(),
    );
    await _repository.updateTask(updatedTask);
    await _notificationService.scheduleTaskReminders(updatedTask);
    await loadTasks();
  }

  Future<void> deleteTask(Task task) async {
    if (task.id == null) {
      return;
    }

    await _repository.deleteTask(task.id!, userId: userId ?? task.userId);
    await _notificationService.cancelTaskReminders(task);
    await loadTasks();
  }

  bool get isLoading => _isLoading;

  String get searchQuery => _searchQuery;

  TaskStatusFilter get statusFilter => _statusFilter;

  TaskSort get sort => _sort;

  List<Task> get tasks => List.unmodifiable(_tasks);

  List<Task> get filteredTasks {
    final normalizedQuery = _searchQuery.trim().toLowerCase();
    final filtered = _tasks.where((task) {
      final matchesQuery =
          normalizedQuery.isEmpty ||
          task.title.toLowerCase().contains(normalizedQuery) ||
          task.courseName.toLowerCase().contains(normalizedQuery);

      final matchesStatus =
          _selectedStatus == null || task.status == _selectedStatus;

      return matchesQuery && matchesStatus;
    }).toList();

    filtered.sort(_compareTasks);
    return filtered;
  }

  List<Task> get overdueTasks {
    return _tasks.where((task) => task.isOverdue).toList()
      ..sort((a, b) => a.deadline.compareTo(b.deadline));
  }

  List<Task> get upcomingTasks {
    return _tasks.where((task) => !task.isCompleted).toList()
      ..sort((a, b) => a.deadline.compareTo(b.deadline));
  }

  Map<String, int> get summary {
    return {
      'total': _tasks.length,
      'belumDikerjakan': _tasks
          .where((task) => task.status == TaskStatus.belumDikerjakan)
          .length,
      'sedangDikerjakan': _tasks
          .where((task) => task.status == TaskStatus.sedangDikerjakan)
          .length,
      'selesai': _tasks
          .where((task) => task.status == TaskStatus.selesai)
          .length,
    };
  }

  void setSearchQuery(String value) {
    _searchQuery = value;
    notifyListeners();
  }

  void setStatusFilter(TaskStatusFilter value) {
    _statusFilter = value;
    notifyListeners();
  }

  void setSort(TaskSort value) {
    _sort = value;
    notifyListeners();
  }

  TaskStatus? get _selectedStatus {
    switch (_statusFilter) {
      case TaskStatusFilter.all:
        return null;
      case TaskStatusFilter.belumDikerjakan:
        return TaskStatus.belumDikerjakan;
      case TaskStatusFilter.sedangDikerjakan:
        return TaskStatus.sedangDikerjakan;
      case TaskStatusFilter.selesai:
        return TaskStatus.selesai;
    }
  }

  int _compareTasks(Task a, Task b) {
    switch (_sort) {
      case TaskSort.deadlineNearest:
        return a.deadline.compareTo(b.deadline);
      case TaskSort.deadlineFarthest:
        return b.deadline.compareTo(a.deadline);
      case TaskSort.titleAsc:
        return a.title.toLowerCase().compareTo(b.title.toLowerCase());
      case TaskSort.titleDesc:
        return b.title.toLowerCase().compareTo(a.title.toLowerCase());
      case TaskSort.courseAsc:
        return a.courseName.toLowerCase().compareTo(b.courseName.toLowerCase());
    }
  }
}
