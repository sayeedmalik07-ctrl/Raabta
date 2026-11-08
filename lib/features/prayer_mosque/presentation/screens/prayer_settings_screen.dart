import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/glass/glass_card.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/core/widgets/glass_screen_scaffold.dart';
import 'package:raabta/features/prayer_mosque/domain/models/prayer_enums.dart';
import 'package:raabta/features/prayer_mosque/presentation/l10n/prayer_strings.dart';
import 'package:raabta/features/prayer_mosque/providers/prayer_providers.dart';
import 'package:raabta/features/prayer_mosque/services/prayer_location_service.dart';

class PrayerSettingsScreen extends ConsumerWidget {
  const PrayerSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(prayerProvider);
    final settings = state.settings;
    final locale = settings.locale;

    return GlassScreenScaffold(
      title: PrayerStrings.t('prayer_settings', locale),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => context.pop(),
      ),
      padding: const EdgeInsets.all(AppSpacing.lg),
      body: ListView(
        children: [
          _Section(
            title: PrayerStrings.t('prayer_method', locale),
            child: DropdownButtonFormField<PrayerCalculationMethod>(
              initialValue: settings.calculationMethod,
              items: PrayerCalculationMethod.values
                  .map(
                    (m) => DropdownMenuItem(
                      value: m,
                      child: Text(_methodLabel(m, locale)),
                    ),
                  )
                  .toList(),
              onChanged: (v) async {
                if (v == null) return;
                await ref.read(prayerProvider.notifier).updateSettings(
                      settings.copyWith(calculationMethod: v),
                    );
              },
            ),
          ),
          _Section(
            title: PrayerStrings.t('prayer_madhab', locale),
            child: DropdownButtonFormField<PrayerMadhab>(
              initialValue: settings.madhab,
              items: PrayerMadhab.values
                  .map(
                    (m) => DropdownMenuItem(
                      value: m,
                      child: Text(_madhabLabel(m, locale)),
                    ),
                  )
                  .toList(),
              onChanged: (v) async {
                if (v == null) return;
                await ref.read(prayerProvider.notifier).updateSettings(
                      settings.copyWith(madhab: v),
                    );
              },
            ),
          ),
          _GlassSwitchTile(
            title: PrayerStrings.t('prayer_auto_location', locale),
            value: settings.autoLocation,
            onChanged: (v) => ref.read(prayerProvider.notifier).updateSettings(
                  settings.copyWith(autoLocation: v),
                ),
          ),
          if (!settings.autoLocation)
            _Section(
              title: PrayerStrings.t('prayer_manual_city', locale),
              child: DropdownButtonFormField<String>(
                initialValue: settings.manualCity,
                items: prayerCityPresets
                    .map(
                      (c) => DropdownMenuItem(
                        value: PrayerStrings.t(c.nameKey, locale),
                        child: Text(PrayerStrings.t(c.nameKey, locale)),
                      ),
                    )
                    .toList(),
                onChanged: (v) async {
                  if (v == null) return;
                  final preset = prayerCityPresets.firstWhere(
                    (c) => PrayerStrings.t(c.nameKey, locale) == v,
                  );
                  await ref.read(prayerProvider.notifier).updateSettings(
                        settings.copyWith(
                          manualCity: v,
                          manualLatitude: preset.latitude,
                          manualLongitude: preset.longitude,
                        ),
                      );
                },
              ),
            ),
          _GlassSwitchTile(
            title: PrayerStrings.t('prayer_vacation', locale),
            value: settings.vacationMode,
            onChanged: (v) => ref.read(prayerProvider.notifier).updateSettings(
                  settings.copyWith(vacationMode: v),
                ),
          ),
          _GlassListTile(
            title: PrayerStrings.t('prayer_time_format', locale),
            trailing: DropdownButton<PrayerTimeFormat>(
              value: settings.timeFormat,
              items: const [
                DropdownMenuItem(
                  value: PrayerTimeFormat.hour12,
                  child: Text('12h'),
                ),
                DropdownMenuItem(
                  value: PrayerTimeFormat.hour24,
                  child: Text('24h'),
                ),
              ],
              onChanged: (v) async {
                if (v == null) return;
                await ref.read(prayerProvider.notifier).updateSettings(
                      settings.copyWith(timeFormat: v),
                    );
              },
            ),
          ),
          _GlassListTile(
            title: PrayerStrings.t('prayer_nav_app', locale),
            trailing: DropdownButton<NavigationMapsApp>(
              value: settings.navigationApp,
              items: NavigationMapsApp.values
                  .map(
                    (app) => DropdownMenuItem(
                      value: app,
                      child: Text(_navAppLabel(app, locale)),
                    ),
                  )
                  .toList(),
              onChanged: (v) async {
                if (v == null) return;
                await ref.read(prayerProvider.notifier).updateSettings(
                      settings.copyWith(navigationApp: v),
                    );
              },
            ),
          ),
          _GlassListTile(
            title: PrayerStrings.t('prayer_notifications', locale),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/prayer-mosque/notifications'),
          ),
        ],
      ),
    );
  }

  String _methodLabel(PrayerCalculationMethod m, String locale) {
    switch (m) {
      case PrayerCalculationMethod.ummAlQura:
        return PrayerStrings.t('method_umm_al_qura', locale);
      case PrayerCalculationMethod.muslimWorldLeague:
        return PrayerStrings.t('method_mwl', locale);
      case PrayerCalculationMethod.qatarCalendarHouse:
        return PrayerStrings.t('method_qatar', locale);
      case PrayerCalculationMethod.isna:
        return PrayerStrings.t('method_isna', locale);
    }
  }

  String _madhabLabel(PrayerMadhab m, String locale) {
    switch (m) {
      case PrayerMadhab.hanafi:
        return PrayerStrings.t('madhab_hanafi', locale);
      case PrayerMadhab.shafi:
        return PrayerStrings.t('madhab_shafi', locale);
    }
  }

  String _navAppLabel(NavigationMapsApp app, String locale) {
    switch (app) {
      case NavigationMapsApp.googleMaps:
        return PrayerStrings.t('nav_google_maps', locale);
      case NavigationMapsApp.appleMaps:
        return PrayerStrings.t('nav_apple_maps', locale);
      case NavigationMapsApp.waze:
        return PrayerStrings.t('nav_waze', locale);
    }
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: GlassCard(
        padding: const EdgeInsets.all(AppSpacing.md),
        glowColor: AppColors.chipPrayer,
        glowIntensity: 0.08,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: AppTypography.caption.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            child,
          ],
        ),
      ),
    );
  }
}

class _GlassSwitchTile extends StatelessWidget {
  const _GlassSwitchTile({
    required this.title,
    required this.value,
    required this.onChanged,
  });

  final String title;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: GlassCard(
        padding: EdgeInsets.zero,
        glowColor: AppColors.chipPrayer,
        glowIntensity: 0.06,
        child: Material(
          color: Colors.transparent,
          child: SwitchListTile(
            title: Text(title, style: AppTypography.body),
            value: value,
            onChanged: onChanged,
          ),
        ),
      ),
    );
  }
}

class _GlassListTile extends StatelessWidget {
  const _GlassListTile({
    required this.title,
    this.trailing,
    this.onTap,
  });

  final String title;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: GlassCard(
        padding: EdgeInsets.zero,
        glowColor: AppColors.chipPrayer,
        glowIntensity: 0.06,
        child: Material(
          color: Colors.transparent,
          child: ListTile(
            title: Text(title, style: AppTypography.body),
            trailing: trailing,
            onTap: onTap,
          ),
        ),
      ),
    );
  }
}
