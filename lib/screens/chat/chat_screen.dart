// lib/screens/chat/chat_screen.dart (MODIFIÉ - suppression bordure)
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:valeon/models/chat_model.dart';
import '../../config/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/chat_provider.dart';
import '../../providers/connectivity_provider.dart';
import '../../widgets/common/theme_switch.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadChat();
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _loadChat() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final chat = Provider.of<ChatProvider>(context, listen: false);
    final connectivity =
        Provider.of<ConnectivityProvider>(context, listen: false);

    chat.setConnectivity(connectivity);

    if (auth.user != null) {
      await chat.loadChat(auth.user!);
      setState(() {
        _isInitialized = true;
      });
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _sendMessage() {
    final message = _messageController.text.trim();
    if (message.isEmpty) return;

    final auth = Provider.of<AuthProvider>(context, listen: false);
    final chat = Provider.of<ChatProvider>(context, listen: false);

    chat.sendMessage(message, auth.user!);
    _messageController.clear();
    _focusNode.requestFocus();
    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = ResponsiveHelper.isTablet(context);
    final hPadding = ResponsiveHelper.paddingScreen(context);
    final auth = Provider.of<AuthProvider>(context);
    final chat = Provider.of<ChatProvider>(context);
    final connectivity = Provider.of<ConnectivityProvider>(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.darkPurple,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(
                context, hPadding, isTablet, connectivity.isOnline, isDark),
            Expanded(
              child:
                  !_isInitialized || (chat.isLoading && chat.messages.isEmpty)
                      ? const Center(
                          child: CircularProgressIndicator(
                              color: AppColors.primaryBlue))
                      : _buildMessagesList(chat, isTablet, isDark),
            ),
            _buildInputArea(
                isTablet, chat.isTyping, isDark, connectivity.isOnline),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, double hPadding, bool isTablet,
      bool isOnline, bool isDark) {
    return Padding(
      padding: EdgeInsets.all(hPadding),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(Icons.arrow_back,
                color: isDark ? AppColors.darkTextPrimary : Colors.white),
          ),
          Container(
            width: isTablet ? 48 : 40,
            height: isTablet ? 48 : 40,
            decoration: BoxDecoration(
              color: AppColors.primaryBlue,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.assistant, color: Colors.white),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Assistant Valeon',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppColors.darkTextPrimary : Colors.white,
                  ),
                ),
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: isOnline ? Colors.green : Colors.orange,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      isOnline ? 'En ligne' : 'Hors ligne',
                      style: TextStyle(
                        fontSize: 12,
                        color: isOnline ? Colors.green : Colors.orange,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const ThemeSwitch(showLabel: false),
          const SizedBox(width: 8),
          IconButton(
            onPressed: () async {
              final auth = Provider.of<AuthProvider>(context, listen: false);
              final chat = Provider.of<ChatProvider>(context, listen: false);

              final confirm = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  backgroundColor:
                      isDark ? AppColors.darkSurface : AppColors.surface,
                  title: const Text('Effacer l\'historique'),
                  content: const Text(
                      'Voulez-vous vraiment effacer toute la conversation ?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Annuler'),
                    ),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context, true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                      ),
                      child: const Text('Effacer'),
                    ),
                  ],
                ),
              );
              if (confirm == true && auth.user != null) {
                await chat.clearHistory(auth.user!);
              }
            },
            icon: Icon(Icons.delete_outline,
                color: isDark ? AppColors.darkTextSecondary : Colors.white54),
          ),
        ],
      ),
    );
  }

  Widget _buildMessagesList(ChatProvider chat, bool isTablet, bool isDark) {
    if (chat.messages.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.chat_bubble_outline,
              size: isTablet ? 80 : 60,
              color: isDark ? AppColors.darkTextSecondary : Colors.white54,
            ),
            const SizedBox(height: 16),
            Text(
              'Aucun message',
              style: TextStyle(
                fontSize: 18,
                color: isDark ? AppColors.darkTextPrimary : Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Commencez la conversation !',
              style: TextStyle(
                color: isDark ? AppColors.darkTextSecondary : Colors.white70,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      controller: _scrollController,
      padding: EdgeInsets.symmetric(
          horizontal: ResponsiveHelper.paddingScreen(context)),
      itemCount: chat.messages.length,
      itemBuilder: (context, index) {
        final message = chat.messages[index];
        return _buildMessageBubble(message, isTablet, isDark);
      },
    );
  }

  Widget _buildMessageBubble(ChatMessage message, bool isTablet, bool isDark) {
    final isUser = message.role == MessageRole.user;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) ...[
            Container(
              width: isTablet ? 40 : 32,
              height: isTablet ? 40 : 32,
              decoration: const BoxDecoration(
                color: AppColors.primaryBlue,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.assistant, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: EdgeInsets.all(isTablet ? 16 : 12),
              decoration: BoxDecoration(
                color: isUser
                    ? AppColors.primaryBlue
                    : (isDark
                        ? AppColors.darkSurface
                        : Colors.white.withOpacity(0.15)),
                borderRadius: BorderRadius.circular(20).copyWith(
                  bottomLeft: isUser ? null : const Radius.circular(4),
                  bottomRight: isUser ? const Radius.circular(4) : null,
                ),
                border: isUser
                    ? null
                    : Border.all(
                        color: isDark
                            ? AppColors.darkDivider
                            : Colors.white.withOpacity(0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message.content,
                    style: TextStyle(
                      color: isUser
                          ? Colors.white
                          : (isDark ? AppColors.darkTextPrimary : Colors.white),
                      fontSize: isTablet ? 16 : 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatTime(message.timestamp),
                    style: TextStyle(
                      color: isUser
                          ? Colors.white.withOpacity(0.7)
                          : (isDark
                              ? AppColors.darkTextSecondary
                              : Colors.white70),
                      fontSize: isTablet ? 12 : 10,
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
              width: isTablet ? 40 : 32,
              height: isTablet ? 40 : 32,
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.darkSurface
                    : Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.person,
                  color: isDark ? AppColors.darkTextPrimary : Colors.white),
            ),
          ],
        ],
      ),
    );
  }

  // ===== MODIFICATION: SUPPRESSION DE LA BORDURE =====
  Widget _buildInputArea(
      bool isTablet, bool isTyping, bool isDark, bool isOnline) {
    return Container(
      padding: EdgeInsets.all(ResponsiveHelper.paddingScreen(context)),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white.withOpacity(0.1),
        border: Border(
          top: BorderSide(
            color:
                isDark ? AppColors.darkDivider : Colors.white.withOpacity(0.2),
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.darkBackground
                    : Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(30),
                // ===== SUPPRESSION DE border =====
                // La ligne suivante a été supprimée pour enlever la bordure
                // border: Border.all(...),
              ),
              child: Material(
                color: Colors.transparent,
                child: TextField(
                  controller: _messageController,
                  focusNode: _focusNode,
                  enabled: isOnline,
                  style: TextStyle(
                    color: isDark ? AppColors.darkTextPrimary : Colors.white,
                  ),
                  decoration: InputDecoration(
                    hintText: isOnline
                        ? 'Posez votre question...'
                        : 'Hors ligne - Connectez-vous',
                    hintStyle: TextStyle(
                      color:
                          isDark ? AppColors.darkTextSecondary : Colors.white54,
                    ),
                    border: InputBorder.none, // Pas de bordure
                  ),
                  maxLines: null,
                  onSubmitted: (_) => _sendMessage(),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: isOnline ? _sendMessage : null,
            child: Opacity(
              opacity: isOnline ? 1.0 : 0.5,
              child: Container(
                width: isTablet ? 60 : 50,
                height: isTablet ? 60 : 50,
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue,
                  shape: BoxShape.circle,
                ),
                child: isTyping
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Icon(Icons.send, color: Colors.white),
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
      return DateFormat.Hm().format(time);
    }
  }
}
