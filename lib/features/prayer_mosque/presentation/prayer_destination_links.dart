import 'package:flutter/material.dart';
import 'package:raabta/features/ramadan/l10n/zakat_strings.dart';
import 'package:raabta/features/ramadan/ramadan_season.dart';
import 'package:raabta/features/prayer_mosque/presentation/l10n/prayer_strings.dart';

/// Slim destination links for `/prayer-mosque` — not a mini-app nav grid.
class PrayerDestinationLink {
  const PrayerDestinationLink({
    required this.labelKey,
    required this.icon,
    required this.route,
    this.useZakatStrings = false,
  });

  final String labelKey;
  final IconData icon;
  final String route;
  final bool useZakatStrings;
}

/// Reference and tool destinations — excludes duplicate hub tiles.
List<PrayerDestinationLink> prayerDestinationLinks({DateTime? reference}) {
  return [
    const PrayerDestinationLink(
      labelKey: 'prayer_times',
      icon: Icons.schedule,
      route: '/prayer-mosque/times',
    ),
    const PrayerDestinationLink(
      labelKey: 'prayer_qibla',
      icon: Icons.explore,
      route: '/prayer-mosque/qibla',
    ),
    const PrayerDestinationLink(
      labelKey: 'prayer_mosques',
      icon: Icons.mosque_outlined,
      route: '/prayer-mosque/mosques',
    ),
    const PrayerDestinationLink(
      labelKey: 'prayer_calendar',
      icon: Icons.calendar_month,
      route: '/prayer-mosque/calendar',
    ),
    const PrayerDestinationLink(
      labelKey: 'prayer_jumuah',
      icon: Icons.notifications_active,
      route: '/prayer-mosque/jumuah',
    ),
    const PrayerDestinationLink(
      labelKey: 'prayer_ai',
      icon: Icons.auto_awesome,
      route: '/prayer-mosque/assistant',
    ),
    const PrayerDestinationLink(
      labelKey: 'prayer_travel',
      icon: Icons.flight,
      route: '/prayer-mosque/travel',
    ),
    const PrayerDestinationLink(
      labelKey: 'prayer_history',
      icon: Icons.history,
      route: '/prayer-mosque/history',
    ),
    const PrayerDestinationLink(
      labelKey: 'prayer_notifications',
      icon: Icons.notifications_outlined,
      route: '/prayer-mosque/notifications',
    ),
    const PrayerDestinationLink(
      labelKey: 'prayer_settings',
      icon: Icons.settings_outlined,
      route: '/prayer-mosque/settings',
    ),
    if (RamadanSeason.isSeasonalPeriod(reference))
      const PrayerDestinationLink(
        labelKey: 'prayer_ramadan',
        icon: Icons.nightlight_round,
        route: '/ramadan',
      ),
    if (RamadanSeason.isSeasonalPeriod(reference))
      const PrayerDestinationLink(
        labelKey: 'zakat_title',
        icon: Icons.volunteer_activism_outlined,
        route: '/ramadan/zakat',
        useZakatStrings: true,
      ),
  ];
}

String prayerDestinationLabel(String labelKey, String locale) {
  if (labelKey == 'zakat_title') {
    return ZakatStrings.t('zakat_title', locale);
  }
  return PrayerStrings.t(labelKey, locale);
}

/// @deprecated Use [prayerDestinationLinks] — kept for test migration only.
@Deprecated('Use prayerDestinationLinks')
List<(String labelKey, IconData icon, String route)> prayerDashboardNavItems({
  DateTime? reference,
}) {
  return prayerDestinationLinks(reference: reference)
      .map((l) => (l.labelKey, l.icon, l.route))
      .toList();
}
