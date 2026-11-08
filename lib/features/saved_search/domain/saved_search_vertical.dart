/// Post Engine vertical ids for saved search alerts.
enum SavedSearchVertical {
  housing('housing'),
  jobs('jobs'),
  business('business'),
  services('services'),
  marketplace('marketplace');

  const SavedSearchVertical(this.storageValue);

  final String storageValue;

  static SavedSearchVertical? fromStorage(String? raw) {
    if (raw == null) return null;
    for (final vertical in SavedSearchVertical.values) {
      if (vertical.storageValue == raw) return vertical;
    }
    return null;
  }
}
