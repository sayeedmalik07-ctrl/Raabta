import 'package:flutter_test/flutter_test.dart';
import 'package:raabta/core/persistence/local_data_isolation_keys.dart';
import 'package:raabta/core/persistence/uid_scoped_preferences.dart';
import 'package:raabta/features/eosb/data/eosb_repository.dart';
import 'package:raabta/features/eosb/domain/models/eosb_employee_input.dart';
import 'package:raabta/features/eosb/domain/models/eosb_result.dart';
import 'package:raabta/features/eosb/domain/models/overtime_truth_models.dart';
import 'package:raabta/features/eosb/domain/services/eosb_salary_storage_policy.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:raabta/features/quick_actions/bill_tracker/data/bill_tracker_repository.dart';
import 'package:raabta/services/ai/expat_score_live_calculator.dart';
import 'package:raabta/services/ai/expat_score_live_inputs_loader.dart';
import 'package:raabta/services/ai/expat_score_signal_enricher.dart';
import 'package:raabta/services/ai/user_profile_ai_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

UserAIProfile _profile(String uid) => UserAIProfile.defaultProfile(uid);

CalculationHistoryEntry _legacySalaryEntry() {
  return CalculationHistoryEntry(
    id: 'legacy-1',
    input: const EosbEmployeeInput(basicSalary: 8000, companyName: 'Co'),
    result: EosbResult(
      totalEntitlement: 12_000,
      breakdown: const [],
      warnings: const [],
      violations: const [],
      explanation: const CalculationExplanation(
        summaryKey: 'k',
        confidenceScore: 0.9,
        stepsKeys: [],
      ),
      calculatedAt: DateTime(2025, 6, 1),
    ),
    savedAt: DateTime(2025, 6, 2),
    salaryDetailsStored: true,
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('EosbSalaryStoragePolicy intelligence pick', () {
    test('returns null when consent off despite legacy salary row', () {
      final picked = EosbSalaryStoragePolicy.pickSalaryAwareHistoryEntry([
        _legacySalaryEntry(),
      ], salaryStorageConsent: false);
      expect(picked, isNull);
    });

    test('returns salary-bearing row when consent on', () {
      final picked = EosbSalaryStoragePolicy.pickSalaryAwareHistoryEntry([
        _legacySalaryEntry(),
      ], salaryStorageConsent: true);
      expect(picked?.id, 'legacy-1');
      expect(picked?.input.basicSalary, 8000);
    });
  });

  group('ExpatScoreSignalEnricher', () {
    test('skips EOSB tags when consent off', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      const uid = 'expat-off';
      final repo = EosbRepository(prefs);

      UidScopedPreferences.setString(
        prefs,
        EosbRepository.calculationHistoryKey,
        '[{"id":"1"}]',
        uid: uid,
      );

      final fakeDb = FakeFirebaseFirestore();
      final tags = await ExpatScoreSignalEnricher.enrichInterests(
        profile: _profile(uid),
        storageUid: uid,
        prefs: prefs,
        firestore: fakeDb,
        eosbRepository: repo,
      );

      expect(tags.contains('profile:eosb_calculation'), isFalse);
    });

    test('adds EOSB tag when consent on and history exists', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      const uid = 'expat-on';
      final repo = EosbRepository(prefs);
      await repo.setSalaryConsent(true, uid: uid);

      UidScopedPreferences.setString(
        prefs,
        EosbRepository.calculationHistoryKey,
        '[{"id":"1","input":{},"result":{},"savedAt":"2025-01-01T00:00:00.000Z"}]',
        uid: uid,
      );

      final fakeDb = FakeFirebaseFirestore();
      final tags = await ExpatScoreSignalEnricher.enrichInterests(
        profile: _profile(uid),
        storageUid: uid,
        prefs: prefs,
        firestore: fakeDb,
        eosbRepository: repo,
      );

      expect(tags.contains('profile:eosb_calculation'), isTrue);
    });

    test('strips stale salary tags when consent off', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      const uid = 'expat-stale';
      final repo = EosbRepository(prefs);

      final staleProfile = _profile(uid).copyWith(
        interests: const [
          'profile:eosb_calculation',
          'profile:overtime_calculation',
          'profile:money_transfer',
        ],
      );

      final tags = await ExpatScoreSignalEnricher.enrichInterests(
        profile: staleProfile,
        storageUid: uid,
        prefs: prefs,
        firestore: FakeFirebaseFirestore(),
        eosbRepository: repo,
      );

      expect(
        tags.contains(ExpatScoreSignalEnricher.eosbCalculationTag),
        isFalse,
      );
      expect(
        tags.contains(ExpatScoreSignalEnricher.overtimeCalculationTag),
        isFalse,
      );
      expect(tags.contains('profile:money_transfer'), isTrue);
    });
  });

  group('Stale tags and financial scoring', () {
    test(
      'stale EOSB interest tags do not boost financial points when consent off',
      () async {
        SharedPreferences.setMockInitialValues({});
        final prefs = await SharedPreferences.getInstance();
        const uid = 'financial-stale';
        final repo = EosbRepository(prefs);

        final staleProfile = _profile(uid).copyWith(
          interests: const [
            'profile:eosb_calculation',
            'profile:overtime_calculation',
          ],
        );
        final enriched = await ExpatScoreSignalEnricher.enrichInterests(
          profile: staleProfile,
          storageUid: uid,
          prefs: prefs,
          firestore: FakeFirebaseFirestore(),
          eosbRepository: repo,
        );
        final scoringProfile = staleProfile.copyWith(interests: enriched);

        const calculator = ExpatScoreLiveCalculator();
        final withStaleStripped = calculator.compute(
          ExpatScoreLiveInputs(profile: scoringProfile),
        );
        final baseline = calculator.compute(
          ExpatScoreLiveInputs(profile: _profile(uid)),
        );

        final financialStripped = withStaleStripped.categoryMeta['financial']!;
        final financialBaseline = baseline.categoryMeta['financial']!;

        expect(
          financialStripped.evidenceLines.any((line) => line.contains('EOSB')),
          isFalse,
        );
        expect(
          financialStripped.evidenceLines.any(
            (line) => line.contains('Overtime'),
          ),
          isFalse,
        );
        expect(financialStripped.rawPoints, financialBaseline.rawPoints);
      },
    );
  });

  group('ExpatScoreLiveInputsLoader', () {
    test('omits salary fields when consent off', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      const uid = 'loader-off';
      final repo = EosbRepository(prefs);
      await repo.setSalaryConsent(false, uid: uid);
      await repo.saveHistoryEntry(_legacySalaryEntry(), uid: uid);

      final otInput = OvertimeTruthInput(
        companyName: 'Employer',
        basicSalary: 3000,
      );
      await repo.cacheOvertimeInput(otInput, uid: uid);

      final fakeDb = FakeFirebaseFirestore();
      final bills = BillTrackerRepository(firestore: fakeDb);
      final inputs = await ExpatScoreLiveInputsLoader.load(
        profile: _profile(uid),
        storageUid: uid,
        eosbRepository: repo,
        prefs: prefs,
        firestore: fakeDb,
        deadlineRepo: null,
        billRepository: bills,
      );

      expect(inputs.eosbInput, isNull);
      expect(inputs.eosbBreakdown, isNull);
      expect(inputs.overtimeBasicSalary, 0);
      expect(inputs.overtimeCompanyName, isEmpty);
    });

    test('loads salary fields when consent on', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      const uid = 'loader-on';
      final repo = EosbRepository(prefs);
      await repo.setSalaryConsent(true, uid: uid);
      await repo.saveHistoryEntry(_legacySalaryEntry(), uid: uid);

      final otInput = OvertimeTruthInput(
        companyName: 'Employer',
        basicSalary: 3000,
      );
      await repo.cacheOvertimeInput(otInput, uid: uid);

      final fakeDb = FakeFirebaseFirestore();
      final bills = BillTrackerRepository(firestore: fakeDb);
      final inputs = await ExpatScoreLiveInputsLoader.load(
        profile: _profile(uid),
        storageUid: uid,
        eosbRepository: repo,
        prefs: prefs,
        firestore: fakeDb,
        deadlineRepo: null,
        billRepository: bills,
      );

      expect(inputs.eosbInput?.basicSalary, 8000);
      expect(inputs.overtimeBasicSalary, 3000);
      expect(inputs.overtimeCompanyName, 'Employer');
    });
  });
}
