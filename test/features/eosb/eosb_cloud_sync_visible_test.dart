import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raabta/core/l10n/app_locale.dart';
import 'package:raabta/features/eosb/data/eosb_repository.dart';
import 'package:raabta/features/eosb/domain/models/eosb_employee_input.dart';
import 'package:raabta/features/eosb/domain/models/eosb_result.dart';
import 'package:raabta/features/eosb/domain/models/overtime_truth_models.dart';
import 'package:raabta/features/eosb/domain/services/eosb_calculation_service.dart';
import 'package:raabta/features/eosb/domain/services/overtime_truth_engine.dart';
import 'package:raabta/features/eosb/presentation/l10n/eosb_strings.dart';
import 'package:raabta/features/eosb/presentation/widgets/eosb_cloud_sync_notice.dart';
import 'package:raabta/features/eosb/providers/eosb_providers.dart';
import 'package:raabta/features/eosb/providers/overtime_truth_providers.dart';
import 'package:raabta/providers/auth_scoped_storage_providers.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _TestAuthUser extends Fake implements User {
  _TestAuthUser(this.uid);
  @override
  final String uid;
}

class _ThrowingFirestore extends Fake implements FirebaseFirestore {
  @override
  CollectionReference<Map<String, dynamic>> collection(String collectionPath) {
    return _ThrowingCollectionReference();
  }
}

class _ThrowingCollectionReference extends Fake
    implements CollectionReference<Map<String, dynamic>> {
  @override
  DocumentReference<Map<String, dynamic>> doc([String? path]) {
    return _ThrowingDocumentReference();
  }
}

class _ThrowingDocumentReference extends Fake
    implements DocumentReference<Map<String, dynamic>> {
  @override
  Future<void> set(Map<String, dynamic> data, [SetOptions? options]) {
    throw Exception('firestore write failed');
  }

  @override
  CollectionReference<Map<String, dynamic>> collection(String collectionPath) {
    return _ThrowingCollectionReference();
  }
}

class _SyncStubEosbRepository extends EosbRepository {
  _SyncStubEosbRepository(super.prefs, {required this.syncOutcome});

  final EosbCloudSyncOutcome syncOutcome;

  @override
  Future<EosbCloudSyncOutcome> syncOvertimeCalculation(
    OvertimeTruthResult result, {
    String? uid,
  }) async {
    return syncOutcome;
  }
}

EosbEmployeeInput _sampleInput() => EosbEmployeeInput(
  basicSalary: 8000,
  joiningDate: DateTime(2019, 6, 1),
  lastWorkingDate: DateTime(2025, 6, 1),
);

CalculationHistoryEntry _sampleEntry() {
  const calc = EosbCalculationService();
  final input = _sampleInput();
  final result = calc.calculate(input);
  return CalculationHistoryEntry(
    id: 'entry-sync-1',
    input: input,
    result: result,
    savedAt: DateTime(2025, 6, 2),
    label: '12,000',
  );
}

OvertimeTruthResult _minimalOvertimeResult() {
  final record = OvertimeMonthlyRecord.emptyForMonth(2026, 6).copyWith(
    profile: const OvertimeEmployeeProfile(
      companyName: 'Acme Corp',
      employeeName: 'Test',
    ),
  );
  return OvertimeTruthEngine.calculateRecord(record);
}

final _eosbTestRefProvider = Provider<Ref>((ref) => ref);

Ref _refFrom(ProviderContainer container) =>
    container.read(_eosbTestRefProvider);

void main() {
  group('EosbRepository cloud sync outcome', () {
    setUp(() async {
      SharedPreferences.setMockInitialValues({});
    });

    test('saveHistoryEntry reports skipped sync for guest', () async {
      final prefs = await SharedPreferences.getInstance();
      final repo = EosbRepository(prefs);
      const uid = 'guest-sync-uid';

      final outcome = await repo.saveHistoryEntry(_sampleEntry(), uid: uid);
      expect(outcome.saved, isTrue);
      expect(outcome.cloudSync, EosbCloudSyncOutcome.skipped);
    });

    test('syncOvertimeCalculation returns skipped without auth user', () async {
      final prefs = await SharedPreferences.getInstance();
      final repo = EosbRepository(prefs);

      final outcome = await repo.syncOvertimeCalculation(
        _minimalOvertimeResult(),
        uid: 'ot-sync-uid',
      );
      expect(outcome, EosbCloudSyncOutcome.skipped);
    });

    test(
      'saveHistoryEntry reports failed when Firestore write throws',
      () async {
        final prefs = await SharedPreferences.getInstance();
        const uid = 'signed-in-sync-uid';
        final repo = EosbRepository(
          prefs,
          firestore: _ThrowingFirestore(),
          currentAuthUser: () => _TestAuthUser(uid),
        );
        await repo.setSalaryConsent(false, uid: uid);

        final outcome = await repo.saveHistoryEntry(_sampleEntry(), uid: uid);
        expect(outcome.saved, isTrue);
        expect(outcome.cloudSync, EosbCloudSyncOutcome.failed);

        final history = await repo.loadHistory(uid: uid);
        expect(history, hasLength(1));
      },
    );

    test(
      'syncOvertimeCalculation reports failed when Firestore write throws',
      () async {
        final prefs = await SharedPreferences.getInstance();
        const uid = 'ot-fail-sync-uid';
        final repo = EosbRepository(
          prefs,
          firestore: _ThrowingFirestore(),
          currentAuthUser: () => _TestAuthUser(uid),
        );
        await repo.setSalaryConsent(false, uid: uid);

        final outcome = await repo.syncOvertimeCalculation(
          _minimalOvertimeResult(),
          uid: uid,
        );
        expect(outcome, EosbCloudSyncOutcome.failed);
      },
    );
  });

  group('EosbNotifier cloud sync notice', () {
    test(
      'sets notice without error when local save succeeds and sync fails',
      () async {
        SharedPreferences.setMockInitialValues({});
        final prefs = await SharedPreferences.getInstance();
        final repository = EosbRepository(
          prefs,
          firestore: _ThrowingFirestore(),
          currentAuthUser: () => _TestAuthUser('eosb-notice-uid'),
        );
        await repository.setSalaryConsent(false, uid: 'eosb-notice-uid');

        final container = ProviderContainer(
          overrides: [
            currentAuthUidProvider.overrideWith((ref) => 'eosb-notice-uid'),
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
        expect(notifier.state.error, isNull);
        expect(notifier.state.cloudSyncNoticePending, isTrue);
        expect(notifier.state.result, isNotNull);

        notifier.clearCloudSyncNotice();
        expect(notifier.state.cloudSyncNoticePending, isFalse);
      },
    );
  });

  group('OvertimeTruthNotifier cloud sync notice', () {
    test(
      'calculate sets notice when sync fails without blocking result',
      () async {
        SharedPreferences.setMockInitialValues({});
        final prefs = await SharedPreferences.getInstance();
        final repo = _SyncStubEosbRepository(
          prefs,
          syncOutcome: EosbCloudSyncOutcome.failed,
        );

        final container = ProviderContainer(
          overrides: [
            currentAuthUidProvider.overrideWith((ref) => 'ot-notice-uid'),
            eosbRepositoryProvider.overrideWith((ref) async => repo),
          ],
        );
        addTearDown(container.dispose);

        final eosb = EosbNotifier(
          const EosbCalculationService(),
          repo,
          _refFrom(container),
        );
        final ot = OvertimeTruthNotifier(eosb, _refFrom(container));
        ot.attachRepository(repo);
        ot.state = OvertimeTruthState(
          record: OvertimeMonthlyRecord.emptyForMonth(2026, 6),
          isHydrating: false,
        );

        final result = await ot.calculate();
        expect(result, isNotNull);
        expect(ot.state.error, isNull);
        expect(ot.state.cloudSyncNoticePending, isTrue);
      },
    );
  });

  group('cloud sync notice UI', () {
    testWidgets('showEosbCloudSyncFailedNoticeIfPending consumes notice', (
      tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            eosbProvider.overrideWith((ref) {
              final notifier = EosbNotifier(
                const EosbCalculationService(),
                null,
                ref,
              );
              notifier.state = notifier.state.copyWith(
                cloudSyncNoticePending: true,
              );
              return notifier;
            }),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: Consumer(
                builder: (context, ref, _) {
                  return ElevatedButton(
                    onPressed: () => showEosbCloudSyncFailedNoticeIfPending(
                      context,
                      ref,
                      'English',
                    ),
                    child: const Text('SHOW'),
                  );
                },
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('SHOW'));
      await tester.pump();

      expect(
        find.text(EosbStrings.t('eosb_cloud_sync_failed', 'English')),
        findsOneWidget,
      );
    });

    test('eosb_cloud_sync_failed covers nine locales', () {
      for (final locale in AppLocale.supportedLocales) {
        final text = EosbStrings.t('eosb_cloud_sync_failed', locale);
        expect(text, isNot('eosb_cloud_sync_failed'));
        expect(text, isNotEmpty);
      }
    });
  });
}
