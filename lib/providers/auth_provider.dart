// lib/providers/auth_provider.dart
import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../core/network/connectivity_service.dart';
import '../utils/secure_storage.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;

enum AuthStatus { initial, loading, authenticated, unauthenticated, error }

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final ConnectivityService _connectivity = ConnectivityService();
  final SecureStorage _secureStorage = SecureStorage();

  UserModel? _user;
  fb.User? _firebaseUser;
  AuthStatus _status = AuthStatus.initial;
  String? _errorMessage;

  UserModel? get user => _user;
  AuthStatus get status => _status;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _status == AuthStatus.loading;
  bool get isAuthenticated => _status == AuthStatus.authenticated;

  String get userName => _user?.displayName ?? 'Utilisateur';
  String get userEmail => _user?.userEmail ?? '';
  String? get userImage => _user?.userImage;
  bool get isPremium => _user?.isPremium ?? false;
  fb.User? get firebaseUser => _firebaseUser;

  AuthProvider() {
    _init();
  }

  void _init() {
    _checkAuth();
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
          await _secureStorage.saveUser(user);
          _status = AuthStatus.authenticated;
        } catch (e) {
          _status = AuthStatus.unauthenticated;
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

  Future<bool> signIn({required String email, required String password}) async {
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

      final token = await _authService.login(email: email, password: password);
      final user = await _authService.getProfile();
      _user = user;
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
}
