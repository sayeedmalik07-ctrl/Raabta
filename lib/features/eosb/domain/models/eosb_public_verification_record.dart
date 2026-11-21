import 'package:flutter/foundation.dart';
import 'package:raabta/features/eosb/domain/models/eosb_certificate_models.dart';
import 'package:raabta/features/eosb/domain/rules/eosb_certificate_constants.dart';

/// Minimal public record for Phase 2 online verification — non-PII only.
@immutable
class EosbPublicVerificationRecord {
  const EosbPublicVerificationRecord({
    required this.certificateId,
    required this.certificateStatus,
    required this.estimatedEntitlement,
    required this.currency,
    required this.eosbRulesetVersion,
    required this.legalSourceVersion,
    required this.legalSourceSummary,
    required this.legalSourceVerifiedDate,
    required this.confidenceBand,
    required this.calculationFingerprint,
    required this.generatedAt,
    this.registeredAt,
    this.recordVersion,
    this.schemaVersion,
    this.revokedAt,
    this.revocationReason,
    this.supersededBy,
    this.recordSignature,
    this.signatureVersion,
    this.signedAt,
  });

  final String certificateId;
  final EosbCertificateTrustState certificateStatus;
  final String estimatedEntitlement;
  final String currency;
  final String eosbRulesetVersion;
  final String legalSourceVersion;
  final String legalSourceSummary;
  final String legalSourceVerifiedDate;
  final EosbCertificateConfidenceBand confidenceBand;
  final String calculationFingerprint;
  final DateTime generatedAt;
  final DateTime? registeredAt;
  final int? recordVersion;
  final int? schemaVersion;
  final DateTime? revokedAt;
  final String? revocationReason;
  final String? supersededBy;
  final String? recordSignature;
  final int? signatureVersion;
  final DateTime? signedAt;

  bool get isCryptographicallySigned =>
      recordSignature != null && recordSignature!.isNotEmpty;

  factory EosbPublicVerificationRecord.fromSnapshot(
    EosbCertificateSnapshot snapshot, {
    EosbCertificateTrustState? certificateStatus,
  }) {
    return EosbPublicVerificationRecord(
      certificateId: snapshot.certificateId,
      certificateStatus: certificateStatus ?? snapshot.trustState,
      estimatedEntitlement: snapshot.totalEntitlement,
      currency: snapshot.currency,
      eosbRulesetVersion: snapshot.eosbRulesetVersion,
      legalSourceVersion: snapshot.legalSourceVersion,
      legalSourceSummary: snapshot.legalProvenance.primaryLaw.lawIdentifier,
      legalSourceVerifiedDate: snapshot.legalProvenance.sourceVerifiedDate,
      confidenceBand: snapshot.certificateConfidenceBand,
      calculationFingerprint: snapshot.calculationFingerprint,
      generatedAt: snapshot.generatedAt,
    );
  }

  Map<String, dynamic> toRegistrationJson() {
    return {
      'certificateId': certificateId,
      'certificateStatus': _trustStateToJson(certificateStatus),
      'estimatedEntitlement': estimatedEntitlement,
      'currency': currency,
      'eosbRulesetVersion': eosbRulesetVersion,
      'legalSourceVersion': legalSourceVersion,
      'legalSourceSummary': legalSourceSummary,
      'legalSourceVerifiedDate': legalSourceVerifiedDate,
      'confidenceBand': confidenceBand.name,
      'calculationFingerprint': calculationFingerprint,
      'generatedAt': generatedAt.toUtc().toIso8601String(),
    };
  }

  factory EosbPublicVerificationRecord.fromServerJson(Map<String, dynamic> json) {
    return EosbPublicVerificationRecord(
      certificateId: json['certificateId'] as String,
      certificateStatus: _trustStateFromJson(json['certificateStatus'] as String?),
      estimatedEntitlement: json['estimatedEntitlement'] as String? ?? '',
      currency: json['currency'] as String? ?? 'QAR',
      eosbRulesetVersion: json['eosbRulesetVersion'] as String? ?? '',
      legalSourceVersion: json['legalSourceVersion'] as String? ?? '',
      legalSourceSummary: json['legalSourceSummary'] as String? ?? '',
      legalSourceVerifiedDate: json['legalSourceVerifiedDate'] as String? ?? '',
      confidenceBand: _confidenceFromJson(json['confidenceBand'] as String?),
      calculationFingerprint: json['calculationFingerprint'] as String? ?? '',
      generatedAt: _parseDate(json['generatedAt']),
      registeredAt: _parseOptionalDate(json['registeredAt']),
      recordVersion: json['recordVersion'] as int?,
      schemaVersion: json['schemaVersion'] as int?,
      revokedAt: _parseOptionalDate(json['revokedAt']),
      revocationReason: json['revocationReason'] as String?,
      supersededBy: json['supersededBy'] as String?,
      recordSignature: json['recordSignature'] as String?,
      signatureVersion: json['signatureVersion'] as int?,
      signedAt: _parseOptionalDate(json['signedAt']),
    );
  }

  static String _trustStateToJson(EosbCertificateTrustState state) {
    return switch (state) {
      EosbCertificateTrustState.visualEstimate => 'visualEstimate',
      EosbCertificateTrustState.registeredOnline => 'registeredOnline',
      EosbCertificateTrustState.revoked => 'revoked',
      EosbCertificateTrustState.superseded => 'superseded',
    };
  }

  static EosbCertificateTrustState _trustStateFromJson(String? raw) {
    return switch (raw) {
      'registeredOnline' => EosbCertificateTrustState.registeredOnline,
      'revoked' => EosbCertificateTrustState.revoked,
      'superseded' => EosbCertificateTrustState.superseded,
      _ => EosbCertificateTrustState.visualEstimate,
    };
  }

  static EosbCertificateConfidenceBand _confidenceFromJson(String? raw) {
    return switch (raw) {
      'medium' => EosbCertificateConfidenceBand.medium,
      'low' => EosbCertificateConfidenceBand.low,
      _ => EosbCertificateConfidenceBand.high,
    };
  }

  static DateTime _parseDate(Object? raw) {
    if (raw is String && raw.isNotEmpty) {
      return DateTime.parse(raw).toUtc();
    }
    return DateTime.fromMillisecondsSinceEpoch(0, isUtc: true);
  }

  static DateTime? _parseOptionalDate(Object? raw) {
    if (raw is String && raw.isNotEmpty) {
      return DateTime.parse(raw).toUtc();
    }
    return null;
  }
}
