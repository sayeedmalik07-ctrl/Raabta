import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class CallingCodeEntry {
  const CallingCodeEntry({
    required this.code,
    required this.countryEn,
    required this.countryAr,
  });

  final String code;
  final String countryEn;
  final String countryAr;
}

abstract final class CallingCodeCatalog {
  static const assetPath = 'assets/scam_shield/calling_codes.json';
  static List<CallingCodeEntry>? _cache;

  @visibleForTesting
  static void installForTest(List<CallingCodeEntry> entries) => _cache = entries;

  @visibleForTesting
  static void resetForTest() => _cache = null;

  static Future<List<CallingCodeEntry>> load() async {
    if (_cache != null) return _cache!;
    final raw = await rootBundle.loadString(assetPath);
    final decoded = jsonDecode(raw) as Map<String, dynamic>;
    final list = decoded['codes'] as List<dynamic>? ?? [];
    _cache = [
      for (final item in list)
        if (item is Map<String, dynamic>)
          CallingCodeEntry(
            code: item['code']?.toString() ?? '',
            countryEn: item['countryEn']?.toString() ?? '',
            countryAr: item['countryAr']?.toString() ?? '',
          ),
    ];
    return _cache!;
  }

  static CallingCodeEntry? matchLongestCode(String digits) {
    final codes = _cache ?? const [];
    CallingCodeEntry? best;
    for (final entry in codes) {
      if (digits.startsWith(entry.code) &&
          (best == null || entry.code.length > best.code.length)) {
        best = entry;
      }
    }
    return best;
  }
}
