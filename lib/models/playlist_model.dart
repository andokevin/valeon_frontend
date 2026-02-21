import 'content_model.dart';

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
    playlistId: json['playlist_id'],
    playlistName: json['playlist_name'] ?? '',
    playlistDescription: json['playlist_description'],
    playlistImage: json['playlist_image'],
    contentCount: json['content_count'] ?? 0,
    createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
    updatedAt: DateTime.parse(json['updated_at'] ?? DateTime.now().toIso8601String()),
    contents: (json['contents'] as List<dynamic>?)
        ?.map((c) => ContentModel.fromJson(c))
        .toList() ?? [],
  );
}
