// lib/core/database/entities/favorite_entity.dart
class FavoriteEntity {
  final int? favoriteId;
  final int userId;
  final int contentId;
  final String? notes;
  final DateTime createdAt;
  final bool synced;

  FavoriteEntity({
    this.favoriteId,
    required this.userId,
    required this.contentId,
    this.notes,
    required this.createdAt,
    this.synced = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'favorite_id': favoriteId,
      'user_id': userId,
      'content_id': contentId,
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
      'synced': synced ? 1 : 0,
    };
  }

  factory FavoriteEntity.fromMap(Map<String, dynamic> map) {
    return FavoriteEntity(
      favoriteId: map['favorite_id'],
      userId: map['user_id'],
      contentId: map['content_id'],
      notes: map['notes'],
      createdAt: DateTime.parse(map['created_at']),
      synced: map['synced'] == 1,
    );
  }
}
