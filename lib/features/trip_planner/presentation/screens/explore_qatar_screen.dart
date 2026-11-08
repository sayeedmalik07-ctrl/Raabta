import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/glass/glass_card.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/core/widgets/glass_screen_scaffold.dart';
import 'package:raabta/features/trip_planner/data/qatar_places_catalog.dart';
import 'package:raabta/features/trip_planner/domain/models/catalog_place.dart';
import 'package:raabta/features/trip_planner/presentation/l10n/trip_strings.dart';
import 'package:raabta/features/trip_planner/providers/trip_planner_providers.dart';

class ExploreQatarScreen extends ConsumerWidget {
  const ExploreQatarScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(tripPlannerProvider).preferences.locale;

    return GlassScreenScaffold(
      title: TripStrings.t('travel_explore', locale),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => context.pop(),
      ),
      padding: const EdgeInsets.all(AppSpacing.lg),
      body: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: AppSpacing.sm,
          crossAxisSpacing: AppSpacing.sm,
          childAspectRatio: 1.15,
        ),
        itemCount: ExploreCategory.values.length,
        itemBuilder: (context, i) {
          final cat = ExploreCategory.values[i];
          final count = QatarPlacesCatalog.placesForCategory(cat, locale).length;
          return GlassCard(
            onTap: () => context.push('/trip-planner/explore/${cat.name}'),
            padding: const EdgeInsets.all(AppSpacing.md),
            glowColor: AppColors.chipTrip,
            glowIntensity: 0.08,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(cat.emoji, style: const TextStyle(fontSize: 28)),
                const Spacer(),
                Text(
                  TripStrings.t(cat.titleKey, locale),
                  style: AppTypography.caption.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 2,
                ),
                Text(
                  '$count places',
                  style: AppTypography.caption,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class ExploreCategoryScreen extends ConsumerWidget {
  const ExploreCategoryScreen({super.key, required this.categoryName});

  final String categoryName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(tripPlannerProvider).preferences.locale;
    final category = ExploreCategory.values.firstWhere(
      (c) => c.name == categoryName,
      orElse: () => ExploreCategory.topAttractions,
    );
    final places = QatarPlacesCatalog.placesForCategory(category, locale);

    return GlassScreenScaffold(
      title: TripStrings.t(category.titleKey, locale),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => context.pop(),
      ),
      padding: const EdgeInsets.all(AppSpacing.lg),
      body: ListView.separated(
        itemCount: places.length,
        separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
        itemBuilder: (context, i) {
          final place = places[i];
          return GlassCard(
            onTap: () => context.push('/trip-planner/place/${place.id}'),
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(place.title, style: AppTypography.title),
                      const SizedBox(height: 4),
                      Text(
                        place.description,
                        style: AppTypography.bodySmall,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '★ ${place.rating.toStringAsFixed(1)} · '
                        '${place.durationMinutes} min',
                        style: AppTypography.caption.copyWith(
                          color: AppColors.accentGold,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right),
              ],
            ),
          );
        },
      ),
    );
  }
}
