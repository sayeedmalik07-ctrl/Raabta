import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:raabta/config/app_config.dart';
import 'package:raabta/data/qatar_labour_law_kb.dart';

class ApiService {
  static const String baseUrl = AppConfig.backendUrl;

  static Future<String> sendMessage(
    String message, {
    String language = 'English',
    String languageCode = 'en',
    List<Map<String, String>> conversationHistory = const [],
  }) async {
    try {
      final isLabour = QatarLabourLawKB.isLabourQuery(message);
      final context = QatarLabourLawKB.buildSystemPrompt(
        userLanguageCode: languageCode,
        isLabourQuery: isLabour,
      );

      final response = await http
          .post(
            Uri.parse('$baseUrl/api/chat'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'message': message,
              'language': language,
              'languageCode': languageCode,
              'conversationHistory': conversationHistory,
              'context': context,
              'requestType': 'chat',
            }),
          )
          .timeout(Duration(seconds: AppConfig.aiRequestTimeout));

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return data['reply'] as String? ?? 'No response';
      }

      return data['message'] as String? ??
          data['error'] as String? ??
          'Error: ${response.statusCode}';
    } catch (e) {
      return 'Connection Error: $e';
    }
  }
}
