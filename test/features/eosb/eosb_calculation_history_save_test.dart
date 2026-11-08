import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raabta/core/persistence/local_data_isolation_keys.dart';
import 'package:raabta/core/persistence/uid_scoped_preferences.dart';
import 'package:raabta/features/eosb/data/eosb_repository.dart';
import 'package:raabta/features/eosb/domain/models/eosb_employee_input.dart';
import 'package:raabta/features/eosb/domain/models/eosb_result.dart';
import 'package:raabta/features/eosb/domain/services/eosb_calculation_service.dart';
import 'package:raabta/features/eosb/providers/eosb_providers.dart';
import 'package:raabta/features/home/domain/truth_chip_status.dart';
import 'package:raabta/features/home/providers/truth_chip_status_providers.dart';
import 'package:raabta/providers/auth_scoped_storage_providers.dart';
import 'package:shared_preferences/shared_preferences.dart';

EosbEmployeeInput _sampleInput() => EosbEmployeeInput(
      basicSalary: 8000,
      joiningDate: DateTime(2019, 6, 1),
      lastWorkingDate: DateTime(2025, 6, 1),
    );

final _eosbTestRefProvider = Provider<Ref>((ref) => ref);

Ref _refFrom(ProviderContainer container) =>
    container.read(_eosbTestRefProvider);

CalculationHistoryEntry _sampleEntry() {
  const calc = EosbCalculationService();
  final input = _sampleInput();
  final result = calc.calculate(input);
  return CalculationHistoryEntry(
    id: 'entry-1',
    input: input,
    result: result,
    savedAt: DateTime(2025, 6, 2),
    label: '12,000',
  );
}

void main() {
  group('EosbRepository.saveHistoryEntry', () {
    setUp(() async {
      SharedPreferences.setMockInitialValues({});
    });

    test('returns true and round-trips history for explicit uid', () async {
      final prefs = await SharedPreferences.getInstance();
      final repo = EosbRepository(prefs);
      const uid = 'eosb-save-test-uid';

      final saved = await repo.saveHistoryEntry(_sampleEntry(), uid: uid);
      expect(saved, isTrue);

      final history = await repo.loadHistory(uid: uid);
      expect(history, hasLength(1));
      expect(history.first.id, 'entry-1');
    });

    test('returns false for guest/no UID scope', () async {
      final prefs = await SharedPreferences.getInstance();
      final repo = EosbRepository(prefs);

      final saved = await repo.saveHistoryEntry(_sampleEntry());
      expect(saved, isFalse);

      final raw = prefs.getString(
        UidScopedPreferences.scopedKey(
          'ghost',
          LocalDataIsolationKeys.eosbCalculationHistory,
        ),
      );
      expect(raw, isNull);
    });
  });

  group('persistEosbCalculationHistory', () {
    test('invalidates Home truth providers only after successful save', () async {
      var truthFetches = 0;
      var historyFetches = 0;

      final container = ProviderContainer(
        overrides: [
          eosbHistoryProvider.overrideWith((ref) async {
            historyFetches++;
            return [];
          }),
          truthChipStatusProvider(TruthChipEngine.eosb).overrideWith((ref) async {
            truthFetches++;
            await ref.watch(eosbHistoryProvider.future);
            return TruthChipStatus.loading(
              engine: TruthChipEngine.eosb,
              titleKey: 'tool_eosb_title',
              deepLink: '/eosb',
            );
          }),
        ],
      );
      addTearDown(container.dispose);

      final prefs = await SharedPreferences.getInstance();
      final repository = EosbRepository(prefs);

      container.read(truthChipStatusProvider(TruthChipEngine.eosb));
      expect(truthFetches, 1);

      final saved = await persistEosbCalculationHistory(
        ref: container,
        repository: repository,
        entry: _sampleEntry(),
        uid: 'persist-uid',
      );
      expect(saved, isTrue);
      expect(truthFetches, 1);
      container.read(truthChipStatusProvider(TruthChipEngine.eosb));
      expect(truthFetches, 2);
      expect(historyFetches, greaterThanOrEqualTo(2));
    });

    test('does not invalidate when persistence fails', () async {
      var truthFetches = 0;

      final container = ProviderContainer(
        overrides: [
          truthChipStatusProvider(TruthChipEngine.eosb).overrideWith((ref) async {
            truthFetches++;
            return const TruthChipStatus(
              engine: TruthChipEngine.eosb,
              state: TruthChipState.invite,
              tone: TruthChipTone.neutral,
              titleKey: 'tool_eosb_title',
              statusText: 'invite',
              freshnessText: '',
              deepLink: '/eosb',
            );
          }),
        ],
      );
      addTearDown(container.dispose);

      container.read(truthChipStatusProvider(TruthChipEngine.eosb));
      expect(truthFetches, 1);

      final prefs = await SharedPreferences.getInstance();
      final repository = EosbRepository(prefs);

      final saved = await persistEosbCalculationHistory(
        ref: container,
        repository: repository,
        entry: _sampleEntry(),
        uid: null,
      );
      expect(saved, isFalse);
      expect(truthFetches, 1);
    });
  });

  group('EosbNotifier.calculate saveHistory', () {
    setUp(() async {
      SharedPreferences.setMockInitialValues({});
    });

    test('awaits repository provider when notifier was constructed without repo',
        () async {
      final prefs = await SharedPreferences.getInstance();
      final repository = EosbRepository(prefs);
      final repoReady = Completer<EosbRepository>();

      final container = ProviderContainer(
        overrides: [
          currentAuthUidProvider.overrideWith((ref) => 'signed-in-uid'),
          eosbRepositoryProvider.overrideWith((ref) => repoReady.future),
        ],
      );
      addTearDown(container.dispose);

      final notifier = EosbNotifier(
        const EosbCalculationService(),
        null,
        _refFrom(container),
      );
      notifier.updateInput(_sampleInput());

      final calculateFuture = notifier.calculate();
      await Future<void>.delayed(Duration.zero);
      expect(repoReady.isCompleted, isFalse);

      repoReady.complete(repository);
      final result = await calculateFuture;

      expect(result, isNotNull);
      expect(notifier.state.error, isNull);
      final history = await repository.loadHistory(uid: 'signed-in-uid');
      expect(history, isNotEmpty);
    });

    test('returns result but sets error when UID-scoped save fails', () async {
      final prefs = await SharedPreferences.getInstance();
      final repository = EosbRepository(prefs);

      final container = ProviderContainer(
        overrides: [
          currentAuthUidProvider.overrideWith((ref) => null),
          eosbRepositoryProvider.overrideWith((ref) async => repository),
        ],
      );
      addTearDown(container.dispose);

      final notifier = EosbNotifier(
        const EosbCalculationService(),
        null,
        _refFrom(container),
      );
      notifier.updateInput(_sampleInput());
      final result = await notifier.calculate();

      expect(result, isNotNull);
      expect(notifier.state.error, eosbHistoryPersistenceFailedMessage);
      final history = await repository.loadHistory();
      expect(history, isEmpty);
    });

    test('saveHistory:false skips persistence', () async {
      var truthFetches = 0;
      final prefs = await SharedPreferences.getInstance();
      final repository = EosbRepository(prefs);

      final container = ProviderContainer(
        overrides: [
          currentAuthUidProvider.overrideWith((ref) => 'signed-in-uid'),
          eosbRepositoryProvider.overrideWith((ref) async => repository),
          truthChipStatusProvider(TruthChipEngine.eosb).overrideWith((ref) async {
            truthFetches++;
            return TruthChipStatus.loading(
              engine: TruthChipEngine.eosb,
              titleKey: 'tool_eosb_title',
              deepLink: '/eosb',
            );
          }),
        ],
      );
      addTearDown(container.dispose);

      container.read(truthChipStatusProvider(TruthChipEngine.eosb));
      expect(truthFetches, 1);

      final notifier = EosbNotifier(
        const EosbCalculationService(),
        null,
        _refFrom(container),
      );
      notifier.updateInput(_sampleInput());
      final result = await notifier.calculate(saveHistory: false);

      expect(result, isNotNull);
      expect(notifier.state.error, isNull);
      final history = await repository.loadHistory(uid: 'signed-in-uid');
      expect(history, isEmpty);
      expect(truthFetches, 1);
    });
  });
}
