import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:raabta/features/case_timeline/domain/case_timeline_entry.dart';
import 'package:raabta/features/case_timeline/presentation/l10n/case_timeline_strings.dart';
import 'package:raabta/features/case_timeline/services/case_timeline_service.dart';
import 'package:raabta/features/sponsorship_transfer/data/transfer_document_checklist_catalog.dart';
import 'package:raabta/features/sponsorship_transfer/domain/models/sponsorship_transfer_enums.dart';
import 'package:raabta/features/sponsorship_transfer/domain/models/transfer_readiness_input.dart';
import 'package:raabta/features/sponsorship_transfer/domain/models/transfer_readiness_models.dart';
import 'package:raabta/features/sponsorship_transfer/presentation/l10n/sponsorship_transfer_strings.dart';
import 'package:share_plus/share_plus.dart';

/// Transfer preparation packet PDF — cover sheet only, NOT a filed MADLSA form.
class SponsorshipTransferPdfService {
  Future<File> generatePreparationPacket({
    required TransferReadinessInput input,
    required TransferReadinessResult result,
    required Set<String> collectedItemIds,
    required String locale,
    List<CaseTimelineEntry> timelineEntries = const [],
  }) async {
    final doc = pw.Document();
    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (context) => [
          pw.Header(
            level: 0,
            child: pw.Text(
              SponsorshipTransferStrings.t('st_packet_title', locale),
              style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold),
            ),
          ),
          pw.Text(
            SponsorshipTransferStrings.t('st_packet_disclaimer', locale),
            style: const pw.TextStyle(fontSize: 9),
          ),
          pw.SizedBox(height: 8),
          pw.Text(
            SponsorshipTransferStrings.t('st_law_disambiguation', locale),
            style: const pw.TextStyle(fontSize: 9),
          ),
          pw.SizedBox(height: 16),
          pw.Text(
            SponsorshipTransferStrings.t('st_packet_summary_heading', locale),
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 6),
          if (input.residencePermitExpiry != null)
            pw.Text(
              SponsorshipTransferStrings.format('st_packet_permit_expiry', locale, {
                'date': _formatDate(input.residencePermitExpiry!),
              }),
            ),
          if (input.employmentStartDate != null)
            pw.Text(
              SponsorshipTransferStrings.format('st_packet_employment_start', locale, {
                'date': _formatDate(input.employmentStartDate!),
              }),
            ),
          pw.Text(
            SponsorshipTransferStrings.format('st_packet_contract_type', locale, {
              'type': _contractLabel(input.contractType, locale),
            }),
          ),
          if (input.formalNoticeStatus != null)
            pw.Text(
              SponsorshipTransferStrings.format('st_packet_formal_notice', locale, {
                'status': _noticeLabel(input.formalNoticeStatus!, locale),
              }),
            ),
          pw.SizedBox(height: 16),
          pw.Text(
            SponsorshipTransferStrings.t('st_packet_readiness_heading', locale),
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 6),
          ...result.items.map(
            (item) => pw.Padding(
              padding: const pw.EdgeInsets.only(bottom: 4),
              child: pw.Text(
                '• [${_statusLabel(item.status, locale)}] '
                '${SponsorshipTransferStrings.t(item.titleKey, locale)}',
              ),
            ),
          ),
          pw.SizedBox(height: 16),
          pw.Text(
            SponsorshipTransferStrings.t('st_packet_docs_heading', locale),
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 6),
          pw.Text(
            SponsorshipTransferStrings.t('st_checklist_verified_section', locale),
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10),
          ),
          pw.SizedBox(height: 4),
          ...TransferDocumentChecklistCatalog.verifiedItems.map(
            (def) => _checklistLine(def, collectedItemIds, locale),
          ),
          pw.SizedBox(height: 8),
          pw.Text(
            SponsorshipTransferStrings.t('st_checklist_informal_section', locale),
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10),
          ),
          pw.SizedBox(height: 4),
          ...TransferDocumentChecklistCatalog.informalItems.map(
            (def) => _checklistLine(def, collectedItemIds, locale),
          ),
          if (timelineEntries.isNotEmpty) ...[
            pw.SizedBox(height: 16),
            pw.Text(
              CaseTimelineStrings.t('ct_packet_appendix_heading', locale),
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 6),
            ...CaseTimelineService.sortedChronologically(timelineEntries).map(
              (e) => pw.Padding(
                padding: const pw.EdgeInsets.only(bottom: 4),
                child: pw.Text(
                  '${e.entryDate.toIso8601String().split('T').first} — ${e.title}',
                ),
              ),
            ),
          ],
          pw.SizedBox(height: 16),
          pw.Text(
            SponsorshipTransferStrings.t('st_packet_not_filing_form', locale),
            style: pw.TextStyle(
              fontSize: 10,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
        ],
      ),
    );

    final dir = await getTemporaryDirectory();
    final file = File(
      '${dir.path}/sponsorship_transfer_packet_${DateTime.now().millisecondsSinceEpoch}.pdf',
    );
    await file.writeAsBytes(await doc.save());
    return file;
  }

  pw.Widget _checklistLine(
    TransferChecklistItemDef def,
    Set<String> collectedItemIds,
    String locale,
  ) {
    final collected = collectedItemIds.contains(def.id);
    final mark = collected ? '[x]' : '[ ]';
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 4),
      child: pw.Text(
        '$mark ${SponsorshipTransferStrings.t(def.titleKey, locale)}',
      ),
    );
  }

  String _formatDate(DateTime date) =>
      '${date.day.toString().padLeft(2, '0')}/'
      '${date.month.toString().padLeft(2, '0')}/'
      '${date.year}';

  String _contractLabel(TransferContractType type, String locale) {
    return switch (type) {
      TransferContractType.fixedTerm =>
        SponsorshipTransferStrings.t('st_form_fixed_term', locale),
      TransferContractType.indefinite =>
        SponsorshipTransferStrings.t('st_form_indefinite', locale),
    };
  }

  String _noticeLabel(FormalNoticeStatus status, String locale) {
    return switch (status) {
      FormalNoticeStatus.yes =>
        SponsorshipTransferStrings.t('st_form_notice_yes', locale),
      FormalNoticeStatus.no =>
        SponsorshipTransferStrings.t('st_form_notice_no', locale),
      FormalNoticeStatus.notSure =>
        SponsorshipTransferStrings.t('st_form_notice_unsure', locale),
    };
  }

  String _statusLabel(TransferReadinessStatus status, String locale) {
    return switch (status) {
      TransferReadinessStatus.compliant =>
        SponsorshipTransferStrings.t('st_status_compliant', locale),
      TransferReadinessStatus.warning =>
        SponsorshipTransferStrings.t('st_status_warning', locale),
      TransferReadinessStatus.critical =>
        SponsorshipTransferStrings.t('st_status_critical', locale),
      TransferReadinessStatus.needsVerification =>
        SponsorshipTransferStrings.t('st_status_needs_verification', locale),
      TransferReadinessStatus.informational =>
        SponsorshipTransferStrings.t('st_status_informational', locale),
    };
  }

  Future<void> sharePacket(File file, {required String locale}) async {
    await Share.shareXFiles(
      [XFile(file.path)],
      text: SponsorshipTransferStrings.t('st_packet_share_text', locale),
    );
  }
}

final sponsorshipTransferPdfServiceProvider =
    Provider<SponsorshipTransferPdfService>(
  (ref) => SponsorshipTransferPdfService(),
);
