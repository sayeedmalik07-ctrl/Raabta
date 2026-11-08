import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raabta/core/l10n/app_locale.dart';
import 'package:raabta/features/concierge_90_day/data/models/journey_milestone.dart';
import 'package:raabta/features/concierge_90_day/data/models/journey_progress.dart';
import 'package:raabta/features/concierge_90_day/data/repository/concierge_journey_repository.dart';
import 'package:raabta/features/concierge_90_day/domain/services/concierge_timeline_service.dart';
import 'package:raabta/features/onboarding/services/onboarding_service.dart';
import 'package:raabta/providers/auth_providers.dart';
import 'package:raabta/providers/visa_providers.dart';
import 'package:raabta/services/ai/user_profile_ai_service.dart';
import 'package:raabta/services/smart_notification_engine.dart';

final conciergeRepositoryProvider =
    FutureProvider<ConciergeJourneyRepository>((ref) async {
  return createConciergeRepository();
});

final conciergeCompletionDetectorProvider =
    FutureProvider<ConciergeCompletionDetector>((ref) async {
  return createCompletionDetector();
});

final conciergeTimelineServiceProvider =
    Provider<ConciergeTimelineService>((ref) => const ConciergeTimelineService());

final conciergeProgressProvider = StreamProvider<JourneyProgress>((ref) async* {
  final uid = ref.watch(currentUserProvider)?.uid;
  if (uid == null) {
    yield const JourneyProgress();
    return;
  }
  final repo = await ref.watch(conciergeRepositoryProvider.future);
  yield await repo.loadProgress(uid);
  yield* repo.watchProgress(uid);
});

class ConciergeState {
  const ConciergeState({
    this.progress = const JourneyProgress(),
    this.snapshot,
    this.isLoading = true,
  });

  final JourneyProgress progress;
  final ConciergeTimelineSnapshot? snapshot;
  final bool isLoading;

  bool get shouldShowConcierge =>
      !progress.conciergeDisabled && !progress.journeyCompleted;
}

final conciergeStateProvider = FutureProvider<ConciergeState>((ref) async {
  // Milestone copy is resolved in widgets via ConciergeStrings — rebuild state
  // when locale changes so home card + journey screen pick up new labels.
  ref.watch(userLanguageProvider);
  final uid = ref.watch(currentUserProvider)?.uid;
  final timeline = ref.watch(conciergeTimelineServiceProvider);
  if (uid == null) {
    return const ConciergeState(isLoading: false);
  }

  final repo = await ref.watch(conciergeRepositoryProvider.future);
  final detector = await ref.watch(conciergeCompletionDetectorProvider.future);
  var progress = await repo.loadProgress(uid);

  final profile = ref.watch(userAIProfileProvider);
  final hasDocs = await repo.hasScannedDocuments(uid);
  final detected = await detector.detectAutoCompletions(
    profile: profile,
    hasScannedDocuments: hasDocs,
  );
  progress = await repo.mergeAutoDetections(uid, detected, progress);

  final snapshot = timeline.buildSnapshot(progress);
  if (timeline.isJourneyComplete(progress) && !progress.journeyCompleted) {
    progress = progress.copyWith(journeyCompleted: true);
    await repo.saveProgress(uid, progress);
  }

  return ConciergeState(
    progress: progress,
    snapshot: snapshot,
    isLoading: false,
  );
});

final conciergeNotifierProvider =
    Provider<ConciergeJourneyNotifier>((ref) => ConciergeJourneyNotifier(ref));

class ConciergeJourneyNotifier {
  ConciergeJourneyNotifier(this._ref);

  final Ref _ref;

  Future<void> refresh() async {
    _ref.invalidate(conciergeStateProvider);
    _ref.invalidate(conciergeProgressProvider);
  }

  Future<void> markDone(JourneyMilestoneId id) async {
    final uid = _ref.read(currentUserProvider)?.uid;
    if (uid == null) return;
    final repo = await _ref.read(conciergeRepositoryProvider.future);
    final state = await _ref.read(conciergeStateProvider.future);
    await repo.markMilestone(
      uid,
      id,
      MilestoneStatus.completed,
      state.progress,
    );
    await _scheduleNextNotificationIfNeeded(uid);
    await refresh();
  }

  Future<void> markNotApplicable(JourneyMilestoneId id) async {
    final uid = _ref.read(currentUserProvider)?.uid;
    if (uid == null) return;
    final repo = await _ref.read(conciergeRepositoryProvider.future);
    final state = await _ref.read(conciergeStateProvider.future);
    await repo.markMilestone(
      uid,
      id,
      MilestoneStatus.notApplicable,
      state.progress,
    );
    await refresh();
  }

  Future<void> setArrivalDate(DateTime? date, {bool skipped = false}) async {
    final uid = _ref.read(currentUserProvider)?.uid;
    if (uid == null) return;
    final repo = await _ref.read(conciergeRepositoryProvider.future);
    final state = await _ref.read(conciergeStateProvider.future);
    await repo.setArrivalDate(uid, date, skipped: skipped, current: state.progress);
    await refresh();
  }

  Future<void> disableConcierge() async {
    final uid = _ref.read(currentUserProvider)?.uid;
    if (uid == null) return;
    final repo = await _ref.read(conciergeRepositoryProvider.future);
    final state = await _ref.read(conciergeStateProvider.future);
    await repo.disableConcierge(uid, state.progress);
    await SmartNotificationEngine.instance.cancelConcierge90DayReminders();
    await refresh();
  }

  Future<String> resolveRoute(JourneyMilestone milestone) async {
    if (milestone.id == JourneyMilestoneId.eosbOnboarding) {
      final done = await OnboardingService.instance.isCompletedLocally();
      return done ? '/eosb/employee-info' : '/onboarding/welcome';
    }
    return milestone.route;
  }

  Future<void> _scheduleNextNotificationIfNeeded(String uid) async {
    final state = await _ref.read(conciergeStateProvider.future);
    if (state.progress.conciergeDisabled) return;
    final next = state.snapshot?.nextMilestone;
    if (next == null) return;
    final locale = AppLocale.normalize(
      // Snapshot: notification text matches locale at schedule time, not later toggles.
      _ref.read(userLanguageProvider),
    );
    await SmartNotificationEngine.instance.scheduleConciergeMilestoneReminder(
      milestoneId: next.idString,
      route: await resolveRoute(next),
      locale: locale,
    );
  }
}
