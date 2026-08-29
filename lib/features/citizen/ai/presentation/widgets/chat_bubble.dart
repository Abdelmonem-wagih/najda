import 'package:flutter/material.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/theme/app_radius.dart';
import '../../domain/entities/chat_message.dart';

class ChatBubble extends StatelessWidget {
  final ChatMessage msg;
  final Color accentColor;

  const ChatBubble({
    super.key,
    required this.msg,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: msg.isUser ? Alignment.centerLeft : Alignment.centerRight,
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.md),
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: msg.isUser ? AppColors.white : accentColor,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(AppRadius.lg),
            topRight: const Radius.circular(AppRadius.lg),
            bottomLeft: Radius.circular(msg.isUser ? 0 : AppRadius.lg),
            bottomRight: Radius.circular(msg.isUser ? AppRadius.lg : 0),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 5,
              offset: const Offset(0, 2),
            )
          ],
        ),
        child: Text(
          msg.text,
          style: AppTextStyles.bodyMedium.copyWith(
            color: msg.isUser ? AppColors.textPrimary : AppColors.white,
          ),
        ),
      ),
    );
  }
}
