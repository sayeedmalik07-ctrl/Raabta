import 'package:raabta/features/jobs/esco_match/data/esco_catalog.dart';
import 'package:raabta/features/jobs/esco_match/data/models/esco_models.dart';
import 'package:raabta/features/jobs/esco_match/domain/models/esco_job_match_models.dart';
import 'package:raabta/features/jobs/esco_match/domain/services/esco_job_match_service.dart';
import 'package:raabta/features/jobs/esco_match/domain/services/esco_normalizer.dart';
import 'package:raabta/features/jobs/cv_maker/domain/models/cv_document.dart';

/// CV Maker insight: essential ESCO skills missing for the user's target role.
class EscoSkillGapResult {
  const EscoSkillGapResult({
    required this.targetRoleInput,
    this.targetOccupation,
    this.missingSkills = const [],
    this.matchedSkills = const [],
    this.unmapped = false,
    this.noTargetRole = false,
  });

  final String targetRoleInput;
  final EscoOccupationDef? targetOccupation;
  final List<EscoSkillMatchItem> missingSkills;
  final List<EscoSkillMatchItem> matchedSkills;
  final bool unmapped;
  final bool noTargetRole;

  bool get hasInsight =>
      !noTargetRole && targetOccupation != null && !unmapped;

  factory EscoSkillGapResult.noRole() => const EscoSkillGapResult(
        targetRoleInput: '',
        noTargetRole: true,
      );

  factory EscoSkillGapResult.unmappedRole(String role) => EscoSkillGapResult(
        targetRoleInput: role,
        unmapped: true,
      );
}

class EscoSkillGapService {
  EscoSkillGapService({EscoNormalizer? normalizer})
      : _normalizer = normalizer ?? EscoNormalizer();

  final EscoNormalizer _normalizer;

  static const displayLimit = 6;

  EscoSkillGapResult analyzeForCv({
    required CvDocument cv,
    String? profileProfession,
    String locale = 'English',
  }) {
    final targetRole = resolveTargetRole(cv, profileProfession);
    if (targetRole.isEmpty) return EscoSkillGapResult.noRole();

    final occResult = _normalizer.normalize(
      targetRole,
      preferType: EscoConceptType.occupation,
    );
    if (occResult.occupation == null) {
      return EscoSkillGapResult.unmappedRole(targetRole);
    }

    final occupation = occResult.occupation!;
    final candidate = CandidateSkillProfileBuilder.fromTokens(
      _normalizer,
      skillTokens: [
        ...cv.skills.hardSkills,
        ...cv.skills.toolsSoftware,
        ...cv.skills.softSkills,
      ],
      certTokens: cv.certifications
          .map((c) => c.name)
          .where((n) => n.trim().isNotEmpty),
    );

    final matched = <EscoSkillMatchItem>[];
    final missing = <EscoSkillMatchItem>[];

    for (final uri in occupation.essentialSkillUris) {
      final skill = EscoCatalog.skillByUri(uri);
      if (skill == null) continue;

      final item = EscoSkillMatchItem(skill: skill);
      if (candidate.skillUris.contains(uri)) {
        matched.add(item);
      } else {
        missing.add(item);
      }
    }

    return EscoSkillGapResult(
      targetRoleInput: targetRole,
      targetOccupation: occupation,
      missingSkills: missing.take(displayLimit).toList(growable: false),
      matchedSkills: matched.take(displayLimit).toList(growable: false),
    );
  }

  /// Latest/current experience title, else profile profession.
  static String resolveTargetRole(CvDocument cv, String? profileProfession) {
    if (cv.experience.isNotEmpty) {
      final current = cv.experience.where((e) => e.isCurrent);
      if (current.isNotEmpty && current.first.jobTitle.trim().isNotEmpty) {
        return current.first.jobTitle.trim();
      }
      for (final exp in cv.experience) {
        if (exp.jobTitle.trim().isNotEmpty) return exp.jobTitle.trim();
      }
    }
    return profileProfession?.trim() ?? '';
  }

  String occupationLabel(EscoOccupationDef occupation, String locale) {
    final useArabic = locale.toLowerCase().contains('arabic');
    if (useArabic && occupation.labelAr.isNotEmpty) return occupation.labelAr;
    return occupation.labelEn;
  }
}
