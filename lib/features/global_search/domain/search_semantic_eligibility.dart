import 'package:raabta/features/global_search/domain/global_search_models.dart';
import 'package:raabta/features/global_search/domain/search_analysis.dart';
import 'package:raabta/features/global_search/domain/search_semantic_config.dart';
import 'package:raabta/features/global_search/domain/search_semantic_privacy_sanitizer.dart';
import 'package:raabta/services/ai/smart_search_service.dart';

/// When semantic retrieval may run (S12).
abstract final class SearchSemanticEligibility {
  static const weakFindScoreThreshold = 70;
  static const strongFindScoreThreshold = 70;

  static const _actionIntents = {
    SearchIntent.eosbCalculator,
    SearchIntent.checkRate,
    SearchIntent.verifyEmployer,
    SearchIntent.verifyAgency,
    SearchIntent.scanDocument,
  };

  static bool shouldRun({
    required SearchSemanticConfig config,
    required SearchAnalysis analysis,
    required List<GlobalSearchResultItem> findResults,
    required bool isOnline,
    required bool fromCache,
  }) {
    if (!SearchSemanticFeatureFlag.isEnabled(config)) return false;
    if (!isOnline) return false;
    if (fromCache) return false;
    if (_actionIntents.contains(analysis.intent) &&
        analysis.confidence >= 0.70) {
      return false;
    }
    if (SearchSemanticPrivacySanitizer.isBlocked(analysis.originalQuery)) {
      return false;
    }
    final query = analysis.originalQuery.trim();
    if (query.length < 2) return false;
    if (!_isWeakOrIncomplete(findResults, analysis)) return false;
    return true;
  }

  static bool _isWeakOrIncomplete(
    List<GlobalSearchResultItem> findResults,
    SearchAnalysis analysis,
  ) {
    if (findResults.isEmpty) return true;

    final topScore = findResults
        .map((item) => item.score)
        .fold<int>(0, (max, score) => score > max ? score : max);

    if (topScore < weakFindScoreThreshold) return true;

    if (analysis.intent != SearchIntent.unknown &&
        analysis.confidence >= 0.55) {
      final intentCategory = _primaryCategoryForIntent(analysis.intent);
      if (intentCategory != null) {
        final hasIntentCategoryHit = findResults.any(
          (item) =>
              item.category == intentCategory &&
              item.score >= weakFindScoreThreshold,
        );
        if (!hasIntentCategoryHit) return true;
      }
    }

    final onlyGenericHubs = findResults.every(_isGenericHub);
    if (onlyGenericHubs && topScore < strongFindScoreThreshold) return true;

    return false;
  }

  static GlobalSearchCategory? _primaryCategoryForIntent(SearchIntent intent) {
    return switch (intent) {
      SearchIntent.findService => GlobalSearchCategory.services,
      SearchIntent.findJob => GlobalSearchCategory.jobs,
      SearchIntent.findHousing => GlobalSearchCategory.housing,
      SearchIntent.findBusiness || SearchIntent.findDoctor =>
        GlobalSearchCategory.businesses,
      SearchIntent.visaQuestion => GlobalSearchCategory.visa,
      _ => null,
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

  static Set<String>? categoriesForIntent(SearchAnalysis analysis) {
    if (analysis.intent == SearchIntent.unknown ||
        analysis.confidence < 0.55) {
      return null;
    }
    final category = _primaryCategoryForIntent(analysis.intent);
    if (category == null) return const {};
    return {category.name};
  }
}
