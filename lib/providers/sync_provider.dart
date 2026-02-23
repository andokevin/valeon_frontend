// lib/providers/sync_provider.dart
import 'package:flutter/material.dart';
import '../core/sync/sync_manager.dart';
import '../models/user_model.dart';

class SyncProvider extends ChangeNotifier {
  final SyncManager _syncManager = SyncManager();

  bool get isSyncing => _syncManager.isSyncing;
  int get syncProgress => _syncManager.syncProgress;
  String? get lastSyncError => _syncManager.lastSyncError;
  DateTime? get lastSyncTime => _syncManager.lastSyncTime;
  String get syncStatusMessage => _syncManager.syncStatusMessage;

  Future<void> syncAll({UserModel? user}) async {
    await _syncManager.syncAll(user: user);
    notifyListeners();
  }

  void triggerSync() {
    if (!_syncManager.isSyncing) {
      syncAll();
    }
  }
}
