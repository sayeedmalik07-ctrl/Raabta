import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:raabta/core/glass/glass_card.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/core/widgets/glass_screen_scaffold.dart';
import 'package:raabta/core/widgets/glass_text_field.dart';
import 'package:raabta/features/prayer_mosque/domain/models/mosque.dart';
import 'package:raabta/features/prayer_mosque/services/prayer_navigation_service.dart';
import 'package:raabta/features/prayer_mosque/presentation/l10n/prayer_strings.dart';
import 'package:raabta/features/prayer_mosque/presentation/widgets/mosque_card.dart';
import 'package:raabta/features/prayer_mosque/providers/prayer_providers.dart';

class TravelPrayerScreen extends ConsumerWidget {
  const TravelPrayerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(prayerProvider);
    final locale = state.settings.locale;
    final prayerRooms = state.mosques
        .where((m) => m.type == MosqueType.prayerHall)
        .take(5)
        .toList();

    return GlassScreenScaffold(
      title: PrayerStrings.t('prayer_travel', locale),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => context.pop(),
      ),
      padding: const EdgeInsets.all(AppSpacing.lg),
      body: ListView(
        children: [
          GlassCard(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  PrayerStrings.t('prayer_travel_guide', locale),
                  style: AppTypography.title,
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  PrayerStrings.t('prayer_travel_body', locale),
                  style: AppTypography.bodySmall,
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            PrayerStrings.t('prayer_rooms_nearby', locale),
            style: AppTypography.title,
          ),
          const SizedBox(height: AppSpacing.sm),
          if (prayerRooms.isEmpty)
            Text(
              PrayerStrings.t('prayer_no_rooms', locale),
              style: AppTypography.bodySmall,
            )
          else
            ...prayerRooms.map(
              (m) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: MosqueCard(
                  mosque: m,
                  locale: locale,
                  isFavorite: state.favoriteIds.contains(m.id),
                  onTap: () => context.push('/prayer-mosque/mosque/${m.id}'),
                  onFavorite: () =>
                      ref.read(prayerProvider.notifier).toggleFavorite(m.id),
                  onDirections: () =>
                      PrayerNavigationService.openDirections(
                    latitude: m.latitude,
                    longitude: m.longitude,
                    app: state.settings.navigationApp,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class PrayerSearchScreen extends ConsumerStatefulWidget {
  const PrayerSearchScreen({super.key});

  @override
  ConsumerState<PrayerSearchScreen> createState() =>
      _PrayerSearchScreenState();
}

class _PrayerSearchScreenState extends ConsumerState<PrayerSearchScreen> {
  final _queryController = TextEditingController();

  @override
  void dispose() {
    _queryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(prayerProvider);
    final locale = state.settings.locale;

    return GlassScreenScaffold(
      title: PrayerStrings.t('prayer_search', locale),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => context.pop(),
      ),
      padding: const EdgeInsets.all(AppSpacing.lg),
      body: Column(
        children: [
          GlassTextField(
            controller: _queryController,
            icon: Icons.search,
            hint: PrayerStrings.t('prayer_search_hint', locale),
            onChanged: (q) =>
                ref.read(prayerProvider.notifier).searchMosques(q),
          ),
          const SizedBox(height: AppSpacing.md),
          Expanded(
            child: ListView.builder(
              itemCount: state.mosques.length,
              itemBuilder: (context, index) {
                final mosque = state.mosques[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: MosqueCard(
                    mosque: mosque,
                    locale: locale,
                    isFavorite: state.favoriteIds.contains(mosque.id),
                    onTap: () =>
                        context.push('/prayer-mosque/mosque/${mosque.id}'),
                    onFavorite: () => ref
                        .read(prayerProvider.notifier)
                        .toggleFavorite(mosque.id),
                    onDirections: () =>
                        PrayerNavigationService.openDirections(
                      latitude: mosque.latitude,
                      longitude: mosque.longitude,
                      app: state.settings.navigationApp,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
