import 'package:raabta/features/jobs/cv_maker/domain/models/cv_document.dart';

/// Ordered renderable sections for preview and ATS PDF — single source of truth.
enum CvSectionKind {
  professionalSummary,
  workExperience,
  projects,
  education,
  certifications,
  skills,
  languages,
}

class CvSectionLayout {
  const CvSectionLayout._();

  static bool hasWorkExperience(CvDocument cv) =>
      cv.experience.any((e) => e.jobTitle.isNotEmpty || e.employer.isNotEmpty);

  static bool hasProjects(CvDocument cv) =>
      cv.projects.any((p) => p.title.isNotEmpty || p.description.isNotEmpty);

  static bool hasEducation(CvDocument cv) => cv.education.any(
        (e) => e.institution.isNotEmpty || e.qualification.isNotEmpty,
      );

  static bool hasCertifications(CvDocument cv) =>
      cv.certifications.any((c) => c.name.isNotEmpty);

  static bool hasSkills(CvDocument cv) =>
      cv.skills.hardSkills.isNotEmpty ||
      cv.skills.toolsSoftware.isNotEmpty ||
      cv.skills.softSkills.isNotEmpty;

  static bool hasLanguages(CvDocument cv) =>
      cv.languageEntries.any((l) => l.language.isNotEmpty);

  /// Top-to-bottom section order per product spec.
  static List<CvSectionKind> orderedSections(CvDocument cv) {
    final sections = <CvSectionKind>[];

    if (cv.professionalSummary.trim().isNotEmpty) {
      sections.add(CvSectionKind.professionalSummary);
    }

    final hasWork = hasWorkExperience(cv);
    final hasProj = hasProjects(cv);

    if (hasWork) {
      sections.add(CvSectionKind.workExperience);
      if (hasProj) sections.add(CvSectionKind.projects);
    }

    if (hasEducation(cv)) {
      sections.add(CvSectionKind.education);
    }

    if (!hasWork && hasProj) {
      sections.add(CvSectionKind.projects);
    }

    if (hasCertifications(cv)) {
      sections.add(CvSectionKind.certifications);
    }

    if (hasSkills(cv)) {
      sections.add(CvSectionKind.skills);
    }

    if (hasLanguages(cv)) {
      sections.add(CvSectionKind.languages);
    }

    return sections;
  }
}
