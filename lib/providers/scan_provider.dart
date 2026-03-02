// lib/providers/scan_provider.dart
import 'dart:io';
import 'package:flutter/material.dart';
import '../models/scan_model.dart';
import '../models/user_model.dart';
import '../services/scan_service.dart';
import '../core/network/connectivity_service.dart';
import '../utils/secure_storage.dart';

enum ScanPhase { idle, uploading, processing, done, error }

class ScanProvider extends ChangeNotifier {
  final ScanService _service = ScanService();
  final ConnectivityService _connectivity = ConnectivityService();
  final SecureStorage _secureStorage = SecureStorage();

  ScanPhase _phase = ScanPhase.idle;
  int? _currentScanId;
  ScanModel? _result;
  String? _errorMessage;
  double _uploadProgress = 0;
  List<ScanModel> _history = [];

  ScanPhase get phase => _phase;
  int? get currentScanId => _currentScanId;
  ScanModel? get result => _result;
  String? get errorMessage => _errorMessage;
  double get uploadProgress => _uploadProgress;
  List<ScanModel> get history => _history;
  bool get isLoading => _phase != ScanPhase.idle && _phase != ScanPhase.done;

  Future<void> loadHistory(UserModel user) async {
    try {
      if (!_connectivity.isOnline) {
        debugPrint('❌ Pas de connexion pour charger l\'historique');
        return;
      }
      _history = await _service.getHistory();
      notifyListeners();
    } catch (e) {
      debugPrint('❌ Erreur chargement historique: $e');
    }
  }

  Future<void> scanAudio(File file, UserModel user) async {
    await _scan(() => _service.scanAudio(file), ScanType.audio, user);
  }

  Future<void> scanImage(File file, UserModel user) async {
    await _scan(() => _service.scanImage(file), ScanType.image, user);
  }

  Future<void> scanVideo(File file, UserModel user) async {
    await _scan(() => _service.scanVideo(file), ScanType.video, user);
  }

  Future<void> _scan(
    Future<Map<String, dynamic>> Function() scanFn,
    ScanType type,
    UserModel user,
  ) async {
    _phase = ScanPhase.uploading;
    _uploadProgress = 0;
    _errorMessage = null;
    notifyListeners();

    try {
      if (!_connectivity.isOnline) {
        throw Exception('Connexion internet requise pour scanner');
      }

      // Envoyer à l'API
      final uploadData = await scanFn();
      _currentScanId = uploadData['scan_id'];

      _phase = ScanPhase.processing;
      notifyListeners();

      // Poll pour le résultat
      final scanResult = await _service.pollScanResult(_currentScanId!);
      _result = scanResult;

      if (scanResult.status == ScanStatus.failed) {
        _phase = ScanPhase.error;
        _errorMessage = scanResult.error ?? 'Scan échoué';
      } else {
        _phase = ScanPhase.done;
        _history.insert(0, scanResult);
      }
    } catch (e) {
      _phase = ScanPhase.error;
      _errorMessage = e.toString();
    }

    notifyListeners();
  }

  Future<ScanModel?> getScanById(int scanId) async {
    try {
      if (!_connectivity.isOnline) {
        throw Exception('Connexion internet requise');
      }
      return await _service.getScanResult(scanId);
    } catch (e) {
      debugPrint('❌ Erreur récupération scan: $e');
      return null;
    }
  }

  void reset() {
    _phase = ScanPhase.idle;
    _currentScanId = null;
    _result = null;
    _errorMessage = null;
    _uploadProgress = 0;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
