import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:raabta/features/prayer_mosque/data/mosque_data_source.dart';
import 'package:raabta/features/prayer_mosque/domain/models/prayer_enums.dart';
import 'package:raabta/features/prayer_mosque/domain/models/prayer_schedule.dart';
import 'package:raabta/features/prayer_mosque/domain/models/prayer_settings.dart';
import 'package:raabta/features/prayer_mosque/presentation/l10n/prayer_strings.dart';
import 'package:raabta/services/notifications/notification_service.dart';

class PrayerNotificationService {
  static const channelId = 'raabta_prayer_mosque';
  static const baseId = 5000;
  static const jumuahId = 5010;

  static Future<void> ensureChannel() async {
    if (!Platform.isAndroid) return;
    final plugin = FlutterLocalNotificationsPlugin();
    await plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(
          const AndroidNotificationChannel(
            channelId,
            'Prayer & Mosque',
            description: 'Prayer times, Jumu\'ah, and Islamic reminders',
            importance: Importance.high,
          ),
        );
  }

  static bool _isWeekend(DateTime date) {
    // Qatar weekend: Friday & Saturday
    return date.weekday == DateTime.friday ||
        date.weekday == DateTime.saturday;
  }

  static Future<void> schedulePrayerReminders({
    required PrayerScheduleDay schedule,
    required PrayerSettings settings,
  }) async {
    await ensureChannel();
    if (settings.vacationMode) {
      await cancelAll();
      return;
    }

    final plugin = FlutterLocalNotificationsPlugin();
    await cancelAll();

    final now = DateTime.now();
    for (var i = 0; i < schedule.entries.length; i++) {
      final entry = schedule.entries[i];
      if (entry.isSunrise) continue;
      if (settings.weekendOnly && !_isWeekend(now)) continue;

      final enabled = settings.perPrayerNotifications[entry.key] ??
          (PrayerSettings.defaultNotifications[entry.key] ?? true);
      if (!enabled) continue;
      if (entry.time.isBefore(now)) continue;

      final tzTime = tz.TZDateTime.from(entry.time, tz.local);
      await plugin.zonedSchedule(
        baseId + i,
        PrayerStrings.t('prayer_reminder_title', settings.locale),
        '${PrayerStrings.t(entry.labelKey, settings.locale)} — ${PrayerStrings.t('prayer_time_now', settings.locale)}',
        tzTime,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            channelId,
            'Prayer & Mosque',
            importance: Importance.high,
            priority: Priority.high,
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
      trackScheduled(entry.key);
    }

    await _scheduleJumuah(
      plugin: plugin,
      settings: settings,
      schedule: schedule,
    );
  }

  static Future<void> _scheduleJumuah({
    required FlutterLocalNotificationsPlugin plugin,
    required PrayerSettings settings,
    required PrayerScheduleDay schedule,
  }) async {
    if (DateTime.now().weekday != DateTime.friday) return;

    final mosqueId = settings.favoriteMosqueId;
    final mosque = mosqueId != null
        ? MosqueDataSource().byId(mosqueId)
        : null;
    final jumuahLabel = mosque?.jumuahTime ?? '12:15 PM';
    final reminderTime = _parseJumuahReminder(
      jumuahLabel,
      settings.jumuahReminderOffset.minutesBefore,
    );
    if (reminderTime == null || reminderTime.isBefore(DateTime.now())) return;

    await plugin.zonedSchedule(
      jumuahId,
      PrayerStrings.t('prayer_jumuah', settings.locale),
      '${PrayerStrings.t('prayer_jumuah', settings.locale)} — $jumuahLabel',
      tz.TZDateTime.from(reminderTime, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          channelId,
          'Prayer & Mosque',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  static DateTime? _parseJumuahReminder(String timeLabel, int minutesBefore) {
    final match = RegExp(r'(\d{1,2}):(\d{2})\s*(AM|PM)?', caseSensitive: false)
        .firstMatch(timeLabel);
    if (match == null) return null;
    var hour = int.parse(match.group(1)!);
    final minute = int.parse(match.group(2)!);
    final ampm = match.group(3)?.toUpperCase();
    if (ampm == 'PM' && hour < 12) hour += 12;
    if (ampm == 'AM' && hour == 12) hour = 0;

    final now = DateTime.now();
    final jumuah = DateTime(now.year, now.month, now.day, hour, minute);
    return jumuah.subtract(Duration(minutes: minutesBefore));
  }

  static Future<void> cancelAll() async {
    final plugin = FlutterLocalNotificationsPlugin();
    for (var i = 0; i < 12; i++) {
      await plugin.cancel(baseId + i);
    }
    await plugin.cancel(jumuahId);
  }

  static Future<bool> requestPermission() =>
      NotificationService.requestPermission();

  static void trackScheduled(String prayerKey) {
    debugPrint('[PrayerAnalytics] scheduled: $prayerKey');
  }
}
