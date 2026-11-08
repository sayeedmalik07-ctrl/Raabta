import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

/// Shared weekly push budget for Life Intelligence (V2).
abstract final class LifeIntelligenceWeeklyCap {
  static const kLifeIntelligenceWeeklyCap = 1;
  static const _boxName = 'life_intelligence_weekly_cap_v1';
  static const _namespace = 'life_intelligence';

  static Box<int>? _box;
  static bool _tzReady = false;

  static Future<void> init() async {
    if (_box != null && _box!.isOpen) return;
    try {
      if (!Hive.isBoxOpen(_boxName)) {
        await _ensureHive();
        _box = await Hive.openBox<int>(_boxName);
      } else {
        _box = Hive.box<int>(_boxName);
      }
    } catch (e) {
      debugPrint('LifeIntelligenceWeeklyCap Hive init failed: $e');
    }
  }

  static Future<void> _ensureHive() async {
    if (_tzReady) return;
    try {
      await Hive.initFlutter();
    } catch (_) {
      Hive.init('raabta_hive');
    }
    tz_data.initializeTimeZones();
    _tzReady = true;
  }

  /// ISO week key in Qatar timezone, e.g. `2026-W39|life_intelligence`.
  static String weekKeyFor([DateTime? at]) {
    final qatar = tz.getLocation('Asia/Qatar');
    final dt = at != null
        ? tz.TZDateTime.from(at, qatar)
        : tz.TZDateTime.now(qatar);
    final iso = _isoWeekYear(dt);
    return '${iso.$1}-W${iso.$2.toString().padLeft(2, '0')}|$_namespace';
  }

  /// Returns ISO week-year and week number (1–53).
  static (int, int) _isoWeekYear(tz.TZDateTime dt) {
    final date = DateTime(dt.year, dt.month, dt.day);
    final thursday = date.add(Duration(days: 4 - date.weekday));
    final isoYear = thursday.year;
    final jan4 = DateTime(isoYear, 1, 4);
    final week1Monday = jan4.subtract(Duration(days: jan4.weekday - 1));
    final week =
        ((thursday.difference(week1Monday).inDays) / 7).floor() + 1;
    return (isoYear, week);
  }

  static Future<int> currentCount({DateTime? at}) async {
    await init();
    final box = _box;
    if (box == null) return 0;
    return box.get(weekKeyFor(at)) ?? 0;
  }

  static Future<bool> isCapReached({DateTime? at}) async {
    return (await currentCount(at: at)) >= kLifeIntelligenceWeeklyCap;
  }

  static Future<void> recordDelivery({DateTime? at}) async {
    await init();
    final box = _box;
    if (box == null) return;
    final key = weekKeyFor(at);
    await box.put(key, (box.get(key) ?? 0) + 1);
    await _purgeOldWeeks(box, at ?? DateTime.now());
  }

  static Future<void> _purgeOldWeeks(Box<int> box, DateTime now) async {
    final current = weekKeyFor(now);
    final toDelete = <dynamic>[];
    for (final key in box.keys) {
      if (key is! String) continue;
      if (key == current) continue;
      toDelete.add(key);
    }
    for (final key in toDelete) {
      await box.delete(key);
    }
  }
}
