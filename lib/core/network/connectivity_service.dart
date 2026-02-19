// lib/core/network/connectivity_service.dart
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';

class ConnectivityService extends ChangeNotifier {
  bool _isOnline = true;
  final Connectivity _connectivity = Connectivity();

  bool get isOnline => _isOnline;

  ConnectivityService() {
    _initConnectivity();
    _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
  }

  Future<void> _initConnectivity() async {
    try {
      final result = await _connectivity.checkConnectivity();
      _updateConnectionStatus(result);
    } catch (e) {
      print('❌ Erreur vérification connexion: $e');
      _isOnline = false;
      notifyListeners();
    }
  }

  // ✅ MÉTHODE PUBLIQUE POUR VÉRIFIER LA CONNEXION
  Future<void> checkConnectivity() async {
    await _initConnectivity();
  }

  void _updateConnectionStatus(List<ConnectivityResult> result) {
    final wasOnline = _isOnline;
    _isOnline = result.isNotEmpty && result.first != ConnectivityResult.none;

    if (wasOnline != _isOnline) {
      print('📡 Connexion: ${_isOnline ? 'ONLINE' : 'OFFLINE'}');
      notifyListeners();

      if (_isOnline) {
        // Déclencher synchronisation automatique
        _triggerSync();
      }
    }
  }

  void _triggerSync() {
    // TODO: Notifier le SyncManager
  }
}
