import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:raabta/core/persistence/local_data_isolation_keys.dart';
import 'package:raabta/core/persistence/uid_scoped_preferences.dart';
import 'package:raabta/features/eosb/data/eosb_repository.dart';
import 'package:raabta/features/eosb/domain/models/overtime_truth_models.dart';
import 'package:raabta/features/eosb/domain/services/overtime_truth_engine.dart';
import 'package:shared_preferences/shared_preferences.dart';

OvertimeMonthlyRecord _salaryRecord(String id) {
  return OvertimeMonthlyRecord(
    id: id,
    year: 2025,
    month: 4,
    profile: const OvertimeEmployeeProfile(
      companyName: 'Employer Co',
      basicSalary: 3000,
    ),
    employerPaidOvertime: 200,
  );
}

OvertimeTruthResult _resultFor(OvertimeMonthlyRecord record) {
  return OvertimeTruthEngine.calculateRecord(record.withFullMonthDays());
}

void main() {
  group('EosbRepository overtime salary consent', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('cacheOvertimeInput skipped when consent is false', () async {
      final prefs = await SharedPreferences.getInstance();
      final repo = EosbRepository(prefs);
      const uid = 'ot-user-1';

      await repo.setSalaryConsent(false, uid: uid);
      final input = OvertimeTruthInput(
        companyName: 'Co',
        basicSalary: 1000,
        record: _salaryRecord('r1'),
      );
      await repo.cacheOvertimeInput(input, uid: uid);

      expect(
        prefs.getString(
          UidScopedPreferences.scopedKey(
            uid,
            LocalDataIsolationKeys.eosbOvertimeInput,
          ),
        ),
        isNull,
      );
    });

    test(
      'setSalaryConsent false clears overtime input/result caches',
      () async {
        final prefs = await SharedPreferences.getInstance();
        final repo = EosbRepository(prefs);
        const uid = 'ot-user-2';

        await repo.setSalaryConsent(true, uid: uid);
        final record = _salaryRecord('r2').withFullMonthDays();
        final result = _resultFor(record);
        await repo.cacheOvertimeInput(result.input, uid: uid);
        await repo.saveOvertimeResult(result, uid: uid);

        await repo.setSalaryConsent(false, uid: uid);

        expect(repo.loadCachedOvertimeInput(uid: uid), isNull);
        expect(repo.loadCachedOvertimeResult(uid: uid), isNull);
      },
    );

    test(
      'saveOvertimeHistory stores redacted rows when consent false',
      () async {
        final prefs = await SharedPreferences.getInstance();
        final repo = EosbRepository(prefs);
        const uid = 'ot-user-3';

        await repo.setSalaryConsent(false, uid: uid);
        await repo.saveOvertimeHistory([_salaryRecord('hist-1')], uid: uid);

        final history = repo.loadOvertimeHistory(uid: uid);
        expect(history, hasLength(1));
        expect(history.first.salaryDetailsStored, isFalse);
        expect(history.first.profile.basicSalary, 0);
        expect(history.first.profile.companyName, isEmpty);

        final raw = prefs.getString(
          UidScopedPreferences.scopedKey(
            uid,
            LocalDataIsolationKeys.eosbOvertimeHistory,
          ),
        );
        final decoded = jsonDecode(raw!) as List;
        expect((decoded.first as Map)['salaryDetailsStored'], isFalse);
      },
    );

    test('saveOvertimeHistory keeps salary when consent true', () async {
      final prefs = await SharedPreferences.getInstance();
      final repo = EosbRepository(prefs);
      const uid = 'ot-user-4';

      await repo.setSalaryConsent(true, uid: uid);
      await repo.saveOvertimeHistory([_salaryRecord('hist-2')], uid: uid);

      final history = repo.loadOvertimeHistory(uid: uid);
      expect(history.first.salaryDetailsStored, isTrue);
      expect(history.first.profile.basicSalary, 3000);
    });

    test('overtime storage is UID-scoped', () async {
      final prefs = await SharedPreferences.getInstance();
      final repo = EosbRepository(prefs);
      const uidA = 'ot-a';
      const uidB = 'ot-b';

      await repo.setSalaryConsent(true, uid: uidA);
      await repo.saveOvertimeHistory([_salaryRecord('a1')], uid: uidA);

      expect(repo.loadOvertimeHistory(uid: uidB), isEmpty);
      expect(repo.salaryConsent(uid: uidB), isFalse);
    });

    test(
      'setSalaryConsent false redacts salary in existing overtime history',
      () async {
        final prefs = await SharedPreferences.getInstance();
        final repo = EosbRepository(prefs);
        const uid = 'ot-redact-hist';

        await repo.setSalaryConsent(true, uid: uid);
        await repo.saveOvertimeHistory([_salaryRecord('ot-hist-1')], uid: uid);

        await repo.setSalaryConsent(false, uid: uid);

        final history = repo.loadOvertimeHistory(uid: uid);
        expect(history, hasLength(1));
        expect(history.first.id, 'ot-hist-1');
        expect(history.first.salaryDetailsStored, isFalse);
        expect(history.first.profile.basicSalary, 0);
        expect(history.first.profile.companyName, isEmpty);
      },
    );

    test('loadCachedOvertimeInput returns null when consent off', () async {
      final prefs = await SharedPreferences.getInstance();
      final repo = EosbRepository(prefs);
      const uid = 'ot-stale-input';

      await UidScopedPreferences.setString(
        prefs,
        LocalDataIsolationKeys.eosbOvertimeInput,
        jsonEncode(
          OvertimeTruthInput(
            companyName: 'Co',
            basicSalary: 1000,
            record: _salaryRecord('stale'),
          ).toJson(),
        ),
        uid: uid,
      );
      await UidScopedPreferences.setBool(
        prefs,
        LocalDataIsolationKeys.eosbSalaryConsent,
        false,
        uid: uid,
      );

      expect(repo.loadCachedOvertimeInput(uid: uid), isNull);
      expect(repo.loadCachedOvertimeResult(uid: uid), isNull);
    });
  });
}
