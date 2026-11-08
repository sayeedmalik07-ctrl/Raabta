import '../models/eosb_employee_input.dart';

/// Resolves Art. 67 input dates without silent legacy inference.
///
/// Same-as-last-working-day flags apply only when the user explicitly confirmed
/// that relationship in Employee Info — never from stored legacy records alone.
abstract final class Art67InputResolver {
  Art67InputResolver._();

  static DateTime? contractTerminationDate(EosbEmployeeInput input) {
    if (input.contractTerminationSameAsLastWorkingDate) {
      return input.lastWorkingDate;
    }
    return input.contractTerminationDate;
  }

  static DateTime? dateOfLeavingWork(EosbEmployeeInput input) {
    if (input.dateOfLeavingSameAsLastWorkingDate) {
      return input.lastWorkingDate;
    }
    return input.dateOfLeavingWork;
  }
}
