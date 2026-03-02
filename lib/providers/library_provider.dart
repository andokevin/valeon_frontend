// lib/providers/library_provider.dart
import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../models/content_model.dart';
import '../models/favorite_model.dart';
import '../models/playlist_model.dart';
import '../models/scan_model.dart';
import '../services/library_service.dart';
import '../services/scan_service.dart';
import '../core/network/connectivity_service.dart';

class LibraryProvider extends ChangeNotifier {
  final LibraryService _service = LibraryService();
  final ScanService _scanService = ScanService();
  final ConnectivityService _connectivity = ConnectivityService();

  List<FavoriteModel> _favorites = [];
  List<ScanModel> _history = [];
  List<PlaylistModel> _playlists = [];
  Map<String, int> _stats = {};
  bool _isLoading = false;
  String? _errorMessage;

  List<FavoriteModel> get favorites => _favorites;
  List<ScanModel> get history => _history;
  List<PlaylistModel> get playlists => _playlists;
  Map<String, int> get stats => _stats;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadUserLibrary(UserModel user) async {
    _isLoading = true;
    notifyListeners();

    try {
      if (_connectivity.isOnline) {
        await Future.wait([
          _loadFavorites(),
          _loadHistory(),
          _loadPlaylists(user),
          _loadStats(),
        ]);
      } else {
        _errorMessage =
            'Connexion internet requise pour charger la bibliothèque';
      }
    } catch (e) {
      _errorMessage = e.toString();
      debugPrint('❌ Erreur chargement bibliothèque: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> _loadFavorites() async {
    try {
      _favorites = await _service.getFavorites();
      debugPrint('✅ Favoris chargés: ${_favorites.length} éléments');
    } catch (e) {
      debugPrint('❌ Erreur chargement favoris: $e');
    }
  }

  Future<void> _loadHistory() async {
    try {
      _history = await _service.getHistory();
      debugPrint('✅ Historique chargé: ${_history.length} éléments');
    } catch (e) {
      debugPrint('❌ Erreur chargement historique: $e');
    }
  }

  Future<void> _loadPlaylists(UserModel user) async {
    try {
      _playlists = await _service.getPlaylists();
      debugPrint('✅ Playlists chargées: ${_playlists.length} éléments');
    } catch (e) {
      debugPrint('❌ Erreur chargement playlists: $e');
    }
  }

  Future<void> _loadStats() async {
    try {
      final statsData = await _service.getStats();
      _stats = statsData.cast<String, int>();
      debugPrint('✅ Stats chargées: $_stats');
    } catch (e) {
      debugPrint('❌ Erreur chargement stats: $e');
    }
  }

  // ===== FAVORIS =====
  Future<void> addToFavorites(ContentModel content, UserModel user) async {
    try {
      if (!_connectivity.isOnline) {
        _errorMessage = 'Connexion internet requise';
        notifyListeners();
        return;
      }

      debugPrint('➕ Ajout aux favoris: ${content.contentTitle} (ID: ${content.contentId})');
      await _service.addFavorite(content.contentId);
      await _loadFavorites(); // Recharger la liste
      await _loadStats();
      notifyListeners();
      debugPrint('✅ Ajouté aux favoris avec succès');
    } catch (e) {
      _errorMessage = e.toString();
      debugPrint('❌ Erreur ajout favori: $e');
    }
  }

  Future<void> removeFromFavorites(int contentId, UserModel user) async {
    try {
      if (!_connectivity.isOnline) {
        _errorMessage = 'Connexion internet requise';
        notifyListeners();
        return;
      }

      debugPrint('➖ Retrait des favoris: ID $contentId');
      await _service.removeFavorite(contentId);
      await _loadFavorites(); // Recharger la liste
      await _loadStats();
      notifyListeners();
      debugPrint('✅ Retiré des favoris avec succès');
    } catch (e) {
      _errorMessage = e.toString();
      debugPrint('❌ Erreur suppression favori: $e');
    }
  }

  Future<bool> isFavorite(int contentId) async {
    try {
      if (!_connectivity.isOnline) return false;
      final result = await _service.checkFavorite(contentId);
      debugPrint('🔍 Vérification favori ID $contentId: $result');
      return result;
    } catch (e) {
      debugPrint('❌ Erreur check favorite: $e');
      return false;
    }
  }

  // ===== PLAYLISTS =====
  Future<void> loadPlaylists(UserModel user) async {
    try {
      if (_connectivity.isOnline) {
        _playlists = await _service.getPlaylists();
        debugPrint('✅ Playlists rechargées: ${_playlists.length} éléments');
      }
      notifyListeners();
    } catch (e) {
      debugPrint('❌ Erreur chargement playlists: $e');
    }
  }

  Future<void> createPlaylist(String name, UserModel user,
      {String? description}) async {
    try {
      if (!_connectivity.isOnline) {
        _errorMessage = 'Connexion internet requise';
        notifyListeners();
        return;
      }

      debugPrint('➕ Création playlist: $name');
      final playlist =
          await _service.createPlaylist(name, description: description);
      _playlists.add(playlist);
      await _loadStats();
      notifyListeners();
      debugPrint('✅ Playlist créée avec ID: ${playlist.playlistId}');
    } catch (e) {
      _errorMessage = e.toString();
      debugPrint('❌ Erreur création playlist: $e');
    }
  }

  Future<void> deletePlaylist(int playlistId) async {
    try {
      if (!_connectivity.isOnline) {
        _errorMessage = 'Connexion internet requise';
        notifyListeners();
        return;
      }

      debugPrint('➖ Suppression playlist ID: $playlistId');
      await _service.deletePlaylist(playlistId);
      _playlists.removeWhere((p) => p.playlistId == playlistId);
      await _loadStats();
      notifyListeners();
      debugPrint('✅ Playlist supprimée');
    } catch (e) {
      _errorMessage = e.toString();
      debugPrint('❌ Erreur suppression playlist: $e');
    }
  }

  Future<PlaylistModel> getPlaylist(int playlistId) async {
    try {
      if (!_connectivity.isOnline) {
        throw Exception('Connexion internet requise');
      }
      final playlist = await _service.getPlaylist(playlistId);
      debugPrint('🔍 Playlist récupérée: ${playlist.playlistName} (${playlist.contents.length} éléments)');
      return playlist;
    } catch (e) {
      debugPrint('❌ Erreur récupération playlist: $e');
      rethrow;
    }
  }

  Future<void> addToPlaylist(int playlistId, int contentId) async {
    try {
      if (!_connectivity.isOnline) {
        _errorMessage = 'Connexion internet requise';
        notifyListeners();
        return;
      }

      debugPrint('➕ Ajout contenu $contentId à la playlist $playlistId');
      await _service.addToPlaylist(playlistId, contentId);
      final updatedPlaylist = await _service.getPlaylist(playlistId);
      final index = _playlists.indexWhere((p) => p.playlistId == playlistId);
      if (index != -1) {
        _playlists[index] = updatedPlaylist;
      }
      notifyListeners();
      debugPrint('✅ Contenu ajouté à la playlist');
    } catch (e) {
      _errorMessage = e.toString();
      debugPrint('❌ Erreur ajout à la playlist: $e');
    }
  }

  Future<void> removeFromPlaylist(int playlistId, int contentId) async {
    try {
      if (!_connectivity.isOnline) {
        _errorMessage = 'Connexion internet requise';
        notifyListeners();
        return;
      }

      debugPrint('➖ Retrait contenu $contentId de la playlist $playlistId');
      // Note: Cette fonctionnalité nécessite un endpoint API dédié
      await _service.getPlaylist(playlistId);
      notifyListeners();
    } catch (e) {
      debugPrint('❌ Erreur suppression de la playlist: $e');
    }
  }

  // ===== HISTORIQUE =====
  Future<void> refreshHistory() async {
    try {
      if (_connectivity.isOnline) {
        await _loadHistory();
        notifyListeners();
      }
    } catch (e) {
      debugPrint('❌ Erreur rafraîchissement historique: $e');
    }
  }

  Future<ScanModel?> getScanDetails(int scanId) async {
    try {
      if (!_connectivity.isOnline) {
        throw Exception('Connexion internet requise');
      }
      
      // Chercher d'abord dans l'historique chargé
      try {
        final scan = _history.firstWhere((s) => s.scanId == scanId);
        debugPrint('🔍 Scan trouvé dans l\'historique local: ID $scanId');
        return scan;
      } catch (e) {
        // Sinon aller chercher sur le serveur
        debugPrint('🔍 Scan non trouvé localement, requête serveur: ID $scanId');
        return await _scanService.getScanResult(scanId);
      }
    } catch (e) {
      debugPrint('❌ Erreur récupération scan: $e');
      return null;
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
