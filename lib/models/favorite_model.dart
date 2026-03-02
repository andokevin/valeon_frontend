// lib/models/favorite_model.dart
import 'package:valeon/models/content_model.dart';

class FavoriteModel {
  final int favoriteId;
  final int contentId;
  final String contentTitle;
  final String contentType;
  final String? contentImage;
  final String? contentArtist;
  final String? notes;
  final DateTime createdAt;

  const FavoriteModel({
    required this.favoriteId,
    required this.contentId,
    required this.contentTitle,
    required this.contentType,
    this.contentImage,
    this.contentArtist,
    this.notes,
    required this.createdAt,
  });

  factory FavoriteModel.fromJson(Map<String, dynamic> json) => FavoriteModel(
        favoriteId: json['favorite_id'] ?? json['favoriteId'] ?? 0,
        contentId: json['content_id'] ?? json['contentId'] ?? 0,
        contentTitle: json['content_title'] ?? json['title'] ?? '',
        contentType: json['content_type'] ?? json['type'] ?? 'unknown',
        contentImage: json['content_image'] ?? json['image'],
        contentArtist: json['content_artist'] ?? json['artist'],
        notes: json['notes'],
        createdAt: DateTime.parse(
            json['created_at'] ?? DateTime.now().toIso8601String()),
      );

  Map<String, dynamic> toJson() => {
        'favorite_id': favoriteId,
        'content_id': contentId,
        'content_title': contentTitle,
        'content_type': contentType,
        'content_image': contentImage,
        'content_artist': contentArtist,
        'notes': notes,
        'created_at': createdAt.toIso8601String(),
      };

  ContentModel toContent() => ContentModel(
        contentId: contentId,
        contentType: contentType,
        contentTitle: contentTitle,
        contentArtist: contentArtist,
        contentImage: contentImage,
      );
}