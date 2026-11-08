import 'dart:io';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import '../../core/constants/reminder_constants.dart';

// ─── Notification channels ───────────────────────────────

class NotificationChannels {
  NotificationChannels._();

  // Document expiry (QID, visa, labour card)
  static const String documentExpiry = 'raabta_document_expiry';

  // Recurring bill split reminders
  static const String billSplit = 'raabta_bill_split';

  // Heat safety alerts (summer months only)
  static const String heatSafety = 'raabta_heat_safety';

  // General RAABTA alerts
  static const String general = 'raabta_general';
}

// ─── Notification ID ranges ──────────────────────────────
// Keeps IDs unique across feature areas

class NotificationIds {
  NotificationIds._();
  // 1000-1999: document expiry
  // 2000-2999: bill split reminders
  // 3000-3999: heat safety
  // 4000+:     general

  static int documentExpiryId(String docId, int daysBefore) {
    return 1000 + docId.hashCode.abs() % 900 + daysBefore;
  }

  static int billSplitId(String groupId) {
    return 2000 + groupId.hashCode.abs() % 999;
  }

  static int heatSafetyId() => 3001;

  /// 3002–3009: hydration break reminders (Climate Navigator opt-in).
  static int hydrationReminderId(int slot) => 3002 + slot;

  static const hydrationReminderSlotCount = 8;

  static int generalId(int n) => 4000 + n;
}

// ─── SERVICE ─────────────────────────────────────────────

class NotificationService {
  static final _plugin = FlutterLocalNotificationsPlugin();
  static bool _initialized = false;

  // ── Initialize once at app startup ───────────────────
  static Future<void> initialize() async {
    if (_initialized) return;

    tz.initializeTimeZones();
    // Qatar is UTC+3 always (no DST)
    tz.setLocalLocation(tz.getLocation('Asia/Qatar'));

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const darwinSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    await _plugin.initialize(
      const InitializationSettings(
        android: androidSettings,
        iOS: darwinSettings,
        macOS: darwinSettings,
      ),
    );

    // Android: create notification channels
    if (Platform.isAndroid) {
      await _plugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(
            const AndroidNotificationChannel(
              NotificationChannels.documentExpiry,
              'Document Expiry Reminders',
              description:
                  'Reminders when QID, visa, or other '
                  'documents are about to expire',
              importance: Importance.high,
            ),
          );
      await _plugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(
            const AndroidNotificationChannel(
              NotificationChannels.billSplit,
              'Bill Split Reminders',
              description: 'Monthly recurring split reminders',
              importance: Importance.defaultImportance,
            ),
          );
      await _plugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(
            const AndroidNotificationChannel(
              NotificationChannels.heatSafety,
              'Heat Safety Alerts',
              description:
                  'Daily heat index alerts during '
                  'Qatar summer months',
              importance: Importance.high,
            ),
          );
    }

    _initialized = true;
  }

  // ── Request permission ────────────────────────────────
  static Future<bool> requestPermission() async {
    if (Platform.isIOS) {
      final granted = await _plugin
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );
      return granted ?? false;
    }
    if (Platform.isAndroid) {
      final androidPlugin = _plugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      final granted =
          await androidPlugin?.requestNotificationsPermission();
      return granted ?? false;
    }
    return false;
  }

  // ── DOCUMENT EXPIRY REMINDERS ─────────────────────────
  // Schedules 3 notifications: 30, 14, and 3 days before
  // Uses ReminderConstants from Prompt 1
  static Future<void> scheduleDocumentExpiryReminders({
    required String docId,
    required String docTypeName,
    required DateTime expiryDate,
  }) async {
    if (!_initialized) return;

    await cancelDocumentReminders(docId);

    for (final daysBefore in ReminderConstants.expiryReminderDaysBefore) {
      final scheduleDate = expiryDate.subtract(
        Duration(days: daysBefore),
      );

      // Skip if reminder date is in the past
      if (scheduleDate.isBefore(DateTime.now())) continue;

      final tzDate = tz.TZDateTime.from(
        scheduleDate,
        tz.local,
      );

      await _plugin.zonedSchedule(
        NotificationIds.documentExpiryId(docId, daysBefore),
        ReminderConstants.expiryReminderTitle,
        ReminderConstants.expiryReminderBody(
          docTypeName,
          daysBefore,
        ),
        tzDate,
        NotificationDetails(
          android: AndroidNotificationDetails(
            NotificationChannels.documentExpiry,
            'Document Expiry',
            importance: Importance.high,
            priority: Priority.high,
            styleInformation: const BigTextStyleInformation(''),
          ),
          iOS: const DarwinNotificationDetails(
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
  }

  // ── Cancel document reminders ─────────────────────────
  static Future<void> cancelDocumentReminders(String docId) async {
    if (!_initialized) return;

    for (final days in ReminderConstants.expiryReminderDaysBefore) {
      await _plugin.cancel(
        NotificationIds.documentExpiryId(docId, days),
      );
    }
  }

  // ── BILL SPLIT MONTHLY REMINDER ───────────────────────
  static Future<void> scheduleBillSplitReminder({
    required String groupId,
    required String groupName,
    required String billTypeLabel,
    required double totalQar,
    required int memberCount,
    required DateTime nextCycleDate,
  }) async {
    if (!_initialized) return;

    // Schedule 1 day before the cycle date at 9 AM
    final reminderDate = nextCycleDate
        .subtract(const Duration(days: 1))
        .copyWith(hour: 9, minute: 0);

    if (reminderDate.isBefore(DateTime.now())) return;

    final tzDate = tz.TZDateTime.from(
      reminderDate,
      tz.local,
    );

    await _plugin.zonedSchedule(
      NotificationIds.billSplitId(groupId),
      '🔄 $groupName split is ready',
      'QAR ${totalQar.toStringAsFixed(0)} split with '
          '$memberCount people — send reminder to group',
      tzDate,
      NotificationDetails(
        android: AndroidNotificationDetails(
          NotificationChannels.billSplit,
          'Bill Split',
          importance: Importance.defaultImportance,
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentSound: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  // ── DAILY HEAT SAFETY ALERT ───────────────────────────
  // Only scheduled during Qatar summer months (May-Sep)
  // Shows daily at 10 AM with current heat risk level
  static Future<void> scheduleHeatSafetyAlert({
    required double heatIndexC,
    required String heatRiskLabel,
  }) async {
    if (!_initialized) return;

    final month = DateTime.now().month;
    final isPeakSummer = month >= 5 && month <= 9;
    if (!isPeakSummer) {
      await cancelHeatSafetyAlert();
      return;
    }

    if (heatIndexC < 38) {
      await cancelHeatSafetyAlert();
      return;
    }

    final now = DateTime.now();
    var scheduleDate = DateTime(
      now.year,
      now.month,
      now.day,
      10,
      0,
    );
    if (scheduleDate.isBefore(now)) {
      scheduleDate = scheduleDate.add(const Duration(days: 1));
    }

    final tzDate = tz.TZDateTime.from(
      scheduleDate,
      tz.local,
    );

    await _plugin.zonedSchedule(
      NotificationIds.heatSafetyId(),
      '🌡️ Qatar Heat Alert — $heatRiskLabel',
      'Heat index ${heatIndexC.toStringAsFixed(0)}°C today. '
          'Avoid outdoor activity 11AM-4PM. '
          'Stay hydrated.',
      tzDate,
      NotificationDetails(
        android: AndroidNotificationDetails(
          NotificationChannels.heatSafety,
          'Heat Safety',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentSound: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  static Future<void> cancelHeatSafetyAlert() async {
    if (!_initialized) return;
    await _plugin.cancel(NotificationIds.heatSafetyId());
  }

  // ── HYDRATION / REST BREAK REMINDERS (opt-in) ──────────
  static Future<void> setHydrationRemindersEnabled({
    required bool enabled,
    required String title,
    required String body,
  }) async {
    await _cancelHydrationReminders();
    if (!enabled || !_initialized) return;

    final now = DateTime.now();
    for (var slot = 0;
        slot < NotificationIds.hydrationReminderSlotCount;
        slot++) {
      final when = now.add(Duration(minutes: 30 * (slot + 1)));
      final tzDate = tz.TZDateTime.from(when, tz.local);
      await _plugin.zonedSchedule(
        NotificationIds.hydrationReminderId(slot),
        title,
        body,
        tzDate,
        NotificationDetails(
          android: AndroidNotificationDetails(
            NotificationChannels.heatSafety,
            'Heat Safety',
            importance: Importance.defaultImportance,
          ),
          iOS: const DarwinNotificationDetails(
            presentAlert: true,
            presentSound: true,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
    }
  }

  static Future<void> _cancelHydrationReminders() async {
    if (!_initialized) return;
    for (var slot = 0;
        slot < NotificationIds.hydrationReminderSlotCount;
        slot++) {
      await _plugin.cancel(NotificationIds.hydrationReminderId(slot));
    }
  }

  // ── Cancel all RAABTA notifications ──────────────────
  static Future<void> cancelAll() async {
    if (!_initialized) return;
    await _plugin.cancelAll();
  }
}

// ─── Provider ────────────────────────────────────────────

final notificationServiceProvider =
    Provider<NotificationService>((_) => NotificationService());
