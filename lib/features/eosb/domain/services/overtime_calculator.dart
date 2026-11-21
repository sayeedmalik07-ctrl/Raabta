import '../models/eosb_employee_input.dart';
import '../models/eosb_result.dart';

/// Overtime at 125% hourly rate (Art. 73–74).
class OvertimeCalculator {
  const OvertimeCalculator._();

  static EntitlementBreakdownItem calculate(EosbEmployeeInput input) {
    if (input.overtimeHours <= 0 || input.basicSalary <= 0) {
      return const EntitlementBreakdownItem(
        id: 'overtime',
        titleKey: 'eosb_overtime',
        amount: 0,
        formulaKey: 'eosb_overtime_formula_none',
        ruleKey: 'eosb_overtime_rule',
        exampleKey: 'eosb_overtime_example',
      );
    }

    final hourly = input.basicSalary / 30 / 8;
    final amount = input.overtimeHours * hourly * 1.25;

    return EntitlementBreakdownItem(
      id: 'overtime',
      titleKey: 'eosb_overtime',
      amount: amount,
      formulaKey: 'eosb_overtime_formula',
      ruleKey: 'eosb_overtime_rule',
      exampleKey: 'eosb_overtime_example',
    );
  }
}
