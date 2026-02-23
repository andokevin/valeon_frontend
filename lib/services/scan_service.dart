// lib/services/scan_service.dart
import 'dart:io';
import 'package:dio/dio.dart';
import '../core/errors/app_exception.dart';
import '../core/network/api_client.dart';
import '../models/scan_model.dart';

class ScanService {
  final ApiClient _api = ApiClient();

  ScanService() {
    _api.init();
  }

  Future<Map<String, dynamic>> scanAudio(File file) async {
    try {
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(file.path,
            filename: file.path.split('/').last),
        'source': 'file',
      });
      final response = await _api.uploadFile('/scans/audio', formData);
      return response.data;
    } on DioException catch (e) {
      throw AppException.fromDio(e);
    }
  }

  Future<Map<String, dynamic>> scanImage(File file) async {
    try {
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(file.path,
            filename: file.path.split('/').last),
        'source': 'file',
      });
      final response = await _api.uploadFile('/scans/image', formData);
      return response.data;
    } on DioException catch (e) {
      throw AppException.fromDio(e);
    }
  }

  Future<Map<String, dynamic>> scanVideo(File file) async {
    try {
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(file.path,
            filename: file.path.split('/').last),
        'source': 'file',
      });
      final response = await _api.uploadFile('/scans/video', formData);
      return response.data;
    } on DioException catch (e) {
      throw AppException.fromDio(e);
    }
  }

  Future<ScanModel> getScanResult(int scanId) async {
    try {
      final response = await _api.get('/scans/$scanId');
      return ScanModel.fromJson(response.data);
    } on DioException catch (e) {
      throw AppException.fromDio(e);
    }
  }

  Future<ScanModel> pollScanResult(int scanId, {int maxAttempts = 30}) async {
    for (var i = 0; i < maxAttempts; i++) {
      await Future.delayed(const Duration(seconds: 2));
      final scan = await getScanResult(scanId);
      if (scan.status == ScanStatus.completed ||
          scan.status == ScanStatus.failed) {
        return scan;
      }
    }
    throw const AppException('Délai de traitement dépassé');
  }
}
