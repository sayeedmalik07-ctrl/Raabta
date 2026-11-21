import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:raabta/features/eosb/domain/models/overtime_truth_models.dart';
import 'package:raabta/features/eosb/domain/services/overtime_salary_storage_policy.dart';

OvertimeMonthlyRecord _sampleRecord() {
  return OvertimeMonthlyRecord(
    id: '2025_3_test',
    year: 2025,
    month: 3,
    profile: const OvertimeEmployeeProfile(
      companyName: 'Acme',
      basicSalary: 4000,
      employeeName: 'Sam',
    ),
    employerPaidOvertime: 500,
    updatedAt: DateTime(2025, 3, 15),
  );
}

void main() {
  group('OvertimeSalaryStoragePolicy', () {
    test('firestore doc includes employer fields when consent on', () {
      final doc = OvertimeSalaryStoragePolicy.firestoreOvertimeDoc(
        record: _sampleRecord(),
        calculatedAt: DateTime(2025, 3, 15),
        violationFlagged: true,
        includeSalaryDetails: true,
      );
      expect(doc['hasSalaryData'], isTrue);
      expect(doc['companyName'], 'Acme');
      expect(doc['normalizedEmployerKey'], isNotEmpty);
      expect(doc['year'], 2025);
    });

    test('firestore doc deletes employer fields when consent off', () {
      final doc = OvertimeSalaryStoragePolicy.firestoreOvertimeDoc(
        record: _sampleRecord(),
        calculatedAt: DateTime(2025, 3, 15),
        violationFlagged: false,
        includeSalaryDetails: false,
      );
      expect(doc['hasSalaryData'], isFalse);
      expect(doc['companyName'], isA<FieldValue>());
      expect(doc['normalizedEmployerKey'], isA<FieldValue>());
      expect(doc['violationFlagged'], isFalse);
    });

    test('prepareHistoryList redacts new rows when consent off', () {
      final record = _sampleRecord();
      final prepared = OvertimeSalaryStoragePolicy.prepareHistoryList(
        records: [record],
        includeSalaryDetails: false,
        existingById: const {},
      );
      expect(prepared, hasLength(1));
      expect(prepared.first.salaryDetailsStored, isFalse);
      expect(prepared.first.profile.basicSalary, 0);
      expect(prepared.first.profile.companyName, isEmpty);
      expect(prepared.first.employerPaidOvertime, 0);
    });

    test('prepareHistoryList redacts legacy salary rows when consent off', () {
      final legacy = _sampleRecord().copyWith(salaryDetailsStored: true);
      final incoming = legacy.copyWith(isFavorite: true);
      final prepared = OvertimeSalaryStoragePolicy.prepareHistoryList(
        records: [incoming],
        includeSalaryDetails: false,
        existingById: {legacy.id: legacy},
      );
      expect(prepared.first.salaryDetailsStored, isFalse);
      expect(prepared.first.profile.basicSalary, 0);
      expect(prepared.first.profile.companyName, isEmpty);
      expect(prepared.first.isFavorite, isTrue);
    });

    test('recordToExportJson redacts metadata-only rows', () {
      final redacted = OvertimeSalaryStoragePolicy.redactRecord(
        _sampleRecord(),
      );
      final json = OvertimeSalaryStoragePolicy.recordToExportJson(redacted);
      expect(json['salaryDetailsStored'], isFalse);
      expect((json['profile'] as Map)['basicSalary'], 0);
    });
  });
}
