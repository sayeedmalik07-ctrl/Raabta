import 'package:raabta/providers/ai_chat_provider.dart';
import 'package:raabta/screens/ai_chat/utils/ai_chat_error_message.dart';

/// Visual states for [RaabtaOrb] (see kit orb state sheet).
enum RaabtaOrbState {
  idle,
  listening,
  processing,
  responding,
  error,
  completion,
}

abstract final class RaabtaOrbStateResolver {
  /// Maps chat UI signals to orb motion (does not handle [RaabtaOrbState.completion]).
  static RaabtaOrbState resolve({
    required AiChatState chatState,
    required bool composerFocused,
    required bool composerHasText,
  }) {
    final last = chatState.messages.isNotEmpty ? chatState.messages.last : null;
    if (last != null &&
        AiChatErrorMessage.isAssistantError(last) &&
        !chatState.isGenerating) {
      return RaabtaOrbState.error;
    }
    if (chatState.isStreaming || chatState.isSending) {
      final streamingAssistant = last != null &&
          !last.isUser &&
          last.isStreaming &&
          last.text.trim().isEmpty;
      if (streamingAssistant) {
        return RaabtaOrbState.processing;
      }
      return RaabtaOrbState.responding;
    }
    if (chatState.isProcessingAttachment) {
      return RaabtaOrbState.processing;
    }
    if (chatState.isListening || composerFocused || composerHasText) {
      return RaabtaOrbState.listening;
    }
    return RaabtaOrbState.idle;
  }
}
