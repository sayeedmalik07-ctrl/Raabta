import 'package:flutter/widgets.dart';
import 'package:raabta/features/scam_shield/domain/scam_incident_models.dart';
import 'package:raabta/features/scam_shield/domain/scam_shield_models.dart';
import 'package:raabta/services/notifications/notification_copy_strings.dart';
import 'package:raabta/services/smart_notification_engine.dart';

/// Local-only Scam Shield notifications — no Firestore sync required.
abstract final class ScamShieldNotificationService {
  static Future<void> maybeNotifyIncidentResult({
    required ScamIncidentAssessmentResult result,
    required String locale,
  }) async {
    if (result.chainNarrative != null && result.chainNarrative!.isNotEmpty) {
      await SmartNotificationEngine.instance.notifyScamShieldIncident(
        dedupKey: 'incident_chain_${result.incidentGroupId ?? result.stage.name}',
        title: NotificationCopyStrings.t('scam_incident_chain_title', locale),
        body: NotificationCopyStrings.t('scam_incident_chain_body', locale),
        route: '/scam-shield/incident',
        timeCritical: result.responsePriority == ScamResponsePriority.emergency,
      );
      return;
    }

    if (result.responsePriority == ScamResponsePriority.emergency ||
        result.responsePriority == ScamResponsePriority.urgent) {
      await SmartNotificationEngine.instance.notifyScamShieldIncident(
        dedupKey: 'incident_priority_${result.stage.name}_${DateTime.now().day}',
        title: NotificationCopyStrings.t('scam_incident_urgent_title', locale),
        body: NotificationCopyStrings.t('scam_incident_urgent_body', locale),
        route: '/scam-shield/incident',
        timeCritical: result.responsePriority == ScamResponsePriority.emergency,
      );
    }
  }

  static Future<void> maybeNotifyShareAssessment({
    required ScamShieldAssessmentResult result,
    required String locale,
    AppLifecycleState? lifecycleState,
  }) async {
    if (result.overallRisk != ScamShieldRiskLevel.high) return;

    final backgrounded = lifecycleState != null &&
        lifecycleState != AppLifecycleState.resumed;
    if (!backgrounded) return;

    await SmartNotificationEngine.instance.notifyScamShieldShareAlert(
      dedupKey:
          'share_high_${DateTime.now().millisecondsSinceEpoch ~/ 60000}',
      title: NotificationCopyStrings.t('scam_share_high_risk_title', locale),
      body: NotificationCopyStrings.t('scam_share_high_risk_body', locale),
      route: '/scam-shield/share-review',
      timeCritical: result.scanAnalysis.stop.triggered,
    );
  }
}
