import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/widgets/glass_progress_indicator.dart';
import 'package:raabta/core/widgets/glass_screen_scaffold.dart';
import 'package:raabta/features/quick_actions/climate_navigator/models/qatar_weather.dart';
import 'package:raabta/features/trip_planner/domain/models/trip_plan.dart';
import 'package:raabta/features/trip_planner/presentation/l10n/trip_strings.dart';
import 'package:raabta/features/trip_planner/presentation/widgets/trip_budget_chart.dart';
import 'package:raabta/features/prayer_mosque/domain/models/mosque.dart';
import 'package:raabta/features/prayer_mosque/providers/nearby_mosques_provider.dart';
import 'package:raabta/features/trip_planner/providers/trip_planner_providers.dart';

TripPlan? tripForId(TripPlannerState state, String tripId) {
  for (final t in state.savedTrips) {
    if (t.id == tripId) return t;
  }
  if (state.activeTrip?.id == tripId) return state.activeTrip;
  return null;
}

class TripBudgetScreen extends ConsumerWidget {
  const TripBudgetScreen({super.key, required this.tripId});

  final String tripId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(tripPlannerProvider);
    final trip = tripForId(state, tripId);
    final locale = state.preferences.locale;

    return GlassScreenScaffold(
      title: TripStrings.t('trip_budget', locale),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => context.pop(),
      ),
      padding: const EdgeInsets.all(AppSpacing.lg),
      body: trip == null
          ? const Center(child: GlassProgressIndicator())
          : ListView(
              children: [
                TripBudgetChart(
                  budget: trip.budget,
                  locale: locale,
                  currency: trip.preferences.currency,
                ),
                if (trip.budgetTips.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.lg),
                  Text(TripStrings.t('trip_over_budget', locale)),
                  ...trip.budgetTips.map(
                    (t) => ListTile(
                      title: Text(t.title),
                      subtitle: Text(t.description),
                      trailing: Text('-${t.savings.round()}'),
                    ),
                  ),
                ],
              ],
            ),
    );
  }
}

class TripMapScreen extends ConsumerStatefulWidget {
  const TripMapScreen({super.key, required this.tripId});

  final String tripId;

  @override
  ConsumerState<TripMapScreen> createState() => _TripMapScreenState();
}

class _TripMapScreenState extends ConsumerState<TripMapScreen> {
  bool _showMosques = false;

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(tripPlannerProvider);
    final trip = tripForId(state, widget.tripId);
    final locale = state.preferences.locale;

    if (trip == null) {
      return const GlassScreenScaffold(
        body: Center(child: GlassProgressIndicator()),
      );
    }

    final center = _mapCenter(trip);
    final activityMarkers = _activityMarkers(trip);

    Widget mapBody(Set<Marker> markers) {
      return Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              AppSpacing.sm,
              AppSpacing.md,
              0,
            ),
            child: Align(
              alignment: Alignment.centerLeft,
              child: FilterChip(
                label: Text(TripStrings.t('trip_map_mosques_layer', locale)),
                selected: _showMosques,
                onSelected: (value) => setState(() => _showMosques = value),
              ),
            ),
          ),
          Expanded(
            child: GoogleMap(
              initialCameraPosition: CameraPosition(target: center, zoom: 11),
              markers: markers,
              myLocationButtonEnabled: true,
            ),
          ),
        ],
      );
    }

    if (!_showMosques) {
      return GlassScreenScaffold(
        title: TripStrings.t('trip_map', locale),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        body: mapBody(activityMarkers),
      );
    }

    final mosquesAsync = ref.watch(
      nearbyMosquesProvider(
        NearbyMosquesQuery(
          latitude: center.latitude,
          longitude: center.longitude,
        ),
      ),
    );

    return GlassScreenScaffold(
      title: TripStrings.t('trip_map', locale),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => context.pop(),
      ),
      body: mosquesAsync.when(
        loading: () => mapBody(activityMarkers),
        error: (_, _) => mapBody(activityMarkers),
        data: (mosques) =>
            mapBody({...activityMarkers, ..._mosqueMarkers(mosques)}),
      ),
    );
  }

  LatLng _mapCenter(TripPlan trip) {
    for (final act in trip.allActivities) {
      if (act.latitude != null && act.longitude != null) {
        return LatLng(act.latitude!, act.longitude!);
      }
    }
    return const LatLng(25.2854, 51.5310);
  }

  Set<Marker> _activityMarkers(TripPlan trip) {
    final markers = <Marker>{};
    for (final act in trip.allActivities) {
      if (act.latitude == null || act.longitude == null) continue;
      markers.add(
        Marker(
          markerId: MarkerId(act.id),
          position: LatLng(act.latitude!, act.longitude!),
          infoWindow: InfoWindow(title: act.title),
        ),
      );
    }
    return markers;
  }

  Set<Marker> _mosqueMarkers(List<MosquePlace> mosques) {
    return mosques
        .map(
          (m) => Marker(
            markerId: MarkerId('mosque_${m.id}'),
            position: LatLng(m.latitude, m.longitude),
            icon: BitmapDescriptor.defaultMarkerWithHue(
              BitmapDescriptor.hueGreen,
            ),
            infoWindow: InfoWindow(title: m.name, snippet: m.address),
          ),
        )
        .toSet();
  }
}

class TripWeatherScreen extends ConsumerWidget {
  const TripWeatherScreen({super.key, required this.tripId});

  final String tripId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(tripPlannerProvider);
    final trip = tripForId(state, tripId);
    final locale = state.preferences.locale;
    final weatherAsync = ref.watch(qatarWeatherProvider);

    return GlassScreenScaffold(
      title: TripStrings.t('trip_weather', locale),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => context.pop(),
      ),
      padding: const EdgeInsets.all(AppSpacing.lg),
      body: weatherAsync.when(
        loading: () => const Center(child: GlassProgressIndicator()),
        error: (_, _) => Center(
          child: Text(TripStrings.t('trip_weather_unavailable', locale)),
        ),
        data: (w) => ListView(
          children: [
            ListTile(
              leading: const Icon(Icons.thermostat),
              title: Text('${w.tempC.toStringAsFixed(1)}°C'),
              subtitle: Text(
                TripStrings.format(
                  'trip_weather_feels_like',
                  locale,
                  {'temp': w.feelsLikeC.toStringAsFixed(1)},
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.water_drop_outlined),
              title: Text(
                TripStrings.format(
                  'trip_weather_humidity',
                  locale,
                  {'value': '${w.humidity}'},
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.wb_sunny_outlined),
              title: Text(
                TripStrings.format(
                  'trip_weather_uv',
                  locale,
                  {'value': '${w.uvIndex}'},
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.warning_amber),
              title: Text(w.heatRiskLabel),
              subtitle: Text(w.description),
            ),
            if (trip?.weatherSummary != null) ...[
              const Divider(),
              Text(trip!.weatherSummary!),
            ],
          ],
        ),
      ),
    );
  }
}

class TripSummaryScreen extends ConsumerWidget {
  const TripSummaryScreen({super.key, required this.tripId});

  final String tripId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(tripPlannerProvider);
    final trip = tripForId(state, tripId);
    final locale = state.preferences.locale;

    if (trip == null) {
      return const GlassScreenScaffold(
        body: Center(child: GlassProgressIndicator()),
      );
    }

    return GlassScreenScaffold(
      title: TripStrings.t('trip_summary', locale),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => context.pop(),
      ),
      padding: const EdgeInsets.all(AppSpacing.lg),
      body: ListView(
        children: [
          Text(trip.title, style: Theme.of(context).textTheme.headlineSmall),
          Text('${trip.totalDays} days · ${trip.preferences.destination}'),
          Text(
            'Budget: ${formatTripCurrency(trip.budget.totalBudget, symbol: trip.preferences.currency)}',
          ),
          const SizedBox(height: AppSpacing.lg),
          Text('${trip.allActivities.length} activities planned'),
          if (trip.shoppingSpots.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.md),
            Text(TripStrings.t('trip_shopping', locale)),
            ...trip.shoppingSpots.map((s) => ListTile(title: Text(s))),
          ],
        ],
      ),
    );
  }
}
