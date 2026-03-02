// lib/providers/recommendation_provider.dart (CORRIGÉ)
import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../models/content_model.dart';
import '../services/recommendation_service.dart';
import '../core/network/connectivity_service.dart';

class RecommendationProvider extends ChangeNotifier {
  final RecommendationService _service = RecommendationService();
  final ConnectivityService _connectivity = ConnectivityService();

  List<ContentModel> _personalized = [];
  List<ContentModel> _trending = [];
  List<ContentModel> _forYou = [];
  Map<int, List<ContentModel>> _similarCache = {}; // Cache pour les similaires
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
        ]);
        _forYou = [..._personalized, ..._trending];
        _forYou.shuffle();
        _forYou = _forYou.take(10).toList();
      } else {
        _errorMessage = 'Connexion internet requise pour les recommandations';
      }
    } catch (e) {
      _errorMessage = e.toString();
      debugPrint('❌ Erreur chargement recommandations: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  // ===== MODIFICATION: AJOUT DU PARAMÈTRE limit OBLIGATOIRE =====
  Future<void> _loadPersonalized(UserModel user) async {
    try {
      // Ajout du paramètre limit: 20 (ou toute autre valeur par défaut)
      _personalized = await _service.getPersonalized(limit: 20);
    } catch (e) {
      debugPrint('❌ Erreur load personalized: $e');
      _personalized = []; // ← Éviter de garder d'anciennes valeurs
    }
  }

  Future<void> _loadTrending() async {
    try {
      _trending = await _service.getTrending();
    } catch (e) {
      debugPrint('❌ Erreur load trending: $e');
      _trending = []; // ← Éviter de garder d'anciennes valeurs
    }
  }

  // NOUVELLE MÉTHODE : récupérer les contenus similaires
  Future<List<ContentModel>> getSimilar(int contentId, {int limit = 5}) async {
    // Vérifier le cache
    if (_similarCache.containsKey(contentId)) {
      return _similarCache[contentId]!;
    }

    try {
      if (!_connectivity.isOnline) {
        return [];
      }

      final similar = await _service.getSimilar(contentId, limit: limit);
      _similarCache[contentId] = similar;
      return similar;
    } catch (e) {
      debugPrint('❌ Erreur getSimilar: $e');
      return [];
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void clearCache() {
    _similarCache.clear();
  }
}
