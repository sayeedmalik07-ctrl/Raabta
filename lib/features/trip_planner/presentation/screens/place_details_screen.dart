import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:raabta/core/glass/glass_card.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/core/widgets/glass_primary_button.dart';
import 'package:raabta/core/widgets/glass_screen_scaffold.dart';
import 'package:raabta/features/trip_planner/domain/models/trip_plan.dart';
import 'package:raabta/features/trip_planner/presentation/l10n/trip_strings.dart';
import 'package:raabta/features/trip_planner/providers/trip_planner_providers.dart';
import 'package:raabta/features/trip_planner/services/trip_planner_analytics_service.dart';
import 'package:url_launcher/url_launcher.dart';

class PlaceDetailsScreen extends ConsumerWidget {
  const PlaceDetailsScreen({
    super.key,
    required this.tripId,
    required this.activityId,
  });

  final String tripId;
  final String activityId;

  TripActivity? _findActivity(TripPlannerState state) {
    TripPlan? trip;
    for (final t in state.savedTrips) {
      if (t.id == tripId) {
        trip = t;
        break;
      }
    }
    trip ??= state.activeTrip?.id == tripId ? state.activeTrip : null;
    if (trip == null) return null;
    for (final day in trip.days) {
      for (final act in day.activities) {
        if (act.id == activityId) return act;
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(tripPlannerProvider);
    final activity = _findActivity(state);
    final locale = state.preferences.locale;

    if (activity == null) {
      return GlassScreenScaffold(
        title: TripStrings.t('trip_attraction', locale),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        body: Center(child: Text(TripStrings.t('trip_not_found', locale))),
      );
    }

    TripPlannerAnalyticsService.attractionViewed(activity.id);

    return GlassScreenScaffold(
      title: activity.title,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => context.pop(),
      ),
      padding: const EdgeInsets.all(AppSpacing.lg),
      body: ListView(
        children: [
          if (activity.latitude != null && activity.longitude != null)
            SizedBox(
              height: 180,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                child: GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: LatLng(activity.latitude!, activity.longitude!),
                    zoom: 15,
                  ),
                  markers: {
                    Marker(
                      markerId: MarkerId(activity.id),
                      position:
                          LatLng(activity.latitude!, activity.longitude!),
                    ),
                  },
                  zoomControlsEnabled: false,
                ),
              ),
            ),
          const SizedBox(height: AppSpacing.md),
          Text(activity.description, style: AppTypography.body),
          if (activity.address != null) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(activity.address!, style: AppTypography.bodySmall),
          ],
          const SizedBox(height: AppSpacing.md),
          GlassCard(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              children: [
                if (activity.openingHours != null)
                  _Row('Hours', activity.openingHours!),
                if (activity.rating > 0)
                  _Row('Rating', '${activity.rating} ★'),
                if (activity.entryFee > 0)
                  _Row('Entry', formatTripCurrency(activity.entryFee)),
                if (activity.estimatedCost > 0)
                  _Row('Est. cost', formatTripCurrency(activity.estimatedCost)),
                if (activity.cuisine != null)
                  _Row('Cuisine', activity.cuisine!),
                if (activity.halal)
                  _Row(TripStrings.t('trip_halal', locale), '✓'),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          if (activity.latitude != null && activity.longitude != null)
            GlassPrimaryButton(
              label: TripStrings.t('trip_navigate', locale),
              icon: Icons.directions,
              expand: true,
              onPressed: () async {
                final uri = Uri.parse(
                  'https://www.google.com/maps/dir/?api=1&destination=${activity.latitude},${activity.longitude}',
                );
                if (await canLaunchUrl(uri)) {
                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                }
              },
            ),
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row(this.label, this.value);
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxs),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTypography.bodySmall),
          Text(value, style: AppTypography.title),
        ],
      ),
    );
  }
}
