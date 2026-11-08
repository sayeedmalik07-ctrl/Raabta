import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/glass/glass_card.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/core/widgets/glass_progress_indicator.dart';
import 'package:raabta/core/widgets/glass_screen_scaffold.dart';
import 'package:raabta/features/prayer_mosque/presentation/l10n/prayer_strings.dart';
import 'package:raabta/features/prayer_mosque/presentation/prayer_destination_links.dart';
import 'package:raabta/features/prayer_mosque/presentation/widgets/prayer_time_card.dart';
import 'package:raabta/features/prayer_mosque/providers/prayer_providers.dart';
import 'package:raabta/features/prayer_mosque/services/prayer_analytics_service.dart';

/// Slim Islamic reference destination — not a multi-tab mini-app hub.
class PrayerDashboardScreen extends ConsumerStatefulWidget {
  const PrayerDashboardScreen({super.key});

  @override
  ConsumerState<PrayerDashboardScreen> createState() =>
      _PrayerDashboardScreenState();
}

class _PrayerDashboardScreenState extends ConsumerState<PrayerDashboardScreen> {
  @override
  void initState() {
    super.initState();
    PrayerAnalyticsService.dashboardVisit();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(prayerProvider);
    final locale = state.settings.locale;
    final content = ref.watch(prayerDailyContentProvider);
    final links = prayerDestinationLinks();

    return GlassScreenScaffold(
      title: PrayerStrings.t('prayer_companion_title', locale),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => context.pop(),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.search),
          onPressed: () => context.push('/prayer-mosque/search'),
        ),
        IconButton(
          icon: const Icon(Icons.settings_outlined),
          onPressed: () => context.push('/prayer-mosque/settings'),
        ),
      ],
      padding: const EdgeInsets.all(AppSpacing.lg),
      body: state.isLoading
          ? const Center(child: GlassProgressIndicator())
          : RefreshIndicator(
              onRefresh: () =>
                  ref.read(prayerProvider.notifier).refreshLocation(),
              child: ListView(
                children: [
                  Text(
                    PrayerStrings.t('prayer_destination_subtitle', locale),
                    style: AppTypography.bodySmall,
                  ),
                  if (state.error != null) ...[
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      PrayerStrings.t('prayer_offline', locale),
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.warning,
                      ),
                    ),
                  ],
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    PrayerStrings.t('prayer_destination_section', locale),
                    style: AppTypography.title,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  ...links.map(
                    (link) => Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                      child: GlassCard(
                        onTap: () => context.push(link.route),
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                          vertical: AppSpacing.sm,
                        ),
                        child: Row(
                          children: [
                            Icon(link.icon, color: AppColors.chipPrayer),
                            const SizedBox(width: AppSpacing.md),
                            Expanded(
                              child: Text(
                                prayerDestinationLabel(link.labelKey, locale),
                                style: AppTypography.body,
                              ),
                            ),
                            Icon(
                              Icons.chevron_right,
                              color: AppColors.textSecondary,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    PrayerStrings.t('prayer_daily_quote', locale),
                    style: AppTypography.subtitle,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  IslamicContentCard(
                    title: PrayerStrings.t('prayer_daily_quote', locale),
                    body: content.quote,
                    emoji: '✨',
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  IslamicContentCard(
                    title: PrayerStrings.t('prayer_daily_hadith', locale),
                    body: content.hadith,
                    emoji: '📖',
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  IslamicContentCard(
                    title: PrayerStrings.t('prayer_daily_dua', locale),
                    body: content.dua,
                    emoji: '🤲',
                  ),
                  if (content.verse.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.sm),
                    IslamicContentCard(
                      title: PrayerStrings.t('prayer_daily_verse', locale),
                      body: content.verse,
                      emoji: '📿',
                    ),
                  ],
                ],
              ),
            ),
    );
  }
}
