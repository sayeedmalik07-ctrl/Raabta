import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// Offline fallback — stores recent successful AI translations on device.
class CachedLandmarkTranslation {
  const CachedLandmarkTranslation({
    required this.input,
    required this.arabic,
    required this.englishGps,
    this.area,
    this.confidence,
  });

  final String input;
  final String arabic;
  final String englishGps;
  final String? area;
  final String? confidence;

  Map<String, dynamic> toJson() => {
        'input': input,
        'arabic': arabic,
        'englishGps': englishGps,
        if (area != null) 'area': area,
        if (confidence != null) 'confidence': confidence,
      };

  factory CachedLandmarkTranslation.fromJson(Map<String, dynamic> json) {
    return CachedLandmarkTranslation(
      input: json['input'] as String? ?? '',
      arabic: json['arabic'] as String? ?? '',
      englishGps: json['englishGps'] as String? ?? '',
      area: json['area'] as String?,
      confidence: json['confidence'] as String?,
    );
  }
}

abstract final class LandmarkTranslationCache {
  static const _key = 'landmark_translation_cache_v1';
  static const _maxEntries = 20;

  static String normalizeInput(String input) =>
      input.trim().toLowerCase().replaceAll(RegExp(r'\s+'), ' ');

  static Future<void> save(CachedLandmarkTranslation entry) async {
    final prefs = await SharedPreferences.getInstance();
    final entries = await _loadAll(prefs);
    final key = normalizeInput(entry.input);
    entries.removeWhere((e) => normalizeInput(e.input) == key);
    entries.insert(0, entry);
    if (entries.length > _maxEntries) {
      entries.removeRange(_maxEntries, entries.length);
    }
    await prefs.setString(
      _key,
      jsonEncode(entries.map((e) => e.toJson()).toList()),
    );
  }

  static Future<CachedLandmarkTranslation?> find(String input) async {
    final prefs = await SharedPreferences.getInstance();
    final key = normalizeInput(input);
    for (final entry in await _loadAll(prefs)) {
      if (normalizeInput(entry.input) == key) return entry;
    }
    return null;
  }

  static Future<List<CachedLandmarkTranslation>> _loadAll(
    SharedPreferences prefs,
  ) async {
    final raw = prefs.getString(_key);
    if (raw == null) return [];
    try {
      final decoded = jsonDecode(raw) as List<dynamic>;
      return decoded
          .map(
            (e) => CachedLandmarkTranslation.fromJson(
              e as Map<String, dynamic>,
            ),
          )
          .toList();
    } catch (_) {
      return [];
    }
  }
}
