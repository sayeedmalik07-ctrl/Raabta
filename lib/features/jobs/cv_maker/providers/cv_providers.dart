import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raabta/features/jobs/cv_maker/data/cv_repository.dart';
import 'package:raabta/features/jobs/cv_maker/domain/models/cv_document.dart';
import 'package:raabta/features/jobs/cv_maker/services/cv_analytics_service.dart';
import 'package:raabta/features/jobs/cv_maker/services/cv_photo_service.dart';
import 'package:raabta/features/jobs/cv_maker/services/cv_prefill_service.dart';

enum CvLoadIntent { profilePrefill, scratch, existing, imported }

class CvBuilderState {
  const CvBuilderState({
    this.cv,
    this.isLoading = false,
    this.isSaving = false,
    this.error,
  });

  final CvDocument? cv;
  final bool isLoading;
  final bool isSaving;
  final String? error;

  CvBuilderState copyWith({
    CvDocument? cv,
    bool? isLoading,
    bool? isSaving,
    String? error,
    bool clearError = false,
  }) {
    return CvBuilderState(
      cv: cv ?? this.cv,
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class CvBuilderNotifier extends StateNotifier<CvBuilderState> {
  CvBuilderNotifier(this._ref) : super(const CvBuilderState());

  final Ref _ref;

  Future<bool> load({
    String? existingCvId,
    CvDocument? imported,
    String? freshId,
    CvLoadIntent? intent,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final repo = _ref.read(cvRepositoryProvider);
      CvDocument? cv;

      if (imported != null) {
        cv = imported;
      } else if (intent == CvLoadIntent.profilePrefill ||
          (intent == null && existingCvId == null && freshId == null)) {
        cv = await _ref.read(cvPrefillServiceProvider).buildPrefilled();
      } else if (freshId != null || intent == CvLoadIntent.scratch) {
        final id = freshId ?? DateTime.now().millisecondsSinceEpoch.toString();
        cv = CvDocument(id: id, updatedAt: DateTime.now());
      } else if (existingCvId != null) {
        cv = await repo.load(existingCvId);
        if (cv == null && state.cv?.id == existingCvId) {
          cv = state.cv;
        }
        cv ??= CvDocument(id: existingCvId, updatedAt: DateTime.now());
      } else {
        cv = await _ref.read(cvPrefillServiceProvider).buildPrefilled();
      }

      await repo.save(cv);
      state = state.copyWith(cv: cv, isLoading: false);
      CvAnalyticsService.cvBuilderStarted();
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  /// Opens builder when CV is already in memory (from start screen).
  void adopt(CvDocument cv) {
    state = state.copyWith(cv: cv, isLoading: false, clearError: true);
  }

  void updateCv(CvDocument cv) {
    state = state.copyWith(cv: cv.copyWith(updatedAt: DateTime.now()));
  }

  Future<void> persist() async {
    var cv = state.cv;
    if (cv == null) return;
    state = state.copyWith(isSaving: true, clearError: true);
    try {
      final photoPath = cv.photoLocalPath;
      if (photoPath != null && photoPath.isNotEmpty) {
        final url = await _ref.read(cvPhotoServiceProvider).uploadToStorage(
              cvId: cv.id,
              localPath: photoPath,
            );
        if (url != null && url != cv.photoStorageUrl) {
          cv = cv.copyWith(photoStorageUrl: url);
          state = state.copyWith(cv: cv);
        }
      }
      await _ref.read(cvRepositoryProvider).save(cv);
      state = state.copyWith(isSaving: false);
    } catch (e) {
      state = state.copyWith(isSaving: false, error: e.toString());
    }
  }

  Future<void> refreshAiCounts() async {
    final cv = state.cv;
    if (cv == null) return;
    final loaded = await _ref.read(cvRepositoryProvider).load(cv.id);
    if (loaded != null) {
      state = state.copyWith(
        cv: cv.copyWith(
          aiAssistCounts: loaded.aiAssistCounts,
          totalAiAssistCalls: loaded.totalAiAssistCalls,
        ),
      );
    }
  }
}

/// Kept alive across cv-start → cv-builder navigation within a session.
final cvBuilderProvider =
    StateNotifierProvider<CvBuilderNotifier, CvBuilderState>(
  (ref) => CvBuilderNotifier(ref),
);

final hasSavedCvProvider = FutureProvider<bool>((ref) async {
  return ref.read(cvRepositoryProvider).hasSavedCvInVault();
});

final hasDraftCvProvider = FutureProvider<bool>((ref) async {
  return ref.read(cvRepositoryProvider).hasDraftCv();
});
