import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:raabta/features/global_search/domain/global_search_models.dart';

/// Shared Firestore + grouping helpers for search providers.
abstract final class SearchQueryHelpers {
  static const fetchLimit = GlobalSearchRepositoryConstants.fetchLimit;
  static const perCategoryDisplayLimit =
      GlobalSearchRepositoryConstants.perCategoryDisplayLimit;

  static GlobalSearchCategoryGroup buildGroup({
    required GlobalSearchCategory category,
    required List<GlobalSearchResultItem> allMatches,
    bool failed = false,
  }) {
    allMatches.sort((a, b) => b.score.compareTo(a.score));
    return GlobalSearchCategoryGroup(
      category: category,
      items: allMatches.take(perCategoryDisplayLimit).toList(),
      totalMatched: allMatches.length,
      failed: failed,
    );
  }

  static bool matchesQuery(String q, String haystack, String? token) {
    if (haystack.contains(q)) return true;
    if (token != null && haystack.contains(token)) return true;
    return false;
  }

  static Future<List<QueryDocumentSnapshot<Map<String, dynamic>>>>
      fetchWithKeywordFallback(
    CollectionReference<Map<String, dynamic>> collection, {
    required String? token,
    Map<String, Object?> equalityFilters = const {},
  }) async {
    if (token != null) {
      try {
        Query<Map<String, dynamic>> query = collection;
        for (final entry in equalityFilters.entries) {
          query = query.where(entry.key, isEqualTo: entry.value);
        }
        query = query
            .where('searchKeywords', arrayContains: token)
            .limit(fetchLimit);
        final snap = await query.get();
        if (snap.docs.isNotEmpty) return snap.docs;
      } catch (_) {
        // Missing composite index — fall through.
      }
    }

    Query<Map<String, dynamic>> query = collection;
    for (final entry in equalityFilters.entries) {
      query = query.where(entry.key, isEqualTo: entry.value);
    }
    final snap = await query.limit(fetchLimit).get();
    return snap.docs;
  }
}

/// Constants shared between repository and helpers (avoids circular imports).
abstract final class GlobalSearchRepositoryConstants {
  static const minQueryLength = 2;
  static const perCategoryDisplayLimit = 5;
  static const fetchLimit = 24;

  /// Per-provider ceiling for parallel global search (P1).
  static const providerSearchTimeout = Duration(seconds: 4);
}
