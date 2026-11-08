import 'package:raabta/features/tenancy/domain/models/tenancy_compliance_models.dart';
import 'package:raabta/features/tenancy/domain/models/tenancy_lease_input.dart';

/// A what-if tenancy compliance scenario for comparison.
class TenancyScenario {
  const TenancyScenario({
    required this.id,
    required this.titleKey,
    required this.descriptionKey,
    required this.input,
    required this.result,
    required this.differenceFromBase,
    required this.differenceSummaryKey,
  });

  final String id;
  final String titleKey;
  final String descriptionKey;
  final TenancyLeaseInput input;
  final TenancyComplianceResult result;
  /// Positive = worse than base case (higher severity).
  final int differenceFromBase;
  final String differenceSummaryKey;
}
