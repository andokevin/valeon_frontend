// lib/providers/sync_provider.dart
import 'package:flutter/material.dart';
import '../core/sync/sync_manager.dart';
import '../models/user_model.dart';

class SyncProvider extends ChangeNotifier {
  final SyncManager _syncManager = SyncManager();

  bool get isSyncing => _syncManager.isSyncing;
  int get syncProgress => _syncManager.syncProgress;
  String? get lastSyncError => _syncManager.lastSyncError;

  Future<void> syncAll({User? user}) async {
    await _syncManager.syncAll(user: user);
    notifyListeners();
  }

  String get syncStatus {
    if (isSyncing) {
      return 'Synchronisation... $syncProgress%';
    } else if (lastSyncError != null) {
      return 'Erreur: $lastSyncError';
    } else {
      return 'À jour';
    }
  }
}
