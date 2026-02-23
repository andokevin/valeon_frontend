// lib/models/chat_model.dart
enum MessageRole { user, assistant, system }

class ChatMessage {
  final String id;
  final MessageRole role;
  final String content;
  final DateTime timestamp;
  final bool synced;

  const ChatMessage({
    required this.id,
    required this.role,
    required this.content,
    required this.timestamp,
    this.synced = false,
  });

  factory ChatMessage.user(String content) {
    return ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      role: MessageRole.user,
      content: content,
      timestamp: DateTime.now(),
    );
  }

  factory ChatMessage.assistant(String content) {
    return ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      role: MessageRole.assistant,
      content: content,
      timestamp: DateTime.now(),
    );
  }

  factory ChatMessage.system(String content) {
    return ChatMessage(
      id: 'system-${DateTime.now().millisecondsSinceEpoch}',
      role: MessageRole.system,
      content: content,
      timestamp: DateTime.now(),
    );
  }

  factory ChatMessage.fromJson(Map<String, dynamic> json) => ChatMessage(
        id: json['id'] ?? '',
        role: _roleFromString(json['role'] ?? 'assistant'),
        content: json['content'] ?? '',
        timestamp: DateTime.parse(
            json['timestamp'] ?? DateTime.now().toIso8601String()),
        synced: json['synced'] == true,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'role': _roleToString(role),
        'content': content,
        'timestamp': timestamp.toIso8601String(),
        'synced': synced,
      };

  static MessageRole _roleFromString(String role) {
    switch (role.toLowerCase()) {
      case 'user':
        return MessageRole.user;
      case 'system':
        return MessageRole.system;
      default:
        return MessageRole.assistant;
    }
  }

  static String _roleToString(MessageRole role) {
    switch (role) {
      case MessageRole.user:
        return 'user';
      case MessageRole.system:
        return 'system';
      case MessageRole.assistant:
        return 'assistant';
    }
  }

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
  final DateTime lastMessageAt;
  final bool synced;

  const ChatConversation({
    required this.id,
    required this.userId,
    required this.messages,
    required this.lastMessageAt,
    this.synced = false,
  });

  factory ChatConversation.fromJson(Map<String, dynamic> json) =>
      ChatConversation(
        id: json['id'] ?? '',
        userId: json['userId'] ?? json['user_id'] ?? '',
        messages: (json['messages'] as List<dynamic>? ?? [])
            .map((m) => ChatMessage.fromJson(m as Map<String, dynamic>))
            .toList(),
        lastMessageAt: DateTime.parse(json['lastMessageAt'] ??
            json['last_message_at'] ??
            DateTime.now().toIso8601String()),
        synced: json['synced'] == true,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'userId': userId,
        'messages': messages.map((m) => m.toJson()).toList(),
        'lastMessageAt': lastMessageAt.toIso8601String(),
        'synced': synced,
      };

  ChatConversation copyWith({
    String? id,
    String? userId,
    List<ChatMessage>? messages,
    DateTime? lastMessageAt,
    bool? synced,
  }) =>
      ChatConversation(
        id: id ?? this.id,
        userId: userId ?? this.userId,
        messages: messages ?? this.messages,
        lastMessageAt: lastMessageAt ?? this.lastMessageAt,
        synced: synced ?? this.synced,
      );

  ChatMessage? get lastMessage => messages.isNotEmpty ? messages.last : null;
}
