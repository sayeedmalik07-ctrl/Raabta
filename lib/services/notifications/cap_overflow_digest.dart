import 'dart:convert';

import 'package:raabta/models/notification_models.dart';
import 'package:raabta/services/notifications/notification_copy_strings.dart';

/// Lossy cap-overflow digest — consumes [notification_cap_queue_v1] entries.
abstract final class CapOverflowDigest {
  static const ttlQatarDays = 7;
  static const dataFlag = 'capOverflowDigest';

  static bool isCapOverflowDigestData(Map<String, dynamic> data) =>
      data[dataFlag] == true || data[dataFlag] == 'true';

  /// Hive key: `{qatarDateKey}|{apiKey}` → (queueDate, apiKey).
  static ({String queueDate, String apiKey})? parseQueueHiveKey(String hiveKey) {
    final sep = hiveKey.indexOf('|');
    if (sep <= 0 || sep >= hiveKey.length - 1) return null;
    final queueDate = hiveKey.substring(0, sep);
    final apiKey = hiveKey.substring(sep + 1);
    if (queueDate.isEmpty || apiKey.isEmpty) return null;
    if (parseQatarDateKey(queueDate) == null) return null;
    return (queueDate: queueDate, apiKey: apiKey);
  }

  static DateTime? parseQatarDateKey(String key) {
    final parts = key.split('-');
    if (parts.length != 3) return null;
    final year = int.tryParse(parts[0]);
    final month = int.tryParse(parts[1]);
    final day = int.tryParse(parts[2]);
    if (year == null || month == null || day == null) return null;
    return DateTime(year, month, day);
  }

  static int qatarCalendarDaysBetween(String earlierKey, String laterKey) {
    final earlier = parseQatarDateKey(earlierKey);
    final later = parseQatarDateKey(laterKey);
    if (earlier == null || later == null) return 0;
    final a = DateTime(earlier.year, earlier.month, earlier.day);
    final b = DateTime(later.year, later.month, later.day);
    return b.difference(a).inDays;
  }

  /// Previous Qatar calendar days only — same-day entries stay queued.
  static bool isEligibleForFlush(String queueDate, String currentQatarDate) {
    final queue = parseQatarDateKey(queueDate);
    final current = parseQatarDateKey(currentQatarDate);
    if (queue == null || current == null) return false;
    final q = DateTime(queue.year, queue.month, queue.day);
    final c = DateTime(current.year, current.month, current.day);
    return q.isBefore(c);
  }

  static bool isExpiredByTtl(String queueDate, String currentQatarDate) {
    return qatarCalendarDaysBetween(queueDate, currentQatarDate) > ttlQatarDays;
  }

  static String buildDedupReference(String apiKey, String queueDate) =>
      '$apiKey|cap_overflow_digest|$queueDate';

  static CapOverflowQueueEntry? parseQueueValue(String? raw) {
    if (raw == null || raw.isEmpty) return null;
    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      final count = map['count'];
      final type = map['type'] as String?;
      if (count is! int || count < 1) {
        final parsedCount = int.tryParse('$count');
        if (parsedCount == null || parsedCount < 1) return null;
        return CapOverflowQueueEntry(
          count: parsedCount,
          type: type ?? '',
        );
      }
      return CapOverflowQueueEntry(count: count, type: type ?? '');
    } catch (_) {
      return null;
    }
  }

  static CapOverflowDigestCopy buildDigestCopy({
    required NotificationType type,
    required int heldCount,
    required String locale,
  }) {
    final title = NotificationCopyStrings.t('cap_overflow_digest_title', locale);
    final body = heldCount == 1
        ? NotificationCopyStrings.format(
            'cap_overflow_digest_body_one',
            locale,
            params: {
              'category': categoryLabel(type, locale),
            },
          )
        : NotificationCopyStrings.format(
            'cap_overflow_digest_body_many',
            locale,
            params: {
              'count': '$heldCount',
              'category': categoryLabel(type, locale),
            },
          );
    return CapOverflowDigestCopy(title: title, body: body);
  }

  static String categoryLabel(NotificationType type, String locale) {
    final key = _categoryCopyKey[type];
    if (key == null) {
      return NotificationCopyStrings.t('cap_overflow_category_generic', locale);
    }
    return NotificationCopyStrings.t(key, locale);
  }

  static const _categoryCopyKey = <NotificationType, String>{
    NotificationType.jobMatch: 'cap_overflow_category_jobs',
    NotificationType.housingMatch: 'cap_overflow_category_housing',
    NotificationType.communityReply: 'cap_overflow_category_community',
    NotificationType.groupActivity: 'cap_overflow_category_groups',
    NotificationType.billDue: 'cap_overflow_category_bills',
    NotificationType.documentDeadlineApproaching:
        'cap_overflow_category_documents',
    NotificationType.legalSourceUpdate: 'cap_overflow_category_legal',
    NotificationType.scamShieldIncident: 'cap_overflow_category_safety',
    NotificationType.scamShieldShareAlert: 'cap_overflow_category_safety',
    NotificationType.lifeEventCorrelation: 'cap_overflow_category_life_events',
    NotificationType.lifeIntelligence: 'cap_overflow_category_life_events',
    NotificationType.healthInsuranceReminder:
        'cap_overflow_category_health_insurance',
  };
}

class CapOverflowDigestCopy {
  const CapOverflowDigestCopy({required this.title, required this.body});

  final String title;
  final String body;
}

class CapOverflowQueueEntry {
  const CapOverflowQueueEntry({
    required this.count,
    required this.type,
  });

  final int count;
  final String type;
}
