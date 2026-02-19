// lib/core/database/entities/content_entity.dart
class ContentEntity {
  final String id;
  final String type;
  final String title;
  final String? artist;
  final String? description;
  final String? imageUrl;
  final String? releaseDate;
  final String? metadata;
  final int synced;

  ContentEntity({
    required this.id,
    required this.type,
    required this.title,
    this.artist,
    this.description,
    this.imageUrl,
    this.releaseDate,
    this.metadata,
    this.synced = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type,
      'title': title,
      'artist': artist,
      'description': description,
      'imageUrl': imageUrl,
      'releaseDate': releaseDate,
      'metadata': metadata,
      'synced': synced,
    };
  }

  factory ContentEntity.fromMap(Map<String, dynamic> map) {
    return ContentEntity(
      id: map['id'],
      type: map['type'],
      title: map['title'],
      artist: map['artist'],
      description: map['description'],
      imageUrl: map['imageUrl'],
      releaseDate: map['releaseDate'],
      metadata: map['metadata'],
      synced: map['synced'] ?? 0,
    );
  }
}
