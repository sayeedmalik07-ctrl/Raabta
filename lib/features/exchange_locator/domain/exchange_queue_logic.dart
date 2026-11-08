import 'package:raabta/features/exchange_locator/domain/models/exchange_branch.dart';

/// One-tap crowd report levels — maps to [ExchangeQueueStatus] when aggregated.
enum CrowdReportLevel {
  quiet('quiet', 'Quiet', 1, ExchangeQueueStatus.low, 5),
  moderate('moderate', 'Moderate', 2, ExchangeQueueStatus.moderate, 15),
  busy('busy', 'Busy', 3, ExchangeQueueStatus.busy, 30),
  veryBusy('very_busy', 'Very Busy', 4, ExchangeQueueStatus.busy, 45);

  const CrowdReportLevel(
    this.value,
    this.label,
    this.score,
    this.queueStatus,
    this.estimatedWaitMinutes,
  );

  final String value;
  final String label;
  final int score;
  final ExchangeQueueStatus queueStatus;
  final int estimatedWaitMinutes;

  static CrowdReportLevel fromValue(String? raw) {
    return CrowdReportLevel.values.firstWhere(
      (l) => l.value == raw,
      orElse: () => CrowdReportLevel.quiet,
    );
  }
}

/// Deterministic queue aggregation — no AI, fully auditable.
abstract final class ExchangeQueueLogic {
  static const reportWindow = Duration(hours: 2);
  static const minReportsForPattern = 5;
  static const nudgeScoreGap = 2;

  /// Time-decay weight: linear decay to zero at [reportWindow].
  static double decayWeight(DateTime reportedAt, DateTime now) {
    final age = now.difference(reportedAt);
    if (age >= reportWindow) return 0;
    return 1 - (age.inMinutes / reportWindow.inMinutes);
  }

  /// Weighted average crowd score from recent reports.
  static CrowdAggregate? aggregateReports(
    List<CrowdReportSample> reports, {
    DateTime? now,
  }) {
    final clock = now ?? DateTime.now();
    var totalWeight = 0.0;
    var weightedScore = 0.0;
    DateTime? latest;

    for (final r in reports) {
      final w = decayWeight(r.reportedAt, clock);
      if (w <= 0) continue;
      totalWeight += w;
      weightedScore += r.level.score * w;
      if (latest == null || r.reportedAt.isAfter(latest)) {
        latest = r.reportedAt;
      }
    }

    if (totalWeight <= 0 || latest == null) return null;

    final avgScore = weightedScore / totalWeight;
    final level = _scoreToLevel(avgScore);
    return CrowdAggregate(
      level: level,
      estimatedWaitMinutes: level.estimatedWaitMinutes,
      reportCount: reports.where((r) => decayWeight(r.reportedAt, clock) > 0).length,
      lastReportAt: latest,
    );
  }

  static CrowdReportLevel _scoreToLevel(double avgScore) {
    if (avgScore < 1.5) return CrowdReportLevel.quiet;
    if (avgScore < 2.5) return CrowdReportLevel.moderate;
    if (avgScore < 3.5) return CrowdReportLevel.busy;
    return CrowdReportLevel.veryBusy;
  }

  /// True when user's selection disagrees strongly with recent crowd reports.
  static bool shouldNudgeAccuracy({
    required CrowdReportLevel selected,
    required List<CrowdReportSample> recentReports,
    DateTime? now,
  }) {
    final agg = aggregateReports(recentReports, now: now);
    if (agg == null || agg.reportCount < 2) return false;
    return (selected.score - agg.level.score).abs() >= nudgeScoreGap;
  }

  /// Best hour hint from denormalized hourly counts `{ "weekday-hour": count }`.
  static BestTimeHint? bestTimeToGo(
    Map<String, int> hourlyBusyCounts, {
    DateTime? now,
  }) {
    if (hourlyBusyCounts.isEmpty) return null;

    final byHour = <int, int>{};
    for (final entry in hourlyBusyCounts.entries) {
      final parts = entry.key.split('-');
      if (parts.length != 2) continue;
      final hour = int.tryParse(parts[1]);
      if (hour == null) continue;
      byHour[hour] = (byHour[hour] ?? 0) + entry.value;
    }

    int? quietestHour;
    var quietestCount = 1 << 30;
    for (final entry in byHour.entries) {
      if (entry.value < minReportsForPattern) continue;
      if (entry.value < quietestCount) {
        quietestCount = entry.value;
        quietestHour = entry.key;
      }
    }

    if (quietestHour == null) {
      return const BestTimeHint(
        hasEnoughData: false,
        message: 'Not enough data yet — check back after more crowd reports.',
      );
    }

    final formatted = _formatHour(quietestHour);
    return BestTimeHint(
      hasEnoughData: true,
      quietestHour: quietestHour,
      message: 'Usually quieter around $formatted (based on $quietestCount reports)',
    );
  }

  static String _formatHour(int hour) {
    final period = hour >= 12 ? 'PM' : 'AM';
    final h = hour % 12 == 0 ? 12 : hour % 12;
    return '$h:00 $period';
  }

  static String formatRecency(DateTime? updatedAt, DateTime now) {
    if (updatedAt == null) return 'No recent crowd reports';
    final diff = now.difference(updatedAt);
    if (diff.inMinutes < 1) return 'Updated just now';
    if (diff.inMinutes < 60) return 'Updated ${diff.inMinutes} min ago';
    if (diff.inHours < 24) return 'Updated ${diff.inHours} hr ago';
    return 'Updated ${diff.inDays} day${diff.inDays == 1 ? '' : 's'} ago';
  }

  static String hourlyCountKey(DateTime at) => '${at.weekday}-${at.hour}';
}

class CrowdReportSample {
  const CrowdReportSample({
    required this.level,
    required this.reportedAt,
  });

  final CrowdReportLevel level;
  final DateTime reportedAt;
}

class CrowdAggregate {
  const CrowdAggregate({
    required this.level,
    required this.estimatedWaitMinutes,
    required this.reportCount,
    required this.lastReportAt,
  });

  final CrowdReportLevel level;
  final int estimatedWaitMinutes;
  final int reportCount;
  final DateTime lastReportAt;
}

class BestTimeHint {
  const BestTimeHint({
    required this.hasEnoughData,
    required this.message,
    this.quietestHour,
  });

  final bool hasEnoughData;
  final String message;
  final int? quietestHour;
}
