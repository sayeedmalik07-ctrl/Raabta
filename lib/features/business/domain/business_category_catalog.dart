/// Canonical business directory taxonomy — aligned with post_schemas/business leaves.
abstract final class BusinessCategoryCatalog {
  static const leafIds = [
    'restaurant',
    'salon',
    'gym',
    'clinic',
    'ac_repair',
    'grocery',
    'travel',
    'pro_services',
  ];

  static const _displayLabels = {
    'restaurant': 'Restaurants',
    'salon': 'Salons',
    'gym': 'Gyms',
    'clinic': 'Clinics',
    'ac_repair': 'AC & Repair',
    'grocery': 'Grocery',
    'travel': 'Travel',
    'pro_services': 'PRO Services',
  };

  static String displayLabel(String leafId) =>
      _displayLabels[leafId] ?? leafId;

  /// Resolves stored Firestore category (legacy display or leaf id) to leaf id.
  static const _legacySingularLabels = {
    'Restaurant': 'restaurant',
    'Salon': 'salon',
    'Gym': 'gym',
    'Clinic': 'clinic',
    'AC & Repair': 'ac_repair',
    'Grocery': 'grocery',
    'Travel': 'travel',
    'PRO Services': 'pro_services',
  };

  static String? leafIdForStoredCategory(String stored) {
    final trimmed = stored.trim();
    if (leafIds.contains(trimmed)) return trimmed;
    final legacy = _legacySingularLabels[trimmed];
    if (legacy != null) return legacy;
    for (final entry in _displayLabels.entries) {
      if (entry.value == trimmed) return entry.key;
    }
    return null;
  }

  static bool matchesFilter({
    required String storedCategory,
    String? storedCategoryId,
    required String filterLeafId,
  }) {
    if (storedCategoryId != null && storedCategoryId == filterLeafId) {
      return true;
    }
    return leafIdForStoredCategory(storedCategory) == filterLeafId ||
        storedCategory == displayLabel(filterLeafId);
  }
}
