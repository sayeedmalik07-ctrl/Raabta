import '../models/eosb_employee_input.dart';
import '../models/eosb_enums.dart';
import '../models/eosb_result.dart';
import '../rules/summary_dismissal_rules.dart';

class ViolationDetector {
  const ViolationDetector._();

  static List<ViolationItem> detect(
    EosbEmployeeInput input,
    List<EntitlementBreakdownItem> breakdown,
  ) {
    final violations = <ViolationItem>[];

    if (input.isTotalSalaryInvalid) {
      violations.add(
        const ViolationItem(
          titleKey: 'eosb_violation_salary_basis',
          explanationKey: 'eosb_violation_salary_basis_exp',
          ruleKey: 'eosb_violation_salary_basis_rule',
          riskLevelKey: 'eosb_risk_high',
        ),
      );
    }

    if (!input.hasMinimumService &&
        input.terminationType == EosbTerminationType.employeeResignation) {
      violations.add(
        const ViolationItem(
          titleKey: 'eosb_violation_min_service',
          explanationKey: 'eosb_violation_min_service_exp',
          ruleKey: 'eosb_gratuity_rule_min_service',
          riskLevelKey: 'eosb_risk_medium',
        ),
      );
    }

    final gratuity =
        breakdown.where((b) => b.id == 'gratuity').map((b) => b.amount).firstOrNull ?? 0;

    final strikeForfeiture =
        SummaryDismissalRules.appliesStrikeIncitementGratuityForfeiture(input);

    if (gratuity == 0 &&
        input.hasMinimumService &&
        input.basicSalary > 0 &&
        input.terminationType == EosbTerminationType.employerTermination &&
        !strikeForfeiture) {
      violations.add(
        const ViolationItem(
          titleKey: 'eosb_violation_gratuity_missing',
          explanationKey: 'eosb_violation_gratuity_missing_exp',
          ruleKey: 'eosb_gratuity_rule',
          riskLevelKey: 'eosb_risk_critical',
        ),
      );
    }

    return violations;
  }
}

extension _FirstOrNull<E> on Iterable<E> {
  E? get firstOrNull {
    final i = iterator;
    if (i.moveNext()) return i.current;
    return null;
  }
}
