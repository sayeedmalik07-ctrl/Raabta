import 'dart:io';

import 'package:flutter/material.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/features/jobs/cv_maker/domain/cv_template_catalog.dart';
import 'package:raabta/features/jobs/cv_maker/domain/models/cv_document.dart';
import 'package:raabta/features/jobs/cv_maker/domain/models/cv_section_layout.dart';

/// In-app CV preview — template-aware styling, separate from ATS PDF export.
class CvPreviewContent extends StatelessWidget {
  const CvPreviewContent({
    super.key,
    required this.cv,
    this.templateOverride,
    this.compact = false,
  });

  final CvDocument cv;
  final CvTemplateId? templateOverride;
  final bool compact;

  CvTemplateId get _templateId => templateOverride ?? cv.templateId;

  CvTemplateDefinition get _def => CvTemplateCatalog.definitionFor(_templateId);

  @override
  Widget build(BuildContext context) {
    final def = _def;
    final padding = compact
        ? const EdgeInsets.all(AppSpacing.sm)
        : const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.xl,
            AppSpacing.lg,
            AppSpacing.lg,
          );

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: def.documentSurface,
        borderRadius: BorderRadius.circular(compact ? 8 : AppSpacing.radiusMd),
        border: Border.all(
          color: def.premiumStyledHeader
              ? (def.accentColor ?? AppColors.cyanGlow).withValues(alpha: 0.25)
              : Colors.black.withValues(alpha: 0.08),
        ),
        boxShadow: compact
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      padding: padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _ContactHeader(cv: cv, def: def, compact: compact),
          SizedBox(height: compact ? AppSpacing.sm : AppSpacing.lg),
          ...CvSectionLayout.orderedSections(cv).map(
            (kind) => _SectionBlock(
              kind: kind,
              cv: cv,
              def: def,
              compact: compact,
            ),
          ),
        ],
      ),
    );
  }
}

class _ContactHeader extends StatelessWidget {
  const _ContactHeader({
    required this.cv,
    required this.def,
    required this.compact,
  });

  final CvDocument cv;
  final CvTemplateDefinition def;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final headlineRole = cv.experience
        .firstWhere(
          (e) => e.jobTitle.isNotEmpty,
          orElse: () => const CvExperience(),
        )
        .jobTitle;

    final showPhoto = def.supportsPhoto && cv.hasPhoto;
    final serif = def.useSerifPreview;
    final nameSize = compact ? 14.0 : 22.0;
    final accent = def.useBrandAccentInHeader
        ? AppColors.accentGold
        : def.accentColor;

    final nameStyle = TextStyle(
      fontSize: nameSize,
      fontWeight: FontWeight.w700,
      letterSpacing: def.sectionHeadersAllCaps ? 0.2 : -0.3,
      fontFamily: serif ? 'Georgia' : null,
      color: accent ?? Colors.black87,
      height: 1.2,
    );

    Widget headerContent = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    cv.fullName.isNotEmpty ? cv.fullName : 'Your Name',
                    style: nameStyle,
                  ),
                  if (headlineRole.isNotEmpty) ...[
                    SizedBox(height: compact ? 2 : 4),
                    Text(
                      headlineRole,
                      style: TextStyle(
                        fontSize: compact ? 10 : 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.black54,
                        fontFamily: serif ? 'Georgia' : null,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (showPhoto)
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: Image.file(
                  File(cv.photoLocalPath!),
                  width: compact ? 36 : 64,
                  height: compact ? 36 : 64,
                  fit: BoxFit.cover,
                ),
              ),
          ],
        ),
        SizedBox(height: compact ? AppSpacing.xs : AppSpacing.md),
        if (cv.phone.isNotEmpty)
          _ContactLine(label: 'Phone', value: cv.phone, compact: compact, serif: serif),
        if (cv.email.isNotEmpty)
          _ContactLine(label: 'Email', value: cv.email, compact: compact, serif: serif),
        if (cv.location.isNotEmpty)
          _ContactLine(label: 'Location', value: cv.location, compact: compact, serif: serif),
        if (cv.linkedInUrl.trim().isNotEmpty)
          _ContactLine(
            label: 'LinkedIn',
            value: cv.linkedInUrl.trim(),
            compact: compact,
            serif: serif,
          ),
        if (def.showSectionRule && accent != null) ...[
          SizedBox(height: compact ? AppSpacing.xs : AppSpacing.md),
          Container(
            height: compact ? 1 : 1.5,
            width: compact ? 32 : 48,
            color: accent,
          ),
        ] else if (!def.showSectionRule) ...[
          SizedBox(height: compact ? AppSpacing.xxs : AppSpacing.sm),
        ],
      ],
    );

    if (def.premiumStyledHeader) {
      return Container(
        width: double.infinity,
        padding: EdgeInsets.all(compact ? AppSpacing.xs : AppSpacing.md),
        decoration: BoxDecoration(
          color: (def.accentColor ?? AppColors.cyanGlow).withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(8),
          border: Border(
            left: BorderSide(
              color: def.accentColor ?? AppColors.cyanGlow,
              width: compact ? 2 : 3,
            ),
          ),
        ),
        child: headerContent,
      );
    }

    return headerContent;
  }
}

class _ContactLine extends StatelessWidget {
  const _ContactLine({
    required this.label,
    required this.value,
    required this.compact,
    required this.serif,
  });

  final String label;
  final String value;
  final bool compact;
  final bool serif;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: RichText(
        text: TextSpan(
          style: TextStyle(
            fontSize: compact ? 8 : 12,
            color: Colors.black54,
            height: 1.4,
            fontFamily: serif ? 'Georgia' : null,
          ),
          children: [
            TextSpan(
              text: '$label: ',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            TextSpan(text: value),
          ],
        ),
      ),
    );
  }
}

class _SectionBlock extends StatelessWidget {
  const _SectionBlock({
    required this.kind,
    required this.cv,
    required this.def,
    required this.compact,
  });

  final CvSectionKind kind;
  final CvDocument cv;
  final CvTemplateDefinition def;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: compact ? AppSpacing.sm : AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionTitle(_titleFor(kind), def: def, compact: compact),
          SizedBox(height: compact ? 4 : AppSpacing.sm),
          _bodyFor(kind),
        ],
      ),
    );
  }

  String _titleFor(CvSectionKind kind) {
    final raw = switch (kind) {
      CvSectionKind.professionalSummary => 'Professional Summary',
      CvSectionKind.workExperience => 'Work Experience',
      CvSectionKind.projects => 'Projects',
      CvSectionKind.education => 'Education',
      CvSectionKind.certifications => 'Certifications & Licenses',
      CvSectionKind.skills => 'Skills',
      CvSectionKind.languages => 'Languages',
    };
    return def.sectionHeadersAllCaps ? raw.toUpperCase() : raw;
  }

  TextStyle get _bodyStyle => TextStyle(
        fontSize: compact ? 8 : 11,
        height: 1.55,
        color: Colors.black87,
        fontFamily: def.useSerifPreview ? 'Georgia' : null,
      );

  TextStyle get _subtitleStyle => TextStyle(
        fontSize: compact ? 9 : 13,
        fontWeight: FontWeight.w600,
        color: Colors.black87,
        fontFamily: def.useSerifPreview ? 'Georgia' : null,
      );

  Widget _bodyFor(CvSectionKind kind) {
    switch (kind) {
      case CvSectionKind.professionalSummary:
        if (cv.summaryFormat == CvSummaryFormat.bullets &&
            cv.summaryBulletLines.isNotEmpty) {
          return _BulletList(cv.summaryBulletLines, def: def, compact: compact);
        }
        return Text(cv.professionalSummary.trim(), style: _bodyStyle);
      case CvSectionKind.workExperience:
        return Column(
          children: cv.experience
              .where((e) => e.jobTitle.isNotEmpty || e.employer.isNotEmpty)
              .map(
                (exp) => _ExperienceBlock(
                  exp: exp,
                  def: def,
                  compact: compact,
                  bodyStyle: _bodyStyle,
                  subtitleStyle: _subtitleStyle,
                ),
              )
              .toList(),
        );
      case CvSectionKind.projects:
        return Column(
          children: cv.projects
              .where((p) => p.title.isNotEmpty)
              .map(
                (p) => Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(p.title, style: _subtitleStyle),
                      if (p.description.isNotEmpty)
                        Text(p.description, style: _bodyStyle),
                      if (p.url.isNotEmpty && !compact)
                        Text(
                          p.url,
                          style: _bodyStyle.copyWith(
                            fontSize: 10,
                            color: def.accentColor ?? Colors.black54,
                          ),
                        ),
                    ],
                  ),
                ),
              )
              .toList(),
        );
      case CvSectionKind.education:
        return Column(
          children: cv.education
              .where(
                (e) => e.institution.isNotEmpty || e.qualification.isNotEmpty,
              )
              .map(
                (edu) => Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        edu.qualification.isNotEmpty
                            ? edu.qualification
                            : edu.institution,
                        style: _subtitleStyle,
                      ),
                      Text(
                        [
                          if (edu.qualification.isNotEmpty &&
                              edu.institution.isNotEmpty)
                            edu.institution,
                          if (edu.institutionLocation.isNotEmpty)
                            edu.institutionLocation,
                        ].join(' · '),
                        style: _bodyStyle.copyWith(color: Colors.black54),
                      ),
                      if (edu.showGraduationYear && edu.graduationLabel.isNotEmpty)
                        Text(
                          edu.graduationLabel,
                          style: _bodyStyle.copyWith(
                            fontSize: compact ? 7 : 10,
                            color: Colors.black45,
                          ),
                        ),
                    ],
                  ),
                ),
              )
              .toList(),
        );
      case CvSectionKind.certifications:
        return Column(
          children: cv.certifications
              .where((c) => c.name.isNotEmpty)
              .map(
                (c) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(
                    [
                      c.name,
                      if (c.issuer.isNotEmpty) c.issuer,
                      if (c.year.isNotEmpty) c.year,
                    ].join(' · '),
                    style: _bodyStyle,
                  ),
                ),
              )
              .toList(),
        );
      case CvSectionKind.skills:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (cv.skills.hardSkills.isNotEmpty)
              _SkillGroup(
                label: 'Technical skills',
                items: cv.skills.hardSkills,
                def: def,
                compact: compact,
                bodyStyle: _bodyStyle,
              ),
            if (cv.skills.toolsSoftware.isNotEmpty)
              _SkillGroup(
                label: 'Tools & software',
                items: cv.skills.toolsSoftware,
                def: def,
                compact: compact,
                bodyStyle: _bodyStyle,
              ),
            if (cv.skills.softSkills.isNotEmpty)
              _SkillGroup(
                label: 'Soft skills',
                items: cv.skills.softSkills,
                def: def,
                compact: compact,
                bodyStyle: _bodyStyle,
              ),
          ],
        );
      case CvSectionKind.languages:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: cv.languageEntries
              .where((l) => l.language.isNotEmpty)
              .map(
                (l) => Padding(
                  padding: const EdgeInsets.only(bottom: 2),
                  child: Text(
                    l.proficiency.isNotEmpty
                        ? '${l.language} — ${l.proficiency}'
                        : l.language,
                    style: _bodyStyle,
                  ),
                ),
              )
              .toList(),
        );
    }
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text, {required this.def, required this.compact});

  final String text;
  final CvTemplateDefinition def;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final accent = def.premiumStyledHeader
        ? def.accentColor
        : (def.useBrandAccentInHeader ? AppColors.accentGold : def.accentColor);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          text,
          style: TextStyle(
            fontSize: compact ? 9 : 12,
            fontWeight: FontWeight.w700,
            letterSpacing: def.sectionHeadersAllCaps ? 0.8 : 0.1,
            fontFamily: def.useSerifPreview ? 'Georgia' : null,
            color: def.premiumStyledHeader && accent != null
                ? accent
                : Colors.black87,
          ),
        ),
        if (def.showSectionRule && accent != null) ...[
          SizedBox(height: compact ? 2 : 4),
          Container(
            height: compact ? 0.75 : 1,
            width: double.infinity,
            color: accent.withValues(alpha: def.premiumStyledHeader ? 0.5 : 1),
          ),
        ] else if (!def.showSectionRule) ...[
          SizedBox(height: compact ? 2 : 6),
        ],
      ],
    );
  }
}

class _ExperienceBlock extends StatelessWidget {
  const _ExperienceBlock({
    required this.exp,
    required this.def,
    required this.compact,
    required this.bodyStyle,
    required this.subtitleStyle,
  });

  final CvExperience exp;
  final CvTemplateDefinition def;
  final bool compact;
  final TextStyle bodyStyle;
  final TextStyle subtitleStyle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(exp.jobTitle, style: subtitleStyle),
          Text(
            [
              if (exp.employer.isNotEmpty) exp.employer,
              if (exp.location.isNotEmpty) exp.location,
            ].join(' · '),
            style: bodyStyle.copyWith(color: Colors.black54),
          ),
          if (exp.dateRangeLabel.isNotEmpty)
            Text(
              exp.dateRangeLabel,
              style: bodyStyle.copyWith(
                fontSize: compact ? 7 : 10,
                color: Colors.black45,
              ),
            ),
          if (exp.displayResponsibilities.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              'Responsibilities',
              style: bodyStyle.copyWith(
                fontWeight: FontWeight.w700,
                color: Colors.black54,
                fontSize: compact ? 7 : 10,
              ),
            ),
            _BulletList(exp.displayResponsibilities, def: def, compact: compact),
          ],
          if (exp.displayAchievements.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              'Achievements',
              style: bodyStyle.copyWith(
                fontWeight: FontWeight.w700,
                color: Colors.black54,
                fontSize: compact ? 7 : 10,
              ),
            ),
            _BulletList(exp.displayAchievements, def: def, compact: compact),
          ],
        ],
      ),
    );
  }
}

class _BulletList extends StatelessWidget {
  const _BulletList(this.bullets, {required this.def, required this.compact});

  final List<String> bullets;
  final CvTemplateDefinition def;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final markerColor = def.accentColor ?? Colors.black54;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: bullets
          .map(
            (b) => Padding(
              padding: const EdgeInsets.only(bottom: 2),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '- ',
                    style: TextStyle(
                      fontSize: compact ? 8 : 11,
                      color: markerColor,
                      fontWeight: FontWeight.w600,
                      fontFamily: def.useSerifPreview ? 'Georgia' : null,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      b,
                      style: TextStyle(
                        fontSize: compact ? 8 : 11,
                        height: 1.5,
                        color: Colors.black87,
                        fontFamily: def.useSerifPreview ? 'Georgia' : null,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )
          .toList(),
    );
  }
}

class _SkillGroup extends StatelessWidget {
  const _SkillGroup({
    required this.label,
    required this.items,
    required this.def,
    required this.compact,
    required this.bodyStyle,
  });

  final String label;
  final List<String> items;
  final CvTemplateDefinition def;
  final bool compact;
  final TextStyle bodyStyle;

  @override
  Widget build(BuildContext context) {
    if (compact) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: Text('$label: ${items.join(', ')}', style: bodyStyle),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: bodyStyle.copyWith(
              fontWeight: FontWeight.w700,
              color: Colors.black54,
              fontSize: 10,
            ),
          ),
          const SizedBox(height: 4),
          Text(items.join(', '), style: bodyStyle),
        ],
      ),
    );
  }
}
