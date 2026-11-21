/// User-facing entry classification — configurable per engine in UI copy.
enum CaseTimelineEntryType {
  document,
  correspondence,
  note,
  photo,
  milestone,
}

extension CaseTimelineEntryTypeX on CaseTimelineEntryType {
  String get storageValue => name;

  static CaseTimelineEntryType? fromStorage(String? raw) {
    return switch (raw) {
      'document' => CaseTimelineEntryType.document,
      'correspondence' => CaseTimelineEntryType.correspondence,
      'note' => CaseTimelineEntryType.note,
      'photo' => CaseTimelineEntryType.photo,
      'milestone' => CaseTimelineEntryType.milestone,
      _ => null,
    };
  }
}
