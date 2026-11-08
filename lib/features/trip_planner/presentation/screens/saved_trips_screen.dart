import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:raabta/core/glass/glass_card.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/core/widgets/glass_empty_state.dart';
import 'package:raabta/core/widgets/glass_screen_scaffold.dart';
import 'package:raabta/features/trip_planner/domain/models/trip_plan.dart';
import 'package:raabta/features/trip_planner/presentation/l10n/trip_strings.dart';
import 'package:raabta/features/trip_planner/providers/trip_planner_providers.dart';

class SavedTripsScreen extends ConsumerWidget {
  const SavedTripsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(tripPlannerProvider);
    final locale = state.preferences.locale;
    final trips = state.savedTrips;

    return GlassScreenScaffold(
      title: TripStrings.t('trip_saved', locale),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => context.pop(),
      ),
      padding: const EdgeInsets.all(AppSpacing.lg),
      body: trips.isEmpty
          ? GlassEmptyState(
              icon: Icons.map_outlined,
              title: TripStrings.t('trip_empty_saved', locale),
              description: TripStrings.t('trip_empty_saved_desc', locale),
              actionLabel: TripStrings.t('trip_generate', locale),
              onAction: () => context.go('/trip-planner'),
            )
          : ListView.separated(
              itemCount: trips.length,
              separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
              itemBuilder: (context, index) {
                final trip = trips[index];
                return GlassCard(
                  onTap: () {
                    ref.read(tripPlannerProvider.notifier).setActiveTrip(trip);
                    context.push('/trip-planner/itinerary/${trip.id}');
                  },
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(trip.title, style: AppTypography.title),
                            Text(
                              '${trip.totalDays} days · '
                              '${formatTripCurrency(trip.budget.totalSpent, symbol: trip.preferences.currency)}',
                              style: AppTypography.bodySmall,
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        tooltip: TripStrings.t('trip_duplicate', locale),
                        icon: const Icon(Icons.copy_outlined),
                        onPressed: () async {
                          final copy = await ref
                              .read(tripPlannerProvider.notifier)
                              .duplicateTrip(trip.id);
                          if (copy != null && context.mounted) {
                            context.push('/trip-planner/itinerary/${copy.id}');
                          }
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline),
                        onPressed: () => ref
                            .read(tripPlannerProvider.notifier)
                            .deleteTrip(trip.id),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}

class SharedTripScreen extends ConsumerWidget {
  const SharedTripScreen({super.key, required this.shareCode});

  final String shareCode;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(tripPlannerProvider);
    final locale = state.preferences.locale;
    TripPlan? trip;
    for (final t in state.savedTrips) {
      if (t.shareCode?.toUpperCase() == shareCode.toUpperCase()) {
        trip = t;
        break;
      }
    }

    return GlassScreenScaffold(
      title: TripStrings.t('trip_share', locale),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => context.pop(),
      ),
      padding: const EdgeInsets.all(AppSpacing.lg),
      body: trip == null
          ? Center(
              child: Text(
                TripStrings.format(
                  'trip_share_code_not_found',
                  locale,
                  {'code': shareCode},
                ),
              ),
            )
          : ListView(
              children: [
                Text(trip.title, style: AppTypography.headline2),
                Text(
                  TripStrings.format(
                    'trip_share_code_label',
                    locale,
                    {'code': trip.shareCode ?? ''},
                  ),
                ),
                ListTile(
                  title: Text(
                    TripStrings.t('trip_open_full_itinerary', locale),
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () =>
                      context.push('/trip-planner/itinerary/${trip!.id}'),
                ),
              ],
            ),
    );
  }
}

class TripSettingsScreen extends ConsumerWidget {
  const TripSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(tripPlannerProvider);
    final locale = state.preferences.locale;

    return GlassScreenScaffold(
      title: TripStrings.t('trip_settings', locale),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => context.pop(),
      ),
      padding: const EdgeInsets.all(AppSpacing.lg),
      body: ListView(
        children: [
          ListTile(
            title: Text(TripStrings.t('trip_default_language', locale)),
            subtitle: Text(locale),
          ),
          ListTile(
            title: Text(TripStrings.t('trip_default_currency', locale)),
            subtitle: Text(state.preferences.currency),
          ),
        ],
      ),
    );
  }
}
