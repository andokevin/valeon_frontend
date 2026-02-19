// lib/screens/chat_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/chat_provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/space_background.dart';
import '../config/constants.dart';
import '../models/chat_model.dart'; // ✅ IMPORT AJOUTÉ pour ChatMessage

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final chatProvider = Provider.of<ChatProvider>(context, listen: false);

      if (authProvider.user != null) {
        // ✅ Correction: loadChat au lieu de loadConversation
        chatProvider.loadChat(authProvider.user!);
      }
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final message = _messageController.text.trim();
    if (message.isEmpty) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final chatProvider = Provider.of<ChatProvider>(context, listen: false);

    chatProvider.sendMessage(message, authProvider.user!);
    _messageController.clear();

    // Scroll to bottom
    Future.delayed(const Duration(milliseconds: 100), () {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = ResponsiveHelper.isTablet(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final chatProvider = Provider.of<ChatProvider>(context);

    return Scaffold(
      body: SpaceBackground(
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: ResponsiveHelper.maxContentWidth(context),
              ),
              child: Column(
                children: [
                  _buildHeader(context, authProvider.isOfflineMode),

                  Expanded(
                    child:
                        chatProvider.isLoading && chatProvider.messages.isEmpty
                        ? const Center(child: CircularProgressIndicator())
                        : _buildMessagesList(chatProvider, isTablet),
                  ),

                  _buildInputArea(isTablet),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isOffline) {
    final isTablet = ResponsiveHelper.isTablet(context);
    return Padding(
      padding: EdgeInsets.all(ResponsiveHelper.paddingScreen(context)),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(
              Icons.arrow_back_ios,
              color: AppColors.textPrimary,
              size: isTablet ? 28.0 : 22.0,
            ),
          ),
          Expanded(
            child: Text(
              'Assistant Valeon',
              style: AppTextStyles.titleMedium.copyWith(
                fontSize: isTablet ? 26.0 : 22.0,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          if (isOffline)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.orange.withOpacity(0.5)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.wifi_off,
                    color: Colors.orange,
                    size: isTablet ? 20.0 : 16.0,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Hors ligne',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: Colors.orange,
                      fontSize: isTablet ? 14.0 : 12.0,
                    ),
                  ),
                ],
              ),
            )
          else
            const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _buildMessagesList(ChatProvider chatProvider, bool isTablet) {
    return ListView.builder(
      controller: _scrollController,
      padding: EdgeInsets.symmetric(
        horizontal: ResponsiveHelper.paddingScreen(context),
      ),
      itemCount: chatProvider.messages.length,
      itemBuilder: (context, index) {
        final message = chatProvider.messages[index];
        return _buildMessageBubble(message, isTablet);
      },
    );
  }

  Widget _buildMessageBubble(ChatMessage message, bool isTablet) {
    final isUser = message.role == 'user';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: isUser
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) ...[
            Container(
              width: isTablet ? 40.0 : 32.0,
              height: isTablet ? 40.0 : 32.0,
              decoration: BoxDecoration(
                color: AppColors.primaryBlue,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.assistant,
                color: Colors.white,
                size: isTablet ? 24.0 : 18.0,
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: EdgeInsets.all(isTablet ? 16.0 : 12.0),
              decoration: BoxDecoration(
                color: isUser
                    ? AppColors.primaryBlue
                    : Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(20).copyWith(
                  bottomLeft: isUser ? null : const Radius.circular(4),
                  bottomRight: isUser ? const Radius.circular(4) : null,
                ),
                border: isUser
                    ? null
                    : Border.all(color: Colors.white.withOpacity(0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message.content,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: isUser ? Colors.white : AppColors.textPrimary,
                      fontSize: isTablet ? 16.0 : 14.0,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatTime(message.timestamp),
                    style: AppTextStyles.bodySmall.copyWith(
                      color: isUser
                          ? Colors.white.withOpacity(0.7)
                          : AppColors.textSecondary,
                      fontSize: isTablet ? 12.0 : 10.0,
                    ),
                    textAlign: TextAlign.right,
                  ),
                ],
              ),
            ),
          ),
          if (isUser) ...[
            const SizedBox(width: 8),
            Container(
              width: isTablet ? 40.0 : 32.0,
              height: isTablet ? 40.0 : 32.0,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.person,
                color: Colors.white,
                size: isTablet ? 24.0 : 18.0,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInputArea(bool isTablet) {
    return Container(
      padding: EdgeInsets.all(ResponsiveHelper.paddingScreen(context)),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        border: Border(top: BorderSide(color: Colors.white.withOpacity(0.2))),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: Colors.white.withOpacity(0.2)),
              ),
              child: TextField(
                controller: _messageController,
                style: AppTextStyles.bodyMedium.copyWith(
                  fontSize: isTablet ? 16.0 : 14.0,
                ),
                decoration: InputDecoration(
                  hintText: 'Posez votre question...',
                  hintStyle: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: isTablet ? 16.0 : 14.0,
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    vertical: isTablet ? 18.0 : 14.0,
                  ),
                ),
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: _sendMessage,
            child: Container(
              width: isTablet ? 60.0 : 50.0,
              height: isTablet ? 60.0 : 50.0,
              decoration: BoxDecoration(
                color: AppColors.primaryBlue,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.send,
                color: Colors.white,
                size: isTablet ? 28.0 : 22.0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inMinutes < 1) {
      return 'À l\'instant';
    } else if (difference.inMinutes < 60) {
      return 'Il y a ${difference.inMinutes} min';
    } else {
      return '${time.hour}:${time.minute.toString().padLeft(2, '0')}';
    }
  }
}
