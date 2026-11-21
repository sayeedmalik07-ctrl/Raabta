import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class QatarNumberingPlan {
  const QatarNumberingPlan({
    required this.verified,
    required this.mobileLeadingDigits,
    required this.landlineLeadingDigit,
    required this.nationalSignificantLength,
    required this.countryCallingCode,
    required this.sourceLabel,
  });

  final bool verified;
  final List<String> mobileLeadingDigits;
  final String landlineLeadingDigit;
  final int nationalSignificantLength;
  final String countryCallingCode;
  final String sourceLabel;
}

abstract final class QatarNumberingCatalog {
  static const assetPath = 'assets/scam_shield/qatar_numbering.json';
  static QatarNumberingPlan? _cache;

  @visibleForTesting
  static void installForTest(QatarNumberingPlan plan) => _cache = plan;

  @visibleForTesting
  static void resetForTest() => _cache = null;

  static Future<QatarNumberingPlan> load() async {
    if (_cache != null) return _cache!;
    final raw = await rootBundle.loadString(assetPath);
    final json = jsonDecode(raw) as Map<String, dynamic>;
    _cache = QatarNumberingPlan(
      verified: json['verified'] == true,
      mobileLeadingDigits: [
        for (final d in (json['mobileLeadingDigits'] as List<dynamic>? ?? []))
          d.toString(),
      ],
      landlineLeadingDigit:
          json['landlineLeadingDigit']?.toString() ?? '4',
      nationalSignificantLength:
          json['nationalSignificantLength'] as int? ?? 8,
      countryCallingCode: json['countryCallingCode']?.toString() ?? '974',
      sourceLabel: json['sourceLabel']?.toString() ?? 'Pattern check',
    );
    return _cache!;
  }
}
