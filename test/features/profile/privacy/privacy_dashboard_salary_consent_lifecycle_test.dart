import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raabta/features/eosb/data/eosb_repository.dart';
import 'package:raabta/features/eosb/domain/models/eosb_contract_analysis.dart';
import 'package:raabta/features/eosb/domain/models/eosb_employee_input.dart';
import 'package:raabta/features/eosb/domain/models/overtime_truth_models.dart';
import 'package:raabta/features/eosb/domain/services/eosb_salary_claude_consent.dart';
import 'package:raabta/features/eosb/providers/eosb_providers.dart';
import 'package:raabta/features/eosb/providers/eosb_salary_consent_revocation.dart';
import 'package:raabta/features/eosb/providers/overtime_rounding_providers.dart';
import 'package:raabta/features/eosb/providers/overtime_truth_providers.dart';
import 'package:raabta/providers/auth_scoped_storage_providers.dart';
import 'package:raabta/services/ai/claude_ai_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _RevocationSpy {
  int eosbNotifier = 0;
  int overtimeNotifier = 0;
}

class _SpyEosbNotifier extends EosbNotifier {
  _SpyEosbNotifier(super.calc, super.repo, super.ref, this.spy);

  final _RevocationSpy spy;

  @override
  void applySalaryConsentRevocation() {
    spy.eosbNotifier++;
    super.applySalaryConsentRevocation();
  }
}

class _SpyOvertimeTruthNotifier extends OvertimeTruthNotifier {
  _SpyOvertimeTruthNotifier(super.eosb, super.ref, this.spy);

  final _RevocationSpy spy;

  @override
  void applySalaryConsentRevocation() {
    spy.overtimeNotifier++;
    super.applySalaryConsentRevocation();
  }
}

class _TestScopedEosbRepository extends EosbRepository {
  _TestScopedEosbRepository(super.prefs);

  @override
  Future<void> setSalaryConsent(bool value, {String? uid}) async {
    return super.setSalaryConsent(value, uid: uid ?? 'uid');
  }
}

class _GatedSalaryConsentEosbRepository extends _TestScopedEosbRepository {
  _GatedSalaryConsentEosbRepository(
    super.prefs, {
    required this.onPersistStarted,
    required this.persistGate,
    this.onPersistCompleted,
  });

  final void Function() onPersistStarted;
  final Completer<void> persistGate;
  final void Function()? onPersistCompleted;

  @override
  Future<void> setSalaryConsent(bool value, {String? uid}) async {
    onPersistStarted();
    await persistGate.future;
    await super.setSalaryConsent(value, uid: uid);
    onPersistCompleted?.call();
  }
}

class _DelayedSalaryConsentEosbRepository extends _TestScopedEosbRepository {
  _DelayedSalaryConsentEosbRepository(
    super.prefs, {
    required this.onPersistStarted,
  });

  final void Function() onPersistStarted;

  @override
  Future<void> setSalaryConsent(bool value, {String? uid}) async {
    onPersistStarted();
    await Future<void>.delayed(const Duration(milliseconds: 5));
    await super.setSalaryConsent(value, uid: uid);
  }
}

class _ThrowingSalaryConsentEosbRepository extends _TestScopedEosbRepository {
  _ThrowingSalaryConsentEosbRepository(super.prefs, this.exception);

  final Object exception;

  @override
  Future<void> setSalaryConsent(bool value, {String? uid}) async {
    throw exception;
  }
}

const _seedEosbSalary = 9000.0;
const _seedOtSalary = 4000.0;
const _seedContractSalary = 5000.0;
const _seedRoundingExplanation = 'Claude said QAR 100';

String _eosbClaudeCacheKey(ClaudeAIService claude) {
  return claude.generateCacheKeyForTest(
    EosbSalarySensitiveClaudeRequestTypes.eosbContractAnalysis,
    'p',
    'English',
  );
}

void _seedSalaryState(ProviderContainer container) {
  container
      .read(eosbProvider.notifier)
      .updateInput(const EosbEmployeeInput(basicSalary: _seedEosbSalary));
  container
      .read(overtimeTruthProvider.notifier)
      .updateRecord(
        OvertimeMonthlyRecord(
          id: '1',
          year: 2025,
          month: 1,
          profile: const OvertimeEmployeeProfile(
            companyName: 'Co',
            basicSalary: _seedOtSalary,
          ),
        ),
      );
  container.read(eosbContractAnalysisProvider.notifier).state =
      const EosbContractAnalysis(basicSalary: _seedContractSalary);
  container.read(overtimeRoundingAiExplanationProvider.notifier).state =
      _seedRoundingExplanation;

  final claude = container.read(claudeAIServiceProvider);
  claude.seedResponseCacheForTest(
    _eosbClaudeCacheKey(claude),
    'r',
    requestType: EosbSalarySensitiveClaudeRequestTypes.eosbContractAnalysis,
  );
}

void _expectSalaryStateIntact(ProviderContainer container) {
  expect(container.read(eosbProvider).input.basicSalary, _seedEosbSalary);
  expect(
    container.read(overtimeTruthProvider).record.profile.basicSalary,
    _seedOtSalary,
  );
  expect(
    container.read(eosbContractAnalysisProvider)?.basicSalary,
    _seedContractSalary,
  );
  expect(
    container.read(overtimeRoundingAiExplanationProvider),
    _seedRoundingExplanation,
  );
  final claude = container.read(claudeAIServiceProvider);
  expect(claude.isResponseCachedForTest(_eosbClaudeCacheKey(claude)), isTrue);
}

void _expectSalaryStateRevoked(ProviderContainer container) {
  expect(container.read(eosbProvider).input.basicSalary, 0);
  expect(container.read(overtimeTruthProvider).record.profile.basicSalary, 0);
  expect(
    container.read(overtimeTruthProvider).record.profile.companyName,
    isEmpty,
  );
  expect(container.read(eosbContractAnalysisProvider), isNull);
  expect(container.read(overtimeRoundingAiExplanationProvider), isNull);
  final claude = container.read(claudeAIServiceProvider);
  expect(claude.isResponseCachedForTest(_eosbClaudeCacheKey(claude)), isFalse);
}

ProviderContainer _buildContainer({
  required EosbRepository repo,
  required _RevocationSpy spy,
  int Function()? onConsentProviderEvaluated,
}) {
  return ProviderContainer(
    overrides: [
      eosbRepositoryProvider.overrideWith((ref) async => repo),
      currentAuthUidProvider.overrideWith((ref) => 'uid'),
      if (onConsentProviderEvaluated != null)
        eosbSalaryConsentProvider.overrideWith((ref) async {
          onConsentProviderEvaluated();
          final uid = ref.watch(currentAuthUidProvider);
          final repository = await ref.watch(eosbRepositoryProvider.future);
          return repository.salaryConsent(uid: uid);
        }),
      eosbProvider.overrideWith((ref) {
        final calc = ref.watch(eosbCalculationServiceProvider);
        return _SpyEosbNotifier(calc, null, ref, spy);
      }),
      overtimeTruthProvider.overrideWith((ref) {
        final eosb = ref.watch(eosbProvider.notifier);
        return _SpyOvertimeTruthNotifier(eosb, ref, spy);
      }),
    ],
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('persistEosbSalaryConsentChange', () {
    test('consent OFF persists before invalidation and revocation', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final spy = _RevocationSpy();
      final persistGate = Completer<void>();
      var sawMidPersistSnapshot = false;
      var persistCompleted = false;
      late final ProviderContainer container;
      final repo = _GatedSalaryConsentEosbRepository(
        prefs,
        persistGate: persistGate,
        onPersistStarted: () {
          expect(persistCompleted, isFalse);
          expect(spy.eosbNotifier, 0);
          expect(spy.overtimeNotifier, 0);
          sawMidPersistSnapshot = true;
          _expectSalaryStateIntact(container);
          persistGate.complete();
        },
        onPersistCompleted: () => persistCompleted = true,
      );
      await _TestScopedEosbRepository(prefs).setSalaryConsent(true, uid: 'uid');

      container = _buildContainer(repo: repo, spy: spy);
      addTearDown(container.dispose);
      await container.read(eosbRepositoryProvider.future);
      _seedSalaryState(container);

      await persistEosbSalaryConsentChange(container, false);

      expect(sawMidPersistSnapshot, isTrue);
      expect(persistCompleted, isTrue);
      expect(spy.eosbNotifier, 1);
      expect(spy.overtimeNotifier, 1);
      _expectSalaryStateRevoked(container);
    });

    test('consent ON invalidates provider without salary revocation', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final spy = _RevocationSpy();
      var consentEvaluations = 0;
      final repo = _TestScopedEosbRepository(prefs);
      await repo.setSalaryConsent(false, uid: 'uid');

      final container = _buildContainer(
        repo: repo,
        spy: spy,
        onConsentProviderEvaluated: () => consentEvaluations++,
      );
      addTearDown(container.dispose);
      await container.read(eosbRepositoryProvider.future);
      _seedSalaryState(container);

      await container.read(eosbSalaryConsentProvider.future);
      final evaluationsAfterWarm = consentEvaluations;

      await persistEosbSalaryConsentChange(container, true);

      expect(await container.read(eosbSalaryConsentProvider.future), isTrue);
      expect(consentEvaluations, greaterThan(evaluationsAfterWarm));
      expect(spy.eosbNotifier, 0);
      expect(spy.overtimeNotifier, 0);
      _expectSalaryStateIntact(container);
    });

    test(
      'persistence failure propagates without invalidate or revocation',
      () async {
        SharedPreferences.setMockInitialValues({});
        final prefs = await SharedPreferences.getInstance();
        final spy = _RevocationSpy();
        var consentEvaluations = 0;
        final repo = _ThrowingSalaryConsentEosbRepository(
          prefs,
          StateError('persist failed'),
        );
        await _TestScopedEosbRepository(
          prefs,
        ).setSalaryConsent(true, uid: 'uid');

        final container = _buildContainer(
          repo: repo,
          spy: spy,
          onConsentProviderEvaluated: () => consentEvaluations++,
        );
        addTearDown(container.dispose);
        await container.read(eosbRepositoryProvider.future);
        _seedSalaryState(container);

        await container.read(eosbSalaryConsentProvider.future);
        final evaluationsAfterWarm = consentEvaluations;

        await expectLater(
          persistEosbSalaryConsentChange(container, false),
          throwsA(isA<StateError>()),
        );

        expect(consentEvaluations, evaluationsAfterWarm);
        await container.read(eosbSalaryConsentProvider.future);
        expect(consentEvaluations, evaluationsAfterWarm);

        expect(spy.eosbNotifier, 0);
        expect(spy.overtimeNotifier, 0);
        _expectSalaryStateIntact(container);
      },
    );
  });

  test(
    'consent revocation completes after Privacy screen disposes mid-save',
    () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final persistStarted = Completer<void>();
      final repo = _DelayedSalaryConsentEosbRepository(
        prefs,
        onPersistStarted: () {
          if (!persistStarted.isCompleted) {
            persistStarted.complete();
          }
        },
      );
      await repo.setSalaryConsent(true, uid: 'uid');

      final container = _buildContainer(repo: repo, spy: _RevocationSpy());
      addTearDown(container.dispose);
      await container.read(eosbRepositoryProvider.future);
      _seedSalaryState(container);

      final consentFuture = persistEosbSalaryConsentChange(container, false);
      await persistStarted.future;
      await consentFuture;

      _expectSalaryStateRevoked(container);
    },
  );
}
