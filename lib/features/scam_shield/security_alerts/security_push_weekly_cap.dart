import 'package:hive_flutter/hive_flutter.dart';
import 'package:raabta/features/scam_shield/security_alerts/security_alert_config.dart';

/// At most [SecurityAlertConfig.maxSecurityPushesPerWeek] advisory+tip pushes.
abstract final class SecurityPushWeeklyCap {
  static const _boxName = 'scam_security_push_weekly_v1';
  static const _countKey = 'count';
  static const _weekKey = 'week';

  static Future<Box<int>> _box() async {
    if (!Hive.isBoxOpen(_boxName)) {
      await Hive.openBox<int>(_boxName);
    }
    return Hive.box<int>(_boxName);
  }

  static String weekBucket(DateTime at) {
    final utc = at.toUtc();
    final thursday = utc.subtract(Duration(days: (utc.weekday + 3) % 7));
    return '${thursday.year}-${thursday.month}-${thursday.day}';
  }

  static Future<bool> canSend({required DateTime now}) async {
    final box = await _box();
    final bucket = weekBucket(now);
    if (box.get(_weekKey) != bucket.hashCode) {
      return true;
    }
    final count = box.get(_countKey) ?? 0;
    return count < SecurityAlertConfig.maxSecurityPushesPerWeek;
  }

  static Future<void> recordSend({required DateTime now}) async {
    final box = await _box();
    final bucket = weekBucket(now);
    if (box.get(_weekKey) != bucket.hashCode) {
      await box.put(_weekKey, bucket.hashCode);
      await box.put(_countKey, 1);
      return;
    }
    final count = box.get(_countKey) ?? 0;
    await box.put(_countKey, count + 1);
  }

  static Future<void> resetForTest() async {
    if (Hive.isBoxOpen(_boxName)) {
      await Hive.box<int>(_boxName).clear();
    }
  }
}
