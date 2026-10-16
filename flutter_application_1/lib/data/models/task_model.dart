enum TaskStatus { belumDikerjakan, sedangDikerjakan, selesai }

extension TaskStatusX on TaskStatus {
  String get label {
    switch (this) {
      case TaskStatus.belumDikerjakan:
        return 'Belum Dikerjakan';
      case TaskStatus.sedangDikerjakan:
        return 'Sedang Dikerjakan';
      case TaskStatus.selesai:
        return 'Selesai';
    }
  }

  String get value {
    switch (this) {
      case TaskStatus.belumDikerjakan:
        return 'belumDikerjakan';
      case TaskStatus.sedangDikerjakan:
        return 'sedangDikerjakan';
      case TaskStatus.selesai:
        return 'selesai';
    }
  }

  static TaskStatus fromValue(String? value) {
    switch (value) {
      case 'belumDikerjakan':
        return TaskStatus.belumDikerjakan;
      case 'sedangDikerjakan':
        return TaskStatus.sedangDikerjakan;
      case 'selesai':
        return TaskStatus.selesai;
      default:
        return TaskStatus.belumDikerjakan;
    }
  }
}

class Task {
  const Task({
    this.id,
    this.userId,
    required this.title,
    required this.courseName,
    required this.deadline,
    this.description = '',
    this.status = TaskStatus.belumDikerjakan,
    required this.createdAt,
    required this.updatedAt,
  });

  final int? id;
  final int? userId;
  final String title;
  final String courseName;
  final DateTime deadline;
  final String description;
  final TaskStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;

  Task copyWith({
    int? id,
    int? userId,
    String? title,
    String? courseName,
    DateTime? deadline,
    String? description,
    TaskStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Task(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      courseName: courseName ?? this.courseName,
      deadline: deadline ?? this.deadline,
      description: description ?? this.description,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'userId': userId,
      'title': title,
      'courseName': courseName,
      'deadline': deadline.millisecondsSinceEpoch,
      'description': description,
      'status': status.value,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
    };

    if (id != null) {
      map['id'] = id;
    }

    return map;
  }

  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'] as int?,
      userId: map['userId'] as int?,
      title: map['title'] as String? ?? '',
      courseName: map['courseName'] as String? ?? '',
      deadline: DateTime.fromMillisecondsSinceEpoch(
        map['deadline'] as int? ?? DateTime.now().millisecondsSinceEpoch,
      ),
      description: map['description'] as String? ?? '',
      status: TaskStatusX.fromValue(map['status'] as String?),
      createdAt: DateTime.fromMillisecondsSinceEpoch(
        map['createdAt'] as int? ?? DateTime.now().millisecondsSinceEpoch,
      ),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(
        map['updatedAt'] as int? ?? DateTime.now().millisecondsSinceEpoch,
      ),
    );
  }

  bool get isOverdue =>
      !isCompleted &&
      deadline.isBefore(DateTime.now()) &&
      !deadline.isAtSameMomentAs(DateTime.now());

  bool get isCompleted => status == TaskStatus.selesai;

  bool get isDueSoon {
    final difference = deadline.difference(DateTime.now());
    return !isCompleted && difference.inHours <= 24 && difference.inHours >= 0;
  }

  String get formattedDeadline {
    return '${deadline.day} ${_monthLabel(deadline.month)} ${deadline.year}, ${_timeLabel(deadline.hour, deadline.minute)}';
  }

  String get relativeDeadlineText {
    final diff = deadline.difference(DateTime.now());
    if (isCompleted) {
      return 'Tugas selesai';
    }
    if (isOverdue) {
      final overdueHours = diff.inHours.abs();
      if (overdueHours < 24) {
        return 'Terlewat $overdueHours jam';
      }
      final overdueDays = diff.inDays.abs();
      return 'Terlewat $overdueDays hari';
    }
    if (diff.inDays > 0) {
      return 'Sisa ${diff.inDays} hari';
    }
    if (diff.inHours > 0) {
      return 'Sisa ${diff.inHours} jam';
    }
    return 'Deadline hari ini';
  }

  String _monthLabel(int month) {
    const names = [
      '',
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember',
    ];
    return names[month];
  }

  String _timeLabel(int hour, int minute) {
    final formattedHour = hour.toString().padLeft(2, '0');
    final formattedMinute = minute.toString().padLeft(2, '0');
    return '$formattedHour:$formattedMinute';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Task &&
        id == other.id &&
        userId == other.userId &&
        title == other.title &&
        courseName == other.courseName &&
        deadline == other.deadline &&
        description == other.description &&
        status == other.status;
  }

  @override
  int get hashCode =>
      Object.hash(id, userId, title, courseName, deadline, description, status);

  @override
  String toString() {
    return 'Task(id: $id, title: $title, courseName: $courseName, deadline: $deadline, status: ${status.label})';
  }
}
