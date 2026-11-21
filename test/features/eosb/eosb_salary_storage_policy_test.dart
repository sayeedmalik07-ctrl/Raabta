import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:raabta/features/eosb/domain/models/eosb_employee_input.dart';
import 'package:raabta/features/eosb/domain/models/eosb_result.dart';
import 'package:raabta/features/eosb/domain/services/eosb_calculation_service.dart';
import 'package:raabta/features/eosb/domain/services/eosb_salary_storage_policy.dart';

CalculationHistoryEntry _entry() {
  const calc = EosbCalculationService();
  const input = EosbEmployeeInput(
    basicSalary: 6000,
    companyName: 'Acme',
    joiningDate: null,
    lastWorkingDate: null,
  );
  final result = calc.calculate(
    input.copyWith(
      joiningDate: DateTime(2020, 1, 1),
      lastWorkingDate: DateTime(2024, 6, 1),
    ),
  );
  return CalculationHistoryEntry(
    id: 'e1',
    input: input.copyWith(
      joiningDate: DateTime(2020, 1, 1),
      lastWorkingDate: DateTime(2024, 6, 1),
    ),
    result: result,
    savedAt: DateTime(2025, 1, 2),
    label: 'QAR 12,000',
  );
}

void main() {
  group('EosbSalaryStoragePolicy', () {
    test('firestore doc includes salary fields when consent on', () {
      final doc = EosbSalaryStoragePolicy.firestoreCalculationDoc(
        entry: _entry(),
        legalVersionVerifiedAt: '2025-01-01',
        includeSalaryDetails: true,
      );
      expect(doc['hasSalaryData'], isTrue);
      expect(doc['totalEntitlement'], isNotNull);
      expect(doc['companyName'], 'Acme');
      expect(doc.containsKey('totalEntitlement'), isTrue);
    });

    test('firestore doc deletes salary fields when consent off', () {
      final doc = EosbSalaryStoragePolicy.firestoreCalculationDoc(
        entry: _entry(),
        legalVersionVerifiedAt: '2025-01-01',
        includeSalaryDetails: false,
      );
      expect(doc['hasSalaryData'], isFalse);
      expect(doc['totalEntitlement'], isA<FieldValue>());
      expect(doc['companyName'], isA<FieldValue>());
      expect(doc['contractType'], isNotNull);
      expect(doc['violationRuleKeys'], isA<List<dynamic>>());
    });

    test('user summary deletes date fields when consent off', () {
      final summary = EosbSalaryStoragePolicy.firestoreUserSummary(
        calculationCount: 2,
        entry: _entry(),
        legalVersionVerifiedAt: '2025-01-01',
        includeSalaryDetails: false,
      );
      expect(summary['joiningDate'], isA<FieldValue>());
      expect(summary['contractEndDate'], isA<FieldValue>());
      expect(summary['calculationCount'], 2);
    });

    test('prepareHistoryEntry redacts local payload when consent off', () {
      final prepared = EosbSalaryStoragePolicy.prepareHistoryEntry(
        entry: _entry(),
        includeSalaryDetails: false,
      );
      expect(prepared.salaryDetailsStored, isFalse);
      expect(prepared.input.basicSalary, 0);
      expect(prepared.input.companyName, isEmpty);
      expect(prepared.result.totalEntitlement, 0);
      expect(prepared.result.breakdown, isEmpty);
    });
  });
}
