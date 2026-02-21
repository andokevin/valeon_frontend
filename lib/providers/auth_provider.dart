import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

enum AuthStatus {
  initial,
  loading,
  authenticated,
  unauthenticated,
  error,
}

class AuthState {
  final AuthStatus status;
  final UserModel? user;
  final String? error;
  final bool isPremium;

  const AuthState({
    this.status = AuthStatus.initial,
    this.user,
    this.error,
    this.isPremium = false,
  });

  AuthState copyWith({
    AuthStatus? status,
    UserModel? user,
    String? error,
    bool? isPremium,
  }) =>
      AuthState(
        status: status ?? this.status,
        user: user ?? this.user,
        error: error ?? this.error,
        isPremium: isPremium ?? this.isPremium,
      );
}

class AuthProvider extends StateNotifier<AuthState> {
  final AuthService _service;

  AuthProvider(this._service) : super(const AuthState()) {
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkAuth());
  }

  // ─── CHECK INITIAL ───────────────────────────────────────────────────────

  Future<void> _checkAuth() async {
    debugPrint('🔄 [Auth] _checkAuth started');
    state = state.copyWith(status: AuthStatus.loading);

    if (await _service.isLoggedIn()) {
      debugPrint('🔑 [Auth] Token found — fetching profile...');
      try {
        final user = await _service.getProfile();
        debugPrint('✅ [Auth] Profile loaded: ${user.toString()}');
        state = AuthState(
          status: AuthStatus.authenticated,
          user: user,
          isPremium: user.isPremium,
        );
      } catch (e, stack) {
        debugPrint('❌ [Auth] _checkAuth getProfile ERROR: $e');
        debugPrint('❌ [Auth] StackTrace: $stack');
        state = const AuthState(status: AuthStatus.unauthenticated);
      }
    } else {
      debugPrint('🔓 [Auth] No token found — unauthenticated');
      state = const AuthState(status: AuthStatus.unauthenticated);
    }
  }

  // ─── EMAIL / PASSWORD ────────────────────────────────────────────────────

  Future<void> login(String email, String password) async {
    debugPrint('🔄 [Auth] login() called with email: $email');
    state = state.copyWith(status: AuthStatus.loading);
    try {
      await _service.login(email: email, password: password);
      debugPrint('✅ [Auth] login() success — fetching profile...');
      final user = await _service.getProfile();
      debugPrint('✅ [Auth] Profile: ${user.toString()}');
      state = AuthState(
        status: AuthStatus.authenticated,
        user: user,
        isPremium: user.isPremium,
      );
    } catch (e, stack) {
      debugPrint('❌ [Auth] login() ERROR: $e');
      debugPrint('❌ [Auth] ERROR TYPE: ${e.runtimeType}');
      debugPrint('❌ [Auth] StackTrace: $stack');
      state = AuthState(
        status: AuthStatus.error,
        error: e.toString(),
      );
    }
  }

  Future<void> register(String fullName, String email, String password) async {
    debugPrint('🔄 [Auth] register() called with email: $email');
    state = state.copyWith(status: AuthStatus.loading);
    try {
      await _service.register(
        fullName: fullName,
        email: email,
        password: password,
      );
      debugPrint('✅ [Auth] register() success — fetching profile...');
      final user = await _service.getProfile();
      debugPrint('✅ [Auth] Profile: ${user.toString()}');
      state = AuthState(
        status: AuthStatus.authenticated,
        user: user,
        isPremium: user.isPremium,
      );
    } catch (e, stack) {
      debugPrint('❌ [Auth] register() ERROR: $e');
      debugPrint('❌ [Auth] ERROR TYPE: ${e.runtimeType}');
      debugPrint('❌ [Auth] StackTrace: $stack');
      state = AuthState(
        status: AuthStatus.error,
        error: e.toString(),
      );
    }
  }

  // ─── SOCIAL LOGIN ───────────────────────────────────────────────────────

  Future<void> loginWithGoogle() async {
    debugPrint('🔄 [Auth] loginWithGoogle() called');
    state = state.copyWith(status: AuthStatus.loading);
    try {
      await _service.loginWithGoogle();
      debugPrint('✅ [Auth] loginWithGoogle() success — fetching profile...');
      final user = await _service.getProfile();
      debugPrint('✅ [Auth] Profile: ${user.toString()}');
      state = AuthState(
        status: AuthStatus.authenticated,
        user: user,
        isPremium: user.isPremium,
      );
    } catch (e, stack) {
      debugPrint('❌ [Auth] loginWithGoogle() ERROR: $e');
      debugPrint('❌ [Auth] ERROR TYPE: ${e.runtimeType}');
      debugPrint('❌ [Auth] StackTrace: $stack');
      state = AuthState(
        status: AuthStatus.error,
        error: e.toString(),
      );
    }
  }

  Future<void> loginWithFacebook() async {
    debugPrint('🔄 [Auth] loginWithFacebook() called');
    state = state.copyWith(status: AuthStatus.loading);
    try {
      await _service.loginWithFacebook();
      debugPrint('✅ [Auth] loginWithFacebook() success — fetching profile...');
      final user = await _service.getProfile();
      debugPrint('✅ [Auth] Profile: ${user.toString()}');
      state = AuthState(
        status: AuthStatus.authenticated,
        user: user,
        isPremium: user.isPremium,
      );
    } catch (e, stack) {
      debugPrint('❌ [Auth] loginWithFacebook() ERROR: $e');
      debugPrint('❌ [Auth] ERROR TYPE: ${e.runtimeType}');
      debugPrint('❌ [Auth] StackTrace: $stack');
      state = AuthState(
        status: AuthStatus.error,
        error: e.toString(),
      );
    }
  }

  // ─── UTILITAIRES ────────────────────────────────────────────────────────

  Future<void> logout() async {
    debugPrint('🔄 [Auth] logout() called');
    await _service.logout();
    debugPrint('✅ [Auth] logout() success');
    state = const AuthState(status: AuthStatus.unauthenticated);
  }

  void clearError() {
    debugPrint('🧹 [Auth] clearError() called');
    state = state.copyWith(
      status: AuthStatus.unauthenticated,
      error: null,
    );
  }

  Future<void> refreshProfile() async {
    if (state.status != AuthStatus.authenticated) return;
    debugPrint('🔄 [Auth] refreshProfile() called');
    try {
      final user = await _service.getProfile();
      debugPrint('✅ [Auth] refreshProfile() success');
      state = state.copyWith(user: user, isPremium: user.isPremium);
    } catch (e, stack) {
      debugPrint('❌ [Auth] refreshProfile() ERROR: $e');
      debugPrint('❌ [Auth] StackTrace: $stack');
      state = const AuthState(status: AuthStatus.unauthenticated);
    }
  }
}

// ─── PROVIDERS ───────────────────────────────────────────────────────────────

final authServiceProvider = Provider((ref) => AuthService());

final authProvider = StateNotifierProvider<AuthProvider, AuthState>(
  (ref) => AuthProvider(ref.watch(authServiceProvider)),
);

final currentUserProvider = Provider<UserModel?>(
  (ref) => ref.watch(authProvider).user,
);

final isAuthenticatedProvider = Provider<bool>(
  (ref) => ref.watch(authProvider).status == AuthStatus.authenticated,
);

final isPremiumProvider = Provider<bool>(
  (ref) => ref.watch(authProvider).isPremium,
);

final authStatusProvider = Provider<AuthStatus>(
  (ref) => ref.watch(authProvider).status,
);
