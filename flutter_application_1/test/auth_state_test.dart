import 'dart:async';

import 'package:flutter_application_1/data/auth_state.dart';
import 'package:flutter_application_1/data/models/user_model.dart';
import 'package:flutter_application_1/data/repositories/auth_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AuthController login', () {
    late _MemoryAuthRepository repository;
    late AuthController controller;

    setUp(() {
      repository = _MemoryAuthRepository();
      controller = AuthController(repository: repository);
    });

    tearDown(() {
      controller.dispose();
    });

    test('logs in after registration using normalized email', () async {
      final registrationMessage = await controller.register(
        fullName: 'Nama Pengguna',
        email: 'User@example.com',
        password: 'password123',
        confirmPassword: 'password123',
      );

      expect(registrationMessage, isNull);
      await controller.logout();

      final loginMessage = await controller.login(
        email: ' USER@EXAMPLE.COM ',
        password: 'password123',
        rememberMe: false,
      );

      expect(loginMessage, isNull);
      expect(controller.currentUser?.email, 'user@example.com');
      expect(controller.isSubmitting, isFalse);
    });

    test('rejects an incorrect password', () async {
      await controller.register(
        fullName: 'Nama Pengguna',
        email: 'user@example.com',
        password: 'password123',
        confirmPassword: 'password123',
      );
      await controller.logout();

      final message = await controller.login(
        email: 'user@example.com',
        password: 'incorrect',
        rememberMe: false,
      );

      expect(message, 'Email atau password tidak valid.');
      expect(controller.currentUser, isNull);
      expect(controller.isSubmitting, isFalse);
    });

    test('returns a recoverable message when account lookup fails', () async {
      repository.failLookups = true;

      final message = await controller.login(
        email: 'user@example.com',
        password: 'password123',
        rememberMe: false,
      );

      expect(message, 'Login gagal karena terjadi kendala. Silakan coba lagi.');
      expect(controller.currentUser, isNull);
      expect(controller.isSubmitting, isFalse);
    });

    test('does not wait for session persistence before completing login',
        () async {
      await controller.register(
        fullName: 'Nama Pengguna',
        email: 'user@example.com',
        password: 'password123',
        confirmPassword: 'password123',
      );
      repository.blockSessionPersistence = true;

      final login = controller.login(
        email: 'user@example.com',
        password: 'password123',
        rememberMe: true,
      );

      await expectLater(
        login.timeout(const Duration(seconds: 1)),
        completion(isNull),
      );
      expect(controller.currentUser?.email, 'user@example.com');
      expect(controller.isSubmitting, isFalse);
      repository.finishSessionOperation();
    });
  });
}

class _MemoryAuthRepository extends AuthRepository {
  final Map<String, User> _users = {};
  final Completer<void> _sessionOperation = Completer<void>();
  bool failLookups = false;
  bool blockSessionPersistence = false;

  @override
  Future<User?> getUserByEmail(String email) async {
    if (failLookups) {
      throw Exception('Database unavailable');
    }
    return _users[email.toLowerCase()];
  }

  @override
  Future<User> createUser({
    required String fullName,
    required String email,
    required String passwordHash,
    required String passwordSalt,
  }) async {
    final user = User(
      id: 1,
      fullName: fullName,
      email: email,
      passwordHash: passwordHash,
      passwordSalt: passwordSalt,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    _users[email.toLowerCase()] = user;
    return user;
  }

  @override
  Future<void> clearSession() async {}

  @override
  Future<void> persistSession(User user, {required bool rememberMe}) async {
    if (blockSessionPersistence) {
      await _sessionOperation.future;
    }
  }

  void finishSessionOperation() {
    if (!_sessionOperation.isCompleted) {
      _sessionOperation.complete();
    }
  }
}
