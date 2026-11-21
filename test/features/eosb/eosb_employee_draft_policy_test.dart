import 'package:flutter_test/flutter_test.dart';
import 'package:raabta/features/eosb/domain/services/eosb_employee_draft_policy.dart';

void main() {
  group('EosbEmployeeDraftPolicy', () {
    test('detects salary-bearing draft values', () {
      expect(
        EosbEmployeeDraftPolicy.containsSalaryBearingValues({
          'companyName': 'Acme',
          'contractType': 'unlimited',
        }),
        isTrue,
      );
      expect(
        EosbEmployeeDraftPolicy.containsSalaryBearingValues({
          'contractType': 'unlimited',
          'termination': 'employerTermination',
        }),
        isFalse,
      );
    });

    test('stripSalaryFields removes employer and wage keys', () {
      final stripped = EosbEmployeeDraftPolicy.stripSalaryFields({
        'companyName': 'Acme',
        'basicSalary': '5000',
        'contractType': 'unlimited',
        'noticeServed': true,
      });
      expect(stripped.containsKey('companyName'), isFalse);
      expect(stripped.containsKey('basicSalary'), isFalse);
      expect(stripped['contractType'], 'unlimited');
      expect(stripped['noticeServed'], isTrue);
    });
  });
}
