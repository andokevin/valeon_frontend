// lib/services/recommendation_service.dart
import '../core/network/api_client.dart';
import '../models/user_model.dart';
import '../models/chat_model.dart';

class RecommendationService {
  final ApiClient _api = ApiClient();

  Future<List<Map<String, dynamic>>> getRecommendations(
    UserModel user, {
    int limit = 20,
    String? contentType,
  }) async {
    try {
      final params = {'limit': limit.toString()};
      if (contentType != null) params['content_type'] = contentType;

      final response = await _api.get(
        '/recommendations/personalized',
        params: params,
      );

      if (response != null && response is List) {
        return List<Map<String, dynamic>>.from(response);
      }
      return [];
    } catch (e) {
      print('❌ Get recommendations error: $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getTrending({
    String timeRange = 'week',
    String? contentType,
    int limit = 20,
  }) async {
    try {
      final params = {'time_range': timeRange, 'limit': limit.toString()};
      if (contentType != null) params['content_type'] = contentType;

      final response = await _api.get(
        '/recommendations/trending',
        params: params,
      );

      if (response != null && response is List) {
        return List<Map<String, dynamic>>.from(response);
      }
      return [];
    } catch (e) {
      print('❌ Get trending error: $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getSimilar(
    String contentId, {
    int limit = 10,
  }) async {
    try {
      final response = await _api.get('/recommendations/similar/$contentId');

      if (response != null && response is List) {
        return List<Map<String, dynamic>>.from(response);
      }
      return [];
    } catch (e) {
      print('❌ Get similar error: $e');
      return [];
    }
  }

  Future<Map<String, dynamic>> getChatRecommendation(
    String query,
    UserModel user,
  ) async {
    try {
      final response = await _api.post(
        '/recommendations/chat',
        data: {'query': query},
      );

      if (response != null) {
        return response;
      }
      return {'recommendations': []};
    } catch (e) {
      print('❌ Chat recommendation error: $e');
      return {'recommendations': []};
    }
  }
}
