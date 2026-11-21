import 'dart:io';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:raabta/core/l10n/app_locale.dart';
import 'package:raabta/core/pdf/pdf_font_loader.dart';
import 'package:raabta/features/scam_shield/report_pack/report_pack_content_builder.dart';
import 'package:raabta/features/scam_shield/report_pack/report_pack_pdf_typography.dart';
import 'package:raabta/features/scam_shield/report_pack/report_pack_temp_files.dart';

class ReportPackPdfService {
  /// Helvetica lacks U+2014; keep PDF ASCII-safe without changing plain-text export.
  static String _pdfText(String value) =>
      value.replaceAll(RegExp(r'[\u2014\u2013]'), '-');

  Future<File> generate({
    required ReportPackSnapshot snapshot,
    String? uid,
    String? replacePreviousPath,
  }) async {
    final resolved = ReportPackTempFiles.requireUidOrThrow(uid: uid);
    final bundles = await PdfFontLoader.forBilingualPack();
    final typography = ReportPackPdfTypography(
      latin: bundles.latin,
      arabic: bundles.arabic,
    );
    final rtl = AppLocale.isRtl(snapshot.locale);

    final doc = pw.Document(
      theme: pw.ThemeData.withFont(
        base: typography.latin.base,
        bold: typography.latin.bold,
      ),
    );

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        textDirection: rtl ? pw.TextDirection.rtl : pw.TextDirection.ltr,
        build: (context) => [
          pw.Text(
            _pdfText(snapshot.title),
            style: typography.style(fontSize: 20, bold: true),
          ),
          pw.SizedBox(height: 16),
          for (final section in snapshot.sections) ...[
            pw.Text(
              _pdfText(section.heading),
              style: typography.style(fontSize: 12, bold: true),
            ),
            pw.SizedBox(height: 6),
            for (final line in section.lines)
              pw.Padding(
                padding: const pw.EdgeInsets.only(bottom: 6),
                child: pw.Text(
                  _pdfText(line),
                  style: typography.style(fontSize: 10),
                ),
              ),
            pw.SizedBox(height: 10),
          ],
          pw.Divider(),
          pw.Text(
            _pdfText(snapshot.disclaimer),
            style: typography.style(fontSize: 9),
          ),
        ],
      ),
    );

    final bytes = await doc.save();
    final file = await ReportPackTempFiles.writeTemp(
      bytes: bytes,
      suffix: 'pdf',
      uid: resolved,
    );
    if (replacePreviousPath != null &&
        replacePreviousPath.isNotEmpty &&
        replacePreviousPath != file.path) {
      await ReportPackTempFiles.discard(replacePreviousPath, uid: resolved);
    }
    return file;
  }
}
