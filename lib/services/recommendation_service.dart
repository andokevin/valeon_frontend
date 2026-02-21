import 'package:dio/dio.dart';
import '../core/errors/app_exception.dart';
import '../core/network/api_client.dart';

class RecommendationService {
  final _api = ApiClient.instance;

  Future<List<Map<String, dynamic>>> getPersonalized({String? contentType}) async {
    try {
      final res = await _api.get('/recommendations/personalized',
          params: {'limit': 20, if (contentType != null) 'content_type': contentType});
      final data = res.data;
      if (data is Map && data['recommendations'] != null) {
        return List<Map<String, dynamic>>.from(data['recommendations']);
      }
      return [];
    } on DioException catch (e) {
      throw AppException.fromDio(e);
    }
  }

  Future<List<Map<String, dynamic>>> getTrending({
    String timeRange = 'week',
    String? contentType,
  }) async {
    try {
      final res = await _api.get('/recommendations/trending', params: {
        'time_range': timeRange,
        'limit': 20,
        if (contentType != null) 'content_type': contentType,
      });
      return List<Map<String, dynamic>>.from(res.data);
    } on DioException catch (e) {
      throw AppException.fromDio(e);
    }
  }
}
