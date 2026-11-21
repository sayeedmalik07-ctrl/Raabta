import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raabta/services/ai/claude_ai_service.dart'
    show claudeAIServiceProvider;
import 'package:raabta/services/documents/utils/date_parse_utils.dart';

import 'expiry_date_claude_normalizer.dart';

class ExpiryDateScanResult {
  const ExpiryDateScanResult({
    required this.rawOcrText,
    required this.candidates,
    required this.isAmbiguous,
    this.notes,
    this.source = ExpiryDateParseSource.local,
  });

  final String rawOcrText;
  final List<DateTime> candidates;
  final bool isAmbiguous;
  final String? notes;
  final ExpiryDateParseSource source;

  DateTime? get resolvedDate =>
      !isAmbiguous && candidates.length == 1 ? candidates.first : null;
}

enum ExpiryDateParseSource { local, claude }

/// OCR text → local date parse → Claude fallback for ambiguous formats.
class ExpiryDateScanService {
  ExpiryDateScanService(this._claudeNormalizer);

  final ExpiryDateClaudeNormalizer _claudeNormalizer;

  static const _expiryLabels = [
    'exp',
    'expiry',
    'expires',
    'best before',
    'best-before',
    'use by',
    'use-by',
    'bb',
    'bbd',
  ];

  Future<ExpiryDateScanResult> parseOcrText({
    required String ocrText,
    required String uiLanguage,
  }) async {
    final trimmed = ocrText.trim();
    if (trimmed.isEmpty) {
      return const ExpiryDateScanResult(
        rawOcrText: '',
        candidates: [],
        isAmbiguous: false,
      );
    }

    final nearLabel = DateParseUtils.parseNearLabels(trimmed, _expiryLabels);
    if (nearLabel != null) {
      return ExpiryDateScanResult(
        rawOcrText: trimmed,
        candidates: [nearLabel],
        isAmbiguous: false,
        source: ExpiryDateParseSource.local,
      );
    }

    final local = DateParseUtils.parseFirst(trimmed);
    final ambiguousLocal = _ambiguousDayMonthCandidates(trimmed);
    if (ambiguousLocal.length > 1) {
      return ExpiryDateScanResult(
        rawOcrText: trimmed,
        candidates: ambiguousLocal,
        isAmbiguous: true,
        notes: 'Day/month order unclear in OCR text.',
        source: ExpiryDateParseSource.local,
      );
    }
    if (local != null) {
      return ExpiryDateScanResult(
        rawOcrText: trimmed,
        candidates: [local],
        isAmbiguous: false,
        source: ExpiryDateParseSource.local,
      );
    }

    final claude = await _claudeNormalizer.normalize(
      ocrText: trimmed,
      uiLanguage: uiLanguage,
    );
    return ExpiryDateScanResult(
      rawOcrText: trimmed,
      candidates: claude.candidates,
      isAmbiguous: claude.isAmbiguous || claude.candidates.length > 1,
      notes: claude.notes,
      source: ExpiryDateParseSource.claude,
    );
  }

  @visibleForTesting
  static List<DateTime> ambiguousDayMonthCandidatesForTesting(String text) =>
      _ambiguousDayMonthCandidates(text);

  static List<DateTime> _ambiguousDayMonthCandidates(String text) {
    final match = RegExp(r'(\d{1,2})[-/.](\d{1,2})[-/.](\d{2,4})').firstMatch(text);
    if (match == null) return const [];

    final a = int.parse(match.group(1)!);
    final b = int.parse(match.group(2)!);
    var year = int.parse(match.group(3)!);
    if (year < 100) year += 2000;

    if (a > 12 || b > 12 || a == b) return const [];

    try {
      return [
        DateTime(year, a, b),
        DateTime(year, b, a),
      ];
    } catch (_) {
      return const [];
    }
  }
}

final expiryDateScanServiceProvider = Provider<ExpiryDateScanService>((ref) {
  final claude = ref.watch(claudeAIServiceProvider);
  return ExpiryDateScanService(ExpiryDateClaudeNormalizer(claude));
});
