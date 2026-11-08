import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:raabta/features/quick_actions/climate_navigator/models/qatar_weather.dart';
import 'package:raabta/features/trip_planner/data/trip_planner_repository.dart';
import 'package:raabta/features/trip_planner/domain/models/trip_booking_segment.dart';
import 'package:raabta/features/trip_planner/domain/models/trip_plan.dart';
import 'package:raabta/features/trip_planner/domain/models/trip_preferences.dart';
import 'package:raabta/features/trip_planner/domain/models/trip_readiness_manual_checks.dart';
import 'package:raabta/features/trip_planner/domain/services/trip_booking_import_service.dart';
import 'package:raabta/features/trip_planner/domain/services/trip_planner_config.dart';
import 'package:raabta/features/trip_planner/domain/services/trip_prompt_signature.dart';
import 'package:raabta/features/trip_planner/domain/services/trip_change_of_plans_service.dart';
import 'package:raabta/features/trip_planner/services/trip_flight_reminder_service.dart';
import 'package:raabta/features/trip_planner/services/trip_planner_ai_service.dart';
import 'package:raabta/features/trip_planner/services/trip_planner_analytics_service.dart';
import 'package:raabta/services/ai/document_extraction_service.dart';

final tripPlannerRepositoryProvider =
    FutureProvider<TripPlannerRepository>((ref) async {
  final prefs = await SharedPreferences.getInstance();
  return TripPlannerRepository(prefs);
});

class TripPlannerState {
  const TripPlannerState({
    this.preferences = const TripPreferences(),
    this.activeTrip,
    this.savedTrips = const [],
    this.isGenerating = false,
    this.isInitialized = false,
    this.error,
    this.sessionEpoch = 0,
  });

  final TripPreferences preferences;
  final TripPlan? activeTrip;
  final List<TripPlan> savedTrips;
  final bool isGenerating;
  final bool isInitialized;
  final String? error;
  final int sessionEpoch;

  TripPlannerState copyWith({
    TripPreferences? preferences,
    TripPlan? activeTrip,
    List<TripPlan>? savedTrips,
    bool? isGenerating,
    bool? isInitialized,
    String? error,
    int? sessionEpoch,
  }) {
    return TripPlannerState(
      preferences: preferences ?? this.preferences,
      activeTrip: activeTrip ?? this.activeTrip,
      savedTrips: savedTrips ?? this.savedTrips,
      isGenerating: isGenerating ?? this.isGenerating,
      isInitialized: isInitialized ?? this.isInitialized,
      error: error,
      sessionEpoch: sessionEpoch ?? this.sessionEpoch,
    );
  }
}

class TripPlannerNotifier extends StateNotifier<TripPlannerState> {
  TripPlannerNotifier(this._ref) : super(const TripPlannerState()) {
    _load();
  }

  final Ref _ref;
  bool _preferencesLoaded = false;
  DateTime? _lastGenerateStarted;
  final Map<String, TripPlan> _changeOfPlansUndoByTripId = {};

  Future<void> _load({bool reloadTripsOnly = false}) async {
    try {
      final repo = await _ref.read(tripPlannerRepositoryProvider.future);
      final trips = await repo.loadTrips();
      final activeId = repo.getActiveTripId();
      TripPlan? active;
      if (activeId != null) {
        active = await repo.getTrip(activeId);
      }

      if (!reloadTripsOnly && !_preferencesLoaded) {
        final prefs = repo.loadDefaultPreferences();
        state = state.copyWith(
          preferences: prefs,
          savedTrips: trips,
          activeTrip: active ?? trips.firstOrNull,
          isInitialized: true,
          error: null,
        );
        _preferencesLoaded = true;
        return;
      }

      state = state.copyWith(
        savedTrips: trips,
        activeTrip: active ?? trips.firstOrNull,
        isInitialized: true,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(
        isInitialized: true,
        error: e.toString(),
      );
    }
  }

  Future<void> refreshPreferencesFromStorage() async {
    try {
      final repo = await _ref.read(tripPlannerRepositoryProvider.future);
      final prefs = repo.loadDefaultPreferences();
      state = state.copyWith(preferences: prefs, isInitialized: true, error: null);
      _preferencesLoaded = true;
    } catch (e) {
      state = state.copyWith(isInitialized: true, error: e.toString());
    }
  }

  void updatePreferences(TripPreferences prefs) {
    state = state.copyWith(preferences: prefs);
  }

  Future<bool> persistPreferences(TripPreferences prefs) async {
    state = state.copyWith(preferences: prefs);
    return savePreferences();
  }

  Future<bool> savePreferences() async {
    final repo = await _ref.read(tripPlannerRepositoryProvider.future);
    final saved = await repo.saveDefaultPreferences(state.preferences);
    if (!saved) return false;

    final verified = repo.loadDefaultPreferences();
    state = state.copyWith(preferences: verified);
    _preferencesLoaded = true;
    return true;
  }

  Future<TripPlan?> generateTrip() async {
    if (state.isGenerating) return null;

    final now = DateTime.now();
    if (_lastGenerateStarted != null &&
        now.difference(_lastGenerateStarted!) <
            Duration(seconds: TripPlannerConfig.generateDebounceSeconds)) {
      return state.activeTrip;
    }
    _lastGenerateStarted = now;

    state = state.copyWith(isGenerating: true, error: null);
    try {
      final weather = await _ref.read(qatarWeatherProvider.future);
      final weatherContext = weather.toPromptContext();
      final repo = await _ref.read(tripPlannerRepositoryProvider.future);
      final signature = TripPromptSignature.fromPreferences(state.preferences);

      final cached = await repo.loadCachedPlanForSignature(signature);
      final TripPlan plan;
      if (cached != null) {
        plan = cached.cloneWithNewIdentity().copyWith(
          weatherSummary: weatherContext,
          preferences: state.preferences,
        );
      } else {
        final tripId = DateTime.now().millisecondsSinceEpoch.toString();
        final ai = _ref.read(tripPlannerAiServiceProvider);
        final generated = await ai.generateTrip(
          preferences: state.preferences,
          weatherContext: weatherContext,
          tripId: tripId,
        );
        await repo.savePromptCache(signature: signature, plan: generated);
        plan = generated;
      }

      await repo.saveTrip(plan);
      await repo.setActiveTripId(plan.id);

      TripPlannerAnalyticsService.tripCreated(plan.id);

      state = state.copyWith(
        activeTrip: plan,
        savedTrips: [plan, ...state.savedTrips.where((t) => t.id != plan.id)],
        isGenerating: false,
      );
      return plan;
    } catch (e) {
      state = state.copyWith(
        isGenerating: false,
        error: e.toString(),
      );
      return null;
    }
  }

  Future<TripPlan?> duplicateTrip(String sourceId) async {
    final repo = await _ref.read(tripPlannerRepositoryProvider.future);
    final source = await repo.getTrip(sourceId);
    if (source == null) return null;

    final copy = source.cloneWithNewIdentity(titleSuffix: ' (copy)');
    await repo.saveTrip(copy);
    await repo.setActiveTripId(copy.id);

    state = state.copyWith(
      activeTrip: copy,
      savedTrips: [copy, ...state.savedTrips.where((t) => t.id != copy.id)],
    );
    return copy;
  }

  Future<TripPlan?> applyBookingImport({
    required BookingConfirmationExtractionResult extraction,
    required TripBookingSegment segment,
    required TripPreferences updatedPrefs,
    String? mergeIntoTripId,
  }) async {
    final repo = await _ref.read(tripPlannerRepositoryProvider.future);

    final TripPlan plan;
    if (mergeIntoTripId != null) {
      final existing = await repo.getTrip(mergeIntoTripId);
      if (existing == null) return null;
      plan = TripBookingImportService.mergeIntoExisting(
        existing: existing,
        segment: segment,
        updatedPrefs: updatedPrefs,
      );
    } else {
      plan = TripBookingImportService.createNewTrip(
        prefs: updatedPrefs,
        segment: segment,
        locale: updatedPrefs.locale,
      );
    }

    await repo.saveTrip(plan);
    await repo.setActiveTripId(plan.id);
    await repo.saveDefaultPreferences(updatedPrefs);

    state = state.copyWith(
      preferences: updatedPrefs,
      activeTrip: plan,
      savedTrips: [plan, ...state.savedTrips.where((t) => t.id != plan.id)],
    );
    _preferencesLoaded = true;
    return plan;
  }

  Future<void> updateReadinessManualChecks(
    String tripId,
    TripReadinessManualChecks checks,
  ) async {
    final repo = await _ref.read(tripPlannerRepositoryProvider.future);
    final trip = await repo.getTrip(tripId);
    if (trip == null) return;

    final updated = trip.copyWith(readinessManualChecks: checks);
    await repo.saveTrip(updated);

    state = state.copyWith(
      activeTrip: state.activeTrip?.id == tripId ? updated : state.activeTrip,
      savedTrips: state.savedTrips
          .map((t) => t.id == tripId ? updated : t)
          .toList(),
    );
  }

  Future<void> deleteTrip(String id) async {
    final repo = await _ref.read(tripPlannerRepositoryProvider.future);
    final existing = await repo.getTrip(id);
    if (existing != null) {
      final reminders = await _flightReminders();
      await reminders.setEnabled(
        tripId: id,
        enabled: false,
        trip: existing,
        locale: state.preferences.locale,
      );
    }
    _changeOfPlansUndoByTripId.remove(id);
    await repo.deleteTrip(id);
    final trips = await repo.loadTrips();
    state = state.copyWith(
      savedTrips: trips,
      activeTrip: state.activeTrip?.id == id ? trips.firstOrNull : state.activeTrip,
    );
    state = state.copyWith(sessionEpoch: state.sessionEpoch + 1);
  }

  bool changeOfPlansUndoAvailable(String tripId) =>
      _changeOfPlansUndoByTripId.containsKey(tripId);

  Future<void> applyChangeOfPlans({
    required String tripId,
    required TripChangeOfPlansAction action,
    required int count,
  }) async {
    final repo = await _ref.read(tripPlannerRepositoryProvider.future);
    final trip = await repo.getTrip(tripId);
    if (trip == null) return;

    _changeOfPlansUndoByTripId[tripId] = trip;
    final updated = TripChangeOfPlansService.apply(
      trip: trip,
      action: action,
      count: count,
    );
    await _saveTripAndSyncReminders(updated);
    state = state.copyWith(sessionEpoch: state.sessionEpoch + 1);
  }

  Future<void> undoChangeOfPlans(String tripId) async {
    final snapshot = _changeOfPlansUndoByTripId.remove(tripId);
    if (snapshot == null) return;
    await _saveTripAndSyncReminders(snapshot);
    state = state.copyWith(sessionEpoch: state.sessionEpoch + 1);
  }

  Future<void> moveDeferredActivityToDay({
    required String tripId,
    required String activityId,
    required int dayNumber,
  }) async {
    final repo = await _ref.read(tripPlannerRepositoryProvider.future);
    final trip = await repo.getTrip(tripId);
    if (trip == null) return;

    final updated = TripChangeOfPlansService.moveDeferredToDay(
      trip: trip,
      activityId: activityId,
      dayNumber: dayNumber,
    );
    await _saveTripAndSyncReminders(updated);
    state = state.copyWith(sessionEpoch: state.sessionEpoch + 1);
  }

  Future<void> setFlightReminderEnabled({
    required String tripId,
    required bool enabled,
  }) async {
    final repo = await _ref.read(tripPlannerRepositoryProvider.future);
    final trip = await repo.getTrip(tripId);
    if (trip == null) return;

    final reminders = await _flightReminders();
    await reminders.setEnabled(
      tripId: tripId,
      enabled: enabled,
      trip: trip,
      locale: state.preferences.locale,
    );
    state = state.copyWith(sessionEpoch: state.sessionEpoch + 1);
  }

  Future<void> _saveTripAndSyncReminders(TripPlan trip) async {
    final repo = await _ref.read(tripPlannerRepositoryProvider.future);
    await repo.saveTrip(trip);
    final reminders = await _flightReminders();
    await reminders.rescheduleAfterTripChange(
      trip: trip,
      locale: state.preferences.locale,
    );
    state = state.copyWith(
      activeTrip: state.activeTrip?.id == trip.id ? trip : state.activeTrip,
      savedTrips: state.savedTrips.map((t) => t.id == trip.id ? trip : t).toList(),
    );
  }

  Future<TripFlightReminderService> _flightReminders() async {
    final prefs = await SharedPreferences.getInstance();
    return TripFlightReminderService(prefs);
  }

  Future<void> toggleFavorite(String id) async {
    final repo = await _ref.read(tripPlannerRepositoryProvider.future);
    await repo.toggleFavorite(id);
    await _load(reloadTripsOnly: true);
  }

  void setActiveTrip(TripPlan trip) async {
    final repo = await _ref.read(tripPlannerRepositoryProvider.future);
    await repo.setActiveTripId(trip.id);
    state = state.copyWith(activeTrip: trip);
  }
}

final tripPlannerProvider =
    StateNotifierProvider<TripPlannerNotifier, TripPlannerState>((ref) {
  return TripPlannerNotifier(ref);
});

final tripChangeOfPlansUndoAvailableProvider =
    Provider.family<bool, String>((ref, tripId) {
  ref.watch(tripPlannerProvider.select((s) => s.sessionEpoch));
  return ref.read(tripPlannerProvider.notifier).changeOfPlansUndoAvailable(tripId);
});

final tripFlightReminderEnabledProvider =
    FutureProvider.family<bool, String>((ref, tripId) async {
  ref.watch(tripPlannerProvider.select((s) => s.sessionEpoch));
  final prefs = await SharedPreferences.getInstance();
  return TripFlightReminderService(prefs).isEnabledForTrip(tripId);
});

class SavedPlacesNotifier extends StateNotifier<List<String>> {
  SavedPlacesNotifier(this._ref) : super([]) {
    _load();
  }

  final Ref _ref;

  Future<void> _load() async {
    final repo = await _ref.read(tripPlannerRepositoryProvider.future);
    state = repo.loadSavedPlaceIds();
  }

  Future<void> toggle(String placeId) async {
    final repo = await _ref.read(tripPlannerRepositoryProvider.future);
    await repo.toggleSavedPlace(placeId);
    state = repo.loadSavedPlaceIds();
  }
}

final savedPlacesProvider =
    StateNotifierProvider<SavedPlacesNotifier, List<String>>((ref) {
  return SavedPlacesNotifier(ref);
});

extension _FirstOrNull<E> on List<E> {
  E? get firstOrNull => isEmpty ? null : first;
}
