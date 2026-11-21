import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:raabta/core/glass/glass_card.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/core/widgets/glass_screen_scaffold.dart';
import 'package:raabta/features/prayer_mosque/domain/models/prayer_enums.dart';
import 'package:raabta/features/prayer_mosque/presentation/l10n/prayer_strings.dart';
import 'package:raabta/features/prayer_mosque/providers/prayer_providers.dart';
import 'package:raabta/features/prayer_mosque/services/prayer_analytics_service.dart';

class JumuahReminderScreen extends ConsumerWidget {
  const JumuahReminderScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(prayerProvider);
    final locale = state.settings.locale;
    final favoriteMosque = state.settings.favoriteMosqueId != null
        ? ref
            .watch(mosqueDataSourceProvider)
            .byId(state.settings.favoriteMosqueId!)
        : null;

    return GlassScreenScaffold(
      title: PrayerStrings.t('prayer_jumuah', locale),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => context.pop(),
      ),
      padding: const EdgeInsets.all(AppSpacing.lg),
      body: ListView(
        children: [
          GlassCard(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  PrayerStrings.t('prayer_jumuah_reminders_title', locale),
                  style: AppTypography.title,
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  favoriteMosque != null
                      ? PrayerStrings.t('prayer_jumuah_favorite', locale)
                          .replaceAll('{name}', favoriteMosque.name)
                      : PrayerStrings.t('prayer_jumuah_pick_favorite', locale),
                  style: AppTypography.bodySmall,
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          ...JumuahReminderOffset.values.map((offset) {
            final selected = state.settings.jumuahReminderOffset == offset;
            return Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: GlassCard(
                onTap: () async {
                  PrayerAnalyticsService.reminderSet(offset.name);
                  await ref.read(prayerProvider.notifier).updateSettings(
                        state.settings.copyWith(
                          jumuahReminderOffset: offset,
                        ),
                      );
                },
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Row(
                  children: [
                    Icon(
                      selected
                          ? Icons.radio_button_checked
                          : Icons.radio_button_off,
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Text(
                      _offsetLabel(offset, locale),
                      style: AppTypography.body,
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  static String _offsetLabel(JumuahReminderOffset offset, String locale) {
    switch (offset) {
      case JumuahReminderOffset.oneHour:
        return PrayerStrings.t('jumuah_offset_one_hour', locale);
      case JumuahReminderOffset.thirtyMinutes:
        return PrayerStrings.t('jumuah_offset_thirty_min', locale);
      case JumuahReminderOffset.fifteenMinutes:
        return PrayerStrings.t('jumuah_offset_fifteen_min', locale);
      case JumuahReminderOffset.custom:
        return PrayerStrings.t('jumuah_offset_custom', locale);
    }
  }
}
