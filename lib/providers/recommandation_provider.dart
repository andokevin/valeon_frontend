// lib/providers/recommendation_provider.dart
import 'package:flutter/material.dart';
import 'dart:convert';
import '../models/user_model.dart';
import '../models/content_model.dart';
import '../core/network/api_client.dart';
import '../core/database/database_service.dart';
import '../core/network/connectivity_service.dart';
import '../config/app_config.dart';

class RecommendationProvider extends ChangeNotifier {
  final ApiClient _api = ApiClient();
  final DatabaseService _db = DatabaseService();
  final ConnectivityService _connectivity = ConnectivityService();

  List<ContentModel> _personalized = [];
  List<ContentModel> _trending = [];
  List<ContentModel> _forYou = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<ContentModel> get personalized => _personalized;
  List<ContentModel> get trending => _trending;
  List<ContentModel> get forYou => _forYou;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadRecommendations(UserModel user) async {
    _isLoading = true;
    notifyListeners();

    try {
      if (_connectivity.isOnline) {
        // Charger depuis l'API
        await Future.wait([
          _loadPersonalized(user),
          _loadTrending(),
          _loadForYou(user),
        ]);
      } else {
        // Mode offline - charger depuis SQLite
        await _loadOfflineRecommendations(user);
      }
    } catch (e) {
      _errorMessage = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> _loadPersonalized(UserModel user) async {
    try {
      final response = await _api.get(
        '/recommendations/personalized',
        params: {'limit': AppConfig.maxRecommendations.toString()},
      );

      if (response != null && response['recommendations'] != null) {
        _personalized = (response['recommendations'] as List)
            .map((r) => ContentModel.fromJson(r))
            .toList();
      }
    } catch (e) {
      print('❌ Erreur load personalized: $e');
    }
  }

  Future<void> _loadTrending() async {
    try {
      final response = await _api.get('/recommendations/trending');

      if (response != null) {
        _trending = (response as List)
            .map((r) => ContentModel.fromJson(r))
            .toList();
      }
    } catch (e) {
      print('❌ Erreur load trending: $e');
    }
  }

  Future<void> _loadForYou(UserModel user) async {
    try {
      final response = await _api.get('/recommendations/for-you');

      if (response != null && response['recommendations'] != null) {
        _forYou = (response['recommendations'] as List)
            .map((r) => ContentModel.fromJson(r))
            .toList();
      }
    } catch (e) {
      print('❌ Erreur load for you: $e');
    }
  }

  Future<void> _loadOfflineRecommendations(UserModel user) async {
    // En mode offline, utiliser les favoris et l'historique
    final scans = await _db.getUserScans(user.id);
    final recentTypes = <String, int>{};

    for (var scan in scans) {
      if (scan.result != null && scan.result!['type'] != null) {
        final type = scan.result!['type'];
        recentTypes[type] = (recentTypes[type] ?? 0) + 1;
      }
    }

    // Recommandations basées sur les types les plus scannés
    final preferredType = recentTypes.entries.isNotEmpty
        ? recentTypes.entries.reduce((a, b) => a.value > b.value ? a : b).key
        : 'music';

    // Simuler des recommandations
    _personalized = _getMockRecommendations(preferredType, 5);
    _trending = _getMockRecommendations('trending', 5);
    _forYou = _getMockRecommendations('mixed', 10);
  }

  List<ContentModel> _getMockRecommendations(String type, int count) {
    final mockData = [
      ContentModel(
        id: '1',
        title: 'Inception',
        artist: 'Christopher Nolan',
        year: '2010',
        genre: 'Science-fiction',
        description: 'Un voleur qui s\'infiltre dans les rêves.',
        imageUrl: '',
        type: ContentType.film,
        scannedAt: DateTime.now(),
      ),
      ContentModel(
        id: '2',
        title: 'Blinding Lights',
        artist: 'The Weeknd',
        year: '2019',
        genre: 'Synth-pop',
        description: 'Chanson populaire de The Weeknd.',
        imageUrl: '',
        type: ContentType.music,
        scannedAt: DateTime.now(),
      ),
      // Ajouter plus de données mock...
    ];

    return mockData.take(count).toList();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
