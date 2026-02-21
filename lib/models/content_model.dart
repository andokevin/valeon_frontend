import 'dart:convert';

class ContentModel {
  final int contentId;
  final String contentType;
  final String contentTitle;
  final String? contentOriginalTitle;
  final String? contentDescription;
  final String? contentArtist;
  final String? contentDirector;
  final String? contentImage;
  final String? contentBackdrop;
  final String? contentReleaseDate;
  final int? contentDuration;
  final double? contentRating;
  final String? contentUrl;
  final String? spotifyId;
  final int? tmdbId;
  final String? youtubeId;
  final Map<String, dynamic>? metadata;

  const ContentModel({
    required this.contentId,
    required this.contentType,
    required this.contentTitle,
    this.contentOriginalTitle,
    this.contentDescription,
    this.contentArtist,
    this.contentDirector,
    this.contentImage,
    this.contentBackdrop,
    this.contentReleaseDate,
    this.contentDuration,
    this.contentRating,
    this.contentUrl,
    this.spotifyId,
    this.tmdbId,
    this.youtubeId,
    this.metadata,
  });

  factory ContentModel.fromJson(Map<String, dynamic> json) => ContentModel(
    contentId: json['content_id'] ?? 0,
    contentType: json['content_type'] ?? 'unknown',
    contentTitle: json['content_title'] ?? json['title'] ?? '',
    contentOriginalTitle: json['content_original_title'],
    contentDescription: json['content_description'] ?? json['description'],
    contentArtist: json['content_artist'] ?? json['artist'],
    contentDirector: json['content_director'],
    contentImage: json['content_image'] ?? json['image'],
    contentBackdrop: json['content_backdrop'],
    contentReleaseDate: json['content_release_date'],
    contentDuration: json['content_duration'],
    contentRating: (json['content_rating'])?.toDouble(),
    contentUrl: json['content_url'],
    spotifyId: json['spotify_id'],
    tmdbId: json['tmdb_id'],
    youtubeId: json['youtube_id'],
    metadata: json['content_metadata'] is Map
        ? Map<String, dynamic>.from(json['content_metadata'])
        : null,
  );

  factory ContentModel.fromDbMap(Map<String, dynamic> map) => ContentModel(
    contentId: map['content_id'] ?? 0,
    contentType: map['content_type'] ?? 'unknown',
    contentTitle: map['content_title'] ?? '',
    contentOriginalTitle: map['content_original_title'],
    contentDescription: map['content_description'],
    contentArtist: map['content_artist'],
    contentDirector: map['content_director'],
    contentImage: map['content_image'],
    contentBackdrop: map['content_backdrop'],
    contentReleaseDate: map['content_release_date'],
    contentDuration: map['content_duration'],
    contentRating: map['content_rating']?.toDouble(),
    contentUrl: map['content_url'],
    spotifyId: map['spotify_id'],
    tmdbId: map['tmdb_id'],
    youtubeId: map['youtube_id'],
    metadata: map['content_metadata'] != null
        ? jsonDecode(map['content_metadata']) as Map<String, dynamic>
        : null,
  );

  Map<String, dynamic> toJson() => {
    'content_id': contentId,
    'content_type': contentType,
    'content_title': contentTitle,
    'content_original_title': contentOriginalTitle,
    'content_description': contentDescription,
    'content_artist': contentArtist,
    'content_director': contentDirector,
    'content_image': contentImage,
    'content_backdrop': contentBackdrop,
    'content_release_date': contentReleaseDate,
    'content_duration': contentDuration,
    'content_rating': contentRating,
    'content_url': contentUrl,
    'spotify_id': spotifyId,
    'tmdb_id': tmdbId,
    'youtube_id': youtubeId,
    'content_metadata': metadata,
  };

  Map<String, dynamic> toDbMap() => {
    'content_id': contentId,
    'content_type': contentType,
    'content_title': contentTitle,
    'content_original_title': contentOriginalTitle,
    'content_description': contentDescription,
    'content_artist': contentArtist,
    'content_director': contentDirector,
    'content_image': contentImage,
    'content_backdrop': contentBackdrop,
    'content_release_date': contentReleaseDate,
    'content_duration': contentDuration,
    'content_rating': contentRating,
    'content_url': contentUrl,
    'spotify_id': spotifyId,
    'tmdb_id': tmdbId,
    'youtube_id': youtubeId,
    'content_metadata': metadata != null ? jsonEncode(metadata) : null,
    'content_date': DateTime.now().toIso8601String(),
  };

  String get typeLabel {
    switch (contentType) {
      case 'music': return '🎵 Musique';
      case 'movie': return '🎬 Film';
      case 'tv_show': return '📺 Série';
      case 'album_cover': return '💿 Album';
      case 'movie_poster': return '🎬 Film';
      default: return '📁 Contenu';
    }
  }
}
