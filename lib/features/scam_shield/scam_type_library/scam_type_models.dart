/// Bundled scam type library (Phase 27) — offline only.
enum ScamTypeActionLink {
  officialDirectory,
  paymentCheck,
  incident,
  familyVerification,
  authorityDirectory,
  academy,
  checkup,
  simSwap,
  tenancyHub,
}

class ScamTypeMatchRules {
  const ScamTypeMatchRules({
    this.patternIds = const [],
    this.topics = const [],
    this.contentTypes = const [],
    this.localFlags = const [],
    this.terms = const [],
    this.minTermMatches = 2,
  });

  final List<String> patternIds;
  final List<String> topics;
  final List<String> contentTypes;
  final List<String> localFlags;
  final List<String> terms;
  final int minTermMatches;
}

class ScamTypeWhatToDoStep {
  const ScamTypeWhatToDoStep({
    required this.labelKey,
    required this.link,
  });

  final String labelKey;
  final ScamTypeActionLink link;
}

class ScamTypeDefinition {
  const ScamTypeDefinition({
    required this.id,
    required this.titleKey,
    required this.howItWorksKey,
    required this.redFlagKeys,
    required this.whatToDo,
    required this.exampleKey,
    required this.sourceLabelKeys,
    required this.lastReviewed,
    required this.verified,
    required this.match,
  });

  final String id;
  final String titleKey;
  final String howItWorksKey;
  final List<String> redFlagKeys;
  final List<ScamTypeWhatToDoStep> whatToDo;
  final String exampleKey;
  final List<String> sourceLabelKeys;
  final DateTime lastReviewed;
  final bool verified;
  final ScamTypeMatchRules match;
}
