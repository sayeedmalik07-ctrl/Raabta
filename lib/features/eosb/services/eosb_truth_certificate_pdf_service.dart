import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';
import 'package:raabta/core/pdf/pdf_font_loader.dart';
import 'package:raabta/features/eosb/domain/services/eosb_certificate_presentation_builder.dart';
import 'package:raabta/features/eosb/presentation/l10n/eosb_certificate_strings.dart';

/// Thrown when Truth Certificate PDF generation or sharing fails.
class EosbCertificatePdfException implements Exception {
  EosbCertificatePdfException(this.message, [this.cause]);

  final String message;
  final Object? cause;

  @override
  String toString() => 'EosbCertificatePdfException: $message';
}

/// Renders EOSB Truth Certificate PDF from frozen [EosbCertificatePresentation].
///
/// Never calls [EosbCalculationService] or any EOSB calculator.
class EosbTruthCertificatePdfService {
  /// Builds PDF bytes in-memory — used by tests and [generate].
  Future<Uint8List> generateBytes({
    required EosbCertificatePresentation presentation,
    PdfFontBundle? fonts,
  }) async {
    try {
      final fontBundle =
          fonts ?? await PdfFontLoader.forLocale(presentation.locale);
      final doc = pw.Document(
        theme: pw.ThemeData.withFont(
          base: fontBundle.base,
          bold: fontBundle.bold,
        ),
      );
      final rtl = presentation.isRtl;

      doc.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.symmetric(horizontal: 48, vertical: 44),
          textDirection: rtl ? pw.TextDirection.rtl : pw.TextDirection.ltr,
          footer: (context) => _buildFooter(presentation),
          build: (context) => _pageContent(presentation),
        ),
      );

      return doc.save();
    } catch (e, st) {
      Error.throwWithStackTrace(
        EosbCertificatePdfException('PDF generation failed', e),
        st,
      );
    }
  }

  Future<File> generate({
    required EosbCertificatePresentation presentation,
  }) async {
    try {
      final bytes = await generateBytes(presentation: presentation);
      final dir = await getTemporaryDirectory();
      final file = File(
        '${dir.path}/eosb_truth_certificate_${DateTime.now().millisecondsSinceEpoch}.pdf',
      );
      await file.writeAsBytes(bytes);
      return file;
    } on EosbCertificatePdfException {
      rethrow;
    } catch (e, st) {
      Error.throwWithStackTrace(
        EosbCertificatePdfException('PDF file write failed', e),
        st,
      );
    }
  }

  Future<void> share(File file, {required String locale}) async {
    try {
      await Share.shareXFiles(
        [XFile(file.path)],
        subject: EosbCertificateStrings.t('eosb_cert_pdf_share_subject', locale),
      );
    } catch (e, st) {
      Error.throwWithStackTrace(
        EosbCertificatePdfException('PDF share failed', e),
        st,
      );
    }
  }

  List<pw.Widget> _pageContent(EosbCertificatePresentation presentation) {
    return [
      _buildHeader(presentation),
      pw.SizedBox(height: 20),
      _buildEntitlementBlock(presentation),
      pw.SizedBox(height: 16),
      _buildConfidenceBlock(presentation),
      pw.SizedBox(height: 20),
      _sectionTitle(presentation.employmentSummaryTitle),
      pw.SizedBox(height: 8),
      _bodyLine(presentation.basicSalaryLabel),
      _bodyLine(presentation.serviceDurationLabel),
      _bodyLine(presentation.calculatedAtLabel),
      if (presentation.warningLines.isNotEmpty) ...[
        pw.SizedBox(height: 20),
        _sectionTitle(presentation.warningsSectionTitle),
        pw.SizedBox(height: 8),
        ...presentation.warningLines.map(_warningLine),
      ],
      pw.SizedBox(height: 20),
      _sectionTitle(presentation.legalBasisTitle),
      pw.SizedBox(height: 8),
      _bodyLine(presentation.legalSourceLabel),
      if (presentation.articleReferenceLabel.isNotEmpty)
        _bodyLine(presentation.articleReferenceLabel),
      _bodyLine(
        '${presentation.rulesetLabel}: ${presentation.rulesetVersionValue}',
      ),
      _bodyLine(presentation.sourceVerifiedLabel),
      pw.NewPage(),
      _sectionTitle(presentation.breakdownSectionTitle),
      pw.SizedBox(height: 8),
      ...presentation.breakdownLines.map(_breakdownRow),
      pw.SizedBox(height: 20),
      _sectionTitle(presentation.certificateIdHeading),
      pw.SizedBox(height: 6),
      _monoLine(presentation.certificateIdDisplay),
      pw.SizedBox(height: 12),
      _sectionTitle(presentation.fingerprintHeading),
      pw.SizedBox(height: 6),
      _monoLine(presentation.fingerprintShort),
      pw.SizedBox(height: 20),
      _trustStateBlock(presentation),
      if (presentation.showVerificationQr) ...[
        pw.SizedBox(height: 16),
        _verificationQrBlock(presentation),
      ],
      pw.SizedBox(height: 16),
      pw.Text(
        presentation.confidenceDisclaimer,
        style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700),
      ),
      pw.SizedBox(height: 10),
      pw.Text(
        presentation.disclaimer,
        style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700),
      ),
    ];
  }

  pw.Widget _buildHeader(EosbCertificatePresentation p) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.stretch,
      children: [
        pw.Text(
          p.brandLabel,
          style: pw.TextStyle(
            fontSize: 14,
            fontWeight: pw.FontWeight.bold,
            letterSpacing: 3,
            color: PdfColors.grey700,
          ),
          textAlign: pw.TextAlign.center,
        ),
        pw.SizedBox(height: 6),
        pw.Text(
          p.certificateHeading,
          style: pw.TextStyle(
            fontSize: 22,
            fontWeight: pw.FontWeight.bold,
          ),
          textAlign: pw.TextAlign.center,
        ),
        pw.SizedBox(height: 4),
        pw.Container(
          height: 2,
          color: PdfColors.grey400,
        ),
      ],
    );
  }

  pw.Widget _buildEntitlementBlock(EosbCertificatePresentation p) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.stretch,
      children: [
        pw.Text(
          p.entitlementHeading,
          style: pw.TextStyle(
            fontSize: 12,
            color: PdfColors.grey700,
          ),
          textAlign: pw.TextAlign.center,
        ),
        pw.SizedBox(height: 8),
        pw.Text(
          p.entitlementAmountDisplay,
          style: pw.TextStyle(
            fontSize: 32,
            fontWeight: pw.FontWeight.bold,
          ),
          textAlign: pw.TextAlign.center,
        ),
      ],
    );
  }

  pw.Widget _buildConfidenceBlock(EosbCertificatePresentation p) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: pw.BorderRadius.circular(4),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.stretch,
        children: [
          _bodyLine(p.inputCompletenessLabel),
          pw.SizedBox(height: 4),
          _bodyLine(p.estimateConfidenceLabel),
        ],
      ),
    );
  }

  pw.Widget _trustStateBlock(EosbCertificatePresentation p) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey100,
        border: pw.Border.all(color: PdfColors.grey400),
        borderRadius: pw.BorderRadius.circular(4),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.stretch,
        children: [
          pw.Text(
            p.trustStateHeading,
            style: pw.TextStyle(
              fontSize: 11,
              fontWeight: pw.FontWeight.bold,
              letterSpacing: 1,
            ),
            textAlign: pw.TextAlign.center,
          ),
          pw.SizedBox(height: 4),
          pw.Text(
            p.trustStateLabel,
            style: const pw.TextStyle(fontSize: 10),
            textAlign: pw.TextAlign.center,
          ),
          if (p.verificationNotice.isNotEmpty) ...[
            pw.SizedBox(height: 6),
            pw.Text(
              p.verificationNotice,
              style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700),
              textAlign: pw.TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }

  pw.Widget _verificationQrBlock(EosbCertificatePresentation p) {
    final url = p.verificationUrl!;
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.stretch,
      children: [
        pw.Center(
          child: pw.BarcodeWidget(
            barcode: pw.Barcode.qrCode(),
            data: url,
            width: 96,
            height: 96,
          ),
        ),
        pw.SizedBox(height: 6),
        pw.Text(
          url,
          style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600),
          textAlign: pw.TextAlign.center,
        ),
      ],
    );
  }

  pw.Widget _sectionTitle(String text) {
    return pw.Text(
      text,
      style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold),
    );
  }

  pw.Widget _bodyLine(String text) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 4),
      child: pw.Text(text, style: const pw.TextStyle(fontSize: 11)),
    );
  }

  pw.Widget _warningLine(String text) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 6),
      child: pw.Text(
        '• $text',
        style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey800),
      ),
    );
  }

  pw.Widget _monoLine(String text) {
    return pw.Text(
      text,
      style: const pw.TextStyle(
        fontSize: 10,
        letterSpacing: 0.5,
      ),
    );
  }

  pw.Widget _breakdownRow(EosbCertificateBreakdownLinePresentation line) {
    final amountText = line.estimatedSuffix.isEmpty
        ? line.amount
        : '${line.amount} ${line.estimatedSuffix}';
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 6),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Expanded(
            child: pw.Text(line.title, style: const pw.TextStyle(fontSize: 11)),
          ),
          pw.SizedBox(width: 8),
          pw.SizedBox(
            width: 120,
            child: pw.Text(
              amountText,
              style: const pw.TextStyle(fontSize: 11),
              textAlign: pw.TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget _buildFooter(EosbCertificatePresentation p) {
    return pw.Container(
      padding: const pw.EdgeInsets.only(top: 8),
      decoration: const pw.BoxDecoration(
        border: pw.Border(top: pw.BorderSide(color: PdfColors.grey300)),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.stretch,
        children: [
          pw.Text(
            p.certificateIdDisplay,
            style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600),
            textAlign: pw.TextAlign.center,
          ),
          pw.Text(
            p.rulesetVersionValue,
            style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600),
            textAlign: pw.TextAlign.center,
          ),
          pw.Text(
            p.trustStateLabel,
            style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600),
            textAlign: pw.TextAlign.center,
          ),
        ],
      ),
    );
  }
}

final eosbTruthCertificatePdfServiceProvider =
    Provider<EosbTruthCertificatePdfService>(
  (ref) => EosbTruthCertificatePdfService(),
);
