import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class ClimateRouteHistoryEntry {
  const ClimateRouteHistoryEntry({
    required this.from,
    required this.to,
    required this.savedAt,
  });

  final String from;
  final String to;
  final DateTime savedAt;

  Map<String, dynamic> toJson() => {
        'from': from,
        'to': to,
        'savedAt': savedAt.toIso8601String(),
      };

  factory ClimateRouteHistoryEntry.fromJson(Map<String, dynamic> json) {
    return ClimateRouteHistoryEntry(
      from: json['from'] as String? ?? '',
      to: json['to'] as String? ?? '',
      savedAt: DateTime.tryParse(json['savedAt'] as String? ?? '') ??
          DateTime.now(),
    );
  }
}

abstract final class ClimateRouteHistoryRepository {
  static const _key = 'climate_route_history_v1';
  static const _maxEntries = 5;

  static Future<List<ClimateRouteHistoryEntry>> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null || raw.isEmpty) return const [];

    try {
      final list = jsonDecode(raw) as List<dynamic>;
      return list
          .map(
            (e) => ClimateRouteHistoryEntry.fromJson(
              e as Map<String, dynamic>,
            ),
          )
          .where((e) => e.from.isNotEmpty && e.to.isNotEmpty)
          .toList();
    } catch (_) {
      return const [];
    }
  }

  static Future<void> save({
    required String from,
    required String to,
  }) async {
    final trimmedFrom = from.trim();
    final trimmedTo = to.trim();
    if (trimmedFrom.isEmpty || trimmedTo.isEmpty) return;

    final prefs = await SharedPreferences.getInstance();
    final existing = await load();

    final updated = [
      ClimateRouteHistoryEntry(
        from: trimmedFrom,
        to: trimmedTo,
        savedAt: DateTime.now(),
      ),
      ...existing.where(
        (e) =>
            e.from.toLowerCase() != trimmedFrom.toLowerCase() ||
            e.to.toLowerCase() != trimmedTo.toLowerCase(),
      ),
    ].take(_maxEntries).toList();

    await prefs.setString(
      _key,
      jsonEncode(updated.map((e) => e.toJson()).toList()),
    );
  }
}
