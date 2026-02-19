// lib/core/database/entities/scan_entity.dart
class ScanEntity {
  final String id;
  final String userId;
  final String type;
  final String? inputSource;
  final String? result;
  final String? filePath;
  final int synced;
  final String scannedAt;

  ScanEntity({
    required this.id,
    required this.userId,
    required this.type,
    this.inputSource,
    this.result,
    this.filePath,
    this.synced = 0,
    required this.scannedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'type': type,
      'inputSource': inputSource,
      'result': result,
      'filePath': filePath,
      'synced': synced,
      'scannedAt': scannedAt,
    };
  }

  factory ScanEntity.fromMap(Map<String, dynamic> map) {
    return ScanEntity(
      id: map['id'],
      userId: map['userId'],
      type: map['type'],
      inputSource: map['inputSource'],
      result: map['result'],
      filePath: map['filePath'],
      synced: map['synced'] ?? 0,
      scannedAt: map['scannedAt'],
    );
  }
}
