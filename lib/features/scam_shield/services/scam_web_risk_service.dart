import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:raabta/config/app_config.dart';
import 'package:raabta/features/scam_shield/domain/scam_shield_sanitized_uri.dart';
import 'package:raabta/features/scam_shield/scam_shield_config.dart';
import 'package:raabta/services/auth/auth_session_service.dart';

class ScamWebRiskLookupResult {
  const ScamWebRiskLookupResult({
    required this.flagged,
    required this.threatTypes,
    required this.unavailable,
  });

  final bool flagged;
  final List<String> threatTypes;
  final bool unavailable;
}

class ScamWebRiskBatchResult {
  const ScamWebRiskBatchResult({
    required this.byUri,
    required this.remaining,
    required this.limit,
    required this.capReached,
  });

  final Map<String, ScamWebRiskLookupResult> byUri;
  final int remaining;
  final int limit;
  final bool capReached;

  static const empty = ScamWebRiskBatchResult(
    byUri: {},
    remaining: 0,
    limit: 0,
    capReached: false,
  );
}

/// Proxied Web Risk lookups — never calls Google directly from the client.
class ScamWebRiskService {
  Future<Map<String, String>> _jsonAuthHeaders() async {
    final headers = <String, String>{'Content-Type': 'application/json'};
    final token = await AuthSessionService.instance.getIdToken();
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  Future<ScamWebRiskBatchResult> lookupUris({
    required List<ScamShieldSanitizedUri> uris,
    String? userId,
  }) async {
    if (uris.isEmpty) return ScamWebRiskBatchResult.empty;

    try {
      final headers = await _jsonAuthHeaders();
      final payloadUris = uris.map((u) => u.value).take(10).toList();
      final response = await http
          .post(
            Uri.parse('${AppConfig.backendUrl}/api/scam-shield/web-risk'),
            headers: headers,
            body: jsonEncode({
              'uris': payloadUris,
              if (userId != null && userId.isNotEmpty) 'userId': userId,
            }),
          )
          .timeout(const Duration(seconds: 12));

      if (response.statusCode == 401) {
        return ScamWebRiskBatchResult.empty;
      }

      if (response.statusCode == 429) {
        return const ScamWebRiskBatchResult(
          byUri: {},
          remaining: 0,
          limit: ScamShieldConfig.freeMonthlyWebRiskLimit,
          capReached: true,
        );
      }

      if (response.statusCode != 200) {
        return ScamWebRiskBatchResult.empty;
      }

      final json = jsonDecode(response.body) as Map<String, dynamic>;
      final rawResults = json['results'] as Map<String, dynamic>? ?? {};
      final parsed = <String, ScamWebRiskLookupResult>{};

      rawResults.forEach((uri, value) {
        final map = value as Map<String, dynamic>;
        parsed[uri] = ScamWebRiskLookupResult(
          flagged: map['flagged'] == true,
          threatTypes: (map['threatTypes'] as List<dynamic>? ?? [])
              .map((e) => e.toString())
              .toList(),
          unavailable: map['unavailable'] == true,
        );
      });

      return ScamWebRiskBatchResult(
        byUri: parsed,
        remaining: (json['remaining'] as num?)?.toInt() ?? 0,
        limit: (json['limit'] as num?)?.toInt() ??
            ScamShieldConfig.freeMonthlyWebRiskLimit,
        capReached: false,
      );
    } catch (_) {
      return ScamWebRiskBatchResult.empty;
    }
  }
}
