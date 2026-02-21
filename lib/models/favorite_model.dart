import 'dart:convert';
import 'content_model.dart';

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
    favoriteId: json['favorite_id'],
    contentId: json['content_id'],
    contentTitle: json['content_title'] ?? '',
    contentType: json['content_type'] ?? 'unknown',
    contentImage: json['content_image'],
    contentArtist: json['content_artist'],
    notes: json['notes'],
    createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
  );

  ContentModel toContent() => ContentModel(
    contentId: contentId,
    contentType: contentType,
    contentTitle: contentTitle,
    contentArtist: contentArtist,
    contentImage: contentImage,
  );
}
