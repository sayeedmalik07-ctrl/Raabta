import 'dart:convert';

import 'package:raabta/services/notification_background.dart';

/// Opt-in local reminders for a scanned product expiry date (ephemeral ID).
abstract final class ProductExpiryReminderService {
  static const _idBase = 5200;

  static int _notificationId(String reminderId, int offsetDays) =>
      _idBase + reminderId.hashCode.abs() % 700 + offsetDays;

  static Future<void> schedule({
    required String reminderId,
    required String productLabel,
    required DateTime expiryDate,
  }) async {
    await RaabtaLocalNotifications.instance.initialize();

    for (final daysBefore in const [1, 0]) {
      final notifyAt = DateTime(
        expiryDate.year,
        expiryDate.month,
        expiryDate.day,
      ).subtract(Duration(days: daysBefore));

      final title = daysBefore == 0
          ? 'Product expiry today'
          : 'Product expiring soon';
      final body = daysBefore == 0
          ? '$productLabel expires today. Check before use.'
          : '$productLabel expires tomorrow (${_formatDate(expiryDate)}).';

      await RaabtaLocalNotifications.instance.schedule(
        id: _notificationId(reminderId, daysBefore),
        title: title,
        body: body,
        scheduledDate: notifyAt,
        payload: jsonEncode({
          'route': '/barcode-scanner',
          'type': 'product_expiry',
          'reminderId': reminderId,
        }),
      );
    }
  }

  static Future<void> cancel(String reminderId) async {
    await RaabtaLocalNotifications.instance.initialize();
    for (final daysBefore in const [1, 0]) {
      await RaabtaLocalNotifications.instance.cancel(
        _notificationId(reminderId, daysBefore),
      );
    }
  }

  static String _formatDate(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
}
