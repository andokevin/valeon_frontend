// lib/providers/library_provider.dart
import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../models/content_model.dart';
import '../models/favorite_model.dart';
import '../models/playlist_model.dart';
import '../models/scan_model.dart';
import '../services/library_service.dart';
import '../core/database/database_service.dart';
import '../core/network/connectivity_service.dart';
import '../core/sync/sync_manager.dart';

class LibraryProvider extends ChangeNotifier {
  final LibraryService _service = LibraryService();
  final DatabaseService _db = DatabaseService();
  final ConnectivityService _connectivity = ConnectivityService();
  final SyncManager _syncManager = SyncManager();

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
      // Charger depuis la base locale d'abord
      final favs = await _db.getUserFavorites(user.userId);
      _favorites = favs.map((f) => FavoriteModel.fromJson(f)).toList();

      _history = await _db.getUserScans(user.userId);

      // Si connecté, synchroniser avec le serveur
      if (_connectivity.isOnline) {
        await Future.wait([
          _syncFavorites(user),
          _syncHistory(user),
          _loadStats(),
        ]);
      }
    } catch (e) {
      _errorMessage = e.toString();
      debugPrint('❌ Erreur chargement bibliothèque: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> _syncFavorites(UserModel user) async {
    try {
      final remoteFavs = await _service.getFavorites();
      for (var fav in remoteFavs) {
        final exists = _favorites.any((f) => f.contentId == fav.contentId);
        if (!exists) {
          _favorites.add(fav);
          await _db.insertFavorite(user.userId, fav.toContent());
        }
      }
    } catch (e) {
      debugPrint('❌ Erreur sync favoris: $e');
    }
  }

  Future<void> _syncHistory(UserModel user) async {
    try {
      final remoteHistory = await _service.getHistory();
      for (var scan in remoteHistory) {
        final exists = _history.any((s) => s.scanId == scan.scanId);
        if (!exists && scan.scanId != null) {
          _history.add(scan);
          await _db.insertScan(scan);
        }
      }
    } catch (e) {
      debugPrint('❌ Erreur sync historique: $e');
    }
  }

  Future<void> _loadStats() async {
    try {
      final statsData = await _service.getStats();
      _stats = statsData.cast<String, int>();
    } catch (e) {
      debugPrint('❌ Erreur chargement stats: $e');
    }
  }

  Future<void> addToFavorites(ContentModel content, UserModel user) async {
    try {
      await _db.insertFavorite(user.userId, content);
      _favorites.insert(
          0,
          FavoriteModel(
            favoriteId: DateTime.now().millisecondsSinceEpoch,
            contentId: content.contentId,
            contentTitle: content.contentTitle,
            contentType: content.contentType,
            contentImage: content.contentImage,
            contentArtist: content.contentArtist,
            createdAt: DateTime.now(),
          ));

      if (_connectivity.isOnline) {
        await _service.addFavorite(content.contentId);
      } else {
        await _syncManager.addToQueue(
          operation: 'INSERT',
          tableName: 'favorites',
          data: {'userId': user.userId, 'contentId': content.contentId},
        );
      }

      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      debugPrint('❌ Erreur ajout favori: $e');
    }
  }

  Future<void> removeFromFavorites(int contentId, UserModel user) async {
    try {
      _favorites.removeWhere((f) => f.contentId == contentId);

      // Trouver l'ID du favori local
      final localFav = await _db.getUserFavorites(user.userId);
      final fav = localFav.firstWhere((f) => f['content_id'] == contentId);
      await _db.deleteFavorite(fav['favorite_id'] as int);

      if (_connectivity.isOnline) {
        await _service.removeFavorite(contentId);
      } else {
        await _syncManager.addToQueue(
          operation: 'DELETE',
          tableName: 'favorites',
          data: {'contentId': contentId, 'userId': user.userId},
        );
      }

      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      debugPrint('❌ Erreur suppression favori: $e');
    }
  }

  Future<bool> isFavorite(int contentId) async {
    return _favorites.any((f) => f.contentId == contentId);
  }

  // ===== PLAYLISTS =====
  Future<void> loadPlaylists(UserModel user) async {
    try {
      if (_connectivity.isOnline) {
        _playlists = await _service.getPlaylists();
      } else {
        // Charger depuis la base locale
        final localPlaylists = await _db.getUserPlaylists(user.userId);
        _playlists = localPlaylists
            .map((p) => PlaylistModel.fromJson(p.toMap()))
            .toList();
      }
      notifyListeners();
    } catch (e) {
      debugPrint('❌ Erreur chargement playlists: $e');
    }
  }

  Future<void> createPlaylist(String name, UserModel user,
      {String? description}) async {
    try {
      if (_connectivity.isOnline) {
        final playlist =
            await _service.createPlaylist(name, description: description);
        _playlists.add(playlist);
      } else {
        // Créer localement et mettre en queue
        final localPlaylist = PlaylistModel(
          playlistId: DateTime.now().millisecondsSinceEpoch,
          playlistName: name,
          playlistDescription: description,
          contentCount: 0,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        _playlists.add(localPlaylist);

        await _syncManager.addToQueue(
          operation: 'INSERT',
          tableName: 'playlists',
          data: {
            'name': name,
            'description': description,
            'userId': user.userId
          },
        );
      }
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      debugPrint('❌ Erreur création playlist: $e');
    }
  }

  // ===== HISTORIQUE =====
  Future<ScanModel?> getScanDetails(int scanId) async {
    try {
      if (_connectivity.isOnline) {
        final scan = await _service
            .getHistory()
            .then((list) => list.firstWhere((s) => s.scanId == scanId));
        return scan;
      } else {
        return _history.firstWhere((s) => s.scanId == scanId);
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
