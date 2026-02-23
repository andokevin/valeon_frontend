// lib/services/chat_service.dart
import '../models/chat_model.dart';
import '../core/database/database_service.dart';
import '../core/network/connectivity_service.dart';
import '../core/network/api_client.dart';
import 'package:flutter/foundation.dart';

class ChatService {
  final DatabaseService _db = DatabaseService();
  final ConnectivityService _connectivity = ConnectivityService();
  final ApiClient _api = ApiClient();

  ChatService() {
    _api.init();
  }

  Future<ChatConversation> getOrCreateChat(int userId) async {
    final existing = await _db.getLastChat(userId);
    if (existing != null) return existing;

    return ChatConversation(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: userId.toString(),
      messages: [
        ChatMessage.assistant(
          'Bonjour ! Je suis votre assistant Valeon. Posez-moi des questions sur des films, musiques ou séries !',
        ),
      ],
      lastMessageAt: DateTime.now(),
    );
  }

  Future<ChatMessage> sendMessage(int userId, String content) async {
    final userMessage = ChatMessage.user(content);
    final chat = await getOrCreateChat(userId);

    final chatWithUserMsg = chat.copyWith(
      messages: [...chat.messages, userMessage],
      lastMessageAt: DateTime.now(),
    );
    await _db.saveChat(chatWithUserMsg);

    String response;
    if (_connectivity.isOnline) {
      response = await _getAIResponse(content, userId);
    } else {
      response = _getOfflineResponse(content);
    }

    final assistantMessage = ChatMessage.assistant(response);
    final updatedChat = chatWithUserMsg.copyWith(
      messages: [...chatWithUserMsg.messages, assistantMessage],
      lastMessageAt: DateTime.now(),
    );
    await _db.saveChat(updatedChat);

    return assistantMessage;
  }

  Future<String> _getAIResponse(String query, int userId) async {
    try {
      final response = await _api.post(
        '/recommendations/chat',
        data: {
          'query': query,
          'context': {'userId': userId}
        },
      );
      final data = response.data;
      if (data != null && data['recommendations'] != null) {
        final recs = data['recommendations'] as List<dynamic>? ?? [];
        if (recs.isNotEmpty) {
          var result = 'Voici mes recommandations :\n\n';
          for (final rec in recs.take(5)) {
            result += '🎯 ${rec['title']}';
            if (rec['artist'] != null) {
              result += ' par ${rec['artist']}';
            }
            result += '\n${rec['reason'] ?? ''}\n\n';
          }
          return result.trim();
        }
      }
      return "Je n'ai pas trouvé de recommandations pour votre demande.";
    } catch (e) {
      debugPrint('❌ API chat error: $e');
      return _getOfflineResponse(query);
    }
  }

  String _getOfflineResponse(String query) {
    final lowerQuery = query.toLowerCase();
    if (lowerQuery.contains('film') || lowerQuery.contains('movie')) {
      return "🔴 Mode hors ligne\n\nFilms populaires :\n"
          "• Inception (Sci-fi)\n"
          "• Interstellar (Sci-fi)\n"
          "• The Dark Knight (Action)\n\n"
          "Connectez-vous pour des recommandations personnalisées !";
    } else if (lowerQuery.contains('musique') || lowerQuery.contains('music')) {
      return "🔴 Mode hors ligne\n\nHits populaires :\n"
          "• Blinding Lights - The Weeknd\n"
          "• Heat Waves - Glass Animals\n"
          "• Sunflower - Post Malone\n\n"
          "Connectez-vous pour vos recommandations !";
    }
    return "🔴 Hors ligne — Connectez-vous à Internet pour des recommandations personnalisées.";
  }

  Future<void> clearHistory(int userId) async {
    final chat = await getOrCreateChat(userId);
    final welcomeMsg = ChatMessage.assistant(
      'Historique effacé. Comment puis-je vous aider ?',
    );

    final clearedChat = chat.copyWith(
      messages: [welcomeMsg],
      lastMessageAt: DateTime.now(),
    );
    await _db.saveChat(clearedChat);
  }

  Future<List<ChatMessage>> getRemoteMessages(int userId) async {
    try {
      if (!_connectivity.isOnline) return [];
      final response = await _api.get('/chat/history/$userId');
      final data = response.data;
      if (data is List) {
        return data.map((item) => ChatMessage.fromJson(item)).toList();
      }
      return [];
    } catch (e) {
      debugPrint('❌ Erreur messages distants: $e');
      return [];
    }
  }

  Future<bool> deleteRemoteMessage(int userId, String messageId) async {
    try {
      if (!_connectivity.isOnline) return false;
      await _api.delete('/chat/message/$messageId');
      return true;
    } catch (e) {
      debugPrint('❌ Erreur suppression distante: $e');
      return false;
    }
  }

  Future<ChatMessage?> syncMessage(int userId, ChatMessage message) async {
    try {
      if (!_connectivity.isOnline) return null;
      final response = await _api.post(
        '/chat/messages',
        data: {'userId': userId, 'message': message.toJson()},
      );
      if (response.statusCode == 200) {
        final syncedMsg = message.copyWith(synced: true);
        await _db.markMessagesAsSynced(userId);
        return syncedMsg;
      }
      return null;
    } catch (e) {
      debugPrint('❌ Erreur sync message: $e');
      return null;
    }
  }
}
