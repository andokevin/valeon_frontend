import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import '../core/constants/app_constants.dart';
import '../core/errors/app_exception.dart';
import '../core/network/api_client.dart';
import '../models/auth_model.dart';
import '../models/user_model.dart';

class AuthService {
  final _api = ApiClient.instance;
  final _storage = const FlutterSecureStorage();
  final _firebaseAuth = FirebaseAuth.instance;

  // ✅ serverClientId obligatoire pour récupérer idToken sur Android
  final _googleSignIn = GoogleSignIn(
    serverClientId: 'VOTRE_WEB_CLIENT_ID.apps.googleusercontent.com',
  );

  // ─── EMAIL / PASSWORD ────────────────────────────────────────────────────

  Future<AuthTokenModel> register({
    required String fullName,
    required String email,
    required String password,
  }) async {
    try {
      final res = await _api.post('/auth/register', data: {
        'user_full_name': fullName,
        'user_email': email,
        'password': password,
        'accept_terms': true,
      });
      final token = AuthTokenModel.fromJson(res.data);
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
      final res = await _api.dio.post(
        '/auth/login',
        data: FormData.fromMap({'username': email, 'password': password}),
        options: Options(contentType: 'application/x-www-form-urlencoded'),
      );
      final token = AuthTokenModel.fromJson(res.data);
      await _saveTokens(token);
      return token;
    } on DioException catch (e) {
      throw AppException.fromDio(e);
    }
  }

  // ─── GOOGLE SIGN-IN ─────────────────────────────────────────────────────

  Future<AuthTokenModel> loginWithGoogle() async {
    try {
      // ✅ Force disconnect pour éviter cache compte précédent
      await _googleSignIn.signOut();

      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        throw const AppException('Connexion Google annulée');
      }

      final googleAuth = await googleUser.authentication;

      // ✅ Debug logs pour vérifier les tokens
      debugPrint('✅ Google accessToken: ${googleAuth.accessToken != null}');
      debugPrint('✅ Google idToken: ${googleAuth.idToken != null}');

      if (googleAuth.idToken == null) {
        throw const AppException(
          'idToken Google null — vérifiez le serverClientId dans Firebase',
        );
      }

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential =
          await _firebaseAuth.signInWithCredential(credential);
      final firebaseToken = await userCredential.user?.getIdToken();

      debugPrint('✅ Firebase token: ${firebaseToken != null}');

      if (firebaseToken == null) {
        throw const AppException('Token Firebase invalide');
      }

      final res = await _api.post('/auth/social-login', data: {
        'provider': 'google',
        'firebase_token': firebaseToken,
        'user_full_name': googleUser.displayName ?? '',
        'user_email': googleUser.email ?? '',
        'user_image': googleUser.photoUrl,
      });

      debugPrint('✅ Backend response: ${res.statusCode} | ${res.data}');

      final token = AuthTokenModel.fromJson(res.data);
      await _saveTokens(token);
      return token;
    } on AppException {
      rethrow;
    } catch (e) {
      debugPrint('❌ Google Sign-In error: $e');
      throw AppException('Erreur Google Sign-In: $e');
    }
  }

  // ─── FACEBOOK SIGN-IN ───────────────────────────────────────────────────

  Future<AuthTokenModel> loginWithFacebook() async {
    try {
      final result = await FacebookAuth.instance.login(
        permissions: ['email', 'public_profile'],
      );

      if (result.status != LoginStatus.success || result.accessToken == null) {
        throw const AppException('Connexion Facebook annulée ou refusée');
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

      final res = await _api.post('/auth/social-login', data: {
        'provider': 'facebook',
        'firebase_token': firebaseToken,
        'user_full_name': userData['name'] ?? '',
        'user_email': userData['email'] ?? userCredential.user?.email ?? '',
        'user_image': userData['picture']?['data']?['url'],
      });

      final token = AuthTokenModel.fromJson(res.data);
      await _saveTokens(token);
      return token;
    } on AppException {
      rethrow;
    } catch (e) {
      debugPrint('❌ Facebook Sign-In error: $e');
      throw AppException('Erreur Facebook Sign-In: $e');
    }
  }

  // ─── UTILITAIRES ───────────────────────────────────────────────────────

  Future<UserModel> getProfile() async {
    try {
      final res = await _api.get('/auth/me');
      return UserModel.fromJson(res.data);
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
}
