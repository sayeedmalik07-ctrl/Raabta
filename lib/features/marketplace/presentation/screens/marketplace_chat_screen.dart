import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/core/widgets/hub/hub_subscreen_scaffold.dart';
import 'package:raabta/features/marketplace/data/marketplace_chat_repository.dart';
import 'package:raabta/features/marketplace/domain/marketplace_chat_message.dart';
import 'package:raabta/features/marketplace/domain/marketplace_payment_phishing_detector.dart';
import 'package:raabta/features/marketplace/domain/marketplace_platform_hop_detector.dart';
import 'package:raabta/core/l10n/classifieds_chat_safety_strings.dart';
import 'package:raabta/core/widgets/classifieds_chat_safety_menu.dart';
import 'package:raabta/core/widgets/classifieds_host_notice.dart';
import 'package:raabta/providers/classifieds_chat_safety_providers.dart';
import 'package:raabta/services/classifieds/classifieds_chat_report_service.dart';
import 'package:raabta/services/classifieds/classifieds_chat_safety_logic.dart';
import 'package:raabta/features/marketplace/presentation/l10n/marketplace_strings.dart';
import 'package:raabta/features/marketplace/presentation/widgets/marketplace_message_phishing_alert.dart';
import 'package:raabta/features/marketplace/presentation/widgets/marketplace_payment_security_banner.dart';
import 'package:raabta/features/marketplace/presentation/widgets/marketplace_platform_hop_reminder.dart';
import 'package:raabta/features/marketplace/services/marketplace_platform_hop_reminder_prefs.dart';
import 'package:raabta/features/marketplace/services/marketplace_qr_image_decoder.dart';
import 'package:raabta/providers/auth_providers.dart';
import 'package:raabta/features/link_safety/link_safety_models.dart';
import 'package:raabta/features/link_safety/presentation/link_safety_author_compose_hint.dart';
import 'package:raabta/features/link_safety/presentation/user_generated_text_with_link_safety.dart';
import 'package:raabta/providers/marketplace_providers.dart';
import 'package:raabta/providers/visa_providers.dart';
import 'package:raabta/screens/marketplace/widgets/marketplace_seller_payment_protection_card.dart';
import 'package:raabta/services/qr/listing_ownership.dart';

final marketplaceChatRepositoryProvider = Provider<MarketplaceChatRepository>(
  (ref) => MarketplaceChatRepository(),
);

class MarketplaceChatScreen extends ConsumerStatefulWidget {
  const MarketplaceChatScreen({
    super.key,
    required this.listingId,
    required this.listingTitle,
  });

  final String listingId;
  final String listingTitle;

  @override
  ConsumerState<MarketplaceChatScreen> createState() =>
      _MarketplaceChatScreenState();
}

class _MarketplaceChatScreenState extends ConsumerState<MarketplaceChatScreen> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  bool _buyerBannerVisible = true;
  bool _sellerBannerVisible = true;
  String? _pendingQrPayload;
  bool _sending = false;
  bool _platformHopReminderVisible = false;
  bool _platformHopReminderShownForThread = false;
  bool _platformHopPrefsLoaded = false;
  bool _platformHopReminderPending = false;
  List<MarketplaceChatMessage> _latestMessages = const [];

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      if (mounted) setState(() {});
    });
    _loadPlatformHopReminderState();
  }

  Future<void> _loadPlatformHopReminderState() async {
    final shown = await MarketplacePlatformHopReminderPrefs.isShown(
      widget.listingId,
    );
    if (!mounted) return;
    setState(() => _platformHopPrefsLoaded = true);
    if (shown) {
      setState(() => _platformHopReminderShownForThread = true);
    }
  }

  Future<void> _maybeShowPlatformHopReminder(String text) async {
    if (!_platformHopPrefsLoaded ||
        _platformHopReminderShownForThread ||
        _platformHopReminderPending) {
      return;
    }
    if (!MarketplacePlatformHopDetector.scan(text: text).hasSignal) return;

    _platformHopReminderPending = true;
    await MarketplacePlatformHopReminderPrefs.markShown(widget.listingId);
    if (!mounted) {
      _platformHopReminderPending = false;
      return;
    }
    setState(() {
      _platformHopReminderShownForThread = true;
      _platformHopReminderVisible = true;
      _platformHopReminderPending = false;
    });
  }

  void _dismissPlatformHopReminder() {
    setState(() => _platformHopReminderVisible = false);
  }

  void _evaluateMessagesForPlatformHop(List<MarketplaceChatMessage> messages) {
    if (!_platformHopPrefsLoaded ||
        _platformHopReminderShownForThread ||
        _platformHopReminderPending) {
      return;
    }
    for (final message in messages) {
      if (MarketplacePlatformHopDetector.scan(text: message.text).hasSignal) {
        unawaited(_maybeShowPlatformHopReminder(message.text));
        return;
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final locale = ref.read(userLanguageProvider);
    final user = ref.read(currentUserProvider);
    if (user == null) {
      _showSignInSnack(locale);
      return;
    }

    final text = _controller.text.trim();
    if (text.isEmpty && _pendingQrPayload == null) return;

    final listing = ref
        .read(marketplaceListingDetailProvider(widget.listingId))
        .valueOrNull;
    final ownerUid = listing?.ownerUserId ?? '';
    final peerUid = ClassifiedsChatSafetyLogic.inferMarketplacePeer(
      myUid: user.uid,
      listingOwnerUid: ownerUid,
      messageSenderIds: [
        for (final m in _latestMessages)
          if (!m.isOfferSystem) m.senderId,
      ],
    );
    if (peerUid == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            ClassifiedsChatSafetyStrings.t('send_failed_generic', locale),
          ),
        ),
      );
      return;
    }

    setState(() => _sending = true);
    final repo = ref.read(marketplaceChatRepositoryProvider);
    final outgoingText = text.isEmpty
        ? MarketplaceStrings.t('mp_image_qr_attached', locale)
        : text;
    try {
      await repo.sendMessage(
        listingId: widget.listingId,
        text: outgoingText,
        peerUid: peerUid,
        embeddedQrPayload: _pendingQrPayload,
        imageAttached: _pendingQrPayload != null,
      );
      unawaited(_maybeShowPlatformHopReminder(outgoingText));
      _controller.clear();
      setState(() => _pendingQrPayload = null);
      await _scrollToBottom();
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

  Future<void> _attachImageQr() async {
    final locale = ref.read(userLanguageProvider);
    final picker = ImagePicker();
    final file = await picker.pickImage(source: ImageSource.gallery);
    if (file == null || !mounted) return;

    final payload = await MarketplaceQrImageDecoder.decodePayload(file.path);
    setState(() => _pendingQrPayload = payload);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          payload != null
              ? MarketplaceStrings.t('mp_qr_detected_review', locale)
              : MarketplaceStrings.t('mp_qr_not_found', locale),
        ),
      ),
    );
  }

  Future<void> _scrollToBottom() async {
    await Future<void>.delayed(const Duration(milliseconds: 100));
    if (!_scrollController.hasClients) return;
    await _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
    );
  }

  void _showSignInSnack(String locale) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(MarketplaceStrings.t('mp_sign_in_required', locale)),
      ),
    );
  }

  Future<void> _reportConversation() async {
    final locale = ref.read(userLanguageProvider);
    await ref
        .read(marketplaceChatRepositoryProvider)
        .reportConversation(
          listingId: widget.listingId,
          reason: 'marketplace_payment_phishing',
        );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(MarketplaceStrings.t('mp_report_submitted', locale)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final locale = ref.watch(userLanguageProvider);
    final user = ref.watch(currentUserProvider);
    final repo = ref.watch(marketplaceChatRepositoryProvider);
    final listingAsync = ref.watch(
      marketplaceListingDetailProvider(widget.listingId),
    );
    final isSeller = listingAsync.maybeWhen(
      data: (listing) => isListingOwnedByCurrentUser(listing?.ownerUserId),
      orElse: () => false,
    );

    final blockedIds = ref.watch(blockedUserIdsProvider).valueOrNull ?? {};
    final ownerUid = listingAsync.valueOrNull?.ownerUserId ?? '';
    final peerUid = user == null
        ? null
        : ClassifiedsChatSafetyLogic.inferMarketplacePeer(
            myUid: user.uid,
            listingOwnerUid: ownerUid,
            messageSenderIds: [
              for (final m in _latestMessages)
                if (!m.isOfferSystem) m.senderId,
            ],
          );
    final canSend = ClassifiedsChatSafetyLogic.composerEnabled(
      peerUid: peerUid,
      myBlockedUserIds: blockedIds,
    );

    return HubSubscreenScaffold(
      title: MarketplaceStrings.t('mp_chat_title', locale),
      subtitle: widget.listingTitle,
      onBack: () => context.pop(),
      headerTrailing: peerUid != null
          ? ClassifiedsChatSafetyMenu(
              locale: locale,
              peerUid: peerUid,
              reportContext: (
                targetId: widget.listingId,
                targetType: 'marketplace_chat',
                peerUid: peerUid,
                messages: [
                  for (final m in _latestMessages)
                    ClassifiedsChatReportMessageSnapshot(
                      messageId: m.id,
                      senderId: m.senderId,
                      text: m.text,
                      createdAtIso: m.createdAt.toIso8601String(),
                    ),
                ],
              ),
            )
          : null,
      body: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.xl,
          0,
          AppSpacing.xl,
          AppSpacing.md,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClassifiedsHostNotice(locale: locale, dense: true),
            const SizedBox(height: AppSpacing.sm),
            if (isSeller)
              MarketplaceSellerPaymentProtectionCard(
                locale: locale,
                compact: true,
                visible: _sellerBannerVisible,
                onDismiss: () => setState(() => _sellerBannerVisible = false),
              )
            else
              MarketplacePaymentSecurityBanner(
                visible: _buyerBannerVisible,
                onDismiss: () => setState(() => _buyerBannerVisible = false),
                locale: locale,
              ),
            if (_platformHopReminderVisible)
              MarketplacePlatformHopReminder(
                locale: locale,
                onDismiss: _dismissPlatformHopReminder,
              ),
            Expanded(
              child: user == null
                  ? Center(
                      child: Text(
                        MarketplaceStrings.t('mp_sign_in_required', locale),
                        style: AppTypography.body,
                        textAlign: TextAlign.center,
                      ),
                    )
                  : StreamBuilder<List<MarketplaceChatMessage>>(
                      stream: repo.watchMessages(widget.listingId),
                      builder: (context, snapshot) {
                        final messages = snapshot.data ?? const [];
                        _latestMessages = messages;
                        final visible =
                            ClassifiedsChatSafetyLogic.visibleMessages(
                              messages: messages,
                              myUid: user.uid,
                              blockedUserIds: blockedIds,
                              senderIdOf: (m) => m.senderId,
                            );
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          _evaluateMessagesForPlatformHop(messages);
                          _scrollToBottom();
                        });

                        if (messages.isEmpty) {
                          return Center(
                            child: Text(
                              MarketplaceStrings.t(
                                'mp_empty_chat_hint',
                                locale,
                              ),
                              style: AppTypography.bodySmall.copyWith(
                                color: AppColors.textTertiary,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          );
                        }

                        return ListView.builder(
                          controller: _scrollController,
                          itemCount: visible.length,
                          itemBuilder: (context, index) {
                            final message = visible[index];
                            if (message.isOfferSystem) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 6,
                                ),
                                child: Center(
                                  child: Container(
                                    padding: const EdgeInsets.all(
                                      AppSpacing.sm,
                                    ),
                                    constraints: BoxConstraints(
                                      maxWidth:
                                          MediaQuery.sizeOf(context).width *
                                          0.9,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.brandFamilyMain
                                          .withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                        color: AppColors.brandFamilyMain
                                            .withValues(alpha: 0.4),
                                      ),
                                    ),
                                    child: Text(
                                      message.text,
                                      style: AppTypography.caption.copyWith(
                                        height: 1.4,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                              );
                            }

                            final isMine =
                                message.senderId ==
                                FirebaseAuth.instance.currentUser?.uid;
                            final scan =
                                message.phishingScan ??
                                MarketplacePaymentPhishingDetector.scan(
                                  text: message.text,
                                  embeddedQrPayload: message.embeddedQrPayload,
                                );

                            return Column(
                              crossAxisAlignment: isMine
                                  ? CrossAxisAlignment.end
                                  : CrossAxisAlignment.start,
                              children: [
                                Container(
                                  margin: const EdgeInsets.symmetric(
                                    vertical: 4,
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: AppSpacing.sm,
                                    vertical: AppSpacing.xs,
                                  ),
                                  constraints: BoxConstraints(
                                    maxWidth:
                                        MediaQuery.sizeOf(context).width * 0.78,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isMine
                                        ? AppColors.brandFamilyMain.withValues(
                                            alpha: 0.18,
                                          )
                                        : AppColors.surfaceElevated,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      UserGeneratedTextWithLinkSafety(
                                        text: message.text,
                                        locale: locale,
                                        surface:
                                            LinkSafetySurface.marketplaceChat,
                                        onReportPost: _reportConversation,
                                      ),
                                      if (message.imageAttached)
                                        Padding(
                                          padding: const EdgeInsets.only(
                                            top: 4,
                                          ),
                                          child: Text(
                                            '📷 ${MarketplaceStrings.t('mp_image_qr_attached', locale)}',
                                            style: AppTypography.caption,
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                                if (scan.hasSignals)
                                  MarketplaceMessagePhishingAlert(
                                    scan: scan,
                                    onReport: _reportConversation,
                                    locale: locale,
                                  ),
                              ],
                            );
                          },
                        );
                      },
                    ),
            ),
            if (_pendingQrPayload != null)
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                child: Text(
                  MarketplaceStrings.format(
                    'mp_qr_pending',
                    locale,
                    params: {'payload': _pendingQrPayload!},
                  ),
                  style: AppTypography.caption.copyWith(
                    color: AppColors.warning,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            if (user != null && !canSend)
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
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
              ),
            LinkSafetyAuthorComposeHint(
              text: _controller.text,
              locale: locale,
              surface: LinkSafetySurface.marketplaceChat,
              onRemoveLink: () {
                _controller.text = _controller.text.replaceAll(
                  RegExp(
                    r'(?:(?:https?://)|(?:www\.))[^\s<>"{}|\\^`\[\]]+',
                    caseSensitive: false,
                  ),
                  '',
                );
              },
            ),
            Row(
              children: [
                IconButton(
                  onPressed: user == null || !canSend
                      ? () => _showSignInSnack(locale)
                      : _attachImageQr,
                  icon: const Icon(Icons.image_outlined),
                  tooltip: MarketplaceStrings.t(
                    'mp_attach_image_tooltip',
                    locale,
                  ),
                ),
                Expanded(
                  child: TextField(
                    controller: _controller,
                    enabled: user != null && !_sending && canSend,
                    decoration: InputDecoration(
                      hintText: MarketplaceStrings.t('mp_message_hint', locale),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      isDense: true,
                    ),
                    minLines: 1,
                    maxLines: 4,
                  ),
                ),
                IconButton(
                  onPressed: _sending || user == null || !canSend
                      ? null
                      : _send,
                  icon: _sending
                      ? SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.brandFamilyMain,
                          ),
                        )
                      : Icon(Icons.send, color: AppColors.brandFamilyMain),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
