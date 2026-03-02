// lib/services/chat_service.dart (MODIFIÉ)
import '../models/chat_model.dart';
import '../core/network/connectivity_service.dart';
import '../core/network/api_client.dart';
import 'package:flutter/foundation.dart';
import '../config/app_config.dart';

class ChatService {
  final ConnectivityService _connectivity = ConnectivityService();
  final ApiClient _api = ApiClient();
  final String baseUrl = AppConfig.apiBaseUrl;

  ChatService() {
    _api.init();
  }

  Future<ChatConversation> getOrCreateChat(int userId) async {
    try {
      if (!_connectivity.isOnline) {
        // Mode offline - conversation locale uniquement
        return ChatConversation(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          userId: userId.toString(),
          messages: [
            ChatMessage.assistant(
              'Bonjour ! Je suis votre assistant Valeon. Connectez-vous à Internet pour utiliser le chat.',
            ),
          ],
          lastMessageAt: DateTime.now(),
        );
      }

      // Récupérer l'historique depuis l'API
      final response = await _api.get('/chat/history/$userId');
      final data = response.data;

      if (data != null && data is Map && data['messages'] != null) {
        final messages = (data['messages'] as List)
            .map((m) => ChatMessage.fromJson(m))
            .toList();

        return ChatConversation(
          id: data['conversation_id'] ??
              DateTime.now().millisecondsSinceEpoch.toString(),
          userId: userId.toString(),
          messages: messages,
          lastMessageAt: DateTime.now(),
        );
      }

      // Créer une nouvelle conversation
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
    } catch (e) {
      debugPrint('❌ Erreur getOrCreateChat: $e');
      return ChatConversation(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: userId.toString(),
        messages: [
          ChatMessage.assistant(
            'Bonjour ! Je suis votre assistant Valeon. Une erreur est survenue, veuillez réessayer.',
          ),
        ],
        lastMessageAt: DateTime.now(),
      );
    }
  }

  Future<ChatMessage> sendMessage(int userId, String content) async {
    if (!_connectivity.isOnline) {
      return ChatMessage.assistant(
        'Mode hors ligne - Connectez-vous à Internet pour utiliser le chat.',
      );
    }

    try {
      debugPrint('📤 Envoi message à $baseUrl/chat/message');

      final response = await _api.post(
        '/chat/message',
        data: {
          'message': content,
          'conversation_id': userId.toString(),
        },
      );

      debugPrint('📥 Réponse reçue: ${response.statusCode}');

      final data = response.data;
      if (data != null && data['response'] != null) {
        return ChatMessage.assistant(data['response']);
      }

      return ChatMessage.assistant(
        "Je n'ai pas pu traiter votre demande. Veuillez réessayer.",
      );
    } catch (e) {
      debugPrint('❌ API chat error: $e');

      // Fallback : réponse locale
      return ChatMessage.assistant(
        _getLocalResponse(content),
      );
    }
  }

  String _getLocalResponse(String query) {
    // Réponses locales en cas d'échec API
    final lowerQuery = query.toLowerCase();

    if (lowerQuery.contains('bonjour') || lowerQuery.contains('salut')) {
      return 'Bonjour ! Comment puis-je vous aider aujourd\'hui ?';
    }
    if (lowerQuery.contains('film') || lowerQuery.contains('movie')) {
      return 'Je peux vous aider à trouver des films ! Que cherchez-vous ?';
    }
    if (lowerQuery.contains('musique') || lowerQuery.contains('chanson')) {
      return 'Je connais beaucoup de musique ! Quel artiste ou titre vous intéresse ?';
    }
    if (lowerQuery.contains('merci')) {
      return 'Avec plaisir ! N\'hésitez pas si vous avez d\'autres questions.';
    }

    return "Je suis votre assistant Valeon. Posez-moi des questions sur les films, la musique ou les séries !";
  }

  Future<void> clearHistory(int userId) async {
    try {
      if (!_connectivity.isOnline) return;
      await _api.post('/chat/clear/$userId');
    } catch (e) {
      debugPrint('❌ Erreur clear history: $e');
    }
  }
}
