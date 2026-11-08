import 'eosb_employee_input.dart';
import 'eosb_result.dart';

/// A what-if settlement scenario for comparison.
class EosbScenario {
  const EosbScenario({
    required this.id,
    required this.titleKey,
    required this.descriptionKey,
    required this.input,
    required this.result,
    required this.differenceFromBase,
  });

  final String id;
  final String titleKey;
  final String descriptionKey;
  final EosbEmployeeInput input;
  final EosbResult result;
  final double differenceFromBase;
}
