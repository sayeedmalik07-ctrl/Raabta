import 'package:raabta/features/community/services/ask_qatar_similar_question_config.dart';

class AskQatarSimilarQuestionCacheEntry {
  AskQatarSimilarQuestionCacheEntry({
    required this.questionIds,
    required this.fetchedAt,
  });

  final List<String> questionIds;
  final DateTime fetchedAt;
}

/// In-memory TTL cache for similar-question lookup (BuddyMatchCache pattern).
abstract final class AskQatarSimilarQuestionCache {
  static final _store = <String, AskQatarSimilarQuestionCacheEntry>{};

  static List<String>? get(String cacheKey) {
    final entry = _store[cacheKey];
    if (entry == null) return null;
    if (DateTime.now().difference(entry.fetchedAt) >
        AskQatarSimilarQuestionConfig.clientCacheTtl) {
      _store.remove(cacheKey);
      return null;
    }
    return entry.questionIds;
  }

  static void put(String cacheKey, List<String> questionIds) {
    _store[cacheKey] = AskQatarSimilarQuestionCacheEntry(
      questionIds: List<String>.from(questionIds),
      fetchedAt: DateTime.now(),
    );
  }

  static void invalidate(String cacheKey) => _store.remove(cacheKey);

  static void clear() => _store.clear();
}
