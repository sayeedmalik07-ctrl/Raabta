import 'package:raabta/features/global_search/data/search_query_helpers.dart';
import 'package:raabta/features/global_search/domain/global_search_models.dart';
import 'package:raabta/features/global_search/domain/search_analysis.dart';
import 'package:raabta/features/global_search/domain/search_hybrid_ranker.dart';
import 'package:raabta/features/global_search/domain/search_semantic_candidate.dart';
import 'package:raabta/features/global_search/domain/search_semantic_candidate_mapper.dart';
import 'package:raabta/features/global_search/domain/search_semantic_config.dart';

/// Merges deterministic and semantic FIND candidates with deduplication (S12).
abstract final class SearchHybridMerger {
  static GlobalSearchResponse merge({
    required GlobalSearchResponse response,
    required List<SearchSemanticCandidate> candidates,
    required SearchAnalysis analysis,
    required SearchSemanticConfig config,
  }) {
    if (candidates.isEmpty) return response;

    final existingById = <String, GlobalSearchResultItem>{};
    for (final group in response.groups) {
      for (final item in group.items) {
        existingById[item.id] = item;
      }
    }

    final additionsByCategory = <GlobalSearchCategory, List<GlobalSearchResultItem>>{};

    for (final candidate in candidates) {
      if (SearchHybridRanker.semanticBonusForCandidate(
            candidate: candidate,
            maxSemanticBonus: config.maxSemanticBonus,
            analysis: analysis,
          ) <=
          0) {
        continue;
      }

      final existing = existingById[candidate.resultId];
      if (existing != null) {
        existingById[candidate.resultId] = GlobalSearchResultItem(
          id: existing.id,
          category: existing.category,
          title: existing.title,
          subtitle: existing.subtitle,
          routePath: existing.routePath,
          score: existing.score,
          useHousingDetailNavigator: existing.useHousingDetailNavigator,
          resultKind: existing.resultKind,
          actionId: existing.actionId,
          actionPayload: existing.actionPayload,
          queryParameters: existing.queryParameters,
          confidence: existing.confidence,
          searchRouteParameters: existing.searchRouteParameters,
          listingLatitude:
              existing.listingLatitude ?? candidate.listingLatitude,
          listingLongitude:
              existing.listingLongitude ?? candidate.listingLongitude,
          distanceMeters: existing.distanceMeters,
          semanticSimilarity: candidate.semanticSimilarity,
        );
        continue;
      }

      final mapped = SearchSemanticCandidateMapper.toResultItem(
        candidate: candidate,
        analysis: analysis,
        config: config,
      );
      if (mapped == null) continue;

      additionsByCategory
          .putIfAbsent(mapped.category, () => [])
          .add(mapped);
    }

    final updatedGroups = response.groups.map((group) {
      final mergedItems = <GlobalSearchResultItem>[];
      final seen = <String>{};

      for (final item in group.items) {
        final updated = existingById[item.id] ?? item;
        if (seen.add(updated.id)) mergedItems.add(updated);
      }

      final additions = additionsByCategory[group.category] ?? const [];
      for (final item in additions) {
        if (seen.add(item.id)) mergedItems.add(item);
      }

      mergedItems.sort(
        (a, b) => SearchHybridRanker.semanticSortScore(
              item: b,
              analysis: analysis,
              maxSemanticBonus: config.maxSemanticBonus,
            ).compareTo(
              SearchHybridRanker.semanticSortScore(
                item: a,
                analysis: analysis,
                maxSemanticBonus: config.maxSemanticBonus,
              ),
            ),
      );

      return GlobalSearchCategoryGroup(
        category: group.category,
        items: mergedItems
            .take(GlobalSearchRepositoryConstants.perCategoryDisplayLimit)
            .toList(),
        totalMatched: group.totalMatched + additions.length,
        failed: group.failed && mergedItems.isEmpty,
        seeAllRouteParameters: group.seeAllRouteParameters,
      );
    }).toList();

    for (final entry in additionsByCategory.entries) {
      if (updatedGroups.any((g) => g.category == entry.key)) continue;
      if (entry.value.isEmpty) continue;
      final sorted = [...entry.value]
        ..sort(
          (a, b) => SearchHybridRanker.semanticSortScore(
                item: b,
                analysis: analysis,
                maxSemanticBonus: config.maxSemanticBonus,
              ).compareTo(
                SearchHybridRanker.semanticSortScore(
                  item: a,
                  analysis: analysis,
                  maxSemanticBonus: config.maxSemanticBonus,
                ),
              ),
        );
      updatedGroups.add(
        GlobalSearchCategoryGroup(
          category: entry.key,
          items: sorted
              .take(GlobalSearchRepositoryConstants.perCategoryDisplayLimit)
              .toList(),
          totalMatched: sorted.length,
        ),
      );
    }

    return GlobalSearchResponse(
      query: response.query,
      groups: updatedGroups,
      actions: response.actions,
      fromCache: response.fromCache,
      offline: response.offline,
      analysis: response.analysis,
      locationUnavailable: response.locationUnavailable,
    );
  }
}
