// lib/providers/recommendation_provider.dart
import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../models/content_model.dart';
import '../services/recommendation_service.dart';
import '../core/database/database_service.dart';
import '../core/network/connectivity_service.dart';

class RecommendationProvider extends ChangeNotifier {
  final RecommendationService _service = RecommendationService();
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
        await Future.wait([
          _loadPersonalized(user),
          _loadTrending(),
          _loadForYou(user),
        ]);
      } else {
        await _loadOfflineRecommendations(user);
      }
    } catch (e) {
      _errorMessage = e.toString();
      debugPrint('❌ Erreur chargement recommandations: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> _loadPersonalized(UserModel user) async {
    try {
      _personalized = await _service.getPersonalized();
    } catch (e) {
      debugPrint('❌ Erreur load personalized: $e');
    }
  }

  Future<void> _loadTrending() async {
    try {
      _trending = await _service.getTrending();
    } catch (e) {
      debugPrint('❌ Erreur load trending: $e');
    }
  }

  Future<void> _loadForYou(UserModel user) async {
    try {
      // Mix de personalized et trending
      _forYou = [..._personalized, ..._trending];
      _forYou.shuffle();
      _forYou = _forYou.take(10).toList();
    } catch (e) {
      debugPrint('❌ Erreur load for you: $e');
    }
  }

  Future<void> _loadOfflineRecommendations(UserModel user) async {
    // En mode offline, utiliser l'historique et les favoris
    final scans = await _db.getUserScans(user.userId);
    final recentTypes = <String, int>{};

    for (var scan in scans) {
      if (scan.result != null && scan.result!['type'] != null) {
        final type = scan.result!['type'];
        recentTypes[type] = (recentTypes[type] ?? 0) + 1;
      }
    }

    final preferredType = recentTypes.entries.isNotEmpty
        ? recentTypes.entries.reduce((a, b) => a.value > b.value ? a : b).key
        : 'music';

    _personalized = _getMockRecommendations(preferredType, 5);
    _trending = _getMockRecommendations('trending', 5);
    _forYou = _getMockRecommendations('mixed', 10);
  }

  List<ContentModel> _getMockRecommendations(String type, int count) {
    final mockData = [
      ContentModel(
        contentId: 1,
        contentType: 'movie',
        contentTitle: 'Inception',
        contentArtist: 'Christopher Nolan',
        contentReleaseDate: '2010',
        contentDescription: 'Un voleur qui s\'infiltre dans les rêves.',
        contentImage: '',
      ),
      ContentModel(
        contentId: 2,
        contentType: 'music',
        contentTitle: 'Blinding Lights',
        contentArtist: 'The Weeknd',
        contentReleaseDate: '2019',
        contentDescription: 'Chanson populaire de The Weeknd.',
        contentImage: '',
      ),
      ContentModel(
        contentId: 3,
        contentType: 'movie',
        contentTitle: 'Interstellar',
        contentArtist: 'Christopher Nolan',
        contentReleaseDate: '2014',
        contentDescription: 'Un voyage à travers les étoiles.',
        contentImage: '',
      ),
      ContentModel(
        contentId: 4,
        contentType: 'music',
        contentTitle: 'Heat Waves',
        contentArtist: 'Glass Animals',
        contentReleaseDate: '2020',
        contentDescription: 'Chanson populaire du groupe Glass Animals.',
        contentImage: '',
      ),
    ];
    return mockData.take(count).toList();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
