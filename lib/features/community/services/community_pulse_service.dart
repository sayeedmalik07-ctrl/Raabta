import 'package:raabta/features/community/models/community_pulse_snapshot.dart';
import 'package:raabta/features/community/services/community_repository.dart';

/// Pull-based Community Pulse with in-memory TTL cache (matches news feed pattern).
class CommunityPulseService {
  CommunityPulseService({
    CommunityRepository? repository,
    Future<CommunityPulseCounts> Function()? fetchCounts,
  }) : _fetchCounts =
            fetchCounts ?? (repository ?? CommunityRepository()).fetchPulseCounts;

  final Future<CommunityPulseCounts> Function() _fetchCounts;

  static CommunityPulseSnapshot? _memoryCache;

  static void clearClientCache() => _memoryCache = null;

  Future<CommunityPulseSnapshot> fetch({bool bypassClientCache = false}) async {
    if (!bypassClientCache &&
        _memoryCache != null &&
        _memoryCache!.isFresh) {
      return _memoryCache!.copyWith(fromCache: true);
    }

    try {
      final counts = await _fetchCounts();
      final snapshot = CommunityPulseSnapshot(
        trendingDiscussions: counts.trendingDiscussions,
        eventsToday: counts.eventsToday,
        openQuestions: counts.openQuestions,
        fetchedAt: DateTime.now(),
      );
      _memoryCache = snapshot;
      return snapshot;
    } catch (_) {
      if (_memoryCache != null) {
        return _memoryCache!.copyWith(fromCache: true);
      }
      return CommunityPulseSnapshot.empty();
    }
  }
}

/// Raw count() aggregation results from [CommunityRepository.fetchPulseCounts].
class CommunityPulseCounts {
  const CommunityPulseCounts({
    required this.trendingDiscussions,
    required this.eventsToday,
    required this.openQuestions,
  });

  final int trendingDiscussions;
  final int eventsToday;
  final int openQuestions;
}

/// Qatar calendar day boundaries in UTC for Firestore [Timestamp] range queries.
abstract final class CommunityPulseTime {
  static const qatarOffset = Duration(hours: 3);

  static (DateTime startUtc, DateTime endUtc) qatarTodayUtcRange({DateTime? now}) {
    final qatarNow = (now ?? DateTime.now()).toUtc().add(qatarOffset);
    final startUtc = DateTime.utc(
      qatarNow.year,
      qatarNow.month,
      qatarNow.day,
    ).subtract(qatarOffset);
    return (startUtc, startUtc.add(const Duration(days: 1)));
  }
}
