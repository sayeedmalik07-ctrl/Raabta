import 'package:raabta/features/community/services/community_moderation_config.dart';

/// Cached Community Pulse counts (Part D) — cheap Firestore count() aggregations.
class CommunityPulseSnapshot {
  const CommunityPulseSnapshot({
    required this.trendingDiscussions,
    required this.eventsToday,
    required this.openQuestions,
    required this.fetchedAt,
    this.fromCache = false,
  });

  final int trendingDiscussions;
  final int eventsToday;
  final int openQuestions;
  final DateTime fetchedAt;
  final bool fromCache;

  static CommunityPulseSnapshot empty({DateTime? fetchedAt}) {
    return CommunityPulseSnapshot(
      trendingDiscussions: 0,
      eventsToday: 0,
      openQuestions: 0,
      fetchedAt: fetchedAt ?? DateTime.now(),
    );
  }

  bool get isFresh =>
      DateTime.now().difference(fetchedAt) <
      CommunityModerationConfig.newsClientCacheTtl;

  CommunityPulseSnapshot copyWith({
    int? trendingDiscussions,
    int? eventsToday,
    int? openQuestions,
    DateTime? fetchedAt,
    bool? fromCache,
  }) {
    return CommunityPulseSnapshot(
      trendingDiscussions: trendingDiscussions ?? this.trendingDiscussions,
      eventsToday: eventsToday ?? this.eventsToday,
      openQuestions: openQuestions ?? this.openQuestions,
      fetchedAt: fetchedAt ?? this.fetchedAt,
      fromCache: fromCache ?? this.fromCache,
    );
  }
}
