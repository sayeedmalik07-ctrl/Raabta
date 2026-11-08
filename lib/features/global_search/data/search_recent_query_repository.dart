import 'package:raabta/features/global_search/data/recent_searches_cache.dart';
import 'package:raabta/features/global_search/domain/search_recent_query.dart';

/// Local recent-query persistence for Global Search autocomplete (S8).
///
/// Wraps existing [RecentSearchesCache] (Hive) — no remote writes.
abstract final class SearchRecentQueryRepository {
  static const maxEntries = 8;

  static Future<void> init() => RecentSearchesCache.instance.init();

  static List<SearchRecentQuery> getRecentQueries() {
    final now = DateTime.now();
    return RecentSearchesCache.instance
        .load()
        .take(maxEntries)
        .map((text) => SearchRecentQuery(text: text, recordedAt: now))
        .toList();
  }

  static Future<void> addRecentQuery(String query) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return;
    if (isSensitiveQuery(trimmed)) return;
    await RecentSearchesCache.instance.add(trimmed);
    await _trimToMax();
  }

  static Future<void> removeRecentQuery(String query) {
    return RecentSearchesCache.instance.remove(query);
  }

  static Future<void> clearRecentQueries() {
    return RecentSearchesCache.instance.clear();
  }

  static Future<void> _trimToMax() async {
    final current = RecentSearchesCache.instance.load();
    if (current.length <= maxEntries) return;
    await RecentSearchesCache.instance.clear();
    for (final entry in current.take(maxEntries)) {
      await RecentSearchesCache.instance.add(entry);
    }
  }

  /// Conservative filter — rejects obvious secrets and long numeric strings.
  static bool isSensitiveQuery(String query) {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return true;

    final lower = trimmed.toLowerCase();
    const blockedTerms = [
      'password',
      'passwd',
      'otp',
      'pin code',
      'cvv',
      'cvc',
      'secret',
      'token',
      'api key',
      'apikey',
    ];
    if (blockedTerms.any(lower.contains)) return true;

    final digitsOnly = RegExp(r'^\d+$');
    if (digitsOnly.hasMatch(trimmed)) {
      if (trimmed.length >= 6) return true;
    }

    if (RegExp(r'\d{10,}').hasMatch(trimmed)) return true;

    if (RegExp(r'\b\d{4}[\s-]?\d{4}[\s-]?\d{4}[\s-]?\d{4}\b').hasMatch(trimmed)) {
      return true;
    }

    return false;
  }

  /// Test-only reset.
  static Future<void> resetForTests() =>
      RecentSearchesCache.instance.resetForTests();
}
