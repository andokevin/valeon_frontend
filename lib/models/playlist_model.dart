// lib/models/playlist_model.dart
import 'package:valeon/models/content_model.dart';

class PlaylistModel {
  final int playlistId;
  final String playlistName;
  final String? playlistDescription;
  final String? playlistImage;
  final int contentCount;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<ContentModel> contents;

  const PlaylistModel({
    required this.playlistId,
    required this.playlistName,
    this.playlistDescription,
    this.playlistImage,
    required this.contentCount,
    required this.createdAt,
    required this.updatedAt,
    this.contents = const [],
  });

  factory PlaylistModel.fromJson(Map<String, dynamic> json) => PlaylistModel(
        playlistId: json['playlist_id'] ?? json['playlistId'] ?? 0,
        playlistName: json['playlist_name'] ?? json['name'] ?? '',
        playlistDescription:
            json['playlist_description'] ?? json['description'],
        playlistImage: json['playlist_image'] ?? json['image'],
        contentCount: json['content_count'] ?? json['count'] ?? 0,
        createdAt: DateTime.parse(json['created_at'] ??
            json['createdAt'] ??
            DateTime.now().toIso8601String()),
        updatedAt: DateTime.parse(json['updated_at'] ??
            json['updatedAt'] ??
            DateTime.now().toIso8601String()),
        contents: (json['contents'] as List<dynamic>?)
                ?.map((c) => ContentModel.fromJson(c))
                .toList() ??
            [],
      );

  Map<String, dynamic> toJson() => {
        'playlist_id': playlistId,
        'playlist_name': playlistName,
        'playlist_description': playlistDescription,
        'playlist_image': playlistImage,
        'content_count': contentCount,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
        'contents': contents.map((c) => c.toJson()).toList(),
      };
}