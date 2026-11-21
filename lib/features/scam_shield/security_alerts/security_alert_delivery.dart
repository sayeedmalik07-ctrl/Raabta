import 'package:raabta/features/scam_shield/domain/scam_advisory_models.dart';
import 'package:raabta/features/scam_shield/security_alerts/security_alert_state_repository.dart';
import 'package:raabta/features/scam_shield/security_alerts/security_guidance_catalog.dart'
    show SecurityGuidanceCatalog, SecurityGuidanceTopic;
import 'package:raabta/features/scam_shield/security_alerts/security_guidance_strings.dart';
import 'package:raabta/features/scam_shield/security_alerts/security_monthly_tip_scheduler.dart';
import 'package:raabta/services/notifications/notification_copy_strings.dart';
import 'package:raabta/services/smart_notification_engine.dart';

abstract final class SecurityAlertDelivery {
  static Future<void> notifyElevatedAdvisory({
    required ScamAdvisory advisory,
    required String locale,
  }) async {
    await SmartNotificationEngine.instance.notifyScamAdvisoryAlert(
      dedupKey: 'advisory_${advisory.id}',
      title: NotificationCopyStrings.t('scam_advisory_alert_title', locale),
      body: NotificationCopyStrings.t('scam_advisory_alert_body', locale),
      route: '/scam-shield/advisories/${advisory.id}',
      advisoryId: advisory.id,
    );
    final repo = SecurityAlertStateRepository();
    final started = DateTime.now();
    await repo.write(
      'advisory_campaign_${advisory.id}',
      started.toIso8601String(),
    );
    await repo.write(SecurityAlertStateRepository.activeAdvisoryIdKey, advisory.id);
    await repo.write(
      SecurityAlertStateRepository.activeAdvisoryStartedKey,
      started.toIso8601String(),
    );
  }

  static Future<void> notifyMonthlyTip({
    required String locale,
    required String topicId,
    required String variantKey,
  }) async {
    await SmartNotificationEngine.instance.notifySecurityTip(
      dedupKey: 'tip_${topicId}_$variantKey',
      title: SecurityGuidanceStrings.t('ss_sec_push_tip_title', locale),
      body: SecurityGuidanceStrings.t('ss_sec_push_tip_body', locale),
      route: '/scam-shield/security-tip?topic=$topicId',
      topicId: topicId,
    );
    final repo = SecurityAlertStateRepository();
    await repo.write(SecurityAlertStateRepository.lastTopicIdKey, topicId);
    await repo.write(SecurityAlertStateRepository.lastVariantKey, variantKey);
    await repo.write(
      SecurityAlertStateRepository.monthlyCampaignUntilKey,
      DateTime.now()
          .add(const Duration(days: 2))
          .toIso8601String(),
    );
  }

  static Future<void> onAppOpen({required String locale}) async {
    await SecurityMonthlyTipScheduler.reconcile(locale: locale);
  }

  static Future<void> recordTipOpened() async {
    final repo = SecurityAlertStateRepository();
    await repo.writeInt(SecurityAlertStateRepository.consecutiveUnopenedKey, 0);
    await repo.write(
      SecurityAlertStateRepository.tipEngagedAtKey,
      DateTime.now().toIso8601String(),
    );
  }

  static Future<void> recordTipUnopenedDelivery() async {
    final repo = SecurityAlertStateRepository();
    final n = await repo.readInt(
      SecurityAlertStateRepository.consecutiveUnopenedKey,
    );
    await repo.writeInt(
      SecurityAlertStateRepository.consecutiveUnopenedKey,
      n + 1,
    );
  }

  static Future<void> markPostIncidentCampaign() async {
    final repo = SecurityAlertStateRepository();
    await repo.write(
      SecurityAlertStateRepository.postIncidentUntilKey,
      DateTime.now().add(const Duration(days: 3)).toIso8601String(),
    );
  }

  static Future<List<SecurityGuidanceTopic>> verifiedTopics() async {
    final all = await SecurityGuidanceCatalog.loadTopics();
    return SecurityGuidanceCatalog.verifiedTopics(all);
  }
}
