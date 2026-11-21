import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/l10n/classifieds_chat_safety_strings.dart';
import 'package:raabta/providers/classifieds_chat_safety_providers.dart';
import 'package:raabta/services/classifieds/classifieds_chat_report_service.dart';

typedef ClassifiedsChatReportContext = ({
  String targetId,
  String targetType,
  String? peerUid,
  List<ClassifiedsChatReportMessageSnapshot> messages,
});

class ClassifiedsChatSafetyMenu extends ConsumerWidget {
  const ClassifiedsChatSafetyMenu({
    super.key,
    required this.locale,
    required this.peerUid,
    required this.reportContext,
  });

  final String locale;
  final String? peerUid;
  final ClassifiedsChatReportContext reportContext;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (peerUid == null || peerUid!.isEmpty) {
      return const SizedBox.shrink();
    }

    return PopupMenuButton<String>(
      icon: Icon(Icons.more_vert, color: AppColors.textSecondary),
      onSelected: (value) async {
        switch (value) {
          case 'report':
            await _reportConversation(context, ref);
          case 'block':
            await _confirmBlock(context, ref);
        }
      },
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 'report',
          child: Text(ClassifiedsChatSafetyStrings.t('menu_report', locale)),
        ),
        PopupMenuItem(
          value: 'block',
          child: Text(
            ClassifiedsChatSafetyStrings.t('menu_block_user', locale),
          ),
        ),
      ],
    );
  }

  Future<void> _reportConversation(BuildContext context, WidgetRef ref) async {
    final messages = reportContext.messages;
    if (messages.isEmpty) return;

    final reportedId = await showDialog<String>(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: Text(
          ClassifiedsChatSafetyStrings.t('report_pick_message', locale),
        ),
        children: [
          for (final m in messages.reversed.take(12))
            SimpleDialogOption(
              onPressed: () => Navigator.pop(ctx, m.messageId),
              child: Text(
                m.text.length > 80 ? '${m.text.substring(0, 80)}…' : m.text,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
        ],
      ),
    );

    if (reportedId == null || !context.mounted) return;

    await ClassifiedsChatReportService.submitChatReport(
      reportService: ref.read(reportServiceProvider),
      locale: locale,
      targetId: reportContext.targetId,
      targetType: reportContext.targetType,
      title: 'Classifieds chat report',
      description: 'User-reported classifieds chat message',
      reportedMessageId: reportedId,
      allMessages: messages,
      peerUid: reportContext.peerUid,
    );

    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          ClassifiedsChatSafetyStrings.t('report_success', locale),
        ),
      ),
    );
  }

  Future<void> _confirmBlock(BuildContext context, WidgetRef ref) async {
    final peer = peerUid;
    if (peer == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          ClassifiedsChatSafetyStrings.t('block_confirm_title', locale),
        ),
        content: Text(
          ClassifiedsChatSafetyStrings.t('block_confirm_body', locale),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              ClassifiedsChatSafetyStrings.t('menu_block_user', locale),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    await ref.read(blockUserRepositoryProvider).blockUser(peer);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          ClassifiedsChatSafetyStrings.t('block_success', locale),
        ),
      ),
    );
  }
}
