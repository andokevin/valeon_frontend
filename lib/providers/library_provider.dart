// lib/providers/library_provider.dart
import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../models/content_model.dart';
import '../core/database/database_service.dart';
import '../core/network/connectivity_service.dart';
import '../core/sync/sync_manager.dart';

class LibraryProvider extends ChangeNotifier {
  final DatabaseService _db = DatabaseService();
  final ConnectivityService _connectivity = ConnectivityService();
  final SyncManager _syncManager = SyncManager();

  List<ContentModel> _favorites = [];
  List<ContentModel> _musicHistory = [];
  List<ContentModel> _filmsHistory = [];
  List<ContentModel> _imagesHistory = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<ContentModel> get favorites => _favorites;
  List<ContentModel> get musicHistory => _musicHistory;
  List<ContentModel> get filmsHistory => _filmsHistory;
  List<ContentModel> get imagesHistory => _imagesHistory;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadUserLibrary(User user) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Charger les favoris
      final favs = await _db.getUserFavorites(user.id);
      _favorites = favs
          .map((f) => ContentModel.fromJson(f['content']))
          .toList();

      // Charger l'historique des scans
      final scans = await _db.getUserScans(user.id);

      _musicHistory = [];
      _filmsHistory = [];
      _imagesHistory = [];

      for (var scan in scans) {
        if (scan.result != null) {
          final content = ContentModel.fromJson(scan.result!);
          switch (content.type) {
            case ContentType.music:
              _musicHistory.add(content);
              break;
            case ContentType.film:
              _filmsHistory.add(content);
              break;
            case ContentType.image:
              _imagesHistory.add(content);
              break;
          }
        }
      }
    } catch (e) {
      _errorMessage = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> addToFavorites(ContentModel content, User user) async {
    try {
      await _db.insertFavorite(user.id, content.toJson());
      _favorites.add(content);

      // Ajouter à la queue de synchronisation
      await _syncManager.addToQueue(
        operation: 'INSERT',
        tableName: 'favorites',
        data: {'userId': user.id, 'content': content.toJson()},
      );

      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
    }
  }

  Future<void> removeFromFavorites(String contentId, User user) async {
    try {
      _favorites.removeWhere((c) => c.id == contentId);

      await _syncManager.addToQueue(
        operation: 'DELETE',
        tableName: 'favorites',
        data: {'contentId': contentId, 'userId': user.id},
      );

      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
    }
  }

  bool isFavorite(String contentId) {
    return _favorites.any((c) => c.id == contentId);
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
