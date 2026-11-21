import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:raabta/features/eosb/data/eosb_repository.dart';
import 'package:raabta/features/eosb/domain/models/eosb_contract_analysis.dart';
import 'package:raabta/features/eosb/domain/models/eosb_employee_input.dart';
import 'package:raabta/features/eosb/domain/models/eosb_history_load_outcome.dart';
import 'package:raabta/features/eosb/domain/models/eosb_result.dart';
import 'package:raabta/features/eosb/domain/models/eosb_scenario.dart';
import 'package:raabta/features/eosb/domain/services/eosb_calculation_service.dart';
import 'package:raabta/features/eosb/domain/services/eosb_salary_claude_consent.dart';
import 'package:raabta/features/eosb/domain/services/eosb_salary_storage_policy.dart';
import 'package:raabta/features/eosb/domain/services/eosb_scenario_service.dart';
import 'package:raabta/features/eosb/presentation/l10n/eosb_strings.dart';
import 'package:raabta/features/eosb/services/reengagement_session.dart';
import 'package:raabta/features/onboarding/services/onboarding_analytics_service.dart';
import 'package:raabta/features/eosb/services/eosb_contract_analysis_service.dart';
import 'package:raabta/features/eosb/services/eosb_legal_review_template_service.dart';
import 'package:raabta/features/eosb/services/eosb_document_import_service.dart';
import 'package:raabta/services/ai/claude_ai_service.dart';
import 'package:raabta/core/l10n/app_locale.dart';
import 'package:raabta/features/home/providers/home_truth_chip_invalidation.dart';
import 'package:raabta/providers/auth_scoped_storage_providers.dart';
import 'package:raabta/providers/visa_providers.dart';

/// When UID-scoped history could not be written ([saveHistory] path).
const eosbHistoryPersistenceFailedErrorCode = 'eosb_history_save_failed';

/// Local history JSON is corrupt; writes must not overwrite salvaged data.
const eosbHistoryCorruptWriteBlockedErrorCode =
    'eosb_history_corrupt_write_blocked';

/// Delete blocked while local history JSON remains corrupt.
const eosbHistoryCorruptDeleteBlockedErrorCode =
    'eosb_history_corrupt_delete_blocked';

/// Non-blocking notice after local save when Firestore sync failed.
const eosbCloudSyncFailedNoticeKey = 'eosb_cloud_sync_failed';

/// Stable provider error code — map to [EosbStrings] in UI; never raw exceptions.
const eosbCalculationFailedErrorCode = 'eosb_calculation_failed';

/// Maps [EosbState.error] codes to localized UI text.
String eosbStateErrorMessage(String? errorCode, String locale) {
  if (errorCode == null || errorCode.isEmpty) return '';
  return EosbStrings.t(errorCode, locale);
}

@visibleForTesting
Future<EosbHistorySaveOutcome> persistEosbCalculationHistory({
  required dynamic ref,
  required EosbRepository repository,
  required CalculationHistoryEntry entry,
  String? uid,
}) async {
  final outcome = await repository.saveHistoryEntry(entry, uid: uid);
  if (outcome.saved) {
    invalidateHomeTruthChips(ref);
  }
  return outcome;
}

final eosbRepositoryProvider = FutureProvider<EosbRepository>((ref) async {
  final prefs = await SharedPreferences.getInstance();
  return EosbRepository(prefs);
});

final eosbCalculationServiceProvider = Provider<EosbCalculationService>(
  (ref) => const EosbCalculationService(),
);

final eosbLocaleProvider = FutureProvider<String>((ref) async {
  ref.watch(currentAuthUidProvider);
  return AppLocale.normalize(ref.watch(userLanguageProvider));
});

/// Locale for EOSB loading/error gates — prefer resolved [eosbLocaleProvider],
/// else last-known [userLanguageProvider].
final eosbPresentationLocaleProvider = Provider<String>((ref) {
  final eosbAsync = ref.watch(eosbLocaleProvider);
  return eosbAsync.when(
    data: (locale) => locale,
    loading: () => AppLocale.normalize(ref.watch(userLanguageProvider)),
    error: (_, __) => AppLocale.normalize(ref.watch(userLanguageProvider)),
  );
});

final eosbSalaryConsentProvider = FutureProvider<bool>((ref) async {
  final uid = ref.watch(currentAuthUidProvider);
  final repo = await ref.watch(eosbRepositoryProvider.future);
  return repo.salaryConsent(uid: uid);
});

/// Persists [EosbRepository.salaryConsent] — authoritative for salary-bearing Claude calls.
final eosbSalaryClaudeConsentGuardProvider =
    Provider<EosbSalaryClaudeConsentGuard>((ref) {
      ref.watch(currentAuthUidProvider);
      ref.watch(eosbSalaryConsentProvider);
      return EosbSalaryClaudeConsentGuard(() {
        final repo = ref.read(eosbRepositoryProvider).valueOrNull;
        if (repo == null) return false;
        final uid = ref.read(currentAuthUidProvider);
        return repo.salaryConsent(uid: uid);
      });
    });

class EosbState {
  const EosbState({
    this.input = const EosbEmployeeInput(),
    this.result,
    this.isCalculating = false,
    this.error,
    this.lastHistoryNoticeKey,
    this.cloudSyncNoticePending = false,
  });

  final EosbEmployeeInput input;
  final EosbResult? result;
  final bool isCalculating;
  final String? error;
  final String? lastHistoryNoticeKey;
  final bool cloudSyncNoticePending;

  EosbState copyWith({
    EosbEmployeeInput? input,
    EosbResult? result,
    bool? isCalculating,
    String? error,
    String? lastHistoryNoticeKey,
    bool? cloudSyncNoticePending,
    bool clearResult = false,
    bool clearError = false,
    bool clearHistoryNotice = false,
    bool clearCloudSyncNotice = false,
  }) {
    return EosbState(
      input: input ?? this.input,
      result: clearResult ? null : (result ?? this.result),
      isCalculating: isCalculating ?? this.isCalculating,
      error: clearError ? null : (error ?? this.error),
      lastHistoryNoticeKey: clearHistoryNotice
          ? null
          : (lastHistoryNoticeKey ?? this.lastHistoryNoticeKey),
      cloudSyncNoticePending: clearCloudSyncNotice
          ? false
          : (cloudSyncNoticePending ?? this.cloudSyncNoticePending),
    );
  }
}

class EosbNotifier extends StateNotifier<EosbState> {
  EosbNotifier(this._calc, this._repo, this._ref) : super(const EosbState()) {
    _loadCache();
  }

  final EosbCalculationService _calc;
  final EosbRepository? _repo;
  final Ref _ref;

  Future<void> _loadCache() async {
    final cached = _repo?.loadCachedInput();
    if (cached != null) {
      state = state.copyWith(input: cached);
    }
  }

  void updateInput(EosbEmployeeInput input) {
    state = state.copyWith(input: input, clearError: true);
  }

  /// Restores a saved history calculation without recalculating.
  void restoreFromHistory({
    required EosbEmployeeInput input,
    required EosbResult result,
  }) {
    state = state.copyWith(input: input, result: result, clearError: true);
    _repo?.cacheInput(input);
  }

  void clearHistoryNotice() {
    if (state.lastHistoryNoticeKey == null) return;
    state = state.copyWith(clearHistoryNotice: true);
  }

  void clearCloudSyncNotice() {
    if (!state.cloudSyncNoticePending) return;
    state = state.copyWith(clearCloudSyncNotice: true);
  }

  void clearError() {
    if (state.error == null) return;
    state = state.copyWith(clearError: true);
  }

  /// Strips salary-bearing fields from in-memory EOSB state after consent off.
  void applySalaryConsentRevocation() {
    final redactedInput = EosbSalaryStoragePolicy.redactInput(state.input);
    final redactedResult = state.result != null
        ? EosbSalaryStoragePolicy.redactResult(state.result!)
        : null;
    state = state.copyWith(
      input: redactedInput,
      result: redactedResult,
      clearError: true,
      clearHistoryNotice: true,
      clearCloudSyncNotice: true,
    );
  }

  Future<EosbResult?> calculate({bool saveHistory = true}) async {
    state = state.copyWith(
      isCalculating: true,
      clearError: true,
      clearHistoryNotice: true,
      clearCloudSyncNotice: true,
    );
    try {
      await _repo?.cacheInput(state.input);
      final result = _calc.calculate(state.input);
      state = state.copyWith(result: result, isCalculating: false);

      if (saveHistory) {
        final repository = await _ref.read(eosbRepositoryProvider.future);
        final entry = CalculationHistoryEntry(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          input: state.input,
          result: result,
          savedAt: DateTime.now(),
          label: formatEosbCurrency(result.totalEntitlement),
        );
        final uid = _ref.read(currentAuthUidProvider);
        final outcome = await persistEosbCalculationHistory(
          ref: _ref,
          repository: repository,
          entry: entry,
          uid: uid,
        );
        if (!outcome.saved) {
          state = state.copyWith(
            result: result,
            error: outcome.blockedByCorruptStorage
                ? eosbHistoryCorruptWriteBlockedErrorCode
                : eosbHistoryPersistenceFailedErrorCode,
          );
          return result;
        }
        if (!outcome.includesSalaryDetails) {
          state = state.copyWith(
            result: result,
            lastHistoryNoticeKey: 'eosb_history_consent_limited',
          );
        }
        if (outcome.cloudSync == EosbCloudSyncOutcome.failed) {
          state = state.copyWith(result: result, cloudSyncNoticePending: true);
        }
        try {
          final trigger = await ReengagementSession.consumeIfActive();
          if (trigger != null) {
            OnboardingAnalyticsService.reengagementResultedInNewCalculation(
              trigger,
            );
          }
        } catch (_) {
          // Re-engagement is best-effort; persistence already succeeded.
        }
      }

      return result;
    } catch (_) {
      state = state.copyWith(
        isCalculating: false,
        error: eosbCalculationFailedErrorCode,
      );
      return null;
    }
  }
}

final eosbProvider = StateNotifierProvider<EosbNotifier, EosbState>((ref) {
  ref.watch(currentAuthUidProvider);
  final calc = ref.watch(eosbCalculationServiceProvider);
  final repoAsync = ref.watch(eosbRepositoryProvider);
  return EosbNotifier(calc, repoAsync.valueOrNull, ref);
});

final eosbHistoryLoadProvider =
    FutureProvider<EosbCalculationHistoryLoadOutcome>((ref) async {
      ref.watch(currentAuthUidProvider);
      final uid = ref.watch(currentAuthUidProvider);
      final repo = await ref.watch(eosbRepositoryProvider.future);
      return repo.loadHistoryOutcome(uid: uid);
    });

final eosbHistoryProvider = FutureProvider<List<CalculationHistoryEntry>>((
  ref,
) async {
  final outcome = await ref.watch(eosbHistoryLoadProvider.future);
  return outcome.records;
});

final eosbHistoryIsStorageCorruptProvider = Provider<bool>((ref) {
  final async = ref.watch(eosbHistoryLoadProvider);
  return async.maybeWhen(
    data: (outcome) => outcome.isStorageCorrupt,
    orElse: () => false,
  );
});

final eosbHistoryIsGenuinelyEmptyProvider = Provider<bool>((ref) {
  final async = ref.watch(eosbHistoryLoadProvider);
  return async.maybeWhen(
    data: (outcome) => outcome.isGenuinelyEmpty,
    orElse: () => false,
  );
});

final eosbContractAnalysisServiceProvider =
    Provider<EosbContractAnalysisService>((ref) {
      return EosbContractAnalysisService(
        ref.watch(claudeAIServiceProvider),
        ref.watch(eosbSalaryClaudeConsentGuardProvider),
      );
    });

final eosbDocumentImportServiceProvider = Provider<EosbDocumentImportService>((
  ref,
) {
  return EosbDocumentImportService(
    ref.watch(eosbContractAnalysisServiceProvider),
  );
});

final eosbContractAnalysisProvider = StateProvider<EosbContractAnalysis?>(
  (ref) => null,
);

final eosbScenarioServiceProvider = Provider<EosbScenarioService>((ref) {
  return EosbScenarioService(ref.watch(eosbCalculationServiceProvider));
});

final eosbScenariosProvider = Provider<List<EosbScenario>>((ref) {
  final input = ref.watch(eosbProvider).input;
  return ref.watch(eosbScenarioServiceProvider).simulate(input);
});

class EosbLegalReviewRequest {
  const EosbLegalReviewRequest({this.forceRegenerate = false});

  final bool forceRegenerate;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EosbLegalReviewRequest &&
          forceRegenerate == other.forceRegenerate;

  @override
  int get hashCode => forceRegenerate.hashCode;
}

final eosbLegalReviewTemplateProvider = Provider(
  (_) => const EosbLegalReviewTemplateService(),
);

final eosbLegalReviewProvider =
    Provider.family<EosbLegalReview?, EosbLegalReviewRequest>((ref, request) {
      final localeAsync = ref.watch(eosbLocaleProvider);
      final state = ref.watch(eosbProvider);
      final result = state.result;
      final locale = localeAsync.valueOrNull ?? 'English';

      if (result == null) return null;

      final analysis = ref.watch(eosbContractAnalysisProvider);
      return ref
          .watch(eosbLegalReviewTemplateProvider)
          .generate(
            input: state.input,
            result: result,
            locale: locale,
            contractAnalysis: analysis,
          );
    });
