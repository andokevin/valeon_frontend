enum ContentType { music, film, image }

class ContentModel {
  final String id;
  final String title;
  final String artist;
  final String year;
  final String genre;
  final String description;
  final String imageUrl;
  final ContentType type;
  final DateTime scannedAt;

  ContentModel({
    required this.id,
    required this.title,
    required this.artist,
    required this.year,
    required this.genre,
    required this.description,
    required this.imageUrl,
    required this.type,
    required this.scannedAt,
  });

  // ===== Conversion JSON =====
  factory ContentModel.fromJson(Map<String, dynamic> json) {
    return ContentModel(
      id: json['id'],
      title: json['title'],
      artist: json['artist'],
      year: json['year'],
      genre: json['genre'],
      description: json['description'],
      imageUrl: json['imageUrl'],
      type: ContentType.values.firstWhere(
        (e) => e.toString() == 'ContentType.${json['type']}',
        orElse: () => ContentType.image, // valeur par défaut
      ),
      scannedAt: json['scannedAt'] != null
          ? DateTime.parse(json['scannedAt'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'artist': artist,
      'year': year,
      'genre': genre,
      'description': description,
      'imageUrl': imageUrl,
      'type': type.toString().split('.').last,
      'scannedAt': scannedAt.toIso8601String(),
    };
  }

  // ===== Getter pratique pour afficher "il y a ..." =====
  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(scannedAt);

    if (difference.inMinutes < 60) {
      return 'Il y a ${difference.inMinutes} min';
    } else if (difference.inHours < 24) {
      return 'Il y a ${difference.inHours} heure${difference.inHours > 1 ? 's' : ''}';
    } else if (difference.inDays < 7) {
      return 'Il y a ${difference.inDays} jour${difference.inDays > 1 ? 's' : ''}';
    } else {
      final weeks = (difference.inDays / 7).floor();
      return 'Il y a $weeks semaine${weeks > 1 ? 's' : ''}';
    }
  }
}
