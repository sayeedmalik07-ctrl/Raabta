import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:raabta/features/trip_planner/domain/models/trip_plan.dart';
import 'package:raabta/features/trip_planner/domain/models/trip_preferences.dart';
import 'package:raabta/features/trip_planner/domain/services/trip_planner_config.dart';

class TripPlannerRepository {
  TripPlannerRepository(this._prefs);

  final SharedPreferences _prefs;

  static const _tripsKey = 'trip_planner_saved_trips';
  static const _settingsKey = 'trip_planner_settings';
  static const _activeTripKey = 'trip_planner_active_trip';
  static const _savedPlacesKey = 'trip_planner_saved_places';

  String _promptCacheKey([String? userId]) =>
      'trip_planner_prompt_cache_${userId ?? _currentUserId()}';

  String _currentUserId() =>
      FirebaseAuth.instance.currentUser?.uid ?? 'local_guest';

  Future<List<TripPlan>> loadTrips() async {
    final raw = _prefs.getString(_tripsKey);
    if (raw == null) return [];
    try {
      final list = jsonDecode(raw) as List;
      return list
          .map(
            (e) => TripPlan.fromJson(Map<String, dynamic>.from(e as Map)),
          )
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> saveTrip(TripPlan trip) async {
    final trips = await loadTrips();
    trips.removeWhere((t) => t.id == trip.id);
    trips.insert(0, trip);
    final trimmed = trips.take(30).toList();
    await _prefs.setString(
      _tripsKey,
      jsonEncode(trimmed.map((t) => t.toJson()).toList()),
    );
    await _syncTripToCloud(trip);
  }

  Future<void> deleteTrip(String id) async {
    final trips = await loadTrips();
    trips.removeWhere((t) => t.id == id);
    await _prefs.setString(
      _tripsKey,
      jsonEncode(trips.map((t) => t.toJson()).toList()),
    );
  }

  Future<TripPlan?> getTrip(String id) async {
    final trips = await loadTrips();
    try {
      return trips.firstWhere((t) => t.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<TripPlan?> getByShareCode(String code) async {
    final trips = await loadTrips();
    try {
      return trips.firstWhere(
        (t) => t.shareCode?.toUpperCase() == code.toUpperCase(),
      );
    } catch (_) {
      return null;
    }
  }

  Future<void> setActiveTripId(String? id) async {
    if (id == null) {
      await _prefs.remove(_activeTripKey);
    } else {
      await _prefs.setString(_activeTripKey, id);
    }
  }

  String? getActiveTripId() => _prefs.getString(_activeTripKey);

  TripPreferences loadDefaultPreferences() {
    final raw = _prefs.getString(_settingsKey);
    if (raw == null) return const TripPreferences();
    try {
      return TripPreferences.fromJson(
        jsonDecode(raw) as Map<String, dynamic>,
      );
    } catch (_) {
      return const TripPreferences();
    }
  }

  Future<bool> saveDefaultPreferences(TripPreferences prefs) async {
    return _prefs.setString(_settingsKey, jsonEncode(prefs.toJson()));
  }

  Future<void> toggleFavorite(String tripId) async {
    final trip = await getTrip(tripId);
    if (trip == null) return;
    await saveTrip(trip.copyWith(isFavorite: !trip.isFavorite));
  }

  List<String> loadSavedPlaceIds() {
    return _prefs.getStringList(_savedPlacesKey) ?? [];
  }

  Future<void> toggleSavedPlace(String placeId) async {
    final ids = loadSavedPlaceIds();
    if (ids.contains(placeId)) {
      ids.remove(placeId);
    } else {
      ids.insert(0, placeId);
    }
    await _prefs.setStringList(_savedPlacesKey, ids.take(50).toList());
  }

  /// Per-user exact-prompt cache — never shared across users.
  Future<TripPlan?> loadCachedPlanForSignature(String signature) async {
    final entries = _loadPromptCacheEntries();
    final now = DateTime.now();
    final ttl = Duration(hours: TripPlannerConfig.promptCacheTtlHours);

    for (final entry in entries) {
      if (entry['signature'] != signature) continue;
      final storedAt =
          DateTime.tryParse(entry['storedAt'] as String? ?? '') ?? now;
      if (now.difference(storedAt) > ttl) continue;

      final planMap = entry['plan'] as Map<String, dynamic>?;
      if (planMap == null) continue;
      return TripPlan.fromJson(planMap);
    }
    return null;
  }

  Future<void> savePromptCache({
    required String signature,
    required TripPlan plan,
  }) async {
    final entries = _loadPromptCacheEntries()
      ..removeWhere((e) => e['signature'] == signature);
    entries.insert(0, {
      'signature': signature,
      'storedAt': DateTime.now().toIso8601String(),
      'plan': plan.toJson(),
    });

    final trimmed = entries.take(TripPlannerConfig.promptCacheMaxEntries).toList();
    await _prefs.setString(
      _promptCacheKey(),
      jsonEncode(trimmed),
    );
  }

  List<Map<String, dynamic>> _loadPromptCacheEntries() {
    final raw = _prefs.getString(_promptCacheKey());
    if (raw == null) return [];
    try {
      final list = jsonDecode(raw) as List;
      return list
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> _syncTripToCloud(TripPlan trip) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('user_trips')
        .doc(trip.id)
        .set(trip.toJson(), SetOptions(merge: true));
  }
}
