// lib/providers/scan_provider.dart
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/scan_model.dart';
import '../models/user_model.dart';
import '../core/database/database_service.dart';
import '../core/network/connectivity_service.dart';
import '../config/app_config.dart';
import '../utils/secure_storage.dart';

class ScanProvider extends ChangeNotifier {
  final DatabaseService _db = DatabaseService();
  final ConnectivityService _connectivity = ConnectivityService();
  final SecureStorage _secureStorage = SecureStorage();

  List<Scan> _scans = [];
  bool _isLoading = false;
  String? _errorMessage;
  Map<String, dynamic>? _lastResult;

  List<Scan> get scans => _scans;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  Map<String, dynamic>? get lastResult => _lastResult;

  Future<void> loadUserScans(UserModel user) async {
    _isLoading = true;
    notifyListeners();

    try {
      _scans = await _db.getUserScans(user.id);
    } catch (e) {
      _errorMessage = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<Map<String, dynamic>?> scanAudio(
    String filePath,
    UserModel user,
  ) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Créer le scan local immédiatement
      final scan = Scan(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: user.id,
        type: ScanType.audio,
        inputSource: 'file',
        scannedAt: DateTime.now(),
        synced: false,
      );

      await _db.insertScan(scan);
      _scans.insert(0, scan);
      notifyListeners();

      // Si connecté, envoyer à l'API
      if (_connectivity.isOnline) {
        final result = await _sendScanToApi(filePath, user);

        if (result != null) {
          // Mettre à jour le scan avec le résultat
          final updatedScan = Scan(
            id: scan.id,
            userId: user.id,
            type: ScanType.audio,
            result: result,
            scannedAt: scan.scannedAt,
            synced: true,
          );
          await _db.insertScan(updatedScan);
          await _db.markScanAsSynced(scan.id);

          final index = _scans.indexWhere((s) => s.id == scan.id);
          if (index != -1) {
            _scans[index] = updatedScan;
          }

          _lastResult = result;
          notifyListeners();
          return result;
        }
      }

      return null;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>?> _sendScanToApi(
    String filePath,
    UserModel user,
  ) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('${AppConfig.apiBaseUrl}/scans/audio'),
      );

      request.files.add(await http.MultipartFile.fromPath('file', filePath));
      request.fields['source'] = 'file';

      final token = await _secureStorage.getToken();
      request.headers['Authorization'] = 'Bearer $token';

      final response = await request.send();
      final responseData = await response.stream.bytesToString();

      if (response.statusCode == 200 || response.statusCode == 202) {
        return jsonDecode(responseData);
      } else {
        throw Exception('Erreur API: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Erreur envoi scan: $e');
      return null;
    }
  }

  Future<void> syncUnsyncedScans(UserModel user) async {
    if (!_connectivity.isOnline) return;

    final unsynced = await _db.getUnsyncedScans();

    for (var scan in unsynced) {
      if (scan.userId == user.id) {
        // Réessayer d'envoyer
        if (scan.filePath != null) {
          await _sendScanToApi(scan.filePath!, user);
        }
      }
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
