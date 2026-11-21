import 'dart:io';
import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:raabta/features/jobs/cv_maker/domain/cv_template_catalog.dart';
import 'package:raabta/features/jobs/cv_maker/domain/models/cv_document.dart';
import 'package:raabta/features/jobs/cv_maker/domain/models/cv_section_layout.dart';
import 'package:raabta/features/jobs/cv_maker/l10n/cv_strings.dart';

/// ATS-safe CV PDF export — template-aware styling, single-column flow layout.
class CvPdfService {
  static const _nameSize = 22.0;
  static const _sectionSize = 12.0;
  static const _bodySize = 11.0;
  static const _smallSize = 10.0;
  static const _lineHeight = 1.35;

  static const _modernAccent = PdfColor.fromInt(0xFF1A5276);
  static const _professionalAccent = PdfColor.fromInt(0xFFFFB627);
  static const _premiumAccent = PdfColor.fromInt(0xFF00D4FF);

  Future<Uint8List> buildPdf(
    CvDocument cv, {
    String locale = 'English',
  }) async {
    final template = cv.templateId;
    final def = CvTemplateCatalog.definitionFor(template);

    pw.ImageProvider? photoProvider;
    if (def.supportsPhoto && cv.hasPhoto) {
      final file = File(cv.photoLocalPath!);
      if (await file.exists()) {
        photoProvider = pw.MemoryImage(await file.readAsBytes());
      }
    }

    final useSerif = template == CvTemplateId.classic;
    final baseFont = useSerif ? pw.Font.times() : pw.Font.helvetica();
    final boldFont = useSerif ? pw.Font.timesBold() : pw.Font.helveticaBold();

    final doc = pw.Document(
      theme: pw.ThemeData.withFont(base: baseFont, bold: boldFont),
    );

    final accent = switch (template) {
      CvTemplateId.modern => _modernAccent,
      CvTemplateId.classic => PdfColors.black,
      CvTemplateId.professional => _professionalAccent,
      CvTemplateId.premium => _premiumAccent,
    };

    final body = pw.TextStyle(fontSize: _bodySize, lineSpacing: _lineHeight);
    final small = pw.TextStyle(
      fontSize: _smallSize,
      lineSpacing: _lineHeight,
      color: PdfColors.grey800,
    );
    final boldBody = body.copyWith(fontWeight: pw.FontWeight.bold);

    pw.Widget sectionHeader(String key) {
      final label = CvStrings.t(key, locale);
      final title = def.sectionHeadersAllCaps ? label.toUpperCase() : label;
      return pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(height: template == CvTemplateId.classic ? 14 : 16),
          pw.Text(
            title,
            style: pw.TextStyle(
              fontSize: _sectionSize,
              fontWeight: pw.FontWeight.bold,
              color: template == CvTemplateId.premium ? accent : PdfColors.black,
            ),
          ),
          if (def.showSectionRule) ...[
            pw.SizedBox(height: 4),
            pw.Container(
              height: 0.75,
              color: template == CvTemplateId.classic
                  ? PdfColors.grey400
                  : accent,
            ),
          ] else
            pw.SizedBox(height: 8),
          pw.SizedBox(height: 6),
        ],
      );
    }

    pw.Widget bulletBlock(List<String> items) {
      if (items.isEmpty) return pw.SizedBox();
      return pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: items
            .map(
              (line) => pw.Padding(
                padding: const pw.EdgeInsets.only(bottom: 4),
                child: pw.Text('- $line', style: body),
              ),
            )
            .toList(),
      );
    }

    pw.Widget subLabel(String key) => pw.Padding(
          padding: const pw.EdgeInsets.only(top: 4, bottom: 2),
          child: pw.Text(
            CvStrings.t(key, locale),
            style: pw.TextStyle(
              fontSize: _smallSize,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.grey700,
            ),
          ),
        );

    pw.Widget experienceBlock(CvExperience exp) {
      return pw.Padding(
        padding: pw.EdgeInsets.only(
          bottom: template == CvTemplateId.professional ? 14 : 12,
        ),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(exp.jobTitle, style: boldBody),
            if (exp.employer.isNotEmpty || exp.location.isNotEmpty)
              pw.Text(
                [
                  if (exp.employer.isNotEmpty) exp.employer,
                  if (exp.location.isNotEmpty) exp.location,
                ].join(', '),
                style: small,
              ),
            if (exp.dateRangeLabel.isNotEmpty)
              pw.Text(exp.dateRangeLabel, style: small),
            if (exp.displayResponsibilities.isNotEmpty) ...[
              subLabel('cv_pdf_responsibilities'),
              bulletBlock(exp.displayResponsibilities),
            ],
            if (exp.displayAchievements.isNotEmpty) ...[
              subLabel('cv_pdf_achievements'),
              bulletBlock(exp.displayAchievements),
            ],
          ],
        ),
      );
    }

    pw.Widget nameHeader() {
      final nameColor = switch (template) {
        CvTemplateId.classic => PdfColors.black,
        CvTemplateId.professional => _professionalAccent,
        CvTemplateId.premium => PdfColors.black,
        CvTemplateId.modern => PdfColors.black,
      };

      final nameWidget = pw.Text(
        cv.fullName,
        style: pw.TextStyle(
          fontSize: _nameSize,
          fontWeight: pw.FontWeight.bold,
          color: nameColor,
        ),
      );

      if (def.premiumStyledHeader) {
        return pw.Container(
          width: double.infinity,
          padding: const pw.EdgeInsets.all(12),
          decoration: pw.BoxDecoration(
            color: PdfColor.fromInt(0xFFF4FAFC),
            border: pw.Border(
              left: pw.BorderSide(color: _premiumAccent, width: 3),
            ),
          ),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              if (photoProvider != null)
                pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Expanded(child: nameWidget),
                    pw.SizedBox(width: 12),
                    pw.Container(
                      width: 72,
                      height: 72,
                      decoration: pw.BoxDecoration(
                        border: pw.Border.all(color: PdfColors.grey400, width: 0.5),
                      ),
                      child: pw.Image(photoProvider, fit: pw.BoxFit.cover),
                    ),
                  ],
                )
              else
                nameWidget,
            ],
          ),
        );
      }

      return pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          nameWidget,
          if (def.showSectionRule && template != CvTemplateId.classic) ...[
            pw.SizedBox(height: 4),
            pw.Container(height: 1, color: accent),
          ],
          pw.SizedBox(height: 8),
        ],
      );
    }

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: pw.EdgeInsets.symmetric(
          horizontal: 48,
          vertical: template == CvTemplateId.professional ? 48 : 44,
        ),
        textDirection: cv.isRtl ? pw.TextDirection.rtl : pw.TextDirection.ltr,
        build: (context) {
          final blocks = <pw.Widget>[nameHeader()];

          if (!def.premiumStyledHeader && photoProvider != null) {
            blocks.add(
              pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Expanded(
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: _contactLines(cv, small, locale),
                    ),
                  ),
                  pw.SizedBox(width: 12),
                  pw.Container(
                    width: 72,
                    height: 72,
                    decoration: pw.BoxDecoration(
                      border: pw.Border.all(color: PdfColors.grey400, width: 0.5),
                    ),
                    child: pw.Image(photoProvider, fit: pw.BoxFit.cover),
                  ),
                ],
              ),
            );
          } else {
            blocks.addAll(_contactLines(cv, small, locale));
          }

          blocks.add(pw.SizedBox(height: 6));

          for (final kind in CvSectionLayout.orderedSections(cv)) {
            switch (kind) {
              case CvSectionKind.professionalSummary:
                blocks.add(sectionHeader('cv_pdf_section_summary'));
                if (cv.summaryFormat == CvSummaryFormat.bullets &&
                    cv.summaryBulletLines.isNotEmpty) {
                  blocks.add(bulletBlock(cv.summaryBulletLines));
                } else {
                  blocks.add(pw.Text(cv.professionalSummary.trim(), style: body));
                }
              case CvSectionKind.workExperience:
                blocks.add(sectionHeader('cv_pdf_section_experience'));
                for (final exp in cv.experience.where(
                  (e) => e.jobTitle.isNotEmpty || e.employer.isNotEmpty,
                )) {
                  blocks.add(experienceBlock(exp));
                }
              case CvSectionKind.projects:
                blocks.add(sectionHeader('cv_pdf_section_projects'));
                for (final proj in cv.projects.where((p) => p.title.isNotEmpty)) {
                  blocks.add(
                    pw.Padding(
                      padding: const pw.EdgeInsets.only(bottom: 8),
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(proj.title, style: boldBody),
                          if (proj.description.isNotEmpty)
                            pw.Text(proj.description, style: body),
                          if (proj.url.isNotEmpty) pw.Text(proj.url, style: small),
                        ],
                      ),
                    ),
                  );
                }
              case CvSectionKind.education:
                blocks.add(sectionHeader('cv_pdf_section_education'));
                for (final edu in cv.education.where(
                  (e) => e.institution.isNotEmpty || e.qualification.isNotEmpty,
                )) {
                  blocks.add(
                    pw.Padding(
                      padding: const pw.EdgeInsets.only(bottom: 6),
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(
                            [
                              if (edu.qualification.isNotEmpty) edu.qualification,
                              if (edu.institution.isNotEmpty) edu.institution,
                              if (edu.institutionLocation.isNotEmpty)
                                edu.institutionLocation,
                            ].join(', '),
                            style: body,
                          ),
                          if (edu.showGraduationYear && edu.graduationLabel.isNotEmpty)
                            pw.Text(edu.graduationLabel, style: small),
                        ],
                      ),
                    ),
                  );
                }
              case CvSectionKind.certifications:
                blocks.add(sectionHeader('cv_pdf_section_certifications'));
                for (final cert in cv.certifications.where((c) => c.name.isNotEmpty)) {
                  blocks.add(
                    pw.Padding(
                      padding: const pw.EdgeInsets.only(bottom: 4),
                      child: pw.Text(
                        [
                          cert.name,
                          if (cert.issuer.isNotEmpty) cert.issuer,
                          if (cert.dateLabel.isNotEmpty) cert.dateLabel,
                        ].join(' - '),
                        style: body,
                      ),
                    ),
                  );
                }
              case CvSectionKind.skills:
                blocks.add(sectionHeader('cv_pdf_section_skills'));
                if (cv.skills.hardSkills.isNotEmpty) {
                  blocks.add(pw.Text(
                    '${CvStrings.t('cv_pdf_technical_skills', locale)}: ${cv.skills.hardSkills.join(', ')}',
                    style: body,
                  ));
                  blocks.add(pw.SizedBox(height: 4));
                }
                if (cv.skills.toolsSoftware.isNotEmpty) {
                  blocks.add(pw.Text(
                    '${CvStrings.t('cv_pdf_tools_software', locale)}: ${cv.skills.toolsSoftware.join(', ')}',
                    style: body,
                  ));
                  blocks.add(pw.SizedBox(height: 4));
                }
                if (cv.skills.softSkills.isNotEmpty) {
                  blocks.add(pw.Text(
                    '${CvStrings.t('cv_pdf_soft_skills', locale)}: ${cv.skills.softSkills.join(', ')}',
                    style: body,
                  ));
                }
              case CvSectionKind.languages:
                blocks.add(sectionHeader('cv_pdf_section_languages'));
                for (final lang in cv.languageEntries) {
                  if (lang.language.isEmpty) continue;
                  final line = lang.proficiency.isNotEmpty
                      ? '${lang.language} (${lang.proficiency})'
                      : lang.language;
                  blocks.add(pw.Padding(
                    padding: const pw.EdgeInsets.only(bottom: 2),
                    child: pw.Text(line, style: body),
                  ));
                }
            }
          }

          return blocks;
        },
      ),
    );

    return doc.save();
  }

  List<pw.Widget> _contactLines(
    CvDocument cv,
    pw.TextStyle small,
    String locale,
  ) {
    return [
      if (cv.phone.isNotEmpty)
        pw.Text('${CvStrings.t('cv_pdf_phone', locale)}: ${cv.phone}', style: small),
      if (cv.email.isNotEmpty)
        pw.Text('${CvStrings.t('cv_pdf_email', locale)}: ${cv.email}', style: small),
      if (cv.location.isNotEmpty)
        pw.Text('${CvStrings.t('cv_pdf_location', locale)}: ${cv.location}', style: small),
      if (cv.linkedInUrl.trim().isNotEmpty)
        pw.Text(
          '${CvStrings.t('cv_pdf_linkedin', locale)}: ${cv.linkedInUrl.trim()}',
          style: small,
        ),
    ];
  }
}
