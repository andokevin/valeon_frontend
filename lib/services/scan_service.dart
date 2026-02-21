import 'dart:io';
import 'package:dio/dio.dart';
import '../core/errors/app_exception.dart';
import '../core/network/api_client.dart';
import '../models/scan_model.dart';

class ScanService {
  final _api = ApiClient.instance;

  Future<Map<String, dynamic>> scanAudio(File file) async {
    try {
      final data = FormData.fromMap({
        'file': await MultipartFile.fromFile(file.path, filename: file.path.split('/').last),
        'source': 'file',
      });
      final res = await _api.uploadFile('/scans/audio', data);
      return res.data;
    } on DioException catch (e) {
      throw AppException.fromDio(e);
    }
  }

  Future<Map<String, dynamic>> scanImage(File file) async {
    try {
      final data = FormData.fromMap({
        'file': await MultipartFile.fromFile(file.path, filename: file.path.split('/').last),
        'source': 'file',
      });
      final res = await _api.uploadFile('/scans/image', data);
      return res.data;
    } on DioException catch (e) {
      throw AppException.fromDio(e);
    }
  }

  Future<Map<String, dynamic>> scanVideo(File file) async {
    try {
      final data = FormData.fromMap({
        'file': await MultipartFile.fromFile(file.path, filename: file.path.split('/').last),
        'source': 'file',
      });
      final res = await _api.uploadFile('/scans/video', data);
      return res.data;
    } on DioException catch (e) {
      throw AppException.fromDio(e);
    }
  }

  Future<ScanModel> getScanResult(int scanId) async {
    try {
      final res = await _api.get('/scans/$scanId');
      return ScanModel.fromJson(res.data);
    } on DioException catch (e) {
      throw AppException.fromDio(e);
    }
  }

  Future<ScanModel> pollScanResult(int scanId, {int maxAttempts = 30}) async {
    for (var i = 0; i < maxAttempts; i++) {
      await Future.delayed(const Duration(seconds: 2));
      final scan = await getScanResult(scanId);
      if (scan.status == ScanStatus.completed || scan.status == ScanStatus.failed) {
        return scan;
      }
    }
    throw const AppException('Délai de traitement dépassé', code: 'timeout');
  }
}
