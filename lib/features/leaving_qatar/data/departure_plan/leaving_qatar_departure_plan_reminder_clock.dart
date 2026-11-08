import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

/// Qatar (Asia/Qatar) wall clock for departure-plan reminders — matches
/// [RaabtaLocalNotifications] scheduling (`tz.local` → Asia/Qatar after init).
abstract final class LeavingQatarDeparturePlanReminderClock {
  static tz.Location get qatarLocation {
    tz_data.initializeTimeZones();
    return tz.getLocation('Asia/Qatar');
  }

  /// Current time in Qatar, or [clock] components interpreted as Qatar local.
  static tz.TZDateTime now({DateTime Function()? clock}) {
    if (clock != null) {
      final c = clock();
      return tz.TZDateTime(
        qatarLocation,
        c.year,
        c.month,
        c.day,
        c.hour,
        c.minute,
        c.second,
        c.millisecond,
        c.microsecond,
      );
    }
    return tz.TZDateTime.now(qatarLocation);
  }
}
