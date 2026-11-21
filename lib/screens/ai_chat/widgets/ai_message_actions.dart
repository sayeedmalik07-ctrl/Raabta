import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/screens/ai_chat/l10n/ai_chat_strings.dart';

void showAiMessageActionSheet(
  BuildContext context, {
  required String locale,
  required String text,
  VoidCallback? onCopy,
  VoidCallback? onEdit,
  VoidCallback? onRegenerate,
  VoidCallback? onSpeak,
  VoidCallback? onReply,
}) {
  HapticFeedback.mediumImpact();
  showModalBottomSheet<void>(
    context: context,
    backgroundColor: AppColors.surfaceElevated,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(AppSpacing.radiusLg),
      ),
    ),
    builder: (ctx) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (onReply != null)
            ListTile(
              leading: const Icon(Icons.reply_rounded),
              title: Text(AiChatStrings.t('ai_reply', locale)),
              onTap: () {
                Navigator.pop(ctx);
                onReply();
              },
            ),
          if (onCopy != null)
            ListTile(
              leading: const Icon(Icons.copy_rounded),
              title: Text(AiChatStrings.t('ai_copy', locale)),
              onTap: () {
                Navigator.pop(ctx);
                onCopy();
              },
            ),
          if (onEdit != null)
            ListTile(
              leading: const Icon(Icons.edit_outlined),
              title: Text(AiChatStrings.t('ai_edit_message', locale)),
              onTap: () {
                Navigator.pop(ctx);
                onEdit();
              },
            ),
          if (onRegenerate != null)
            ListTile(
              leading: const Icon(Icons.refresh_rounded),
              title: Text(AiChatStrings.t('ai_regenerate', locale)),
              onTap: () {
                Navigator.pop(ctx);
                onRegenerate();
              },
            ),
          if (onSpeak != null)
            ListTile(
              leading: const Icon(Icons.volume_up_rounded),
              title: Text(AiChatStrings.t('ai_speak', locale)),
              onTap: () {
                Navigator.pop(ctx);
                onSpeak();
              },
            ),
        ],
      ),
    ),
  );
}

/// Swipe to quote an assistant reply into the composer.
class AiSwipeToReply extends StatelessWidget {
  const AiSwipeToReply({
    super.key,
    required this.enabled,
    required this.isRtl,
    required this.locale,
    required this.messageId,
    required this.onReply,
    required this.child,
  });

  final bool enabled;
  final bool isRtl;
  final String locale;
  final String messageId;
  final VoidCallback onReply;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (!enabled) return child;

    return Dismissible(
      key: Key('reply-$messageId'),
      direction: isRtl
          ? DismissDirection.endToStart
          : DismissDirection.startToEnd,
      confirmDismiss: (_) async {
        HapticFeedback.selectionClick();
        onReply();
        return false;
      },
      background: Align(
        alignment: isRtl ? Alignment.centerLeft : Alignment.centerRight,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.reply_rounded, color: AppColors.cyanGlow),
              const SizedBox(width: AppSpacing.xs),
              Text(
                AiChatStrings.t('ai_reply', locale),
                style: TextStyle(color: AppColors.cyanGlow, fontSize: 13),
              ),
            ],
          ),
        ),
      ),
      child: child,
    );
  }
}
