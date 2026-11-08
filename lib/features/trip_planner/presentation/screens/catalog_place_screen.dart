import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/glass/glass_card.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/core/widgets/glass_empty_state.dart';
import 'package:raabta/core/widgets/ai_suggestion_card.dart';
import 'package:raabta/core/widgets/glass_primary_button.dart';
import 'package:raabta/features/know_qatar/presentation/l10n/know_qatar_strings.dart';
import 'package:raabta/features/know_qatar/presentation/screens/know_qatar_screen.dart';
import 'package:raabta/core/widgets/glass_screen_scaffold.dart';
import 'package:raabta/core/widgets/glass_tag.dart';
import 'package:raabta/features/trip_planner/data/qatar_places_catalog.dart';
import 'package:raabta/features/trip_planner/domain/models/catalog_place.dart';
import 'package:raabta/features/trip_planner/presentation/l10n/trip_strings.dart';
import 'package:raabta/features/trip_planner/providers/trip_planner_providers.dart';
import 'package:url_launcher/url_launcher.dart';

class CatalogPlaceScreen extends ConsumerWidget {
  const CatalogPlaceScreen({super.key, required this.placeId});

  final String placeId;

  Future<void> _openMaps(CatalogPlace place) async {
    final uri = Uri.parse(
      'https://www.google.com/maps/dir/?api=1'
      '&destination=${place.lat},${place.lng}',
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(tripPlannerProvider).preferences.locale;
    final place = QatarPlacesCatalog.catalogById(placeId, locale);
    final saved = ref.watch(savedPlacesProvider);
    final isSaved = saved.contains(placeId);

    if (place == null) {
      return GlassScreenScaffold(
        title: TripStrings.t('trip_attraction', locale),
        body: GlassEmptyState(
          icon: Icons.place_outlined,
          title: TripStrings.t('trip_place_not_found', locale),
          description: TripStrings.t('trip_place_not_in_catalog', locale),
        ),
      );
    }

    return GlassScreenScaffold(
      title: place.title,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => context.pop(),
      ),
      padding: const EdgeInsets.all(AppSpacing.lg),
      body: ListView(
        children: [
          SizedBox(
            height: 180,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              child: GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: LatLng(place.lat, place.lng),
                  zoom: 14,
                ),
                markers: {
                  Marker(
                    markerId: MarkerId(place.id),
                    position: LatLng(place.lat, place.lng),
                  ),
                },
                zoomControlsEnabled: false,
                myLocationButtonEnabled: false,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              Text(
                '★ ${place.rating.toStringAsFixed(1)}',
                style: AppTypography.title.copyWith(
                  color: AppColors.accentGold,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              if (place.familyFriendly)
                GlassTag(
                  label: TripStrings.t('travel_family', locale),
                  accentColor: AppColors.chipTrip,
                  margin: const EdgeInsets.only(right: AppSpacing.xs),
                ),
              if (place.wheelchairAccessible)
                GlassTag(
                  label: TripStrings.t('travel_accessible', locale),
                  accentColor: AppColors.chipTrip,
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(place.description, style: AppTypography.body),
          const SizedBox(height: AppSpacing.md),
          AISuggestionCard(
            title: KnowQatarStrings.t('kq_section_cities_title', locale),
            description: KnowQatarStrings.t('kq_trip_learn_link', locale),
            icon: Icons.public_outlined,
            accentColor: AppColors.cyanGlow,
            actionLabel: KnowQatarStrings.t('kq_trip_learn_link', locale),
            onTap: () => context.push(
              KnowQatarScreen.route(sectionKey: 'cities_regions'),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          GlassCard(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (place.openingHours != null)
                  _InfoRow(Icons.schedule, place.openingHours!),
                if (place.address != null)
                  _InfoRow(Icons.location_on_outlined, place.address!),
                _InfoRow(
                  Icons.timer_outlined,
                  '${place.durationMinutes} min visit',
                ),
                if (place.bestVisitTime != null)
                  _InfoRow(Icons.wb_sunny_outlined, place.bestVisitTime!),
                if (place.entryFee > 0)
                  _InfoRow(
                    Icons.confirmation_number_outlined,
                    formatTripCurrency(place.entryFee),
                  )
                else if (place.estimatedMeal > 0)
                  _InfoRow(
                    Icons.restaurant,
                    '~${formatTripCurrency(place.estimatedMeal)} / meal',
                  )
                else
                  _InfoRow(Icons.check_circle_outline, 'Free entry'),
                if (place.cuisine != null)
                  _InfoRow(Icons.restaurant_menu, place.cuisine!),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              Expanded(
                child: GlassPrimaryButton(
                  label: TripStrings.t('trip_navigate', locale),
                  icon: Icons.navigation_outlined,
                  onPressed: () => _openMaps(place),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              IconButton(
                icon: Icon(
                  isSaved ? Icons.bookmark : Icons.bookmark_border,
                  color: AppColors.chipTrip,
                ),
                onPressed: () => ref
                    .read(savedPlacesProvider.notifier)
                    .toggle(placeId),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow(this.icon, this.text);
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppColors.chipTrip),
          const SizedBox(width: AppSpacing.sm),
          Expanded(child: Text(text, style: AppTypography.bodySmall)),
        ],
      ),
    );
  }
}
