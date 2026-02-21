import 'dart:convert';
import 'content_model.dart';

enum ScanStatus { pending, processing, completed, failed }
enum ScanType { audio, image, video }

class ScanModel {
  final int? scanId;
  final ScanType scanType;
  final String inputSource;
  final ScanStatus status;
  final Map<String, dynamic>? result;
  final String? error;
  final DateTime scanDate;
  final double? processingTime;
  final ContentModel? content;

  // ✅ Ajout du champ filePath pour le sync
  final String? filePath;

  const ScanModel({
    this.scanId,
    required this.scanType,
    required this.inputSource,
    required this.status,
    this.result,
    this.error,
    required this.scanDate,
    this.processingTime,
    this.content,
    this.filePath,          // ✅ nouveau
  });

  // ✅ Getter pratique : type en String pour les requêtes HTTP
  String get type => scanType.name;

  // ✅ Getter id String pour compatibilité avec DatabaseService
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
    content: json['content'] != null
        ? ContentModel.fromJson(json['content'])
        : null,
    filePath: json['file_path'],       // ✅ nouveau
  );

  factory ScanModel.fromDbMap(Map<String, dynamic> map) => ScanModel(
    scanId: map['scan_id'],
    scanType: ScanType.values.firstWhere(
      (e) => e.name == map['scan_type'],
      orElse: () => ScanType.audio,
    ),
    inputSource: map['input_source'] ?? 'file',
    status: ScanStatus.values.firstWhere(
      (e) => e.name == map['status'],
      orElse: () => ScanStatus.pending,
    ),
    result: map['result'] != null
        ? jsonDecode(map['result']) as Map<String, dynamic>
        : null,
    error: map['error'],
    scanDate: DateTime.tryParse(map['scan_date'] ?? '') ?? DateTime.now(),
    processingTime: (map['processing_time'] as num?)?.toDouble(),
    filePath: map['file_path'],        // ✅ nouveau
  );

  Map<String, dynamic> toDbMap() => {
    if (scanId != null) 'scan_id': scanId,
    'scan_type': scanType.name,
    'input_source': inputSource,
    'status': status.name,
    'result': result != null ? jsonEncode(result) : null,
    'error': error,
    'scan_date': scanDate.toIso8601String(),
    'processing_time': processingTime,
    'file_path': filePath,             // ✅ nouveau
    'synced': 0,
  };

  String get statusLabel {
    switch (status) {
      case ScanStatus.pending: return 'En attente';
      case ScanStatus.processing: return 'Traitement...';
      case ScanStatus.completed: return 'Terminé';
      case ScanStatus.failed: return 'Échoué';
    }
  }
}
