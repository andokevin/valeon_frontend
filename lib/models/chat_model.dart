// lib/models/chat_model.dart
class ChatMessage {
  final String id;
  final String role; // 'user' ou 'assistant'
  final String content;
  final DateTime timestamp;
  final bool synced;

  ChatMessage({
    required this.id,
    required this.role,
    required this.content,
    required this.timestamp,
    this.synced = false,
  });

  factory ChatMessage.user(String content) {
    return ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      role: 'user',
      content: content,
      timestamp: DateTime.now(),
    );
  }

  factory ChatMessage.assistant(String content) {
    return ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      role: 'assistant',
      content: content,
      timestamp: DateTime.now(),
    );
  }

  factory ChatMessage.fromMap(Map<String, dynamic> map) {
    return ChatMessage(
      id: map['id'],
      role: map['role'],
      content: map['content'],
      timestamp: DateTime.parse(map['timestamp']),
      synced: map['synced'] == 1,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'role': role,
      'content': content,
      'timestamp': timestamp.toIso8601String(),
      'synced': synced ? 1 : 0,
    };
  }

  // ✅ Méthode pour créer une copie avec synced modifié
  ChatMessage copyWith({bool? synced}) {
    return ChatMessage(
      id: id,
      role: role,
      content: content,
      timestamp: timestamp,
      synced: synced ?? this.synced,
    );
  }
}

class ChatConversation {
  final String id;
  final String userId;
  final List<ChatMessage> messages;

  // ✅ Rendu non-final pour pouvoir le modifier
  DateTime lastMessageAt;
  bool synced;

  ChatConversation({
    required this.id,
    required this.userId,
    required this.messages,
    required this.lastMessageAt,
    this.synced = false,
  });

  factory ChatConversation.fromMap(Map<String, dynamic> map) {
    return ChatConversation(
      id: map['id'],
      userId: map['userId'],
      messages: (map['messages'] as List)
          .map((m) => ChatMessage.fromMap(m))
          .toList(),
      lastMessageAt: DateTime.parse(map['lastMessageAt']),
      synced: map['synced'] == 1,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'messages': messages.map((m) => m.toMap()).toList(),
      'lastMessageAt': lastMessageAt.toIso8601String(),
      'synced': synced ? 1 : 0,
    };
  }

  // ✅ Méthode utilitaire pour ajouter un message
  void addMessage(ChatMessage message) {
    messages.add(message);
    lastMessageAt = DateTime.now();
    synced = false;
  }

  // ✅ Méthode pour créer une copie avec synced modifié
  ChatConversation copyWith({bool? synced}) {
    return ChatConversation(
      id: id,
      userId: userId,
      messages: messages.map((m) => m).toList(),
      lastMessageAt: lastMessageAt,
      synced: synced ?? this.synced,
    );
  }

  // ✅ Obtenir le dernier message
  ChatMessage? get lastMessage => messages.isNotEmpty ? messages.last : null;
}
