import 'package:raabta/data/raabta_ai_brain.dart';
import 'package:raabta/features/global_search/domain/search_ai_privacy_sanitizer.dart';
import 'package:raabta/features/global_search/domain/search_ask_ai_request.dart';
import 'package:raabta/features/global_search/domain/search_ask_ai_response.dart';
import 'package:raabta/features/global_search/domain/search_ask_ai_response_validator.dart';
import 'package:raabta/services/ai/claude_ai_service.dart';

/// AI ASK adapter for Global Search — isolated from UI (S9).
class SearchAskAiService {
  SearchAskAiService(this._claude);

  final ClaudeAIService _claude;

  static const requestType = 'global_search_ask';
  static const cooldownSeconds = 5;

  String? _lastRequestKey;
  DateTime? _lastRequestAt;
  bool _inFlight = false;

  bool get isInFlight => _inFlight;

  Future<SearchAskAiResponse> ask({
    required SearchAskAiRequest request,
    required String locale,
    required String languageCode,
    String? userId,
    Map<String, dynamic> userProfile = const {},
  }) async {
    final sanitized = SearchAiPrivacySanitizer.sanitize(request.originalQuery);
    if (sanitized == null || sanitized.isEmpty) {
      return const SearchAskAiResponse(
        answer: '',
        errorMessage: 'blocked_query',
      );
    }

    if (_isDuplicateRequest(sanitized)) {
      return const SearchAskAiResponse(
        answer: '',
        errorMessage: 'duplicate_request',
      );
    }

    if (_inFlight) {
      return const SearchAskAiResponse(
        answer: '',
        errorMessage: 'request_in_progress',
      );
    }

    _inFlight = true;
    _lastRequestKey = sanitized.toLowerCase();
    _lastRequestAt = DateTime.now();

    try {
      final context = _buildContext(request, sanitized);
      final aiRequest = _claude.buildMainChatRequest(
        message: sanitized,
        language: locale,
        languageCode: languageCode,
        conversationHistory: const [],
        userProfile: userProfile,
        userId: userId,
        extraContext: context,
      );

      final response = await _claude.sendMainChat(
        AIRequest(
          message: sanitized,
          language: locale,
          languageCode: languageCode,
          context: aiRequest.context,
          requestType: requestType,
          userProfile: userProfile,
          userId: userId,
        ),
      );

      if (!response.success && response.reply.trim().isEmpty) {
        return SearchAskAiResponseValidator.validate(
          rawAnswer: '',
          errorMessage: 'network_error',
          fromFallback: true,
        );
      }

      return SearchAskAiResponseValidator.validate(
        rawAnswer: response.reply,
        fromFallback: !response.success,
      );
    } catch (_) {
      return SearchAskAiResponseValidator.validate(
        rawAnswer: RaabtaAIBrain.buildOfflineFallbackReply(
          message: sanitized,
          userLanguageCode: languageCode,
        ),
        fromFallback: true,
      );
    } finally {
      _inFlight = false;
    }
  }

  bool _isDuplicateRequest(String sanitized) {
    if (_lastRequestKey == null || _lastRequestAt == null) return false;
    if (_lastRequestKey != sanitized.toLowerCase()) return false;
    return DateTime.now().difference(_lastRequestAt!).inSeconds <
        cooldownSeconds;
  }

  static String _buildContext(SearchAskAiRequest request, String sanitized) {
    final buffer = StringBuffer(
      'The user searched in RAABTA Global Search. '
      'Provide a concise, practical answer about life in Qatar. '
      'Do not invent legal advice. '
      'When a Raabta feature genuinely helps, you may suggest in-app navigation using '
      '[[action:/route-path|Short button label]] markers (max 2), matching main AI chat rules. '
      'Do not return raw external URLs.\n',
    );
    buffer.writeln('Normalized query: $sanitized');
    buffer.writeln('Detected language: ${request.detectedLanguage}');
    buffer.writeln('Intent hint: ${request.intent.name}');
    buffer.writeln('Confidence: ${request.confidence.toStringAsFixed(2)}');
    if (request.area != null) buffer.writeln('Area: ${request.area}');
    if (request.nearMe) buffer.writeln('Near-me context: yes');
    if (request.visaTopic != null) {
      buffer.writeln('Visa topic: ${request.visaTopic}');
    }
    return buffer.toString();
  }

  /// Test-only reset.
  void resetForTests() {
    _lastRequestKey = null;
    _lastRequestAt = null;
    _inFlight = false;
  }
}
