import 'package:raabta/features/eosb/domain/models/eosb_employee_input.dart';
import 'package:raabta/features/eosb/domain/models/eosb_enums.dart';
import 'package:raabta/features/eosb/domain/rules/labour_law_9_2026.dart';

/// Deterministic rules for Law No. 9 of 2026 summary-dismissal gratuity exception.
///
/// Applied **only** when the user explicitly selects the narrow strike-incitement
/// ground — never inferred from generic employer termination.
abstract final class SummaryDismissalRules {
  /// True only when all narrow conditions for gratuity forfeiture are met.
  static bool appliesStrikeIncitementGratuityForfeiture(EosbEmployeeInput input) {
    if (input.terminationType != EosbTerminationType.employerTermination) {
      return false;
    }
    if (input.summaryDismissalGround !=
        EosbSummaryDismissalGround.unlawfulStrikeIncitement) {
      return false;
    }
    // Must be explicitly confirmed — prevents accidental misapplication.
    if (!input.summaryDismissalGroundConfirmed) return false;
    return true;
  }

  static bool isEligibleForStandardGratuityCalculation(EosbEmployeeInput input) {
    return !appliesStrikeIncitementGratuityForfeiture(input);
  }

  static String get ruleKey => LabourLaw92026.summaryDismissalStrikeIncitementGroundId;

  /// True when the strike-incitement ground is selected (confirmed or not).
  static bool isStrikeIncitementGroundSelected(EosbEmployeeInput input) {
    return input.summaryDismissalGround ==
        EosbSummaryDismissalGround.unlawfulStrikeIncitement;
  }

  /// Ground only exists from Law No. 9 of 2026 (25 June 2026).
  static bool dismissalPredatesLaw9(EosbEmployeeInput input) {
    final last = input.lastWorkingDate;
    if (last == null) return false;
    return last.isBefore(LabourLaw92026.promulgationDateTime);
  }
}
