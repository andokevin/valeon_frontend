// lib/providers/sync_provider.dart
import 'package:flutter/material.dart';
import 'package:valeon/models/user_model.dart';

// Provider vide car la synchronisation hors ligne a été supprimée
class SyncProvider extends ChangeNotifier {
  bool get isSyncing => false;
  int get syncProgress => 0;
  String? get lastSyncError => null;
  DateTime? get lastSyncTime => null;
  String get syncStatusMessage => 'Synchronisation désactivée';

  Future<void> syncAll({UserModel? user}) async {
    // Ne fait rien car la synchronisation hors ligne a été supprimée
    debugPrint('ℹ️ La synchronisation hors ligne a été supprimée');
    notifyListeners();
  }

  void triggerSync() {
    // Ne fait rien
  }
}
