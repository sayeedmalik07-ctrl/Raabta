import 'package:raabta/features/jobs/esco_match/data/models/esco_models.dart';

/// One ESCO skill in a match breakdown — always explainable, never opaque.
class EscoSkillMatchItem {
  const EscoSkillMatchItem({
    required this.skill,
    this.sourceInput,
    this.viaOccupation = false,
  });

  final EscoSkillDef skill;
  final String? sourceInput;

  /// True when inferred from a matched occupation rather than explicit skill text.
  final bool viaOccupation;

  String labelForLocale(String locale) {
    final useArabic = locale.toLowerCase().contains('arabic') ||
        locale.toLowerCase() == 'ar';
    if (useArabic && skill.labelAr.isNotEmpty) return skill.labelAr;
    return skill.labelEn;
  }
}

/// Deterministic ESCO skill-overlap result for one job ↔ candidate pair.
class EscoJobMatchDetail {
  const EscoJobMatchDetail({
    required this.skillScore,
    required this.overlapPercent,
    required this.matchedSkills,
    required this.missingRequiredSkills,
    required this.blockedQualifications,
    required this.explanation,
    this.inferredJobOccupation,
    this.inferredCandidateOccupation,
    this.hardRequirementBlocked = false,
    this.totalRequiredCount = 0,
  });

  /// Contribution to JobMatchService skill dimension (0–40).
  final int skillScore;

  /// Skill overlap 0–100 for display.
  final int overlapPercent;

  final List<EscoSkillMatchItem> matchedSkills;
  final List<EscoSkillMatchItem> missingRequiredSkills;

  /// Hard [JobRequirementsSpec.qualifications] the candidate does not satisfy.
  final List<String> blockedQualifications;

  final String explanation;
  final EscoOccupationDef? inferredJobOccupation;
  final EscoOccupationDef? inferredCandidateOccupation;
  final bool hardRequirementBlocked;
  final int totalRequiredCount;

  bool get hasSkillOverlap => matchedSkills.isNotEmpty;
}

/// Normalized candidate skill set ready for ESCO overlap scoring.
class CandidateSkillProfile {
  const CandidateSkillProfile({
    required this.skillUris,
    required this.rawTokens,
    this.primaryOccupation,
  });

  final Set<String> skillUris;
  final Set<String> rawTokens;
  final EscoOccupationDef? primaryOccupation;
}

/// Normalized job requirement set derived from listing fields.
class JobSkillRequirement {
  const JobSkillRequirement({
    required this.requiredSkillUris,
    required this.hardQualifications,
    this.inferredOccupation,
    this.explicitSkillLabels = const {},
  });

  final Set<String> requiredSkillUris;
  final List<String> hardQualifications;
  final EscoOccupationDef? inferredOccupation;

  /// Original free-text labels keyed by ESCO URI (for explanation).
  final Map<String, String> explicitSkillLabels;
}
