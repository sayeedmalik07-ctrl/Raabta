import 'package:raabta/features/global_search/domain/global_search_models.dart';
import 'package:raabta/features/global_search/domain/search_analysis.dart';
import 'package:raabta/services/ai/smart_search_service.dart';

/// Why ASK AI was or was not offered (S9).
enum SearchAskAiEligibilityReason {
  eligibleUnknownIntent,
  eligibleWeakResults,
  eligibleInformationalQuery,
  eligibleGenericHubsOnly,
  eligibleVisaCommunityQuestion,
  suppressedOffline,
  suppressedDeterministicActions,
  suppressedStrongBestMatch,
  suppressedStrongFindResults,
  suppressedNavigationalIntent,
  suppressedExactMatch,
  suppressedQueryTooShort,
  suppressedSensitiveQuery,
}

/// Deterministic eligibility decision for ASK AI fallback (S9).
class SearchAskAiEligibility {
  const SearchAskAiEligibility({
    required this.isEligible,
    required this.reason,
  });

  final bool isEligible;
  final SearchAskAiEligibilityReason reason;

  static const unknownConfidenceThreshold = 0.45;
  static const strongBestMatchThreshold = 55.0;
  static const strongFindScoreThreshold = 70;
  static const weakFindScoreThreshold = 40;

  static const _navigationalIntents = {
    SearchIntent.findJob,
    SearchIntent.findHousing,
    SearchIntent.findBusiness,
    SearchIntent.findService,
    SearchIntent.findDoctor,
    SearchIntent.checkRate,
    SearchIntent.verifyEmployer,
    SearchIntent.verifyAgency,
    SearchIntent.scanDocument,
    SearchIntent.eosbCalculator,
    SearchIntent.prayerMosque,
    SearchIntent.tripPlanner,
  };

  static const _informationalIntents = {
    SearchIntent.visaQuestion,
    SearchIntent.communityQuestion,
    SearchIntent.unknown,
  };

  static SearchAskAiEligibility evaluate({
    required SearchAnalysis analysis,
    required GlobalSearchResponse response,
    required bool isOnline,
    required bool isSensitiveQuery,
    int minQueryLength = 2,
  }) {
    final query = analysis.originalQuery.trim();
    if (query.length < minQueryLength) {
      return const SearchAskAiEligibility(
        isEligible: false,
        reason: SearchAskAiEligibilityReason.suppressedQueryTooShort,
      );
    }

    if (isSensitiveQuery) {
      return const SearchAskAiEligibility(
        isEligible: false,
        reason: SearchAskAiEligibilityReason.suppressedSensitiveQuery,
      );
    }

    if (!isOnline || response.offline) {
      return const SearchAskAiEligibility(
        isEligible: false,
        reason: SearchAskAiEligibilityReason.suppressedOffline,
      );
    }

    if (response.actions.isNotEmpty) {
      return const SearchAskAiEligibility(
        isEligible: false,
        reason: SearchAskAiEligibilityReason.suppressedDeterministicActions,
      );
    }

    if (response.bestMatch != null &&
        response.bestMatch!.score >= strongBestMatchThreshold) {
      return const SearchAskAiEligibility(
        isEligible: false,
        reason: SearchAskAiEligibilityReason.suppressedStrongBestMatch,
      );
    }

    if (_hasExactTitleMatch(analysis, response)) {
      return const SearchAskAiEligibility(
        isEligible: false,
        reason: SearchAskAiEligibilityReason.suppressedExactMatch,
      );
    }

    final topFindScore = _topFindScore(response);

    if (isInformationalQuery(query) &&
        (response.isEmpty || topFindScore < weakFindScoreThreshold)) {
      return SearchAskAiEligibility(
        isEligible: true,
        reason: analysis.intent == SearchIntent.unknown
            ? SearchAskAiEligibilityReason.eligibleInformationalQuery
            : SearchAskAiEligibilityReason.eligibleVisaCommunityQuestion,
      );
    }

    if (topFindScore >= strongFindScoreThreshold) {
      return const SearchAskAiEligibility(
        isEligible: false,
        reason: SearchAskAiEligibilityReason.suppressedStrongFindResults,
      );
    }

    if (_navigationalIntents.contains(analysis.intent) &&
        analysis.confidence >= 0.55) {
      return const SearchAskAiEligibility(
        isEligible: false,
        reason: SearchAskAiEligibilityReason.suppressedNavigationalIntent,
      );
    }

    if (analysis.intent == SearchIntent.unknown &&
        analysis.confidence < unknownConfidenceThreshold) {
      return const SearchAskAiEligibility(
        isEligible: true,
        reason: SearchAskAiEligibilityReason.eligibleUnknownIntent,
      );
    }

    if (_informationalIntents.contains(analysis.intent) &&
        isInformationalQuery(query)) {
      return SearchAskAiEligibility(
        isEligible: true,
        reason: analysis.intent == SearchIntent.unknown
            ? SearchAskAiEligibilityReason.eligibleInformationalQuery
            : SearchAskAiEligibilityReason.eligibleVisaCommunityQuestion,
      );
    }

    if (isInformationalQuery(query) && topFindScore < weakFindScoreThreshold) {
      return const SearchAskAiEligibility(
        isEligible: true,
        reason: SearchAskAiEligibilityReason.eligibleInformationalQuery,
      );
    }

    if (response.isEmpty) {
      return const SearchAskAiEligibility(
        isEligible: true,
        reason: SearchAskAiEligibilityReason.eligibleWeakResults,
      );
    }

    if (_onlyGenericHubs(response) && topFindScore < weakFindScoreThreshold) {
      return const SearchAskAiEligibility(
        isEligible: true,
        reason: SearchAskAiEligibilityReason.eligibleGenericHubsOnly,
      );
    }

    if (topFindScore < weakFindScoreThreshold &&
        _countUsefulFindResults(response) <= 1) {
      return const SearchAskAiEligibility(
        isEligible: true,
        reason: SearchAskAiEligibilityReason.eligibleWeakResults,
      );
    }

    return const SearchAskAiEligibility(
      isEligible: false,
      reason: SearchAskAiEligibilityReason.suppressedStrongFindResults,
    );
  }

  static bool isInformationalQuery(String query) {
    final lower = query.toLowerCase().trim();
    if (lower.contains('?') || query.contains('؟')) return true;
    const starters = [
      'how ',
      'what ',
      'why ',
      'when ',
      'where ',
      'is ',
      'are ',
      'should ',
      'can i ',
      'do i ',
      'does ',
      'tell me ',
      'explain ',
      'kya ',
      'kaise ',
      'kyun ',
      'kya ',
      'كيف ',
      'ما ',
      'هل ',
      'لماذا ',
      'کیا ',
      'کیسے ',
      'کیوں ',
    ];
    if (starters.any(lower.startsWith)) return true;
    if (starters.any((s) => lower.contains(' $s'))) return true;
    if (starters.any((s) => query.contains(s.trim()))) return true;
    return false;
  }

  static int _topFindScore(GlobalSearchResponse response) {
    var top = 0;
    for (final group in response.groups) {
      if (group.failed || group.items.isEmpty) continue;
      for (final item in group.items) {
        if (item.isAction) continue;
        if (item.score > top) top = item.score;
      }
    }
    return top;
  }

  static int _countUsefulFindResults(GlobalSearchResponse response) {
    var count = 0;
    for (final group in response.groups) {
      if (group.failed) continue;
      for (final item in group.items) {
        if (!item.isAction && item.score >= weakFindScoreThreshold) {
          count++;
        }
      }
    }
    return count;
  }

  static bool _hasExactTitleMatch(
    SearchAnalysis analysis,
    GlobalSearchResponse response,
  ) {
    final tokens = analysis.normalizedQuery
        .split(RegExp(r'\s+'))
        .where((t) => t.length >= 3)
        .toSet();
    if (tokens.isEmpty) return false;

    for (final group in response.groups) {
      for (final item in group.items) {
        if (item.isAction) continue;
        final titleLower = item.title.toLowerCase();
        if (tokens.every(titleLower.contains)) return true;
      }
    }
    return false;
  }

  static bool _onlyGenericHubs(GlobalSearchResponse response) {
    final visible = response.groups
        .where((g) => !g.failed && g.items.isNotEmpty)
        .toList();
    if (visible.isEmpty) return false;

    return visible.every((group) {
      return group.items.every((item) {
        final subtitle = item.subtitle.toLowerCase();
        return subtitle.contains('browse') ||
            subtitle.contains('hub') ||
            subtitle.contains('see all') ||
            item.score < weakFindScoreThreshold;
      });
    });
  }
}
