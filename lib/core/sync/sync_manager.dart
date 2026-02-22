// lib/core/sync/sync_manager.dart (MODIFIÉ)
import 'dart:async';
import 'package:flutter/material.dart';
import '../database/database_service.dart';
import '../network/api_client.dart';
import '../network/connectivity_service.dart';
import '../../models/user_model.dart';
import 'package:http/http.dart' as http;
import '../../config/app_config.dart';
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
    if (_connectivity.isOnline) {
      _autoSync();
    }
  }

  Future<void> _autoSync() async {
    if (!_connectivity.isOnline || _isSyncing) return;
    await syncAll();
  }

  Future<void> syncAll({User? user}) async {
    if (_isSyncing) return;

    _isSyncing = true;
    _syncProgress = 0;
    notifyListeners();

    try {
      // 1. Synchroniser les scans
      await _syncScans();
      _syncProgress = 25;

      // 2. Synchroniser les favoris
      await _syncFavorites();
      _syncProgress = 50;

      // 3. Synchroniser les chats
      await _syncChats();
      _syncProgress = 75;

      // 4. Synchroniser l'utilisateur
      if (user != null) {
        await _syncUser(user);
      }
      _syncProgress = 100;

      _lastSyncError = null;
      _lastSyncTime = DateTime.now();
      await _secureStorage.saveLastSync(_lastSyncTime!);
    } catch (e) {
      _lastSyncError = e.toString();
    } finally {
      _isSyncing = false;
      notifyListeners();
    }
  }

  Future<void> _syncScans() async {
    final unsynced = await _db.getUnsyncedScans();

    for (var scan in unsynced) {
      try {
        if (scan.filePath != null) {
          var request = http.MultipartRequest(
            'POST',
            Uri.parse('${AppConfig.apiBaseUrl}/scans/${scan.type.name}'),
          );
          request.files.add(
            await http.MultipartFile.fromPath('file', scan.filePath!),
          );
          request.fields['source'] = scan.inputSource ?? 'file';

          final token = await SecureStorage().getToken();
          request.headers['Authorization'] = 'Bearer $token';

          final response = await request.send();
          final responseData = await http.Response.fromStream(response);

          if (response.statusCode == 200 || response.statusCode == 202) {
            await _db.markScanAsSynced(scan.id);
          }
        }
      } catch (e) {
        print('❌ Erreur sync scan ${scan.id}: $e');
      }
    }
  }

  Future<void> _syncFavorites() async {
    // Récupérer les favoris non synchronisés
    final user = await _secureStorage.getUser();
    if (user == null) return;

    final favorites = await _db.getUserFavorites(user.id);
    for (var fav in favorites) {
      if (fav['synced'] == 0) {
        try {
          await _api.post('/library/favorites/${fav['contentId']}');
          await _db.markFavoriteAsSynced(fav['id']);
        } catch (e) {
          print('❌ Erreur sync favori: $e');
        }
      }
    }
  }

  Future<void> _syncChats() async {
    final user = await _secureStorage.getUser();
    if (user == null) return;

    final unsyncedMessages = await _db.getUnsyncedMessages(user.id);
    for (var message in unsyncedMessages) {
      try {
        final response = await _api.post(
          '/chat/messages',
          data: {'userId': user.id, 'message': message.toMap()},
        );
        if (response != null) {
          await _db.markMessageAsSynced(message.id);
        }
      } catch (e) {
        print('❌ Erreur sync message: $e');
      }
    }
  }

  Future<void> _syncUser(User user) async {
    try {
      await _api.post('/users/sync', data: user.toMap());
    } catch (e) {
      print('❌ Erreur sync user: $e');
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

    if (_connectivity.isOnline) {
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
