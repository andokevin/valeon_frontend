import 'dart:convert';

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

  // ─── Factory constructors ────────────────────────────────────────────────

  ChatMessage.user(String content)
      : this(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          role: MessageRole.user,
          content: content,
          timestamp: DateTime.now(),
        );

  ChatMessage.assistant(String content)
      : this(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          role: MessageRole.assistant,
          content: content,
          timestamp: DateTime.now(),
        );

  ChatMessage.system(String content)
      : this(
          id: 'system-${DateTime.now().millisecondsSinceEpoch}',
          role: MessageRole.system,
          content: content,
          timestamp: DateTime.now(),
        );

  // ─── JSON ───────────────────────────────────────────────────────────────

  factory ChatMessage.fromJson(Map<String, dynamic> json) => ChatMessage(
    id: json['id'] ?? '',
    role: _roleFromString(json['role'] ?? 'assistant'),
    content: json['content'] ?? '',
    timestamp: DateTime.parse(json['timestamp'] ?? DateTime.now().toIso8601String()),
    synced: json['synced'] == true,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'role': _roleToString(role),
    'content': content,
    'timestamp': timestamp.toIso8601String(),
    'synced': synced,
  };

  // ─── Database Map ───────────────────────────────────────────────────────

  factory ChatMessage.fromMap(Map<String, dynamic> map) => ChatMessage.fromJson(map);
  Map<String, dynamic> toMap() => toJson();

  // ─── Helpers privés ─────────────────────────────────────────────────────

  static MessageRole _roleFromString(String role) {
    switch (role.toLowerCase()) {
      case 'user': return MessageRole.user;
      case 'system': return MessageRole.system;
      default: return MessageRole.assistant;
    }
  }

  static String _roleToString(MessageRole role) {
    switch (role) {
      case MessageRole.user: return 'user';
      case MessageRole.system: return 'system';
      case MessageRole.assistant: return 'assistant';
    }
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChatMessage &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}

class ChatConversation {
  final String id;
  final String userId;
  final List<ChatMessage> messages;
  final DateTime lastMessageAt;  // ✅ final normal
  final bool synced;

  const ChatConversation({
    required this.id,
    required this.userId,
    required this.messages,
    required this.lastMessageAt,
    this.synced = false,
  });

  // ✅ copyWith pour modifier l'état
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

  // ─── JSON ───────────────────────────────────────────────────────────────

  factory ChatConversation.fromJson(Map<String, dynamic> json) => ChatConversation(
    id: json['id'] ?? '',
    userId: json['userId'] ?? '',
    messages: (json['messages'] as List<dynamic>? ?? [])
        .map((m) => ChatMessage.fromJson(m as Map<String, dynamic>))
        .toList(),
    lastMessageAt: DateTime.parse(json['lastMessageAt'] ?? DateTime.now().toIso8601String()),
    synced: json['synced'] == true,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'userId': userId,
    'messages': messages.map((m) => m.toJson()).toList(),
    'lastMessageAt': lastMessageAt.toIso8601String(),
    'synced': synced,
  };

  // ─── Database Map ───────────────────────────────────────────────────────

  factory ChatConversation.fromMap(Map<String, dynamic> map) => ChatConversation.fromJson(map);
  Map<String, dynamic> toMap() => toJson();

  // ─── Égalité ────────────────────────────────────────────────────────────

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChatConversation &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
