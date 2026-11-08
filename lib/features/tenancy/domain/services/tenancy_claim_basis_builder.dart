import 'package:raabta/features/tenancy/domain/models/tenancy_compliance_models.dart';
import 'package:raabta/features/tenancy/domain/models/tenancy_enums.dart';
import 'package:raabta/features/tenancy/domain/models/tenancy_lease_input.dart';

/// Builds implicated claim-basis keys from a compliance result for PDF/checklist.
abstract final class TenancyClaimBasisBuilder {
  static List<String> basisKeys({
    required TenancyComplianceResult result,
    required TenancyLeaseInput input,
  }) {
    final keys = <String>[];

    final reg = result.items.where((i) => i.id == 'registration').firstOrNull;
    if (reg?.status == TenancyComplianceStatus.critical ||
        reg?.status == TenancyComplianceStatus.needsVerification) {
      keys.add('tenancy_claim_art3_unregistered');
    }

    final deposit = result.items.where((i) => i.id == 'deposit_cap').firstOrNull;
    if (deposit?.status == TenancyComplianceStatus.violation) {
      keys.add('tenancy_claim_deposit_cap');
    }

    if (result.lateFeeEstimate != null &&
        result.lateFeeEstimate!.monthsLate >= 1) {
      keys.add('tenancy_claim_late_registration');
    }

    if (keys.isEmpty) {
      keys.add('tenancy_claim_general_rights');
    }

    return keys;
  }
}

extension _FirstOrNull<E> on Iterable<E> {
  E? get firstOrNull {
    final i = iterator;
    if (i.moveNext()) return i.current;
    return null;
  }
}

class DisputePacketMetadata {
  const DisputePacketMetadata({
    required this.generatedAt,
    required this.collectedItemIds,
    required this.claimBasisKeys,
  });

  final DateTime generatedAt;
  final List<String> collectedItemIds;
  final List<String> claimBasisKeys;

  Map<String, dynamic> toJson() => {
        'generatedAt': generatedAt.toIso8601String(),
        'collectedItemIds': collectedItemIds,
        'claimBasisKeys': claimBasisKeys,
      };

  factory DisputePacketMetadata.fromJson(Map<String, dynamic> json) {
    return DisputePacketMetadata(
      generatedAt: DateTime.tryParse(json['generatedAt'] as String? ?? '') ??
          DateTime.now(),
      collectedItemIds: (json['collectedItemIds'] as List<dynamic>? ?? [])
          .map((e) => e.toString())
          .toList(),
      claimBasisKeys: (json['claimBasisKeys'] as List<dynamic>? ?? [])
          .map((e) => e.toString())
          .toList(),
    );
  }
}
