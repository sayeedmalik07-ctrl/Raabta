import 'package:flutter/foundation.dart';
import 'package:raabta/features/eosb/domain/models/eosb_public_verification_record.dart';
import 'package:raabta/features/eosb/domain/rules/eosb_certificate_constants.dart';

/// Result of public certificate verification (Phase 2).
@immutable
class EosbCertificateVerificationResult {
  const EosbCertificateVerificationResult({
    required this.found,
    required this.certificateId,
    this.record,
    this.verificationUrl,
    this.fingerprintProvided = false,
    this.fingerprintMatch,
    this.signaturePresent = false,
    this.signatureValid,
    this.error,
  });

  final bool found;
  final String certificateId;
  final EosbPublicVerificationRecord? record;
  final String? verificationUrl;
  final bool fingerprintProvided;
  final bool? fingerprintMatch;
  final bool signaturePresent;
  final bool? signatureValid;
  final String? error;

  bool get isCryptographicallySigned =>
      signaturePresent && signatureValid == true;

  bool get isRegistered =>
      record?.certificateStatus == EosbCertificateTrustState.registeredOnline;

  bool get isRevoked =>
      record?.certificateStatus == EosbCertificateTrustState.revoked;

  bool get isSuperseded =>
      record?.certificateStatus == EosbCertificateTrustState.superseded;

  factory EosbCertificateVerificationResult.notFound(String certificateId) {
    return EosbCertificateVerificationResult(
      found: false,
      certificateId: certificateId,
    );
  }

  factory EosbCertificateVerificationResult.fromServerJson(
    Map<String, dynamic> json,
  ) {
    if (json['success'] != true) {
      return EosbCertificateVerificationResult(
        found: false,
        certificateId: json['certificateId'] as String? ?? '',
        error: json['error'] as String? ?? 'verify_failed',
      );
    }

    if (json['found'] != true) {
      return EosbCertificateVerificationResult.notFound(
        json['certificateId'] as String? ?? '',
      );
    }

    final verification = json['verification'] as Map<String, dynamic>?;
    return EosbCertificateVerificationResult(
      found: true,
      certificateId: json['certificateId'] as String,
      record: EosbPublicVerificationRecord.fromServerJson(json),
      verificationUrl: json['verificationUrl'] as String?,
      fingerprintProvided: verification?['fingerprintProvided'] as bool? ?? false,
      fingerprintMatch: verification?['fingerprintMatch'] as bool?,
      signaturePresent: verification?['signaturePresent'] as bool? ?? false,
      signatureValid: verification?['signatureValid'] as bool?,
    );
  }
}

/// Result of online certificate registration (Phase 2).
@immutable
class EosbCertificateRegistrationResult {
  const EosbCertificateRegistrationResult({
    required this.success,
    this.record,
    this.verificationUrl,
    this.idempotent = false,
    this.error,
  });

  final bool success;
  final EosbPublicVerificationRecord? record;
  final String? verificationUrl;
  final bool idempotent;
  final String? error;

  factory EosbCertificateRegistrationResult.fromServerJson(
    Map<String, dynamic> json,
  ) {
    if (json['success'] != true) {
      return EosbCertificateRegistrationResult(
        success: false,
        error: json['error'] as String? ?? 'register_failed',
      );
    }

    final recordJson = json['record'] as Map<String, dynamic>?;
    return EosbCertificateRegistrationResult(
      success: true,
      idempotent: json['idempotent'] as bool? ?? false,
      verificationUrl: json['verificationUrl'] as String?,
      record: recordJson == null
          ? null
          : EosbPublicVerificationRecord.fromServerJson(recordJson),
    );
  }
}
