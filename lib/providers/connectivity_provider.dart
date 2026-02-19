// lib/providers/connectivity_provider.dart
import 'package:flutter/material.dart';
import '../core/network/connectivity_service.dart';

class ConnectivityProvider extends ChangeNotifier {
  late final ConnectivityService _connectivityService;
  bool _isOnline = true;
  bool _isInitialized = false;

  bool get isOnline => _isOnline;
  bool get isOffline => !_isOnline;
  bool get isInitialized => _isInitialized;

  ConnectivityProvider() {
    _connectivityService = ConnectivityService();
    _init();
  }

  void _init() {
    _isOnline = _connectivityService.isOnline;
    _isInitialized = true;

    _connectivityService.addListener(_onConnectivityChanged);
    notifyListeners();
  }

  void _onConnectivityChanged() {
    final wasOnline = _isOnline;
    _isOnline = _connectivityService.isOnline;

    if (wasOnline != _isOnline) {
      print('📡 ConnectivityProvider: ${_isOnline ? 'ONLINE' : 'OFFLINE'}');
      notifyListeners();
    }
  }

  // ✅ MÉTHODE CORRIGÉE - Utilise checkConnectivity() qui est public
  Future<void> checkConnection() async {
    await _connectivityService.checkConnectivity();
  }

  @override
  void dispose() {
    _connectivityService.removeListener(_onConnectivityChanged);
    super.dispose();
  }
}
