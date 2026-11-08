import 'package:cloud_firestore/cloud_firestore.dart';
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
import 'package:raabta/features/housing/domain/housing_chat_message.dart';
import 'package:raabta/features/housing/presentation/l10n/housing_viewing_strings.dart';
import 'package:raabta/features/housing/providers/housing_viewing_providers.dart';
import 'package:raabta/providers/classifieds_chat_safety_providers.dart';
import 'package:raabta/features/scam_shield/forewarnings/forewarning_moment_id.dart';
import 'package:raabta/features/scam_shield/presentation/widgets/forewarning_slot.dart';
import 'package:raabta/providers/housing_providers.dart';
import 'package:raabta/features/link_safety/link_safety_models.dart';
import 'package:raabta/features/link_safety/presentation/user_generated_text_with_link_safety.dart';
import 'package:raabta/providers/visa_providers.dart';
import 'package:raabta/services/classifieds/classifieds_chat_report_service.dart';
import 'package:raabta/services/classifieds/classifieds_chat_safety_logic.dart';

class HousingChatScreen extends ConsumerStatefulWidget {
  const HousingChatScreen({
    super.key,
    required this.listingId,
    required this.listingTitle,
  });

  final String listingId;
  final String listingTitle;

  @override
  ConsumerState<HousingChatScreen> createState() => _HousingChatScreenState();
}

class _HousingChatScreenState extends ConsumerState<HousingChatScreen> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  bool _sending = false;

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  String? _peerUid({
    required String myUid,
    required String? ownerUid,
    required List<HousingChatMessage> messages,
  }) {
    if (ownerUid == null || ownerUid.isEmpty) return null;
    if (myUid != ownerUid) return ownerUid;
    return ClassifiedsChatSafetyLogic.inferMarketplacePeer(
      myUid: myUid,
      listingOwnerUid: ownerUid,
      messageSenderIds: [
        for (final m in messages)
          if (!m.isViewingSystem) m.senderId,
      ],
    );
  }

  Future<void> _send({
    required String locale,
    required String? peerUid,
  }) async {
    final text = _controller.text.trim();
    if (text.isEmpty || _sending || peerUid == null) return;
    setState(() => _sending = true);
    try {
      await ref.read(housingChatRepositoryProvider).sendMessage(
            listingId: widget.listingId,
            text: text,
            peerUid: peerUid,
          );
      if (!mounted) return;
      _controller.clear();
      await Future<void>.delayed(const Duration(milliseconds: 100));
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    } on FirebaseException catch (_) {
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
    final listingAsync = ref.watch(housingListingDetailProvider(widget.listingId));
    final ownerUid = listingAsync.valueOrNull?.ownerUserId;
    final blockedAsync = ref.watch(blockedUserIdsProvider);
    final blockedIds = blockedAsync.valueOrNull ?? {};
    final messagesAsync =
        ref.watch(housingChatMessagesProvider(widget.listingId));

    return GlassScreenScaffold(
      title: HousingViewingStrings.t('hv_chat_title', locale),
      actions: [
        messagesAsync.maybeWhen(
          data: (messages) {
            final peer = _peerUid(
              myUid: uid,
              ownerUid: ownerUid,
              messages: messages,
            );
            if (peer == null) return const SizedBox.shrink();
            return ClassifiedsChatSafetyMenu(
              locale: locale,
              peerUid: peer,
              reportContext: (
                targetId: widget.listingId,
                targetType: 'housing_chat',
                peerUid: peer,
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
              widget.listingTitle,
              style: AppTypography.subtitle,
              textAlign: TextAlign.center,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: ClassifiedsHostNotice(locale: locale, dense: true),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              AppSpacing.sm,
              AppSpacing.md,
              0,
            ),
            child: ForewarningSlot(
              momentId: ForewarningMomentId.housingDepositViewing,
              locale: locale,
            ),
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
                return ListView.builder(
                  controller: _scrollController,
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
          messagesAsync.maybeWhen(
            data: (messages) {
              final peer = _peerUid(
                myUid: uid,
                ownerUid: ownerUid,
                messages: messages,
              );
              final canSend = ClassifiedsChatSafetyLogic.composerEnabled(
                peerUid: peer,
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
                    style: AppTypography.caption.copyWith(
                      color: AppColors.textTertiary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                );
              }
              return SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _controller,
                          enabled: !_sending && peer != null,
                          decoration: InputDecoration(
                            hintText: HousingViewingStrings.t(
                              'hv_chat_hint',
                              locale,
                            ),
                            filled: true,
                            fillColor: AppColors.surface.withValues(alpha: 0.5),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(24),
                            ),
                          ),
                          onSubmitted: (_) => _send(locale: locale, peerUid: peer),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      IconButton(
                        onPressed: _sending || peer == null
                            ? null
                            : () => _send(locale: locale, peerUid: peer),
                        icon: const Icon(Icons.send, color: AppColors.cyanGlow),
                      ),
                    ],
                  ),
                ),
              );
            },
            orElse: () => const SizedBox.shrink(),
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

  final HousingChatMessage message;
  final String uid;
  final String locale;

  @override
  Widget build(BuildContext context) {
    final isMine = message.senderId == uid;
    final isSystem = message.isViewingSystem;

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
        constraints: BoxConstraints(
          maxWidth: MediaQuery.sizeOf(context).width * 0.78,
        ),
        decoration: BoxDecoration(
          color: isSystem
              ? AppColors.surface.withValues(alpha: 0.35)
              : (isMine
                  ? AppColors.cyanGlow.withValues(alpha: 0.25)
                  : AppColors.surface.withValues(alpha: 0.5)),
          borderRadius: BorderRadius.circular(12),
        ),
        child: isSystem
            ? Text(
                message.text,
                style: AppTypography.caption.copyWith(
                  color: AppColors.textSecondary,
                  fontStyle: FontStyle.italic,
                ),
              )
            : UserGeneratedTextWithLinkSafety(
                text: message.text,
                locale: locale,
                surface: LinkSafetySurface.housingChat,
              ),
      ),
    );
  }
}
