import 'package:raabta/models/intelligence/intelligence_insight.dart';
import 'package:raabta/models/intelligence/intelligence_priority.dart';
import 'package:raabta/services/intelligence/attention_scorer.dart';

/// Groups recent insights for batched surfacing — no delivery in this phase.
class DailyDigestBuilder {
  const DailyDigestBuilder({
    AttentionScorer? scorer,
    this.lookback = const Duration(hours: 24),
  }) : scorer = scorer ?? const AttentionScorer();

  final AttentionScorer scorer;
  final Duration lookback;

  /// Minimum composite score for a digest-tier insight to appear in the daily batch.
  ///
  /// Rationale: [AttentionScorer] maps composite `< 0.28` to [IntelligencePriority.digest].
  /// With default type severity (0.5), composite floor is ~0.175 at zero confidence.
  /// Items at or below [digestInclusionFloor] are dropped as noise. Immediate tiers
  /// (critical–low) always pass through when within the lookback window.
  static const digestInclusionFloor = 0.20;

  /// Groups [insights] from the last [lookback] by scored priority, omitting ignorable noise.
  Map<IntelligencePriority, List<IntelligenceInsight>> build(
    List<IntelligenceInsight> insights, {
    List<IntelligenceInsight>? recentHistory,
    DateTime? now,
  }) {
    final clock = now ?? DateTime.now();
    final cutoff = clock.subtract(lookback);
    final history = recentHistory ?? const [];

    final grouped = <IntelligencePriority, List<IntelligenceInsight>>{
      for (final p in IntelligencePriority.values) p: [],
    };

    for (final insight in insights) {
      if (insight.createdAt.isBefore(cutoff)) continue;

      final priority = scorer.score(insight, recentHistory: history);
      if (_isIgnorable(insight, priority, history)) continue;

      grouped[priority]!.add(insight);
    }

    for (final list in grouped.values) {
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    }

    return grouped;
  }

  bool _isIgnorable(
    IntelligenceInsight insight,
    IntelligencePriority priority,
    List<IntelligenceInsight> history,
  ) {
    if (priority != IntelligencePriority.digest) return false;

    final composite = scorer.compositeScore(
      insight,
      recentHistory: history,
    );
    return composite < digestInclusionFloor;
  }
}
