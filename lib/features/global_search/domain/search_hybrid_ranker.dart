import 'package:raabta/features/global_search/domain/global_search_models.dart';
import 'package:raabta/features/global_search/domain/search_analysis.dart';
import 'package:raabta/features/global_search/domain/search_semantic_candidate.dart';
import 'package:raabta/features/global_search/domain/search_semantic_config.dart';
import 'package:raabta/features/global_search/domain/search_semantic_eligibility.dart';
import 'package:raabta/services/ai/smart_search_service.dart';

/// Bounded semantic bonus for hybrid ranking (S12).
abstract final class SearchHybridRanker {
  static int semanticBonusForRanking({
    required double? semanticSimilarity,
    required int maxSemanticBonus,
    required GlobalSearchResultItem item,
    required SearchAnalysis analysis,
  }) {
    if (semanticSimilarity == null || !semanticSimilarity.isFinite) return 0;
    if (_isCrossIntentMismatch(item, analysis)) return 0;
    if (semanticSimilarity < 0.70) return 0;

    final normalized =
        ((semanticSimilarity - 0.70) / 0.30).clamp(0.0, 1.0);
    return (normalized * maxSemanticBonus).round().clamp(0, maxSemanticBonus);
  }

  static int baseScoreForSemanticOnlyCandidate({
    required SearchSemanticCandidate candidate,
    required SearchSemanticConfig config,
  }) {
    // Base score only — semantic bonus is applied once in [SearchBestMatchRanker]
    // and in category sort via [semanticSortScore].
    return 35;
  }

  /// Display/sort score including a single semantic bonus application.
  static int semanticSortScore({
    required GlobalSearchResultItem item,
    required SearchAnalysis analysis,
    required int maxSemanticBonus,
  }) {
    return item.score +
        semanticBonusForRanking(
          semanticSimilarity: item.semanticSimilarity,
          maxSemanticBonus: maxSemanticBonus,
          item: item,
          analysis: analysis,
        );
  }

  static int semanticBonusForCandidate({
    required SearchSemanticCandidate candidate,
    required int maxSemanticBonus,
    SearchAnalysis? analysis,
  }) {
    if (!candidate.semanticSimilarity.isFinite) return 0;
    if (analysis != null &&
        !_matchesIntent(candidate, analysis)) {
      return 0;
    }
    if (candidate.semanticSimilarity < 0.70) return 0;
    final normalized =
        ((candidate.semanticSimilarity - 0.70) / 0.30).clamp(0.0, 1.0);
    return (normalized * maxSemanticBonus).round().clamp(0, maxSemanticBonus);
  }

  static bool _matchesIntent(
    SearchSemanticCandidate candidate,
    SearchAnalysis analysis,
  ) {
    if (analysis.intent == SearchIntent.unknown ||
        analysis.confidence < 0.55) {
      return true;
    }
    final allowed = SearchSemanticEligibility.categoriesForIntent(analysis);
    if (allowed == null) return true;
    if (allowed.isEmpty) return false;
    return allowed.contains(candidate.category.name);
  }

  static bool _isCrossIntentMismatch(
    GlobalSearchResultItem item,
    SearchAnalysis analysis,
  ) {
    if (analysis.intent == SearchIntent.unknown) return false;
    if (analysis.confidence < 0.55) return false;
    return switch (analysis.intent) {
      SearchIntent.findJob ||
      SearchIntent.findHousing ||
      SearchIntent.findBusiness =>
        item.category == GlobalSearchCategory.services,
      SearchIntent.findService => item.category == GlobalSearchCategory.jobs,
      _ => false,
    };
  }
}
