class BuddyIntroTemplate {
  const BuddyIntroTemplate({required this.id, required this.labelKey});

  final String id;
  final String labelKey;
}

abstract final class BuddyIntroTemplates {
  static const defaultId = 'orient_me';

  static const all = [
    BuddyIntroTemplate(id: 'orient_me', labelKey: 'buddy_intro_orient'),
    BuddyIntroTemplate(
      id: 'housing_tips',
      labelKey: 'buddy_intro_housing',
    ),
    BuddyIntroTemplate(id: 'daily_life', labelKey: 'buddy_intro_daily'),
  ];

  static BuddyIntroTemplate? byId(String id) {
    for (final t in all) {
      if (t.id == id) return t;
    }
    return null;
  }
}
