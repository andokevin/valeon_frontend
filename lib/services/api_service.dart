// lib/services/api_service.dart
import '../core/network/api_client.dart';

class ApiService {
  final ApiClient _api = ApiClient();

  // ===== AUTH =====
  Future<Map<String, dynamic>?> login(String email, String password) async {
    try {
      return await _api.post(
        '/auth/login/json',
        data: {'user_email': email, 'password': password},
      );
    } catch (e) {
      print('❌ Login error: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> register({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      return await _api.post(
        '/auth/register',
        data: {
          'user_full_name': name,
          'user_email': email,
          'password': password,
          'accept_terms': true,
        },
      );
    } catch (e) {
      print('❌ Register error: $e');
      return null;
    }
  }

  // ===== SCANS =====
  Future<Map<String, dynamic>?> scanAudio(String filePath) async {
    try {
      final fields = {'source': 'file'};
      final files = {'file': filePath};

      return await _api.postMultipart('/scans/audio', fields, files);
    } catch (e) {
      print('❌ Scan audio error: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> getScanResult(String scanId) async {
    try {
      return await _api.get('/scans/$scanId');
    } catch (e) {
      print('❌ Get scan result error: $e');
      return null;
    }
  }

  // ===== LIBRARY =====
  Future<List<dynamic>?> getFavorites() async {
    try {
      return await _api.get('/library/favorites');
    } catch (e) {
      print('❌ Get favorites error: $e');
      return null;
    }
  }

  Future<bool> addToFavorites(int contentId) async {
    try {
      await _api.post('/library/favorites/$contentId');
      return true;
    } catch (e) {
      print('❌ Add favorite error: $e');
      return false;
    }
  }

  Future<bool> removeFromFavorites(int contentId) async {
    try {
      await _api.delete('/library/favorites/$contentId');
      return true;
    } catch (e) {
      print('❌ Remove favorite error: $e');
      return false;
    }
  }

  // ===== RECOMMENDATIONS =====
  Future<List<dynamic>?> getPersonalizedRecommendations() async {
    try {
      return await _api.get('/recommendations/personalized');
    } catch (e) {
      print('❌ Get recommendations error: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> chatWithAI(String query) async {
    try {
      return await _api.post('/recommendations/chat', data: {'query': query});
    } catch (e) {
      print('❌ Chat error: $e');
      return null;
    }
  }

  // ===== USER =====
  Future<Map<String, dynamic>?> getUserProfile() async {
    try {
      return await _api.get('/auth/me');
    } catch (e) {
      print('❌ Get profile error: $e');
      return null;
    }
  }

  Future<bool> updateUserProfile(Map<String, dynamic> data) async {
    try {
      await _api.put('/auth/me', data: data);
      return true;
    } catch (e) {
      print('❌ Update profile error: $e');
      return false;
    }
  }
}
