import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

/// Qatar wall clock for the Home Doha scene (matches notification scheduling).
abstract final class HomeDohaQatarClock {
  static tz.Location get qatarLocation {
    tz_data.initializeTimeZones();
    return tz.getLocation('Asia/Qatar');
  }

  /// Current Qatar time, or [clock] components interpreted as Qatar local.
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