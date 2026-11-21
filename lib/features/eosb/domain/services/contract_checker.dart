import '../models/eosb_employee_input.dart';
import '../models/eosb_enums.dart';
import '../models/eosb_result.dart';
import '../rules/employment_coverage_rules.dart';
import '../rules/summary_dismissal_rules.dart';

class ContractChecker {
  const ContractChecker._();

  static List<WarningItem> check(EosbEmployeeInput input) {
    final warnings = <WarningItem>[];

    if (EmploymentCoverageRules.mayFallOutsideStandardLabourLaw(input)) {
      warnings.add(
        WarningItem(
          severity: EosbWarningSeverity.warning,
          titleKey: EmploymentCoverageRules.coverageFlagKey,
          explanationKey: 'eosb_warn_employment_coverage_law9_exp',
          actionKey: 'eosb_warn_employment_coverage_law9_action',
        ),
      );
    }

    if (SummaryDismissalRules.isStrikeIncitementGroundSelected(input) &&
        SummaryDismissalRules.dismissalPredatesLaw9(input)) {
      warnings.add(
        const WarningItem(
          severity: EosbWarningSeverity.warning,
          titleKey: 'eosb_warn_strike_predates_law9',
          explanationKey: 'eosb_warn_strike_predates_law9_exp',
          actionKey: 'eosb_warn_strike_predates_law9_action',
        ),
      );
    }

    if (SummaryDismissalRules.appliesStrikeIncitementGratuityForfeiture(input)) {
      warnings.add(
        const WarningItem(
          severity: EosbWarningSeverity.critical,
          titleKey: 'eosb_warn_strike_incitement_gratuity',
          explanationKey: 'eosb_warn_strike_incitement_gratuity_exp',
          actionKey: 'eosb_warn_strike_incitement_gratuity_action',
        ),
      );
    } else if (input.summaryDismissalGround ==
            EosbSummaryDismissalGround.unlawfulStrikeIncitement &&
        !input.summaryDismissalGroundConfirmed) {
      warnings.add(
        const WarningItem(
          severity: EosbWarningSeverity.info,
          titleKey: 'eosb_warn_strike_incitement_unconfirmed',
          explanationKey: 'eosb_warn_strike_incitement_unconfirmed_exp',
          actionKey: 'eosb_warn_strike_incitement_unconfirmed_action',
        ),
      );
    }

    if (input.isTotalSalaryInvalid) {
      warnings.add(
        const WarningItem(
          severity: EosbWarningSeverity.warning,
          titleKey: 'eosb_warn_total_below_basic',
          explanationKey: 'eosb_warn_total_below_basic_exp',
          actionKey: 'eosb_warn_total_below_basic_action',
        ),
      );
    }

    if (input.joiningDate == null || input.lastWorkingDate == null) {
      warnings.add(
        const WarningItem(
          severity: EosbWarningSeverity.info,
          titleKey: 'eosb_warn_dates_missing',
          explanationKey: 'eosb_warn_dates_missing_exp',
          actionKey: 'eosb_warn_dates_missing_action',
        ),
      );
    }

    if (input.unusedLeaveDays > 0 && input.dailyTotalRate <= 0) {
      warnings.add(
        const WarningItem(
          severity: EosbWarningSeverity.warning,
          titleKey: 'eosb_warn_leave_no_salary',
          explanationKey: 'eosb_warn_leave_no_salary_exp',
          actionKey: 'eosb_warn_leave_no_salary_action',
        ),
      );
    }

    if (input.contractType == EosbContractType.limited &&
        input.terminationType == EosbTerminationType.employeeResignation) {
      warnings.add(
        const WarningItem(
          severity: EosbWarningSeverity.info,
          titleKey: 'eosb_warn_limited_resign',
          explanationKey: 'eosb_warn_limited_resign_exp',
          actionKey: 'eosb_warn_limited_resign_action',
        ),
      );
    }

    return warnings;
  }
}
