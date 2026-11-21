import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/core/widgets/classifieds_chat_safety_menu.dart';
import 'package:raabta/core/widgets/classifieds_host_notice.dart';
import 'package:raabta/core/widgets/glass_screen_scaffold.dart';
import 'package:raabta/data/models/job_application_chat_message.dart';
import 'package:raabta/providers/classifieds_chat_safety_providers.dart';
import 'package:raabta/providers/jobs_providers.dart';
import 'package:raabta/features/link_safety/link_safety_models.dart';
import 'package:raabta/features/link_safety/presentation/user_generated_text_with_link_safety.dart';
import 'package:raabta/providers/visa_providers.dart';
import 'package:raabta/screens/jobs/l10n/jobs_application_strings.dart';
import 'package:raabta/services/classifieds/classifieds_chat_report_service.dart';
import 'package:raabta/services/classifieds/classifieds_chat_safety_logic.dart';

class JobApplicationChatScreen extends ConsumerWidget {
  const JobApplicationChatScreen({
    super.key,
    required this.jobId,
    required this.applicantUid,
    required this.jobTitle,
  });

  final String jobId;
  final String applicantUid;
  final String jobTitle;

  String? _peerUid(String myUid, String? posterUid) {
    if (posterUid == null || posterUid.isEmpty) return null;
    if (myUid == applicantUid) return posterUid;
    if (myUid == posterUid) return applicantUid;
    return null;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(userLanguageProvider);
    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
    final posterUid = ref.watch(jobListingForIdProvider(jobId))?.postedBy;
    final peerUid = _peerUid(uid, posterUid);
    final blockedIds = ref.watch(blockedUserIdsProvider).valueOrNull ?? {};
    final messagesAsync = ref.watch(
      jobApplicationChatMessagesProvider(
        (jobId: jobId, applicantUid: applicantUid),
      ),
    );

    return GlassScreenScaffold(
      title: JobsApplicationStrings.t('jobs_app_chat_title', locale),
      actions: [
        messagesAsync.maybeWhen(
          data: (messages) {
            if (peerUid == null) return const SizedBox.shrink();
            return ClassifiedsChatSafetyMenu(
              locale: locale,
              peerUid: peerUid,
              reportContext: (
                targetId: '$jobId:$applicantUid',
                targetType: 'job_application_chat',
                peerUid: peerUid,
                messages: [
                  for (final m in messages)
                    ClassifiedsChatReportMessageSnapshot(
                      messageId: m.id,
                      senderId: m.senderId,
                      text: m.localizedBody(locale),
                      createdAtIso: m.createdAt.toIso8601String(),
                    ),
                ],
              ),
            );
          },
          orElse: () => const SizedBox.shrink(),
        ),
      ],
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Text(
              jobTitle,
              style: AppTypography.subtitle,
              textAlign: TextAlign.center,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: ClassifiedsHostNotice(locale: locale, dense: true),
          ),
          Expanded(
            child: messagesAsync.when(
              loading: () => const Center(
                child: CircularProgressIndicator(color: AppColors.purpleGlow),
              ),
              error: (_, __) => const SizedBox.shrink(),
              data: (messages) {
                final visible = ClassifiedsChatSafetyLogic.visibleMessages(
                  messages: messages,
                  myUid: uid,
                  blockedUserIds: blockedIds,
                  senderIdOf: (m) => m.senderId,
                );
                return ListView.builder(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  itemCount: visible.length,
                  itemBuilder: (context, index) => _MessageBubble(
                    message: visible[index],
                    uid: uid,
                    locale: locale,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({
    required this.message,
    required this.uid,
    required this.locale,
  });

  final JobApplicationChatMessage message;
  final String uid;
  final String locale;

  @override
  Widget build(BuildContext context) {
    final isMine = message.senderId == uid;
    final isSystem = message.isApplicationSystem;

    return Align(
      alignment: isSystem
          ? Alignment.center
          : (isMine ? Alignment.centerRight : Alignment.centerLeft),
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.sm),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: isSystem
              ? AppColors.surfaceElevated.withValues(alpha: 0.7)
              : (isMine
                  ? AppColors.purpleGlow.withValues(alpha: 0.18)
                  : AppColors.surfaceElevated),
          borderRadius: BorderRadius.circular(16),
        ),
        child: isSystem
            ? Text(
                message.localizedBody(locale),
                style: AppTypography.bodySmall.copyWith(
                  fontStyle: FontStyle.italic,
                  color: AppColors.textSecondary,
                ),
              )
            : UserGeneratedTextWithLinkSafety(
                text: message.localizedBody(locale),
                locale: locale,
                surface: LinkSafetySurface.jobsChat,
                style: AppTypography.bodySmall,
              ),
      ),
    );
  }
}
