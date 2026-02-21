import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/scan_model.dart';
import '../services/scan_service.dart';

enum ScanPhase { idle, uploading, processing, done, error }

class ScanState {
  final ScanPhase phase;
  final int? scanId;
  final ScanModel? result;
  final String? error;
  final double uploadProgress;
  const ScanState({
    this.phase = ScanPhase.idle,
    this.scanId,
    this.result,
    this.error,
    this.uploadProgress = 0,
  });
  ScanState copyWith({ScanPhase? phase, int? scanId, ScanModel? result,
      String? error, double? uploadProgress}) =>
      ScanState(
        phase: phase ?? this.phase,
        scanId: scanId ?? this.scanId,
        result: result ?? this.result,
        error: error ?? this.error,
        uploadProgress: uploadProgress ?? this.uploadProgress,
      );
}

class ScanNotifier extends StateNotifier<ScanState> {
  final ScanService _service;
  ScanNotifier(this._service) : super(const ScanState());

  Future<void> scanAudio(File file) => _scan(() => _service.scanAudio(file));
  Future<void> scanImage(File file) => _scan(() => _service.scanImage(file));
  Future<void> scanVideo(File file) => _scan(() => _service.scanVideo(file));

  Future<void> _scan(Future<Map<String, dynamic>> Function() uploadFn) async {
    state = const ScanState(phase: ScanPhase.uploading, uploadProgress: 0);
    try {
      final uploadData = await uploadFn();
      final scanId = uploadData['scan_id'];
      state = state.copyWith(phase: ScanPhase.processing, scanId: scanId, uploadProgress: 1.0);
      final result = await _service.pollScanResult(scanId);
      if (result.status == ScanStatus.failed) {
        state = state.copyWith(phase: ScanPhase.error, error: result.error ?? 'Scan échoué');
      } else {
        state = state.copyWith(phase: ScanPhase.done, result: result);
      }
    } catch (e) {
      state = state.copyWith(phase: ScanPhase.error, error: e.toString());
    }
  }

  void reset() => state = const ScanState();
}

final scanServiceProvider = Provider((_) => ScanService());
final scanProvider = StateNotifierProvider<ScanNotifier, ScanState>(
  (ref) => ScanNotifier(ref.watch(scanServiceProvider)),
);
