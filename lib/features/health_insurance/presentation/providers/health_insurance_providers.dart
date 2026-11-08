import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:raabta/core/l10n/app_locale.dart';
import 'package:raabta/features/health_insurance/data/models/compliance_check_model.dart';
import 'package:raabta/features/health_insurance/data/models/insurer_lookup_models.dart';
import 'package:raabta/features/health_insurance/data/models/insurance_policy_model.dart';
import 'package:raabta/features/health_insurance/data/repository/health_insurance_repository.dart';
import 'package:raabta/features/health_insurance/domain/calculators/insurance_compliance_checker.dart';
import 'package:raabta/features/health_insurance/data/insurance_compliance_history_loader.dart';
import 'package:raabta/features/health_insurance/domain/models/insurance_compliance_history_entry.dart';
import 'package:raabta/features/health_insurance/domain/models/health_insurance_scenario.dart';
import 'package:raabta/features/health_insurance/domain/services/health_insurance_scenario_service.dart';
import 'package:raabta/features/health_insurance/domain/services/health_insurance_services.dart';
import 'package:raabta/features/health_insurance/domain/services/insurer_lookup_service.dart';
import 'package:raabta/providers/visa_providers.dart';
import 'package:raabta/services/ai/claude_ai_service.dart';
import 'package:raabta/features/health_insurance/domain/models/health_compliance_enums.dart';
import 'package:raabta/services/notifications/notification_copy_strings.dart';
import 'package:raabta/services/smart_notification_engine.dart';
import 'package:raabta/features/eosb/providers/eosb_providers.dart';
import 'package:raabta/features/home/providers/home_truth_chip_invalidation.dart';
import 'package:raabta/providers/auth_scoped_storage_providers.dart';

final healthInsuranceRepositoryProvider =
    FutureProvider<HealthInsuranceRepository>((ref) async {
  final prefs = await SharedPreferences.getInstance();
  return HealthInsuranceRepository(prefs);
});

final healthInsuranceLocaleProvider = FutureProvider<String>((ref) async {
  final repo = await ref.watch(healthInsuranceRepositoryProvider.future);
  final userLang = ref.watch(userLanguageProvider);
  final stored = repo.locale().isNotEmpty ? repo.locale() : userLang;
  return AppLocale.normalize(stored);
});

final healthInsuranceExplanationServiceProvider =
    Provider<HealthInsuranceExplanationService>(
  (ref) => const HealthInsuranceExplanationService(),
);

final healthInsurancePolicyExplainerProvider =
    Provider<HealthInsurancePolicyExplainerService>(
  (ref) => HealthInsurancePolicyExplainerService(
    ref.watch(claudeAIServiceProvider),
  ),
);

final mophInsurerSnapshotProvider =
    FutureProvider<MophInsurerLookupSnapshot>((ref) async {
  final repo = await ref.watch(healthInsuranceRepositoryProvider.future);
  return repo.fetchMophInsurerSnapshot();
});

final insurerLookupServiceProvider = FutureProvider<InsurerLookupService>((ref) async {
  final snapshot = await ref.watch(mophInsurerSnapshotProvider.future);
  return InsurerLookupService(snapshot: snapshot);
});

class HealthInsuranceState {
  const HealthInsuranceState({
    this.input = const InsuranceComplianceInput(),
    this.result,
    this.isChecking = false,
    this.policyExplainer,
    this.isExplaining = false,
    this.error,
  });

  final InsuranceComplianceInput input;
  final ComplianceCheckResult? result;
  final bool isChecking;
  final PolicyExplainerResult? policyExplainer;
  final bool isExplaining;
  final String? error;

  HealthInsuranceState copyWith({
    InsuranceComplianceInput? input,
    ComplianceCheckResult? result,
    bool? isChecking,
    PolicyExplainerResult? policyExplainer,
    bool? isExplaining,
    String? error,
    bool clearResult = false,
    bool clearExplainer = false,
    bool clearError = false,
  }) {
    return HealthInsuranceState(
      input: input ?? this.input,
      result: clearResult ? null : (result ?? this.result),
      isChecking: isChecking ?? this.isChecking,
      policyExplainer:
          clearExplainer ? null : (policyExplainer ?? this.policyExplainer),
      isExplaining: isExplaining ?? this.isExplaining,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class HealthInsuranceNotifier extends StateNotifier<HealthInsuranceState> {
  HealthInsuranceNotifier(this._repo, this._explainer, this._ref)
      : super(const HealthInsuranceState()) {
    _loadCache();
  }

  final HealthInsuranceRepository? _repo;
  final HealthInsurancePolicyExplainerService _explainer;
  final Ref _ref;

  Future<void> _loadCache() async {
    final cachedInput = _repo?.loadCachedInput();
    final cachedResult = _repo?.loadCachedResult();
    if (cachedInput != null || cachedResult != null) {
      state = state.copyWith(
        input: cachedInput ?? state.input,
        result: cachedResult,
      );
    }
  }

  void updateInput(InsuranceComplianceInput input) {
    state = state.copyWith(input: input);
    _repo?.saveInput(input);
  }

  Future<ComplianceCheckResult?> runComplianceCheck({
    required InsuranceComplianceChecker checker,
  }) async {
    state = state.copyWith(isChecking: true, clearError: true);
    try {
      final result = checker.check(state.input);
      await _repo?.saveResult(result);
      invalidateHomeTruthChips(_ref);

      final eosbInput = _ref.read(eosbProvider).input;
      final employerKey = eosbInput.effectiveNormalizedEmployerKey;
      if (employerKey.isNotEmpty) {
        await _repo?.syncComplianceCheckToFirestore(
          result: result,
          companyName: eosbInput.companyName,
          normalizedEmployerKey: employerKey,
        );
      }

      final year = state.input.currentRenewalYear ?? DateTime.now().year;
      if (state.input.insurerName.trim().isNotEmpty &&
          state.input.newPolicyStartDate != null) {
        final end = state.input.newPolicyStartDate!.add(const Duration(days: 364));
        await _repo?.upsertInsurerHistory(
          InsurerSwitchRecord(
            renewalYear: year,
            insurerName: state.input.insurerName.trim(),
            coverageStart: state.input.newPolicyStartDate!,
            coverageEnd: end,
          ),
        );
      }

      state = state.copyWith(result: result, isChecking: false);

      await _notifyComplianceIssues(result, await _resolveLocale());

      if (result.hasUnresolvedViolation) {
        await SmartNotificationEngine.instance
            .scheduleHealthInsuranceViolationRecheck();
      } else {
        await SmartNotificationEngine.instance.cancelHealthInsuranceReminders();
      }

      return result;
    } catch (e) {
      state = state.copyWith(isChecking: false, error: e.toString());
      return null;
    }
  }

  Future<void> explainPolicy(InsurancePolicyDocument document) async {
    state = state.copyWith(isExplaining: true, clearError: true);
    try {
      final locale = await _resolveLocale();
      final result = await _explainer.explainPolicy(
        document: document,
        locale: locale,
      );
      state = state.copyWith(policyExplainer: result, isExplaining: false);
    } catch (e) {
      state = state.copyWith(isExplaining: false, error: e.toString());
    }
  }

  Future<String> _resolveLocale() async {
    if (_repo?.locale().isNotEmpty == true) {
      return AppLocale.normalize(_repo!.locale());
    }
    return AppLocale.normalize(_ref.read(userLanguageProvider));
  }

  Future<void> scheduleOnboardingNudgeIfNeeded() async {
    if (_repo?.hasCompletedComplianceCheck() ?? false) return;
    await SmartNotificationEngine.instance
        .scheduleHealthInsuranceComplianceNudge();
  }

  Future<void> _notifyComplianceIssues(
    ComplianceCheckResult result,
    String locale,
  ) async {
    for (final item in result.items) {
      if (item.id == 'insurer_switch_gap' &&
          item.status == HealthComplianceStatus.violation) {
        await SmartNotificationEngine.instance.notifyHealthInsuranceComplianceIssue(
          issueId: item.id,
          title: NotificationCopyStrings.t('hi_insurer_switch_gap_title', locale),
          body: NotificationCopyStrings.t('hi_insurer_switch_gap_body', locale),
          route: '/health-insurance/compliance/results',
        );
      }
      if (item.id == 'qid_renewal_proof' &&
          item.status == HealthComplianceStatus.needsVerification) {
        await SmartNotificationEngine.instance.notifyHealthInsuranceComplianceIssue(
          issueId: item.id,
          title: NotificationCopyStrings.t('hi_qid_renewal_proof_title', locale),
          body: NotificationCopyStrings.t('hi_qid_renewal_proof_body', locale),
          route: '/health-insurance/compliance/results',
        );
      }
    }
  }
}

final healthInsuranceProvider =
    StateNotifierProvider<HealthInsuranceNotifier, HealthInsuranceState>((ref) {
  ref.watch(currentAuthUidProvider);
  final repo = ref.watch(healthInsuranceRepositoryProvider).valueOrNull;
  return HealthInsuranceNotifier(
    repo,
    ref.watch(healthInsurancePolicyExplainerProvider),
    ref,
  );
});

final insuranceComplianceCheckerProvider =
    FutureProvider<InsuranceComplianceChecker>((ref) async {
  final snapshot = await ref.watch(mophInsurerSnapshotProvider.future);
  final lookup = InsurerLookupService(snapshot: snapshot);
  return InsuranceComplianceChecker(
    mophInsurers: snapshot.insurers,
    insurerLookup: lookup,
    mophListLastVerified: snapshot.lastVerified,
  );
});

final healthInsuranceScenarioServiceProvider =
    FutureProvider<HealthInsuranceScenarioService>((ref) async {
  final checker = await ref.watch(insuranceComplianceCheckerProvider.future);
  return HealthInsuranceScenarioService(
    baseChecker: checker,
    insurerLookup: checker.insurerLookup,
  );
});

final healthInsuranceScenariosProvider =
    FutureProvider<List<HealthInsuranceScenario>>((ref) async {
  final service =
      await ref.watch(healthInsuranceScenarioServiceProvider.future);
  final input = ref.watch(healthInsuranceProvider).input;
  return service.simulate(input);
});

final insuranceComplianceHistoryProvider =
    FutureProvider<List<InsuranceComplianceHistoryEntry>>((ref) async {
  return InsuranceComplianceHistoryLoader.load();
});
