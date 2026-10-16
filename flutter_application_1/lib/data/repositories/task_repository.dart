import '../database/app_database.dart';
import '../models/task_model.dart';

class TaskRepository {
  TaskRepository({AppDatabase? database})
    : _database = database ?? AppDatabase.instance;

  final AppDatabase _database;

  Future<List<Task>> getAllTasks() => _database.getAllTasks();

  Future<List<Task>> getTasksByUserId(int userId) =>
      _database.getTasksByUserId(userId);

  Future<Task?> getTaskById(int id) => _database.getTaskById(id);

  Future<int> insertTask(Task task) => _database.insertTask(task);

  Future<int> updateTask(Task task) => _database.updateTask(task);

  Future<int> deleteTask(int id, {int? userId}) =>
      _database.deleteTask(id, userId: userId);
}
