import 'dart:io';

import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:raabta/core/l10n/app_locale.dart';
import 'package:raabta/core/pdf/pdf_font_loader.dart';
import 'package:raabta/features/leaving_qatar/data/departure_plan/leaving_qatar_departure_plan_models.dart';
import 'package:raabta/features/leaving_qatar/data/departure_plan/leaving_qatar_departure_plan_pdf_content.dart';

class LeavingQatarDeparturePlanPdfService {
  Future<File> generate({
    required LeavingQatarDeparturePlanState plan,
    required String locale,
    DateTime? generatedAt,
  }) async {
    final at = generatedAt ?? DateTime.now();
    final snapshot = LeavingQatarDeparturePlanPdfContent.build(
      plan: plan,
      locale: locale,
      generatedAt: at,
    );
    final dateLabel = DateFormat.yMMMMd().format(at);
    final fonts = await PdfFontLoader.forLocale(locale);
    final rtl = AppLocale.isRtl(locale);

    final doc = pw.Document(
      theme: pw.ThemeData.withFont(
        base: fonts.base,
        bold: fonts.bold,
      ),
    );
    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        textDirection: rtl ? pw.TextDirection.rtl : pw.TextDirection.ltr,
        build: (context) => [
          pw.Header(
            level: 0,
            child: pw.Text(
              snapshot.title,
              style: pw.TextStyle(
                fontSize: 22,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
          ),
          pw.Text(
            _brandingDateLine(
              snapshot.brandingLine,
              dateLabel,
              locale,
            ),
            style: const pw.TextStyle(fontSize: 10),
          ),
          pw.SizedBox(height: 12),
          pw.Text(snapshot.intro, style: const pw.TextStyle(fontSize: 11)),
          pw.SizedBox(height: 12),
          pw.Text(
            snapshot.departureDateLine,
            style: pw.TextStyle(
              fontSize: 11,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 8),
          pw.Text(snapshot.progressLine, style: const pw.TextStyle(fontSize: 11)),
          pw.SizedBox(height: 16),
          for (final row in snapshot.rows) ...[
            pw.Text(
              row.title,
              style: pw.TextStyle(
                fontSize: 12,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.Text(
              _joinTimingStatus(row.timingLabel, row.statusLabel, locale),
              style: const pw.TextStyle(fontSize: 10),
            ),
            pw.Text(
              row.referenceLabel,
              style: const pw.TextStyle(fontSize: 9),
            ),
            pw.SizedBox(height: 10),
          ],
          pw.Divider(),
          pw.Text(
            snapshot.disclaimer,
            style: const pw.TextStyle(fontSize: 9),
          ),
        ],
      ),
    );

    final dir = await getTemporaryDirectory();
    final file = File(
      '${dir.path}/raabta_departure_plan_${at.millisecondsSinceEpoch}.pdf',
    );
    await file.writeAsBytes(await doc.save());
    return file;
  }

  static String _brandingDateLine(
    String branding,
    String dateLabel,
    String locale,
  ) {
    final sep = AppLocale.isRtl(locale) ? '\u00b7' : '-';
    return '$branding $sep $dateLabel';
  }

  static String _joinTimingStatus(
    String timing,
    String status,
    String locale,
  ) {
    final sep = AppLocale.isRtl(locale) ? '\u00b7' : '-';
    return '$timing $sep $status';
  }
}
