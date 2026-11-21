import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:raabta/config/app_config.dart';
import 'package:raabta/features/eosb/domain/models/eosb_certificate_verification_result.dart';
import 'package:raabta/features/eosb/domain/models/eosb_public_verification_record.dart';
import 'package:raabta/features/eosb/domain/services/eosb_salary_claude_consent.dart';

/// UID-scoped salary storage consent reader for registration.
typedef EosbSalaryStorageConsentReader = bool Function();

/// Registers immutable public certificate records on Raabta server (Phase 2).
///
/// Never sends PII — only [EosbPublicVerificationRecord] fields.
class EosbCertificateRegistrationService {
  EosbCertificateRegistrationService({
    http.Client? client,
    EosbSalaryStorageConsentReader? salaryConsent,
  }) : _client = client ?? http.Client(),
       _salaryConsent = salaryConsent ?? (() => false);

  static const _base = '${AppConfig.backendUrl}/api/eosb/certificates';

  final http.Client _client;
  final EosbSalaryStorageConsentReader _salaryConsent;

  Future<EosbCertificateRegistrationResult> register(
    EosbPublicVerificationRecord record,
  ) async {
    if (!_salaryConsent()) {
      throw const EosbSalaryStorageConsentRequired();
    }
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
    } catch (_) {
      if (kDebugMode) {
        debugPrint('EOSB register failed: network_error');
      }
      return const EosbCertificateRegistrationResult(
        success: false,
        error: 'network_error',
      );
    }
  }
}
