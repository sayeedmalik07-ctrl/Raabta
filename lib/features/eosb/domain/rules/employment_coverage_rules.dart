import 'package:raabta/features/eosb/domain/models/eosb_employee_input.dart';
import 'package:raabta/features/eosb/domain/models/eosb_enums.dart';
import 'package:raabta/features/eosb/domain/rules/labour_law_9_2026.dart';

/// Flags when standard Labour Law EOSB formulas may not apply (Law 9/2026 scope).
abstract final class EmploymentCoverageRules {
  static bool mayFallOutsideStandardLabourLaw(EosbEmployeeInput input) {
    return input.employmentCategory == EosbEmploymentCategory.partTime ||
        input.employmentCategory == EosbEmploymentCategory.freelance;
  }

  static bool isStandardFullTimeCoverage(EosbEmployeeInput input) {
    return input.employmentCategory == EosbEmploymentCategory.fullTime;
  }

  static String get coverageFlagKey {
    if (LabourLaw92026.partTimeFreelanceExcludedByDefault) {
      return 'eosb_warn_employment_coverage_law9';
    }
    return 'eosb_warn_employment_coverage';
  }

  /// User opted in to see standard-employee formulas as a reference figure only.
  static bool isReferenceCalculation(EosbEmployeeInput input) {
    return mayFallOutsideStandardLabourLaw(input) &&
        input.showStandardEmployeeReference;
  }
}
