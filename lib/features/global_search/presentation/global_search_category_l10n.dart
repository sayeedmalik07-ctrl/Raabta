import 'package:raabta/core/l10n/app_shell_strings.dart';
import 'package:raabta/features/global_search/domain/global_search_models.dart';

/// Localized presentation labels for [GlobalSearchCategory] (enum values unchanged).
abstract final class GlobalSearchCategoryL10n {
  static String label(GlobalSearchCategory category, String locale) {
    return AppShellStrings.t(_keyFor(category), locale);
  }

  static String seeAllLabel(GlobalSearchCategory category, String locale) {
    return AppShellStrings.format(
      'global_search_see_all_in',
      locale,
      params: {'category': label(category, locale)},
    );
  }

  static String _keyFor(GlobalSearchCategory category) {
    return switch (category) {
      GlobalSearchCategory.actions => 'global_search_category_actions',
      GlobalSearchCategory.jobs => 'global_search_category_jobs',
      GlobalSearchCategory.housing => 'global_search_category_housing',
      GlobalSearchCategory.community => 'global_search_category_community',
      GlobalSearchCategory.documents => 'global_search_category_documents',
      GlobalSearchCategory.exchange => 'global_search_category_exchange',
      GlobalSearchCategory.mosques => 'global_search_category_mosques',
      GlobalSearchCategory.tripPlanner => 'global_search_category_trip_planner',
      GlobalSearchCategory.businesses => 'global_search_category_businesses',
      GlobalSearchCategory.marketplace => 'global_search_category_marketplace',
      GlobalSearchCategory.visa => 'global_search_category_visa',
      GlobalSearchCategory.health => 'global_search_category_health',
      GlobalSearchCategory.money => 'global_search_category_money',
      GlobalSearchCategory.tools => 'global_search_category_tools',
      GlobalSearchCategory.services => 'global_search_category_services',
    };
  }
}
