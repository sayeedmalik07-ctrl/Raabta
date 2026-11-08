import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:raabta/config/app_config.dart';
import 'package:raabta/screens/ai_chat/models/ai_chat_message.dart';

class AiConversationSummarizer {
  Future<String?> summarize({
    required List<AiChatMessage> messages,
    required String language,
  }) async {
    if (messages.length < 10) return null;

    final transcript = messages
        .where((m) => m.text.trim().isNotEmpty && !m.isStreaming)
        .map((m) => '${m.isUser ? 'User' : 'Assistant'}: ${m.text.trim()}')
        .join('\n');

    try {
      final token = await FirebaseAuth.instance.currentUser?.getIdToken();
      if (token == null) return null;

      final response = await http
          .post(
            Uri.parse('${AppConfig.backendUrl}/api/chat/summarize'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
            body: jsonEncode({
              'transcript': transcript,
              'language': language,
            }),
          )
          .timeout(const Duration(seconds: 25));

      if (response.statusCode != 200) return null;
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final summary = data['summary'] as String? ?? '';
      return summary.trim().isEmpty ? null : summary.trim();
    } catch (_) {
      return null;
    }
  }
}
