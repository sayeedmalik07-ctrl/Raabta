import 'package:raabta/features/tenancy/domain/models/tenancy_compliance_models.dart';
import 'package:raabta/features/tenancy/domain/models/tenancy_lease_input.dart';

/// A past tenancy compliance check loaded from Firestore.
class TenancyCheckHistoryEntry {
  const TenancyCheckHistoryEntry({
    required this.id,
    required this.checkedAt,
    required this.input,
    required this.result,
  });

  final String id;
  final DateTime checkedAt;
  final TenancyLeaseInput input;
  final TenancyComplianceResult result;
}
