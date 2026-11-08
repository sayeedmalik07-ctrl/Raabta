import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/core/widgets/glass_empty_state.dart';
import 'package:raabta/core/widgets/glass_progress_indicator.dart';
import 'package:raabta/core/widgets/glass_screen_scaffold.dart';
import 'package:raabta/core/widgets/glass_tag.dart';
import 'package:raabta/core/widgets/glass_text_field.dart';
import 'package:raabta/features/prayer_mosque/presentation/l10n/prayer_strings.dart';
import 'package:raabta/features/prayer_mosque/presentation/widgets/live_location_banner.dart';
import 'package:raabta/features/prayer_mosque/presentation/widgets/mosque_card.dart';
import 'package:raabta/features/prayer_mosque/providers/prayer_providers.dart';
import 'package:raabta/features/prayer_mosque/services/prayer_analytics_service.dart';
import 'package:raabta/features/prayer_mosque/services/prayer_navigation_service.dart';

class NearbyMosquesScreen extends ConsumerStatefulWidget {
  const NearbyMosquesScreen({super.key});

  @override
  ConsumerState<NearbyMosquesScreen> createState() =>
      _NearbyMosquesScreenState();
}

class _NearbyMosquesScreenState extends ConsumerState<NearbyMosquesScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _refreshLocation() async {
    await ref.read(prayerProvider.notifier).refreshLocation();
    if (!mounted) return;
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(prayerProvider);
    final locale = state.settings.locale;
    final favorites = ref.watch(favoriteMosquesProvider);

    return GlassScreenScaffold(
      title: PrayerStrings.t('prayer_mosques', locale),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => context.pop(),
      ),
      actions: [
        IconButton(
          tooltip: PrayerStrings.t('prayer_refresh_location', locale),
          icon: state.isLoading
              ? const GlassProgressIndicator(size: 20, strokeWidth: 2)
              : const Icon(Icons.my_location),
          onPressed: state.isLoading ? null : _refreshLocation,
        ),
      ],
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      body: Column(
        children: [
          LiveLocationBanner(
            locale: locale,
            isActive: state.isLiveLocationActive,
            location: state.location,
            locationUpdatedAt: state.locationUpdatedAt,
            onRefresh: _refreshLocation,
          ),
          const SizedBox(height: AppSpacing.sm),
          GlassTextField(
            controller: _searchController,
            icon: Icons.search,
            hint: PrayerStrings.t('prayer_search_hint', locale),
            suffix: IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () {
                _searchController.clear();
                ref.read(prayerProvider.notifier).searchMosques('');
              },
            ),
            onSubmitted: ref.read(prayerProvider.notifier).searchMosques,
          ),
          if (favorites.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sm),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                PrayerStrings.t('prayer_favorites', locale),
                style: AppTypography.bodySmall.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xxs),
            SizedBox(
              height: 36,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  for (final m in favorites)
                    Padding(
                      padding: const EdgeInsets.only(right: AppSpacing.sm),
                      child: GlassTag(
                        label: m.name,
                        accentColor: AppColors.chipPrayer,
                        onTap: () =>
                            context.push('/prayer-mosque/mosque/${m.id}'),
                      ),
                    ),
                ],
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.sm),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _refreshLocation,
              child: state.mosques.isEmpty
                  ? ListView(
                      children: [
                        SizedBox(
                          height: MediaQuery.sizeOf(context).height * 0.35,
                          child: GlassEmptyState(
                            icon: Icons.mosque_outlined,
                            title: PrayerStrings.t(
                              'prayer_empty_mosques',
                              locale,
                            ),
                            description: PrayerStrings.t(
                              'prayer_empty_mosques_desc',
                              locale,
                            ),
                          ),
                        ),
                      ],
                    )
                  : ListView.separated(
                      itemCount: state.mosques.length,
                      separatorBuilder: (_, _) =>
                          const SizedBox(height: AppSpacing.sm),
                      itemBuilder: (context, index) {
                        final mosque = state.mosques[index];
                        PrayerAnalyticsService.mosqueViewed(mosque.id);
                        return MosqueCard(
                          mosque: mosque,
                          locale: locale,
                          isFavorite:
                              state.favoriteIds.contains(mosque.id),
                          onTap: () => context.push(
                            '/prayer-mosque/mosque/${mosque.id}',
                          ),
                          onFavorite: () async {
                            await ref
                                .read(prayerProvider.notifier)
                                .toggleFavorite(mosque.id);
                            await ref
                                .read(prayerProvider.notifier)
                                .updateSettings(
                                  ref.read(prayerProvider).settings.copyWith(
                                        favoriteMosqueId: mosque.id,
                                      ),
                                );
                          },
                          onDirections: () =>
                              PrayerNavigationService.openDirections(
                            latitude: mosque.latitude,
                            longitude: mosque.longitude,
                            app: ref
                                .read(prayerProvider)
                                .settings
                                .navigationApp,
                          ),
                        );
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
