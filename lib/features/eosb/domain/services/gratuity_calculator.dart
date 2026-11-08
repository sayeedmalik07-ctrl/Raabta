import '../models/eosb_employee_input.dart';
import '../models/eosb_enums.dart';
import '../models/eosb_result.dart';
import '../rules/summary_dismissal_rules.dart';

/// Qatar Labour Law Art. 54 — gratuity on basic salary.
/// Law No. 9 of 2026 narrow exception: unlawful strike incitement (explicit only).
class GratuityCalculator {
  const GratuityCalculator._();

  static EntitlementBreakdownItem calculate(EosbEmployeeInput input) {
    if (SummaryDismissalRules.appliesStrikeIncitementGratuityForfeiture(input)) {
      return const EntitlementBreakdownItem(
        id: 'gratuity',
        titleKey: 'eosb_gratuity',
        amount: 0,
        formulaKey: 'eosb_gratuity_formula_strike_incitement_none',
        ruleKey: 'eosb_gratuity_rule_strike_incitement_law9',
        exampleKey: 'eosb_gratuity_example_strike_incitement',
      );
    }

    if (!input.hasMinimumService || input.basicSalary <= 0) {
      return const EntitlementBreakdownItem(
        id: 'gratuity',
        titleKey: 'eosb_gratuity',
        amount: 0,
        formulaKey: 'eosb_gratuity_formula_none',
        ruleKey: 'eosb_gratuity_rule_min_service',
        exampleKey: 'eosb_gratuity_example_none',
      );
    }

    final years = input.serviceYears;
    final daily = input.dailyBasicRate;

    double eligibleDays = 0;
    if (years <= 5) {
      eligibleDays = 21 * years;
    } else {
      eligibleDays = (21 * 5) + (30 * (years - 5));
    }

    var amount = daily * eligibleDays;

    // Resignation reduction (Art. 54)
    if (input.terminationType == EosbTerminationType.employeeResignation) {
      if (years >= 1 && years < 3) {
        amount *= 1 / 3;
      } else if (years >= 3 && years < 5) {
        amount *= 2 / 3;
      }
    }

    return EntitlementBreakdownItem(
      id: 'gratuity',
      titleKey: 'eosb_gratuity',
      amount: amount,
      formulaKey: 'eosb_gratuity_formula',
      ruleKey: 'eosb_gratuity_rule',
      exampleKey: 'eosb_gratuity_example',
    );
  }
}
