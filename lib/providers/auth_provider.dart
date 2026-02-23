// lib/providers/auth_provider.dart
import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../core/database/database_service.dart';
import '../core/network/connectivity_service.dart';
import '../utils/secure_storage.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;

enum AuthStatus { initial, loading, authenticated, unauthenticated, error }

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final DatabaseService _db = DatabaseService();
  final ConnectivityService _connectivity = ConnectivityService();
  final SecureStorage _secureStorage = SecureStorage();

  UserModel? _user;
  fb.User? _firebaseUser;
  AuthStatus _status = AuthStatus.initial;
  String? _errorMessage;
  bool _isOfflineMode = false;

  UserModel? get user => _user;
  AuthStatus get status => _status;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _status == AuthStatus.loading;
  bool get isAuthenticated => _status == AuthStatus.authenticated;
  bool get isOfflineMode => _isOfflineMode;

  String get userName => _user?.displayName ?? 'Utilisateur';
  String get userEmail => _user?.userEmail ?? '';
  String? get userImage => _user?.userImage;
  bool get isPremium => _user?.isPremium ?? false;
  fb.User? get firebaseUser => _firebaseUser;

  AuthProvider() {
    _init();
    _connectivity.addListener(_onConnectivityChanged);
  }

  void _init() {
    _checkAuth();
  }

  void _onConnectivityChanged() {
    if (_connectivity.isOnline && _user != null) {
      _syncUserData();
    }
    notifyListeners();
  }

  Future<void> _checkAuth() async {
    _status = AuthStatus.loading;
    notifyListeners();

    try {
      final isLoggedIn = await _authService.isLoggedIn();

      if (isLoggedIn) {
        try {
          final user = await _authService.getProfile();
          _user = user;
          await _db.upsertUser(user);
          await _secureStorage.saveUser(user);
          _status = AuthStatus.authenticated;
          _isOfflineMode = false;
        } catch (e) {
          // Mode offline - chercher dans la base locale
          final userId = await _secureStorage.getUserId();
          if (userId != null) {
            final localUser = await _db.getUser(userId);
            if (localUser != null) {
              _user = localUser;
              _status = AuthStatus.authenticated;
              _isOfflineMode = true;
            } else {
              _status = AuthStatus.unauthenticated;
            }
          } else {
            _status = AuthStatus.unauthenticated;
          }
        }
      } else {
        _status = AuthStatus.unauthenticated;
      }
    } catch (e) {
      _status = AuthStatus.error;
      _errorMessage = e.toString();
    }

    notifyListeners();
  }

  Future<void> _syncUserData() async {
    if (_user == null) return;
    try {
      await _db.upsertUser(_user!);
      await _secureStorage.saveUser(_user!);
    } catch (e) {
      debugPrint('❌ Erreur sync user: $e');
    }
  }

  Future<bool> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final token = await _authService.register(
        fullName: name,
        email: email,
        password: password,
      );

      final user = await _authService.getProfile();
      _user = user;
      await _db.upsertUser(user);
      await _secureStorage.saveUser(user, password: password);
      await _secureStorage.saveToken(token.accessToken);
      await _secureStorage.saveRefreshToken(token.refreshToken);
      await _secureStorage.saveUserId(user.userId);

      _status = AuthStatus.authenticated;
      _isOfflineMode = false;
      notifyListeners();
      return true;
    } catch (e) {
      _status = AuthStatus.error;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> signIn({required String email, required String password}) async {
    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      // Essayer d'abord en mode offline
      final localUser = await _db.getUserByEmail(email);
      if (localUser != null && !_connectivity.isOnline) {
        final isValid = await _secureStorage.verifyPassword(email, password);
        if (isValid) {
          _user = localUser;
          _status = AuthStatus.authenticated;
          _isOfflineMode = true;
          notifyListeners();
          return true;
        }
      }

      // Mode online
      if (_connectivity.isOnline) {
        final token =
            await _authService.login(email: email, password: password);
        final user = await _authService.getProfile();
        _user = user;
        await _db.upsertUser(user);
        await _secureStorage.saveUser(user, password: password);
        await _secureStorage.saveToken(token.accessToken);
        await _secureStorage.saveRefreshToken(token.refreshToken);
        await _secureStorage.saveUserId(user.userId);

        _status = AuthStatus.authenticated;
        _isOfflineMode = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = 'Mode hors ligne - Identifiants non trouvés localement';
        _status = AuthStatus.error;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _status = AuthStatus.error;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> signInWithGoogle() async {
    if (!_connectivity.isOnline) {
      _errorMessage = 'Connexion internet requise pour Google Sign-In';
      _status = AuthStatus.error;
      notifyListeners();
      return false;
    }

    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final token = await _authService.loginWithGoogle();
      final user = await _authService.getProfile();
      _user = user;
      await _db.upsertUser(user);
      await _secureStorage.saveUser(user);
      await _secureStorage.saveToken(token.accessToken);
      await _secureStorage.saveRefreshToken(token.refreshToken);
      await _secureStorage.saveUserId(user.userId);

      _status = AuthStatus.authenticated;
      notifyListeners();
      return true;
    } catch (e) {
      _status = AuthStatus.error;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> signInWithFacebook() async {
    if (!_connectivity.isOnline) {
      _errorMessage = 'Connexion internet requise pour Facebook Sign-In';
      _status = AuthStatus.error;
      notifyListeners();
      return false;
    }

    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final token = await _authService.loginWithFacebook();
      final user = await _authService.getProfile();
      _user = user;
      await _db.upsertUser(user);
      await _secureStorage.saveUser(user);
      await _secureStorage.saveToken(token.accessToken);
      await _secureStorage.saveRefreshToken(token.refreshToken);
      await _secureStorage.saveUserId(user.userId);

      _status = AuthStatus.authenticated;
      notifyListeners();
      return true;
    } catch (e) {
      _status = AuthStatus.error;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> resetPassword(String email) async {
    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      if (!_connectivity.isOnline) {
        _errorMessage = 'Connexion internet requise';
        _status = AuthStatus.error;
        notifyListeners();
        return false;
      }

      await _authService.resetPassword(email);
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      return true;
    } catch (e) {
      _status = AuthStatus.error;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<void> signOut() async {
    _status = AuthStatus.loading;
    notifyListeners();

    try {
      await _authService.logout();
      _user = null;
      _status = AuthStatus.unauthenticated;
      _isOfflineMode = false;
    } catch (e) {
      _errorMessage = e.toString();
      _status = AuthStatus.error;
    }

    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    if (_status == AuthStatus.error) {
      _status = AuthStatus.unauthenticated;
    }
    notifyListeners();
  }

  @override
  void dispose() {
    _connectivity.removeListener(_onConnectivityChanged);
    super.dispose();
  }
}
