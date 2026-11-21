import 'package:raabta/features/community/data/community_group_registry.dart';
import 'package:raabta/features/community/models/community_nationality_suggestion.dart';
import 'package:raabta/features/community/presentation/l10n/community_strings.dart';
import 'package:raabta/features/community/utils/community_nationality_matching.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// One-time dismiss per nationality country id (non-nagging pattern).
abstract final class CommunityNationalitySuggestionService {
  static String dismissPrefsKey(String countryId) =>
      'community_nat_suggestion_dismissed_$countryId';

  static Future<bool> isDismissed(String countryId) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(dismissPrefsKey(countryId)) ?? false;
  }

  static Future<void> dismiss(String countryId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(dismissPrefsKey(countryId), true);
  }

  static Future<CommunityNationalitySuggestionView> resolve({
    required String nationality,
    required Set<int> joinedGroupIds,
    required String locale,
  }) async {
    final countryId = CommunityNationalityMatcher.countryIdFromNationality(
      nationality,
    );
    if (countryId == null) {
      return const CommunityNationalitySuggestionView.hidden();
    }

    if (await isDismissed(countryId)) {
      return const CommunityNationalitySuggestionView.hidden();
    }

    final label = CommunityStrings.nationalityLabel(countryId, locale);
    final group = CommunityGroupRegistry.byNationalityCountryId(countryId);

    if (group != null) {
      if (joinedGroupIds.contains(group.intId)) {
        return const CommunityNationalitySuggestionView.hidden();
      }
      return CommunityNationalitySuggestionView.joinGroup(
        countryId: countryId,
        nationalityLabel: label,
        group: group,
      );
    }

    return CommunityNationalitySuggestionView.noGroup(
      countryId: countryId,
      nationalityLabel: label,
    );
  }
}
