// lib/core/database/entities/playlist_entity.dart
import 'dart:convert';

class PlaylistEntity {
  final int? playlistId;
  final String playlistName;
  final String? playlistDescription;
  final String? playlistImage;
  final int userId;
  final bool isPublic;
  final bool isCollaborative;
  final int contentCount;
  final Map<String, dynamic>? playlistMetadata;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool synced;

  PlaylistEntity({
    this.playlistId,
    required this.playlistName,
    this.playlistDescription,
    this.playlistImage,
    required this.userId,
    this.isPublic = false,
    this.isCollaborative = false,
    this.contentCount = 0,
    this.playlistMetadata,
    required this.createdAt,
    required this.updatedAt,
    this.synced = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'playlist_id': playlistId,
      'playlist_name': playlistName,
      'playlist_description': playlistDescription,
      'playlist_image': playlistImage,
      'user_id': userId,
      'is_public': isPublic ? 1 : 0,
      'is_collaborative': isCollaborative ? 1 : 0,
      'content_count': contentCount,
      'playlist_metadata':
          playlistMetadata != null ? jsonEncode(playlistMetadata) : null,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'synced': synced ? 1 : 0,
    };
  }

  factory PlaylistEntity.fromMap(Map<String, dynamic> map) {
    return PlaylistEntity(
      playlistId: map['playlist_id'],
      playlistName: map['playlist_name'],
      playlistDescription: map['playlist_description'],
      playlistImage: map['playlist_image'],
      userId: map['user_id'],
      isPublic: map['is_public'] == 1,
      isCollaborative: map['is_collaborative'] == 1,
      contentCount: map['content_count'] ?? 0,
      playlistMetadata: map['playlist_metadata'] != null
          ? jsonDecode(map['playlist_metadata'])
          : null,
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: DateTime.parse(map['updated_at']),
      synced: map['synced'] == 1,
    );
  }
}
