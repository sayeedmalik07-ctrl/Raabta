import '../models/eosb_employee_input.dart';
import '../models/eosb_enums.dart';
import '../models/eosb_result.dart';
import '../rules/summary_dismissal_rules.dart';

/// Notice period compensation when not served or employer terminates.
class NoticeCalculator {
  const NoticeCalculator._();

  static EntitlementBreakdownItem calculate(EosbEmployeeInput input) {
    if (SummaryDismissalRules.appliesStrikeIncitementGratuityForfeiture(input)) {
      return const EntitlementBreakdownItem(
        id: 'notice',
        titleKey: 'eosb_notice',
        amount: 0,
        formulaKey: 'eosb_notice_formula_none',
        ruleKey: 'eosb_notice_rule_strike_incitement_law9',
        exampleKey: 'eosb_notice_example',
      );
    }

    if (input.basicSalary <= 0) {
      return const EntitlementBreakdownItem(
        id: 'notice',
        titleKey: 'eosb_notice',
        amount: 0,
        formulaKey: 'eosb_notice_formula_none',
        ruleKey: 'eosb_notice_rule',
        exampleKey: 'eosb_notice_example',
      );
    }

    final years = input.serviceYears;
    final noticeMonths = years >= 5 ? 2.0 : 1.0;
    final noticePay = input.basicSalary * noticeMonths;

    double amount = 0;
    if (!input.noticeServed &&
        input.terminationType == EosbTerminationType.employerTermination) {
      amount = noticePay;
    } else if (input.noticeBuyoutAmount > 0) {
      amount = input.noticeBuyoutAmount;
    }

    return EntitlementBreakdownItem(
      id: 'notice',
      titleKey: 'eosb_notice',
      amount: amount,
      formulaKey: 'eosb_notice_formula',
      ruleKey: 'eosb_notice_rule',
      exampleKey: 'eosb_notice_example',
    );
  }
}
