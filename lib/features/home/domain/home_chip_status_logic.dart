import 'package:raabta/features/home/domain/home_chip_status.dart';
import 'package:raabta/features/home/l10n/home_chip_status_strings.dart';
import 'package:raabta/features/quick_actions/climate_navigator/l10n/climate_strings.dart';

/// Pure resolution of micro-lines from already-loaded facts (no I/O).
abstract final class HomeChipStatusLogic {
  static HomeChipStatus forRoute({
    required String route,
    required String locale,
    bool eosbHasSavedEstimate = false,
    bool tenancyCheckCompleted = false,
    bool healthPolicyChecked = false,
    int warrantyExpiringCount = 0,
    String? heatRiskLevelKey,
    bool heatDataValid = false,
    String? tripTitle,
  }) {
    switch (route) {
      case '/eosb':
        return HomeChipStatus.ready(
          line: eosbHasSavedEstimate
              ? HomeChipStatusStrings.t('home_chip_eosb_saved', locale)
              : HomeChipStatusStrings.t('home_chip_eosb_empty', locale),
        );
      case '/sponsorship-transfer':
        return HomeChipStatus.ready(
          line: HomeChipStatusStrings.t('home_chip_st_empty', locale),
        );
      case '/tenancy':
        return HomeChipStatus.ready(
          line: tenancyCheckCompleted
              ? HomeChipStatusStrings.t('home_chip_tenancy_saved', locale)
              : HomeChipStatusStrings.t('home_chip_tenancy_empty', locale),
        );
      case '/health-insurance':
        return HomeChipStatus.ready(
          line: healthPolicyChecked
              ? HomeChipStatusStrings.t('home_chip_hi_checked', locale)
              : HomeChipStatusStrings.t('home_chip_hi_empty', locale),
        );
      case '/warranty-shield':
        if (warrantyExpiringCount > 0) {
          return HomeChipStatus.ready(
            line: HomeChipStatusStrings.format(
              'home_chip_warranty_expiring',
              locale,
              params: {'count': '$warrantyExpiringCount'},
            ),
            tone: HomeChipStatusTone.attention,
          );
        }
        return HomeChipStatus.ready(
          line: HomeChipStatusStrings.t('home_chip_warranty_empty', locale),
        );
      case '/bill-tracker':
        return HomeChipStatus.ready(
          line: HomeChipStatusStrings.t('home_chip_bill_empty', locale),
        );
      case '/bill-splitter':
        return HomeChipStatus.ready(
          line: HomeChipStatusStrings.t('home_chip_split_static', locale),
        );
      case '/climate-navigator':
        if (heatDataValid && heatRiskLevelKey != null) {
          return HomeChipStatus.ready(
            line: ClimateStrings.wbgtRiskLabel(heatRiskLevelKey, locale),
          );
        }
        return HomeChipStatus.ready(
          line: HomeChipStatusStrings.t('home_chip_heat_fallback', locale),
        );
      case '/trip-planner':
        final title = tripTitle?.trim();
        if (title != null && title.isNotEmpty) {
          return HomeChipStatus.ready(line: title);
        }
        return HomeChipStatus.ready(
          line: HomeChipStatusStrings.t('home_chip_trip_empty', locale),
        );
      case '/queue-avoidance':
        return HomeChipStatus.ready(
          line: HomeChipStatusStrings.t('home_chip_queue_static', locale),
        );
      case '/know-qatar':
        return HomeChipStatus.ready(
          line: HomeChipStatusStrings.t('home_chip_know_qatar_static', locale),
        );
      case '/arabic-companion':
        return HomeChipStatus.ready(
          line: HomeChipStatusStrings.t('home_chip_arabic_static', locale),
        );
      case '/barcode-scanner':
        return HomeChipStatus.ready(
          line: HomeChipStatusStrings.t('home_chip_barcode_static', locale),
        );
      default:
        return const HomeChipStatus.ready(line: '');
    }
  }
}
