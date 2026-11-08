import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Opt-in heat / hydration local reminders for Climate Navigator (PDPPL-local only).
class ClimateHeatReminderPreferences {
  const ClimateHeatReminderPreferences({
    required this.enabled,
    required this.activeStart,
    required this.activeEnd,
    required this.quietStart,
    required this.quietEnd,
    required this.beforeShiftEnabled,
  });

  final bool enabled;
  final TimeOfDay activeStart;
  final TimeOfDay activeEnd;
  final TimeOfDay quietStart;
  final TimeOfDay quietEnd;
  final bool beforeShiftEnabled;

  bool get hasActiveWindow =>
      _toMinutes(activeEnd) > _toMinutes(activeStart);

  int get activeStartMinute => _toMinutes(activeStart);

  int get activeEndMinute => _toMinutes(activeEnd);

  int get quietStartMinute => _toMinutes(quietStart);

  int get quietEndMinute => _toMinutes(quietEnd);

  static const _enabledKey = 'climate_hydration_reminder_v1';
  static const _activeStartKey = 'climate_heat_reminder_active_start_v1';
  static const _activeEndKey = 'climate_heat_reminder_active_end_v1';
  static const _quietStartKey = 'climate_heat_reminder_quiet_start_v1';
  static const _quietEndKey = 'climate_heat_reminder_quiet_end_v1';
  static const _beforeShiftKey = 'climate_heat_reminder_before_shift_v1';

  static const defaultActiveStart = TimeOfDay(hour: 7, minute: 0);
  static const defaultActiveEnd = TimeOfDay(hour: 18, minute: 0);
  static const defaultQuietStart = TimeOfDay(hour: 22, minute: 0);
  static const defaultQuietEnd = TimeOfDay(hour: 6, minute: 0);

  static Future<ClimateHeatReminderPreferences> load() async {
    final prefs = await SharedPreferences.getInstance();
    return ClimateHeatReminderPreferences(
      enabled: prefs.getBool(_enabledKey) ?? false,
      activeStart: _readTime(prefs, _activeStartKey, defaultActiveStart),
      activeEnd: _readTime(prefs, _activeEndKey, defaultActiveEnd),
      quietStart: _readTime(prefs, _quietStartKey, defaultQuietStart),
      quietEnd: _readTime(prefs, _quietEndKey, defaultQuietEnd),
      beforeShiftEnabled: prefs.getBool(_beforeShiftKey) ?? true,
    );
  }

  static Future<void> setEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_enabledKey, enabled);
  }

  static Future<bool> isEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_enabledKey) ?? false;
  }

  static Future<void> save(ClimateHeatReminderPreferences value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_enabledKey, value.enabled);
    await prefs.setInt(_activeStartKey, _toMinutes(value.activeStart));
    await prefs.setInt(_activeEndKey, _toMinutes(value.activeEnd));
    await prefs.setInt(_quietStartKey, _toMinutes(value.quietStart));
    await prefs.setInt(_quietEndKey, _toMinutes(value.quietEnd));
    await prefs.setBool(_beforeShiftKey, value.beforeShiftEnabled);
  }

  ClimateHeatReminderPreferences copyWith({
    bool? enabled,
    TimeOfDay? activeStart,
    TimeOfDay? activeEnd,
    TimeOfDay? quietStart,
    TimeOfDay? quietEnd,
    bool? beforeShiftEnabled,
  }) {
    return ClimateHeatReminderPreferences(
      enabled: enabled ?? this.enabled,
      activeStart: activeStart ?? this.activeStart,
      activeEnd: activeEnd ?? this.activeEnd,
      quietStart: quietStart ?? this.quietStart,
      quietEnd: quietEnd ?? this.quietEnd,
      beforeShiftEnabled: beforeShiftEnabled ?? this.beforeShiftEnabled,
    );
  }

  static int _toMinutes(TimeOfDay t) => t.hour * 60 + t.minute;

  static TimeOfDay _fromMinutes(int minutes) {
    return TimeOfDay(hour: minutes ~/ 60, minute: minutes % 60);
  }

  static TimeOfDay _readTime(
    SharedPreferences prefs,
    String key,
    TimeOfDay fallback,
  ) {
    if (!prefs.containsKey(key)) return fallback;
    return _fromMinutes(prefs.getInt(key) ?? _toMinutes(fallback));
  }
}

/// Back-compat alias for older imports.
typedef HydrationReminderPreferences = ClimateHeatReminderPreferences;
