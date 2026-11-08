import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class OperatorReportingEntry {
  const OperatorReportingEntry({
    required this.id,
    required this.nameKey,
    required this.bodyKey,
    required this.dialNumber,
    required this.verifyUrl,
    required this.sourceLabel,
    required this.verified,
  });

  final String id;
  final String nameKey;
  final String bodyKey;
  final String? dialNumber;
  final String verifyUrl;
  final String sourceLabel;
  final bool verified;
}

abstract final class OperatorReportingCatalog {
  static const assetPath = 'assets/scam_shield/operator_reporting.json';
  static List<OperatorReportingEntry>? _cache;

  @visibleForTesting
  static void installForTest(List<OperatorReportingEntry> entries) =>
      _cache = entries;

  @visibleForTesting
  static void resetForTest() => _cache = null;

  static Future<List<OperatorReportingEntry>> loadVerified() async {
    if (_cache == null) {
      final raw = await rootBundle.loadString(assetPath);
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      final list = decoded['entries'] as List<dynamic>? ?? [];
      _cache = [
        for (final item in list)
          if (item is Map<String, dynamic>)
            OperatorReportingEntry(
              id: item['id']?.toString() ?? '',
              nameKey: item['nameKey']?.toString() ?? '',
              bodyKey: item['bodyKey']?.toString() ?? '',
              dialNumber: item['dialNumber'] as String?,
              verifyUrl: item['verifyUrl']?.toString() ?? '',
              sourceLabel: item['sourceLabel']?.toString() ?? '',
              verified: item['verified'] == true,
            ),
      ];
    }
    return _cache!.where((e) => e.verified).toList(growable: false);
  }

  /// Phase 21 channel picker — same verified list.
  static Future<List<OperatorReportingEntry>> channelsForReportPicker() =>
      loadVerified();
}
