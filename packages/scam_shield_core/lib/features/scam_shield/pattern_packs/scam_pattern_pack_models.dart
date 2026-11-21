enum ScamPatternEvidenceKind {
  recoveryOffer,
  payToEarnTask,
  fakeFineToll,
  oneRingCallback,
  investmentOffer,
}

class ScamPatternGroup {
  const ScamPatternGroup({required this.id, required this.patterns});

  final String id;
  final List<String> patterns;
}

class ScamPatternPack {
  const ScamPatternPack({
    required this.id,
    required this.verified,
    required this.localFlag,
    required this.evidenceKind,
    required this.minGroups,
    required this.sourceLabel,
    required this.evidenceTextKey,
    required this.groups,
    this.sourceUrl,
  });

  final String id;
  final bool verified;
  final String localFlag;
  final ScamPatternEvidenceKind evidenceKind;
  final int minGroups;
  final String sourceLabel;
  final String evidenceTextKey;
  final List<ScamPatternGroup> groups;
  final String? sourceUrl;
}
