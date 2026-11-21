/// Fixed Buddy interest tags — not coupled to Community group membership.
class BuddyInterestDefinition {
  const BuddyInterestDefinition({required this.id, required this.labelKey});

  final String id;
  final String labelKey;
}

abstract final class BuddyInterestTaxonomy {
  static const all = <BuddyInterestDefinition>[
    BuddyInterestDefinition(id: 'settling_in', labelKey: 'buddy_interest_settling_in'),
    BuddyInterestDefinition(id: 'housing', labelKey: 'buddy_interest_housing'),
    BuddyInterestDefinition(id: 'jobs', labelKey: 'buddy_interest_jobs'),
    BuddyInterestDefinition(id: 'schools', labelKey: 'buddy_interest_schools'),
    BuddyInterestDefinition(id: 'transport', labelKey: 'buddy_interest_transport'),
    BuddyInterestDefinition(id: 'healthcare', labelKey: 'buddy_interest_healthcare'),
    BuddyInterestDefinition(
      id: 'legal_admin',
      labelKey: 'buddy_interest_legal_admin',
    ),
    BuddyInterestDefinition(id: 'social', labelKey: 'buddy_interest_social'),
  ];

  static const allowedIds = {
    'settling_in',
    'housing',
    'jobs',
    'schools',
    'transport',
    'healthcare',
    'legal_admin',
    'social',
  };

  static BuddyInterestDefinition? byId(String id) {
    for (final item in all) {
      if (item.id == id) return item;
    }
    return null;
  }
}
