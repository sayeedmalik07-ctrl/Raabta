import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:raabta/core/persistence/local_data_isolation_keys.dart';
import 'package:raabta/core/persistence/uid_scoped_preferences.dart';
import 'package:raabta/features/eosb/data/eosb_repository.dart';
import 'package:raabta/features/eosb/domain/models/eosb_employee_input.dart';
import 'package:raabta/features/eosb/domain/models/eosb_result.dart';
import 'package:raabta/features/eosb/domain/services/eosb_calculation_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

EosbEmployeeInput _sampleInput() => EosbEmployeeInput(
  basicSalary: 5000,
  companyName: 'Test Co',
  joiningDate: DateTime(2019, 1, 1),
  lastWorkingDate: DateTime(2024, 6, 1),
);

void main() {
  group('EosbRepository salary consent', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('cacheInput writes offline cache only when consent is true', () async {
      final prefs = await SharedPreferences.getInstance();
      final repo = EosbRepository(prefs);
      const uid = 'user-a';

      await repo.setSalaryConsent(true, uid: uid);
      await repo.cacheInput(_sampleInput(), uid: uid);

      final raw = prefs.getString(
        UidScopedPreferences.scopedKey(
          uid,
          LocalDataIsolationKeys.eosbOfflineCache,
        ),
      );
      expect(raw, isNotNull);

      await repo.setSalaryConsent(false, uid: uid);
      await repo.cacheInput(_sampleInput(), uid: uid);

      final cleared = prefs.getString(
        UidScopedPreferences.scopedKey(
          uid,
          LocalDataIsolationKeys.eosbOfflineCache,
        ),
      );
      expect(cleared, isNull);
    });

    test('setSalaryConsent false clears existing offline cache', () async {
      final prefs = await SharedPreferences.getInstance();
      final repo = EosbRepository(prefs);
      const uid = 'user-b';

      await repo.setSalaryConsent(true, uid: uid);
      await repo.cacheInput(_sampleInput(), uid: uid);
      expect(
        prefs.getString(
          UidScopedPreferences.scopedKey(
            uid,
            LocalDataIsolationKeys.eosbOfflineCache,
          ),
        ),
        isNotNull,
      );

      await repo.setSalaryConsent(false, uid: uid);

      expect(
        prefs.getString(
          UidScopedPreferences.scopedKey(
            uid,
            LocalDataIsolationKeys.eosbOfflineCache,
          ),
        ),
        isNull,
      );
      expect(repo.salaryConsent(uid: uid), isFalse);
    });

    test('consent and cache are UID-scoped', () async {
      final prefs = await SharedPreferences.getInstance();
      final repo = EosbRepository(prefs);
      const uidA = 'user-a';
      const uidB = 'user-b';

      await repo.setSalaryConsent(true, uid: uidA);
      await repo.cacheInput(_sampleInput(), uid: uidA);

      expect(repo.salaryConsent(uid: uidB), isFalse);
      expect(
        prefs.getString(
          UidScopedPreferences.scopedKey(
            uidB,
            LocalDataIsolationKeys.eosbOfflineCache,
          ),
        ),
        isNull,
      );
    });

    test(
      'saveHistoryEntry stores metadata only when consent is false',
      () async {
        final prefs = await SharedPreferences.getInstance();
        final repo = EosbRepository(prefs);
        const uid = 'user-c';
        await repo.setSalaryConsent(false, uid: uid);

        const calc = EosbCalculationService();
        final input = _sampleInput();
        final result = calc.calculate(input);
        final saved = await repo.saveHistoryEntry(
          CalculationHistoryEntry(
            id: 'hist-1',
            input: input,
            result: result,
            savedAt: DateTime(2025, 1, 1),
            label: '5,000',
          ),
          uid: uid,
        );
        expect(saved.saved, isTrue);
        expect(saved.includesSalaryDetails, isFalse);
        final history = await repo.loadHistory(uid: uid);
        expect(history, hasLength(1));
        expect(history.first.salaryDetailsStored, isFalse);
        expect(history.first.input.basicSalary, 0);
        expect(history.first.result.totalEntitlement, 0);
      },
    );

    test('saveHistoryEntry includes salary when consent is true', () async {
      final prefs = await SharedPreferences.getInstance();
      final repo = EosbRepository(prefs);
      const uid = 'user-d';
      await repo.setSalaryConsent(true, uid: uid);

      const calc = EosbCalculationService();
      final input = _sampleInput();
      final result = calc.calculate(input);
      final outcome = await repo.saveHistoryEntry(
        CalculationHistoryEntry(
          id: 'hist-2',
          input: input,
          result: result,
          savedAt: DateTime(2025, 1, 1),
          label: '5,000',
        ),
        uid: uid,
      );
      expect(outcome.includesSalaryDetails, isTrue);
      final history = await repo.loadHistory(uid: uid);
      expect(history.first.input.basicSalary, greaterThan(0));
      expect(history.first.result.totalEntitlement, greaterThan(0));
    });

    test(
      'setSalaryConsent false redacts salary in existing calculation history',
      () async {
        final prefs = await SharedPreferences.getInstance();
        final repo = EosbRepository(prefs);
        const uid = 'user-redact-hist';

        await repo.setSalaryConsent(true, uid: uid);
        const calc = EosbCalculationService();
        final input = _sampleInput();
        final result = calc.calculate(input);
        await repo.saveHistoryEntry(
          CalculationHistoryEntry(
            id: 'hist-redact-1',
            input: input,
            result: result,
            savedAt: DateTime(2025, 1, 1),
            label: '5,000',
          ),
          uid: uid,
        );

        await repo.setSalaryConsent(false, uid: uid);

        final history = await repo.loadHistory(uid: uid);
        expect(history, hasLength(1));
        expect(history.first.id, 'hist-redact-1');
        expect(history.first.salaryDetailsStored, isFalse);
        expect(history.first.input.basicSalary, 0);
        expect(history.first.result.totalEntitlement, 0);
      },
    );

    test(
      'loadCachedInput returns null when consent off despite stale cache',
      () async {
        final prefs = await SharedPreferences.getInstance();
        final repo = EosbRepository(prefs);
        const uid = 'user-stale-cache';

        await repo.setSalaryConsent(true, uid: uid);
        await repo.cacheInput(_sampleInput(), uid: uid);
        await UidScopedPreferences.setBool(
          prefs,
          LocalDataIsolationKeys.eosbSalaryConsent,
          false,
          uid: uid,
        );
        await UidScopedPreferences.setString(
          prefs,
          LocalDataIsolationKeys.eosbOfflineCache,
          jsonEncode(_sampleInput().toJson()),
          uid: uid,
        );

        expect(repo.loadCachedInput(uid: uid), isNull);
      },
    );

    test(
      'setSalaryConsent false does not overwrite corrupt calculation history',
      () async {
        final prefs = await SharedPreferences.getInstance();
        final repo = EosbRepository(prefs);
        const uid = 'user-corrupt-hist';
        const corruptPayload = '{not valid json';

        await UidScopedPreferences.setString(
          prefs,
          LocalDataIsolationKeys.eosbCalculationHistory,
          corruptPayload,
          uid: uid,
        );

        await repo.setSalaryConsent(false, uid: uid);

        expect(
          prefs.getString(
            UidScopedPreferences.scopedKey(
              uid,
              LocalDataIsolationKeys.eosbCalculationHistory,
            ),
          ),
          corruptPayload,
        );
        final outcome = await repo.loadHistoryOutcome(uid: uid);
        expect(outcome.isStorageCorrupt, isTrue);
      },
    );
  });
}
