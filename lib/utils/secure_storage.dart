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

  // ===== TOKEN ============================================================

  Future<void> saveToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
  }

  Future<String?> getToken() async {
    return await _storage.read(key: _tokenKey);
  }

  Future<void> deleteToken() async {
    await _storage.delete(key: _tokenKey);
  }

  // ===== UTILISATEUR ======================================================

  Future<void> saveUser(UserModel user, {String? password}) async {
    await _storage.write(
      key: _userKey,
      value: jsonEncode(user.toJson()),  // ✅ toJson() au lieu de toMap()
    );

    if (password != null) {
      // Hash simple pour authentification offline
      final hash = _simpleHash('${user.userEmail}:$password');
      await _storage.write(
        key: '${_passwordHashKey}${user.userId}',  // ✅ userId (int)
        value: hash,
      );
    }
  }

  Future<UserModel?> getUser() async {
    final data = await _storage.read(key: _userKey);
    if (data == null) return null;

    try {
      final map = jsonDecode(data) as Map<String, dynamic>;
      return UserModel.fromJson(map);  // ✅ fromJson() au lieu de fromMap()
    } catch (e) {
      print('❌ Erreur parsing user: $e');
      return null;
    }
  }

  Future<bool> verifyPassword(String email, String password) async {
    final user = await getUser();
    if (user == null) return false;

    final storedHash = await _storage.read(
      key: '${_passwordHashKey}${user.userId}',  // ✅ userId
    );
    if (storedHash == null) return false;

    final computedHash = _simpleHash('$email:$password');
    return storedHash == computedHash;
  }

  String _simpleHash(String input) {
    // Hash simple (production : bcrypt)
    return input.split('').map((c) => c.codeUnitAt(0)).join();
  }

  // ===== PARAMÈTRES ========================================================

  Future<void> saveSettings(Map<String, dynamic> settings) async {
    await _storage.write(key: _settingsKey, value: jsonEncode(settings));
  }

  Future<Map<String, dynamic>?> getSettings() async {
    final data = await _storage.read(key: _settingsKey);
    if (data == null) return null;

    try {
      return jsonDecode(data) as Map<String, dynamic>;
    } catch (e) {
      print('❌ Erreur parsing settings: $e');
      return null;
    }
  }

  // ===== NETTOYAGE ========================================================

  Future<void> clearAll() async {
    await _storage.deleteAll();
  }
}
