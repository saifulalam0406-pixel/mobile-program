import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import 'database_factory.dart';
import '../models/task_model.dart';
import '../models/user_model.dart';

class AppDatabase {
  AppDatabase._();

  static final AppDatabase instance = AppDatabase._();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }

    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    configureDatabaseFactory();
    final path = kIsWeb
        ? 'catatan_tugas_kuliah.db'
        : join(await getDatabasesPath(), 'catatan_tugas_kuliah.db');

    return openDatabase(
      path,
      version: 2,
      onCreate: _createDatabase,
      onUpgrade: _upgradeDatabase,
    );
  }

  Future<void> _createDatabase(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        fullName TEXT NOT NULL,
        email TEXT NOT NULL UNIQUE,
        passwordHash TEXT NOT NULL,
        passwordSalt TEXT NOT NULL,
        createdAt INTEGER NOT NULL,
        updatedAt INTEGER NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE tasks (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        userId INTEGER NOT NULL,
        title TEXT NOT NULL,
        courseName TEXT NOT NULL,
        deadline INTEGER NOT NULL,
        description TEXT NOT NULL,
        status TEXT NOT NULL,
        createdAt INTEGER NOT NULL,
        updatedAt INTEGER NOT NULL,
        FOREIGN KEY (userId) REFERENCES users (id) ON DELETE CASCADE
      )
    ''');
  }

  Future<void> _upgradeDatabase(
    Database db,
    int oldVersion,
    int newVersion,
  ) async {
    if (oldVersion < 2) {
      final tableExists = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table' AND name='users'",
      );
      if (tableExists.isEmpty) {
        await db.execute('''
          CREATE TABLE users (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            fullName TEXT NOT NULL,
            email TEXT NOT NULL UNIQUE,
            passwordHash TEXT NOT NULL,
            passwordSalt TEXT NOT NULL,
            createdAt INTEGER NOT NULL,
            updatedAt INTEGER NOT NULL
          )
        ''');
      }

      final columns = await db.rawQuery('PRAGMA table_info(tasks)');
      final hasUserId = columns.any((column) => column['name'] == 'userId');
      if (!hasUserId) {
        await db.execute(
          'ALTER TABLE tasks ADD COLUMN userId INTEGER DEFAULT 0',
        );
      }
    }
  }

  Future<int> insertUser(User user) async {
    final db = await database;
    return db.insert('users', user.toMap());
  }

  Future<User?> getUserByEmail(String email) async {
    final db = await database;
    final maps = await db.query(
      'users',
      where: 'LOWER(email) = ?',
      whereArgs: [email.toLowerCase()],
    );

    if (maps.isEmpty) {
      return null;
    }

    return User.fromMap(maps.first);
  }

  Future<User?> getUserById(int userId) async {
    final db = await database;
    final maps = await db.query('users', where: 'id = ?', whereArgs: [userId]);

    if (maps.isEmpty) {
      return null;
    }

    return User.fromMap(maps.first);
  }

  Future<int> insertTask(Task task) async {
    final db = await database;
    return db.insert('tasks', task.toMap());
  }

  Future<List<Task>> getAllTasks() async {
    final db = await database;
    final maps = await db.query('tasks', orderBy: 'deadline ASC');
    return maps.map(Task.fromMap).toList();
  }

  Future<List<Task>> getTasksByUserId(int userId) async {
    final db = await database;
    final maps = await db.query(
      'tasks',
      where: 'userId = ?',
      whereArgs: [userId],
      orderBy: 'deadline ASC',
    );
    return maps.map(Task.fromMap).toList();
  }

  Future<Task?> getTaskById(int id) async {
    final db = await database;
    final maps = await db.query('tasks', where: 'id = ?', whereArgs: [id]);

    if (maps.isEmpty) {
      return null;
    }

    return Task.fromMap(maps.first);
  }

  Future<int> updateTask(Task task) async {
    final db = await database;
    return db.update(
      'tasks',
      task.toMap(),
      where: 'id = ? AND userId = ?',
      whereArgs: [task.id, task.userId],
    );
  }

  Future<int> deleteTask(int id, {int? userId}) async {
    final db = await database;
    if (userId == null) {
      return db.delete('tasks', where: 'id = ?', whereArgs: [id]);
    }

    return db.delete(
      'tasks',
      where: 'id = ? AND userId = ?',
      whereArgs: [id, userId],
    );
  }
}
