import 'package:flutter_test/flutter_test.dart';
import 'package:raabta/core/widgets/raabta_orb_state.dart';
import 'package:raabta/providers/ai_chat_provider.dart';
import 'package:raabta/screens/ai_chat/models/ai_chat_message.dart';

void main() {
  test('empty streaming assistant maps to processing', () {
    final state = AiChatState(
      messages: [
        const AiChatMessage(id: 'u1', isUser: true, text: 'Hi'),
        const AiChatMessage(
          id: 'a1',
          isUser: false,
          text: '',
          isStreaming: true,
        ),
      ],
      isSending: true,
      isStreaming: true,
    );

    expect(
      RaabtaOrbStateResolver.resolve(
        chatState: state,
        composerFocused: false,
        composerHasText: false,
      ),
      RaabtaOrbState.processing,
    );
  });

  test('streaming text maps to responding', () {
    final state = AiChatState(
      messages: [
        const AiChatMessage(id: 'u1', isUser: true, text: 'Hi'),
        const AiChatMessage(
          id: 'a1',
          isUser: false,
          text: 'Hello',
          isStreaming: true,
        ),
      ],
      isSending: true,
      isStreaming: true,
    );

    expect(
      RaabtaOrbStateResolver.resolve(
        chatState: state,
        composerFocused: false,
        composerHasText: false,
      ),
      RaabtaOrbState.responding,
    );
  });
}
