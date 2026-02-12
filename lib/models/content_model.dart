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
      return 'Il y a ${(difference.inDays / 7).floor()} semaine${(difference.inDays / 7).floor() > 1 ? 's' : ''}';
    }
  }
}

enum ContentType {
  music,
  film,
  image,
}