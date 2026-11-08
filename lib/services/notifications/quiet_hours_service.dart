import 'package:raabta/models/notification_models.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

/// Quiet hours always computed in Asia/Qatar regardless of device timezone.
class QuietHoursService {
  QuietHoursService._();
  static final QuietHoursService instance = QuietHoursService._();

  static bool _tzReady = false;

  void _ensureTz() {
    if (_tzReady) return;
    tz_data.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Qatar'));
    _tzReady = true;
  }

  bool isQuietHours(NotificationSettings settings) {
    if (!settings.quietHoursEnabled) return false;
    _ensureTz();
    final hour = tz.TZDateTime.now(tz.getLocation('Asia/Qatar')).hour;
    final start = settings.quietHoursStart;
    final end = settings.quietHoursEnd;
    if (start > end) return hour >= start || hour < end;
    return hour >= start && hour < end;
  }

  bool isExemptDuringQuietHours(NotificationType type, NotificationSettings s) {
    if (type == NotificationType.adminAnnouncement && s.adminAnnouncement) {
      return true;
    }
    if (type == NotificationType.emergency && s.emergency) {
      return true;
    }
    return false;
  }

  /// Moves a scheduled local notification out of quiet hours (Asia/Qatar clock).
  DateTime adjustScheduledTime(DateTime scheduled, NotificationSettings settings) {
    if (!settings.quietHoursEnabled) return scheduled;
    final hour = scheduled.hour;
    final start = settings.quietHoursStart;
    final end = settings.quietHoursEnd;
    final inQuiet = start > end
        ? hour >= start || hour < end
        : hour >= start && hour < end;
    if (!inQuiet) return scheduled;
    return DateTime(scheduled.year, scheduled.month, scheduled.day, end);
  }
}
