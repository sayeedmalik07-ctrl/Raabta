import 'package:cloud_firestore/cloud_firestore.dart';

/// Raabta-admin employer identity verification — separate from directory [verificationStatus].
enum EmployerIdentityVerificationStatus {
  pending,
  verified,
  rejected,
  revoked;

  static EmployerIdentityVerificationStatus? fromStored(String? raw) {
    switch (raw) {
      case 'pending':
        return EmployerIdentityVerificationStatus.pending;
      case 'verified':
        return EmployerIdentityVerificationStatus.verified;
      case 'rejected':
        return EmployerIdentityVerificationStatus.rejected;
      case 'revoked':
        return EmployerIdentityVerificationStatus.revoked;
      default:
        return null;
    }
  }

  String get storageValue => name;
}

class EmployerIdentityVerification {
  const EmployerIdentityVerification({
    required this.status,
    this.verifiedAt,
    this.verifiedBy,
    this.rejectedAt,
    this.rejectedBy,
    this.rejectionReason,
    this.revokedAt,
    this.revokedBy,
    this.revocationReason,
  });

  final EmployerIdentityVerificationStatus status;
  final DateTime? verifiedAt;
  final String? verifiedBy;
  final DateTime? rejectedAt;
  final String? rejectedBy;
  final String? rejectionReason;
  final DateTime? revokedAt;
  final String? revokedBy;
  final String? revocationReason;

  bool get isVerified => status == EmployerIdentityVerificationStatus.verified;

  static EmployerIdentityVerification? fromFirestore(Object? raw) {
    if (raw is! Map) return null;
    final data = Map<String, dynamic>.from(raw);
    final status = EmployerIdentityVerificationStatus.fromStored(
      data['status'] as String?,
    );
    if (status == null) return null;

    return EmployerIdentityVerification(
      status: status,
      verifiedAt: _parseTimestamp(data['verifiedAt']),
      verifiedBy: data['verifiedBy'] as String?,
      rejectedAt: _parseTimestamp(data['rejectedAt']),
      rejectedBy: data['rejectedBy'] as String?,
      rejectionReason: data['rejectionReason'] as String?,
      revokedAt: _parseTimestamp(data['revokedAt']),
      revokedBy: data['revokedBy'] as String?,
      revocationReason: data['revocationReason'] as String?,
    );
  }

  static DateTime? _parseTimestamp(Object? value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value);
    return null;
  }
}
