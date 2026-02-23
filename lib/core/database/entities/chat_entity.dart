// lib/core/database/entities/chat_entity.dart
class ChatEntity {
  final String id;
  final int userId;
  final String messages;
  final bool synced;
  final String lastMessageAt;

  ChatEntity({
    required this.id,
    required this.userId,
    required this.messages,
    this.synced = false,
    required this.lastMessageAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'messages': messages,
      'synced': synced ? 1 : 0,
      'last_message_at': lastMessageAt,
    };
  }

  factory ChatEntity.fromMap(Map<String, dynamic> map) {
    return ChatEntity(
      id: map['id'],
      userId: map['user_id'],
      messages: map['messages'],
      synced: map['synced'] == 1,
      lastMessageAt: map['last_message_at'],
    );
  }
}
