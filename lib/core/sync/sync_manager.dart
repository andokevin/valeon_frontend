import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../database/database_service.dart';
import '../network/api_client.dart';
import '../network/connectivity_service.dart';
import '../../models/user_model.dart';
import '../../utils/secure_storage.dart';
import '../constants/app_constants.dart';

class SyncManager extends ChangeNotifier {
  final DatabaseService _db = DatabaseService();

  // ✅ Utiliser le singleton — pas new ApiClient()
  final ApiClient _api = ApiClient.instance;
  final ConnectivityService _connectivity = ConnectivityService();

  Timer? _syncTimer;
  bool _isSyncing = false;
  int _syncProgress = 0;
  String? _lastSyncError;

  bool get isSyncing => _isSyncing;
  int get syncProgress => _syncProgress;
  String? get lastSyncError => _lastSyncError;

  SyncManager() {
    _initAutoSync();
    _connectivity.addListener(_onConnectivityChanged);
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

  Future<void> syncAll({UserModel? user}) async {
    if (_isSyncing) return;

    _isSyncing = true;
    _syncProgress = 0;
    notifyListeners();

    try {
      // 1. Synchroniser les scans
      await _syncScans();
      _syncProgress = 25;
      notifyListeners();

      // 2. Synchroniser les favoris
      await _syncFavorites();
      _syncProgress = 50;
      notifyListeners();

      // 3. Synchroniser les chats
      await _syncChats();
      _syncProgress = 75;
      notifyListeners();

      // 4. Synchroniser l'utilisateur
      if (user != null) {
        await _syncUser(user);
      }
      _syncProgress = 100;
      _lastSyncError = null;
    } catch (e) {
      _lastSyncError = e.toString();
      debugPrint('❌ Erreur sync globale: $e');
    } finally {
      _isSyncing = false;
      notifyListeners();
    }
  }

  Future<void> _syncScans() async {
    final unsynced = await _db.getUnsyncedScans();

    for (final scan in unsynced) {
      try {
        if (scan.filePath != null) {
          final token = await SecureStorage().getToken();
          final request = http.MultipartRequest(
            'POST',
            Uri.parse('${AppConstants.baseUrl}/scans/${scan.type}'),
          );
          request.files.add(
            await http.MultipartFile.fromPath('file', scan.filePath!),
          );
          request.fields['source'] = scan.inputSource ?? 'file';
          if (token != null) {
            request.headers['Authorization'] = 'Bearer $token';
          }

          final response = await request.send();
          if (response.statusCode == 200 || response.statusCode == 202) {
            await _db.markScanAsSynced(scan.id);
          }
        }
      } catch (e) {
        debugPrint('❌ Erreur sync scan ${scan.id}: $e');
      }
    }
  }

  Future<void> _syncFavorites() async {
    // TODO: Implémenter sync favoris
  }

  Future<void> _syncChats() async {
    // TODO: Implémenter sync chats
  }

  Future<void> _syncUser(UserModel user) async {
    try {
      await _api.post('/users/sync', data: user.toJson());
    } catch (e) {
      debugPrint('❌ Erreur sync user: $e');
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

  @override
  void dispose() {
    _syncTimer?.cancel();
    _connectivity.removeListener(_onConnectivityChanged);
    super.dispose();
  }
}
