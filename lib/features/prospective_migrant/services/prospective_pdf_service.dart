import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:raabta/features/eosb/data/models/home_country_support_models.dart';
import 'package:raabta/features/eosb/domain/models/eosb_result.dart';
import 'package:raabta/features/eosb/domain/services/home_country_support_service.dart';
import 'package:raabta/features/eosb/presentation/l10n/eosb_strings.dart';
import 'package:raabta/features/prospective_migrant/data/qvc_stage_catalog.dart';
import 'package:raabta/features/prospective_migrant/domain/models/prospective_profile.dart';
import 'package:raabta/features/prospective_migrant/presentation/l10n/prospective_migrant_strings.dart';
import 'package:share_plus/share_plus.dart';

/// Guest-mode PDF export — no auth required (local generation only).
class ProspectivePdfService {
  const ProspectivePdfService();

  Future<File> generate({
    required ProspectiveProfile profile,
    required EosbResult? previewResult,
    required String locale,
  }) async {
    final doc = pw.Document();
    final bys = const HomeCountrySupportService().resolveBeforeYouSign(
      HomeCountryUserContext(nationality: profile.nationalityLabel),
    );

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (context) => [
          pw.Header(
            level: 0,
            child: pw.Text(
              ProspectiveMigrantStrings.t('pm_pdf_title', locale),
              style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold),
            ),
          ),
          pw.Text(
            ProspectiveMigrantStrings.t('pm_pdf_disclaimer', locale),
            style: const pw.TextStyle(fontSize: 9),
          ),
          pw.SizedBox(height: 12),
          pw.Text(
            '${ProspectiveMigrantStrings.t('pm_country_heading', locale)}: ${profile.nationalityLabel}',
          ),
          pw.Text(
            '${EosbStrings.t('eosb_company_name', locale)}: ${profile.contract.companyName}',
          ),
          if (profile.roleTitle.isNotEmpty)
            pw.Text(
              '${ProspectiveMigrantStrings.t('pm_role_label', locale)}: ${profile.roleTitle}',
            ),
          pw.Text(
            '${EosbStrings.t('eosb_gratuity', locale)} preview salary: '
            '${formatEosbCurrency(profile.contract.basicSalary)}',
          ),
          if (profile.keyTerms.isNotEmpty) ...[
            pw.SizedBox(height: 8),
            pw.Text(ProspectiveMigrantStrings.t('pm_key_terms_label', locale),
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            pw.Text(profile.keyTerms),
          ],
          if (previewResult != null) ...[
            pw.SizedBox(height: 16),
            pw.Text(
              ProspectiveMigrantStrings.t('pm_preview_heading', locale),
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            ),
            pw.Text(
              '${EosbStrings.t('eosb_estimated_total', locale)}: '
              '${formatEosbCurrency(previewResult.totalEntitlement)}',
            ),
            ...previewResult.breakdown.map(
              (item) => pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Expanded(
                    child: pw.Text(EosbStrings.t(item.titleKey, locale)),
                  ),
                  pw.Text(formatEosbCurrency(item.amount)),
                ],
              ),
            ),
          ],
          if (bys.checklist != null) ...[
            pw.SizedBox(height: 16),
            pw.Text(EosbStrings.t('eosb_bys_section_title', locale),
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            pw.Text(EosbStrings.t(bys.checklist!.maxFeeRuleKey, locale)),
            ...bys.checklist!.redFlagKeys.map(
              (key) => pw.Bullet(text: EosbStrings.t(key, locale)),
            ),
          ],
          pw.SizedBox(height: 16),
          pw.Text(ProspectiveMigrantStrings.t('pm_qvc_heading', locale),
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
          ...QvcStageCatalog.steps.map(
            (step) => pw.Bullet(
              text:
                  '${ProspectiveMigrantStrings.t(step.titleKey, locale)} — '
                  '${profile.qvcStepsChecked[step.id] == true ? "✓" : "○"}',
            ),
          ),
        ],
      ),
    );

    final dir = await getTemporaryDirectory();
    final file = File(
      '${dir.path}/prospective_migrant_${DateTime.now().millisecondsSinceEpoch}.pdf',
    );
    await file.writeAsBytes(await doc.save());
    return file;
  }

  Future<void> share(File file, String locale) async {
    await Share.shareXFiles(
      [XFile(file.path)],
      text: ProspectiveMigrantStrings.t('pm_pdf_share_caption', locale),
    );
  }
}
