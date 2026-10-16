import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../database/app_database.dart';
import '../models/user_model.dart';

class AuthRepository {
  AuthRepository({AppDatabase? database, FlutterSecureStorage? storage})
    : _database = database ?? AppDatabase.instance,
      _storage = storage ?? const FlutterSecureStorage();

  static const _sessionUserIdKey = 'catatan_tugas_session_user_id';
  static const _sessionExpiresAtKey = 'catatan_tugas_session_expires_at';
  static const _sessionRememberMeKey = 'catatan_tugas_session_remember_me';

  final AppDatabase _database;
  final FlutterSecureStorage _storage;

  Future<User?> getUserByEmail(String email) => _database.getUserByEmail(email);

  Future<User?> getUserById(int userId) => _database.getUserById(userId);

  Future<User> createUser({
    required String fullName,
    required String email,
    required String passwordHash,
    required String passwordSalt,
  }) async {
    final user = User(
      fullName: fullName,
      email: email,
      passwordHash: passwordHash,
      passwordSalt: passwordSalt,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    final userId = await _database.insertUser(user);
    return user.copyWith(id: userId);
  }

  Future<User?> login({
    required String email,
    required String password,
    required String passwordHash,
    required String passwordSalt,
  }) async {
    final normalizedEmail = email.trim();
    final user = await getUserByEmail(normalizedEmail);
    if (user == null) {
      return null;
    }

    final storedHash = user.passwordHash;
    final storedSalt = user.passwordSalt;
    final candidateHash = passwordHash;

    if (storedHash.isEmpty ||
        storedSalt.isEmpty ||
        storedHash != candidateHash) {
      return null;
    }

    return user;
  }

  Future<User?> getPersistedSessionUser() async {
    try {
      final userIdValue = await _storage.read(key: _sessionUserIdKey);
      if (userIdValue == null || userIdValue.isEmpty) {
        return null;
      }

      final expiresAtValue = await _storage.read(key: _sessionExpiresAtKey);
      if (expiresAtValue == null || expiresAtValue.isEmpty) {
        await clearSession();
        return null;
      }

      final expiresAt = DateTime.fromMillisecondsSinceEpoch(
        int.tryParse(expiresAtValue) ?? 0,
      );
      if (DateTime.now().isAfter(expiresAt)) {
        await clearSession();
        return null;
      }

      final userId = int.tryParse(userIdValue);
      if (userId == null) {
        await clearSession();
        return null;
      }

      final user = await _database.getUserById(userId);
      return user;
    } catch (_) {      return null;
    }
  }

  Future<void> persistSession(User user, {required bool rememberMe}) async {
    final expiresAt = rememberMe
        ? DateTime.now().add(const Duration(days: 30))
        : DateTime.now().add(const Duration(hours: 12));

    await _storage.write(key: _sessionUserIdKey, value: user.id.toString());
    await _storage.write(
      key: _sessionExpiresAtKey,
      value: expiresAt.millisecondsSinceEpoch.toString(),
    );
    await _storage.write(
      key: _sessionRememberMeKey,
      value: rememberMe ? '1' : '0',
    );
  }

  Future<void> clearSession() async {
    await _storage.delete(key: _sessionUserIdKey);
    await _storage.delete(key: _sessionExpiresAtKey);
    await _storage.delete(key: _sessionRememberMeKey);
  }
}
