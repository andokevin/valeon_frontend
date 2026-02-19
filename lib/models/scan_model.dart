// lib/models/scan_model.dart
enum ScanType { audio, image, video }

enum ScanStatus { pending, processing, completed, failed }

class Scan {
  final String id;
  final String userId;
  final ScanType type;
  final String? inputSource;
  final Map<String, dynamic>? result;
  final String? filePath;
  final bool synced;
  final DateTime scannedAt;

  Scan({
    required this.id,
    required this.userId,
    required this.type,
    this.inputSource,
    this.result,
    this.filePath,
    this.synced = false,
    required this.scannedAt,
  });

  factory Scan.fromMap(Map<String, dynamic> map) {
    return Scan(
      id: map['id'],
      userId: map['userId'],
      type: ScanType.values.firstWhere(
        (e) => e.toString() == 'ScanType.${map['type']}',
        orElse: () => ScanType.audio,
      ),
      inputSource: map['inputSource'],
      result: map['result'] != null
          ? Map<String, dynamic>.from(map['result'])
          : null,
      filePath: map['filePath'],
      synced: map['synced'] == 1,
      scannedAt: DateTime.parse(map['scannedAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'type': type.toString().split('.').last,
      'inputSource': inputSource,
      'result': result,
      'filePath': filePath,
      'synced': synced ? 1 : 0,
      'scannedAt': scannedAt.toIso8601String(),
    };
  }

  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(scannedAt);

    if (difference.inMinutes < 60) {
      return 'Il y a ${difference.inMinutes} min';
    } else if (difference.inHours < 24) {
      return 'Il y a ${difference.inHours} h';
    } else if (difference.inDays < 7) {
      return 'Il y a ${difference.inDays} j';
    } else {
      return 'Il y a ${(difference.inDays / 7).floor()} sem';
    }
  }
}
