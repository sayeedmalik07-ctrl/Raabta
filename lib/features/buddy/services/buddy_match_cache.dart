import 'package:raabta/features/buddy/domain/buddy_constants.dart';
import 'package:raabta/features/buddy/domain/buddy_matching_engine.dart';

class _CacheEntry {
  _CacheEntry(this.candidates, this.fetchedAt);

  final List<BuddyMatchCandidate> candidates;
  final DateTime fetchedAt;
}

abstract final class BuddyMatchCache {
  static final _store = <String, _CacheEntry>{};

  static List<BuddyMatchCandidate>? get(String newcomerUid) {
    final entry = _store[newcomerUid];
    if (entry == null) return null;
    if (DateTime.now().difference(entry.fetchedAt) >
        BuddyConstants.matchClientCacheTtl) {
      _store.remove(newcomerUid);
      return null;
    }
    return entry.candidates;
  }

  static void put(String newcomerUid, List<BuddyMatchCandidate> candidates) {
    _store[newcomerUid] = _CacheEntry(candidates, DateTime.now());
  }

  static void invalidate(String newcomerUid) {
    _store.remove(newcomerUid);
  }
}
