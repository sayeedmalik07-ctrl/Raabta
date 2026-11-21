import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:raabta/config/app_config.dart';
import 'package:raabta/features/scam_shield/domain/evidence/domain_age_models.dart';
import 'package:raabta/services/auth/auth_session_service.dart';

/// Proxied RDAP age lookup — sends registrable domain only, never full URLs.
class ScamDomainAgeService {
  @visibleForTesting
  static Future<DomainAgeLookupResult> Function(String domain)? lookupOverride;

  Future<DomainAgeLookupResult> lookupRegistrableDomain(String domain) async {
    final override = lookupOverride;
    if (override != null) {
      return override(domain);
    }
    final d = domain.trim().toLowerCase();
    if (d.isEmpty) return DomainAgeLookupResult.empty;

    try {
      final token = await AuthSessionService.instance.getIdToken();
      final headers = <String, String>{'Accept': 'application/json'};
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }

      final uri = Uri.parse('${AppConfig.backendUrl}/api/scam-shield/domain-age')
          .replace(queryParameters: {'d': d});

      final response = await http
          .get(uri, headers: headers)
          .timeout(const Duration(seconds: 5));

      if (response.statusCode == 404 ||
          response.statusCode == 429 ||
          response.statusCode == 401) {
        return DomainAgeLookupResult.empty;
      }
      if (response.statusCode != 200) {
        return DomainAgeLookupResult.empty;
      }

      final json = jsonDecode(response.body) as Map<String, dynamic>;
      return DomainAgeLookupResult.fromJson(json);
    } catch (_) {
      return DomainAgeLookupResult.empty;
    }
  }
}
