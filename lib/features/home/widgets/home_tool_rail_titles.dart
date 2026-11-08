import 'package:raabta/features/eosb/presentation/l10n/eosb_strings.dart';
import 'package:raabta/features/health_insurance/presentation/l10n/health_insurance_strings.dart';
import 'package:raabta/features/prayer_mosque/presentation/l10n/prayer_strings.dart';
import 'package:raabta/features/quick_actions/l10n/quick_actions_strings.dart';
import 'package:raabta/features/sponsorship_transfer/presentation/l10n/sponsorship_transfer_strings.dart';
import 'package:raabta/features/tenancy/presentation/l10n/tenancy_strings.dart';
import 'package:raabta/features/trip_planner/presentation/l10n/trip_strings.dart';

/// Localized card titles for Home tool rails keyed by quick-action route.
abstract final class HomeToolRailTitles {
  static String forRoute(String route, String locale) {
    return switch (route) {
      '/eosb' => EosbStrings.t('eosb_title', locale),
      '/health-insurance' => HealthInsuranceStrings.t('hi_title', locale),
      '/sponsorship-transfer' =>
        SponsorshipTransferStrings.t('st_title', locale),
      '/tenancy' => TenancyStrings.t('tenancy_title', locale),
      '/trip-planner' => TripStrings.t('trip_title', locale),
      '/prayer-mosque' => PrayerStrings.t('prayer_title', locale),
      '/climate-navigator' =>
        QuickActionsStrings.t('tool_climate_title', locale),
      '/queue-avoidance' => QuickActionsStrings.t('tool_queue_title', locale),
      '/arabic-companion' =>
        QuickActionsStrings.t('tool_arabic_companion_title', locale),
      '/know-qatar' => QuickActionsStrings.t('tool_know_qatar_title', locale),
      _ => '',
    };
  }
}
