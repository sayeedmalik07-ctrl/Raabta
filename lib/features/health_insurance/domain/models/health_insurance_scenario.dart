import 'package:raabta/features/health_insurance/data/models/compliance_check_model.dart';

/// A what-if Part A compliance scenario for comparison.
class HealthInsuranceScenario {
  const HealthInsuranceScenario({
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
  final InsuranceComplianceInput input;
  final ComplianceCheckResult result;
  /// Positive = worse than base case (higher severity).
  final int differenceFromBase;
  final String differenceSummaryKey;
}
