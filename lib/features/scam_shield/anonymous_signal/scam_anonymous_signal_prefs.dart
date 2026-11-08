import 'dart:convert';
import 'dart:math';

import 'package:shared_preferences/shared_preferences.dart';

/// Local-only consent and queue state — default opt-out.
abstract final class ScamAnonymousSignalPrefs {
  static const _optInKey = 'ss_anonymous_signal_opt_in_v1';
  static const _declinedAtKey = 'ss_anonymous_signal_declined_at_v1';
  static const _installKeyKey = 'ss_anonymous_signal_install_key_v1';
  static const _queueKey = 'ss_anonymous_signal_queue_v1';
  static const _lastFlushDayKey = 'ss_anonymous_signal_last_flush_day_v1';
  static const _sentTodayKey = 'ss_anonymous_signal_sent_today_v1';
  static const _sentTodayDayKey = 'ss_anonymous_signal_sent_today_day_v1';
  static const _backoffAttemptKey = 'ss_anonymous_signal_backoff_v1';

  static const declineCooldownDays = 90;

  static Future<bool> isOptedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_optInKey) ?? false;
  }

  static Future<void> setOptedIn(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_optInKey, value);
    if (value) {
      await _ensureInstallKey(prefs);
    } else {
      await clearQueue();
      await prefs.remove(_backoffAttemptKey);
    }
  }

  static Future<DateTime?> declinedAt() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_declinedAtKey);
    if (raw == null || raw.isEmpty) return null;
    return DateTime.tryParse(raw);
  }

  static Future<void> recordDeclined() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_declinedAtKey, DateTime.now().toUtc().toIso8601String());
  }

  static Future<void> clearDeclined() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_declinedAtKey);
  }

  static Future<bool> mayShowConsentPrompt() async {
    if (await isOptedIn()) return false;
    final declined = await declinedAt();
    if (declined == null) return true;
    final elapsed = DateTime.now().toUtc().difference(declined.toUtc());
    return elapsed.inDays >= declineCooldownDays;
  }

  static Future<String?> installKey() async {
    final prefs = await SharedPreferences.getInstance();
    final existing = prefs.getString(_installKeyKey);
    if (existing != null && existing.length >= 16) return existing;
    if (!(await isOptedIn())) return null;
    return _ensureInstallKey(prefs);
  }

  static Future<String> _ensureInstallKey(SharedPreferences prefs) async {
    final existing = prefs.getString(_installKeyKey);
    if (existing != null && existing.length >= 16) return existing;
    final random = Random.secure();
    final bytes = List<int>.generate(32, (_) => random.nextInt(256));
    final key = base64UrlEncode(bytes);
    await prefs.setString(_installKeyKey, key);
    return key;
  }

  static Future<List<Map<String, dynamic>>> readQueue() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_queueKey);
    if (raw == null || raw.isEmpty) return [];
    try {
      final decoded = jsonDecode(raw) as List<dynamic>;
      return decoded
          .whereType<Map>()
          .map((e) => e.map((k, v) => MapEntry(k.toString(), v)))
          .toList();
    } catch (_) {
      return [];
    }
  }

  static Future<void> writeQueue(List<Map<String, dynamic>> events) async {
    final prefs = await SharedPreferences.getInstance();
    if (events.isEmpty) {
      await prefs.remove(_queueKey);
      return;
    }
    await prefs.setString(_queueKey, jsonEncode(events));
  }

  static Future<String?> lastFlushDayUtc() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_lastFlushDayKey);
  }

  static Future<void> markFlushedToday(String dayUtc) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_lastFlushDayKey, dayUtc);
  }

  static Future<int> sentCountToday(String dayUtc) async {
    final prefs = await SharedPreferences.getInstance();
    final storedDay = prefs.getString(_sentTodayDayKey);
    if (storedDay != dayUtc) return 0;
    return prefs.getInt(_sentTodayKey) ?? 0;
  }

  static Future<void> addSentCountToday(String dayUtc, int delta) async {
    final prefs = await SharedPreferences.getInstance();
    final storedDay = prefs.getString(_sentTodayDayKey);
    var count = 0;
    if (storedDay == dayUtc) {
      count = prefs.getInt(_sentTodayKey) ?? 0;
    }
    await prefs.setString(_sentTodayDayKey, dayUtc);
    await prefs.setInt(_sentTodayKey, count + delta);
  }

  static Future<int> backoffAttempt() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_backoffAttemptKey) ?? 0;
  }

  static Future<void> setBackoffAttempt(int value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_backoffAttemptKey, value);
  }

  static Future<void> clearQueue() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_queueKey);
  }
}
