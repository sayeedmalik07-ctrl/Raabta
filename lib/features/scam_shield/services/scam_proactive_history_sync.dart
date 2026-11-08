import 'package:raabta/features/scam_shield/domain/scam_incident_models.dart';
import 'package:raabta/features/scam_shield/domain/scam_shield_history_entry.dart';
import 'package:raabta/features/scam_shield/domain/scam_shield_models.dart';
import 'package:raabta/features/scam_shield/platform/scam_proactive_protection_platform.dart';

/// Persists proactive flagged-call events into the shared Hive history log.
abstract final class ScamProactiveHistorySync {
  static List<ScamShieldHistoryEntry> entriesFromFlaggedCalls(
    List<ScamFlaggedCallEvent> events,
  ) {
    return events.map((event) {
      return ScamShieldHistoryEntry(
        id: 'call-${event.timestamp}-${event.maskedNumber}',
        scannedAt: DateTime.tryParse(event.timestamp) ?? DateTime.now(),
        kind: ScamShieldHistoryEntryKind.proactiveCall,
        riskLevel: event.reasons.contains('stir_shaken_failed')
            ? ScamShieldRiskLevel.high
            : ScamShieldRiskLevel.medium,
        redFlagSummary: event.reasons,
        inputPreview: 'Call ${event.maskedNumber}',
        attackStage: ScamAttackStage.contact,
        impersonationCategory: ScamImpersonationCategory.other,
      );
    }).toList();
  }
}
