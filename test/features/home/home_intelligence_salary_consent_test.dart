import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raabta/features/eosb/data/eosb_repository.dart';
import 'package:raabta/features/eosb/domain/models/eosb_employee_input.dart';
import 'package:raabta/features/eosb/domain/models/eosb_result.dart';
import 'package:raabta/features/eosb/domain/models/overtime_truth_models.dart';
import 'package:raabta/features/eosb/domain/services/eosb_salary_storage_policy.dart';
import 'package:raabta/features/eosb/providers/eosb_providers.dart';
import 'package:raabta/features/eosb/providers/overtime_truth_providers.dart';
import 'package:raabta/features/cost_of_living/presentation/providers/cost_of_living_providers.dart';
import 'package:raabta/features/home/providers/home_intelligence_providers.dart';
import 'package:raabta/features/intelligence/presentation/providers/evidence_trail_providers.dart';
import 'package:raabta/providers/auth_scoped_storage_providers.dart';
import 'package:raabta/providers/auth_providers.dart';
import 'package:raabta/models/intelligence/evidence_entry.dart';
import 'package:raabta/models/intelligence/intelligence_insight.dart';
import 'package:raabta/models/intelligence/risk.dart';
import 'package:raabta/services/intelligence/consistency_checker.dart';
import 'package:raabta/services/intelligence/home_intelligence_focus_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _RecordingFocusService extends HomeIntelligenceFocusService {
  EosbEmployeeInput? capturedEosbInput;
  List<EntitlementBreakdownItem>? capturedBreakdown;
  EosbSalarySnapshot? capturedSalary;
  EosbEmployerSnapshot? capturedEmployer;
  OvertimeEmployerSnapshot? capturedOvertimeEmployer;

  @override
  List<HomeIntelligenceFocusItem> resolveTopItems({
    required String userId,
    List<DocumentVaultRecord> documents = const [],
    List<BillDueRecord> bills = const [],
    EosbEmployeeInput? eosbInput,
    List<EntitlementBreakdownItem>? eosbBreakdown,
    String? eosbCalculationId,
    List<EvidenceDeadlineRecord> evidenceEntries = const [],
    EosbSalarySnapshot? eosbSalary,
    CvStatedSalarySnapshot? cvSalary,
    EosbTimestampSnapshot? eosbTimestamp,
    ExpatScoreTimestampSnapshot? expatScoreTimestamp,
    EosbEmployerSnapshot? eosbEmployer,
    OvertimeEmployerSnapshot? overtimeEmployer,
    List<IntelligenceInsight>? recentInsightHistory,
    DateTime? now,
  }) {
    capturedEosbInput = eosbInput;
    capturedBreakdown = eosbBreakdown;
    capturedSalary = eosbSalary;
    capturedEmployer = eosbEmployer;
    capturedOvertimeEmployer = overtimeEmployer;
    return super.resolveTopItems(
      userId: userId,
      documents: documents,
      bills: bills,
      eosbInput: eosbInput,
      eosbBreakdown: eosbBreakdown,
      eosbCalculationId: eosbCalculationId,
      evidenceEntries: evidenceEntries,
      eosbSalary: eosbSalary,
      cvSalary: cvSalary,
      eosbTimestamp: eosbTimestamp,
      expatScoreTimestamp: expatScoreTimestamp,
      eosbEmployer: eosbEmployer,
      overtimeEmployer: overtimeEmployer,
      recentInsightHistory: recentInsightHistory,
      now: now,
    );
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'homeIntelligenceFocusProvider omits salary EOSB when consent off',
    () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final repo = EosbRepository(prefs);
      const uid = 'home-intel';
      await repo.setSalaryConsent(false, uid: uid);

      final historyEntry = CalculationHistoryEntry(
        id: 'h1',
        input: const EosbEmployeeInput(basicSalary: 5000, companyName: 'X'),
        result: EosbResult(
          totalEntitlement: 9000,
          breakdown: const [],
          warnings: const [],
          violations: const [],
          explanation: const CalculationExplanation(
            summaryKey: 'k',
            confidenceScore: 1,
            stepsKeys: [],
          ),
          calculatedAt: DateTime(2025, 1, 1),
        ),
        savedAt: DateTime(2025, 1, 2),
        salaryDetailsStored: true,
      );

      final recorder = _RecordingFocusService();

      final container = ProviderContainer(
        overrides: [
          currentAuthUidProvider.overrideWith((ref) => uid),
          eosbRepositoryProvider.overrideWith((ref) async => repo),
          eosbHistoryProvider.overrideWith((ref) async => [historyEntry]),
          homeIntelligenceFocusServiceProvider.overrideWith((ref) => recorder),
          userScannedDocumentsProvider.overrideWith((ref) => Stream.value([])),
          userBillsProvider.overrideWith((ref) => Stream.value([])),
          evidenceEntriesProvider.overrideWith((ref) => Stream.value([])),
          currentUserProvider.overrideWith((ref) => _FakeUser(uid: uid)),
          overtimeTruthProvider.overrideWith((ref) {
            final eosb = ref.watch(eosbProvider.notifier);
            return OvertimeTruthNotifier(eosb, ref);
          }),
        ],
      );
      addTearDown(container.dispose);

      final ot = container.read(overtimeTruthProvider.notifier);
      ot.updateInput(
        const OvertimeTruthInput(companyName: 'OT Co', basicSalary: 2000),
      );

      await container.read(eosbRepositoryProvider.future);

      final picked = EosbSalaryStoragePolicy.pickSalaryAwareHistoryEntry([
        historyEntry,
      ], salaryStorageConsent: repo.salaryConsent(uid: uid));
      expect(picked, isNull);

      final async = container.read(homeIntelligenceFocusProvider);
      final items = async.valueOrNull ?? const [];

      expect(recorder.capturedEosbInput, isNull);
      expect(recorder.capturedBreakdown, isNull);
      expect(recorder.capturedSalary, isNull);
      expect(recorder.capturedEmployer, isNull);
      expect(recorder.capturedOvertimeEmployer, isNull);

      final salaryDerived = items.where(
        (item) =>
            item.insightType == Risk.typeEosbViolation ||
            item.evidenceReference.contains('eosb') ||
            item.evidenceReference.contains(ConsistencyChecker.checkIdSalary) ||
            item.evidenceReference.contains(ConsistencyChecker.checkIdEmployer),
      );
      expect(salaryDerived, isEmpty);
    },
  );
}

class _FakeUser implements User {
  _FakeUser({required this.uid});

  @override
  final String uid;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
