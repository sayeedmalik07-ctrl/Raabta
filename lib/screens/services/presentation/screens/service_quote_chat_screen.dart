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
import 'package:raabta/core/widgets/hub/hub_loading_placeholder.dart';
import 'package:raabta/screens/services/widgets/service_hub_quote_skin.dart';
import 'package:raabta/screens/services/widgets/service_hub_subscreen_scaffold.dart';
import 'package:raabta/core/widgets/hub/hub_notice_banner.dart';
import 'package:raabta/providers/classifieds_chat_safety_providers.dart';
import 'package:raabta/features/link_safety/link_safety_models.dart';
import 'package:raabta/features/link_safety/presentation/user_generated_text_with_link_safety.dart';
import 'package:raabta/providers/visa_providers.dart';
import 'package:raabta/screens/services/domain/service_quote_chat_message.dart';
import 'package:raabta/screens/services/l10n/service_quote_strings.dart';
import 'package:raabta/screens/services/providers/service_listings_providers.dart';
import 'package:raabta/screens/services/providers/service_quote_providers.dart';
import 'package:raabta/services/classifieds/classifieds_chat_report_service.dart';
import 'package:raabta/services/classifieds/classifieds_chat_safety_logic.dart';

class ServiceQuoteChatScreen extends ConsumerStatefulWidget {
  const ServiceQuoteChatScreen({
    super.key,
    required this.requestListingId,
    required this.providerId,
    required this.requestTitle,
  });

  final String requestListingId;
  final String providerId;
  final String requestTitle;

  @override
  ConsumerState<ServiceQuoteChatScreen> createState() =>
      _ServiceQuoteChatScreenState();
}

class _ServiceQuoteChatScreenState extends ConsumerState<ServiceQuoteChatScreen> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  bool _sending = false;

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  String? _peerUid(String myUid, String? requestOwnerUid) {
    if (requestOwnerUid == null || requestOwnerUid.isEmpty) return null;
    if (myUid == requestOwnerUid) return widget.providerId;
    if (myUid == widget.providerId) return requestOwnerUid;
    return null;
  }

  Future<void> _send({
    required String locale,
    required String peerUid,
  }) async {
    final text = _controller.text.trim();
    if (text.isEmpty || _sending) return;
    setState(() => _sending = true);
    try {
      await ref.read(serviceQuoteChatRepositoryProvider).sendMessage(
            requestListingId: widget.requestListingId,
            providerId: widget.providerId,
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
    final requestOwnerUid = ref
        .watch(serviceListingDetailProvider(widget.requestListingId))
        .valueOrNull
        ?.userId;
    final peerUid = _peerUid(uid, requestOwnerUid);
    final blockedIds = ref.watch(blockedUserIdsProvider).valueOrNull ?? {};
    final canSend = ClassifiedsChatSafetyLogic.composerEnabled(
      peerUid: peerUid,
      myBlockedUserIds: blockedIds,
    );
    final messagesAsync = ref.watch(
      serviceQuoteChatMessagesProvider(
        (
          requestListingId: widget.requestListingId,
          providerId: widget.providerId,
        ),
      ),
    );

    return ServiceHubSubscreenScaffold(
      title: ServiceQuoteStrings.t('svc_quote_chat_title', locale),
      subtitle: widget.requestTitle,
      onBack: () => Navigator.of(context).pop(),
      headerTrailing: messagesAsync.maybeWhen(
        data: (messages) {
          if (peerUid == null) return null;
          return ClassifiedsChatSafetyMenu(
            locale: locale,
            peerUid: peerUid,
            reportContext: (
              targetId: '${widget.requestListingId}:${widget.providerId}',
              targetType: 'service_quote_chat',
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
          );
        },
        orElse: () => null,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.xl,
              AppSpacing.sm,
              AppSpacing.xl,
              AppSpacing.sm,
            ),
            child: HubNoticeBanner.hostNotice(locale: locale),
          ),
          Expanded(
            child: messagesAsync.when(
              loading: () => Center(
                child: HubLoadingPlaceholder(
                  width: MediaQuery.sizeOf(context).width - AppSpacing.xl * 2,
                  height: 200,
                  silhouette: HubLoadingSilhouette.formTool,
                ),
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
          if (!canSend)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              child: Text(
                ClassifiedsChatSafetyStrings.t('composer_disabled_hint', locale),
                style: AppTypography.caption.copyWith(
                  color: AppColors.textTertiary,
                ),
                textAlign: TextAlign.center,
              ),
            )
          else
            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        enabled: !_sending && peerUid != null,
                        decoration: serviceHubQuoteChatComposerDecoration(
                          hintText: ServiceQuoteStrings.t(
                            'svc_quote_chat_hint',
                            locale,
                          ),
                        ),
                        onSubmitted: (_) {
                          if (peerUid != null) {
                            _send(locale: locale, peerUid: peerUid);
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    IconButton(
                      onPressed: _sending || peerUid == null
                          ? null
                          : () => _send(locale: locale, peerUid: peerUid),
                      icon: Icon(Icons.send, color: AppColors.brandFamilyMain),
                    ),
                  ],
                ),
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

  final ServiceQuoteChatMessage message;
  final String uid;
  final String locale;

  @override
  Widget build(BuildContext context) {
    final isMine = message.senderId == uid;
    final isSystem = message.isQuoteSystem;

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
          maxWidth: MediaQuery.sizeOf(context).width * 0.82,
        ),
        decoration: BoxDecoration(
          color: isSystem
              ? AppColors.surfaceElevated.withValues(alpha: 0.7)
              : (isMine
                  ? AppColors.brandFamilyMain.withValues(alpha: 0.18)
                  : AppColors.surfaceElevated),
          borderRadius: BorderRadius.circular(16),
        ),
        child: isSystem
            ? Text(
                message.text,
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                  fontStyle: FontStyle.italic,
                ),
              )
            : UserGeneratedTextWithLinkSafety(
                text: message.text,
                locale: locale,
                surface: LinkSafetySurface.servicesChat,
                style: AppTypography.bodySmall,
              ),
      ),
    );
  }
}
