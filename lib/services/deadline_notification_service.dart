import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:raabta/models/visa_models.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class DeadlineNotificationService {
  DeadlineNotificationService._();
  static final DeadlineNotificationService instance =
      DeadlineNotificationService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  static const _androidChannel = AndroidNotificationChannel(
    'deadline_reminders',
    'Document Deadline Reminders',
    description: 'Reminders for Qatar document expiry dates',
    importance: Importance.high,
  );

  Future<void> initialize() async {
    if (_initialized) return;

    try {
      tz.initializeTimeZones();

      const androidSettings =
          AndroidInitializationSettings('@mipmap/ic_launcher');
      const darwinSettings = DarwinInitializationSettings();
      const settings = InitializationSettings(
        android: androidSettings,
        iOS: darwinSettings,
        macOS: darwinSettings,
      );

      await _plugin.initialize(settings);

      await _plugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(_androidChannel);

      _initialized = true;
      debugPrint('Deadline notifications initialized');
    } catch (e) {
      debugPrint('Notification init failed: $e');
    }
  }

  Future<void> scheduleDeadlineNotifications(DocumentDeadline deadline) async {
    if (!_initialized) return;

    await cancelDeadlineNotifications(deadline.id);

    final offsets = [90, 30, 7, 1];
    for (final daysBefore in offsets) {
      final notifyDate = deadline.expiryDate.subtract(Duration(days: daysBefore));
      if (notifyDate.isBefore(DateTime.now())) continue;

      final id = _notificationId(deadline.id, daysBefore);
      await _scheduleNotification(
        id: id,
        title: '${deadline.documentType} expiring soon',
        body: daysBefore == 1
            ? 'Your ${deadline.documentType} expires tomorrow!'
            : 'Your ${deadline.documentType} expires in $daysBefore days.',
        scheduledDate: notifyDate,
      );
    }
  }

  Future<void> cancelDeadlineNotifications(String deadlineId) async {
    if (!_initialized) return;
    for (final days in [90, 30, 7, 1]) {
      await _plugin.cancel(_notificationId(deadlineId, days));
    }
  }

  Future<void> rescheduleAll(List<DocumentDeadline> deadlines) async {
    for (final deadline in deadlines) {
      await scheduleDeadlineNotifications(deadline);
    }
  }

  int _notificationId(String deadlineId, int daysBefore) {
    return deadlineId.hashCode + daysBefore;
  }

  Future<void> _scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
  }) async {
    final scheduled = tz.TZDateTime.from(scheduledDate, tz.local);

    await _plugin.zonedSchedule(
      id,
      title,
      body,
      scheduled,
      NotificationDetails(
        android: AndroidNotificationDetails(
          _androidChannel.id,
          _androidChannel.name,
          channelDescription: _androidChannel.description,
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: const DarwinNotificationDetails(),
        macOS: const DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }
}
