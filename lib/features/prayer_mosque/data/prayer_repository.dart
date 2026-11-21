import 'dart:convert';

import 'package:adhan/adhan.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:raabta/features/prayer_mosque/domain/models/prayer_enums.dart';
import 'package:raabta/features/prayer_mosque/domain/models/prayer_record.dart';
import 'package:raabta/features/prayer_mosque/domain/models/prayer_settings.dart';
import 'package:raabta/features/prayer_mosque/domain/models/prayer_schedule.dart';
import 'package:raabta/features/prayer_mosque/services/prayer_location_service.dart';

class PrayerRepository {
  PrayerRepository(this._prefs);

  final SharedPreferences _prefs;

  static const _settingsKey = 'prayer_mosque_settings';
  static const _recordsKey = 'prayer_mosque_records';
  static const _favoritesKey = 'prayer_mosque_favorites';
  static const _completedKey = 'prayer_mosque_completed';
  static const _scheduleCacheKey = 'prayer_mosque_schedule_cache';
  static const _locationCacheKey = 'prayer_mosque_location_cache';

  PrayerSettings loadSettings() {
    final raw = _prefs.getString(_settingsKey);
    if (raw == null) {
      return PrayerSettings(
        perPrayerNotifications: Map<String, bool>.from(
          PrayerSettings.defaultNotifications,
        ),
      );
    }
    try {
      return PrayerSettings.fromJson(
        jsonDecode(raw) as Map<String, dynamic>,
      );
    } catch (_) {
      return const PrayerSettings();
    }
  }

  Future<void> saveSettings(PrayerSettings settings) async {
    await _prefs.setString(_settingsKey, jsonEncode(settings.toJson()));
    if (settings.cloudSyncEnabled) {
      await _syncSettingsToCloud(settings);
    }
  }

  List<String> loadFavoriteIds() {
    return _prefs.getStringList(_favoritesKey) ?? [];
  }

  Future<void> toggleFavorite(String mosqueId) async {
    final ids = loadFavoriteIds();
    if (ids.contains(mosqueId)) {
      ids.remove(mosqueId);
    } else {
      ids.add(mosqueId);
    }
    await _prefs.setStringList(_favoritesKey, ids);
    await _syncFavoritesToCloud(ids);
  }

  bool isFavorite(String mosqueId) => loadFavoriteIds().contains(mosqueId);

  Set<String> loadCompletedToday() {
    final key = _todayKey();
    final raw = _prefs.getString('${_completedKey}_$key');
    if (raw == null) return {};
    return raw.split(',').where((e) => e.isNotEmpty).toSet();
  }

  Future<void> toggleCompleted(String prayerKey) async {
    final key = _todayKey();
    final set = loadCompletedToday();
    if (set.contains(prayerKey)) {
      set.remove(prayerKey);
    } else {
      set.add(prayerKey);
    }
    await _prefs.setString('${_completedKey}_$key', set.join(','));
  }

  List<PrayerRecord> loadRecords() {
    final raw = _prefs.getString(_recordsKey);
    if (raw == null) return [];
    try {
      final list = jsonDecode(raw) as List;
      return list
          .map((e) => PrayerRecord.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> saveRecord(PrayerRecord record) async {
    final records = loadRecords()
      ..removeWhere(
        (r) => r.dateKey == record.dateKey && r.prayerKey == record.prayerKey,
      )
      ..add(record);
    await _prefs.setString(
      _recordsKey,
      jsonEncode(records.map((r) => r.toJson()).toList()),
    );
  }

  PrayerStats computeStats() {
    final records = loadRecords();
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final monthStart = DateTime(now.year, now.month, 1);

    var weekPrayed = 0;
    var weekTotal = 0;
    var monthPrayed = 0;
    var monthTotal = 0;
    var streak = 0;

    for (final record in records) {
      final date = DateTime.tryParse(record.dateKey);
      if (date == null) continue;
      final prayed = _isPrayed(record);
      if (!date.isBefore(monthStart)) {
        monthTotal++;
        if (prayed) monthPrayed++;
      }
      if (!date.isBefore(weekStart)) {
        weekTotal++;
        if (prayed) weekPrayed++;
      }
    }

    for (var i = 0; i < 365; i++) {
      final day = now.subtract(Duration(days: i));
      final key =
          '${day.year}-${day.month.toString().padLeft(2, '0')}-${day.day.toString().padLeft(2, '0')}';
      final dayRecords =
          records.where((r) => r.dateKey == key && _isPrayed(r)).length;
      if (dayRecords >= 3) {
        streak++;
      } else if (i > 0) {
        break;
      }
    }

    return PrayerStats(
      currentStreak: streak,
      weeklyCompletion: weekTotal > 0 ? weekPrayed / weekTotal : 0,
      monthlyCompletion: monthTotal > 0 ? monthPrayed / monthTotal : 0,
      prayerPercentage: records.isEmpty
          ? 0
          : records.where(_isPrayed).length / records.length,
      dailyCounts: {},
    );
  }

  bool _isPrayed(PrayerRecord r) =>
      r.status == PrayerTrackingStatus.prayed ||
      r.status == PrayerTrackingStatus.congregationHome ||
      r.status == PrayerTrackingStatus.congregationMosque;

  Future<void> cacheSchedule(PrayerScheduleDay schedule) async {
    final payload = jsonEncode({
      'date': schedule.date.toIso8601String(),
      'locationLabel': schedule.locationLabel,
      'latitude': schedule.latitude,
      'longitude': schedule.longitude,
      'entries': schedule.entries
          .map(
            (e) => {
              'key': e.key,
              'labelKey': e.labelKey,
              'emoji': e.emoji,
              'time': e.time.toIso8601String(),
              'isSunrise': e.isSunrise,
            },
          )
          .toList(),
    });
    await _prefs.setString(_scheduleCacheKey, payload);
  }

  PrayerScheduleDay? loadCachedSchedule() {
    final raw = _prefs.getString(_scheduleCacheKey);
    if (raw == null) return null;
    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      final entries = (map['entries'] as List).map((e) {
        final m = Map<String, dynamic>.from(e as Map);
        return PrayerScheduleEntry(
          key: m['key'] as String,
          labelKey: m['labelKey'] as String,
          emoji: m['emoji'] as String,
          time: DateTime.parse(m['time'] as String),
          prayer: Prayer.fajr,
          isSunrise: m['isSunrise'] as bool? ?? false,
        );
      }).toList();
      return PrayerScheduleDay(
        date: DateTime.parse(map['date'] as String),
        entries: entries,
        locationLabel: map['locationLabel'] as String? ?? 'Cached',
        latitude: (map['latitude'] as num).toDouble(),
        longitude: (map['longitude'] as num).toDouble(),
      );
    } catch (_) {
      return null;
    }
  }

  Future<void> cacheLocation(PrayerLocationResult location) async {
    await _prefs.setString(
      _locationCacheKey,
      encodeLocationCache(location),
    );
  }

  PrayerLocationResult? loadCachedLocation() =>
      decodeLocationCache(_prefs.getString(_locationCacheKey));

  String _todayKey() {
    final n = DateTime.now();
    return '${n.year}-${n.month.toString().padLeft(2, '0')}-${n.day.toString().padLeft(2, '0')}';
  }

  Future<void> _syncSettingsToCloud(PrayerSettings settings) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('prayer_mosque')
        .doc('settings')
        .set(settings.toJson(), SetOptions(merge: true));
  }

  Future<void> _syncFavoritesToCloud(List<String> ids) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('prayer_mosque')
        .doc('favorites')
        .set({'ids': ids}, SetOptions(merge: true));
  }
}
