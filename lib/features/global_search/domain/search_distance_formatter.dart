import 'package:raabta/core/l10n/app_shell_strings.dart';

/// Localized distance labels for Global Search (S6).
abstract final class SearchDistanceFormatter {
  static String? labelForMeters(int? meters, String locale) {
    if (meters == null || meters < 0) return null;
    if (meters < 1000) {
      return AppShellStrings.t('global_search_distance_meters', locale)
          .replaceAll('{distance}', '$meters');
    }
    final km = (meters / 1000).toStringAsFixed(1);
    return AppShellStrings.t('global_search_distance_kilometers', locale)
        .replaceAll('{distance}', km);
  }

  static String semanticDistanceLabel(int? meters, String locale) {
    if (meters == null || meters < 0) return '';
    if (meters < 1000) return '$meters meters away';
    final km = (meters / 1000).toStringAsFixed(1);
    return '$km kilometers away';
  }
}
