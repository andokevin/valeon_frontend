// lib/providers/chat_provider.dart (MODIFIÉ)
import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../models/chat_model.dart';
import '../services/chat_service.dart';
import 'connectivity_provider.dart';

class ChatProvider extends ChangeNotifier {
  final ChatService _service = ChatService();
  late ConnectivityProvider _connectivity;

  List<ChatMessage> _messages = [];
  bool _isLoading = false;
  bool _isTyping = false;
  String? _errorMessage;
  String? _currentConversationId;

  List<ChatMessage> get messages => _messages;
  bool get isLoading => _isLoading;
  bool get isTyping => _isTyping;
  String? get errorMessage => _errorMessage;
  bool get hasMessages => _messages.isNotEmpty;

  void setConnectivity(ConnectivityProvider connectivity) {
    _connectivity = connectivity;
  }

  Future<void> loadChat(UserModel user) async {
    _isLoading = true;
    notifyListeners();

    try {
      final conversation = await _service.getOrCreateChat(user.userId);
      _messages = conversation.messages;
      _currentConversationId = conversation.id;
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
      debugPrint('❌ Erreur chargement conversation: $e');

      // Message de fallback
      _messages = [
        ChatMessage.assistant(
          'Bonjour ! Je suis votre assistant Valeon. Une erreur est survenue, veuillez réessayer.',
        ),
      ];
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> sendMessage(String content, UserModel user) async {
    if (content.trim().isEmpty) return;

    final userMessage = ChatMessage.user(content);
    _messages.add(userMessage);
    _isTyping = true;
    notifyListeners();

    try {
      final assistantMessage = await _service.sendMessage(user.userId, content);
      _messages.add(assistantMessage);
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Erreur: ${e.toString()}';
      _messages.add(
        ChatMessage.assistant(
          'Désolé, une erreur est survenue. Veuillez réessayer.',
        ),
      );
    }

    _isTyping = false;
    notifyListeners();
  }

  Future<void> clearHistory(UserModel user) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _service.clearHistory(user.userId);
      _messages = [
        ChatMessage.assistant(
          'Historique effacé. Comment puis-je vous aider ?',
        ),
      ];
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  void retryLastMessage(UserModel user) {
    if (_messages.isEmpty) return;

    final lastUserMessage = _messages.lastWhere(
      (m) => m.role == MessageRole.user,
      orElse: () => ChatMessage.user(''),
    );

    if (lastUserMessage.content.isNotEmpty) {
      // Supprimer les messages après le dernier message utilisateur
      final lastUserIndex = _messages.indexOf(lastUserMessage);
      _messages.removeRange(lastUserIndex + 1, _messages.length);

      // Renvoyer le message
      sendMessage(lastUserMessage.content, user);
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void addLocalMessage(String content, {bool isUser = true}) {
    if (isUser) {
      _messages.add(ChatMessage.user(content));
    } else {
      _messages.add(ChatMessage.assistant(content));
    }
    notifyListeners();
  }
}
