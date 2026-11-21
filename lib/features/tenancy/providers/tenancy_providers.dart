import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:raabta/core/l10n/app_locale.dart';
import 'package:raabta/features/tenancy/data/tenancy_repository.dart';
import 'package:raabta/features/tenancy/domain/models/tenancy_compliance_models.dart';
import 'package:raabta/features/tenancy/domain/models/tenancy_lease_input.dart';
import 'package:raabta/features/tenancy/domain/services/tenancy_claim_basis_builder.dart';
import 'package:raabta/features/tenancy/data/tenancy_history_loader.dart';
import 'package:raabta/features/tenancy/domain/models/tenancy_check_history_entry.dart';
import 'package:raabta/features/tenancy/domain/models/tenancy_scenario.dart';
import 'package:raabta/features/tenancy/domain/services/tenancy_compliance_checker.dart';
import 'package:raabta/features/tenancy/domain/services/tenancy_scenario_service.dart';
import 'package:raabta/features/tenancy/services/tenancy_ai_service.dart';
import 'package:raabta/features/tenancy/services/tenancy_analytics_service.dart';
import 'package:raabta/features/home/providers/home_truth_chip_invalidation.dart';
import 'package:raabta/providers/auth_scoped_storage_providers.dart';
import 'package:raabta/providers/visa_providers.dart';
import 'package:raabta/services/ai/claude_ai_service.dart';

final tenancyRepositoryProvider = FutureProvider<TenancyRepository>((ref) async {
  final prefs = await SharedPreferences.getInstance();
  return TenancyRepository(prefs);
});

final tenancyLocaleProvider = FutureProvider<String>((ref) async {
  final repo = await ref.watch(tenancyRepositoryProvider.future);
  final userLang = ref.watch(userLanguageProvider);
  final stored = repo.locale().isNotEmpty ? repo.locale() : userLang;
  return AppLocale.normalize(stored);
});

final tenancyComplianceCheckerProvider =
    Provider<TenancyComplianceChecker>((ref) {
  return const TenancyComplianceChecker();
});

final tenancyAiServiceProvider = Provider<TenancyAiService>((ref) {
  return TenancyAiService(ref.watch(claudeAIServiceProvider));
});

class TenancyState {
  const TenancyState({
    this.input = const TenancyLeaseInput(),
    this.result,
    this.checklistCollected = const {},
    this.isChecking = false,
    this.error,
  });

  final TenancyLeaseInput input;
  final TenancyComplianceResult? result;
  final Set<String> checklistCollected;
  final bool isChecking;
  final String? error;

  TenancyState copyWith({
    TenancyLeaseInput? input,
    TenancyComplianceResult? result,
    Set<String>? checklistCollected,
    bool? isChecking,
    String? error,
    bool clearResult = false,
    bool clearError = false,
  }) {
    return TenancyState(
      input: input ?? this.input,
      result: clearResult ? null : (result ?? this.result),
      checklistCollected: checklistCollected ?? this.checklistCollected,
      isChecking: isChecking ?? this.isChecking,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class TenancyNotifier extends StateNotifier<TenancyState> {
  TenancyNotifier(this._repo, this._ref) : super(const TenancyState()) {
    _loadCache();
  }

  final TenancyRepository? _repo;
  final Ref _ref;

  Future<void> _loadCache() async {
    final cachedInput = _repo?.loadCachedInput();
    final cachedResult = _repo?.loadCachedResult();
    final checklist = _repo?.loadChecklistCollected() ?? {};
    if (cachedInput != null || cachedResult != null || checklist.isNotEmpty) {
      state = state.copyWith(
        input: cachedInput ?? state.input,
        result: cachedResult,
        checklistCollected: checklist,
      );
    }
  }

  void updateInput(TenancyLeaseInput input) {
    state = state.copyWith(input: input);
    _repo?.saveInput(input);
  }

  /// Restores a past check for read-only viewing — does not re-sync Firestore.
  void restoreFromHistory({
    required TenancyLeaseInput input,
    required TenancyComplianceResult result,
  }) {
    state = state.copyWith(input: input, result: result, clearError: true);
    _repo?.saveInput(input);
  }

  Future<void> toggleChecklistItem(String id, bool collected) async {
    final next = Set<String>.from(state.checklistCollected);
    if (collected) {
      next.add(id);
    } else {
      next.remove(id);
    }
    state = state.copyWith(checklistCollected: next);
    await _repo?.saveChecklistCollected(next);
  }

  Future<void> savePacketMetadata({
    required List<String> claimBasisKeys,
  }) async {
    final meta = DisputePacketMetadata(
      generatedAt: DateTime.now(),
      collectedItemIds: state.checklistCollected.toList(),
      claimBasisKeys: claimBasisKeys,
    );
    await _repo?.savePacketMetadata(meta);
    TenancyAnalyticsService.disputePacketGenerated(
      collectedCount: meta.collectedItemIds.length,
    );
  }

  Future<TenancyComplianceResult?> runComplianceCheck({
    required TenancyComplianceChecker checker,
  }) async {
    state = state.copyWith(isChecking: true, clearError: true);
    try {
      final result = checker.check(state.input);
      state = state.copyWith(result: result, isChecking: false);
      await _repo?.saveResult(result, input: state.input);
      invalidateHomeTruthChips(_ref);
      TenancyAnalyticsService.complianceCheckCompleted(
        hasCriticalIssue: result.hasCriticalIssue,
        hasViolation: result.hasViolation,
      );
      return result;
    } catch (e) {
      state = state.copyWith(
        isChecking: false,
        error: e.toString(),
      );
      return null;
    }
  }

  void clearResult() {
    state = state.copyWith(clearResult: true);
  }
}

final tenancyProvider =
    StateNotifierProvider<TenancyNotifier, TenancyState>((ref) {
  ref.watch(currentAuthUidProvider);
  final repoAsync = ref.watch(tenancyRepositoryProvider);
  return TenancyNotifier(repoAsync.valueOrNull, ref);
});

class TenancyAiMessage {
  const TenancyAiMessage({required this.role, required this.text});

  final String role;
  final String text;
}

class TenancyAiChatState {
  const TenancyAiChatState({
    this.messages = const [],
    this.isLoading = false,
  });

  final List<TenancyAiMessage> messages;
  final bool isLoading;

  TenancyAiChatState copyWith({
    List<TenancyAiMessage>? messages,
    bool? isLoading,
  }) {
    return TenancyAiChatState(
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class TenancyAiChatNotifier extends StateNotifier<TenancyAiChatState> {
  TenancyAiChatNotifier(this._service, this._ref)
      : super(const TenancyAiChatState());

  final TenancyAiService _service;
  final Ref _ref;

  Future<void> ask(String question) async {
    if (question.trim().isEmpty) return;
    final tenancy = _ref.read(tenancyProvider);
    final locale = await _ref.read(tenancyLocaleProvider.future);

    state = state.copyWith(
      isLoading: true,
      messages: [
        ...state.messages,
        TenancyAiMessage(role: 'user', text: question.trim()),
      ],
    );

    final history = state.messages
        .map((m) => {'role': m.role, 'content': m.text})
        .toList();

    final reply = await _service.ask(
      question: question,
      locale: locale,
      input: tenancy.input,
      result: tenancy.result,
      conversationHistory: history,
    );

    state = state.copyWith(
      isLoading: false,
      messages: [
        ...state.messages,
        TenancyAiMessage(role: 'assistant', text: reply.text),
      ],
    );
  }

  void clear() {
    state = const TenancyAiChatState();
  }
}

final tenancyAiChatProvider =
    StateNotifierProvider<TenancyAiChatNotifier, TenancyAiChatState>((ref) {
  return TenancyAiChatNotifier(
    ref.watch(tenancyAiServiceProvider),
    ref,
  );
});

final tenancyScenarioServiceProvider = Provider<TenancyScenarioService>((ref) {
  return TenancyScenarioService(ref.watch(tenancyComplianceCheckerProvider));
});

final tenancyScenariosProvider = Provider<List<TenancyScenario>>((ref) {
  final input = ref.watch(tenancyProvider).input;
  return ref.watch(tenancyScenarioServiceProvider).simulate(input);
});

final tenancyHistoryProvider =
    FutureProvider<List<TenancyCheckHistoryEntry>>((ref) async {
  return TenancyHistoryLoader.load();
});
