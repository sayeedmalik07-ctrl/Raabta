import 'package:raabta/features/quick_actions/climate_navigator/services/climate_workload_preferences.dart';

/// ACGIH Heat Stress and Strain — Table 2 screening (75–100% work), educational display only.
/// No comparison to app WBGT estimates.
abstract final class AcgihHeatReferenceEducation {
  /// Returns screening WBGT °C for continuous work, or null when ACGIH provides none.
  static AcgihScreeningReference? screeningReferenceFor(
    ClimateWorkloadCategory category,
  ) {
    switch (category) {
      case ClimateWorkloadCategory.light:
        return const AcgihScreeningReference(
          actionLimitC: 28.0,
          tlvC: 31.0,
        );
      case ClimateWorkloadCategory.moderate:
        return const AcgihScreeningReference(
          actionLimitC: 25.0,
          tlvC: 28.0,
        );
      case ClimateWorkloadCategory.heavy:
      case ClimateWorkloadCategory.veryHeavy:
      case ClimateWorkloadCategory.unset:
        return null;
    }
  }

  static bool showsNoContinuousScreening(ClimateWorkloadCategory category) =>
      category == ClimateWorkloadCategory.heavy ||
      category == ClimateWorkloadCategory.veryHeavy;
}

class AcgihScreeningReference {
  const AcgihScreeningReference({
    required this.actionLimitC,
    required this.tlvC,
  });

  final double actionLimitC;
  final double tlvC;
}
