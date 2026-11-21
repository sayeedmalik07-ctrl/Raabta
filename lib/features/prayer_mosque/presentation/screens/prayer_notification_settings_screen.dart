import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/widgets/glass_primary_button.dart';
import 'package:raabta/core/widgets/glass_screen_scaffold.dart';
import 'package:raabta/features/prayer_mosque/domain/models/prayer_settings.dart';
import 'package:raabta/features/prayer_mosque/presentation/l10n/prayer_strings.dart';
import 'package:raabta/features/prayer_mosque/providers/prayer_providers.dart';
import 'package:raabta/features/prayer_mosque/services/prayer_notification_service.dart';

class PrayerNotificationSettingsScreen extends ConsumerWidget {
  const PrayerNotificationSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(prayerProvider);
    final settings = state.settings;
    final locale = settings.locale;
    final notifications = Map<String, bool>.from(
      settings.perPrayerNotifications.isEmpty
          ? PrayerSettings.defaultNotifications
          : settings.perPrayerNotifications,
    );

    return GlassScreenScaffold(
      title: PrayerStrings.t('prayer_notifications', locale),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => context.pop(),
      ),
      padding: const EdgeInsets.all(AppSpacing.lg),
      body: ListView(
        children: [
          GlassPrimaryButton(
            label: 'Enable notifications',
            icon: Icons.notifications_active,
            expand: true,
            accentColor: AppColors.chipPrayer,
            onPressed: () async {
              await PrayerNotificationService.requestPermission();
            },
          ),
          const SizedBox(height: AppSpacing.lg),
          ...notifications.entries.map(
            (e) => SwitchListTile(
              title: Text(PrayerStrings.t('prayer_${e.key}', locale)),
              value: e.value,
              onChanged: (v) async {
                notifications[e.key] = v;
                await ref.read(prayerProvider.notifier).updateSettings(
                      settings.copyWith(
                        perPrayerNotifications: notifications,
                      ),
                    );
              },
            ),
          ),
          SwitchListTile(
            title: const Text('Weekend only'),
            value: settings.weekendOnly,
            onChanged: (v) => ref.read(prayerProvider.notifier).updateSettings(
                  settings.copyWith(weekendOnly: v),
                ),
          ),
          SwitchListTile(
            title: Text(PrayerStrings.t('prayer_vacation', locale)),
            value: settings.vacationMode,
            onChanged: (v) => ref.read(prayerProvider.notifier).updateSettings(
                  settings.copyWith(vacationMode: v),
                ),
          ),
        ],
      ),
    );
  }
}
