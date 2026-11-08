import 'package:raabta/features/scam_shield/domain/scam_incident_models.dart';
import 'package:raabta/features/scam_shield/domain/scam_shield_history_entry.dart';
import 'package:raabta/features/scam_shield/domain/scam_shield_models.dart';

/// Correlates recent local history into one incident narrative.
abstract final class ScamChainCorrelator {
  static const correlationWindow = Duration(hours: 72);

  static String? buildNarrative({
    required List<ScamShieldHistoryEntry> recentEntries,
    required ScamIncidentAssessmentResult current,
    DateTime? now,
  }) {
    final clock = now ?? DateTime.now();
    final windowStart = clock.subtract(correlationWindow);

    final related = recentEntries
        .where((e) => e.scannedAt.isAfter(windowStart))
        .where((e) => e.id != current.incidentGroupId)
        .toList();

    final stages = <ScamAttackStage>[];
    if (current.stage != ScamAttackStage.contact) {
      stages.add(current.stage);
    }

    for (final entry in related) {
      if (entry.attackStage != null) {
        stages.add(entry.attackStage!);
      } else if (entry.kind == ScamShieldHistoryEntryKind.scan) {
        if (entry.riskLevel == ScamShieldRiskLevel.high) {
          stages.add(ScamAttackStage.impersonation);
        } else if (entry.riskLevel == ScamShieldRiskLevel.medium) {
          stages.add(ScamAttackStage.contact);
        }
      }
    }

    if (stages.length < 2) return null;

    final ordered = ScamAttackStage.values
        .where(stages.contains)
        .toList(growable: false);

    if (ordered.length < 2) return null;

    final parts = <String>[];
    for (var i = 0; i < ordered.length; i++) {
      parts.add(
        '(${i + 1}) ${_stageNarrativeLabel(ordered[i])}',
      );
    }

    return 'Possible connected incident: ${parts.join(' → ')}. '
        'These may be part of a single attack chain.';
  }

  static String _stageNarrativeLabel(ScamAttackStage stage) {
    return switch (stage) {
      ScamAttackStage.contact => 'Suspicious contact',
      ScamAttackStage.impersonation => 'Suspicious impersonation contact',
      ScamAttackStage.informationHarvesting => 'Personal information shared',
      ScamAttackStage.credentialHarvesting => 'Credentials shared',
      ScamAttackStage.otpHarvesting => 'OTP or code shared',
      ScamAttackStage.simSwapRisk => 'Possible telecom/SIM disruption',
      ScamAttackStage.accountTakeoverRisk => 'Account takeover indicators',
      ScamAttackStage.financialAction => 'Financial anomaly',
      ScamAttackStage.suspectedCompromise => 'Suspected compromise',
      ScamAttackStage.incidentResponse => 'Active incident response',
    };
  }

  static String newGroupId() =>
      'inc-${DateTime.now().millisecondsSinceEpoch}';

  static String? resolveGroupId({
    required List<ScamShieldHistoryEntry> recentEntries,
    required ScamAttackStage stage,
    DateTime? now,
  }) {
    final clock = now ?? DateTime.now();
    final windowStart = clock.subtract(correlationWindow);

    for (final entry in recentEntries) {
      if (entry.scannedAt.isBefore(windowStart)) continue;
      if (entry.incidentGroupId == null) continue;
      if (entry.attackStage == null) continue;
      if (entry.attackStage!.rank <= stage.rank) {
        return entry.incidentGroupId;
      }
    }
    return newGroupId();
  }
}
