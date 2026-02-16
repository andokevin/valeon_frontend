import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = authService;
  User? _user;
  bool _isLoading = false;
  String? _errorMessage;

  AuthProvider() {
    print('🟣 AuthProvider initialisé');
    _initAuthListener();
  }

  void _initAuthListener() {
    _authService.user.listen((User? user) {
      print(
        '🟢 Auth state changed - utilisateur: ${user?.email ?? 'Déconnecté'}',
      );
      _user = user;
      notifyListeners();
    });
  }

  // Getters
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
      print('🟡 Début inscription: $email');
      final user = await _authService.signUpWithEmail(email, password, name);

      if (user != null) {
        print('🟢 Inscription réussie pour: ${user.email}');
        _user = user; // Mise à jour manuelle
        notifyListeners();
        _setLoading(false);
        return true;
      } else {
        print('🔴 Échec inscription');
        _setError('Erreur lors de l\'inscription');
        _setLoading(false);
        return false;
      }
    } catch (e) {
      print('🔴 Erreur inscription: $e');
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
      print('🟡 Début connexion email: $email');
      final user = await _authService.signInWithEmail(email, password);

      if (user != null) {
        print('🟢 Connexion email réussie pour: ${user.email}');
        _user = user; // Mise à jour manuelle
        notifyListeners();
        _setLoading(false);
        return true;
      } else {
        print('🔴 Échec connexion email');
        _setError('Email ou mot de passe incorrect');
        _setLoading(false);
        return false;
      }
    } catch (e) {
      print('🔴 Erreur connexion email: $e');
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
      print('🟡 Début connexion Google');
      final user = await _authService.signInWithGoogle();

      if (user != null) {
        print('🟢 Connexion Google réussie pour: ${user.email}');
        print('🟢 Mise à jour manuelle de _user');
        _user = user; // MISE À JOUR MANUELLE CRITIQUE
        notifyListeners();
        print('🟢 _user après mise à jour: ${_user?.email}');
        print('🟢 isAuthenticated: $isAuthenticated');
        _setLoading(false);
        return true;
      } else {
        print('🟡 Connexion Google annulée');
        _setLoading(false);
        return false;
      }
    } catch (e) {
      print('🔴 Erreur Google: $e');
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
      print('🟡 Début connexion Facebook');
      final user = await _authService.signInWithFacebook();

      if (user != null) {
        print('🟢 Connexion Facebook réussie pour: ${user.email}');
        print('🟢 Mise à jour manuelle de _user');
        _user = user; // MISE À JOUR MANUELLE CRITIQUE
        notifyListeners();
        print('🟢 _user après mise à jour: ${_user?.email}');
        print('🟢 isAuthenticated: $isAuthenticated');
        _setLoading(false);
        return true;
      } else {
        print('🟡 Connexion Facebook annulée');
        _setLoading(false);
        return false;
      }
    } catch (e) {
      print('🔴 Erreur Facebook: $e');
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
      print('🟡 Début connexion Apple');
      final user = await _authService.signInWithApple();

      if (user != null) {
        print('🟢 Connexion Apple réussie pour: ${user.email}');
        _user = user; // Mise à jour manuelle
        notifyListeners();
        _setLoading(false);
        return true;
      } else {
        print('🟡 Connexion Apple annulée');
        _setLoading(false);
        return false;
      }
    } catch (e) {
      print('🔴 Erreur Apple: $e');
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  // ===== RÉINITIALISATION MOT DE PASSE =====
  Future<bool> resetPassword(String email) async {
    _setLoading(true);
    _clearError();

    try {
      print('🟡 Envoi reset password à: $email');
      await _authService.resetPassword(email);
      print('🟢 Email de réinitialisation envoyé');
      _setLoading(false);
      return true;
    } catch (e) {
      print('🔴 Erreur reset password: $e');
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  // ===== DÉCONNEXION =====
  Future<void> signOut() async {
    _setLoading(true);

    try {
      print('🟡 Début déconnexion');
      await _authService.signOut();
      _user = null; // Mise à jour manuelle
      notifyListeners();
      print('🟢 Déconnexion réussie');
    } catch (e) {
      print('🔴 Erreur déconnexion: $e');
      _setError(e.toString());
    }

    _setLoading(false);
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

  // Rafraîchir manuellement l'utilisateur
  Future<void> refreshUser() async {
    try {
      await _user?.reload();
      _user = _authService.currentUser;
      notifyListeners();
      print('🟢 Utilisateur rafraîchi: ${_user?.email}');
    } catch (e) {
      print('🔴 Erreur refresh: $e');
    }
  }

  // Vérifier l'état actuel (utile pour debug)
  void checkAuthState() {
    print('📊 État actuel:');
    print('  - isAuthenticated: $isAuthenticated');
    print('  - user: ${_user?.email ?? 'null'}');
    print('  - isLoading: $_isLoading');
    print('  - errorMessage: $_errorMessage');
  }
}
