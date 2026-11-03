// lib/models/content_model.dart
class ContentModel {
  final int contentId;
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
  final String? spotifyId;
  final int? tmdbId;
  final String? youtubeId;
  final Map<String, dynamic>? metadata;

  /// Données reçues de l'API telles quelles (raison, liens YouTube/Spotify…)
  final Map<String, dynamic>? raw;

  const ContentModel({
    required this.contentId,
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
    this.spotifyId,
    this.tmdbId,
    this.youtubeId,
    this.metadata,
    this.raw,
  });

  String get id => contentId.toString();

  factory ContentModel.fromJson(Map<String, dynamic> json) {
    return ContentModel(
      contentId: json['content_id'] ?? json['id'] ?? 0,
      contentType: json['content_type'] ?? json['type'] ?? 'unknown',
      contentTitle: json['content_title'] ?? json['title'] ?? '',
      contentOriginalTitle: json['content_original_title'],
      contentDescription: json['content_description'] ?? json['description'],
      contentArtist: json['content_artist'] ?? json['artist'],
      contentDirector: json['content_director'] ?? json['director'],
      contentCast: json['content_cast'] != null
          ? List<String>.from(json['content_cast'])
          : (json['cast'] != null ? List<String>.from(json['cast']) : null),
      contentImage: json['content_image'] ?? json['image'],
      contentBackdrop: json['content_backdrop'] ?? json['backdrop'],
      contentReleaseDate: json['content_release_date'] ?? json['release_date'],
      contentDuration: json['content_duration'] ?? json['duration'],
      contentRating: (json['content_rating'] ?? json['rating'])?.toDouble(),
      contentUrl: json['content_url'] ?? json['url'],
      spotifyId: json['spotify_id'],
      tmdbId: json['tmdb_id'],
      youtubeId: json['youtube_id'],
      metadata: json['metadata'] ?? json['content_metadata'],
      raw: json,
    );
  }

  bool get isMusic => contentType == 'music';

  /// Données pour ouvrir la page de détail (ScanResultScreen) d'une recommandation
  Map<String, dynamic> toScanResult() {
    final result = <String, dynamic>{...?raw};
    result['title'] = contentTitle;
    result['artist'] ??= contentArtist ?? contentDirector;
    result['type'] = contentType;
    result['image'] ??= contentImage;
    result['description'] ??= contentDescription ?? raw?['reason'];
    result['year'] ??= (contentReleaseDate != null && contentReleaseDate!.length >= 4)
        ? contentReleaseDate!.substring(0, 4)
        : null;
    if (contentId != 0) result['content_id'] = contentId;

    // Lien Spotify : celui de l'API, sinon une recherche Spotify par titre + artiste
    if (isMusic && result['spotify'] == null) {
      final url = raw?['spotify_url'] ??
          (spotifyId != null
              ? 'https://open.spotify.com/track/$spotifyId'
              : 'https://open.spotify.com/search/${Uri.encodeComponent('$contentTitle ${contentArtist ?? ''}'.trim())}');
      result['spotify'] = {'spotify_url': url};
    }
    // Lien YouTube fourni à plat par certaines réponses
    if (result['youtube'] == null && raw?['youtube_url'] != null) {
      result['youtube'] = {'url': raw!['youtube_url']};
    }
    return result;
  }

  Map<String, dynamic> toJson() => {
        'content_id': contentId,
        'content_type': contentType,
        'content_title': contentTitle,
        'content_original_title': contentOriginalTitle,
        'content_description': contentDescription,
        'content_artist': contentArtist,
        'content_director': contentDirector,
        'content_cast': contentCast,
        'content_image': contentImage,
        'content_backdrop': contentBackdrop,
        'content_release_date': contentReleaseDate,
        'content_duration': contentDuration,
        'content_rating': contentRating,
        'content_url': contentUrl,
        'spotify_id': spotifyId,
        'tmdb_id': tmdbId,
        'youtube_id': youtubeId,
        'metadata': metadata,
      };

  String get typeLabel {
    switch (contentType) {
      case 'music':
        return '🎵 Musique';
      case 'movie':
        return '🎬 Film';
      case 'tv_show':
        return '📺 Série';
      case 'album_cover':
        return '💿 Album';
      case 'movie_poster':
        return '🎬 Film';
      default:
        return '📁 Contenu';
    }
  }
}