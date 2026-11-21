import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

abstract final class TheoryQuizProgressService {
  static const _key = 'driving_theory_quiz_progress_v1';

  static Future<Map<String, int>> loadScores() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_key);
      if (raw == null) return {};
      final map = jsonDecode(raw) as Map<String, dynamic>;
      return map.map((k, v) => MapEntry(k, (v as num).toInt()));
    } catch (_) {
      return {};
    }
  }

  static Future<void> recordAttempt({
    required String modeKey,
    required int score,
    required int total,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final existing = await loadScores();
    existing[modeKey] = score;
    await prefs.setString(_key, jsonEncode(existing));
  }
}
