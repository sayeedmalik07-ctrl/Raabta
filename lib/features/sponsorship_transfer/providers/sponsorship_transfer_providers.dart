import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:raabta/core/l10n/app_locale.dart';
import 'package:raabta/features/sponsorship_transfer/data/sponsorship_transfer_repository.dart';
import 'package:raabta/features/sponsorship_transfer/domain/models/transfer_readiness_input.dart';
import 'package:raabta/features/sponsorship_transfer/domain/models/transfer_readiness_models.dart';
import 'package:raabta/features/sponsorship_transfer/data/sponsorship_transfer_history_loader.dart';
import 'package:raabta/features/sponsorship_transfer/domain/models/transfer_check_history_entry.dart';
import 'package:raabta/features/sponsorship_transfer/domain/models/transfer_scenario.dart';
import 'package:raabta/features/sponsorship_transfer/domain/services/transfer_readiness_checker.dart';
import 'package:raabta/features/sponsorship_transfer/domain/services/transfer_scenario_service.dart';
import 'package:raabta/features/sponsorship_transfer/services/sponsorship_transfer_ai_service.dart';
import 'package:raabta/features/sponsorship_transfer/services/sponsorship_transfer_analytics_service.dart';
import 'package:raabta/features/home/providers/home_truth_chip_invalidation.dart';
import 'package:raabta/providers/auth_scoped_storage_providers.dart';
import 'package:raabta/providers/visa_providers.dart';
import 'package:raabta/services/ai/claude_ai_service.dart';

final sponsorshipTransferRepositoryProvider =
    FutureProvider<SponsorshipTransferRepository>((ref) async {
  final prefs = await SharedPreferences.getInstance();
  return SponsorshipTransferRepository(prefs);
});

final sponsorshipTransferLocaleProvider = FutureProvider<String>((ref) async {
  final repo = await ref.watch(sponsorshipTransferRepositoryProvider.future);
  final userLang = ref.watch(userLanguageProvider);
  final stored = repo.locale().isNotEmpty ? repo.locale() : userLang;
  return AppLocale.normalize(stored);
});

final transferReadinessCheckerProvider =
    Provider<TransferReadinessChecker>((ref) {
  return const TransferReadinessChecker();
});

final sponsorshipTransferAiServiceProvider =
    Provider<SponsorshipTransferAiService>((ref) {
  return SponsorshipTransferAiService(ref.watch(claudeAIServiceProvider));
});

class SponsorshipTransferState {
  const SponsorshipTransferState({
    this.input = const TransferReadinessInput(),
    this.result,
    this.checklistCollected = const {},
    this.isChecking = false,
    this.error,
  });

  final TransferReadinessInput input;
  final TransferReadinessResult? result;
  final Set<String> checklistCollected;
  final bool isChecking;
  final String? error;

  SponsorshipTransferState copyWith({
    TransferReadinessInput? input,
    TransferReadinessResult? result,
    Set<String>? checklistCollected,
    bool? isChecking,
    String? error,
    bool clearResult = false,
    bool clearError = false,
  }) {
    return SponsorshipTransferState(
      input: input ?? this.input,
      result: clearResult ? null : (result ?? this.result),
      checklistCollected: checklistCollected ?? this.checklistCollected,
      isChecking: isChecking ?? this.isChecking,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class SponsorshipTransferNotifier extends StateNotifier<SponsorshipTransferState> {
  SponsorshipTransferNotifier(this._repo, this._ref)
      : super(const SponsorshipTransferState()) {
    _loadCache();
  }

  final SponsorshipTransferRepository? _repo;
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

  void updateInput(TransferReadinessInput input) {
    state = state.copyWith(input: input);
    _repo?.saveInput(input);
  }

  /// Restores a past check for read-only viewing — does not re-sync Firestore.
  void restoreFromHistory({
    required TransferReadinessInput input,
    required TransferReadinessResult result,
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
    SponsorshipTransferAnalyticsService.checklistUpdated(
      collectedCount: next.length,
    );
  }

  Future<TransferReadinessResult?> runReadinessCheck({
    required TransferReadinessChecker checker,
  }) async {
    state = state.copyWith(isChecking: true, clearError: true);
    try {
      final result = checker.check(state.input);
      state = state.copyWith(result: result, isChecking: false);
      await _repo?.saveResult(result, input: state.input);
      invalidateHomeTruthChips(_ref);
      SponsorshipTransferAnalyticsService.readinessCheckCompleted(
        hasCriticalIssue: result.hasCriticalIssue,
        hasWarning: result.hasWarning,
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
}

final sponsorshipTransferProvider =
    StateNotifierProvider<SponsorshipTransferNotifier, SponsorshipTransferState>(
        (ref) {
  ref.watch(currentAuthUidProvider);
  final repoAsync = ref.watch(sponsorshipTransferRepositoryProvider);
  return SponsorshipTransferNotifier(repoAsync.valueOrNull, ref);
});

class SponsorshipTransferAiMessage {
  const SponsorshipTransferAiMessage({required this.role, required this.text});

  final String role;
  final String text;
}

class SponsorshipTransferAiChatState {
  const SponsorshipTransferAiChatState({
    this.messages = const [],
    this.isLoading = false,
  });

  final List<SponsorshipTransferAiMessage> messages;
  final bool isLoading;

  SponsorshipTransferAiChatState copyWith({
    List<SponsorshipTransferAiMessage>? messages,
    bool? isLoading,
  }) {
    return SponsorshipTransferAiChatState(
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class SponsorshipTransferAiChatNotifier
    extends StateNotifier<SponsorshipTransferAiChatState> {
  SponsorshipTransferAiChatNotifier(this._service, this._ref)
      : super(const SponsorshipTransferAiChatState());

  final SponsorshipTransferAiService _service;
  final Ref _ref;

  Future<void> ask(String question) async {
    if (question.trim().isEmpty) return;
    final transfer = _ref.read(sponsorshipTransferProvider);
    final locale = await _ref.read(sponsorshipTransferLocaleProvider.future);

    state = state.copyWith(
      isLoading: true,
      messages: [
        ...state.messages,
        SponsorshipTransferAiMessage(role: 'user', text: question.trim()),
      ],
    );

    final history = state.messages
        .map((m) => {'role': m.role, 'content': m.text})
        .toList();

    final reply = await _service.ask(
      question: question,
      locale: locale,
      input: transfer.input,
      result: transfer.result,
      conversationHistory: history,
    );

    SponsorshipTransferAnalyticsService.aiAssistantUsed();

    state = state.copyWith(
      isLoading: false,
      messages: [
        ...state.messages,
        SponsorshipTransferAiMessage(role: 'assistant', text: reply.text),
      ],
    );
  }

  void clear() {
    state = const SponsorshipTransferAiChatState();
  }
}

final sponsorshipTransferAiChatProvider = StateNotifierProvider<
    SponsorshipTransferAiChatNotifier, SponsorshipTransferAiChatState>((ref) {
  return SponsorshipTransferAiChatNotifier(
    ref.watch(sponsorshipTransferAiServiceProvider),
    ref,
  );
});

final transferScenarioServiceProvider = Provider<TransferScenarioService>((ref) {
  return const TransferScenarioService();
});

final transferScenariosProvider = Provider<List<TransferScenario>>((ref) {
  final input = ref.watch(sponsorshipTransferProvider).input;
  return ref.watch(transferScenarioServiceProvider).simulate(input);
});

final transferHistoryProvider =
    FutureProvider<List<TransferCheckHistoryEntry>>((ref) async {
  return SponsorshipTransferHistoryLoader.load();
});
