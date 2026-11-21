import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raabta/features/trip_planner/data/fair_price_guide_catalog.dart';
import 'package:raabta/features/trip_planner/domain/models/fair_price_models.dart';
import 'package:raabta/features/trip_planner/domain/services/trip_bill_parser_service.dart';
import 'package:raabta/features/trip_planner/presentation/l10n/trip_strings.dart';
import 'package:raabta/services/ai/claude_ai_service.dart';

class TripBillScanAiService {
  TripBillScanAiService(this._claude);

  final ClaudeAIService _claude;

  static const requestType = 'trip_planner_bill_scan';

  Future<String> assessBill({
    required ParsedTripBill bill,
    required List<BillItemComparison> comparisons,
    required String locale,
  }) async {
    final guideSummary = FairPriceGuideCatalog.items
        .map(
          (i) =>
              '${i.id}: QAR ${i.minQar}-${i.maxQar} (${TripStrings.t(i.nameKey, locale)})',
        )
        .join('\n');

    final paidSummary = comparisons
        .map(
          (c) =>
              '${c.paidLabel}: QAR ${c.paidAmount.toStringAsFixed(2)}'
              '${c.guideItemId != null ? ' vs guide ${c.guideItemId}' : ''}',
        )
        .join('\n');

    final reply = await _claude.sendMessage(
      '''
You help visitors in Qatar sanity-check a receipt against typical price RANGES (not live prices).
Output language: $locale

PAID (from OCR — may contain errors):
Store: ${bill.store ?? 'unknown'}
Total: ${bill.totalQar?.toStringAsFixed(2) ?? 'unknown'} QAR
Lines:
$paidSummary

REFERENCE TYPICAL RANGES (QAR):
$guideSummary

Return ONLY valid JSON:
{
  "summary": "3-5 sentences, plain language, hedged — never accuse of scam/fraud",
  "items": [{"label":"string","assessment":"in_typical_range|somewhat_above|notably_above|below_typical|unknown","note":"short optional"}]
}

RULES:
- Compare against TYPICAL RANGES only — prices vary by venue and season.
- NEVER say "scam", "fraud", "overcharging", or "you are being cheated".
- Use phrasing like "somewhat above typical range" or "within typical range".
- If OCR data is unclear, say so — do not invent items.
- Do not add legal or dispute advice.
''',
      language: locale,
      requestType: requestType,
    );

    return _parseSummary(reply);
  }

  String _parseSummary(String raw) {
    var text = raw.trim();
    if (text.startsWith('```')) {
      text = text.replaceFirst(RegExp(r'^```(?:json)?\s*'), '');
      text = text.replaceFirst(RegExp(r'\s*```$'), '');
    }
    final start = text.indexOf('{');
    final end = text.lastIndexOf('}');
    if (start >= 0 && end > start) {
      try {
        final map = jsonDecode(text.substring(start, end + 1)) as Map<String, dynamic>;
        final summary = map['summary'] as String?;
        if (summary != null && summary.trim().isNotEmpty) return summary.trim();
      } catch (_) {}
    }
    return text.length > 600 ? '${text.substring(0, 600)}…' : text;
  }
}

final tripBillScanAiServiceProvider = Provider<TripBillScanAiService>((ref) {
  return TripBillScanAiService(ref.watch(claudeAIServiceProvider));
});

final tripBillScanProcessorProvider =
    Provider<TripBillScanProcessor>((ref) => TripBillScanProcessor(ref));

class TripBillScanProcessor {
  TripBillScanProcessor(this._ref);

  final Ref _ref;

  Future<TripBillScanResult> process({
    required String ocrText,
    required String locale,
  }) async {
    final parsed = TripBillParserService.parse(ocrText);
    if (!parsed.isPlausible) {
      return TripBillScanResult(
        parsed: parsed,
        comparisons: const [],
        summary: '',
        usedAi: false,
      );
    }

    final comparisons = TripBillParserService.compare(parsed);
    var summary = '';
    var usedAi = false;

    try {
      summary = await _ref.read(tripBillScanAiServiceProvider).assessBill(
            bill: parsed,
            comparisons: comparisons,
            locale: locale,
          );
      usedAi = summary.isNotEmpty;
    } catch (_) {
      summary = _fallbackSummary(comparisons, locale);
    }

    return TripBillScanResult(
      parsed: parsed,
      comparisons: comparisons,
      summary: summary,
      usedAi: usedAi,
    );
  }

  String _fallbackSummary(List<BillItemComparison> comparisons, String locale) {
    if (comparisons.isEmpty) {
      return TripStrings.t('bill_scan_summary_only_total', locale);
    }
    final above = comparisons
        .where(
          (c) =>
              c.assessment == BillRangeAssessment.somewhatAbove ||
              c.assessment == BillRangeAssessment.notablyAbove,
        )
        .length;
    if (above == 0) {
      return TripStrings.t('bill_scan_summary_in_range', locale);
    }
    return TripStrings.format('bill_scan_summary_some_above', locale, {
      'count': '$above',
      'total': '${comparisons.length}',
    });
  }
}
