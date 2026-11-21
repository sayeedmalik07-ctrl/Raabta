import 'package:raabta/services/documents/document_extraction_config.dart';
import 'package:raabta/services/documents/utils/date_parse_utils.dart';
import 'package:raabta/services/documents/utils/ocr_text_utils.dart';

/// Best-effort generic receipt extraction (lower default confidence).
class ReceiptParser {
  ReceiptParser._();

  static const _totalAnchors = [
    'Grand Total',
    'Total Amount',
    'Total',
    'Amount Paid',
    'Net Total',
    'إجمالي',
    'المجموع',
    'الإجمالي',
  ];

  static ReceiptParseResult? parse(String ocrText) {
    if (!_looksLikeReceipt(ocrText)) return null;

    final store = OcrTextUtils.firstLineLikelyVendor(ocrText);
    final purchaseDate = DateParseUtils.parseFirst(ocrText);
    final price = OcrTextUtils.amountNearAnchors(ocrText, _totalAnchors);
    final productName = _guessProductName(ocrText);

    var confidence = 0.0;
    if (price != null) confidence += 0.3;
    if (purchaseDate != null) confidence += 0.2;
    if (store != null) confidence += 0.15;
    if (productName != null) confidence += 0.1;

    confidence = confidence.clamp(
      0.0,
      DocumentExtractionConfig.receiptLocalConfidenceCap,
    );

    if (confidence < 0.35) return null;

    return ReceiptParseResult(
      store: store,
      purchaseDate: purchaseDate,
      price: price,
      productName: productName,
      warrantyPeriodGuessMonths: _guessWarrantyMonths(productName, ocrText),
      confidence: confidence,
    );
  }

  static bool _looksLikeReceipt(String text) {
    return OcrTextUtils.containsAny(text, [
      'receipt',
      'tax invoice',
      'invoice',
      'فاتورة',
      'إيصال',
      'paid',
      'cash',
      'visa',
      'mastercard',
      ..._totalAnchors,
    ]);
  }

  static String? _guessProductName(String text) {
    final lines = OcrTextUtils.lines(text);
    final skip = RegExp(
      r'^(total|subtotal|tax|vat|qty|quantity|cash|change|thank|receipt|date|time|\d)',
      caseSensitive: false,
    );
    for (final line in lines) {
      if (line.length < 4 || line.length > 80) continue;
      if (skip.hasMatch(line)) continue;
      if (RegExp(r'^\d+[xX]').hasMatch(line)) {
        final cleaned = line.replaceFirst(RegExp(r'^\d+[xX]\s*'), '').trim();
        if (cleaned.length >= 3) return cleaned;
      }
      if (RegExp(r'[A-Za-z\u0600-\u06FF]{4,}').hasMatch(line) &&
          !line.toLowerCase().contains('total')) {
        return line;
      }
    }
    return null;
  }

  static int? _guessWarrantyMonths(String? productName, String text) {
    final blob = '${productName ?? ''} ${text.toLowerCase()}';
    if (RegExp(r'phone|laptop|tv|electronic|mobile|computer|tablet|refrigerator|washing')
        .hasMatch(blob)) {
      return 24;
    }
    if (RegExp(r'furniture|mattress|sofa|bed').hasMatch(blob)) {
      return 12;
    }
    return null;
  }
}

class ReceiptParseResult {
  const ReceiptParseResult({
    this.store,
    this.purchaseDate,
    this.price,
    this.productName,
    this.warrantyPeriodGuessMonths,
    required this.confidence,
  });

  final String? store;
  final DateTime? purchaseDate;
  final double? price;
  final String? productName;
  final int? warrantyPeriodGuessMonths;
  final double confidence;
}
