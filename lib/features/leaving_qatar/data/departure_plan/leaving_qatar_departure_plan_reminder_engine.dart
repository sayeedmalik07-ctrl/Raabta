import 'package:raabta/features/leaving_qatar/data/departure_plan/leaving_qatar_departure_plan_catalog.dart';
import 'package:raabta/features/leaving_qatar/data/departure_plan/leaving_qatar_departure_plan_models.dart';
import 'package:raabta/features/leaving_qatar/data/departure_plan/leaving_qatar_departure_plan_reminder_clock.dart';
import 'package:raabta/features/leaving_qatar/data/departure_plan/leaving_qatar_departure_plan_reminder_timing.dart';
import 'package:raabta/models/notification_models.dart';
import 'package:raabta/services/notifications/quiet_hours_service.dart';
import 'package:timezone/timezone.dart' as tz;

/// One combined local notification for a Qatar calendar reminder day.
class DeparturePlanReminderDay {
  const DeparturePlanReminderDay({
    required this.qatarDateKey,
    required this.itemCount,
    required this.scheduledAt,
  });

  /// `YYYY-MM-DD` in Qatar calendar semantics (date-only, not device TZ).
  final String qatarDateKey;
  final int itemCount;

  /// Fire time as Qatar-local wall clock (passed to [RaabtaLocalNotifications.schedule]).
  final DateTime scheduledAt;
}

/// Pure schedule builder for Departure Plan reminders (Asia/Qatar calendar).
abstract final class LeavingQatarDeparturePlanReminderEngine {
  static const defaultReminderHour = 9;

  static List<DeparturePlanReminderDay> buildSchedule({
    required LeavingQatarDeparturePlanState plan,
    tz.TZDateTime? now,
    DateTime Function()? clock,
    NotificationSettings settings = const NotificationSettings(),
    QuietHoursService? quietHours,
    int reminderHour = defaultReminderHour,
  }) {
    final qatarNow =
        now ?? LeavingQatarDeparturePlanReminderClock.now(clock: clock);

    final departure = plan.plannedDepartureDate;
    if (departure == null ||
        !LeavingQatarDeparturePlanDate.isValidIsoDate(departure)) {
      return const [];
    }

    final countsByDay = <String, int>{};

    for (final item in LeavingQatarDeparturePlanCatalog.items) {
      if (plan.isCompleted(item.id)) continue;
      final offsets = LeavingQatarDeparturePlanReminderTiming.offsetsFor(item.id);
      if (offsets.isEmpty) continue;

      for (final daysBefore in offsets) {
        final reminderDay = _subtractCalendarDays(departure, daysBefore);
        if (reminderDay == null) continue;
        final key = LeavingQatarDeparturePlanDate.formatDateOnly(reminderDay);
        countsByDay[key] = (countsByDay[key] ?? 0) + 1;
      }
    }

    if (countsByDay.isEmpty) return const [];

    final location = LeavingQatarDeparturePlanReminderClock.qatarLocation;
    final out = <DeparturePlanReminderDay>[];
    final sortedKeys = countsByDay.keys.toList()..sort();
    for (final key in sortedKeys) {
      final parts = key.split('-');
      final raw = tz.TZDateTime(
        location,
        int.parse(parts[0]),
        int.parse(parts[1]),
        int.parse(parts[2]),
        reminderHour,
      );
      final adjustedWall = (quietHours ?? QuietHoursService.instance)
          .adjustScheduledTime(
        DateTime(
          raw.year,
          raw.month,
          raw.day,
          raw.hour,
          raw.minute,
          raw.second,
        ),
        settings,
      );
      final scheduled = tz.TZDateTime(
        location,
        adjustedWall.year,
        adjustedWall.month,
        adjustedWall.day,
        adjustedWall.hour,
        adjustedWall.minute,
        adjustedWall.second,
      );
      if (!scheduled.isAfter(qatarNow)) continue;
      out.add(
        DeparturePlanReminderDay(
          qatarDateKey: key,
          itemCount: countsByDay[key]!,
          scheduledAt: scheduled,
        ),
      );
    }
    return out;
  }

  static bool hasSchedulableDays({
    required LeavingQatarDeparturePlanState plan,
    tz.TZDateTime? now,
    DateTime Function()? clock,
    NotificationSettings settings = const NotificationSettings(),
  }) {
    return buildSchedule(
      plan: plan,
      now: now,
      clock: clock,
      settings: settings,
    ).isNotEmpty;
  }

  static DateTime? _subtractCalendarDays(String departureIso, int daysBefore) {
    if (daysBefore < 0) return null;
    final parts = departureIso.split('-');
    final year = int.tryParse(parts[0]);
    final month = int.tryParse(parts[1]);
    final day = int.tryParse(parts[2]);
    if (year == null || month == null || day == null) return null;
    return DateTime.utc(year, month, day).subtract(Duration(days: daysBefore));
  }
}
