import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';
import 'package:raabta/features/eosb/domain/models/eosb_result.dart';
import 'package:raabta/features/eosb/presentation/l10n/eosb_strings.dart';

class EosbPdfService {
  Future<File> generateReport({
    required EosbResult result,
    required String locale,
    String employeeName = 'Employee',
    String companyName = 'Employer',
  }) async {
    final doc = pw.Document();
    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (context) => [
          pw.Header(
            level: 0,
            child: pw.Text(
              EosbStrings.t('eosb_title', locale),
              style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold),
            ),
          ),
          pw.Text(EosbStrings.t('eosb_disclaimer', locale),
              style: const pw.TextStyle(fontSize: 9)),
          pw.SizedBox(height: 16),
          pw.Text(
            '${EosbStrings.t('eosb_estimated_total', locale)}: '
            '${formatEosbCurrency(result.totalEntitlement)}',
            style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 12),
          pw.Text(
            EosbStrings.t('eosb_pdf_employee', locale)
                .replaceAll('{name}', employeeName),
          ),
          pw.Text(
            EosbStrings.t('eosb_pdf_company', locale)
                .replaceAll('{name}', companyName),
          ),
          pw.Text(
            EosbStrings.t('eosb_pdf_date', locale).replaceAll(
              '{date}',
              result.calculatedAt.toLocal().toString(),
            ),
          ),
          pw.SizedBox(height: 16),
          pw.Text(
            EosbStrings.t('eosb_pdf_breakdown', locale),
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 8),
          ...result.breakdown.map(
            (item) => pw.Padding(
              padding: const pw.EdgeInsets.only(bottom: 6),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Expanded(
                    child: pw.Text(EosbStrings.t(item.titleKey, locale)),
                  ),
                  pw.Text(formatEosbCurrency(item.amount)),
                ],
              ),
            ),
          ),
          if (result.comparison != null) ...[
            pw.SizedBox(height: 16),
            pw.Text(EosbStrings.t('eosb_comparison', locale),
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            pw.Text(
              EosbStrings.t('eosb_pdf_offer', locale).replaceAll(
                '{amount}',
                formatEosbCurrency(result.comparison!.employerOffer),
              ),
            ),
            pw.Text(
              EosbStrings.t('eosb_pdf_estimate', locale).replaceAll(
                '{amount}',
                formatEosbCurrency(result.comparison!.legalEstimate),
              ),
            ),
            pw.Text(
              EosbStrings.t('eosb_pdf_difference', locale).replaceAll(
                '{amount}',
                formatEosbCurrency(result.comparison!.difference),
              ),
            ),
          ],
        ],
      ),
    );

    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/eosb_report_${result.calculatedAt.millisecondsSinceEpoch}.pdf');
    await file.writeAsBytes(await doc.save());
    return file;
  }

  Future<void> shareReport(File file, {String locale = 'English'}) async {
    await Share.shareXFiles(
      [XFile(file.path)],
      text: EosbStrings.t('eosb_pdf_share_text', locale),
    );
  }
}

final eosbPdfServiceProvider = Provider<EosbPdfService>(
  (ref) => EosbPdfService(),
);
