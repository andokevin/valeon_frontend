// lib/core/database/entities/chat_entity.dart
class ChatEntity {
  final String id;
  final String userId;
  final String messages;
  final int synced;
  final String lastMessageAt;

  ChatEntity({
    required this.id,
    required this.userId,
    required this.messages,
    this.synced = 0,
    required this.lastMessageAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'messages': messages,
      'synced': synced,
      'lastMessageAt': lastMessageAt,
    };
  }

  factory ChatEntity.fromMap(Map<String, dynamic> map) {
    return ChatEntity(
      id: map['id'],
      userId: map['userId'],
      messages: map['messages'],
      synced: map['synced'] ?? 0,
      lastMessageAt: map['lastMessageAt'],
    );
  }
}
