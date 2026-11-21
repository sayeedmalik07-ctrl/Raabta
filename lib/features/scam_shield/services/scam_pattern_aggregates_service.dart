import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:raabta/config/app_config.dart';
import 'package:raabta/features/scam_shield/domain/scam_pattern_aggregate_lookup.dart';

/// Backend lookup for k-anonymity gated scam pattern aggregates (Part D).
///
/// Never reads `scam_pattern_aggregates` from Firestore on the client.
class ScamPatternAggregatesService {
  ScamPatternAggregatesService({http.Client? client})
      : _client = client ?? http.Client();

  static const _base = '${AppConfig.backendUrl}/api/scam-pattern-reports';

  final http.Client _client;

  Future<ScamPatternAreaAggregates> fetchByArea(String area) async {
    final trimmed = area.trim();
    if (trimmed.isEmpty) return ScamPatternAreaAggregates.empty;

    final uri = Uri.parse('$_base/aggregates').replace(
      queryParameters: {'area': trimmed},
    );

    try {
      final res = await _client.get(uri).timeout(const Duration(seconds: 12));
      if (res.statusCode != 200) {
        debugPrint('ScamPatternAggregates HTTP ${res.statusCode}');
        return ScamPatternAreaAggregates.empty;
      }

      final data = jsonDecode(res.body) as Map<String, dynamic>;
      if (data['success'] != true) {
        return ScamPatternAreaAggregates.empty;
      }

      return ScamPatternAreaAggregates.fromJson(data);
    } catch (e) {
      debugPrint('ScamPatternAggregates lookup error: $e');
      return ScamPatternAreaAggregates.empty;
    }
  }

  void dispose() {
    _client.close();
  }
}
