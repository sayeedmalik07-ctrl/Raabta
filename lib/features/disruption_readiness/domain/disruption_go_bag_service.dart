import 'package:shared_preferences/shared_preferences.dart';

/// Local-only go-bag checklist — never synced to Firestore.
class DisruptionGoBagService {
  /// Non-empty trip id after trim, or null when missing/blank.
  static String? normalizedTripId(String? raw) {
    final id = raw?.trim();
    if (id == null || id.isEmpty) return null;
    return id;
  }

  static bool tripScopeReady(String? tripId) => normalizedTripId(tripId) != null;

  static String storageKey({
    required DisruptionGoBagScope scope,
    String? tripId,
  }) {
    switch (scope) {
      case DisruptionGoBagScope.trip:
        final id = normalizedTripId(tripId);
        if (id == null) {
          throw ArgumentError('tripId required for trip scope');
        }
        return 'disruption_go_bag_trip_$id';
      case DisruptionGoBagScope.leaving:
        return 'disruption_go_bag_leaving';
      case DisruptionGoBagScope.know:
        return 'disruption_go_bag_know';
    }
  }

  Future<Map<String, bool>> load({
    required DisruptionGoBagScope scope,
    String? tripId,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(storageKey(scope: scope, tripId: tripId));
    return _decode(raw);
  }

  Future<void> setItem({
    required DisruptionGoBagScope scope,
    String? tripId,
    required String itemId,
    required bool completed,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final key = storageKey(scope: scope, tripId: tripId);
    final current = _decode(prefs.getString(key));
    current[itemId] = completed;
    await prefs.setString(key, _encode(current));
  }

  Map<String, bool> _decode(String? raw) {
    if (raw == null || raw.isEmpty) return {};
    final result = <String, bool>{};
    for (final part in raw.split('&')) {
      if (part.isEmpty) continue;
      final idx = part.indexOf('=');
      if (idx <= 0) continue;
      result[part.substring(0, idx)] = part.substring(idx + 1) == 'true';
    }
    return result;
  }

  String _encode(Map<String, bool> map) {
    if (map.isEmpty) return '';
    return map.entries.map((e) => '${e.key}=${e.value}').join('&');
  }
}

enum DisruptionGoBagScope {
  trip,
  leaving,
  know,
}
