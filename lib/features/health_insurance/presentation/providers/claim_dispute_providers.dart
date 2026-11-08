import 'package:raabta/features/health_insurance/data/models/claim_dispute_models.dart';
import 'package:raabta/features/health_insurance/data/models/insurer_lookup_models.dart';
import 'package:raabta/features/health_insurance/data/repository/health_insurance_claim_dispute_repository.dart';
import 'package:raabta/features/health_insurance/domain/models/insurer_regulatory_body.dart';
import 'package:raabta/features/health_insurance/domain/services/claim_dispute_ai_service.dart';
import 'package:raabta/features/health_insurance/domain/services/insurer_lookup_service.dart';
import 'package:raabta/providers/auth_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final claimDisputeRepositoryProvider =
    FutureProvider<HealthInsuranceClaimDisputeRepository>((ref) async {
  final prefs = await SharedPreferences.getInstance();
  return HealthInsuranceClaimDisputeRepository(prefs);
});

final claimDisputeAiServiceProvider = Provider<ClaimDisputeAiService>((ref) {
  return ClaimDisputeAiService(ref);
});

class ClaimDisputeState {
  const ClaimDisputeState({
    this.dispute,
    this.isLoading = false,
    this.isSaving = false,
    this.isAiBusy = false,
    this.pendingChecklistItemId,
    this.error,
    this.explainStepText,
    this.explainClauseText,
  });

  final HealthInsuranceClaimDispute? dispute;
  final bool isLoading;
  final bool isSaving;
  final bool isAiBusy;
  final String? pendingChecklistItemId;
  final String? error;
  final String? explainStepText;
  final String? explainClauseText;

  ClaimDisputeState copyWith({
    HealthInsuranceClaimDispute? dispute,
    bool? isLoading,
    bool? isSaving,
    bool? isAiBusy,
    String? pendingChecklistItemId,
    String? error,
    String? explainStepText,
    String? explainClauseText,
    bool clearDispute = false,
    bool clearError = false,
    bool clearAi = false,
    bool clearPendingItem = false,
  }) {
    return ClaimDisputeState(
      dispute: clearDispute ? null : (dispute ?? this.dispute),
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      isAiBusy: isAiBusy ?? this.isAiBusy,
      pendingChecklistItemId: clearPendingItem
          ? null
          : (pendingChecklistItemId ?? this.pendingChecklistItemId),
      error: clearError ? null : (error ?? this.error),
      explainStepText:
          clearAi ? null : (explainStepText ?? this.explainStepText),
      explainClauseText:
          clearAi ? null : (explainClauseText ?? this.explainClauseText),
    );
  }
}

class ClaimDisputeNotifier extends StateNotifier<ClaimDisputeState> {
  ClaimDisputeNotifier(this._ref) : super(const ClaimDisputeState()) {
    _load();
  }

  final Ref _ref;
  HealthInsuranceClaimDisputeRepository? _repo;

  Future<HealthInsuranceClaimDisputeRepository> _repository() async {
    _repo ??= await _ref.read(claimDisputeRepositoryProvider.future);
    return _repo!;
  }

  Future<void> _load() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final repo = await _repository();
      final uid = _ref.read(currentUserProvider)?.uid ?? '';
      final dispute = await repo.fetchLatest(uid);
      state = state.copyWith(dispute: dispute, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> submitIntake({
    required String insurerName,
    required String insurerCardLabel,
    required InsurerLookupMatchType? matchType,
    required InsurerRegulatoryBody regulatoryBody,
    required ClaimDenialReasonCategory denialReason,
    String? denialReasonOtherText,
    DateTime? denialDate,
    required bool hasWrittenDenialLetter,
    required bool employerProvidedCoverage,
    String? claimAmount,
    String? policyNumber,
  }) async {
    state = state.copyWith(isSaving: true, clearError: true);
    try {
      final repo = await _repository();
      final uid = _ref.read(currentUserProvider)?.uid ?? '';
      final now = DateTime.now();
      final dispute = HealthInsuranceClaimDispute(
        disputeId: state.dispute?.disputeId ?? '',
        userId: uid,
        insurerName: insurerName.isNotEmpty ? insurerName : insurerCardLabel,
        insurerMatchType: matchType,
        regulatoryBody: regulatoryBody,
        denialReason: denialReason,
        denialReasonOtherText: denialReasonOtherText,
        denialDate: denialDate,
        hasWrittenDenialLetter: hasWrittenDenialLetter,
        employerProvidedCoverage: employerProvidedCoverage,
        claimAmount: claimAmount,
        policyNumber: policyNumber,
        createdAt: state.dispute?.createdAt ?? now,
        updatedAt: now,
      );
      final saved = await repo.upsert(dispute);
      state = state.copyWith(dispute: saved, isSaving: false);
    } catch (e) {
      state = state.copyWith(isSaving: false, error: e.toString());
    }
  }

  Future<void> toggleStep(String stepId, bool complete) async {
    final dispute = state.dispute;
    if (dispute == null) return;
    state = state.copyWith(isSaving: true, clearError: true);
    try {
      final repo = await _repository();
      final saved = await repo.toggleStep(
        dispute: dispute,
        stepId: stepId,
        complete: complete,
      );
      state = state.copyWith(dispute: saved, isSaving: false);
    } catch (e) {
      state = state.copyWith(isSaving: false, error: e.toString());
    }
  }

  Future<void> attachDocument(String checklistItemId, String documentId) async {
    final dispute = state.dispute;
    if (dispute == null) return;
    state = state.copyWith(isSaving: true, clearError: true);
    try {
      final repo = await _repository();
      final saved = await repo.attachDocument(
        dispute: dispute,
        checklistItemId: checklistItemId,
        documentId: documentId,
      );
      state = state.copyWith(
        dispute: saved,
        isSaving: false,
        clearPendingItem: true,
      );
    } catch (e) {
      state = state.copyWith(isSaving: false, error: e.toString());
    }
  }

  void setPendingChecklistItem(String? itemId) {
    state = state.copyWith(
      pendingChecklistItemId: itemId,
      clearPendingItem: itemId == null,
    );
  }

  Future<void> explainStep(String stepId, String locale) async {
    state = state.copyWith(isAiBusy: true, clearError: true, clearAi: true);
    try {
      final ai = _ref.read(claimDisputeAiServiceProvider);
      final text = await ai.explainStep(stepId: stepId, locale: locale);
      state = state.copyWith(isAiBusy: false, explainStepText: text);
    } catch (e) {
      state = state.copyWith(isAiBusy: false, error: e.toString());
    }
  }

  Future<void> explainClause(String clauseText, String locale) async {
    state = state.copyWith(isAiBusy: true, clearError: true, clearAi: true);
    try {
      final ai = _ref.read(claimDisputeAiServiceProvider);
      final text = await ai.explainClause(clauseText: clauseText, locale: locale);
      state = state.copyWith(isAiBusy: false, explainClauseText: text);
    } catch (e) {
      state = state.copyWith(isAiBusy: false, error: e.toString());
    }
  }

  Future<void> draftLetter({
    required String locale,
    required bool toRegulator,
    String? policyClauseText,
  }) async {
    final dispute = state.dispute;
    if (dispute == null) return;
    state = state.copyWith(isAiBusy: true, clearError: true);
    try {
      final ai = _ref.read(claimDisputeAiServiceProvider);
      final letter = await ai.draftLetter(
        dispute: dispute,
        locale: locale,
        toRegulator: toRegulator,
        policyClauseText: policyClauseText,
      );
      final repo = await _repository();
      final saved = await repo.upsert(
        dispute.copyWith(draftLetter: letter, updatedAt: DateTime.now()),
      );
      state = state.copyWith(dispute: saved, isAiBusy: false);
    } catch (e) {
      state = state.copyWith(isAiBusy: false, error: e.toString());
    }
  }

  Future<void> updateDraftLetter(String letter) async {
    final dispute = state.dispute;
    if (dispute == null) return;
    final repo = await _repository();
    final saved = await repo.upsert(
      dispute.copyWith(draftLetter: letter, updatedAt: DateTime.now()),
    );
    state = state.copyWith(dispute: saved);
  }

  Future<void> resetDispute() async {
    final repo = await _repository();
    await repo.clearLocal();
    state = const ClaimDisputeState();
  }
}

final claimDisputeProvider =
    StateNotifierProvider<ClaimDisputeNotifier, ClaimDisputeState>((ref) {
  return ClaimDisputeNotifier(ref);
});

/// Resolves regulatory body from lookup service + intake labels.
InsurerRegulatoryBody resolveClaimDisputeRegulatoryBody({
  required InsurerLookupService? lookup,
  required String insurerName,
  required String cardLabel,
  bool manualReview = false,
}) {
  if (lookup == null) return InsurerRegulatoryBody.qcb;
  return lookup.resolveRegulatoryBody(
    insurerName: insurerName,
    cardLabel: cardLabel,
    manualReview: manualReview,
  );
}
