import 'package:raabta/features/community/data/community_group_registry.dart';
import 'package:raabta/features/community/utils/community_nationality_matching.dart';

/// Buddy matching nationality — only existing registry / alias country ids.
class BuddySupportedCountry {
  const BuddySupportedCountry({
    required this.countryId,
    required this.nationalityPersistValue,
  });

  final String countryId;
  final String nationalityPersistValue;
}

abstract final class BuddySupportedCountries {
  static const ordered = <BuddySupportedCountry>[
    BuddySupportedCountry(countryId: 'india', nationalityPersistValue: 'India'),
    BuddySupportedCountry(
      countryId: 'pakistan',
      nationalityPersistValue: 'Pakistan',
    ),
    BuddySupportedCountry(
      countryId: 'bangladesh',
      nationalityPersistValue: 'Bangladesh',
    ),
    BuddySupportedCountry(countryId: 'nepal', nationalityPersistValue: 'Nepal'),
    BuddySupportedCountry(
      countryId: 'philippines',
      nationalityPersistValue: 'Philippines',
    ),
    BuddySupportedCountry(countryId: 'kenya', nationalityPersistValue: 'Kenya'),
    BuddySupportedCountry(
      countryId: 'nigeria',
      nationalityPersistValue: 'Nigeria',
    ),
  ];

  static const allowedCountryIds = {
    'india',
    'pakistan',
    'bangladesh',
    'nepal',
    'philippines',
    'kenya',
    'nigeria',
  };

  static BuddySupportedCountry? byCountryId(String? id) {
    if (id == null || id.isEmpty) return null;
    for (final c in ordered) {
      if (c.countryId == id) return c;
    }
    return null;
  }

  /// Resolves profile free-text nationality to a Buddy country id, if possible.
  static String? resolveCountryIdFromProfile(String nationality) {
    return CommunityNationalityMatcher.countryIdFromNationality(nationality);
  }

  static bool isSupportedCountryId(String? id) =>
      id != null && allowedCountryIds.contains(id);

  /// Optional link to a Community nationality group (display only).
  static CommunityGroupDefinition? communityGroupFor(String countryId) {
    return CommunityGroupRegistry.byNationalityCountryId(countryId);
  }
}
