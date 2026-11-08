import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/glass/glass_card.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/core/widgets/glass_primary_button.dart';
import 'package:raabta/core/widgets/glass_screen_scaffold.dart';
import 'package:raabta/features/prayer_mosque/presentation/l10n/prayer_strings.dart';
import 'package:raabta/features/prayer_mosque/providers/prayer_providers.dart';
import 'package:raabta/features/prayer_mosque/services/prayer_analytics_service.dart';
import 'package:raabta/features/prayer_mosque/services/prayer_navigation_service.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class MosqueDetailsScreen extends ConsumerWidget {
  const MosqueDetailsScreen({super.key, required this.mosqueId});

  final String mosqueId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(prayerProvider);
    final locale = state.settings.locale;
    final source = ref.watch(mosqueDataSourceProvider);
    final mosque = source.byId(mosqueId);

    if (mosque == null) {
      return GlassScreenScaffold(
        title: PrayerStrings.t('prayer_mosques', locale),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        body: const Center(child: Text('Mosque not found')),
      );
    }

    PrayerAnalyticsService.mosqueViewed(mosque.id);
    final isFavorite = state.favoriteIds.contains(mosque.id);

    return GlassScreenScaffold(
      title: mosque.name,
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
                  target: LatLng(mosque.latitude, mosque.longitude),
                  zoom: 15,
                ),
                markers: {
                  Marker(
                    markerId: MarkerId(mosque.id),
                    position: LatLng(mosque.latitude, mosque.longitude),
                  ),
                },
                zoomControlsEnabled: false,
                myLocationButtonEnabled: false,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          if (mosque.description.isNotEmpty)
            Text(mosque.description, style: AppTypography.body),
          const SizedBox(height: AppSpacing.sm),
          Text(mosque.address, style: AppTypography.bodySmall),
          if (mosque.jumuahTime != null) ...[
            const SizedBox(height: AppSpacing.md),
            GlassCard(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Row(
                children: [
                  const Icon(Icons.mosque, color: AppColors.tealGlow),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      "Jumu'ah: ${mosque.jumuahTime}",
                      style: AppTypography.title,
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.lg),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              GlassPrimaryButton(
                label: PrayerStrings.t('prayer_navigate', locale),
                onPressed: () => PrayerNavigationService.openDirections(
                  latitude: mosque.latitude,
                  longitude: mosque.longitude,
                  app: ref.read(prayerProvider).settings.navigationApp,
                ),
                icon: Icons.directions,
              ),
              GlassPrimaryButton(
                label: isFavorite
                    ? PrayerStrings.t('prayer_favorites', locale)
                    : PrayerStrings.t('prayer_save', locale),
                onPressed: () =>
                    ref.read(prayerProvider.notifier).toggleFavorite(mosque.id),
                icon: isFavorite ? Icons.favorite : Icons.favorite_border,
              ),
              if (mosque.phone != null)
                GlassPrimaryButton(
                  label: PrayerStrings.t('prayer_call', locale),
                  onPressed: () => launchUrl(Uri.parse('tel:${mosque.phone}')),
                  icon: Icons.phone,
                ),
              GlassPrimaryButton(
                label: PrayerStrings.t('prayer_share', locale),
                onPressed: () => Share.share(
                  '${mosque.name}\n${mosque.address}\n'
                  'https://maps.google.com/?q=${mosque.latitude},${mosque.longitude}',
                ),
                icon: Icons.share,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
