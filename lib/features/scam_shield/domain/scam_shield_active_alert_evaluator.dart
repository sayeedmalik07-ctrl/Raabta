import 'package:raabta/features/scam_shield/domain/scam_incident_models.dart';
import 'package:raabta/features/scam_shield/domain/scam_shield_active_alert.dart';
import 'package:raabta/features/scam_shield/domain/scam_shield_history_entry.dart';
import 'package:raabta/features/scam_shield/domain/scam_shield_models.dart';

/// Pure read-side rules for Home anchor elevation (Option A).
abstract final class ScamShieldActiveAlertEvaluator {
  /// Incidents older than this no longer elevate the anchor if never acked.
  static const incidentMaxAge = Duration(days: 30);

  /// High-risk scans older than this no longer elevate the anchor if never acked.
  static const highScanMaxAge = Duration(days: 30);

  static bool isAlertEligible(
    ScamShieldHistoryEntry entry, {
    DateTime? now,
  }) {
    final clock = now ?? DateTime.now();
    final age = clock.difference(entry.scannedAt);
    if (entry.kind == ScamShieldHistoryEntryKind.incident) {
      return age <= incidentMaxAge;
    }
    if (entry.kind == ScamShieldHistoryEntryKind.scan &&
        entry.riskLevel == ScamShieldRiskLevel.high) {
      return age <= highScanMaxAge;
    }
    return false;
  }

  static ScamShieldActiveAlertState evaluate({
    required List<ScamShieldHistoryEntry> history,
    required Set<String> acknowledgedEntryIds,
    DateTime? now,
  }) {
    var maxSeverity = ScamShieldRiskLevel.low;
    var count = 0;

    for (final entry in history) {
      if (acknowledgedEntryIds.contains(entry.id)) continue;
      if (!isAlertEligible(entry, now: now)) continue;
      count++;
      maxSeverity = entry.riskLevel.severityRank >= maxSeverity.severityRank
          ? entry.riskLevel
          : maxSeverity;
    }

    if (count == 0) return const ScamShieldActiveAlertState.calm();

    return ScamShieldActiveAlertState(
      level: ScamShieldActiveAlertLevel.elevated,
      displaySeverity: maxSeverity,
      unacknowledgedCount: count,
    );
  }

  static Iterable<String> alertEligibleEntryIds(
    List<ScamShieldHistoryEntry> history, {
    DateTime? now,
  }) {
    return history
        .where((entry) => isAlertEligible(entry, now: now))
        .map((entry) => entry.id);
  }
}
