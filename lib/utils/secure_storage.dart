// lib/utils/secure_storage.dart
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';
import '../models/user_model.dart';

class SecureStorage {
  static final SecureStorage _instance = SecureStorage._internal();
  factory SecureStorage() => _instance;
  SecureStorage._internal();

  final FlutterSecureStorage _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  // Clés
  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'user_data';
  static const String _passwordHashKey = 'password_hash_';
  static const String _settingsKey = 'app_settings';

  // ===== TOKEN =====
  Future<void> saveToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
  }

  Future<String?> getToken() async {
    return await _storage.read(key: _tokenKey);
  }

  Future<void> deleteToken() async {
    await _storage.delete(key: _tokenKey);
  }

  // ===== UTILISATEUR =====
  Future<void> saveUser(User user, {String? password}) async {
    await _storage.write(key: _userKey, value: jsonEncode(user.toMap()));

    if (password != null) {
      // Stocker un hash simple pour l'authentification offline
      final hash = _simpleHash('${user.email}:$password');
      await _storage.write(key: '$_passwordHashKey${user.id}', value: hash);
    }
  }

  Future<User?> getUser() async {
    final data = await _storage.read(key: _userKey);
    if (data == null) return null;

    try {
      final map = jsonDecode(data);
      return User.fromMap(map);
    } catch (e) {
      return null;
    }
  }

  Future<bool> verifyPassword(String email, String password) async {
    final user = await getUser();
    if (user == null) return false;

    final storedHash = await _storage.read(key: '$_passwordHashKey${user.id}');
    if (storedHash == null) return false;

    final computedHash = _simpleHash('$email:$password');
    return storedHash == computedHash;
  }

  String _simpleHash(String input) {
    // Hash simple - en production utiliser bcrypt
    return input.split('').map((c) => c.codeUnitAt(0)).join();
  }

  // ===== PARAMÈTRES =====
  Future<void> saveSettings(Map<String, dynamic> settings) async {
    await _storage.write(key: _settingsKey, value: jsonEncode(settings));
  }

  Future<Map<String, dynamic>?> getSettings() async {
    final data = await _storage.read(key: _settingsKey);
    if (data == null) return null;

    try {
      return jsonDecode(data);
    } catch (e) {
      return null;
    }
  }

  // ===== NETTOYAGE =====
  Future<void> clearAll() async {
    await _storage.deleteAll();
  }
}
