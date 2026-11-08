import 'package:raabta/config/app_config.dart';
import 'package:raabta/services/ai/claude_ai_service.dart';

/// Legacy wrapper — prefer [ClaudeAIService.sendMessage] directly.
class ApiService {
  static const String baseUrl = AppConfig.backendUrl;
  static final ClaudeAIService _ai = ClaudeAIService();

  static Future<String> sendMessage(
    String message, {
    String language = 'English',
    String languageCode = 'en',
    List<Map<String, String>> conversationHistory = const [],
    String? userId,
  }) {
    return _ai.sendMessage(
      message,
      language: language,
      languageCode: languageCode,
      conversationHistory: conversationHistory,
      userId: userId,
      requestType: 'chat',
    );
  }
}
