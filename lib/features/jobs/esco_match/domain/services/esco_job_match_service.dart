import 'package:raabta/features/jobs/esco_match/data/esco_catalog.dart';
import 'package:raabta/features/jobs/esco_match/data/models/esco_models.dart';
import 'package:raabta/features/jobs/esco_match/domain/models/esco_job_match_models.dart';
import 'package:raabta/features/jobs/esco_match/domain/services/esco_normalizer.dart';
import 'package:raabta/services/ai/user_profile_ai_service.dart';

/// Builds normalized candidate profiles from [UserAIProfile] (+ optional CV tokens).
abstract final class CandidateSkillProfileBuilder {
  static CandidateSkillProfile fromUserProfile(
    UserAIProfile profile,
    EscoNormalizer normalizer, {
    Iterable<String> extraSkillTokens = const [],
    Iterable<String> extraCertTokens = const [],
    Iterable<String> jobTitleTokens = const [],
  }) {
    final skillUris = <String>{};
    final rawTokens = <String>{};
    EscoOccupationDef? primaryOccupation;

    void absorbOccupation(EscoOccupationDef occ, {bool asPrimary = false}) {
      skillUris.addAll(occ.essentialSkillUris);
      if (asPrimary || primaryOccupation == null) {
        primaryOccupation = occ;
      }
    }

    void absorbSkillUri(String uri) => skillUris.add(uri);

    void absorbText(
      String text, {
      EscoConceptType? preferType,
      bool allowOccupation = true,
    }) {
      final trimmed = text.trim();
      if (trimmed.isEmpty) return;
      rawTokens.add(trimmed);

      final result = normalizer.normalize(trimmed, preferType: preferType);
      if (result.skill != null) {
        absorbSkillUri(result.skill!.uri);
      }
      if (allowOccupation && result.occupation != null) {
        absorbOccupation(result.occupation!, asPrimary: preferType == EscoConceptType.occupation);
      }
    }

    if (profile.profession.trim().isNotEmpty) {
      final occResult = normalizer.normalize(
        profile.profession,
        preferType: EscoConceptType.occupation,
      );
      if (occResult.occupation != null) {
        absorbOccupation(occResult.occupation!, asPrimary: true);
      } else {
        absorbText(profile.profession);
      }
    }

    for (final skill in profile.skills) {
      absorbText(skill, preferType: EscoConceptType.skill, allowOccupation: false);
    }
    for (final cert in profile.certifications) {
      absorbText(cert, preferType: EscoConceptType.skill);
    }
    for (final title in jobTitleTokens) {
      absorbText(title, preferType: EscoConceptType.occupation);
    }
    for (final extra in extraSkillTokens) {
      absorbText(extra, preferType: EscoConceptType.skill, allowOccupation: false);
    }
    for (final cert in extraCertTokens) {
      absorbText(cert, preferType: EscoConceptType.skill);
    }

    return CandidateSkillProfile(
      skillUris: skillUris,
      rawTokens: rawTokens,
      primaryOccupation: primaryOccupation,
    );
  }

  /// Builds a candidate profile from CV / form tokens without a full [UserAIProfile].
  static CandidateSkillProfile fromTokens(
    EscoNormalizer normalizer, {
    Iterable<String> skillTokens = const [],
    Iterable<String> certTokens = const [],
    String? profession,
    Iterable<String> jobTitleTokens = const [],
  }) {
    final skillUris = <String>{};
    final rawTokens = <String>{};
    EscoOccupationDef? primaryOccupation;

    void absorbOccupation(EscoOccupationDef occ, {bool asPrimary = false}) {
      skillUris.addAll(occ.essentialSkillUris);
      if (asPrimary || primaryOccupation == null) {
        primaryOccupation = occ;
      }
    }

    void absorbText(
      String text, {
      EscoConceptType? preferType,
      bool allowOccupation = true,
    }) {
      final trimmed = text.trim();
      if (trimmed.isEmpty) return;
      rawTokens.add(trimmed);

      final result = normalizer.normalize(trimmed, preferType: preferType);
      if (result.skill != null) skillUris.add(result.skill!.uri);
      if (allowOccupation && result.occupation != null) {
        absorbOccupation(
          result.occupation!,
          asPrimary: preferType == EscoConceptType.occupation,
        );
      }
    }

    if (profession != null && profession.trim().isNotEmpty) {
      final occResult = normalizer.normalize(
        profession,
        preferType: EscoConceptType.occupation,
      );
      if (occResult.occupation != null) {
        absorbOccupation(occResult.occupation!, asPrimary: true);
      } else {
        absorbText(profession);
      }
    }

    for (final title in jobTitleTokens) {
      absorbText(title, preferType: EscoConceptType.occupation);
    }
    for (final skill in skillTokens) {
      absorbText(skill, preferType: EscoConceptType.skill, allowOccupation: false);
    }
    for (final cert in certTokens) {
      absorbText(cert, preferType: EscoConceptType.skill);
    }

    return CandidateSkillProfile(
      skillUris: skillUris,
      rawTokens: rawTokens,
      primaryOccupation: primaryOccupation,
    );
  }
}

/// Parses flat job listing maps into ESCO-normalized requirement sets.
abstract final class JobSkillRequirementParser {
  static JobSkillRequirement parse(
    Map<String, dynamic> jobData,
    EscoNormalizer normalizer,
  ) {
    final requiredUris = <String>{};
    final explicitLabels = <String, String>{};
    EscoOccupationDef? inferredOccupation;

    void addSkillUri(String uri, {String? sourceLabel}) {
      requiredUris.add(uri);
      if (sourceLabel != null) {
        explicitLabels.putIfAbsent(uri, () => sourceLabel);
      }
    }

    void absorbRequirementText(String text) {
      final trimmed = text.trim();
      if (trimmed.isEmpty) return;

      final skillFirst = normalizer.normalize(
        trimmed,
        preferType: EscoConceptType.skill,
      );
      if (skillFirst.skill != null) {
        addSkillUri(skillFirst.skill!.uri, sourceLabel: trimmed);
        return;
      }

      final occResult = normalizer.normalize(
        trimmed,
        preferType: EscoConceptType.occupation,
      );
      if (occResult.occupation != null) {
        inferredOccupation ??= occResult.occupation;
        for (final uri in occResult.occupation!.essentialSkillUris) {
          addSkillUri(uri, sourceLabel: trimmed);
        }
        return;
      }

      if (skillFirst.occupation != null) {
        inferredOccupation ??= skillFirst.occupation;
        for (final uri in skillFirst.occupation!.essentialSkillUris) {
          addSkillUri(uri, sourceLabel: trimmed);
        }
      }
    }

    final title = _stringField(jobData, ['title', 'jobTitle', 'profession']);
    if (title.isNotEmpty) {
      final occ = normalizer.normalize(title, preferType: EscoConceptType.occupation);
      if (occ.occupation != null) {
        inferredOccupation = occ.occupation;
        for (final uri in occ.occupation!.essentialSkillUris) {
          addSkillUri(uri, sourceLabel: title);
        }
      }
    }

    for (final token in _stringListField(jobData, ['requiredSkills'])) {
      absorbRequirementText(token);
    }
    for (final token in _stringListField(jobData, ['requirements', 'skills'])) {
      absorbRequirementText(token);
    }

    final qualifications = _stringListField(jobData, ['qualifications']);

    return JobSkillRequirement(
      requiredSkillUris: requiredUris,
      hardQualifications: qualifications,
      inferredOccupation: inferredOccupation,
      explicitSkillLabels: explicitLabels,
    );
  }

  static String _stringField(Map<String, dynamic> data, List<String> keys) {
    for (final key in keys) {
      final value = data[key];
      if (value is String && value.trim().isNotEmpty) return value.trim();
    }
    return '';
  }

  static List<String> _stringListField(Map<String, dynamic> data, List<String> keys) {
    for (final key in keys) {
      final value = data[key];
      if (value is List) {
        return value
            .map((e) => e.toString().trim())
            .where((s) => s.isNotEmpty)
            .toList(growable: false);
      }
      if (value is String && value.isNotEmpty) {
        return value
            .split(RegExp(r'[,;\n•|]+'))
            .map((s) => s.trim())
            .where((s) => s.isNotEmpty)
            .toList(growable: false);
      }
    }
    return const [];
  }
}

/// Deterministic ESCO skill-overlap matcher — zero AI, fully explainable.
class EscoJobMatchService {
  EscoJobMatchService({EscoNormalizer? normalizer})
      : _normalizer = normalizer ?? EscoNormalizer();

  final EscoNormalizer _normalizer;

  /// Max total [JobMatchResult] score when a hard qualification is unmet.
  static const int hardRequirementScoreCap = 44;

  /// Skill dimension max (matches legacy JobMatchService weight).
  static const int skillDimensionMax = 40;

  EscoJobMatchDetail evaluate({
    required Map<String, dynamic> jobData,
    required UserAIProfile profile,
    Iterable<String> extraSkillTokens = const [],
    Iterable<String> extraCertTokens = const [],
    Iterable<String> jobTitleTokens = const [],
    String locale = 'English',
  }) {
    final candidate = CandidateSkillProfileBuilder.fromUserProfile(
      profile,
      _normalizer,
      extraSkillTokens: extraSkillTokens,
      extraCertTokens: extraCertTokens,
      jobTitleTokens: jobTitleTokens,
    );
    final jobReq = JobSkillRequirementParser.parse(jobData, _normalizer);

    return _score(candidate, jobReq, locale: locale);
  }

  EscoJobMatchDetail evaluateProfiles({
    required JobSkillRequirement jobReq,
    required CandidateSkillProfile candidate,
    String locale = 'English',
  }) {
    return _score(candidate, jobReq, locale: locale);
  }

  EscoJobMatchDetail _score(
    CandidateSkillProfile candidate,
    JobSkillRequirement jobReq, {
    required String locale,
  }) {
    final requiredUris = jobReq.requiredSkillUris;
    final matched = <EscoSkillMatchItem>[];
    final missing = <EscoSkillMatchItem>[];

    for (final uri in requiredUris) {
      final skill = EscoCatalog.skillByUri(uri);
      if (skill == null) continue;

      if (candidate.skillUris.contains(uri)) {
        matched.add(
          EscoSkillMatchItem(
            skill: skill,
            sourceInput: jobReq.explicitSkillLabels[uri],
          ),
        );
      } else {
        missing.add(
          EscoSkillMatchItem(
            skill: skill,
            sourceInput: jobReq.explicitSkillLabels[uri],
          ),
        );
      }
    }

    final blockedQualifications = _unmetHardQualifications(
      jobReq.hardQualifications,
      candidate,
    );
    final hardBlocked = blockedQualifications.isNotEmpty;

    final totalRequired = requiredUris.length;
    final overlapPercent = totalRequired == 0
        ? (matched.isNotEmpty ? 100 : 0)
        : ((matched.length / totalRequired) * 100).round().clamp(0, 100);

    var skillScore = totalRequired == 0
        ? (matched.isNotEmpty ? 20 : 0)
        : ((matched.length / totalRequired) * skillDimensionMax).round();

    if (hardBlocked) {
      skillScore = (skillScore * 0.5).round().clamp(0, hardRequirementScoreCap);
    }

    skillScore = skillScore.clamp(0, skillDimensionMax);

    final explanation = _buildExplanation(
      matched: matched,
      missing: missing,
      blockedQualifications: blockedQualifications,
      overlapPercent: overlapPercent,
      hardBlocked: hardBlocked,
      locale: locale,
      jobOccupation: jobReq.inferredOccupation,
    );

    return EscoJobMatchDetail(
      skillScore: skillScore,
      overlapPercent: overlapPercent,
      matchedSkills: matched,
      missingRequiredSkills: missing,
      blockedQualifications: blockedQualifications,
      explanation: explanation,
      inferredJobOccupation: jobReq.inferredOccupation,
      inferredCandidateOccupation: candidate.primaryOccupation,
      hardRequirementBlocked: hardBlocked,
      totalRequiredCount: totalRequired,
    );
  }

  List<String> _unmetHardQualifications(
    List<String> qualifications,
    CandidateSkillProfile candidate,
  ) {
    if (qualifications.isEmpty) return const [];

    final blocked = <String>[];
    final normalizedCandidateTokens = candidate.rawTokens
        .map(EscoTextNormalizer.normalize)
        .toSet();

    for (final qual in qualifications) {
      if (_qualificationSatisfied(qual, candidate, normalizedCandidateTokens)) {
        continue;
      }
      blocked.add(qual);
    }
    return blocked;
  }

  bool _qualificationSatisfied(
    String qualification,
    CandidateSkillProfile candidate,
    Set<String> normalizedCandidateTokens,
  ) {
    final normalizedQual = EscoTextNormalizer.normalize(qualification);
    if (normalizedQual.isEmpty) return true;

    for (final token in normalizedCandidateTokens) {
      if (token.contains(normalizedQual) || normalizedQual.contains(token)) {
        return true;
      }
    }

    final normalized = _normalizer.normalize(
      qualification,
      preferType: EscoConceptType.skill,
    );
    if (normalized.skill != null &&
        candidate.skillUris.contains(normalized.skill!.uri)) {
      return true;
    }

    for (final raw in candidate.rawTokens) {
      final cand = _normalizer.normalize(raw, preferType: EscoConceptType.skill);
      if (cand.skill != null &&
          normalized.skill != null &&
          cand.skill!.uri == normalized.skill!.uri) {
        return true;
      }
      if (EscoTextNormalizer.levenshteinRatio(raw, qualification) >= 0.88) {
        return true;
      }
    }

    return false;
  }

  String _buildExplanation({
    required List<EscoSkillMatchItem> matched,
    required List<EscoSkillMatchItem> missing,
    required List<String> blockedQualifications,
    required int overlapPercent,
    required bool hardBlocked,
    required String locale,
    EscoOccupationDef? jobOccupation,
  }) {
    final parts = <String>[];

    if (jobOccupation != null) {
      final occLabel = locale.toLowerCase().contains('arabic') &&
              jobOccupation.labelAr.isNotEmpty
          ? jobOccupation.labelAr
          : jobOccupation.labelEn;
      parts.add('Role mapped to ESCO occupation: $occLabel.');
    }

    if (matched.isNotEmpty) {
      final labels = matched
          .take(4)
          .map((m) => m.labelForLocale(locale))
          .join(' · ');
      parts.add(
        'Matched $overlapPercent% of required skills ($labels${matched.length > 4 ? '…' : ''}).',
      );
    } else if (missing.isNotEmpty) {
      parts.add('No required ESCO skills matched yet.');
    }

    if (missing.isNotEmpty) {
      final gapLabels = missing
          .take(4)
          .map((m) => m.labelForLocale(locale))
          .join(' · ');
      parts.add('Missing: $gapLabels${missing.length > 4 ? '…' : ''}.');
    }

    if (hardBlocked) {
      parts.add(
        'Required qualification not met: ${blockedQualifications.join(', ')}.',
      );
    }

    if (parts.isEmpty) {
      return 'Insufficient structured requirements to compute ESCO skill overlap.';
    }

    return parts.join(' ');
  }
}
