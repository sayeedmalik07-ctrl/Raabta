import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/l10n/classifieds_chat_safety_strings.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/core/widgets/classifieds_chat_safety_menu.dart';
import 'package:raabta/core/widgets/classifieds_host_notice.dart';
import 'package:raabta/core/widgets/glass_screen_scaffold.dart';
import 'package:raabta/features/buddy/domain/buddy_chat_message.dart';
import 'package:raabta/features/buddy/domain/buddy_chat_safety_scanner.dart';
import 'package:raabta/features/buddy/domain/buddy_thread_peers.dart';
import 'package:raabta/features/buddy/presentation/l10n/buddy_strings.dart';
import 'package:raabta/features/buddy/presentation/widgets/buddy_chat_safety_banner.dart';
import 'package:raabta/features/buddy/providers/buddy_providers.dart';
import 'package:raabta/providers/classifieds_chat_safety_providers.dart';
import 'package:raabta/providers/visa_providers.dart';
import 'package:raabta/services/classifieds/classifieds_chat_report_service.dart';
import 'package:raabta/services/classifieds/classifieds_chat_safety_logic.dart';

class BuddyChatScreen extends ConsumerStatefulWidget {
  const BuddyChatScreen({super.key, required this.threadId});

  final String threadId;

  @override
  ConsumerState<BuddyChatScreen> createState() => _BuddyChatScreenState();
}

class _BuddyChatScreenState extends ConsumerState<BuddyChatScreen> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  bool _sending = false;
  BuddyChatSafetyAdvisoryKind? _visibleAdvisory;
  bool _advisoryShownThisSession = false;

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _maybeShowAdvisory(String text) {
    if (_advisoryShownThisSession) return;
    final kind = BuddyChatSafetyScanner.scan(text);
    if (kind == null || !mounted) return;
    setState(() {
      _advisoryShownThisSession = true;
      _visibleAdvisory = kind;
    });
  }

  void _evaluateMessagesForAdvisory(List<BuddyChatMessage> messages) {
    if (_advisoryShownThisSession) return;
    for (final message in messages) {
      final kind = BuddyChatSafetyScanner.scan(message.text);
      if (kind != null) {
        _maybeShowAdvisory(message.text);
        return;
      }
    }
  }

  Future<void> _send({
    required String locale,
    required String? peerUid,
  }) async {
    final text = _controller.text.trim();
    if (text.isEmpty || _sending || peerUid == null) return;
    setState(() => _sending = true);
    try {
      await ref.read(buddyChatRepositoryProvider).sendMessage(
            threadId: widget.threadId,
            text: text,
          );
      if (!mounted) return;
      _maybeShowAdvisory(text);
      _controller.clear();
      await Future<void>.delayed(const Duration(milliseconds: 100));
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            ClassifiedsChatSafetyStrings.t('send_failed_generic', locale),
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final locale = ref.watch(userLanguageProvider);
    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
    final threadAsync = ref.watch(buddyThreadProvider(widget.threadId));
    final blockedAsync = ref.watch(blockedUserIdsProvider);
    final blockedIds = blockedAsync.valueOrNull ?? {};
    final messagesAsync = ref.watch(buddyChatMessagesProvider(widget.threadId));

    final thread = threadAsync.valueOrNull;
    final peerUid = thread == null
        ? null
        : BuddyThreadPeers.peerUidForParticipant(thread: thread, myUid: uid);

    return GlassScreenScaffold(
      title: BuddyStrings.t('buddy_chat_title', locale),
      actions: [
        if (peerUid != null)
          messagesAsync.maybeWhen(
            data: (messages) => ClassifiedsChatSafetyMenu(
              locale: locale,
              peerUid: peerUid,
              reportContext: (
                targetId: widget.threadId,
                targetType: 'buddy_chat',
                peerUid: peerUid,
                messages: [
                  for (final m in messages)
                    ClassifiedsChatReportMessageSnapshot(
                      messageId: m.id,
                      senderId: m.senderId,
                      text: m.text,
                      createdAtIso: m.createdAt.toIso8601String(),
                    ),
                ],
              ),
            ),
            orElse: () => ClassifiedsChatSafetyMenu(
              locale: locale,
              peerUid: peerUid,
              reportContext: (
                targetId: widget.threadId,
                targetType: 'buddy_chat',
                peerUid: peerUid,
                messages: const [],
              ),
            ),
          ),
      ],
      body: threadAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.cyanGlow),
        ),
        error: (_, __) => Center(
          child: Text(BuddyStrings.t('buddy_error_generic', locale)),
        ),
        data: (loaded) {
          if (loaded == null) {
            return Center(
              child: Text(BuddyStrings.t('buddy_chat_unauthorized', locale)),
            );
          }
          if (!loaded.isActive) {
            return Center(
              child: Text(BuddyStrings.t('buddy_chat_ended', locale)),
            );
          }
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                child: ClassifiedsHostNotice(locale: locale, dense: true),
              ),
              if (_visibleAdvisory != null)
                BuddyChatSafetyBanner(
                  locale: locale,
                  kind: _visibleAdvisory!,
                  onDismiss: () => setState(() => _visibleAdvisory = null),
                ),
              Expanded(
                child: messagesAsync.when(
                  loading: () => const Center(
                    child: CircularProgressIndicator(color: AppColors.cyanGlow),
                  ),
                  error: (_, __) => const SizedBox.shrink(),
                  data: (messages) {
                    final visible = ClassifiedsChatSafetyLogic.visibleMessages(
                      messages: messages,
                      myUid: uid,
                      blockedUserIds: blockedIds,
                      senderIdOf: (m) => m.senderId,
                    );
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      _evaluateMessagesForAdvisory(visible);
                    });
                    return ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.all(AppSpacing.md),
                      itemCount: visible.length,
                      itemBuilder: (context, index) => _MessageBubble(
                        message: visible[index],
                        uid: uid,
                      ),
                    );
                  },
                ),
              ),
              messagesAsync.maybeWhen(
                data: (messages) {
                  final canSend = ClassifiedsChatSafetyLogic.composerEnabled(
                    peerUid: peerUid,
                    myBlockedUserIds: blockedIds,
                  );
                  if (!canSend) {
                    return Padding(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      child: Text(
                        ClassifiedsChatSafetyStrings.t(
                          'composer_disabled_hint',
                          locale,
                        ),
                        style: AppTypography.body.copyWith(
                          color: AppColors.textSecondary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    );
                  }
                  return _Composer(
                    controller: _controller,
                    sending: _sending,
                    locale: locale,
                    onSend: () => _send(locale: locale, peerUid: peerUid),
                  );
                },
                orElse: () => _Composer(
                  controller: _controller,
                  sending: _sending,
                  locale: locale,
                  onSend: () => _send(locale: locale, peerUid: peerUid),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _Composer extends StatelessWidget {
  const _Composer({
    required this.controller,
    required this.sending,
    required this.locale,
    required this.onSend,
  });

  final TextEditingController controller;
  final bool sending;
  final String locale;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                decoration: InputDecoration(
                  hintText: BuddyStrings.t('buddy_chat_hint', locale),
                ),
                onSubmitted: (_) => onSend(),
              ),
            ),
            IconButton(
              onPressed: sending ? null : onSend,
              icon: const Icon(Icons.send),
            ),
          ],
        ),
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({required this.message, required this.uid});

  final BuddyChatMessage message;
  final String uid;

  @override
  Widget build(BuildContext context) {
    final mine = message.senderId == uid;
    return Align(
      alignment: mine ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.sm),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: mine
              ? AppColors.cyanGlow.withValues(alpha: 0.2)
              : AppColors.surface.withValues(alpha: 0.35),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(message.text, style: AppTypography.body),
      ),
    );
  }
}
