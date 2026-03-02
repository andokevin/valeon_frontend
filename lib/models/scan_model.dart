// lib/models/scan_model.dart
import 'package:valeon/models/content_model.dart';

enum ScanType { audio, image, video }

enum ScanStatus { pending, processing, completed, failed }

class ScanModel {
  final int? scanId;
  final ScanType scanType;
  final String inputSource;
  final ScanStatus status;
  final Map<String, dynamic>? result;
  final String? error;
  final DateTime scanDate;
  final double? processingTime;
  final String? filePath;
  final int scanUser;
  final int? recognizedContentId;
  final ContentModel? content;

  const ScanModel({
    this.scanId,
    required this.scanType,
    required this.inputSource,
    required this.status,
    this.result,
    this.error,
    required this.scanDate,
    this.processingTime,
    this.filePath,
    required this.scanUser,
    this.recognizedContentId,
    this.content,
  });

  String get type => scanType.name;
  String get id => scanId?.toString() ?? '';

  factory ScanModel.fromJson(Map<String, dynamic> json) => ScanModel(
        scanId: json['scan_id'],
        scanType: ScanType.values.firstWhere(
          (e) => e.name == (json['scan_type'] ?? 'audio'),
          orElse: () => ScanType.audio,
        ),
        inputSource: json['input_source'] ?? 'file',
        status: ScanStatus.values.firstWhere(
          (e) => e.name == (json['status'] ?? 'pending'),
          orElse: () => ScanStatus.pending,
        ),
        result: json['result'] is Map
            ? Map<String, dynamic>.from(json['result'])
            : null,
        error: json['error'],
        scanDate: DateTime.tryParse(json['scan_date'] ?? '') ?? DateTime.now(),
        processingTime: (json['processing_time'] as num?)?.toDouble(),
        filePath: json['file_path'],
        scanUser: json['scan_user'] ?? 0,
        recognizedContentId: json['recognized_content_id'],
        content: json['content'] != null
            ? ContentModel.fromJson(json['content'])
            : null,
      );

  Map<String, dynamic> toJson() => {
        'scan_id': scanId,
        'scan_type': scanType.name,
        'input_source': inputSource,
        'status': status.name,
        'result': result,
        'error': error,
        'scan_date': scanDate.toIso8601String(),
        'processing_time': processingTime,
        'file_path': filePath,
        'scan_user': scanUser,
        'recognized_content_id': recognizedContentId,
        'content': content?.toJson(),
      };

  String get statusLabel {
    switch (status) {
      case ScanStatus.pending:
        return 'En attente';
      case ScanStatus.processing:
        return 'Traitement...';
      case ScanStatus.completed:
        return 'Terminé';
      case ScanStatus.failed:
        return 'Échoué';
    }
  }
}
