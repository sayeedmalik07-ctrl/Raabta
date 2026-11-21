/// Local-only user provider selections (bank / telecom directory ids).
class PersonalContextSnapshot {
  const PersonalContextSnapshot({
    this.bankDirectoryIds = const [],
    this.telecomDirectoryIds = const [],
    this.noBankInQatar = false,
  });

  static const empty = PersonalContextSnapshot();

  final List<String> bankDirectoryIds;
  final List<String> telecomDirectoryIds;
  final bool noBankInQatar;

  bool get hasBankSelection => noBankInQatar || bankDirectoryIds.isNotEmpty;

  bool get hasTelecomSelection => telecomDirectoryIds.isNotEmpty;

  bool get isEmpty =>
      !hasBankSelection && !hasTelecomSelection && !noBankInQatar;

  Set<String> savedIdsForCategory(String category) {
    return switch (category) {
      'banking' => noBankInQatar
          ? <String>{}
          : bankDirectoryIds.toSet(),
      'telecom' => telecomDirectoryIds.toSet(),
      _ => const {},
    };
  }

  bool hasSavedForCategory(String category) {
    return switch (category) {
      'banking' => hasBankSelection && !noBankInQatar,
      'telecom' => hasTelecomSelection,
      _ => false,
    };
  }
}
