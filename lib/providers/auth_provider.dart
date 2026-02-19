// lib/providers/auth_provider.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import '../services/auth_service.dart';
import '../core/database/database_service.dart';
import '../core/network/connectivity_service.dart';
import '../utils/secure_storage.dart';
import '../models/user_model.dart' as user_local;

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = authService;
  final DatabaseService _db = DatabaseService();
  final ConnectivityService _connectivity = ConnectivityService();
  final SecureStorage _secureStorage = SecureStorage();

  fb.User? _firebaseUser;
  user_local.User? _user;
  bool _isLoading = false;
  String? _errorMessage;
  bool _isOfflineMode = false;

  // Getters
  String get getUserName =>
      _user?.fullName ?? _user?.displayName ?? 'Utilisateur';
  String get getUserEmail => _user?.email ?? 'email inconnu';
  String? get getUserProfilePicture => _user?.photoUrl;
  fb.User? get firebaseUser => _firebaseUser;
  user_local.User? get user => _user;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _user != null;
  bool get isOfflineMode => _isOfflineMode;

  AuthProvider() {
    _initAuthListener();
    _connectivity.addListener(_onConnectivityChanged);
  }

  void _initAuthListener() {
    _authService.user.listen((fb.User? firebaseUser) {
      _firebaseUser = firebaseUser;
      _loadUserData();
    });
  }

  void _onConnectivityChanged() {
    if (_connectivity.isOnline && _user != null) {
      _syncUserData();
    }
    notifyListeners();
  }

  Future<void> _loadUserData() async {
    if (_firebaseUser != null) {
      // Charger depuis SQLite d'abord
      final localUser = await _db.getUser(_firebaseUser!.uid);

      if (localUser != null) {
        _user = localUser;
        _isOfflineMode = !_connectivity.isOnline;
      } else {
        // Sinon créer depuis Firebase
        _user = user_local.User.fromFirebase(_firebaseUser!);
        await _db.upsertUser(_user!);
      }

      // Synchroniser si connecté
      if (_connectivity.isOnline) {
        _syncUserData();
      }
    } else {
      _user = null;
    }
    notifyListeners();
  }

  Future<void> _syncUserData() async {
    try {
      // TODO: Appeler API backend pour synchroniser
      await _db.upsertUser(_user!);
      await _secureStorage.saveUser(_user!);
    } catch (e) {
      print('❌ Erreur sync user: $e');
    }
  }

  // ===== INSCRIPTION =====
  Future<bool> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final firebaseUser = await _authService.signUpWithEmail(
        email,
        password,
        name,
      );

      if (firebaseUser != null) {
        _firebaseUser = firebaseUser;
        _user = user_local.User.fromFirebase(firebaseUser);

        // Sauvegarder localement
        await _db.upsertUser(_user!);
        await _secureStorage.saveUser(_user!);

        // Synchroniser si connecté
        if (_connectivity.isOnline) {
          await _syncUserData();
        }

        _setLoading(false);
        return true;
      }
    } catch (e) {
      _setError(e.toString());
    }

    _setLoading(false);
    return false;
  }

  // ===== CONNEXION EMAIL =====
  Future<bool> signIn({required String email, required String password}) async {
    _setLoading(true);
    _clearError();

    try {
      // Essayer d'abord en local (offline)
      final localUser = await _db.getUserByEmail(email);

      if (localUser != null && !_connectivity.isOnline) {
        // Mode offline - vérifier avec le hash stocké
        final isValid = await _secureStorage.verifyPassword(email, password);

        if (isValid) {
          _user = localUser;
          _isOfflineMode = true;
          _setLoading(false);
          return true;
        }
      }

      // Mode online - appel Firebase
      if (_connectivity.isOnline) {
        final firebaseUser = await _authService.signInWithEmail(
          email,
          password,
        );

        if (firebaseUser != null) {
          _firebaseUser = firebaseUser;
          _user = user_local.User.fromFirebase(firebaseUser);

          await _db.upsertUser(_user!);
          await _secureStorage.saveUser(_user!, password: password);

          _setLoading(false);
          return true;
        }
      } else {
        _setError('Mode hors ligne - Identifiants non trouvés localement');
      }
    } catch (e) {
      _setError(e.toString());
    }

    _setLoading(false);
    return false;
  }

  // ===== CONNEXION GOOGLE =====
  Future<bool> signInWithGoogle() async {
    if (!_connectivity.isOnline) {
      _setError('Connexion internet requise pour Google Sign-In');
      return false;
    }

    _setLoading(true);
    _clearError();

    try {
      final firebaseUser = await _authService.signInWithGoogle();

      if (firebaseUser != null) {
        _firebaseUser = firebaseUser;
        _user = user_local.User.fromFirebase(firebaseUser);

        await _db.upsertUser(_user!);
        await _secureStorage.saveUser(_user!);

        _setLoading(false);
        return true;
      }
    } catch (e) {
      _setError(e.toString());
    }

    _setLoading(false);
    return false;
  }

  // ===== CONNEXION FACEBOOK =====
  Future<bool> signInWithFacebook() async {
    if (!_connectivity.isOnline) {
      _setError('Connexion internet requise pour Facebook Sign-In');
      return false;
    }

    _setLoading(true);
    _clearError();

    try {
      final firebaseUser = await _authService.signInWithFacebook();

      if (firebaseUser != null) {
        _firebaseUser = firebaseUser;
        _user = user_local.User.fromFirebase(firebaseUser);

        await _db.upsertUser(_user!);
        await _secureStorage.saveUser(_user!);

        _setLoading(false);
        return true;
      }
    } catch (e) {
      _setError(e.toString());
    }

    _setLoading(false);
    return false;
  }

  // ===== RÉINITIALISATION MOT DE PASSE =====
  Future<bool> resetPassword(String email) async {
    _setLoading(true);
    _clearError();

    try {
      if (!_connectivity.isOnline) {
        _setError(
          'Connexion internet requise pour réinitialiser le mot de passe',
        );
        _setLoading(false);
        return false;
      }

      await _authService.resetPassword(email);

      _setLoading(false);
      return true;
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
      _firebaseUser = null;
      _user = null;
      _isOfflineMode = false;
      notifyListeners();
    } catch (e) {
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

  @override
  void dispose() {
    _connectivity.removeListener(_onConnectivityChanged);
    super.dispose();
  }
}
