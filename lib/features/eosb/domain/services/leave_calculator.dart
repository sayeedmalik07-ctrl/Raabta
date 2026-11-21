import '../models/eosb_employee_input.dart';
import '../models/eosb_result.dart';

/// Unused annual leave encashment (Art. 79–83).
class LeaveCalculator {
  const LeaveCalculator._();

  static EntitlementBreakdownItem calculate(EosbEmployeeInput input) {
    final days = input.unusedLeaveDays;
    if (days <= 0 || input.dailyTotalRate <= 0) {
      return const EntitlementBreakdownItem(
        id: 'leave',
        titleKey: 'eosb_leave',
        amount: 0,
        formulaKey: 'eosb_leave_formula_none',
        ruleKey: 'eosb_leave_rule',
        exampleKey: 'eosb_leave_example',
      );
    }

    return EntitlementBreakdownItem(
      id: 'leave',
      titleKey: 'eosb_leave',
      amount: input.dailyTotalRate * days,
      formulaKey: 'eosb_leave_formula',
      ruleKey: 'eosb_leave_rule',
      exampleKey: 'eosb_leave_example',
    );
  }
}
