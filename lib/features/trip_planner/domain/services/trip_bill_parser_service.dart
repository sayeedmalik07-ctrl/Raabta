import 'package:raabta/features/trip_planner/data/fair_price_guide_catalog.dart';
import 'package:raabta/features/trip_planner/domain/models/fair_price_models.dart';
import 'package:raabta/services/documents/parsers/receipt_parser.dart';
import 'package:raabta/services/documents/utils/ocr_text_utils.dart';

/// Deterministic bill extraction — pattern matching before any AI.
abstract final class TripBillParserService {
  static ParsedTripBill parse(String ocrText) {
    final trimmed = ocrText.trim();
    if (trimmed.length < 12) {
      return const ParsedTripBill(
        totalQar: null,
        confidence: 0,
        isPlausible: false,
      );
    }

    final receipt = ReceiptParser.parse(trimmed);
    final lines = _extractLineItems(trimmed);
    final total = receipt?.price ?? _extractStandaloneTotal(trimmed);

    var confidence = receipt?.confidence ?? 0.0;
    if (total != null && confidence < 0.35) confidence = 0.45;
    if (lines.isNotEmpty) confidence += 0.15;
    confidence = confidence.clamp(0, 0.85);

    final hasTotal = total != null && total > 0;
    final hasLines = lines.isNotEmpty;
    final plausible = hasTotal && (hasLines || (receipt?.store != null));

    return ParsedTripBill(
      totalQar: total,
      store: receipt?.store,
      lines: lines,
      confidence: confidence,
      isPlausible: plausible,
    );
  }

  static List<BillItemComparison> compare(ParsedTripBill bill) {
    final comparisons = <BillItemComparison>[];

    for (final line in bill.lines) {
      final guide = FairPriceGuideCatalog.matchLine(line.label);
      comparisons.add(
        BillItemComparison(
          paidLabel: line.label,
          paidAmount: line.amountQar,
          guideItemId: guide?.id,
          guideMin: guide?.minQar,
          guideMax: guide?.maxQar,
          assessment: guide == null
              ? BillRangeAssessment.unknown
              : _assess(line.amountQar, guide.minQar, guide.maxQar),
        ),
      );
    }

    if (bill.totalQar != null && comparisons.isEmpty) {
      comparisons.add(
        BillItemComparison(
          paidLabel: 'Total',
          paidAmount: bill.totalQar!,
          assessment: BillRangeAssessment.unknown,
        ),
      );
    }

    return comparisons;
  }

  static BillRangeAssessment _assess(double paid, double min, double max) {
    if (paid >= min && paid <= max) return BillRangeAssessment.inTypicalRange;
    if (paid < min) return BillRangeAssessment.belowTypical;
    final overPct = (paid - max) / max;
    if (overPct <= 0.25) return BillRangeAssessment.somewhatAbove;
    return BillRangeAssessment.notablyAbove;
  }

  static double? _extractStandaloneTotal(String text) {
    return OcrTextUtils.amountNearAnchors(text, const [
      'Grand Total',
      'Total Amount',
      'Total',
      'Amount Paid',
      'Net Total',
      'إجمالي',
      'المجموع',
      'الإجمالي',
      'AMOUNT',
    ]);
  }

  static List<ParsedBillLine> _extractLineItems(String text) {
    final results = <ParsedBillLine>[];
    final seen = <String>{};
    final linePattern = RegExp(
      r'^(.{2,60}?)\s+(?:QAR\s?|QR\s?|ر\.?\s?)?(\d{1,4}(?:[.,]\d{1,2})?)\s*(?:QAR|QR)?$',
      caseSensitive: false,
      multiLine: true,
    );

    for (final match in linePattern.allMatches(text)) {
      final label = match.group(1)?.trim() ?? '';
      final amountStr = match.group(2)?.replaceAll(',', '.') ?? '';
      if (label.isEmpty) continue;
      final lower = label.toLowerCase();
      if (RegExp(r'^(total|subtotal|tax|vat|change|cash|paid|balance)')
          .hasMatch(lower)) {
        continue;
      }
      final amount = double.tryParse(amountStr);
      if (amount == null || amount <= 0 || amount > 50000) continue;
      final key = '$label|$amount';
      if (seen.add(key)) {
        results.add(ParsedBillLine(label: label, amountQar: amount));
      }
    }

    if (results.length > 12) return results.take(12).toList();
    return results;
  }
}
