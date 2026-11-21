import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';
import 'package:raabta/features/health_insurance/data/claim_dispute_checklist_catalog.dart';
import 'package:raabta/features/health_insurance/data/claim_dispute_step_catalog.dart';
import 'package:raabta/features/health_insurance/data/models/claim_dispute_models.dart';
import 'package:raabta/features/health_insurance/presentation/l10n/health_insurance_strings.dart';

/// Personal-record PDF export for claim denial disputes.
class ClaimDisputePdfService {
  Future<File> generateSummary({
    required HealthInsuranceClaimDispute dispute,
    required String locale,
    required List<ClaimDisputeChecklistItemDef> checklistItems,
    required List<ClaimDisputeStepDef> steps,
  }) async {
    final doc = pw.Document();
    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (context) => [
          pw.Header(
            level: 0,
            child: pw.Text(
              HealthInsuranceStrings.t('hi_denial_export_title', locale),
              style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
            ),
          ),
          pw.Text(
            HealthInsuranceStrings.t('hi_denial_export_disclaimer', locale),
            style: const pw.TextStyle(fontSize: 9),
          ),
          pw.SizedBox(height: 12),
          pw.Text(
            HealthInsuranceStrings.t('hi_denial_intake_insurer', locale),
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
          ),
          pw.Text(dispute.insurerName),
          pw.SizedBox(height: 8),
          pw.Text(
            HealthInsuranceStrings.t('hi_denial_intake_reason', locale),
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
          ),
          pw.Text(
            HealthInsuranceStrings.t(dispute.denialReason.labelKey, locale),
          ),
          if (dispute.denialDate != null) ...[
            pw.SizedBox(height: 8),
            pw.Text(
              HealthInsuranceStrings.t('hi_denial_intake_date', locale),
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            ),
            pw.Text(dispute.denialDate!.toIso8601String().split('T').first),
          ],
          pw.SizedBox(height: 16),
          pw.Text(
            HealthInsuranceStrings.t('hi_denial_steps_title', locale),
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 6),
          for (final step in steps)
            pw.Padding(
              padding: const pw.EdgeInsets.only(bottom: 4),
              child: pw.Text(
                '${dispute.isStepComplete(step.id) ? "[✓]" : "[ ]"} '
                '${HealthInsuranceStrings.t(step.titleKey, locale)}'
                '${dispute.completedSteps[step.id] != null ? " — ${dispute.completedSteps[step.id]!.split("T").first}" : ""}',
              ),
            ),
          pw.SizedBox(height: 16),
          pw.Text(
            HealthInsuranceStrings.t('hi_denial_checklist_title', locale),
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 6),
          for (final item in checklistItems)
            pw.Padding(
              padding: const pw.EdgeInsets.only(bottom: 4),
              child: pw.Text(
                '${dispute.documentRefs.containsKey(item.id) ? "[attached]" : "[missing]"} '
                '${HealthInsuranceStrings.t(item.titleKey, locale)}',
              ),
            ),
        ],
      ),
    );

    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/claim_dispute_${dispute.disputeId}.pdf');
    await file.writeAsBytes(await doc.save());
    return file;
  }

  Future<void> sharePdf(File file, String locale) async {
    await Share.shareXFiles(
      [XFile(file.path)],
      text: HealthInsuranceStrings.t('hi_denial_export_share_caption', locale),
    );
  }
}

final claimDisputePdfServiceProvider = Provider<ClaimDisputePdfService>(
  (ref) => ClaimDisputePdfService(),
);
