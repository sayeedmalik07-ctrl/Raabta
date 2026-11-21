import 'package:raabta/services/drafts/draft_box_keys.dart';

/// Hive draft shaping for EOSB employee information under salary-storage consent.
abstract final class EosbEmployeeDraftPolicy {
  static bool isEosbEmployeeInfoDraft(String formId) {
    return formId == DraftBoxKeys.eosbEmployeeInfo;
  }

  static const _salaryFieldKeys = <String>{
    'companyName',
    'basicSalary',
    'finalBasicSalary',
    'basicSalaryChanged',
    'basicSalaryChangeDate',
    'totalSalary',
    'unusedLeave',
    'overtimeHours',
    'pendingSalary',
    'employerOffer',
    'otherBenefits',
    'joining',
    'lastDay',
    'contractTerminationDate',
    'dateOfLeavingWork',
  };

  static bool containsSalaryBearingValues(Map<String, dynamic> data) {
    for (final key in _salaryFieldKeys) {
      if (!_isBlank(data[key])) {
        if (key == 'basicSalaryChanged') {
          if (data[key] == true) return true;
          continue;
        }
        return true;
      }
    }
    return false;
  }

  static Map<String, dynamic> stripSalaryFields(Map<String, dynamic> data) {
    final copy = Map<String, dynamic>.from(data);
    for (final key in _salaryFieldKeys) {
      copy.remove(key);
    }
    return copy;
  }

  static bool _isBlank(dynamic value) {
    if (value == null) return true;
    if (value is bool) return value == false;
    if (value is num) return value == 0;
    final text = value.toString().trim();
    return text.isEmpty || text == '0' || text == '0.0';
  }
}
