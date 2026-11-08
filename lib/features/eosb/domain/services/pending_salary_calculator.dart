import '../models/eosb_employee_input.dart';
import '../models/eosb_result.dart';

class PendingSalaryCalculator {
  const PendingSalaryCalculator._();

  static EntitlementBreakdownItem calculate(EosbEmployeeInput input) {
    return EntitlementBreakdownItem(
      id: 'pending_salary',
      titleKey: 'eosb_pending_salary',
      amount: input.pendingSalary,
      formulaKey: 'eosb_pending_salary_formula',
      ruleKey: 'eosb_pending_salary_rule',
      exampleKey: 'eosb_pending_salary_example',
    );
  }
}
