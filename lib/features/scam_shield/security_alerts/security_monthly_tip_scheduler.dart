import 'dart:convert';
import 'dart:math';

import 'package:raabta/features/scam_shield/security_alerts/security_alert_config.dart';
import 'package:raabta/features/scam_shield/security_alerts/security_alert_delivery.dart';
import 'package:raabta/features/scam_shield/security_alerts/security_alert_state_repository.dart';
import 'package:raabta/features/scam_shield/security_alerts/security_guidance_catalog.dart';
import 'package:raabta/features/scam_shield/security_alerts/security_guidance_strings.dart';
import 'package:raabta/models/notification_models.dart';
import 'package:raabta/services/notification_background.dart';
import 'package:raabta/services/notifications/notification_preferences_service.dart';
import 'package:raabta/services/raabta_notification_service.dart';
import 'package:timezone/timezone.dart' as tz;

abstract final class SecurityMonthlyTipScheduler {
  static final _random = Random();

  static Future<void> reconcile({
    required String locale,
    DateTime Function()? clock,
  }) async {
    final now = clock?.call() ?? DateTime.now();
    final userId = await RaabtaNotificationService.instance.getOrCreateUserId();
    final settings =
        await NotificationPreferencesService(userId).getSettings();
    if (!settings.securityTip) {
      await RaabtaLocalNotifications.instance.cancel(
        SecurityAlertConfig.localNotificationIdTip,
      );
      return;
    }

    final repo = SecurityAlertStateRepository();
    if (await repo.read(SecurityAlertStateRepository.sunsetPausedKey) == 'true') {
      final engaged = await repo.read(
        SecurityAlertStateRepository.tipEngagedAtKey,
      );
      if (engaged == null) return;
      await repo.write(SecurityAlertStateRepository.sunsetPausedKey, null);
    }

    final unopened = await repo.readInt(
      SecurityAlertStateRepository.consecutiveUnopenedKey,
    );
    if (unopened >= SecurityAlertConfig.maxConsecutiveUnopenedTips) {
      await repo.write(SecurityAlertStateRepository.sunsetPausedKey, 'true');
      await RaabtaLocalNotifications.instance.cancel(
        SecurityAlertConfig.localNotificationIdTip,
      );
      return;
    }

    final topics = await SecurityAlertDelivery.verifiedTopics();
    if (topics.isEmpty) return;

    var scheduled = _parse(await repo.read(
      SecurityAlertStateRepository.tipScheduledAtKey,
    ));
    if (scheduled == null || !scheduled.isAfter(now)) {
      scheduled = _nextSlot(now);
      final engagedAt = _parse(await repo.read(
        SecurityAlertStateRepository.tipEngagedAtKey,
      ));
      if (engagedAt != null &&
          now.difference(engagedAt).inDays <
              SecurityAlertConfig.tipPostponeDays) {
        scheduled = engagedAt.add(
          const Duration(days: SecurityAlertConfig.tipPostponeDays),
        );
      }
      await repo.write(
        SecurityAlertStateRepository.tipScheduledAtKey,
        scheduled.toIso8601String(),
      );
    }

    final topic = await _pickTopic(topics, repo);
    final variant = await _pickVariant(topic, repo);
    final title = SecurityGuidanceStrings.t('ss_sec_push_tip_title', locale);
    final body = SecurityGuidanceStrings.t('ss_sec_push_tip_body', locale);

    await RaabtaLocalNotifications.instance.schedule(
      id: SecurityAlertConfig.localNotificationIdTip,
      title: title,
      body: body,
      scheduledDate: scheduled,
      notificationType: NotificationType.securityTip,
      payload: jsonEncode({
        'route': '/scam-shield/security-tip?topic=${topic.id}',
        'type': 'security_tip',
        'topicId': topic.id,
        'variantKey': variant,
      }),
    );
  }

  static DateTime _nextSlot(DateTime from) {
    final days = SecurityAlertConfig.minTipIntervalDays +
        _random.nextInt(
          SecurityAlertConfig.maxTipIntervalDays -
              SecurityAlertConfig.minTipIntervalDays +
              1,
        );
    final hour = 10 + _random.nextInt(9);
    final base = from.add(Duration(days: days));
    var slot = DateTime(base.year, base.month, base.day, hour);
    final qatar = tz.TZDateTime.from(slot, tz.getLocation('Asia/Qatar'));
    if (qatar.hour >= 22 || qatar.hour < 7) {
      slot = DateTime(base.year, base.month, base.day, 10);
    }
    return slot;
  }

  static Future<SecurityGuidanceTopic> _pickTopic(
    List<SecurityGuidanceTopic> topics,
    SecurityAlertStateRepository repo,
  ) async {
    final last = await repo.read(SecurityAlertStateRepository.lastTopicIdKey);
    return topics.firstWhere(
      (t) => t.id != last,
      orElse: () => topics.first,
    );
  }

  static Future<String> _pickVariant(
    SecurityGuidanceTopic topic,
    SecurityAlertStateRepository repo,
  ) async {
    final last = await repo.read(SecurityAlertStateRepository.lastVariantKey);
    final keys = topic.variantKeys;
    if (keys.isEmpty) return '';
    for (final k in keys) {
      if (k != last) return k;
    }
    return keys.first;
  }

  static DateTime? _parse(String? raw) =>
      raw == null ? null : DateTime.tryParse(raw);
}
