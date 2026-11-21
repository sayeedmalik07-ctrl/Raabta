import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:raabta/features/quick_actions/climate_navigator/models/climate_wbgt_meter_reading.dart';

abstract final class ClimateWbgtMeterValidation {
  static const minC = 20.0;
  static const maxC = 45.0;

  static bool isValidWbgtValue(double? value) {
    if (value == null) return false;
    if (!value.isFinite) return false;
    return value >= minC && value <= maxC;
  }

  static double? parseWbgtInput(String raw) {
    final trimmed = raw.trim();
    if (trimmed.isEmpty) return null;
    final value = double.tryParse(trimmed.replaceAll(',', '.'));
    if (!isValidWbgtValue(value)) return null;
    return value;
  }

  /// Rejects likely phone numbers and person names in short notes.
  static bool isNoteAllowed(String? note) {
    if (note == null) return true;
    final trimmed = note.trim();
    if (trimmed.isEmpty) return true;
    if (trimmed.length > 120) return false;

    final digitsOnly = trimmed.replaceAll(RegExp(r'\D'), '');
    if (digitsOnly.length >= 7) return false;

    if (RegExp(r'\+?\d[\d\s\-().]{6,}\d').hasMatch(trimmed)) {
      return false;
    }

    final nameLike = RegExp(
      r'^[A-Z][a-zA-Z\-]{1,24}\s+[A-Z][a-zA-Z\-]{1,24}(\s+[A-Z][a-zA-Z\-]{1,24})?$',
    );
    if (nameLike.hasMatch(trimmed)) return false;

    return true;
  }
}

abstract final class ClimateWbgtMeterRepository {
  static const _key = 'climate_wbgt_meter_readings_v1';
  static const maxReadings = 48;

  static Future<List<ClimateWbgtMeterReading>> loadAll() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null || raw.isEmpty) return const [];

    try {
      final list = jsonDecode(raw) as List<dynamic>;
      return list
          .map(
            (e) => ClimateWbgtMeterReading.fromJson(
              Map<String, dynamic>.from(e as Map),
            ),
          )
          .where((r) => ClimateWbgtMeterValidation.isValidWbgtValue(r.meterWbgtC))
          .toList();
    } catch (_) {
      return const [];
    }
  }

  static Future<ClimateWbgtMeterReading?> latest() async {
    final all = await loadAll();
    if (all.isEmpty) return null;
    all.sort((a, b) => b.recordedAt.compareTo(a.recordedAt));
    return all.first;
  }

  static Future<void> append({
    required double meterWbgtC,
    required double estimateWbgtC,
    required String estimateBandKey,
    String? note,
  }) async {
    if (!ClimateWbgtMeterValidation.isValidWbgtValue(meterWbgtC)) {
      throw ArgumentError('meterWbgtC out of range');
    }
    if (!ClimateWbgtMeterValidation.isNoteAllowed(note)) {
      throw ArgumentError('note not allowed');
    }

    final prefs = await SharedPreferences.getInstance();
    final existing = await loadAll();

    final entry = ClimateWbgtMeterReading(
      recordedAt: DateTime.now(),
      meterWbgtC: _round1(meterWbgtC),
      estimateWbgtC: _round1(estimateWbgtC),
      estimateBandKey: estimateBandKey,
      note: note?.trim().isEmpty == true ? null : note?.trim(),
    );

    final updated = [entry, ...existing]
        .take(maxReadings)
        .map((e) => e.toJson())
        .toList();

    await prefs.setString(_key, jsonEncode(updated));
  }

  @visibleForTesting
  static Future<void> replaceAllForTest(
    List<ClimateWbgtMeterReading> items,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final capped = items.take(maxReadings).map((e) => e.toJson()).toList();
    await prefs.setString(_key, jsonEncode(capped));
  }

  static String buildShareText(
    ClimateWbgtMeterReading reading,
    String Function(String key) t,
    String Function(String key, Map<String, String> params) format,
  ) {
    final diff = reading.differenceC;
    final sign = diff >= 0 ? '+' : '';
    return format(
      'meter_share_body',
      {
        'meter': reading.meterWbgtC.toStringAsFixed(1),
        'estimate': reading.estimateWbgtC.toStringAsFixed(1),
        'diff': '$sign${diff.toStringAsFixed(1)}',
        'time': reading.recordedAt.toIso8601String(),
        'disclaimer': t('meter_not_legal_record'),
      },
    );
  }

  static double _round1(double v) => (v * 10).roundToDouble() / 10;
}
