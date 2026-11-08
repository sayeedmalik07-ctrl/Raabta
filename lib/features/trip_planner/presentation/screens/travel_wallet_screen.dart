import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:raabta/core/glass/glass_card.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/core/widgets/glass_empty_state.dart';
import 'package:raabta/core/widgets/glass_primary_button.dart';
import 'package:raabta/core/widgets/glass_screen_scaffold.dart';
import 'package:raabta/features/trip_planner/data/qatar_places_catalog.dart';
import 'package:raabta/features/trip_planner/domain/models/catalog_place.dart';
import 'package:raabta/features/trip_planner/presentation/l10n/trip_strings.dart';
import 'package:raabta/features/trip_planner/providers/trip_planner_providers.dart';

class TravelWalletScreen extends ConsumerWidget {
  const TravelWalletScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(tripPlannerProvider).preferences.locale;
    final state = ref.watch(tripPlannerProvider);
    final savedIds = ref.watch(savedPlacesProvider);
    final favoriteTrips =
        state.savedTrips.where((t) => t.isFavorite).toList();
    final savedPlaces = savedIds
        .map((id) => QatarPlacesCatalog.catalogById(id, locale))
        .whereType<CatalogPlace>()
        .toList();

    return GlassScreenScaffold(
      title: TripStrings.t('travel_wallet', locale),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => context.pop(),
      ),
      padding: const EdgeInsets.all(AppSpacing.lg),
      body: ListView(
        children: [
          GlassPrimaryButton(
            label: TripStrings.t('travel_document_vault', locale),
            icon: Icons.folder_outlined,
            expand: true,
            onPressed: () => context.push('/document-vault'),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            TripStrings.t('travel_saved_places', locale),
            style: AppTypography.title,
          ),
          const SizedBox(height: AppSpacing.sm),
          if (savedPlaces.isEmpty)
            GlassEmptyState(
              icon: Icons.bookmark_border,
              title: TripStrings.t('travel_no_saved_places', locale),
              description: TripStrings.t('travel_no_saved_places_desc', locale),
            )
          else
            ...savedPlaces.map(
              (p) => GlassCard(
                margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                onTap: () => context.push('/trip-planner/place/${p.id}'),
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Text(p.title, style: AppTypography.title),
              ),
            ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            TripStrings.t('trip_saved', locale),
            style: AppTypography.title,
          ),
          const SizedBox(height: AppSpacing.sm),
          if (favoriteTrips.isEmpty)
            Text(
              TripStrings.t('trip_empty_saved_desc', locale),
              style: AppTypography.bodySmall,
            )
          else
            ...favoriteTrips.map(
              (t) => GlassCard(
                margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                onTap: () => context.push('/trip-planner/itinerary/${t.id}'),
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Text(t.title, style: AppTypography.title),
              ),
            ),
        ],
      ),
    );
  }
}
