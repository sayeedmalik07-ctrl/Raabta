import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';
import 'package:raabta/features/quick_actions/warranty_shield/l10n/warranty_strings.dart';
import 'package:raabta/features/quick_actions/warranty_shield/models/warranty_item.dart';

/// Personal-record PDF export for warranty claim drafts (no QR — letter only).
class WarrantyClaimPdfService {
  Future<File> generateLetter({
    required WarrantyItem item,
    required String draftLetter,
    required String locale,
  }) async {
    final doc = pw.Document();
    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.symmetric(horizontal: 48, vertical: 44),
        build: (context) => [
          pw.Text(
            WarrantyStrings.t('warr_claim_pdf_title', locale),
            style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 8),
          pw.Text(
            WarrantyStrings.t('warr_claim_disclaimer', locale),
            style: const pw.TextStyle(fontSize: 9),
          ),
          pw.SizedBox(height: 12),
          pw.Text(
            '${item.productName} · ${item.retailer.isNotEmpty ? item.retailer : item.brand}',
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 16),
          pw.Text(draftLetter, style: const pw.TextStyle(fontSize: 11)),
        ],
      ),
    );

    final dir = await getTemporaryDirectory();
    final file = File(
      '${dir.path}/warranty_claim_${item.id}_${DateTime.now().millisecondsSinceEpoch}.pdf',
    );
    await file.writeAsBytes(await doc.save());
    return file;
  }

  Future<void> sharePdf(File file, String locale) async {
    await Share.shareXFiles(
      [XFile(file.path)],
      text: WarrantyStrings.t('warr_claim_pdf_share_caption', locale),
    );
  }
}

final warrantyClaimPdfServiceProvider = Provider<WarrantyClaimPdfService>(
  (ref) => WarrantyClaimPdfService(),
);
