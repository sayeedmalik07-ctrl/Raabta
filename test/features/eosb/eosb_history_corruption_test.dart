import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:raabta/core/persistence/local_data_isolation_keys.dart';
import 'package:raabta/core/persistence/uid_scoped_preferences.dart';
import 'package:raabta/features/eosb/data/eosb_history_storage.dart';
import 'package:raabta/features/eosb/data/eosb_repository.dart';
import 'package:raabta/features/eosb/domain/models/eosb_employee_input.dart';
import 'package:raabta/features/eosb/domain/models/eosb_history_load_outcome.dart';
import 'package:raabta/features/eosb/domain/models/eosb_result.dart';
import 'package:raabta/features/eosb/domain/models/overtime_truth_models.dart';
import 'package:raabta/features/eosb/domain/services/eosb_calculation_service.dart';
import 'package:raabta/features/eosb/providers/eosb_providers.dart';
import 'package:raabta/features/eosb/providers/overtime_truth_providers.dart';
import 'package:raabta/providers/auth_scoped_storage_providers.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _uid = 'hist-corrupt-uid';

String _scopedHistoryKey(String base) =>
    UidScopedPreferences.scopedKey(_uid, base);

CalculationHistoryEntry _sampleEosbEntry({String id = 'eosb-1'}) {
  const calc = EosbCalculationService();
  final input = const EosbEmployeeInput(basicSalary: 5000);
  final result = calc.calculate(input);
  return CalculationHistoryEntry(
    id: id,
    input: input,
    result: result,
    savedAt: DateTime(2025, 3, 1),
    label: '5,000',
  );
}

Map<String, dynamic> _eosbEntryJson(CalculationHistoryEntry entry) => {
  'id': entry.id,
  'input': entry.input.toJson(),
  'result': entry.result.toJson(),
  'savedAt': entry.savedAt.toIso8601String(),
  'label': entry.label,
  'salaryDetailsStored': entry.salaryDetailsStored,
};

OvertimeMonthlyRecord _otRecord({String id = '2025_1'}) {
  return OvertimeMonthlyRecord(
    id: id,
    year: 2025,
    month: 1,
    profile: const OvertimeEmployeeProfile(
      companyName: 'Co',
      basicSalary: 1000,
    ),
  );
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('EosbRepository EOSB calculation history', () {
    test('invalid JSON is corrupt with no salvaged records', () async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        _scopedHistoryKey(LocalDataIsolationKeys.eosbCalculationHistory),
        '{not json',
      );
      final repo = EosbRepository(prefs);

      final outcome = await repo.loadHistoryOutcome(uid: _uid);
      expect(outcome.status, EosbHistoryStorageStatus.corrupt);
      expect(outcome.isStorageCorrupt, isTrue);
      expect(outcome.records, isEmpty);
      expect(outcome.isGenuinelyEmpty, isFalse);
    });

    test('salvages valid records when mixed with malformed entries', () async {
      final prefs = await SharedPreferences.getInstance();
      final good = _eosbEntryJson(_sampleEosbEntry());
      await prefs.setString(
        _scopedHistoryKey(LocalDataIsolationKeys.eosbCalculationHistory),
        jsonEncode([
          good,
          'oops',
          {'id': 'bad'},
        ]),
      );
      final repo = EosbRepository(prefs);

      final outcome = await repo.loadHistoryOutcome(uid: _uid);
      expect(outcome.status, EosbHistoryStorageStatus.corrupt);
      expect(outcome.records, hasLength(1));
      expect(outcome.records.first.id, 'eosb-1');
    });

    test('genuine empty history is absent or valid empty', () async {
      final prefs = await SharedPreferences.getInstance();
      final repo = EosbRepository(prefs);

      var outcome = await repo.loadHistoryOutcome(uid: _uid);
      expect(outcome.status, EosbHistoryStorageStatus.absent);
      expect(outcome.isGenuinelyEmpty, isTrue);
      expect(outcome.isStorageCorrupt, isFalse);

      await prefs.setString(
        _scopedHistoryKey(LocalDataIsolationKeys.eosbCalculationHistory),
        '[]',
      );
      outcome = await repo.loadHistoryOutcome(uid: _uid);
      expect(outcome.status, EosbHistoryStorageStatus.valid);
      expect(outcome.records, isEmpty);
      expect(outcome.isGenuinelyEmpty, isTrue);
      expect(outcome.isStorageCorrupt, isFalse);
    });

    test('valid history round-trips through save', () async {
      final prefs = await SharedPreferences.getInstance();
      final repo = EosbRepository(prefs);
      await repo.setSalaryConsent(true, uid: _uid);

      final saved = await repo.saveHistoryEntry(_sampleEosbEntry(), uid: _uid);
      expect(saved.saved, isTrue);

      final outcome = await repo.loadHistoryOutcome(uid: _uid);
      expect(outcome.status, EosbHistoryStorageStatus.valid);
      expect(outcome.isStorageCorrupt, isFalse);
      expect(outcome.records, hasLength(1));
    });

    test('saveHistoryEntry blocked when storage is corrupt', () async {
      final prefs = await SharedPreferences.getInstance();
      final corruptRaw = jsonEncode([
        _eosbEntryJson(_sampleEosbEntry()),
        {'id': ' ', 'input': {}, 'result': {}},
      ]);
      await prefs.setString(
        _scopedHistoryKey(LocalDataIsolationKeys.eosbCalculationHistory),
        corruptRaw,
      );
      final repo = EosbRepository(prefs);
      await repo.setSalaryConsent(true, uid: _uid);

      final outcome = await repo.saveHistoryEntry(
        _sampleEosbEntry(id: 'new'),
        uid: _uid,
      );
      expect(outcome.saved, isFalse);
      expect(outcome.blockedByCorruptStorage, isTrue);
      expect(
        prefs.getString(
          _scopedHistoryKey(LocalDataIsolationKeys.eosbCalculationHistory),
        ),
        corruptRaw,
      );
    });

    test('deleteHistoryEntry blocked when storage is corrupt', () async {
      final prefs = await SharedPreferences.getInstance();
      final corruptRaw = jsonEncode([
        _eosbEntryJson(_sampleEosbEntry()),
        'trailing-garbage',
      ]);
      await prefs.setString(
        _scopedHistoryKey(LocalDataIsolationKeys.eosbCalculationHistory),
        corruptRaw,
      );
      final repo = EosbRepository(prefs);

      final outcome = await repo.deleteHistoryEntry('eosb-1', uid: _uid);
      expect(outcome.saved, isFalse);
      expect(outcome.blockedByCorruptStorage, isTrue);
      expect(
        prefs.getString(
          _scopedHistoryKey(LocalDataIsolationKeys.eosbCalculationHistory),
        ),
        corruptRaw,
      );
    });

    test('rejects EOSB entries with empty ids as malformed', () async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        _scopedHistoryKey(LocalDataIsolationKeys.eosbCalculationHistory),
        jsonEncode([
          _eosbEntryJson(_sampleEosbEntry()),
          {
            'id': '   ',
            'input': _sampleEosbEntry().input.toJson(),
            'result': _sampleEosbEntry().result.toJson(),
            'savedAt': '2025-01-01T00:00:00.000',
          },
        ]),
      );
      final repo = EosbRepository(prefs);
      final outcome = await repo.loadHistoryOutcome(uid: _uid);
      expect(outcome.isStorageCorrupt, isTrue);
      expect(outcome.records, hasLength(1));
    });
  });

  group('eosb history providers', () {
    test('distinguish corrupt storage from genuinely empty', () async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        _scopedHistoryKey(LocalDataIsolationKeys.eosbCalculationHistory),
        '{bad',
      );

      final container = ProviderContainer(
        overrides: [
          currentAuthUidProvider.overrideWith((ref) => _uid),
          eosbRepositoryProvider.overrideWith(
            (ref) async => EosbRepository(prefs),
          ),
        ],
      );
      addTearDown(container.dispose);

      await container.read(eosbHistoryLoadProvider.future);
      expect(container.read(eosbHistoryIsStorageCorruptProvider), isTrue);
      expect(container.read(eosbHistoryIsGenuinelyEmptyProvider), isFalse);
      final records = await container.read(eosbHistoryProvider.future);
      expect(records, isEmpty);
    });
  });

  group('EosbRepository overtime history corruption', () {
    Future<String?> rawOvertimeHistory(SharedPreferences prefs) async {
      return prefs.getString(
        _scopedHistoryKey(LocalDataIsolationKeys.eosbOvertimeHistory),
      );
    }

    test('invalid JSON is corrupt', () async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        _scopedHistoryKey(LocalDataIsolationKeys.eosbOvertimeHistory),
        '[truncated',
      );
      final repo = EosbRepository(prefs);
      final outcome = repo.loadOvertimeHistoryOutcome(uid: _uid);
      expect(outcome.status, EosbHistoryStorageStatus.corrupt);
      expect(outcome.records, isEmpty);
    });

    test('legacy OT id without year or month still loads', () async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        _scopedHistoryKey(LocalDataIsolationKeys.eosbOvertimeHistory),
        jsonEncode([
          {
            'id': '2024_3',
            'profile': {'companyName': 'Legacy Co'},
          },
        ]),
      );
      final repo = EosbRepository(prefs);
      final outcome = repo.loadOvertimeHistoryOutcome(uid: _uid);
      expect(outcome.status, EosbHistoryStorageStatus.valid);
      expect(outcome.isStorageCorrupt, isFalse);
      expect(outcome.records, hasLength(1));
      final record = outcome.records.first;
      expect(record.id, '2024_3');
      expect(record.year, 2024);
      expect(record.month, 3);
      expect(record.label, 'Mar 2024');
      expect(record.periodStart, DateTime(2024, 3));
    });

    test('rejects empty OT ids and invalid month/year', () async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        _scopedHistoryKey(LocalDataIsolationKeys.eosbOvertimeHistory),
        jsonEncode([
          _otRecord().toJson(),
          {'id': '', 'year': 2025, 'month': 1},
          {'id': 'no-legacy-id', 'year': 2025, 'month': 13},
        ]),
      );
      final repo = EosbRepository(prefs);
      final outcome = repo.loadOvertimeHistoryOutcome(uid: _uid);
      expect(outcome.isStorageCorrupt, isTrue);
      expect(outcome.records, hasLength(1));
    });

    test('salvages valid OT records from mixed payload', () async {
      final prefs = await SharedPreferences.getInstance();
      final good = _otRecord().toJson();
      await prefs.setString(
        _scopedHistoryKey(LocalDataIsolationKeys.eosbOvertimeHistory),
        jsonEncode([
          good,
          {
            'id': 'bad',
            'days': [1],
          },
        ]),
      );
      final repo = EosbRepository(prefs);

      final outcome = repo.loadOvertimeHistoryOutcome(uid: _uid);
      expect(outcome.status, EosbHistoryStorageStatus.corrupt);
      expect(outcome.records, hasLength(1));
      expect(outcome.records.first.id, '2025_1');
    });

    test('saveOvertimeHistory blocked when storage is corrupt', () async {
      final prefs = await SharedPreferences.getInstance();
      final corruptRaw = jsonEncode([
        _otRecord(id: 'keep').toJson(),
        {
          'id': 'bad',
          'days': [null],
        },
      ]);
      await prefs.setString(
        _scopedHistoryKey(LocalDataIsolationKeys.eosbOvertimeHistory),
        corruptRaw,
      );
      final repo = EosbRepository(prefs);
      await repo.setSalaryConsent(true, uid: _uid);

      final outcome = await repo.saveOvertimeHistory([
        _otRecord(id: 'new'),
        _otRecord(id: 'keep'),
      ], uid: _uid);
      expect(outcome.saved, isFalse);
      expect(outcome.blockedByCorruptStorage, isTrue);
      expect(await rawOvertimeHistory(prefs), corruptRaw);
    });

    test('valid overtime history round-trips', () async {
      final prefs = await SharedPreferences.getInstance();
      final repo = EosbRepository(prefs);
      await repo.setSalaryConsent(true, uid: _uid);

      final save = await repo.saveOvertimeHistory([_otRecord()], uid: _uid);
      expect(save.saved, isTrue);

      final outcome = repo.loadOvertimeHistoryOutcome(uid: _uid);
      expect(outcome.status, EosbHistoryStorageStatus.valid);
      expect(outcome.records, hasLength(1));
    });
  });

  group('EosbHistoryStorage legacy OT year/month normalization', () {
    OvertimeHistoryLoadOutcome parse(List<Map<String, dynamic>> rows) {
      return EosbHistoryStorage.parseOvertimeHistory(jsonEncode(rows));
    }

    test('2024_3 without year/month normalizes to March 2024', () {
      final outcome = parse([
        {
          'id': '2024_3',
          'profile': {'companyName': 'Legacy Co'},
        },
      ]);
      expect(outcome.status, EosbHistoryStorageStatus.valid);
      final record = outcome.records.single;
      expect(record.year, 2024);
      expect(record.month, 3);
      expect(record.label, 'Mar 2024');
      expect(record.periodStart, DateTime(2024, 3));
      expect(record.periodEnd, DateTime(2024, 3, 31));
    });

    test('2025_6 without year/month normalizes to June 2025', () {
      final outcome = parse([
        {
          'id': '2025_6',
          'profile': {'companyName': 'Mid Co'},
        },
      ]);
      final record = outcome.records.single;
      expect(record.year, 2025);
      expect(record.month, 6);
      expect(record.label, 'Jun 2025');
      expect(record.periodStart, DateTime(2025, 6));
    });

    test('explicit year/month in JSON take precedence over id', () {
      final outcome = parse([
        {
          'id': '2024_3',
          'year': 2025,
          'month': 6,
          'profile': {'companyName': 'Explicit Co'},
        },
      ]);
      final record = outcome.records.single;
      expect(record.year, 2025);
      expect(record.month, 6);
      expect(record.label, 'Jun 2025');
    });

    test('invalid legacy rows stay corrupt and are not salvaged', () {
      final outcome = parse([
        _otRecord().toJson(),
        {'id': 'no-legacy-id', 'year': 2025, 'month': 13},
      ]);
      expect(outcome.isStorageCorrupt, isTrue);
      expect(outcome.records, hasLength(1));
      expect(outcome.records.single.id, '2025_1');
    });

    test('duplicate id prefix uses normalized year and month', () {
      final outcome = parse([
        {
          'id': '2024_3',
          'profile': {'companyName': 'Legacy Co'},
        },
      ]);
      final record = outcome.records.single;
      final dup = record.copyWith(id: '${record.year}_${record.month}_dup_123');
      expect(dup.id, '2024_3_dup_123');
      expect(dup.year, 2024);
      expect(dup.month, 3);
    });
  });

  group('OvertimeTruthNotifier corrupt storage protection', () {
    ProviderContainer buildContainer(EosbRepository repo) {
      final container = ProviderContainer(
        overrides: [
          currentAuthUidProvider.overrideWith((ref) => _uid),
          eosbRepositoryProvider.overrideWith((ref) async => repo),
          eosbProvider.overrideWith((ref) {
            final calc = ref.watch(eosbCalculationServiceProvider);
            return EosbNotifier(calc, repo, ref);
          }),
        ],
      );
      addTearDown(container.dispose);
      return container;
    }

    test('hydration exposes corrupt flag and salvaged rows', () async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        _scopedHistoryKey(LocalDataIsolationKeys.eosbOvertimeHistory),
        jsonEncode([_otRecord(id: 'salvaged').toJson(), 'bad']),
      );
      final repo = EosbRepository(prefs);
      final container = buildContainer(repo);
      await container.read(eosbRepositoryProvider.future);

      final ot = container.read(overtimeTruthProvider.notifier);
      ot.attachRepository(repo);
      await ot.flushHydration();

      final state = container.read(overtimeTruthProvider);
      expect(state.historyStorageCorrupt, isTrue);
      expect(state.historyLoadStatus, EosbHistoryStorageStatus.corrupt);
      expect(state.history, hasLength(1));
      expect(container.read(overtimeHistoryStorageCorruptProvider), isTrue);
    });

    test('duplicate delete favorite blocked while storage corrupt', () async {
      final prefs = await SharedPreferences.getInstance();
      final corruptRaw = jsonEncode([
        _otRecord(id: 'a').toJson(),
        {
          'id': 'bad',
          'days': [null],
        },
      ]);
      await prefs.setString(
        _scopedHistoryKey(LocalDataIsolationKeys.eosbOvertimeHistory),
        corruptRaw,
      );
      final repo = EosbRepository(prefs);
      await repo.setSalaryConsent(true, uid: _uid);
      final container = buildContainer(repo);
      await container.read(eosbRepositoryProvider.future);

      final ot = container.read(overtimeTruthProvider.notifier);
      ot.attachRepository(repo);
      await ot.flushHydration();

      final salvaged = ot.state.history.first;
      await ot.duplicateHistoryRecord(salvaged);
      expect(ot.state.error, eosbHistoryPersistenceFailedErrorCode);
      expect(
        prefs.getString(
          _scopedHistoryKey(LocalDataIsolationKeys.eosbOvertimeHistory),
        ),
        corruptRaw,
      );

      await ot.deleteFromHistory(salvaged.id);
      expect(
        prefs.getString(
          _scopedHistoryKey(LocalDataIsolationKeys.eosbOvertimeHistory),
        ),
        corruptRaw,
      );

      await ot.toggleFavorite(salvaged.id);
      expect(
        prefs.getString(
          _scopedHistoryKey(LocalDataIsolationKeys.eosbOvertimeHistory),
        ),
        corruptRaw,
      );
    });

    test(
      'saveCurrentToHistory fails and preserves corrupt OT raw JSON',
      () async {
        final prefs = await SharedPreferences.getInstance();
        final corruptRaw = jsonEncode([
          _otRecord(id: 'keep').toJson(),
          {
            'id': 'bad',
            'days': [null],
          },
        ]);
        await prefs.setString(
          _scopedHistoryKey(LocalDataIsolationKeys.eosbOvertimeHistory),
          corruptRaw,
        );
        final repo = EosbRepository(prefs);
        await repo.setSalaryConsent(true, uid: _uid);
        final container = buildContainer(repo);
        await container.read(eosbRepositoryProvider.future);

        final ot = container.read(overtimeTruthProvider.notifier);
        ot.attachRepository(repo);
        await ot.flushHydration();

        expect(await ot.saveCurrentToHistory(), isFalse);
        expect(ot.state.error, eosbHistoryPersistenceFailedErrorCode);
        expect(
          prefs.getString(
            _scopedHistoryKey(LocalDataIsolationKeys.eosbOvertimeHistory),
          ),
          corruptRaw,
        );
      },
    );
  });
}
