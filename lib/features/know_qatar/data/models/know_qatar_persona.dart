/// Live-derived Know Qatar audience — never persisted to Firestore.
enum KnowQatarPersona {
  visitor,
  newResident,
  workingResident,
  family,
}

/// Read-only inputs for [KnowQatarPersonaService.derivePersona].
class KnowQatarPersonaInput {
  const KnowQatarPersonaInput({
    this.deadlineDocumentTypes = const [],
    this.deadlineGuideCategoryIds = const [],
    this.deadlineDocumentLabels = const [],
    this.hasCompletedEosbCalculation = false,
    this.expatLifeLevel,
    this.advancedProfileIndustry,
  });

  final List<String> deadlineDocumentTypes;
  final List<String> deadlineGuideCategoryIds;
  final List<String> deadlineDocumentLabels;
  final bool hasCompletedEosbCalculation;
  final String? expatLifeLevel;
  final String? advancedProfileIndustry;
}
