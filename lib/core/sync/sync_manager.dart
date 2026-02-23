// lib/core/sync/sync_manager.dart
import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../database/database_service.dart';
import '../network/api_client.dart';
import '../network/connectivity_service.dart';
import '../../models/user_model.dart';
import '../../utils/secure_storage.dart';

class SyncManager extends ChangeNotifier {
  final DatabaseService _db = DatabaseService();
  final ApiClient _api = ApiClient();
  final ConnectivityService _connectivity = ConnectivityService();
  final SecureStorage _secureStorage = SecureStorage();

  Timer? _syncTimer;
  bool _isSyncing = false;
  int _syncProgress = 0;
  String? _lastSyncError;
  DateTime? _lastSyncTime;

  bool get isSyncing => _isSyncing;
  int get syncProgress => _syncProgress;
  String? get lastSyncError => _lastSyncError;
  DateTime? get lastSyncTime => _lastSyncTime;

  SyncManager() {
    _initAutoSync();
    _connectivity.addListener(_onConnectivityChanged);
    _loadLastSync();
  }

  Future<void> _loadLastSync() async {
    _lastSyncTime = await _secureStorage.getLastSync();
  }

  void _initAutoSync() {
    _syncTimer = Timer.periodic(
      const Duration(minutes: 15),
      (_) => _autoSync(),
    );
  }

  void _onConnectivityChanged() {
    if (_connectivity.isOnline && !_isSyncing) {
      _autoSync();
    }
  }

  Future<void> _autoSync() async {
    if (!_connectivity.isOnline || _isSyncing) return;
    await syncAll();
  }

  Future<void> syncAll({UserModel? user}) async {
    if (_isSyncing) return;

    _isSyncing = true;
    _syncProgress = 0;
    notifyListeners();

    try {
      // 1. Synchroniser l'utilisateur
      if (user != null) {
        await _syncUser(user);
        _syncProgress = 20;
      }

      // 2. Synchroniser les scans
      await _syncScans();
      _syncProgress = 40;

      // 3. Synchroniser les favoris
      await _syncFavorites(user);
      _syncProgress = 60;

      // 4. Synchroniser les playlists
      await _syncPlaylists(user);
      _syncProgress = 80;

      // 5. Synchroniser les chats
      await _syncChats(user);
      _syncProgress = 100;

      _lastSyncError = null;
      _lastSyncTime = DateTime.now();
      await _secureStorage.saveLastSync(_lastSyncTime!);
    } catch (e) {
      _lastSyncError = e.toString();
      debugPrint('❌ Erreur sync: $e');
    } finally {
      _isSyncing = false;
      notifyListeners();
    }
  }

  Future<void> _syncUser(UserModel user) async {
    try {
      await _api.post('/users/sync', data: user.toJson());
    } catch (e) {
      debugPrint('❌ Erreur sync user: $e');
    }
  }

  Future<void> _syncScans() async {
    final unsynced = await _db.getUnsyncedScans();
    for (var scan in unsynced) {
      try {
        if (scan.filePath != null) {
          final formData = FormData.fromMap({
            'file': await MultipartFile.fromFile(scan.filePath!),
            'source': scan.inputSource,
          });
          final response =
              await _api.uploadFile('/scans/${scan.scanType}', formData);
          if (response.statusCode == 200 || response.statusCode == 202) {
            await _db.markScanAsSynced(scan.scanId!);
          }
        }
      } catch (e) {
        debugPrint('❌ Erreur sync scan ${scan.scanId}: $e');
      }
    }
  }

  Future<void> _syncFavorites(UserModel? user) async {
    if (user == null) return;

    final favorites = await _db.getUserFavorites(user.userId);
    for (var fav in favorites) {
      if (fav['synced'] == 0) {
        try {
          await _api.post('/library/favorites/${fav['content_id']}');
          await _db.markFavoriteAsSynced(fav['favorite_id'] as int);
        } catch (e) {
          debugPrint('❌ Erreur sync favori: $e');
        }
      }
    }
  }

  Future<void> _syncPlaylists(UserModel? user) async {
    if (user == null) return;
    // Implémenter la sync des playlists
  }

  Future<void> _syncChats(UserModel? user) async {
    if (user == null) return;

    final unsyncedMessages = await _db.getUnsyncedMessages(user.userId);
    for (var message in unsyncedMessages) {
      try {
        final response = await _api.post(
          '/chat/messages',
          data: {'userId': user.userId, 'message': message.toJson()},
        );
        if (response.statusCode == 200) {
          await _db.markMessagesAsSynced(user.userId);
        }
      } catch (e) {
        debugPrint('❌ Erreur sync message: $e');
      }
    }
  }

  Future<void> addToQueue({
    required String operation,
    required String tableName,
    required Map<String, dynamic> data,
  }) async {
    await _db.addToSyncQueue(
      operation: operation,
      tableName: tableName,
      data: data,
    );

    if (_connectivity.isOnline && !_isSyncing) {
      _autoSync();
    }
  }

  String get syncStatusMessage {
    if (_isSyncing) {
      return 'Synchronisation... $_syncProgress%';
    } else if (_lastSyncError != null) {
      return 'Erreur de synchronisation';
    } else if (_lastSyncTime != null) {
      final diff = DateTime.now().difference(_lastSyncTime!);
      if (diff.inMinutes < 1) {
        return 'Synchronisé à l\'instant';
      } else if (diff.inHours < 1) {
        return 'Synchronisé il y a ${diff.inMinutes} min';
      } else {
        return 'Synchronisé à ${_lastSyncTime!.hour}:${_lastSyncTime!.minute.toString().padLeft(2, '0')}';
      }
    } else {
      return 'Jamais synchronisé';
    }
  }

  @override
  void dispose() {
    _syncTimer?.cancel();
    _connectivity.removeListener(_onConnectivityChanged);
    super.dispose();
  }
}
