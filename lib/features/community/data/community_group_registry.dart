/// Canonical community group definitions — mirrors Groups tab mock data.
/// Firestore uses string [id] fields (e.g. "0" for Indians in Qatar).
class CommunityGroupDefinition {
  const CommunityGroupDefinition({
    required this.id,
    required this.emoji,
    required this.name,
    required this.members,
    this.isProfessional = false,
    this.nationalityCountryId,
  });

  final String id;
  final String emoji;
  final String name;
  final int members;
  final bool isProfessional;

  /// Optional nationality tag for deterministic home-country group discovery.
  final String? nationalityCountryId;

  int get intId => int.tryParse(id) ?? 0;

  bool get isNationalityGroup => nationalityCountryId != null;
}

class CommunityGroupRegistry {
  CommunityGroupRegistry._();

  static const List<CommunityGroupDefinition> all = [
    CommunityGroupDefinition(
      id: '0',
      emoji: '🇮🇳',
      name: 'Indians in Qatar',
      members: 45230,
      nationalityCountryId: 'india',
    ),
    CommunityGroupDefinition(
      id: '1',
      emoji: '🇵🇰',
      name: 'Pakistanis in Qatar',
      members: 32100,
      nationalityCountryId: 'pakistan',
    ),
    CommunityGroupDefinition(
      id: '2',
      emoji: '🇧🇩',
      name: 'Bangladeshis in Qatar',
      members: 18500,
      nationalityCountryId: 'bangladesh',
    ),
    CommunityGroupDefinition(
      id: '3',
      emoji: '🇳🇵',
      name: 'Nepalis in Qatar',
      members: 12300,
      nationalityCountryId: 'nepal',
    ),
    CommunityGroupDefinition(
      id: '4',
      emoji: '🇵🇭',
      name: 'Filipinos in Qatar',
      members: 28900,
      nationalityCountryId: 'philippines',
    ),
    CommunityGroupDefinition(
      id: '5',
      emoji: '🇰🇪',
      name: 'Kenyans in Qatar',
      members: 5600,
      nationalityCountryId: 'kenya',
    ),
    CommunityGroupDefinition(id: '6', emoji: '⛑️', name: 'HSE Professionals Qatar', members: 8900, isProfessional: true),
    CommunityGroupDefinition(id: '7', emoji: '💼', name: 'Qatar Jobs Board', members: 67200),
    CommunityGroupDefinition(id: '8', emoji: '👨‍👩‍👧', name: 'Family Life Qatar', members: 22100),
    CommunityGroupDefinition(id: '9', emoji: '⛑️', name: 'Safety Professionals Qatar', members: 6200, isProfessional: true),
    CommunityGroupDefinition(id: '10', emoji: '👷', name: 'Engineers Qatar', members: 11400, isProfessional: true),
    CommunityGroupDefinition(id: '11', emoji: '🚗', name: 'Drivers Community Qatar', members: 9800, isProfessional: true),
    CommunityGroupDefinition(id: '12', emoji: '👩‍⚕️', name: 'Nurses in Qatar', members: 7600, isProfessional: true),
    CommunityGroupDefinition(id: '13', emoji: '👨‍🏫', name: 'Teachers in Qatar', members: 5400, isProfessional: true),
  ];

  static CommunityGroupDefinition? byId(String id) {
    for (final g in all) {
      if (g.id == id) return g;
    }
    return null;
  }

  static CommunityGroupDefinition? byIntId(int id) => byId('$id');

  static CommunityGroupDefinition? byNationalityCountryId(String countryId) {
    final normalized = countryId.trim().toLowerCase();
    for (final group in all) {
      if (group.nationalityCountryId == normalized) return group;
    }
    return null;
  }
}
