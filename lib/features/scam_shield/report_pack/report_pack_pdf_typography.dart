import 'package:pdf/widgets.dart' as pw;
import 'package:raabta/core/pdf/pdf_font_loader.dart';

/// Latin primary + Arabic fallback for bilingual report-pack PDFs.
class ReportPackPdfTypography {
  const ReportPackPdfTypography({
    required this.latin,
    required this.arabic,
  });

  final PdfFontBundle latin;
  final PdfFontBundle arabic;

  pw.TextStyle style({
    double fontSize = 10,
    bool bold = false,
  }) {
    return pw.TextStyle(
      fontSize: fontSize,
      font: bold ? latin.bold : latin.base,
      fontFallback: [arabic.base],
      fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
    );
  }
}
