import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/glass/glass_card.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/core/widgets/glass_primary_button.dart';
import 'package:raabta/core/widgets/glass_screen_scaffold.dart';
import 'package:raabta/core/widgets/classifieds_chat_safety_menu.dart';
import 'package:raabta/features/buddy/data/buddy_request_repository.dart';
import 'package:raabta/features/buddy/domain/buddy_constants.dart';
import 'package:raabta/features/buddy/domain/buddy_intro_templates.dart';
import 'package:raabta/features/buddy/domain/buddy_request_transitions.dart';
import 'package:raabta/features/buddy/domain/buddy_thread_ids.dart';
import 'package:raabta/features/buddy/models/buddy_profile.dart';
import 'package:raabta/features/buddy/models/buddy_request.dart';
import 'package:raabta/features/buddy/presentation/l10n/buddy_strings.dart';
import 'package:raabta/features/buddy/providers/buddy_providers.dart';
import 'package:raabta/features/buddy/services/buddy_match_cache.dart';
import 'package:raabta/features/community/presentation/l10n/community_strings.dart';
import 'package:raabta/features/community/providers/community_providers.dart';
import 'package:raabta/features/community/services/community_moderation_confirm_flow.dart';
import 'package:raabta/core/l10n/app_locale_notifier.dart';
import 'package:raabta/providers/auth_providers.dart';
import 'package:raabta/providers/visa_providers.dart';
import 'package:raabta/services/classifieds/classifieds_chat_report_service.dart';
import 'package:raabta/services/smart_notification_engine.dart';

class BuddyHubScreen extends ConsumerWidget {
  const BuddyHubScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(userLanguageProvider);
    final profileAsync = ref.watch(buddyProfileProvider);

    return GlassScreenScaffold(
      title: BuddyStrings.t('buddy_hub_title', locale),
      body: profileAsync.when(
        loading: () => Center(
          child: Text(BuddyStrings.t('buddy_loading', locale)),
        ),
        error: (_, _) => Center(
          child: Text(BuddyStrings.t('buddy_error_generic', locale)),
        ),
        data: (profile) {
          if (profile == null) {
            return _NoProfile(locale: locale);
          }
          return RefreshIndicator(
            onRefresh: () async {
              BuddyMatchCache.invalidate(profile.uid);
              ref.invalidate(buddyProfileProvider);
              ref.invalidate(buddySuggestionsProvider);
              ref.invalidate(buddyIncomingRequestsProvider);
              ref.invalidate(buddyOutgoingRequestsProvider);
              ref.invalidate(buddyActiveThreadsProvider);
            },
            child: ListView(
              padding: const EdgeInsets.all(AppSpacing.xl),
              children: [
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => context.push('/community/buddy/profile'),
                    child: Text(BuddyStrings.t('buddy_edit_profile', locale)),
                  ),
                ),
                if (!profile.paused) ...[
                  Text(
                    BuddyStrings.t('buddy_threads_title', locale),
                    style: AppTypography.subtitle,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  _ThreadsSection(locale: locale),
                  const SizedBox(height: AppSpacing.xl),
                ],
                if (profile.isNewcomer && !profile.paused) ...[
                  Text(
                    BuddyStrings.t('buddy_suggestions_title', locale),
                    style: AppTypography.subtitle,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _SuggestionsSection(profile: profile, locale: locale),
                  const SizedBox(height: AppSpacing.xl),
                  Text(
                    BuddyStrings.t('buddy_outgoing_title', locale),
                    style: AppTypography.subtitle,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  _OutgoingSection(locale: locale),
                ],
                if (profile.isHelper && !profile.paused) ...[
                  Text(
                    BuddyStrings.t('buddy_incoming_title', locale),
                    style: AppTypography.subtitle,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  _IncomingSection(locale: locale),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}

class _NoProfile extends StatelessWidget {
  const _NoProfile({required this.locale});

  final String locale;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        children: [
          Text(BuddyStrings.t('buddy_setup_profile', locale)),
          const SizedBox(height: AppSpacing.lg),
          GlassPrimaryButton(
            label: BuddyStrings.t('buddy_edit_profile', locale),
            onPressed: () => context.push('/community/buddy/profile'),
          ),
        ],
      ),
    );
  }
}

class _SuggestionsSection extends ConsumerWidget {
  const _SuggestionsSection({required this.profile, required this.locale});

  final BuddyProfile profile;
  final String locale;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final suggestions = ref.watch(buddySuggestionsProvider);

    return suggestions.when(
      loading: () => const LinearProgressIndicator(),
      error: (_, _) => Text(BuddyStrings.t('buddy_error_generic', locale)),
      data: (items) {
        if (items.isEmpty) {
          return Text(
            BuddyStrings.t('buddy_suggestions_empty', locale),
            style: AppTypography.body.copyWith(color: AppColors.textSecondary),
          );
        }
        return Column(
          children: [
            for (final item in items)
              _HelperCard(
                helper: item.helper,
                locale: locale,
                onRequest: () => _sendIntro(context, ref, item.helper.uid),
              ),
          ],
        );
      },
    );
  }

  Future<void> _sendIntro(
    BuildContext context,
    WidgetRef ref,
    String helperUid,
  ) async {
    final uid = ref.read(currentUserProvider)?.uid;
    if (uid == null) return;

    var templateId = BuddyIntroTemplates.defaultId;
    final noteCtrl = TextEditingController();
    final picked = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(BuddyStrings.t('buddy_send_request', locale)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<String>(
              initialValue: templateId,
              items: [
                for (final t in BuddyIntroTemplates.all)
                  DropdownMenuItem(
                    value: t.id,
                    child: Text(BuddyStrings.t(t.labelKey, locale)),
                  ),
              ],
              onChanged: (v) => templateId = v ?? templateId,
            ),
            TextField(
              controller: noteCtrl,
              maxLength: 200,
              decoration: InputDecoration(
                labelText: BuddyStrings.t('buddy_optional_note', locale),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Back')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Send')),
        ],
      ),
    );
    if (picked != true || !context.mounted) return;

    final template = BuddyIntroTemplates.byId(templateId)!;
    final base = BuddyStrings.t(template.labelKey, locale);
    final intro = noteCtrl.text.trim().isEmpty
        ? base
        : '$base ${noteCtrl.text.trim()}';

    final moderation = ref.read(communityPostModerationServiceProvider);
    final appLocale = ref.read(appLocaleProvider);
    var modResult = await moderation.moderateContent(
      text: intro,
      language: appLocale,
      userId: uid,
      contentType: 'buddy_intro',
      useCommentLength: true,
    );
    modResult = await resolveCommunityModeration(
      context: context,
      locale: appLocale,
      initialResult: modResult,
      runModeration: ({
        investmentWarningAcknowledged = false,
        fundraisingWarningAcknowledged = false,
      }) =>
          moderation.moderateContent(
        text: intro,
        language: appLocale,
        userId: uid,
        contentType: 'buddy_intro',
        useCommentLength: true,
        investmentWarningAcknowledged: investmentWarningAcknowledged,
        fundraisingWarningAcknowledged: fundraisingWarningAcknowledged,
      ),
      onCancelled: (warnResult) => moderation.logModerationWarningCancelled(
        category: warnResult.category!,
        text: intro,
        language: appLocale,
        userId: uid,
        contentType: 'buddy_intro',
        layer: warnResult.layer,
      ),
    );
    if (!context.mounted) return;
    if (!modResult.allowed) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            modResult.blockMessage ??
                BuddyStrings.t('buddy_intro_moderation_blocked', locale),
          ),
        ),
      );
      return;
    }

    final outcome = await ref.read(buddyRequestRepositoryProvider).createRequest(
          fromUid: uid,
          toUid: helperUid,
          introTemplateId: templateId,
          introText: intro,
        );

    if (!context.mounted) return;
    if (outcome.error != null) {
      final message = outcome.error == BuddyRequestCreateError.blocked
          ? BuddyStrings.t('buddy_request_blocked', locale)
          : BuddyStrings.t('buddy_request_failed', locale);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
      return;
    }
    final requestId = outcome.requestId;
    if (requestId != null) {
      await SmartNotificationEngine.instance.notifyBuddyRequest(
        requestId: requestId,
        helperUserId: helperUid,
        introPreview: intro.length > 120 ? '${intro.substring(0, 117)}…' : intro,
      );
    }
    BuddyMatchCache.invalidate(uid);
    ref.invalidate(buddyOutgoingRequestsProvider);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(BuddyStrings.t('buddy_request_sent', locale))),
    );
  }
}

class _HelperCard extends ConsumerWidget {
  const _HelperCard({
    required this.helper,
    required this.locale,
    required this.onRequest,
  });

  final BuddyProfile helper;
  final String locale;
  final VoidCallback onRequest;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: GlassCard(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(helper.displayNickname, style: AppTypography.subtitle),
                ),
                ClassifiedsChatSafetyMenu(
                  locale: locale,
                  peerUid: helper.uid,
                  reportContext: (
                    targetId: helper.uid,
                    targetType: 'buddy_suggestion',
                    peerUid: helper.uid,
                    messages: const [],
                  ),
                ),
              ],
            ),
            Text(
              BuddyStrings.t('buddy_self_declared_label', locale),
              style: AppTypography.caption.copyWith(color: AppColors.textSecondary),
            ),
            Text(
              CommunityStrings.nationalityLabel(helper.nationalityCountryId, locale),
            ),
            Text(helper.areaCode),
            const SizedBox(height: AppSpacing.sm),
            GlassPrimaryButton(
              label: BuddyStrings.t('buddy_send_request', locale),
              onPressed: onRequest,
            ),
          ],
        ),
      ),
    );
  }
}

class _IncomingSection extends ConsumerWidget {
  const _IncomingSection({required this.locale});

  final String locale;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final incoming = ref.watch(buddyIncomingRequestsProvider);
    return incoming.when(
      loading: () => const LinearProgressIndicator(),
      error: (_, _) => Text(BuddyStrings.t('buddy_error_generic', locale)),
      data: (requests) {
        if (requests.isEmpty) return const SizedBox.shrink();
        return Column(
          children: [
            for (final r in requests)
              _RequestTile(
                request: r,
                locale: locale,
                peerUid: r.fromUid,
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextButton(
                      onPressed: () => _respond(ref, r, BuddyRequestAction.decline),
                      child: Text(BuddyStrings.t('buddy_decline', locale)),
                    ),
                    TextButton(
                      onPressed: () => _respond(ref, r, BuddyRequestAction.accept),
                      child: Text(BuddyStrings.t('buddy_accept', locale)),
                    ),
                  ],
                ),
              ),
          ],
        );
      },
    );
  }

  Future<void> _respond(
    WidgetRef ref,
    BuddyRequest request,
    BuddyRequestAction action,
  ) async {
    final uid = ref.read(currentUserProvider)?.uid;
    if (uid == null) return;
    try {
      await ref.read(buddyRequestRepositoryProvider).respondToRequest(
            requestId: request.id,
            action: action,
            actorUid: uid,
          );
      if (action == BuddyRequestAction.accept) {
        final threadId = BuddyThreadIds.forParticipants(
          request.fromUid,
          request.toUid,
        );
        await SmartNotificationEngine.instance.notifyBuddyRequestAccepted(
          requestId: request.id,
          threadId: threadId,
          newcomerUserId: request.fromUid,
        );
      }
      ref.invalidate(buddyIncomingRequestsProvider);
      ref.invalidate(buddyProfileProvider);
      ref.invalidate(buddyActiveThreadsProvider);
    } catch (_) {}
  }
}

class _ThreadsSection extends ConsumerWidget {
  const _ThreadsSection({required this.locale});

  final String locale;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final threads = ref.watch(buddyActiveThreadsProvider);
    return threads.when(
      loading: () => const LinearProgressIndicator(),
      error: (_, _) => Text(BuddyStrings.t('buddy_error_generic', locale)),
      data: (items) {
        if (items.isEmpty) {
          return Text(
            BuddyStrings.t('buddy_threads_empty', locale),
            style: AppTypography.body.copyWith(color: AppColors.textSecondary),
          );
        }
        return Column(
          children: [
            for (final thread in items)
              ListTile(
                title: Text(BuddyStrings.t('buddy_open_chat', locale)),
                subtitle: Text(thread.id),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.push('/community/buddy/chat/${thread.id}'),
              ),
          ],
        );
      },
    );
  }
}

class _OutgoingSection extends ConsumerWidget {
  const _OutgoingSection({required this.locale});

  final String locale;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final outgoing = ref.watch(buddyOutgoingRequestsProvider);
    return outgoing.when(
      loading: () => const LinearProgressIndicator(),
      error: (_, _) => Text(BuddyStrings.t('buddy_error_generic', locale)),
      data: (requests) {
        final pending = requests
            .where((r) => r.effectiveStatus == BuddyConstants.requestStatusPending)
            .toList();
        if (pending.isEmpty) return const SizedBox.shrink();
        return Column(
          children: [
            for (final r in pending)
              _RequestTile(
                request: r,
                locale: locale,
                trailing: TextButton(
                  onPressed: () => _cancel(ref, r),
                  child: Text(BuddyStrings.t('buddy_cancel_request', locale)),
                ),
              ),
          ],
        );
      },
    );
  }

  Future<void> _cancel(WidgetRef ref, BuddyRequest request) async {
    final uid = ref.read(currentUserProvider)?.uid;
    if (uid == null) return;
    try {
      await ref.read(buddyRequestRepositoryProvider).respondToRequest(
            requestId: request.id,
            action: BuddyRequestAction.cancel,
            actorUid: uid,
          );
      ref.invalidate(buddyOutgoingRequestsProvider);
    } catch (_) {}
  }
}

class _RequestTile extends StatelessWidget {
  const _RequestTile({
    required this.request,
    required this.locale,
    required this.trailing,
    this.peerUid,
  });

  final BuddyRequest request;
  final String locale;
  final Widget trailing;
  final String? peerUid;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(request.introText, maxLines: 2, overflow: TextOverflow.ellipsis),
      subtitle: Text(request.effectiveStatus),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (peerUid != null && peerUid!.isNotEmpty)
            ClassifiedsChatSafetyMenu(
              locale: locale,
              peerUid: peerUid,
              reportContext: (
                targetId: request.id,
                targetType: 'buddy_request',
                peerUid: peerUid,
                messages: [
                  ClassifiedsChatReportMessageSnapshot(
                    messageId: request.id,
                    senderId: request.fromUid,
                    text: request.introText,
                    createdAtIso: request.createdAt.toIso8601String(),
                  ),
                ],
              ),
            ),
          trailing,
        ],
      ),
    );
  }
}
