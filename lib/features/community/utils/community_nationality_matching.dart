/// Deterministic nationality → community group matching (zero AI).
abstract final class CommunityNationalityAliases {
  /// Canonical country ids aligned with [CommunityGroupDefinition.nationalityCountryId].
  static const entries = <String, List<String>>{
    'india': ['india', 'indian', 'in', 'ind', 'bharat', 'hindustan', 'भारत'],
    'pakistan': ['pakistan', 'pakistani', 'pk', 'pak'],
    'bangladesh': ['bangladesh', 'bangladeshi', 'bd', 'bangla'],
    'nepal': ['nepal', 'nepali', 'nepalese', 'np'],
    'philippines': [
      'philippines',
      'filipino',
      'filipina',
      'ph',
      'pinoy',
      'pinay',
    ],
    'kenya': ['kenya', 'kenyan', 'ke'],
    'nigeria': ['nigeria', 'nigerian', 'ng'],
  };

  static String? resolveCountryId(String nationality) {
    final normalized = _normalize(nationality);
    if (normalized.isEmpty) return null;

    for (final entry in entries.entries) {
      for (final alias in entry.value) {
        if (_normalize(alias) == normalized) return entry.key;
      }
    }

    // "Indian expat", "from Nepal", etc.
    for (final entry in entries.entries) {
      for (final alias in entry.value) {
        final a = _normalize(alias);
        if (a.length >= 4 && normalized.contains(a)) return entry.key;
      }
    }

    return null;
  }

  static String _normalize(String value) =>
      value.trim().toLowerCase().replaceAll(RegExp(r'\s+'), ' ');
}

/// Resolves a profile nationality string to a community nationality group.
abstract final class CommunityNationalityMatcher {
  static String? countryIdFromNationality(String nationality) {
    return CommunityNationalityAliases.resolveCountryId(nationality);
  }
}
