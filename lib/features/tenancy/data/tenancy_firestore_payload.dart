import 'package:raabta/features/tenancy/domain/models/tenancy_compliance_models.dart';
import 'package:raabta/features/tenancy/domain/models/tenancy_lease_input.dart';
import 'package:raabta/features/tenancy/domain/services/tenancy_claim_basis_builder.dart';

/// Firestore document shapes for tenancy sync — testable without Firebase.
abstract final class TenancyFirestorePayload {
  static String recordIdFor(TenancyComplianceResult result) =>
      '${result.checkedAt.millisecondsSinceEpoch}';

  static String packetIdFor(DisputePacketMetadata meta) =>
      '${meta.generatedAt.millisecondsSinceEpoch}';

  /// Lease compliance record — no landlord name (PII).
  static Map<String, dynamic> record({
    required TenancyLeaseInput input,
    required TenancyComplianceResult result,
    required String legalVersionVerifiedAt,
  }) {
    return {
      'checkedAt': result.checkedAt.toIso8601String(),
      'registrationStatus': input.registrationStatus?.name,
      'propertyType': input.propertyType.name,
      'monthlyRent': input.monthlyRent,
      'securityDeposit': input.securityDeposit,
      'leaseStartDate': input.leaseStartDate?.toIso8601String(),
      'leaseEndDate': input.leaseEndDate?.toIso8601String(),
      'committeeDecisionDate': input.committeeDecisionDate?.toIso8601String(),
      'leaseScannedToVault': input.leaseScannedToVault,
      'hasCriticalIssue': result.hasCriticalIssue,
      'hasViolation': result.hasViolation,
      'depositOverCap': input.isDepositOverCap,
      'lateFeeMonthsLate': result.lateFeeEstimate?.monthsLate,
      'legalVersionVerifiedAt': legalVersionVerifiedAt,
    };
  }

  static Map<String, dynamic> userSummary({
    required String latestRecordId,
    required TenancyLeaseInput input,
    required TenancyComplianceResult result,
    required String legalVersionVerifiedAt,
    required int checklistCollectedCount,
    required int checklistTotalCount,
    DateTime? latestPacketGeneratedAt,
  }) {
    return {
      'checkCompleted': true,
      'latestRecordId': latestRecordId,
      'latestCheckedAt': result.checkedAt.toIso8601String(),
      'hasCriticalIssue': result.hasCriticalIssue,
      'hasViolation': result.hasViolation,
      'registrationStatus': input.registrationStatus?.name,
      'propertyType': input.propertyType.name,
      'legalVersionVerifiedAt': legalVersionVerifiedAt,
      'checklistCollectedCount': checklistCollectedCount,
      'checklistTotalCount': checklistTotalCount,
      if (latestPacketGeneratedAt != null)
        'latestPacketGeneratedAt':
            latestPacketGeneratedAt.toIso8601String(),
    };
  }

  static Map<String, dynamic> disputePacket({
    required DisputePacketMetadata meta,
    required String legalVersionVerifiedAt,
  }) {
    return {
      'generatedAt': meta.generatedAt.toIso8601String(),
      'collectedItemIds': meta.collectedItemIds,
      'claimBasisKeys': meta.claimBasisKeys,
      'collectedCount': meta.collectedItemIds.length,
      'legalVersionVerifiedAt': legalVersionVerifiedAt,
    };
  }
}
