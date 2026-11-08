import 'package:flutter/material.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/glass/glass_card.dart';
import 'package:raabta/core/glass/glass_container.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/screens/ai_chat/l10n/ai_chat_strings.dart';
import 'package:raabta/screens/ai_chat/models/ai_chat_thread.dart';

class AiThreadDrawer extends StatelessWidget {
  const AiThreadDrawer({
    super.key,
    required this.threads,
    required this.activeThreadId,
    required this.locale,
    required this.onSelect,
    required this.onNewChat,
    required this.onRename,
    required this.onDelete,
  });

  final List<AiChatThreadSummary> threads;
  final String activeThreadId;
  final String locale;
  final ValueChanged<String> onSelect;
  final VoidCallback onNewChat;
  final void Function(String threadId, String currentTitle) onRename;
  final ValueChanged<String> onDelete;

  String _formatUpdated(DateTime? updatedAt) {
    if (updatedAt == null) return '';
    final now = DateTime.now();
    final diff = now.difference(updatedAt);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m';
    if (diff.inHours < 24) return '${diff.inHours}h';
    return '${diff.inDays}d';
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.md,
          AppSpacing.sm,
          AppSpacing.md,
          AppSpacing.lg,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    AiChatStrings.t('ai_threads_title', locale),
                    style: AppTypography.headline2,
                  ),
                ),
                TextButton.icon(
                  onPressed: () {
                    Navigator.of(context).pop();
                    onNewChat();
                  },
                  icon: const Icon(Icons.add_rounded, size: 18),
                  label: Text(AiChatStrings.t('ai_new_chat', locale)),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            if (threads.isEmpty)
              GlassContainer(
                padding: const EdgeInsets.all(AppSpacing.md),
                borderRadius: AppSpacing.radiusSm,
                child: Text(
                  AiChatStrings.t('ai_recent_sessions', locale),
                  style: AppTypography.bodySmall,
                ),
              )
            else
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: threads.length,
                  separatorBuilder: (_, _) =>
                      const SizedBox(height: AppSpacing.sm),
                  itemBuilder: (context, index) {
                    final thread = threads[index];
                    final isActive = thread.id == activeThreadId;
                    return GestureDetector(
                      onLongPress: () => _showThreadActions(context, thread),
                      child: GlassCard(
                        onTap: () {
                          Navigator.of(context).pop();
                          onSelect(thread.id);
                        },
                        padding: const EdgeInsets.all(AppSpacing.md),
                        borderRadius: AppSpacing.radiusSm,
                        glowColor: isActive ? AppColors.cyanGlow : null,
                        glowIntensity: isActive ? 0.15 : 0,
                        child: Row(
                        children: [
                          Icon(
                            Icons.chat_bubble_outline_rounded,
                            size: 18,
                            color: isActive
                                ? AppColors.cyanGlow
                                : AppColors.textSecondary,
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  thread.title,
                                  style: AppTypography.subtitle.copyWith(
                                    fontSize: 14,
                                    color: isActive
                                        ? AppColors.cyanGlow
                                        : AppColors.textPrimary,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                if (thread.messageCount > 0)
                                  Text(
                                    '${thread.messageCount} messages',
                                    style: AppTypography.caption.copyWith(
                                      color: AppColors.textOnGlassMuted,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          if (thread.updatedAt != null)
                            Text(
                              _formatUpdated(thread.updatedAt),
                              style: AppTypography.caption.copyWith(
                                color: AppColors.textTertiary,
                              ),
                            ),
                        ],
                      ),
                    ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showThreadActions(BuildContext context, AiChatThreadSummary thread) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.surfaceElevated,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSpacing.radiusMd),
        ),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.drive_file_rename_outline_rounded),
                title: Text(AiChatStrings.t('ai_rename_thread', locale)),
                onTap: () {
                  Navigator.pop(ctx);
                  onRename(thread.id, thread.title);
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.delete_outline_rounded,
                  color: AppColors.roseGlow,
                ),
                title: Text(
                  AiChatStrings.t('ai_delete_thread', locale),
                  style: const TextStyle(color: AppColors.roseGlow),
                ),
                onTap: () {
                  Navigator.pop(ctx);
                  onDelete(thread.id);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
