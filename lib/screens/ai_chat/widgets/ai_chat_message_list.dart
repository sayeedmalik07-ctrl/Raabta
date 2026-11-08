import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raabta/core/l10n/app_locale.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/data/qatar_labour_law_kb.dart';
import 'package:raabta/providers/ai_chat_provider.dart';
import 'package:raabta/screens/ai_chat/widgets/ai_chat_bubble.dart';
import 'package:raabta/screens/ai_chat/utils/ai_chat_error_message.dart';
import 'package:raabta/screens/ai_chat/widgets/ai_message_appear_animation.dart';

class AiChatMessageList extends ConsumerStatefulWidget {
  const AiChatMessageList({
    super.key,
    required this.scrollController,
    required this.locale,
    required this.onReplyToMessage,
  });

  final ScrollController scrollController;
  final String locale;
  final ValueChanged<String> onReplyToMessage;

  @override
  ConsumerState<AiChatMessageList> createState() => _AiChatMessageListState();
}

class _AiChatMessageListState extends ConsumerState<AiChatMessageList> {
  final Set<String> _seenMessageIds = {};
  String? _lastThreadId;

  @override
  Widget build(BuildContext context) {
    final chatState = ref.watch(aiChatProvider);
    final isRtl = AppLocale.isRtl(widget.locale);

    if (_lastThreadId != chatState.activeThreadId) {
      _lastThreadId = chatState.activeThreadId;
      _seenMessageIds.clear();
    }

    return ListView.builder(
      controller: widget.scrollController,
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.md,
        AppSpacing.md,
        AppSpacing.sm,
      ),
      itemCount: chatState.messages.length,
      itemBuilder: (context, index) {
        final message = chatState.messages[index];
        final animate = !_seenMessageIds.contains(message.id);
        if (animate) _seenMessageIds.add(message.id);

        final isErrorMessage = AiChatErrorMessage.isAssistantError(message);
        final shouldAnimateAppear = animate &&
            (message.isUser || (isErrorMessage && !message.isStreaming));

        final bubble = AiChatBubble(
          message: message,
          locale: widget.locale,
          isRtl: isRtl,
          showLabourDisclaimer:
              _showLabourDisclaimer(chatState, message, index),
          isSpeaking: chatState.isSpeaking && !message.isUser,
          onReply: !message.isUser && !message.isStreaming
              ? () => widget.onReplyToMessage(message.text)
              : null,
          onSpeak: message.isUser || message.isStreaming
              ? null
              : () => ref.read(aiChatProvider.notifier).speakMessage(message.text),
          onRetry: isErrorMessage ? () => _retryLastMessage(chatState) : null,
          onRegenerate: !message.isUser &&
                  !message.isStreaming &&
                  _isLastAssistantMessage(chatState, index)
              ? () => ref.read(aiChatProvider.notifier).regenerateLastResponse()
              : null,
          onEdit: message.isUser && !chatState.isGenerating
              ? (newText) => ref
                  .read(aiChatProvider.notifier)
                  .editUserMessage(message.id, newText)
              : null,
        );

        return AiMessageAppearAnimation(
          animate: shouldAnimateAppear,
          child: bubble,
        );
      },
    );
  }

  Future<void> _retryLastMessage(AiChatState chatState) async {
    for (var i = chatState.messages.length - 1; i >= 0; i--) {
      if (chatState.messages[i].isUser) {
        await ref.read(aiChatProvider.notifier).sendMessage(
              chatState.messages[i].text,
            );
        return;
      }
    }
  }

  bool _isLastAssistantMessage(AiChatState state, int index) {
    if (state.messages[index].isUser) return false;
    for (var i = state.messages.length - 1; i >= 0; i--) {
      if (!state.messages[i].isUser) return i == index;
    }
    return false;
  }

  String? _userMessageBefore(List<AiChatMessage> messages, int index) {
    for (var i = index - 1; i >= 0; i--) {
      if (messages[i].isUser) return messages[i].text;
    }
    return null;
  }

  bool _showLabourDisclaimer(
    AiChatState state,
    AiChatMessage message,
    int index,
  ) {
    if (message.isUser || message.isStreaming) return false;
    if (AiChatErrorMessage.isErrorText(message.text)) {
      return false;
    }
    if (state.researchMode && state.isPremium) return true;
    final userText = _userMessageBefore(state.messages, index);
    if (userText != null && QatarLabourLawKB.isLabourQuery(userText)) {
      return true;
    }
    return false;
  }
}
