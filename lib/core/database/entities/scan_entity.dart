// lib/core/database/entities/scan_entity.dart
import 'dart:convert';

class ScanEntity {
  final int? scanId;
  final String scanType;
  final String inputSource;
  final String? filePath;
  final int? fileSize;
  final double? processingTime;
  final String status;
  final String? error;
  final Map<String, dynamic>? result;
  final DateTime scanDate;
  final int scanUser;
  final int? recognizedContentId;
  final bool synced;

  ScanEntity({
    this.scanId,
    required this.scanType,
    required this.inputSource,
    this.filePath,
    this.fileSize,
    this.processingTime,
    required this.status,
    this.error,
    this.result,
    required this.scanDate,
    required this.scanUser,
    this.recognizedContentId,
    this.synced = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'scan_id': scanId,
      'scan_type': scanType,
      'input_source': inputSource,
      'file_path': filePath,
      'file_size': fileSize,
      'processing_time': processingTime,
      'status': status,
      'error': error,
      'result': result != null ? jsonEncode(result) : null,
      'scan_date': scanDate.toIso8601String(),
      'scan_user': scanUser,
      'recognized_content_id': recognizedContentId,
      'synced': synced ? 1 : 0,
    };
  }

  factory ScanEntity.fromMap(Map<String, dynamic> map) {
    return ScanEntity(
      scanId: map['scan_id'],
      scanType: map['scan_type'],
      inputSource: map['input_source'] ?? 'file',
      filePath: map['file_path'],
      fileSize: map['file_size'],
      processingTime: map['processing_time']?.toDouble(),
      status: map['status'] ?? 'pending',
      error: map['error'],
      result: map['result'] != null ? jsonDecode(map['result']) : null,
      scanDate: DateTime.parse(map['scan_date']),
      scanUser: map['scan_user'],
      recognizedContentId: map['recognized_content_id'],
      synced: map['synced'] == 1,
    );
  }
}
