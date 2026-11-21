import '../models/eosb_employee_input.dart';
import '../models/eosb_enums.dart';
import '../models/eosb_result.dart';
import '../models/eosb_scenario.dart';
import 'eosb_calculation_service.dart';

/// Compares settlement outcomes across employment scenarios.
class EosbScenarioService {
  const EosbScenarioService(this._calc);

  final EosbCalculationService _calc;

  List<EosbScenario> simulate(EosbEmployeeInput base) {
    if (base.basicSalary <= 0 ||
        base.joiningDate == null ||
        base.lastWorkingDate == null) {
      return [];
    }

    final baseResult = _calc.calculate(base);
    final scenarios = <EosbScenario>[];

    void add(
      String id,
      String titleKey,
      String descriptionKey,
      EosbEmployeeInput input,
    ) {
      final result = _calc.calculate(input);
      scenarios.add(
        EosbScenario(
          id: id,
          titleKey: titleKey,
          descriptionKey: descriptionKey,
          input: input,
          result: result,
          differenceFromBase: result.totalEntitlement - baseResult.totalEntitlement,
        ),
      );
    }

    add(
      'resign_today',
      'eosb_scenario_resign_today',
      'eosb_scenario_resign_today_desc',
      base.copyWith(terminationType: EosbTerminationType.employeeResignation),
    );

    if (base.lastWorkingDate != null) {
      add(
        'resign_next_month',
        'eosb_scenario_resign_next_month',
        'eosb_scenario_resign_next_month_desc',
        base.copyWith(
          terminationType: EosbTerminationType.employeeResignation,
          lastWorkingDate: base.lastWorkingDate!.add(const Duration(days: 30)),
        ),
      );
    }

    add(
      'employer_terminates',
      'eosb_scenario_employer_terminates',
      'eosb_scenario_employer_terminates_desc',
      base.copyWith(terminationType: EosbTerminationType.employerTermination),
    );

    add(
      'mutual_separation',
      'eosb_scenario_mutual',
      'eosb_scenario_mutual_desc',
      base.copyWith(terminationType: EosbTerminationType.mutualSeparation),
    );

    if (base.contractType == EosbContractType.limited) {
      add(
        'contract_expires',
        'eosb_scenario_contract_expires',
        'eosb_scenario_contract_expires_desc',
        base.copyWith(terminationType: EosbTerminationType.contractExpiry),
      );
    }

    if (base.basicSalary > 0) {
      add(
        'salary_increase_10',
        'eosb_scenario_salary_up',
        'eosb_scenario_salary_up_desc',
        base.copyWith(
          basicSalary: base.basicSalary * 1.1,
          totalSalary: base.totalSalary > 0
              ? base.totalSalary * 1.1
              : base.basicSalary * 1.1,
        ),
      );
    }

    if (base.lastWorkingDate != null) {
      add(
        'six_months_more',
        'eosb_scenario_six_months',
        'eosb_scenario_six_months_desc',
        base.copyWith(
          lastWorkingDate: base.lastWorkingDate!.add(const Duration(days: 182)),
        ),
      );
    }

    return scenarios;
  }

  EosbResult calculateBase(EosbEmployeeInput base) => _calc.calculate(base);
}
