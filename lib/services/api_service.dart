// lib/services/api_service.dart
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../core/network/api_client.dart';
import '../core/errors/app_exception.dart';

class ApiService {
  final ApiClient _api = ApiClient();

  ApiService() {
    _api.init();
  }

  // ===== AUTH =====
  Future<Map<String, dynamic>?> login(String email, String password) async {
    try {
      final response = await _api.post(
        '/auth/login',
        data: FormData.fromMap({'username': email, 'password': password}),
      );
      return response.data;
    } on DioException catch (e) {
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

  // ===== SCANS =====
  Future<Map<String, dynamic>?> scanAudio(String filePath) async {
    try {
      final formData = FormData.fromMap({
        'source': 'file',
        'file': await MultipartFile.fromFile(filePath, filename: 'audio.mp3'),
      });
      final response = await _api.uploadFile('/scans/audio', formData);
      return response.data;
    } on DioException catch (e) {
      debugPrint('❌ Scan audio error: ${e.message}');
      throw AppException.fromDio(e);
    }
  }

  Future<Map<String, dynamic>?> scanImage(String filePath) async {
    try {
      final formData = FormData.fromMap({
        'source': 'file',
        'file': await MultipartFile.fromFile(filePath, filename: 'image.jpg'),
      });
      final response = await _api.uploadFile('/scans/image', formData);
      return response.data;
    } on DioException catch (e) {
      debugPrint('❌ Scan image error: ${e.message}');
      throw AppException.fromDio(e);
    }
  }

  Future<Map<String, dynamic>?> scanVideo(String filePath) async {
    try {
      final formData = FormData.fromMap({
        'source': 'file',
        'file': await MultipartFile.fromFile(filePath, filename: 'video.mp4'),
      });
      final response = await _api.uploadFile('/scans/video', formData);
      return response.data;
    } on DioException catch (e) {
      debugPrint('❌ Scan video error: ${e.message}');
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

  // ===== LIBRARY =====
  Future<List<dynamic>?> getFavorites() async {
    try {
      final response = await _api.get('/library/favorites');
      return response.data as List?;
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

  // ===== RECOMMENDATIONS =====
  Future<List<dynamic>?> getPersonalizedRecommendations() async {
    try {
      final response = await _api.get('/recommendations/personalized');
      return response.data as List?;
    } on DioException catch (e) {
      debugPrint('❌ Get recommendations error: ${e.message}');
      return null;
    }
  }

  // ===== USER =====
  Future<Map<String, dynamic>?> getUserProfile() async {
    try {
      final response = await _api.get('/auth/me');
      return response.data;
    } on DioException catch (e) {
      debugPrint('❌ Get profile error: ${e.message}');
      return null;
    }
  }
}
