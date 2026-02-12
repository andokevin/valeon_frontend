import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = authService;
  User? _user;
  bool _isLoading = false;
  String? _errorMessage;

  AuthProvider() {
    _authService.user.listen((User? user) {
      _user = user;
      notifyListeners();
    });
  }

  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _user != null;

  // ===== INSCRIPTION =====
  Future<bool> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final user = await _authService.signUpWithEmail(email, password, name);
      _setLoading(false);
      return user != null;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  // ===== CONNEXION EMAIL =====
  Future<bool> signIn({required String email, required String password}) async {
    _setLoading(true);
    _clearError();

    try {
      final user = await _authService.signInWithEmail(email, password);
      _setLoading(false);
      return user != null;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  // ===== CONNEXION GOOGLE =====
  Future<bool> signInWithGoogle() async {
    _setLoading(true);
    _clearError();

    try {
      final user = await _authService.signInWithGoogle();
      _setLoading(false);
      return user != null;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  // ===== CONNEXION APPLE =====
  Future<bool> signInWithApple() async {
    _setLoading(true);
    _clearError();

    try {
      final user = await _authService.signInWithApple();
      _setLoading(false);
      return user != null;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  // ===== CONNEXION FACEBOOK =====
  Future<bool> signInWithFacebook() async {
    _setLoading(true);
    _clearError();

    try {
      final user = await _authService.signInWithFacebook();
      _setLoading(false);
      return user != null;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  // ===== DÉCONNEXION =====
  Future<void> signOut() async {
    _setLoading(true);
    try {
      await _authService.signOut();
    } catch (e) {
      _setError(e.toString());
    }
    _setLoading(false);
  }

  // ===== RÉINITIALISATION MOT DE PASSE =====
  Future<bool> resetPassword(String email) async {
    _setLoading(true);
    _clearError();

    try {
      await _authService.resetPassword(email);
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  // ===== UTILITAIRES =====
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  String? getUserName() {
    return _user?.displayName ??
        _user?.email?.split('@').first ??
        'Utilisateur';
  }

  String? getUserEmail() {
    return _user?.email;
  }

  String? getPhotoUrl() {
    return _user?.photoURL;
  }
}
