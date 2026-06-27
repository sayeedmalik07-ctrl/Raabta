import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:raabta/config/app_config.dart';
import 'package:raabta/data/qatar_labour_law_kb.dart';
import 'package:raabta/services/ai/user_profile_ai_service.dart';

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
  });

  final String message;
  final String language;
  final String context;
  final String requestType;
  final Map<String, dynamic> userProfile;

  Map<String, dynamic> toJson() => {
        'message': message,
        'language': language,
        'context': context,
        'requestType': requestType,
        'userProfile': userProfile,
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
  final Map<String, String> _responseCache = {};
  final Map<String, DateTime> _cacheTimestamps = {};
  final Map<String, DateTime> _lastRequestTime = {};

  bool _isCached(String cacheKey) {
    if (!_responseCache.containsKey(cacheKey)) return false;
    final age = DateTime.now().difference(_cacheTimestamps[cacheKey]!);
    return age.inMinutes < AppConfig.cacheExpiryMinutes;
  }

  String _generateCacheKey(String type, String message, String lang) {
    return '$type|$message|$lang'.hashCode.toString();
  }

  bool _isRateLimited(String requestType) {
    if (!_lastRequestTime.containsKey(requestType)) return false;
    return DateTime.now()
            .difference(_lastRequestTime[requestType]!)
            .inSeconds <
        5;
  }

  Future<AIResponse> _makeRequest(AIRequest request) async {
    final cacheKey = _generateCacheKey(
      request.requestType,
      request.message,
      request.language,
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
      await Future.delayed(const Duration(seconds: 5));
    }

    try {
      final response = await http
          .post(
            Uri.parse('${AppConfig.backendUrl}/api/chat'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(request.toJson()),
          )
          .timeout(Duration(seconds: AppConfig.aiRequestTimeout));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
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
      } else {
        return _getFallback(request.requestType);
      }
    } on TimeoutException {
      return _getFallback(request.requestType);
    } on SocketException {
      return _getFallback(request.requestType);
    } catch (_) {
      return _getFallback(request.requestType);
    }
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
  }) {
    final prompt =
        'Expat Life Score: ${score.total.toInt()}/100 (${score.level}). '
        'Career: ${score.career}/25, Housing: ${score.housing}/20, '
        'Financial: ${score.financial}/20, Community: ${score.community}/15, '
        'Health: ${score.health}/10, Documentation: ${score.documentation}/10. '
        'Give 1 specific action this person can do TODAY to improve score. '
        'Keep under 30 words. Respond in ${profile.language}.';

    return _makeRequest(
      AIRequest(
        message: prompt,
        language: profile.language,
        requestType: 'score_advice',
        userProfile: {'level': score.level, 'total': score.total},
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
  }) async {
    final isLabour =
        requestType == 'chat' && QatarLabourLawKB.isLabourQuery(message);
    final context = requestType == 'chat'
        ? QatarLabourLawKB.buildSystemPrompt(
            userLanguageCode: languageCode,
            isLabourQuery: isLabour,
          )
        : '';

    final response = await _makeRequest(
      AIRequest(
        message: message,
        language: language,
        context: context,
        requestType: requestType,
        userProfile: {},
      ),
    );
    return response.reply;
  }
}

// ─── RIVERPOD PROVIDER ───────────────────────────────────────
final claudeAIServiceProvider = Provider<ClaudeAIService>(
  (ref) => ClaudeAIService(),
);
