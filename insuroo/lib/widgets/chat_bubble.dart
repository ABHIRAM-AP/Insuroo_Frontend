import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../models/chat_message.dart';
import '../theme/app_theme.dart';

class ChatBubble extends StatelessWidget {
  final ChatMessage message;

  const ChatBubble({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    final isUser = message.isUser;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isUser) _buildAvatar(),
          const SizedBox(width: 8),
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isUser ? AppTheme.userBubble : AppTheme.aiBubble,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(20),
                  topRight: const Radius.circular(20),
                  bottomLeft: Radius.circular(isUser ? 20 : 4),
                  bottomRight: Radius.circular(isUser ? 4 : 20),
                ),
                boxShadow: [
                  BoxShadow(
                    color: isUser
                        ? AppTheme.primaryColor.withOpacity(0.3)
                        : Colors.black.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
                border: !isUser
                    ? Border.all(
                        color: AppTheme.dividerColor.withOpacity(0.5),
                        width: 1,
                      )
                    : null,
              ),
              child: isUser
                  ? Text(
                      message.text,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        height: 1.5,
                      ),
                    )
                  : MarkdownBody(
                      data: message.text,
                      styleSheet: MarkdownStyleSheet(
                        p: const TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: 15,
                          height: 1.5,
                        ),
                        code: TextStyle(
                          color: AppTheme.accentColor,
                          backgroundColor:
                              Colors.black.withOpacity(0.3),
                          fontSize: 13,
                        ),
                        h1: const TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        h2: const TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        h3: const TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                        listBullet: const TextStyle(
                          color: AppTheme.accentColor,
                        ),
                        strong: const TextStyle(
                          color: AppTheme.textPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                        blockquoteDecoration: BoxDecoration(
                          color: AppTheme.primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                          border: const Border(
                            left: BorderSide(
                              color: AppTheme.primaryColor,
                              width: 3,
                            ),
                          ),
                        ),
                      ),
                    ),
            ),
          ),
          const SizedBox(width: 8),
          if (isUser) _buildUserAvatar(),
        ],
      ),
    );
  }

  Widget _buildAvatar() {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppTheme.primaryColor, AppTheme.accentColor],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryColor.withOpacity(0.4),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: const Center(
        child: Text('🛡️', style: TextStyle(fontSize: 18)),
      ),
    );
  }

  Widget _buildUserAvatar() {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: AppTheme.cardDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.dividerColor),
      ),
      child: const Center(
        child: Text('👤', style: TextStyle(fontSize: 18)),
      ),
    );
  }
}
