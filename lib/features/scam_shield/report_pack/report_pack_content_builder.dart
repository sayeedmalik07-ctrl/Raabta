import 'package:intl/intl.dart';
import 'package:raabta/features/scam_shield/domain/scam_evidence_record.dart';
import 'package:raabta/features/scam_shield/presentation/l10n/scam_shield_strings.dart';
import 'package:raabta/features/scam_shield/report_pack/report_pack_models.dart';
import 'package:raabta/features/scam_shield/report_pack/report_pack_section_headings.dart';

class ReportPackSnapshot {
  const ReportPackSnapshot({
    required this.generatedAt,
    required this.locale,
    required this.title,
    required this.disclaimer,
    required this.sections,
    required this.plainText,
  });

  final DateTime generatedAt;
  final String locale;
  final String title;
  final String disclaimer;
  final List<ReportPackSection> sections;
  final String plainText;
}

class ReportPackSection {
  const ReportPackSection({
    required this.heading,
    required this.lines,
  });

  final String heading;
  final List<String> lines;
}

abstract final class ReportPackContentBuilder {
  static ReportPackSnapshot build({
    required ReportPackDraft draft,
    required String locale,
    required List<ScamEvidenceRecord> selectedEvidence,
    DateTime? generatedAt,
  }) {
    final at = generatedAt ?? DateTime.now();
    final dateLabel = DateFormat.yMMMMd().format(at);
    final sections = <ReportPackSection>[];

    sections.add(
      ReportPackSection(
        heading: ReportPackSectionHeadings.reportDate,
        lines: [dateLabel],
      ),
    );

    if (draft.userSummary.trim().isNotEmpty) {
      sections.add(
        ReportPackSection(
          heading: ReportPackSectionHeadings.userSummary,
          lines: [draft.userSummary.trim()],
        ),
      );
    }

    if (draft.timeline.isNotEmpty) {
      sections.add(
        ReportPackSection(
          heading: ReportPackSectionHeadings.timeline,
          lines: [
            for (final t in draft.timeline)
              _timelineLine(t, locale),
          ],
        ),
      );
    }

    final partyLines = draft.otherPartyDetails
        .where((d) => d.value.trim().isNotEmpty)
        .map((d) => '${d.kind}: ${d.value.trim()}')
        .toList();
    if (partyLines.isNotEmpty) {
      sections.add(
        ReportPackSection(
          heading: ReportPackSectionHeadings.otherParty,
          lines: partyLines,
        ),
      );
    }

    final txLines = draft.transactions
        .where((t) => !t.isEmpty)
        .map(_transactionLine)
        .toList();
    if (txLines.isNotEmpty) {
      sections.add(
        ReportPackSection(
          heading: ReportPackSectionHeadings.transactions,
          lines: txLines,
        ),
      );
    }

    if (selectedEvidence.isNotEmpty) {
      sections.add(
        ReportPackSection(
          heading: ReportPackSectionHeadings.evidence,
          lines: [
            for (final r in selectedEvidence)
              '${r.createdAt.toIso8601String()} — ${r.sourceKind.name}\n${r.maskedSummary}',
          ],
        ),
      );
    }

    if (draft.stepsTakenKeys.isNotEmpty) {
      sections.add(
        ReportPackSection(
          heading: ReportPackSectionHeadings.stepsTaken,
          lines: [
            for (final key in draft.stepsTakenKeys)
              '• ${ScamShieldStrings.t(key, locale)}',
          ],
        ),
      );
    }

    final refLines = <String>[];
    if (draft.bankCaseNumber.trim().isNotEmpty) {
      refLines.add(
        '${ScamShieldStrings.t('ss_rp_ref_bank_case', locale)}: ${draft.bankCaseNumber.trim()}',
      );
    }
    if (draft.authorityReferenceNumbers.trim().isNotEmpty) {
      refLines.add(
        '${ScamShieldStrings.t('ss_rp_ref_authority', locale)}: ${draft.authorityReferenceNumbers.trim()}',
      );
    }
    if (refLines.isNotEmpty) {
      sections.add(
        ReportPackSection(
          heading: ReportPackSectionHeadings.references,
          lines: refLines,
        ),
      );
    }

    if (draft.includeContactDetails) {
      final contact = <String>[
        if (draft.contactName.trim().isNotEmpty) draft.contactName.trim(),
        if (draft.contactPhone.trim().isNotEmpty) draft.contactPhone.trim(),
        if (draft.contactEmail.trim().isNotEmpty) draft.contactEmail.trim(),
      ];
      if (contact.isNotEmpty) {
        sections.add(
          ReportPackSection(
            heading: ReportPackSectionHeadings.yourContact,
            lines: contact,
          ),
        );
      }
    }

    final disclaimer = ScamShieldStrings.t('ss_rp_pack_disclaimer', locale);
    final title = ScamShieldStrings.t('ss_rp_pack_title', locale);
    final plain = _plainText(title, sections, disclaimer);

    return ReportPackSnapshot(
      generatedAt: at,
      locale: locale,
      title: title,
      disclaimer: disclaimer,
      sections: sections,
      plainText: plain,
    );
  }

  static String _timelineLine(ReportPackTimelineEntry t, String locale) {
    final label = t.labelKey.isEmpty
        ? ''
        : ScamShieldStrings.t(t.labelKey, locale);
    if (t.userDate.trim().isEmpty) return label;
    return '$label — ${t.userDate.trim()}';
  }

  static String _transactionLine(ReportPackTransactionLine t) {
    final parts = <String>[
      if (t.amount.isNotEmpty) '${t.amount} ${t.currency}',
      if (t.date.isNotEmpty) t.date,
      if (t.method.isNotEmpty) t.method,
      if (t.reference.isNotEmpty) 'ref: ${t.reference}',
    ];
    return parts.join(' · ');
  }

  static String _plainText(
    String title,
    List<ReportPackSection> sections,
    String disclaimer,
  ) {
    final buffer = StringBuffer()
      ..writeln(title)
      ..writeln('');
    for (final section in sections) {
      buffer
        ..writeln(section.heading)
        ..writeln('---');
      for (final line in section.lines) {
        buffer.writeln(line);
        buffer.writeln('');
      }
    }
    buffer
      ..writeln(ReportPackSectionHeadings.disclaimer)
      ..writeln(disclaimer);
    return buffer.toString().trim();
  }
}
