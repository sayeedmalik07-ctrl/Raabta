import 'package:raabta/core/search/search_keyword_tokenizer.dart';
import 'package:raabta/features/global_search/domain/global_search_models.dart';
import 'package:raabta/features/global_search/domain/intent_relevance_boost.dart';
import 'package:raabta/features/global_search/domain/search_analysis.dart';
import 'package:raabta/features/global_search/domain/search_best_match.dart';
import 'package:raabta/features/global_search/domain/search_location_context.dart';
import 'package:raabta/features/global_search/domain/search_personalization_context.dart';
import 'package:raabta/features/global_search/domain/search_semantic_config.dart';
import 'package:raabta/features/global_search/domain/search_hybrid_ranker.dart';
import 'package:raabta/features/global_search/domain/search_personalization_ranker.dart';
import 'package:raabta/features/global_search/domain/search_proximity_ranker.dart';
import 'package:raabta/services/ai/smart_search_service.dart';

/// Deterministic BEST MATCH selection over merged FIND results (S5).
abstract final class SearchBestMatchRanker {
  static const confidenceThreshold = 0.55;
  static const maxBonus = 25;
  static const minRankingScore = 45;
  static const exactMatchUnknownIntentMinBonus = 15;

  static SearchBestMatch? rank({
    required SearchAnalysis analysis,
    required List<GlobalSearchResultItem> findResults,
    SearchLocationContext? location,
    SearchPersonalizationContext? personalization,
  }) {
    if (findResults.isEmpty) return null;

    SearchBestMatch? best;
    for (final item in findResults) {
      if (!_isEligible(item)) continue;

      final scored = _scoreCandidate(
        item,
        analysis,
        location,
        personalization,
      );
      if (scored == null) continue;

      if (best == null ||
          scored.rankingScore > best.score ||
          (scored.rankingScore == best.score &&
              _prefersCandidate(
                scored,
                best,
                item,
                best.result,
                analysis,
                location,
              ))) {
        final distanceMeters = item.distanceMeters ??
            (analysis.nearMe && location != null
                ? SearchProximityRanker.distanceMetersForItem(
                    item: item,
                    location: location,
                  )
                : null);
        best = SearchBestMatch(
          result: item,
          score: scored.rankingScore.toDouble(),
          reasonKey: scored.reasonKey,
          source: scored.source,
          distanceMeters: distanceMeters,
        );
      }
    }

    return best;
  }

  static bool _prefersCandidate(
    _CandidateScore candidate,
    SearchBestMatch current,
    GlobalSearchResultItem candidateItem,
    GlobalSearchResultItem currentItem,
    SearchAnalysis analysis,
    SearchLocationContext? location,
  ) {
    if (analysis.nearMe && location != null) {
      final candidateDist = candidateItem.distanceMeters;
      final currentDist = currentItem.distanceMeters;
      if (candidateDist != null && currentDist != null &&
          candidateDist != currentDist) {
        return candidateDist < currentDist;
      }
      if (candidateDist != null && currentDist == null) return true;
      if (candidateDist == null && currentDist != null) return false;
    }

    final area = analysis.area?.trim().toLowerCase();
    if (area != null && area.isNotEmpty) {
      final candidateHasArea =
          '${candidateItem.title} ${candidateItem.subtitle}'.toLowerCase().contains(area);
      final currentHasArea =
          '${currentItem.title} ${currentItem.subtitle}'.toLowerCase().contains(area);
      if (candidateHasArea != currentHasArea) {
        return candidateHasArea;
      }
    }

    int sourceRank(SearchBestMatchSource source) => switch (source) {
          SearchBestMatchSource.exactMatch => 4,
          SearchBestMatchSource.serviceListing => 3,
          SearchBestMatchSource.intent => 2,
          SearchBestMatchSource.relevance => 1,
          SearchBestMatchSource.destination => 0,
        };

    final candidateRank = sourceRank(candidate.source);
    final currentRank = sourceRank(current.source);
    if (candidateRank != currentRank) {
      return candidateRank > currentRank;
    }

    if (_isLiveServiceListing(candidateItem) &&
        _isGenericHub(currentItem)) {
      return true;
    }

    return false;
  }

  static bool _isEligible(GlobalSearchResultItem item) {
    if (item.isAction) return false;
    if (item.resultKind == GlobalSearchResultKind.savedItem) return false;
    if (item.title.trim().isEmpty) return false;
    if (item.routePath.trim().isEmpty) return false;
    return true;
  }

  static _CandidateScore? _scoreCandidate(
    GlobalSearchResultItem item,
    SearchAnalysis analysis,
    SearchLocationContext? location,
    SearchPersonalizationContext? personalization,
  ) {
    var bonus = 0;
    var source = SearchBestMatchSource.relevance;

    final exactBonus = _exactMatchBonus(item, analysis);
    bonus += exactBonus;
    if (exactBonus >= 15) {
      source = SearchBestMatchSource.exactMatch;
    }

    bonus += _areaBonus(item, analysis);
    bonus += _filterBonus(item, analysis);

    if (_isLiveServiceListing(item)) {
      final listingBonus =
          analysis.intent == SearchIntent.findService ? 18 : 4;
      bonus += listingBonus;
      if (listingBonus >= 18) {
        source = SearchBestMatchSource.serviceListing;
      }
    } else if (_isGenericHub(item)) {
      final hubPenalty =
          analysis.intent == SearchIntent.findService ? 12 : 6;
      bonus -= hubPenalty;
      source = SearchBestMatchSource.destination;
    }

    if (IntentRelevanceBoost.forCategory(item.category, analysis) > 0) {
      bonus += 10;
      if (source == SearchBestMatchSource.relevance) {
        source = SearchBestMatchSource.intent;
      }
    } else if (_isCrossIntentMismatch(item, analysis)) {
      bonus -= 10;
    }

    bonus = bonus.clamp(-10, maxBonus);

    var proximityBonus = 0;
    if (analysis.nearMe && location != null) {
      proximityBonus = SearchProximityRanker.proximityBonusForItem(
        item: item,
        location: location,
      );
    }

    if (!_passesConfidenceGate(analysis, exactBonus)) return null;

    var personalizationBonus = 0;
    var usedExplicitPreference = false;
    if (personalization != null && personalization.enabled) {
      final personalizationScore = SearchPersonalizationRanker.score(
        item: item,
        analysis: analysis,
        context: personalization,
      );
      personalizationBonus = personalizationScore.bonus;
      usedExplicitPreference = personalizationScore.usedExplicitPreference;
    }

    final semanticBonus = SearchHybridRanker.semanticBonusForRanking(
      semanticSimilarity: item.semanticSimilarity,
      maxSemanticBonus: SearchSemanticConfig.production.maxSemanticBonus,
      item: item,
      analysis: analysis,
    );

    final rankingScore =
        item.score + bonus + proximityBonus + personalizationBonus + semanticBonus;
    if (rankingScore < minRankingScore) return null;

    var reasonKey = _reasonKeyFor(item, analysis, proximityBonus > 0);
    if (usedExplicitPreference && personalizationBonus >= 4) {
      reasonKey = 'global_search_best_match_preferences';
    }

    return _CandidateScore(
      rankingScore: rankingScore,
      reasonKey: reasonKey,
      source: source,
    );
  }

  static bool _passesConfidenceGate(SearchAnalysis analysis, int exactBonus) {
    if (analysis.intent != SearchIntent.unknown &&
        analysis.confidence >= confidenceThreshold) {
      return true;
    }
    if (analysis.intent == SearchIntent.unknown &&
        exactBonus >= exactMatchUnknownIntentMinBonus) {
      return true;
    }
    return false;
  }

  static String _reasonKeyFor(
    GlobalSearchResultItem item,
    SearchAnalysis analysis,
    bool usedProximity,
  ) {
    if (usedProximity) return 'global_search_near_me';
    return switch (analysis.intent) {
      SearchIntent.findService => 'global_search_best_match_service',
      SearchIntent.findJob => 'global_search_best_match_job',
      SearchIntent.findHousing => 'global_search_best_match_housing',
      SearchIntent.findBusiness || SearchIntent.findDoctor =>
        'global_search_best_match_business',
      _ => switch (item.category) {
          GlobalSearchCategory.services => 'global_search_best_match_service',
          GlobalSearchCategory.jobs => 'global_search_best_match_job',
          GlobalSearchCategory.housing => 'global_search_best_match_housing',
          GlobalSearchCategory.businesses => 'global_search_best_match_business',
          _ => 'global_search_best_match_reason',
        },
    };
  }

  static int _exactMatchBonus(
    GlobalSearchResultItem item,
    SearchAnalysis analysis,
  ) {
    final query = analysis.normalizedQuery.trim();
    if (query.isEmpty) return 0;

    final titleNorm = _normalize(item.title);
    final queryNorm = _normalize(query);

    if (titleNorm == queryNorm) return 20;

    final queryTokens = SearchKeywordTokenizer.tokenize(query);
    if (queryTokens.isEmpty) return 0;

    final haystackTokens = SearchKeywordTokenizer.tokenize(
      '${item.title} ${item.subtitle}',
    );
    if (haystackTokens.isEmpty) return 0;

    final allTokensMatch = queryTokens.every(
      (token) => haystackTokens.contains(token),
    );
    if (allTokensMatch) return 12;

    if (queryTokens.length == 1) {
      final token = queryTokens.first;
      if (token.length >= 4 && haystackTokens.contains(token)) return 8;
    }

    return 0;
  }

  static int _areaBonus(
    GlobalSearchResultItem item,
    SearchAnalysis analysis,
  ) {
    final area = analysis.area?.trim().toLowerCase();
    if (area == null || area.isEmpty) return 0;

    final haystack = '${item.title} ${item.subtitle}'.toLowerCase();
    if (haystack.contains(area)) return 8;
    return 0;
  }

  static int _filterBonus(
    GlobalSearchResultItem item,
    SearchAnalysis analysis,
  ) {
    var bonus = 0;
    final text = '${item.title} ${item.subtitle}'.toLowerCase();

    void matchToken(String? raw, int points) {
      final value = raw?.trim().toLowerCase();
      if (value == null || value.isEmpty) return;
      if (text.contains(value)) bonus += points;
    }

    matchToken(analysis.serviceTrade, 5);
    matchToken(analysis.jobTitle, 5);
    matchToken(analysis.jobCategory, 4);
    matchToken(analysis.businessCategory, 4);
    matchToken(analysis.propertyType, 3);
    matchToken(analysis.visaTopic, 3);

    if (analysis.bedrooms != null &&
        text.contains('${analysis.bedrooms} bed')) {
      bonus += 3;
    }

    return bonus.clamp(0, 10);
  }

  static bool _isLiveServiceListing(GlobalSearchResultItem item) {
    return item.id.startsWith('service_listing_') ||
        item.routePath.startsWith('/services/listing/');
  }

  static bool _isCrossIntentMismatch(
    GlobalSearchResultItem item,
    SearchAnalysis analysis,
  ) {
    if (analysis.intent == SearchIntent.unknown) return false;
    if (analysis.confidence < confidenceThreshold) return false;

    return switch (analysis.intent) {
      SearchIntent.findJob ||
      SearchIntent.findHousing ||
      SearchIntent.findBusiness =>
        item.category == GlobalSearchCategory.services,
      SearchIntent.findService => item.category == GlobalSearchCategory.jobs,
      _ => false,
    };
  }

  static bool _isGenericHub(GlobalSearchResultItem item) {
    final path = item.routePath.split('?').first;
    return const {
      '/services',
      '/jobs',
      '/housing',
      '/businesses',
      '/visa',
      '/money',
    }.contains(path);
  }

  static String _normalize(String value) {
    return value
        .toLowerCase()
        .replaceAll(RegExp(r'[^\w\s\u0600-\u06FF]'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }
}

class _CandidateScore {
  const _CandidateScore({
    required this.rankingScore,
    required this.reasonKey,
    required this.source,
  });

  final int rankingScore;
  final String reasonKey;
  final SearchBestMatchSource source;
}
