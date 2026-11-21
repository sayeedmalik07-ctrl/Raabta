import 'package:raabta/screens/ai_chat/models/ai_chat_message.dart';

abstract final class AiChatErrorMessage {
  static bool isErrorText(String text) {
    return text.startsWith('Connection Error:') || text.startsWith('Error:');
  }

  static bool isAssistantError(AiChatMessage message) {
    return !message.isUser && isErrorText(message.text);
  }
}
