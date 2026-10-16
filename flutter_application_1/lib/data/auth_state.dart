import 'dart:async';
import 'dart:math';

import 'package:crypt/crypt.dart';
import 'package:flutter/foundation.dart';

import 'models/user_model.dart';
import 'repositories/auth_repository.dart';

class AuthController extends ChangeNotifier {
  AuthController({AuthRepository? repository})
    : _repository = repository ?? AuthRepository();

  final AuthRepository _repository;

  User? _currentUser;
  bool _isLoadingSession = true;
  bool _isSubmitting = false;

  User? get currentUser => _currentUser;

  bool get isLoadingSession => _isLoadingSession;

  bool get isSubmitting => _isSubmitting;

  Future<void> initialize() async {
    _isLoadingSession = true;
    notifyListeners();

    try {
      final persistedUser = await _repository
          .getPersistedSessionUser()
          .timeout(const Duration(milliseconds: 300), onTimeout: () => null);
      _currentUser = persistedUser;
    } catch (_) {
      _currentUser = null;
    } finally {
      _isLoadingSession = false;
      notifyListeners();
    }
  }

  Future<String?> register({
    required String fullName,
    required String email,
    required String password,
    required String confirmPassword,
  }) async {
    final trimmedFullName = fullName.trim();
    final normalizedEmail = email.trim();

    if (trimmedFullName.isEmpty ||
        trimmedFullName.split(RegExp(r'\s+')).every((part) => part.isEmpty)) {
      return 'Nama lengkap wajib diisi.';
    }

    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(normalizedEmail)) {
      return 'Format email tidak valid.';
    }

    if (password.length < 8) {
      return 'Password minimal 8 karakter.';
    }

    if (confirmPassword != password) {
      return 'Konfirmasi password harus sama dengan password.';
    }

    _isSubmitting = true;
    notifyListeners();

    try {
      final existingUser = await _repository.getUserByEmail(
        normalizedEmail.toLowerCase(),
      );
      if (existingUser != null) {
        return 'Email sudah terdaftar. Silakan gunakan email lain.';
      }

      final salt = _generateSalt();
      final hashedPassword = Crypt.sha256(password, salt: salt).toString();
      final user = await _repository.createUser(
        fullName: trimmedFullName,
        email: normalizedEmail.toLowerCase(),
        passwordHash: hashedPassword,
        passwordSalt: salt,
      );

      _currentUser = user;
      return null;
    } on Exception catch (error) {
      debugPrint('Pendaftaran gagal: $error');
      return 'Pendaftaran gagal karena terjadi kendala. Silakan coba lagi.';
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  Future<String?> login({
    required String email,
    required String password,
    required bool rememberMe,
  }) async {
    final normalizedEmail = email.trim();
    if (normalizedEmail.isEmpty ||
        !RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(normalizedEmail)) {
      return 'Email atau password tidak valid.';
    }

    if (password.isEmpty) {
      return 'Password wajib diisi.';
    }

    _isSubmitting = true;
    notifyListeners();

    try {
      final user = await _repository.getUserByEmail(
        normalizedEmail.toLowerCase(),
      );
      if (user == null) {
        return 'Email atau password tidak valid.';
      }

      final hashedPassword = Crypt.sha256(
        password,
        salt: user.passwordSalt,
      ).toString();
      if (hashedPassword != user.passwordHash) {
        return 'Email atau password tidak valid.';
      }

      _currentUser = user;
      notifyListeners();
      unawaited(_persistLoginSession(user, rememberMe: rememberMe));
      return null;
    } on Object catch (error) {
      debugPrint('Login gagal: $error');
      return 'Login gagal karena terjadi kendala. Silakan coba lagi.';
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  Future<void> _persistLoginSession(
    User user, {
    required bool rememberMe,
  }) async {
    try {
      final operation = rememberMe
          ? _repository.persistSession(user, rememberMe: true)
          : _repository.clearSession();
      await operation.timeout(const Duration(seconds: 3));
    } on Object catch (error) {
      debugPrint('Penyimpanan sesi login gagal: $error');
    }
  }

  Future<void> logout() async {
    _currentUser = null;
    try {
      await _repository.clearSession();
    } catch (_) {
      // Ignore storage errors during logout so the app can continue safely.
    }
    notifyListeners();
  }

  String _generateSalt() {
    const charset =
        'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random.secure();
    final buffer = StringBuffer();
    for (var i = 0; i < 16; i++) {
      buffer.write(charset[random.nextInt(charset.length)]);
    }
    return buffer.toString();
  }
}
