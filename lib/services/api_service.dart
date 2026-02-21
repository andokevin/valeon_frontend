import 'package:dio/dio.dart';  // ✅ FormData, MultipartFile, Options
import 'package:flutter/foundation.dart';  // ✅ debugPrint
import '../core/network/api_client.dart';
import '../core/errors/app_exception.dart';

class ApiService {
  final ApiClient _api = ApiClient.instance;

  // ─── AUTH ───────────────────────────────────────────────────────────────

  Future<Map<String, dynamic>?> login(
    String email,
    String password,
  ) async {
    try {
      final response = await _api.dio.post(
        '/auth/login',
        data: FormData.fromMap({  // ✅ FormData importé
          'username': email,
          'password': password,
        }),
        options: Options(contentType: 'application/x-www-form-urlencoded'),
      );
      return response.data;
    } on DioException catch (e) {  // ✅ DioException au lieu d'Exception
      debugPrint('❌ Login error: ${e.message}');
      throw AppException.fromDio(e);
    }
  }

  Future<Map<String, dynamic>?> register({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final response = await _api.post(
        '/auth/register',
        data: {
          'user_full_name': name,
          'user_email': email,
          'password': password,
          'accept_terms': true,
        },
      );
      return response.data;
    } on DioException catch (e) {
      debugPrint('❌ Register error: ${e.message}');
      throw AppException.fromDio(e);
    }
  }

  // ─── SCANS ──────────────────────────────────────────────────────────────

  Future<Map<String, dynamic>?> scanAudio(String filePath) async {
    try {
      final formData = FormData.fromMap({
        'source': 'file',
        'file': await MultipartFile.fromFile(filePath, filename: 'audio.mp3'),// ✅ MultipartFile importé
      });
      final response = await _api.dio.post(
        '/scans/audio',
        data: formData,
        options: Options(contentType: 'multipart/form-data'),
      );
      return response.data;
    } on DioException catch (e) {
      debugPrint('❌ Scan audio error: ${e.message}');
      throw AppException.fromDio(e);
    }
  }

  Future<Map<String, dynamic>?> getScanResult(String scanId) async {
    try {
      final response = await _api.get('/scans/$scanId');
      return response.data;
    } on DioException catch (e) {
      debugPrint('❌ Get scan result error: ${e.message}');
      throw AppException.fromDio(e);
    }
  }

  // ─── LIBRARY ────────────────────────────────────────────────────────────

  Future<List<Map<String, dynamic>>?> getFavorites() async {
    try {
      final response = await _api.get('/library/favorites');
      return List<Map<String, dynamic>>.from(response.data);
    } on DioException catch (e) {
      debugPrint('❌ Get favorites error: ${e.message}');
      return null;
    }
  }

  Future<bool> addToFavorites(int contentId) async {
    try {
      await _api.post('/library/favorites/$contentId');
      return true;
    } on DioException catch (e) {
      debugPrint('❌ Add favorite error: ${e.message}');
      return false;
    }
  }

  Future<bool> removeFromFavorites(int contentId) async {
    try {
      await _api.delete('/library/favorites/$contentId');
      return true;
    } on DioException catch (e) {
      debugPrint('❌ Remove favorite error: ${e.message}');
      return false;
    }
  }

  // ─── RECOMMENDATIONS ────────────────────────────────────────────────────

  Future<List<Map<String, dynamic>>?> getPersonalizedRecommendations() async {
    try {
      final response = await _api.get('/recommendations/personalized');
      return List<Map<String, dynamic>>.from(response.data);
    } on DioException catch (e) {
      debugPrint('❌ Get recommendations error: ${e.message}');
      return null;
    }
  }

  Future<Map<String, dynamic>?> chatWithAI(String query) async {
    try {
      final response = await _api.post('/recommendations/chat', data: {
        'query': query,
      });
      return response.data;
    } on DioException catch (e) {
      debugPrint('❌ Chat error: ${e.message}');
      return null;
    }
  }

  // ─── USER ───────────────────────────────────────────────────────────────

  Future<Map<String, dynamic>?> getUserProfile() async {
    try {
      final response = await _api.get('/auth/me');
      return response.data;
    } on DioException catch (e) {
      debugPrint('❌ Get profile error: ${e.message}');
      return null;
    }
  }

  Future<bool> updateUserProfile(Map<String, dynamic> data) async {
    try {
      await _api.put('/auth/me', data: data);
      return true;
    } on DioException catch (e) {
      debugPrint('❌ Update profile error: ${e.message}');
      return false;
    }
  }
}
