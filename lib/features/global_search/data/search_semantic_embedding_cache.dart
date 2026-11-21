import 'package:raabta/features/global_search/domain/search_embedding.dart';

/// Short-lived in-memory query embedding cache (S12).
class SearchSemanticEmbeddingCache {
  SearchSemanticEmbeddingCache({
    this.maxEntries = 32,
    this.ttlSeconds = 300,
  });

  final int maxEntries;
  final int ttlSeconds;

  final Map<String, _CacheEntry> _entries = {};

  SearchEmbedding? get(String cacheKey, {required int embeddingVersion}) {
    _evictExpired();
    final entry = _entries[cacheKey];
    if (entry == null) return null;
    if (entry.embeddingVersion != embeddingVersion) {
      _entries.remove(cacheKey);
      return null;
    }
    if (entry.isExpired(ttlSeconds)) {
      _entries.remove(cacheKey);
      return null;
    }
    return entry.embedding;
  }

  void put({
    required String cacheKey,
    required SearchEmbedding embedding,
    required int embeddingVersion,
  }) {
    _evictExpired();
    if (_entries.length >= maxEntries) {
      _evictOldest();
    }
    _entries[cacheKey] = _CacheEntry(
      embedding: embedding,
      embeddingVersion: embeddingVersion,
      storedAt: DateTime.now(),
    );
  }

  void clear() => _entries.clear();

  void invalidateVersion(int embeddingVersion) {
    _entries.removeWhere((_, entry) => entry.embeddingVersion != embeddingVersion);
  }

  void _evictExpired() {
    _entries.removeWhere((_, entry) => entry.isExpired(ttlSeconds));
  }

  void _evictOldest() {
    if (_entries.isEmpty) return;
    String? oldestKey;
    DateTime? oldestTime;
    for (final entry in _entries.entries) {
      if (oldestTime == null || entry.value.storedAt.isBefore(oldestTime)) {
        oldestTime = entry.value.storedAt;
        oldestKey = entry.key;
      }
    }
    if (oldestKey != null) _entries.remove(oldestKey);
  }
}

class _CacheEntry {
  const _CacheEntry({
    required this.embedding,
    required this.embeddingVersion,
    required this.storedAt,
  });

  final SearchEmbedding embedding;
  final int embeddingVersion;
  final DateTime storedAt;

  bool isExpired(int ttlSeconds) {
    return DateTime.now().difference(storedAt).inSeconds >= ttlSeconds;
  }
}
