import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:raabta/features/eosb/data/eosb_repository.dart';
import 'package:raabta/features/eosb/domain/models/eosb_contract_analysis.dart';
import 'package:raabta/features/eosb/domain/models/eosb_employee_input.dart';
import 'package:raabta/features/eosb/domain/models/eosb_result.dart';
import 'package:raabta/features/eosb/domain/models/eosb_scenario.dart';
import 'package:raabta/features/eosb/domain/services/eosb_calculation_service.dart';
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

/// Shown when UID-scoped history could not be written ([saveHistory] path).
const eosbHistoryPersistenceFailedMessage =
    'Could not save calculation history. Sign in and try again.';

@visibleForTesting
Future<bool> persistEosbCalculationHistory({
  required dynamic ref,
  required EosbRepository repository,
  required CalculationHistoryEntry entry,
  String? uid,
}) async {
  final saved = await repository.saveHistoryEntry(entry, uid: uid);
  if (!saved) return false;
  invalidateHomeTruthChips(ref);
  return true;
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
  final repo = await ref.watch(eosbRepositoryProvider.future);
  final userLang = ref.watch(userLanguageProvider);
  final stored = repo.locale().isNotEmpty ? repo.locale() : userLang;
  return AppLocale.normalize(stored);
});

class EosbState {
  const EosbState({
    this.input = const EosbEmployeeInput(),
    this.result,
    this.isCalculating = false,
    this.error,
  });

  final EosbEmployeeInput input;
  final EosbResult? result;
  final bool isCalculating;
  final String? error;

  EosbState copyWith({
    EosbEmployeeInput? input,
    EosbResult? result,
    bool? isCalculating,
    String? error,
    bool clearResult = false,
    bool clearError = false,
  }) {
    return EosbState(
      input: input ?? this.input,
      result: clearResult ? null : (result ?? this.result),
      isCalculating: isCalculating ?? this.isCalculating,
      error: clearError ? null : (error ?? this.error),
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

  Future<EosbResult?> calculate({bool saveHistory = true}) async {
    state = state.copyWith(isCalculating: true, clearError: true);
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
        final persisted = await persistEosbCalculationHistory(
          ref: _ref,
          repository: repository,
          entry: entry,
          uid: uid,
        );
        if (!persisted) {
          state = state.copyWith(
            result: result,
            error: eosbHistoryPersistenceFailedMessage,
          );
          return result;
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
    } catch (e) {
      state = state.copyWith(
        isCalculating: false,
        error: e.toString(),
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

final eosbHistoryProvider = FutureProvider<List<CalculationHistoryEntry>>(
  (ref) async {
    ref.watch(currentAuthUidProvider);
    final repo = await ref.watch(eosbRepositoryProvider.future);
    return repo.loadHistory();
  },
);

final eosbContractAnalysisServiceProvider =
    Provider<EosbContractAnalysisService>((ref) {
  return EosbContractAnalysisService(ref.watch(claudeAIServiceProvider));
});

final eosbDocumentImportServiceProvider =
    Provider<EosbDocumentImportService>((ref) {
  return EosbDocumentImportService(
    ref.watch(eosbContractAnalysisServiceProvider),
  );
});

final eosbContractAnalysisProvider =
    StateProvider<EosbContractAnalysis?>((ref) => null);

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

final eosbLegalReviewTemplateProvider =
    Provider((_) => const EosbLegalReviewTemplateService());

final eosbLegalReviewProvider =
    Provider.family<EosbLegalReview?, EosbLegalReviewRequest>(
        (ref, request) {
  final localeAsync = ref.watch(eosbLocaleProvider);
  final state = ref.watch(eosbProvider);
  final result = state.result;
  final locale = localeAsync.valueOrNull ?? 'English';

  if (result == null) return null;

  final analysis = ref.watch(eosbContractAnalysisProvider);
  return ref.watch(eosbLegalReviewTemplateProvider).generate(
        input: state.input,
        result: result,
        locale: locale,
        contractAnalysis: analysis,
      );
});
