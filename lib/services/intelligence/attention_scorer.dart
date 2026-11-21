import 'package:raabta/models/intelligence/intelligence_insight.dart';
import 'package:raabta/models/intelligence/intelligence_priority.dart';

/// Scores [IntelligenceInsight] signals into [IntelligencePriority] tiers.
///
/// Duplicate suppression mirrors the send-history pattern used by
/// [RaabtaNotificationService.sendSmartNotification] → [NotificationEngine] →
/// [NotificationDedupService]: same `{type}|{reference}|{dayBucket}` key shape,
/// checked against a recent delivery list rather than opening a second pipeline.
class AttentionScorer {
  const AttentionScorer({
    this.typeSeverity = const {},
    this.duplicateSuppressionWindow = const Duration(hours: 24),
    this.now,
  });

  /// Per-type severity weight (0.0–1.0). Unknown types default to [defaultTypeSeverity].
  final Map<String, double> typeSeverity;

  /// Aligns with [NotificationDedupService.dedupWindowFor] default (24h).
  final Duration duplicateSuppressionWindow;

  /// Fixed clock for tests; defaults to [DateTime.now] when null.
  final DateTime? now;

  static const defaultTypeSeverity = 0.5;
  static const intelligenceDedupPrefix = 'intelligence';

  DateTime get _clock => now ?? DateTime.now();

  /// Composite score in `[0, 1]` — exposed for digest filtering thresholds.
  double compositeScore(
    IntelligenceInsight insight, {
    List<IntelligenceInsight>? recentHistory,
  }) {
    return _compositeScore(insight, recentHistory ?? const []);
  }

  IntelligencePriority score(
    IntelligenceInsight insight, {
    List<IntelligenceInsight>? recentHistory,
  }) {
    final history = recentHistory ?? const [];
    if (_wasRecentlyDelivered(insight, history)) {
      return IntelligencePriority.digest;
    }

    final composite = _compositeScore(insight, history);
    return _priorityFromComposite(composite, insight);
  }

  /// Same key shape as [NotificationDedupService.buildKey] for future wiring.
  static String buildDedupKey(
    IntelligenceInsight insight, {
    DateTime? at,
  }) {
    final dt = at ?? insight.createdAt;
    final bucket = '${dt.year}-${dt.month}-${dt.day}';
    return '$intelligenceDedupPrefix|${insight.type}|${insight.userId}|$bucket';
  }

  double _compositeScore(
    IntelligenceInsight insight,
    List<IntelligenceInsight> history,
  ) {
    final severity = typeSeverity[insight.type] ?? defaultTypeSeverity;
    final confidence = insight.confidence.clamp(0.0, 1.0);
    final deadlineBoost = _deadlineUrgency(insight);

    // Weights: severity and confidence dominate; deadline adds urgency tail.
    final raw =
        severity * 0.35 + confidence * 0.45 + deadlineBoost * 0.20;
    return raw.clamp(0.0, 1.0);
  }

  double _deadlineUrgency(IntelligenceInsight insight) {
    final expiresAt = insight.expiresAt;
    if (expiresAt == null) return 0.0;

    final days = expiresAt.difference(_clock).inDays;
    if (days < 0) return 1.0;
    if (days <= 1) return 0.95;
    if (days <= 3) return 0.85;
    if (days <= 7) return 0.65;
    if (days <= 14) return 0.40;
    if (days <= 30) return 0.20;
    return 0.05;
  }

  bool _wasRecentlyDelivered(
    IntelligenceInsight insight,
    List<IntelligenceInsight> history,
  ) {
    final cutoff = _clock.subtract(duplicateSuppressionWindow);
    return history.any(
      (prior) =>
          prior.userId == insight.userId &&
          prior.type == insight.type &&
          !prior.createdAt.isBefore(cutoff),
    );
  }

  IntelligencePriority _priorityFromComposite(
    double composite,
    IntelligenceInsight insight,
  ) {
    final daysToDeadline = insight.expiresAt?.difference(_clock).inDays;

    if (composite >= 0.82 ||
        (daysToDeadline != null && daysToDeadline <= 1 && composite >= 0.55)) {
      return IntelligencePriority.critical;
    }
    if (composite >= 0.68) return IntelligencePriority.high;
    if (composite >= 0.48) return IntelligencePriority.medium;
    if (composite >= 0.28) return IntelligencePriority.low;
    return IntelligencePriority.digest;
  }
}
