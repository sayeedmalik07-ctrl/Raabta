import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:raabta/config/app_config.dart';
import 'package:raabta/config/monetization_state.dart';
import 'package:raabta/data/raabta_ai_brain.dart';
import 'package:raabta/services/ai/ai_chat_stream_update.dart';
import 'package:raabta/services/ai/user_profile_ai_service.dart';
import 'package:raabta/services/auth/auth_session_service.dart';

// ---------------------------------------------------------------------------
// Models
// ---------------------------------------------------------------------------

class AIRequest {
  AIRequest({
    required this.message,
    required this.language,
    this.context = '',
    required this.requestType,
    required this.userProfile,
    this.userId,
    this.languageCode = 'en',
    this.conversationHistory = const [],
    this.researchMode = false,
  });

  final String message;
  final String language;
  final String context;
  final String requestType;
  final Map<String, dynamic> userProfile;
  final String? userId;
  final String languageCode;
  final List<Map<String, String>> conversationHistory;
  final bool researchMode;

  Map<String, dynamic> toJson() => {
        'message': message,
        'language': language,
        'languageCode': languageCode,
        'context': context,
        'requestType': requestType,
        'userProfile': userProfile,
        if (userId != null && userId!.isNotEmpty) 'userId': userId,
        if (conversationHistory.isNotEmpty)
          'conversationHistory': conversationHistory,
        if (researchMode) 'researchMode': true,
      };
}

class AIResponse {
  AIResponse({
    required this.success,
    required this.reply,
    required this.cached,
    required this.requestType,
  });

  final bool success;
  final String reply;
  final bool cached;
  final String requestType;

  factory AIResponse.fallback(String requestType, String fallbackText) {
    return AIResponse(
      success: false,
      reply: fallbackText,
      cached: false,
      requestType: requestType,
    );
  }
}

// ---------------------------------------------------------------------------
// Service
// ---------------------------------------------------------------------------

class ClaudeAIService {
  ClaudeAIService({this._authTokenProvider});

  final Future<String?> Function()? _authTokenProvider;
  final Map<String, String> _responseCache = {};
  final Map<String, DateTime> _cacheTimestamps = {};
  final Map<String, DateTime> _lastRequestTime = {};
  http.Client? _streamClient;

  static const mainChatRequestType = 'chat';
  static const maxHistoryTurns = 12;
  static const authenticationRequiredReply =
      'Sign in required to use Raabta AI chat.';

  /// Returned from [sendMessage] when `/api/chat` responds 429 for moderation AI cap.
  static const moderationHourlyLimitReply = '__RAABTA_MODERATION_HOURLY_LIMIT__';

  /// Returned when the server daily cap for community rewrite suggestions is hit.
  static const communityRephraseDailyLimitReply =
      '__RAABTA_COMMUNITY_REPHRASE_DAILY_LIMIT__';

  static const communityContentRephraseRequestType =
      'community_content_rephrase';

  static const _askQatarSimilarRankLimitError = 'ask_qatar_similar_rank_limit_exceeded';
  static const _communityModerationAiLimitError =
      'community_moderation_ai_limit_exceeded';
  static const _communityRephraseDailyLimitError =
      'community_rephrase_daily_limit_exceeded';

  void cancelActiveStream() {
    _streamClient?.close();
    _streamClient = null;
  }

  List<Map<String, String>> trimHistory(List<Map<String, String>> history) {
    if (history.length <= maxHistoryTurns) return history;
    return history.sublist(history.length - maxHistoryTurns);
  }

  AIRequest buildMainChatRequest({
    required String message,
    required String language,
    required String languageCode,
    required List<Map<String, String>> conversationHistory,
    Map<String, dynamic> userProfile = const {},
    String? userId,
    String? extraContext,
    String? rollingSummary,
    bool researchMode = false,
    String? userGreetingName,
    bool? isFirstAssistantTurn,
  }) {
    final firstTurn = isFirstAssistantTurn ??
        !conversationHistory.any((turn) => turn['role'] == 'assistant');

    var context = researchMode
        ? RaabtaAIBrain.buildResearchContext(
            message: message,
            userLanguageCode: languageCode,
          )
        : RaabtaAIBrain.buildChatContext(
            message: message,
            userLanguageCode: languageCode,
            userGreetingName: userGreetingName,
            isFirstAssistantTurn: firstTurn,
            conversationHistory: conversationHistory,
            rollingSummaryForSelection: rollingSummary,
          );
    if (rollingSummary != null && rollingSummary.trim().isNotEmpty) {
      context =
          '$context\n\nPrevious conversation summary:\n${rollingSummary.trim()}';
    }
    if (extraContext != null && extraContext.trim().isNotEmpty) {
      context = '$context\n\n$extraContext';
    }
    if (userProfile.isNotEmpty) {
      context =
          '$context\n\nUser profile snapshot: ${jsonEncode(userProfile)}';
    }
    return AIRequest(
      message: message,
      language: language,
      languageCode: languageCode,
      context: context,
      requestType: mainChatRequestType,
      userProfile: userProfile,
      userId: userId,
      conversationHistory: trimHistory(conversationHistory),
      researchMode: researchMode,
    );
  }

  Future<String?> _resolveAuthToken() async {
    final provider = _authTokenProvider;
    if (provider != null) {
      return provider();
    }
    return AuthSessionService.instance.getIdToken();
  }

  Future<Map<String, String>> _buildJsonAuthHeaders() async {
    final token = await _resolveAuthToken();
    final headers = <String, String>{'Content-Type': 'application/json'};
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  @visibleForTesting
  Future<Map<String, String>> buildChatAuthHeadersForTest() =>
      _buildJsonAuthHeaders();

  Future<AIResponse> sendMainChat(AIRequest request) async {
    final cacheKey = _generateCacheKey(
      request.requestType,
      '${request.message}|${request.conversationHistory.length}',
      request.language,
      userId: request.userId,
    );

    if (_isCached(cacheKey)) {
      return AIResponse(
        success: true,
        reply: _responseCache[cacheKey]!,
        cached: true,
        requestType: request.requestType,
      );
    }

    if (_isRateLimited(request.requestType)) {
      await Future.delayed(const Duration(seconds: 2));
    }

    try {
      final headers = await _buildJsonAuthHeaders();
      final response = await http
          .post(
            Uri.parse('${AppConfig.backendUrl}/api/chat'),
            headers: headers,
            body: jsonEncode(request.toJson()),
          )
          .timeout(Duration(seconds: AppConfig.aiRequestTimeout));

      if (response.statusCode == 401) {
        return AIResponse.fallback(
          request.requestType,
          authenticationRequiredReply,
        );
      }

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        final reply = data['reply'] as String? ?? '';
        _responseCache[cacheKey] = reply;
        _cacheTimestamps[cacheKey] = DateTime.now();
        _lastRequestTime[request.requestType] = DateTime.now();
        return AIResponse(
          success: true,
          reply: reply,
          cached: false,
          requestType: request.requestType,
        );
      }

      if (RaabtaAIBrain.isBackendUnavailable(response.statusCode, data)) {
        return AIResponse(
          success: false,
          reply: RaabtaAIBrain.buildOfflineFallbackReply(
            message: request.message,
            userLanguageCode: request.languageCode,
          ),
          cached: false,
          requestType: request.requestType,
        );
      }

      return _getFallback(request.requestType);
    } on TimeoutException {
      return AIResponse.fallback(
        request.requestType,
        RaabtaAIBrain.buildOfflineFallbackReply(
          message: request.message,
          userLanguageCode: request.languageCode,
        ),
      );
    } on SocketException {
      return AIResponse.fallback(
        request.requestType,
        RaabtaAIBrain.buildOfflineFallbackReply(
          message: request.message,
          userLanguageCode: request.languageCode,
        ),
      );
    } catch (_) {
      return _getFallback(request.requestType);
    }
  }

  Stream<AiChatStreamUpdate> streamMainChat(AIRequest request) async* {
    final cacheKey = _generateCacheKey(
      request.requestType,
      '${request.message}|${request.conversationHistory.length}',
      request.language,
      userId: request.userId,
    );

    if (_isCached(cacheKey)) {
      yield AiChatStreamUpdate(textDelta: _responseCache[cacheKey]!);
      return;
    }

    if (_isRateLimited(request.requestType)) {
      await Future.delayed(const Duration(seconds: 2));
    }

    _streamClient?.close();
    _streamClient = http.Client();
    final client = _streamClient!;

    try {
      final httpRequest = http.Request(
        'POST',
        Uri.parse('${AppConfig.backendUrl}/api/chat/stream'),
      );
      final headers = await _buildJsonAuthHeaders();
      httpRequest.headers.addAll(headers);
      httpRequest.body = jsonEncode(request.toJson());

      final response = await client.send(httpRequest);
      if (response.statusCode == 401) {
        yield AiChatStreamUpdate(error: authenticationRequiredReply);
        return;
      }
      if (response.statusCode == 429) {
        final body = await response.stream.bytesToString();
        String message = MonetizationState.isHold ||
                !MonetizationState.showPremiumTierUi
            ? 'You have reached your daily Raabta AI limit. Try again tomorrow.'
            : 'You have reached your daily Raabta AI limit. Upgrade to Premium for more.';
        try {
          final json = jsonDecode(body) as Map<String, dynamic>;
          message = json['message'] as String? ?? message;
        } catch (_) {}
        yield AiChatStreamUpdate(error: message);
        return;
      }
      if (response.statusCode != 200) {
        yield AiChatStreamUpdate(
          textDelta: RaabtaAIBrain.buildOfflineFallbackReply(
            message: request.message,
            userLanguageCode: request.languageCode,
          ),
        );
        return;
      }

      final buffer = StringBuffer();
      await for (final chunk
          in response.stream.transform(utf8.decoder).transform(const LineSplitter())) {
        if (chunk.startsWith('data: ')) {
          final payload = chunk.substring(6).trim();
          if (payload == '[DONE]') break;
          try {
            final json = jsonDecode(payload) as Map<String, dynamic>;
            if (json['type'] == 'meta') {
              yield AiChatStreamUpdate(
                meta: AiChatStreamMeta(
                  model: json['model'] as String?,
                  modelTier: json['modelTier'] as String?,
                  dailyRemaining: json['remaining'] as int?,
                  dailyLimit: json['limit'] as int?,
                  isPremium: json['isPremium'] as bool? ?? false,
                ),
              );
              continue;
            }
            if (json['error'] != null) {
              yield AiChatStreamUpdate(error: json['error'].toString());
              continue;
            }
            final text = json['text'] as String? ?? '';
            if (text.isNotEmpty) {
              buffer.write(text);
              yield AiChatStreamUpdate(textDelta: text);
            }
          } catch (_) {}
        }
      }

      final full = buffer.toString();
      if (full.isNotEmpty) {
        _responseCache[cacheKey] = full;
        _cacheTimestamps[cacheKey] = DateTime.now();
        _lastRequestTime[request.requestType] = DateTime.now();
      }
    } catch (_) {
      yield AiChatStreamUpdate(
        textDelta: RaabtaAIBrain.buildOfflineFallbackReply(
          message: request.message,
          userLanguageCode: request.languageCode,
        ),
      );
    } finally {
      client.close();
      if (_streamClient == client) _streamClient = null;
    }
  }

  bool _isCached(String cacheKey) {
    if (!_responseCache.containsKey(cacheKey)) return false;
    final age = DateTime.now().difference(_cacheTimestamps[cacheKey]!);
    return age.inMinutes < AppConfig.cacheExpiryMinutes;
  }

  @visibleForTesting
  String generateCacheKeyForTest(
    String type,
    String message,
    String lang, {
    String? userId,
  }) {
    return _generateCacheKey(type, message, lang, userId: userId);
  }

  @visibleForTesting
  void seedResponseCacheForTest(String cacheKey, String reply) {
    _responseCache[cacheKey] = reply;
    _cacheTimestamps[cacheKey] = DateTime.now();
  }

  @visibleForTesting
  bool isResponseCachedForTest(String cacheKey) => _isCached(cacheKey);

  String _generateCacheKey(
    String type,
    String message,
    String lang, {
    String? userId,
  }) {
    final uid = userId?.trim() ?? '';
    return '$type|$uid|$message|$lang'.hashCode.toString();
  }

  bool _isRateLimited(String requestType) {
    if (!_lastRequestTime.containsKey(requestType)) return false;
    return DateTime.now()
            .difference(_lastRequestTime[requestType]!)
            .inSeconds <
        5;
  }

  Future<AIResponse> _makeRequest(AIRequest request) async {
    final skipResponseCache =
        request.requestType == communityContentRephraseRequestType;
    final cacheKey = _generateCacheKey(
      request.requestType,
      request.message,
      request.language,
      userId: request.userId,
    );

    if (!skipResponseCache && _isCached(cacheKey)) {
      return AIResponse(
        success: true,
        reply: _responseCache[cacheKey]!,
        cached: true,
        requestType: request.requestType,
      );
    }

    if (_isRateLimited(request.requestType)) {
      await Future.delayed(const Duration(seconds: 5));
    }

    try {
      final headers = await _buildJsonAuthHeaders();
      final response = await http
          .post(
            Uri.parse('${AppConfig.backendUrl}/api/chat'),
            headers: headers,
            body: jsonEncode(request.toJson()),
          )
          .timeout(Duration(seconds: AppConfig.aiRequestTimeout));

      if (response.statusCode == 401) {
        return AIResponse.fallback(
          request.requestType,
          authenticationRequiredReply,
        );
      }

      if (response.statusCode == 429) {
        final rateLimitReply = _replyForHourlyQuota429(
          request.requestType,
          response.body,
        );
        if (rateLimitReply != null) {
          return AIResponse(
            success: false,
            reply: rateLimitReply,
            cached: false,
            requestType: request.requestType,
          );
        }
      }

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final reply = data['reply'] as String? ?? '';
        if (!skipResponseCache) {
          _responseCache[cacheKey] = reply;
          _cacheTimestamps[cacheKey] = DateTime.now();
        }
        _lastRequestTime[request.requestType] = DateTime.now();
        return AIResponse(
          success: true,
          reply: reply,
          cached: false,
          requestType: request.requestType,
        );
      } else {
        return _getFallback(request.requestType);
      }
    } on TimeoutException {
      if (request.requestType == communityContentRephraseRequestType) {
        return AIResponse.fallback(request.requestType, '');
      }
      return _getFallback(request.requestType);
    } on SocketException {
      if (request.requestType == communityContentRephraseRequestType) {
        return AIResponse.fallback(request.requestType, '');
      }
      return _getFallback(request.requestType);
    } catch (_) {
      if (request.requestType == communityContentRephraseRequestType) {
        return AIResponse.fallback(request.requestType, '');
      }
      return _getFallback(request.requestType);
    }
  }

  String? _replyForHourlyQuota429(String requestType, String body) {
    try {
      final data = jsonDecode(body) as Map<String, dynamic>;
      final error = data['error'] as String?;
      if (requestType == 'ask_qatar_similar_question_rank' &&
          error == _askQatarSimilarRankLimitError) {
        return '';
      }
      if (requestType == 'community_content_moderation' &&
          error == _communityModerationAiLimitError) {
        return moderationHourlyLimitReply;
      }
      if (requestType == communityContentRephraseRequestType &&
          error == _communityRephraseDailyLimitError) {
        return communityRephraseDailyLimitReply;
      }
    } catch (_) {}
    return null;
  }

  AIResponse _getFallback(String requestType) {
    const fallbacks = {
      'job_explain':
          'Based on your profile, this role aligns with your experience and skills.',
      'housing_explain':
          'This property matches your location and budget preferences.',
      'score_advice':
          'Complete your profile to improve your Expat Life Score.',
      'feed_generate':
          'AI insights are being personalized for you.',
      'chat':
          'I am here to help with any Qatar expat question. Please try again.',
    };
    return AIResponse.fallback(
      requestType,
      fallbacks[requestType] ?? 'Please try again.',
    );
  }

  // ─── FUNCTION 1: JOB EXPLANATION ────────────────────────
  Future<AIResponse> generateJobExplanation({
    required Map<String, dynamic> jobData,
    required int matchScore,
    required UserAIProfile profile,
  }) {
    final prompt =
        'User is a ${profile.profession} with ${profile.yearsExperience} '
        'years experience and skills: ${profile.skills.join(", ")}. '
        'They are viewing a job for ${jobData["title"]} at '
        '${jobData["company"]} with ${jobData["salary"]} salary. '
        'AI match score is $matchScore%. '
        'In 2 sentences, explain why this is or is not a good match. '
        'Be specific. Respond in ${profile.language}.';

    return _makeRequest(
      AIRequest(
        message: prompt,
        language: profile.language,
        requestType: 'job_explain',
        userProfile: {
          'profession': profile.profession,
          'skills': profile.skills,
          'experience': profile.yearsExperience,
        },
      ),
    );
  }

  // ─── FUNCTION 2: HOUSING EXPLANATION ────────────────────
  Future<AIResponse> generateHousingExplanation({
    required Map<String, dynamic> listing,
    required int matchScore,
    required UserAIProfile profile,
  }) {
    final prompt =
        'User prefers ${profile.preferredArea}, '
        'budget ${profile.budgetRange["min"]}-${profile.budgetRange["max"]} QR, '
        'family status: ${profile.familyStatus}. '
        'Listing is ${listing["type"]} in ${listing["area"]} '
        'at ${listing["price"]} QR/month. Match: $matchScore%. '
        'In 2 sentences explain the match. Respond in ${profile.language}.';

    return _makeRequest(
      AIRequest(
        message: prompt,
        language: profile.language,
        requestType: 'housing_explain',
        userProfile: {
          'preferredArea': profile.preferredArea,
          'budgetRange': profile.budgetRange,
          'familyStatus': profile.familyStatus,
        },
      ),
    );
  }

  // ─── FUNCTION 3: LIFE SCORE ADVICE ──────────────────────
  Future<AIResponse> generateLifeScoreAdvice({
    required ExpatLifeScore score,
    required UserAIProfile profile,
    String? userId,
  }) {
    final prompt =
        'Expat Life Score: ${score.total.toInt()}/100 (${score.level}). '
        'Career: ${score.career}/25, Housing: ${score.housing}/20, '
        'Financial: ${score.financial}/20, Community: ${score.community}/15, '
        'Health: ${score.health}/10, Documentation: ${score.documentation}/10. '
        'Profession: ${profile.profession.isEmpty ? "not set" : profile.profession}. '
        'Nationality: ${profile.nationality.isEmpty ? "not set" : profile.nationality}. '
        'Area: ${profile.preferredArea.isEmpty ? "not set" : profile.preferredArea}. '
        'Give 1 specific action this person can do TODAY to improve score. '
        'Keep under 30 words. Respond in ${profile.language}.';

    return _makeRequest(
      AIRequest(
        message: prompt,
        language: profile.language,
        requestType: 'score_advice',
        userId: userId ?? profile.uid,
        userProfile: {
          'level': score.level,
          'total': score.total,
          'uid': profile.uid,
        },
      ),
    );
  }

  Future<AIResponse> generateLifeScoreRecommendations({
    required ExpatLifeScore score,
    required UserAIProfile profile,
    String? userId,
  }) {
    final prompt =
        'Expat Life Score: ${score.total.toInt()}/100 (${score.level}). '
        'Career: ${score.career}/25, Housing: ${score.housing}/20, '
        'Financial: ${score.financial}/20, Community: ${score.community}/15, '
        'Documentation: ${score.documentation}/10. '
        'Profession: ${profile.profession.isEmpty ? "not set" : profile.profession}. '
        'Give exactly 3 specific actions to improve the lowest categories. '
        'One action per line in this format: ACTION | +N pts | DURATION. '
        'Respond in ${profile.language}.';

    return _makeRequest(
      AIRequest(
        message: prompt,
        language: profile.language,
        requestType: 'score_recommendations',
        userId: userId ?? profile.uid,
        userProfile: {
          'level': score.level,
          'total': score.total,
          'uid': profile.uid,
        },
      ),
    );
  }

  // ─── FUNCTION 4: FEED INSIGHT ────────────────────────────
  Future<AIResponse> generateFeedInsight({
    required String insightType,
    required Map<String, dynamic> data,
    required String language,
  }) {
    String prompt = '';
    switch (insightType) {
      case 'exchange_rate':
        prompt =
            'Qatar Riyal to ${data["currency"]} rate is ${data["rate"]} today, '
            'changed by ${data["change"]} from yesterday. '
            'In 1 sentence tell the user if this is a good time to transfer. '
            'Respond in $language.';
      case 'job_market':
        prompt =
            'There are ${data["count"]} new jobs matching the user profile today. '
            'Top category: ${data["topCategory"]}. '
            'In 1 sentence summarize the opportunity. Respond in $language.';
      case 'housing_alert':
        prompt =
            '${data["count"]} new listings appeared in ${data["area"]} today. '
            'Price range: ${data["minPrice"]}-${data["maxPrice"]} QR/month. '
            'In 1 sentence highlight the best opportunity. Respond in $language.';
    }

    return _makeRequest(
      AIRequest(
        message: prompt,
        language: language,
        requestType: 'feed_generate',
        userProfile: {},
      ),
    );
  }

  // ─── FUNCTION 5: SMART SEARCH EXPLANATION ───────────────
  Future<AIResponse> generateSmartSearchExplanation({
    required String originalQuery,
    required int resultCount,
    required String intent,
    required String language,
  }) {
    final prompt =
        'User searched: "$originalQuery". '
        'Intent detected: $intent. Results found: $resultCount. '
        'In 1 sentence tell the user what was found. Respond in $language.';

    return _makeRequest(
      AIRequest(
        message: prompt,
        language: language,
        requestType: 'chat',
        userProfile: {},
      ),
    );
  }

  void clearCache() {
    _responseCache.clear();
    _cacheTimestamps.clear();
  }

  /// Generic chat-style prompt — used by Food Inspector and other features.
  Future<String> sendMessage(
    String message, {
    String language = 'English',
    String requestType = 'chat',
    String languageCode = 'en',
    List<Map<String, String>> conversationHistory = const [],
    String? userId,
    Map<String, dynamic> userProfile = const {},
  }) async {
    if (requestType == 'chat') {
      final request = buildMainChatRequest(
        message: message,
        language: language,
        languageCode: languageCode,
        conversationHistory: conversationHistory,
        userProfile: userProfile,
        userId: userId,
      );
      final response = await sendMainChat(request);
      return response.reply;
    }

    final response = await _makeRequest(
      AIRequest(
        message: message,
        language: language,
        languageCode: languageCode,
        requestType: requestType,
        userProfile: userProfile,
        userId: userId,
      ),
    );
    return response.reply;
  }
}

// ─── RIVERPOD PROVIDER ───────────────────────────────────────
final claudeAIServiceProvider = Provider<ClaudeAIService>(
  (ref) => ClaudeAIService(),
);
