// lib/core/database/entities/content_entity.dart
import 'dart:convert';

class ContentEntity {
  final int? contentId;
  final String contentType;
  final String contentTitle;
  final String? contentOriginalTitle;
  final String? contentDescription;
  final String? contentArtist;
  final String? contentDirector;
  final List<String>? contentCast;
  final String? contentImage;
  final String? contentBackdrop;
  final String? contentReleaseDate;
  final int? contentDuration;
  final double? contentRating;
  final String? contentUrl;
  final DateTime contentDate;
  final String? spotifyId;
  final int? tmdbId;
  final String? imdbId;
  final String? youtubeId;
  final int? justwatchId;
  final Map<String, dynamic>? contentMetadata;
  final bool synced;

  ContentEntity({
    this.contentId,
    required this.contentType,
    required this.contentTitle,
    this.contentOriginalTitle,
    this.contentDescription,
    this.contentArtist,
    this.contentDirector,
    this.contentCast,
    this.contentImage,
    this.contentBackdrop,
    this.contentReleaseDate,
    this.contentDuration,
    this.contentRating,
    this.contentUrl,
    required this.contentDate,
    this.spotifyId,
    this.tmdbId,
    this.imdbId,
    this.youtubeId,
    this.justwatchId,
    this.contentMetadata,
    this.synced = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'content_id': contentId,
      'content_type': contentType,
      'content_title': contentTitle,
      'content_original_title': contentOriginalTitle,
      'content_description': contentDescription,
      'content_artist': contentArtist,
      'content_director': contentDirector,
      'content_cast': contentCast != null ? jsonEncode(contentCast) : null,
      'content_image': contentImage,
      'content_backdrop': contentBackdrop,
      'content_release_date': contentReleaseDate,
      'content_duration': contentDuration,
      'content_rating': contentRating,
      'content_url': contentUrl,
      'content_date': contentDate.toIso8601String(),
      'spotify_id': spotifyId,
      'tmdb_id': tmdbId,
      'imdb_id': imdbId,
      'youtube_id': youtubeId,
      'justwatch_id': justwatchId,
      'content_metadata':
          contentMetadata != null ? jsonEncode(contentMetadata) : null,
      'synced': synced ? 1 : 0,
    };
  }

  factory ContentEntity.fromMap(Map<String, dynamic> map) {
    return ContentEntity(
      contentId: map['content_id'],
      contentType: map['content_type'],
      contentTitle: map['content_title'],
      contentOriginalTitle: map['content_original_title'],
      contentDescription: map['content_description'],
      contentArtist: map['content_artist'],
      contentDirector: map['content_director'],
      contentCast: map['content_cast'] != null
          ? List<String>.from(jsonDecode(map['content_cast']))
          : null,
      contentImage: map['content_image'],
      contentBackdrop: map['content_backdrop'],
      contentReleaseDate: map['content_release_date'],
      contentDuration: map['content_duration'],
      contentRating: map['content_rating']?.toDouble(),
      contentUrl: map['content_url'],
      contentDate: DateTime.parse(map['content_date']),
      spotifyId: map['spotify_id'],
      tmdbId: map['tmdb_id'],
      imdbId: map['imdb_id'],
      youtubeId: map['youtube_id'],
      justwatchId: map['justwatch_id'],
      contentMetadata: map['content_metadata'] != null
          ? jsonDecode(map['content_metadata'])
          : null,
      synced: map['synced'] == 1,
    );
  }
}
