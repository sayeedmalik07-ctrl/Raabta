import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:raabta/config/app_config.dart';
import 'package:raabta/features/eosb/domain/models/eosb_certificate_verification_result.dart';
import 'package:raabta/features/eosb/domain/services/eosb_certificate_verification_urls.dart';

/// Public certificate verification — hash comparison optional (Phase 2).
class EosbCertificateVerificationService {
  EosbCertificateVerificationService({http.Client? client})
      : _client = client ?? http.Client();

  static const _base = '${AppConfig.backendUrl}/api/eosb/certificates';

  final http.Client _client;

  Future<EosbCertificateVerificationResult> verify({
    required String certificateId,
    String? calculationFingerprint,
  }) async {
    if (!EosbCertificateVerificationUrls.isValidCertificateId(certificateId)) {
      return EosbCertificateVerificationResult(
        found: false,
        certificateId: certificateId,
        error: 'invalid_certificate_id',
      );
    }

    final params = <String, String>{};
    if (calculationFingerprint != null && calculationFingerprint.isNotEmpty) {
      params['fingerprint'] = calculationFingerprint;
    }

    final uri = Uri.parse('$_base/${Uri.encodeComponent(certificateId)}')
        .replace(queryParameters: params.isEmpty ? null : params);

    try {
      final res = await _client.get(uri).timeout(const Duration(seconds: 15));
      final data = jsonDecode(res.body) as Map<String, dynamic>;

      if (res.statusCode == 429) {
        return EosbCertificateVerificationResult(
          found: false,
          certificateId: certificateId,
          error: 'rate_limit_exceeded',
        );
      }

      if (res.statusCode != 200) {
        debugPrint('EOSB verify HTTP ${res.statusCode}');
        return EosbCertificateVerificationResult(
          found: false,
          certificateId: certificateId,
          error: data['error'] as String? ?? 'verify_failed',
        );
      }

      return EosbCertificateVerificationResult.fromServerJson(data);
    } catch (e, st) {
      debugPrint('EOSB verify error: $e\n$st');
      return EosbCertificateVerificationResult(
        found: false,
        certificateId: certificateId,
        error: 'network_error',
      );
    }
  }
}
