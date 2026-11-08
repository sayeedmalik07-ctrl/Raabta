import 'dart:convert';

import 'package:raabta/features/trip_planner/domain/models/trip_preferences.dart';

/// Normalized preference fingerprint for per-user duplicate-prompt cache lookup.
abstract final class TripPromptSignature {
  static String fromPreferences(TripPreferences prefs) {
    final map = Map<String, dynamic>.from(prefs.toJson());
    map['naturalLanguagePrompt'] =
        (map['naturalLanguagePrompt'] as String? ?? '').trim().toLowerCase();
    final styles = List<String>.from(map['travelStyles'] as List? ?? [])
      ..sort();
    map['travelStyles'] = styles;
    return jsonEncode(map);
  }
}
