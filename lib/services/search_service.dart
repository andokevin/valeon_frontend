// lib/services/search_service.dart (NOUVEAU)
import '../core/network/api_client.dart';
import '../core/network/connectivity_service.dart';
import '../config/app_config.dart';
import 'package:flutter/foundation.dart';

class SearchService {
  final ApiClient _api = ApiClient();
  final ConnectivityService _connectivity = ConnectivityService();
  final String baseUrl = AppConfig.apiBaseUrl;

  SearchService() {
    _api.init();
  }

  Future<Map<String, dynamic>> search({
    required String query,
    String? type,
    int limit = 20,
  }) async {
    try {
      if (!_connectivity.isOnline) {
        return {
          'query': query,
          'results': _getMockResults(query),
          'total': 3,
        };
      }

      debugPrint('🔍 Recherche: $query');

      final response = await _api.get(
        '/search',
        params: {
          'q': query,
          if (type != null && type != 'all') 'type': type,
          'limit': limit,
        },
      );

      return response.data ??
          {
            'query': query,
            'results': [],
            'total': 0,
          };
    } catch (e) {
      debugPrint('❌ Erreur recherche: $e');
      return {
        'query': query,
        'results': _getMockResults(query),
        'total': 3,
      };
    }
  }

  Future<List<String>> getSuggestions(String query) async {
    try {
      if (!_connectivity.isOnline || query.length < 2) {
        return [];
      }

      final response = await _api.get(
        '/search/suggestions',
        params: {'q': query},
      );

      final data = response.data;
      if (data != null && data['suggestions'] != null) {
        return List<String>.from(data['suggestions']);
      }
      return [];
    } catch (e) {
      debugPrint('❌ Erreur suggestions: $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getTrending() async {
    try {
      if (!_connectivity.isOnline) {
        return _getMockTrending();
      }

      final response = await _api.get('/search/trending');
      final data = response.data;

      if (data != null && data['trending'] != null) {
        return List<Map<String, dynamic>>.from(data['trending']);
      }
      return _getMockTrending();
    } catch (e) {
      debugPrint('❌ Erreur trending: $e');
      return _getMockTrending();
    }
  }

  List<Map<String, dynamic>> _getMockResults(String query) {
    return [
      {
        'title': 'Blinding Lights',
        'type': 'music',
        'artist': 'The Weeknd',
        'year': '2019',
        'source': 'mock',
      },
      {
        'title': 'Inception',
        'type': 'movie',
        'artist': 'Christopher Nolan',
        'year': '2010',
        'source': 'mock',
      },
      {
        'title': 'Heat Waves',
        'type': 'music',
        'artist': 'Glass Animals',
        'year': '2020',
        'source': 'mock',
      },
    ];
  }

  List<Map<String, dynamic>> _getMockTrending() {
    return [
      {'title': 'Blinding Lights', 'count': 156},
      {'title': 'Inception', 'count': 98},
      {'title': 'Heat Waves', 'count': 87},
      {'title': 'Interstellar', 'count': 76},
      {'title': 'The Weeknd', 'count': 65},
    ];
  }
}
