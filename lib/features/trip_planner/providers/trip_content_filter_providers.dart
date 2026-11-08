import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raabta/features/trip_planner/data/qatar_local_life_catalog.dart';
import 'package:raabta/features/trip_planner/domain/models/local_life_models.dart';
import 'package:raabta/features/trip_planner/domain/models/trip_preferences.dart';
import 'package:raabta/features/trip_planner/domain/services/trip_content_filter_service.dart';
import 'package:raabta/features/trip_planner/providers/trip_planner_providers.dart';

final tripContentFilterServiceProvider =
    Provider<TripContentFilterService>((ref) {
  return const TripContentFilterService();
});

/// Active trip preferences when set, otherwise global trip planner preferences.
TripPreferences tripContentContextPreferences(Ref ref) {
  final state = ref.watch(tripPlannerProvider);
  return state.activeTrip?.preferences ?? state.preferences;
}

final tripLocalLifeFilterProvider = Provider<TripLocalLifeFilterResult>((ref) {
  final prefs = tripContentContextPreferences(ref);
  final service = ref.watch(tripContentFilterServiceProvider);
  return service.filterLocalLifeEntries(QatarLocalLifeCatalog.all, prefs);
});

final tripLocalLifeCategoryFilterProvider =
    Provider.family<TripLocalLifeFilterResult, LocalLifeCategory>((ref, category) {
  final prefs = tripContentContextPreferences(ref);
  final service = ref.watch(tripContentFilterServiceProvider);
  return service.filterLocalLifeEntries(
    QatarLocalLifeCatalog.entriesFor(category),
    prefs,
  );
});
