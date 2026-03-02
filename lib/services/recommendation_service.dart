// lib/services/recommendation_service.dart
import 'package:dio/dio.dart';
import '../core/errors/app_exception.dart';
import '../core/network/api_client.dart';
import '../models/content_model.dart';

class RecommendationService {
  final ApiClient _api = ApiClient();

  RecommendationService() {
    _api.init();
  }

  Future<List<ContentModel>> getPersonalized(
      {String? contentType, required int limit}) async {
    try {
      final response = await _api.get(
        '/recommendations/personalized',
        params: {
          'limit': 20,
          if (contentType != null) 'content_type': contentType
        },
      );
      final data = response.data;
      if (data is Map && data['recommendations'] != null) {
        return (data['recommendations'] as List)
            .map((j) => ContentModel.fromJson(j))
            .toList();
      }
      return [];
    } on DioException catch (e) {
      throw AppException.fromDio(e);
    }
  }

  Future<List<ContentModel>> getTrending({
    String timeRange = 'week',
    String? contentType,
  }) async {
    try {
      final response = await _api.get('/recommendations/trending', params: {
        'time_range': timeRange,
        'limit': 20,
        if (contentType != null) 'content_type': contentType,
      });
      return (response.data as List)
          .map((j) => ContentModel.fromJson(j))
          .toList();
    } on DioException catch (e) {
      throw AppException.fromDio(e);
    }
  }

  Future<List<ContentModel>> getSimilar(int contentId, {int limit = 10}) async {
    try {
      final response = await _api.get('/recommendations/similar/$contentId');
      return (response.data as List)
          .map((j) => ContentModel.fromJson(j))
          .toList();
    } on DioException catch (e) {
      throw AppException.fromDio(e);
    }
  }
}
