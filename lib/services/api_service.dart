// lib/services/api_service.dart (CORRIGÉ - avec params)
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
  Future<List<dynamic>?> getFavorites({String? contentType, String sortBy = 'recent', int skip = 0, int limit = 50}) async {
    try {
      final queryParams = <String, dynamic>{
        'skip': skip,
        'limit': limit,
        'sort_by': sortBy,
      };
      if (contentType != null) {
        queryParams['content_type'] = contentType;
      }
      
      final response = await _api.get('/library/favorites', params: queryParams);
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

  // ===== HISTORIQUE =====
  Future<List<dynamic>?> getHistory({int skip = 0, int limit = 50}) async {
    try {
      final response = await _api.get(
        '/library/history',
        params: {'skip': skip, 'limit': limit},
      );
      return response.data as List?;
    } on DioException catch (e) {
      debugPrint('❌ Get history error: ${e.message}');
      return null;
    }
  }

  // ===== STATISTIQUES =====
  Future<Map<String, dynamic>?> getStats() async {
    try {
      final response = await _api.get('/library/stats');
      return response.data;
    } on DioException catch (e) {
      debugPrint('❌ Get stats error: ${e.message}');
      return null;
    }
  }

  // ===== NOUVEAU: RECOMMANDATIONS SIMILAIRES =====
  Future<Map<String, dynamic>?> getSimilarContent(int contentId, {int limit = 3}) async {
    try {
      debugPrint('🔍 Récupération des contenus similaires pour content_id: $contentId');
      
      final response = await _api.get(
        '/recommendations/similar/$contentId',
        params: {'limit': limit},
      );
      
      if (response.statusCode == 200) {
        debugPrint('✅ ${response.data['recommendations']?.length ?? 0} recommandations trouvées');
        return response.data;
      }
    } on DioException catch (e) {
      debugPrint('❌ Erreur getSimilarContent: ${e.message}');
      if (e.response != null) {
        debugPrint('   Status: ${e.response?.statusCode}');
        debugPrint('   Data: ${e.response?.data}');
      }
    } catch (e) {
      debugPrint('❌ Erreur inattendue getSimilarContent: $e');
    }
    return null;
  }

  // ===== RECOMMENDATIONS GÉNÉRALES =====
  Future<List<dynamic>?> getPersonalizedRecommendations({String? contentType, int limit = 10}) async {
    try {
      final queryParams = <String, dynamic>{'limit': limit};
      if (contentType != null) {
        queryParams['content_type'] = contentType;
      }
      
      final response = await _api.get('/recommendations/personalized', params: queryParams);
      return response.data['recommendations'] as List?;
    } on DioException catch (e) {
      debugPrint('❌ Get recommendations error: ${e.message}');
      return null;
    }
  }

  Future<Map<String, dynamic>?> getTrendingContent({
    String? contentType,
    String timeRange = 'week',
    int limit = 10,
  }) async {
    try {
      final response = await _api.get(
        '/recommendations/trending',
        params: {
          if (contentType != null) 'content_type': contentType,
          'time_range': timeRange,
          'limit': limit,
        },
      );
      return response.data;
    } on DioException catch (e) {
      debugPrint('❌ Get trending error: ${e.message}');
      return null;
    }
  }

  // ===== CHAT ASSISTANT =====
  Future<Map<String, dynamic>?> sendChatMessage(String message, {String? conversationId}) async {
    try {
      final response = await _api.post(
        '/chat/message',
        data: {
          'message': message,
          'conversation_id': conversationId,
        },
      );
      return response.data;
    } on DioException catch (e) {
      debugPrint('❌ Chat error: ${e.message}');
      return null;
    }
  }

  // ===== SEARCH =====
  Future<List<dynamic>?> search(String query, {String? type, int limit = 20}) async {
    try {
      final response = await _api.get(
        '/search',
        params: {
          'q': query,
          if (type != null) 'type': type,
          'limit': limit,
        },
      );
      return response.data['results'] as List?;
    } on DioException catch (e) {
      debugPrint('❌ Search error: ${e.message}');
      return null;
    }
  }

  Future<List<String>?> getSearchSuggestions(String query, {int limit = 5}) async {
    try {
      final response = await _api.get(
        '/search/suggestions',
        params: {'q': query, 'limit': limit},
      );
      return (response.data['suggestions'] as List?)?.cast<String>();
    } on DioException catch (e) {
      debugPrint('❌ Get suggestions error: ${e.message}');
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

  Future<bool> updateUserProfile({
    String? fullName,
    Map<String, dynamic>? preferences,
  }) async {
    try {
      final data = <String, dynamic>{};
      if (fullName != null) data['user_full_name'] = fullName;
      if (preferences != null) data['preferences'] = preferences;
      
      await _api.put('/auth/me', data: data);
      return true;
    } on DioException catch (e) {
      debugPrint('❌ Update profile error: ${e.message}');
      return false;
    }
  }

  // ===== SYNC =====
  Future<Map<String, dynamic>?> syncUserData(Map<String, dynamic> data) async {
    try {
      final response = await _api.post('/auth/sync', data: data);
      return response.data;
    } on DioException catch (e) {
      debugPrint('❌ Sync error: ${e.message}');
      return null;
    }
  }

  // ===== STREAMING =====
  Future<Map<String, dynamic>?> getStreamingOptions(int contentId, {String country = 'FR'}) async {
    try {
      final response = await _api.get(
        '/streaming/movie/$contentId',
        params: {'country': country},
      );
      return response.data;
    } on DioException catch (e) {
      debugPrint('❌ Get streaming error: ${e.message}');
      return null;
    }
  }

  // ===== PLAYLISTS =====
  Future<List<dynamic>?> getPlaylists() async {
    try {
      final response = await _api.get('/library/playlists');
      return response.data as List?;
    } on DioException catch (e) {
      debugPrint('❌ Get playlists error: ${e.message}');
      return null;
    }
  }

  Future<Map<String, dynamic>?> createPlaylist(String name, {String? description}) async {
    try {
      final response = await _api.post(
        '/library/playlists',
        data: {'playlist_name': name, 'playlist_description': description},
      );
      return response.data;
    } on DioException catch (e) {
      debugPrint('❌ Create playlist error: ${e.message}');
      return null;
    }
  }

  Future<Map<String, dynamic>?> getPlaylist(int playlistId) async {
    try {
      final response = await _api.get('/library/playlists/$playlistId');
      return response.data;
    } on DioException catch (e) {
      debugPrint('❌ Get playlist error: ${e.message}');
      return null;
    }
  }

  Future<bool> deletePlaylist(int playlistId) async {
    try {
      await _api.delete('/library/playlists/$playlistId');
      return true;
    } on DioException catch (e) {
      debugPrint('❌ Delete playlist error: ${e.message}');
      return false;
    }
  }

  Future<bool> addToPlaylist(int playlistId, int contentId) async {
    try {
      await _api.post(
        '/library/playlists/$playlistId/add',
        data: {'content_id': contentId},
      );
      return true;
    } on DioException catch (e) {
      debugPrint('❌ Add to playlist error: ${e.message}');
      return false;
    }
  }

  Future<bool> removeFromPlaylist(int playlistId, int contentId) async {
    try {
      await _api.delete('/library/playlists/$playlistId/remove/$contentId');
      return true;
    } on DioException catch (e) {
      debugPrint('❌ Remove from playlist error: ${e.message}');
      return false;
    }
  }
}
