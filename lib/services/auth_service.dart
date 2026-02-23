// lib/services/auth_service.dart
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:valeon/config/app_constants.dart';
import '../core/errors/app_exception.dart';
import '../core/network/api_client.dart';
import '../models/auth_model.dart';
import '../models/user_model.dart';

class AuthService {
  final ApiClient _api = ApiClient();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  AuthService() {
    _api.init();
  }

  // ===== EMAIL / PASSWORD =====
  Future<AuthTokenModel> register({
    required String fullName,
    required String email,
    required String password,
  }) async {
    try {
      final response = await _api.post('/auth/register', data: {
        'user_full_name': fullName,
        'user_email': email,
        'password': password,
        'accept_terms': true,
      });
      final token = AuthTokenModel.fromJson(response.data);
      await _saveTokens(token);
      return token;
    } on DioException catch (e) {
      throw AppException.fromDio(e);
    }
  }

  Future<AuthTokenModel> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _api.post(
        '/auth/login',
        data: FormData.fromMap({'username': email, 'password': password}),
      );
      final token = AuthTokenModel.fromJson(response.data);
      await _saveTokens(token);
      return token;
    } on DioException catch (e) {
      throw AppException.fromDio(e);
    }
  }

  // ===== GOOGLE SIGN-IN =====
  Future<AuthTokenModel> loginWithGoogle() async {
    try {
      await _googleSignIn.signOut();

      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        throw const AppException('Connexion Google annulée');
      }

      final googleAuth = await googleUser.authentication;

      if (googleAuth.idToken == null) {
        throw const AppException('idToken Google null');
      }

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential =
          await _firebaseAuth.signInWithCredential(credential);
      final firebaseToken = await userCredential.user?.getIdToken();

      if (firebaseToken == null) {
        throw const AppException('Token Firebase invalide');
      }

      final response = await _api.post('/auth/social-login', data: {
        'provider': 'google',
        'firebase_token': firebaseToken,
        'user_full_name': googleUser.displayName ?? '',
        'user_email': googleUser.email ?? '',
        'user_image': googleUser.photoUrl,
      });

      final token = AuthTokenModel.fromJson(response.data);
      await _saveTokens(token);
      return token;
    } on DioException catch (e) {
      throw AppException.fromDio(e);
    }
  }

  // ===== FACEBOOK SIGN-IN =====
  Future<AuthTokenModel> loginWithFacebook() async {
    try {
      final result = await FacebookAuth.instance.login(
        permissions: ['email', 'public_profile'],
      );

      if (result.status != LoginStatus.success || result.accessToken == null) {
        throw const AppException('Connexion Facebook annulée');
      }

      final credential = FacebookAuthProvider.credential(
        result.accessToken!.tokenString,
      );

      final userCredential =
          await _firebaseAuth.signInWithCredential(credential);
      final firebaseToken = await userCredential.user?.getIdToken();

      if (firebaseToken == null) {
        throw const AppException('Token Firebase invalide');
      }

      final userData = await FacebookAuth.instance.getUserData(
        fields: 'name,email,picture.width(200)',
      );

      final response = await _api.post('/auth/social-login', data: {
        'provider': 'facebook',
        'firebase_token': firebaseToken,
        'user_full_name': userData['name'] ?? '',
        'user_email': userData['email'] ?? userCredential.user?.email ?? '',
        'user_image': userData['picture']?['data']?['url'],
      });

      final token = AuthTokenModel.fromJson(response.data);
      await _saveTokens(token);
      return token;
    } on DioException catch (e) {
      throw AppException.fromDio(e);
    }
  }

  // ===== UTILITAIRES =====
  Future<UserModel> getProfile() async {
    try {
      final response = await _api.get('/auth/me');
      return UserModel.fromJson(response.data);
    } on DioException catch (e) {
      throw AppException.fromDio(e);
    }
  }

  Future<void> logout() async {
    try {
      await _api.post('/auth/logout');
      await _googleSignIn.signOut();
      await FacebookAuth.instance.logOut();
      await _firebaseAuth.signOut();
    } catch (_) {}
    await _storage.deleteAll();
  }

  Future<bool> isLoggedIn() async {
    final token = await _storage.read(key: AppConstants.accessTokenKey);
    return token != null;
  }

  Future<String?> getAccessToken() =>
      _storage.read(key: AppConstants.accessTokenKey);

  Future<void> _saveTokens(AuthTokenModel token) async {
    await _storage.write(
      key: AppConstants.accessTokenKey,
      value: token.accessToken,
    );
    await _storage.write(
      key: AppConstants.refreshTokenKey,
      value: token.refreshToken,
    );
  }

  Future<void> resetPassword(String email) async {
    try {
      await _api.post('/auth/reset-password', data: {'email': email});
    } on DioException catch (e) {
      throw AppException.fromDio(e);
    }
  }
}
