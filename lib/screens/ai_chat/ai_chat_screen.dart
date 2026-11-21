import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:raabta/config/monetization_state.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/l10n/app_locale.dart';
import 'package:raabta/core/l10n/app_shell_strings.dart';
import 'package:raabta/core/router/ai_chat_living_entrance_page.dart';
import 'package:raabta/core/widgets/raabta_orb_state.dart';
import 'package:raabta/screens/ai_chat/utils/ai_chat_error_message.dart';
import 'package:raabta/core/utils/profile_display_helper.dart';
import 'package:raabta/providers/auth_providers.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/providers/ai_chat_provider.dart';
import 'package:raabta/providers/visa_providers.dart';
import 'package:raabta/screens/ai_chat/l10n/ai_chat_strings.dart';
import 'package:raabta/screens/ai_chat/models/ai_chat_context.dart';
import 'package:raabta/features/home/domain/home_ai_assistant_action.dart';
import 'package:raabta/features/know_qatar/providers/know_qatar_providers.dart';
import 'package:raabta/screens/ai_chat/models/ai_chat_feed_teaser.dart';
import 'package:raabta/screens/ai_chat/providers/ai_chat_empty_state_providers.dart';
import 'package:raabta/screens/ai_chat/utils/ai_chat_persona_starters.dart';
import 'package:raabta/screens/ai_chat/utils/ai_chat_personalized_prompts.dart';
import 'package:raabta/screens/ai_chat/widgets/ai_chat_app_bar.dart';
import 'package:raabta/screens/ai_chat/widgets/ai_chat_composer.dart';
import 'package:raabta/screens/ai_chat/widgets/ai_chat_empty_state.dart';
import 'package:raabta/screens/ai_chat/widgets/ai_chat_message_list.dart';
import 'package:raabta/screens/ai_chat/widgets/ai_chat_shell.dart';
import 'package:raabta/screens/ai_chat/widgets/ai_chat_topics_sheet.dart';
import 'package:raabta/screens/ai_chat/widgets/ai_context_chip_bar.dart';
import 'package:raabta/screens/ai_chat/widgets/ai_thread_drawer.dart';
import 'package:raabta/services/ai/user_profile_ai_service.dart';
import 'package:raabta/services/voice_service.dart';

class AiChatScreen extends ConsumerStatefulWidget {
  const AiChatScreen({
    super.key,
    this.onBack,
    this.isTabRoot = false,
    this.initialMessage,
    this.composerHint,
    this.contextSubtitle,
    this.contextSource,
    this.contextBody,
    this.autoSendInitialMessage = true,
    this.livingEntrance = false,
  });

  final VoidCallback? onBack;
  final bool isTabRoot;
  final String? initialMessage;
  final String? composerHint;
  final String? contextSubtitle;
  final String? contextSource;
  final String? contextBody;
  final bool autoSendInitialMessage;
  final bool livingEntrance;

  @override
  ConsumerState<AiChatScreen> createState() => _AiChatScreenState();
}

class _AiChatScreenState extends ConsumerState<AiChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _composerFocusNode = FocusNode();
  bool _pendingInitialSend = false;
  bool _orbCompletionPulse = false;
  Timer? _orbCompletionTimer;

  @override
  void initState() {
    super.initState();
    final initial = widget.initialMessage?.trim();
    if (initial != null && initial.isNotEmpty) {
      _messageController.text = initial;
      if (widget.autoSendInitialMessage) {
        _pendingInitialSend = true;
      }
    }

    void orbDrivingRebuild() {
      if (mounted) setState(() {});
    }

    _composerFocusNode.addListener(orbDrivingRebuild);
    _messageController.addListener(orbDrivingRebuild);

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final notifier = ref.read(aiChatProvider.notifier);
      if (widget.contextSubtitle != null) {
        notifier.setExtraContext(widget.contextSubtitle);
      }
      final source = AiChatContextSource.fromRouteValue(widget.contextSource);
      if (source != null) {
        notifier.setContext(
          AiChatContext(
            source: source,
            label: widget.contextSubtitle ?? source.name,
            body: widget.contextBody,
          ),
        );
      }
      await _syncVoiceLanguage();
      await notifier.loadThreadsIfNeeded();
      await notifier.loadThreadIfNeeded();
      await notifier.initVoice();
      if (_pendingInitialSend) {
        _pendingInitialSend = false;
        ref.read(aiChatProvider.notifier).sendMessage(initial!);
        _messageController.clear();
      }
    });
  }

  @override
  void dispose() {
    _orbCompletionTimer?.cancel();
    _composerFocusNode.dispose();
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  RaabtaOrbState _resolveOrbState(AiChatState chatState) {
    if (_orbCompletionPulse) return RaabtaOrbState.completion;
    return RaabtaOrbStateResolver.resolve(
      chatState: chatState,
      composerFocused: _composerFocusNode.hasFocus,
      composerHasText: _messageController.text.trim().isNotEmpty,
    );
  }

  void _handleOrbLifecycle(AiChatState? previous, AiChatState next) {
    final wasStreaming = previous?.isStreaming ?? false;
    final endedStream = wasStreaming && !next.isStreaming && !next.isSending;
    final lastError = next.messages.isNotEmpty &&
        AiChatErrorMessage.isAssistantError(next.messages.last);

    if (!endedStream || lastError) return;

    _orbCompletionTimer?.cancel();
    setState(() => _orbCompletionPulse = true);
    _orbCompletionTimer = Timer(const Duration(milliseconds: 300), () {
      if (!mounted) return;
      setState(() => _orbCompletionPulse = false);
    });
  }

  Future<void> _syncVoiceLanguage() async {
    // One-shot read when syncing voice engine (init + ref.listen on locale change).
    final appLocale = ref.read(userLanguageProvider);
    final code = AppLocale.toLanguageCode(appLocale);
    await ref.read(aiChatProvider.notifier).changeLanguage(
          raabtaLanguageByCode(code),
        );
  }

  void _handleBack() {
    if (widget.onBack != null) {
      widget.onBack!();
      return;
    }
    if (context.canPop()) {
      context.pop();
    } else if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  Future<void> _sendFromField() async {
    if (ref.read(aiChatProvider).isGenerating) return;
    final text = _messageController.text.trim();
    if (text.isEmpty) return;
    _messageController.clear();
    HapticFeedback.lightImpact();
    await ref.read(aiChatProvider.notifier).sendMessage(text);
    _scrollToBottom();
  }

  Future<void> _sendPrompt(String prompt) async {
    HapticFeedback.selectionClick();
    await ref.read(aiChatProvider.notifier).sendMessage(prompt);
    _scrollToBottom();
  }

  void _handleContextualAction(HomeAiAssistantAction action) {
    final target = action.target;
    if (target is HomeAiAssistantRouteTarget) {
      context.push(target.route);
      return;
    }
    if (target is HomeAiAssistantAiChatTarget) {
      ref.read(aiChatProvider.notifier).setContext(
            AiChatContext(
              source: target.contextSource,
              label: target.contextSubtitle,
              body: target.contextBody,
            ),
          );
    }
  }

  void _handleFeedTeaser(AiChatFeedTeaser teaser) {
    if (teaser.route == '/ai-chat') {
      unawaited(_sendPrompt(teaser.promptOnChatRoute));
      return;
    }
    context.push(teaser.route);
  }

  void _replyToMessage(String assistantText, String locale) {
    final excerpt = assistantText.length > 180
        ? '${assistantText.substring(0, 180)}…'
        : assistantText;
    final prefix = AiChatStrings.t('ai_reply_prefix', locale)
        .replaceAll('{quote}', excerpt);
    _messageController.text = prefix;
    _messageController.selection = TextSelection.collapsed(
      offset: _messageController.text.length,
    );
    HapticFeedback.selectionClick();
  }

  String _greetingForTime(String locale) {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 12) {
      return AiChatStrings.t('ai_greeting_morning', locale);
    }
    if (hour >= 12 && hour < 17) {
      return AiChatStrings.t('ai_greeting_afternoon', locale);
    }
    return AiChatStrings.t('ai_greeting_evening', locale);
  }

  String _greetingLine(String locale) {
    final user = ref.read(currentUserProvider);
    final first = ProfileDisplayHelper.greetingName(user);
    final name = first.isNotEmpty
        ? first
        : AppShellStrings.t('default_friend', locale);
    return '${_greetingForTime(locale)}, $name';
  }

  bool _hasSuggestionContent({
    required List<String> personaStarters,
    required List<String> personalizedPrompts,
    required List contextualActions,
    required List feedTeasers,
  }) {
    return personaStarters.isNotEmpty ||
        personalizedPrompts.isNotEmpty ||
        contextualActions.isNotEmpty ||
        feedTeasers.isNotEmpty;
  }

  void _openThreadDrawer(String locale) {
    final chatState = ref.read(aiChatProvider);
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.backgroundMid,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSpacing.radiusLg),
        ),
      ),
      builder: (_) => AiThreadDrawer(
        threads: chatState.threads,
        activeThreadId: chatState.activeThreadId,
        locale: locale,
        onSelect: (id) =>
            ref.read(aiChatProvider.notifier).switchThread(id),
        onNewChat: () =>
            ref.read(aiChatProvider.notifier).createNewThread(),
        onRename: (id, title) => _renameThread(id, title, locale),
        onDelete: (id) => ref.read(aiChatProvider.notifier).deleteThread(id),
      ),
    );
  }

  Future<void> _renameThread(
    String threadId,
    String currentTitle,
    String locale,
  ) async {
    final controller = TextEditingController(text: currentTitle);
    final newTitle = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceElevated,
        title: Text(AiChatStrings.t('ai_rename_thread', locale)),
        content: TextField(controller: controller, autofocus: true),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(AiChatStrings.t('ai_dismiss', locale)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, controller.text.trim()),
            child: Text(AiChatStrings.t('ai_save', locale)),
          ),
        ],
      ),
    );
    if (newTitle != null && newTitle.isNotEmpty) {
      await ref.read(aiChatProvider.notifier).renameThread(threadId, newTitle);
    }
  }

  void _handleMenuAction(AiChatMenuAction action, String locale) {
    final notifier = ref.read(aiChatProvider.notifier);
    final chatState = ref.read(aiChatProvider);
    switch (action) {
      case AiChatMenuAction.newChat:
        notifier.createNewThread();
      case AiChatMenuAction.threads:
        _openThreadDrawer(locale);
      case AiChatMenuAction.research:
        if (chatState.isPremium) {
          notifier.toggleResearchMode();
        }
      case AiChatMenuAction.voice:
        if (chatState.ttsAvailable) {
          notifier.toggleVoiceEnabled();
        }
      case AiChatMenuAction.premium:
        if (MonetizationState.showPremiumTierUi) {
          context.push('/premium');
        }
    }
  }

  void _showAttachOptions(String locale) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.surfaceElevated,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSpacing.radiusMd),
        ),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: Text(AiChatStrings.t('ai_attach_document', locale)),
              onTap: () {
                Navigator.pop(ctx);
                ref.read(aiChatProvider.notifier).attachFromGallery();
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined),
              title: Text(AiChatStrings.t('ai_take_photo', locale)),
              onTap: () {
                Navigator.pop(ctx);
                ref.read(aiChatProvider.notifier).attachFromCamera();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _startVoiceInput(String locale) {
    if (!ref.read(aiChatProvider).sttAvailable) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AiChatStrings.t('ai_voice_unavailable', locale)),
          backgroundColor: AppColors.sharePurple,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    ref.read(aiChatProvider.notifier).startVoiceInput();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AiChatState>(aiChatProvider, (previous, next) {
      if (previous?.messages.length != next.messages.length ||
          previous?.isSending != next.isSending ||
          previous?.isStreaming != next.isStreaming) {
        _scrollToBottom();
      }
      _handleOrbLifecycle(previous, next);
    });

    ref.listen<String>(userLanguageProvider, (previous, next) {
      if (previous != next) _syncVoiceLanguage();
    });

    final chatState = ref.watch(aiChatProvider);
    final orbState = _resolveOrbState(chatState);
    final locale = ref.watch(userLanguageProvider);
    final profile = ref.watch(userAIProfileProvider);
    final showEmptyState =
        chatState.messages.isEmpty && !chatState.isGenerating;
    final persona = ref.watch(knowQatarPersonaProvider);
    final personaStarters = AiChatPersonaStarters.prompts(
      persona: persona,
      locale: locale,
    );
    final contextualActions = ref.watch(aiChatContextualActionsProvider);
    final feedTeasers = ref.watch(aiChatFeedTeasersProvider);
    final personalizedPrompts =
        AiChatPersonalizedPrompts.build(profile, locale);
    final showBack = !widget.isTabRoot &&
        (widget.onBack != null ||
            context.canPop() ||
            Navigator.of(context).canPop());

    final hasSuggestions = _hasSuggestionContent(
      personaStarters: personaStarters,
      personalizedPrompts: personalizedPrompts,
      contextualActions: contextualActions,
      feedTeasers: feedTeasers,
    );

    final shell = AiChatShell(
      useAurora: !widget.isTabRoot,
      appBar: AiChatAppBar(
        locale: locale,
        chatState: chatState,
        orbState: orbState,
        subtitle:
            widget.contextSubtitle ?? AiChatStrings.t('ai_subtitle', locale),
        showBack: showBack,
        onBack: _handleBack,
        onMenuAction: (action) => _handleMenuAction(action, locale),
      ),
      body: SafeArea(
        child: Column(
          children: [
            if (chatState.context != null)
              AiContextChipBar(
                context: chatState.context!,
                locale: locale,
                onDismiss: () =>
                    ref.read(aiChatProvider.notifier).clearContext(),
              ),
            if (chatState.showQuotaWarning &&
                chatState.dailyRemaining != null &&
                chatState.dailyLimit != null)
              AiQuotaBadge(
                remaining: chatState.dailyRemaining!,
                limit: chatState.dailyLimit!,
                locale: locale,
                onUpgrade: MonetizationState.showPremiumTierUi
                    ? () => context.push('/premium')
                    : null,
              ),
            if (chatState.researchMode && chatState.isPremium)
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.md,
                  0,
                  AppSpacing.md,
                  AppSpacing.xs,
                ),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    AiChatStrings.t('ai_research_premium', locale),
                    style: AppTypography.caption.copyWith(
                      color: AppColors.amberGlow,
                    ),
                  ),
                ),
              ),
            Expanded(
              child: showEmptyState
                  ? AiChatLivingEntranceHost(
                      enabled: widget.livingEntrance,
                      builder: (context, progress) {
                        return AiChatEmptyState(
                          locale: locale,
                          greeting: _greetingLine(locale),
                          personaStarters: personaStarters,
                          personalizedPrompts: personalizedPrompts,
                          contextualActions: contextualActions,
                          feedTeasers: feedTeasers,
                          showServiceSuggestions: hasSuggestions,
                          orbState: orbState,
                          entranceProgress: widget.livingEntrance ? progress : null,
                          onChipTap: _sendPrompt,
                          onContextualActionTap: _handleContextualAction,
                          onFeedTeaserTap: _handleFeedTeaser,
                          onBrowseTopics: () => showAiChatTopicsSheet(
                            context,
                            locale: locale,
                            onTopicSelected: _sendPrompt,
                          ),
                        );
                      },
                    )
                  : AiChatMessageList(
                      scrollController: _scrollController,
                      locale: locale,
                      onReplyToMessage: (text) => _replyToMessage(text, locale),
                    ),
            ),
            AiChatLivingEntranceHost(
              enabled: widget.livingEntrance,
              builder: (context, progress) {
                final composer = AiChatComposer(
                  locale: locale,
                  chatState: chatState,
                  controller: _messageController,
                  hintText: widget.composerHint,
                  focusNode: _composerFocusNode,
                  bottomInset:
                      widget.isTabRoot ? AppSpacing.sm : AppSpacing.md,
                  onSend: _sendFromField,
                  onAttach: () => _showAttachOptions(locale),
                  onStopGeneration: () {
                    HapticFeedback.mediumImpact();
                    ref.read(aiChatProvider.notifier).stopGeneration();
                  },
                  onStartVoice: () => _startVoiceInput(locale),
                  onStopVoice: () =>
                      ref.read(aiChatProvider.notifier).stopVoiceInput(),
                  onClearAttachment: () =>
                      ref.read(aiChatProvider.notifier).clearPendingAttachment(),
                );
                if (!widget.livingEntrance) return composer;
                return AiChatLivingEntranceStagger(
                  index: 4,
                  progress: progress,
                  child: composer,
                );
              },
            ),
          ],
        ),
      ),
    );

    return shell;
  }
}
