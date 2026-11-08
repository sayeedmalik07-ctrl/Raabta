import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:raabta/config/app_config.dart';
import 'package:raabta/features/eosb/domain/models/eosb_certificate_verification_result.dart';
import 'package:raabta/features/eosb/domain/models/eosb_public_verification_record.dart';

/// Registers immutable public certificate records on Raabta server (Phase 2).
///
/// Never sends PII — only [EosbPublicVerificationRecord] fields.
class EosbCertificateRegistrationService {
  EosbCertificateRegistrationService({http.Client? client})
      : _client = client ?? http.Client();

  static const _base = '${AppConfig.backendUrl}/api/eosb/certificates';

  final http.Client _client;

  Future<EosbCertificateRegistrationResult> register(
    EosbPublicVerificationRecord record,
  ) async {
    try {
      final res = await _client
          .post(
            Uri.parse('$_base/register'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(record.toRegistrationJson()),
          )
          .timeout(const Duration(seconds: 20));

      final data = jsonDecode(res.body) as Map<String, dynamic>;
      if (res.statusCode == 429) {
        return EosbCertificateRegistrationResult(
          success: false,
          error: 'rate_limit_exceeded',
        );
      }
      if (res.statusCode == 409) {
        return EosbCertificateRegistrationResult(
          success: false,
          error: data['error'] as String? ?? 'certificate_conflict',
        );
      }
      if (res.statusCode != 200 && res.statusCode != 201) {
        debugPrint('EOSB register HTTP ${res.statusCode}');
        return EosbCertificateRegistrationResult(
          success: false,
          error: data['error'] as String? ?? 'register_failed',
        );
      }

      return EosbCertificateRegistrationResult.fromServerJson(data);
    } catch (e, st) {
      debugPrint('EOSB register error: $e\n$st');
      return const EosbCertificateRegistrationResult(
        success: false,
        error: 'network_error',
      );
    }
  }
}
