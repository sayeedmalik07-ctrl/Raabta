import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:raabta/config/app_config.dart';
import 'package:raabta/features/scam_shield/domain/evidence/link_unroll_models.dart';
import 'package:raabta/services/auth/auth_session_service.dart';

class ScamLinkUnrollService {
  @visibleForTesting
  static Future<LinkUnrollResult> Function(String url)? lookupOverride;

  Future<LinkUnrollResult> unrollShortUrl(String url) async {
    final override = lookupOverride;
    if (override != null) return override(url);

    final trimmed = url.trim();
    if (trimmed.isEmpty) return LinkUnrollResult.empty;

    try {
      final token = await AuthSessionService.instance.getIdToken();
      final headers = <String, String>{
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      };
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }

      final uri = Uri.parse('${AppConfig.backendUrl}/api/scam-shield/link-unroll');
      final response = await http
          .post(
            uri,
            headers: headers,
            body: jsonEncode({'url': trimmed.split('#').first}),
          )
          .timeout(const Duration(seconds: 8));

      if (response.statusCode == 404 ||
          response.statusCode == 429 ||
          response.statusCode == 401 ||
          response.statusCode == 400) {
        return LinkUnrollResult.empty;
      }
      if (response.statusCode != 200) {
        return LinkUnrollResult.empty;
      }

      final json = jsonDecode(response.body) as Map<String, dynamic>;
      return LinkUnrollResult.fromJson(json);
    } catch (_) {
      return LinkUnrollResult.empty;
    }
  }
}
