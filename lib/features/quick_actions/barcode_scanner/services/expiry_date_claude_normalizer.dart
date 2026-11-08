import 'dart:convert';

import 'package:raabta/services/ai/claude_ai_service.dart';

class ExpiryDateNormalizationResult {
  const ExpiryDateNormalizationResult({
    required this.candidates,
    required this.isAmbiguous,
    this.notes,
  });

  final List<DateTime> candidates;
  final bool isAmbiguous;
  final String? notes;

  DateTime? get singleCandidate =>
      !isAmbiguous && candidates.length == 1 ? candidates.first : null;
}

/// Narrow Claude use: normalize OCR expiry strings — never infer halal status.
class ExpiryDateClaudeNormalizer {
  ExpiryDateClaudeNormalizer(this._claude);

  final ClaudeAIService _claude;

  Future<ExpiryDateNormalizationResult> normalize({
    required String ocrText,
    required String uiLanguage,
  }) async {
    final prompt = '''
You normalize printed food expiry / best-before dates from OCR text.
Respond ONLY with valid JSON — no markdown.

OCR text:
"""
$ocrText
"""

Return EXACTLY:
{
  "candidates": ["YYYY-MM-DD"],
  "ambiguous": true|false,
  "notes": "<optional one line if DD/MM vs MM/DD ambiguity>"
}

Rules:
- Prefer dates near labels like EXP, Best Before, Use By, BB.
- If day and month are both <=12 and order is unclear, set ambiguous=true and list BOTH interpretations as separate ISO dates.
- Do not guess silently when ambiguous — list up to 2 candidates.
- Ignore manufacturing dates unless clearly marked as expiry.
- Use Gregorian calendar only in output.
''';

    final raw = await _claude.sendMessage(
      prompt,
      language: uiLanguage,
      requestType: 'food_inspector',
    );

    final clean = raw.replaceAll('```json', '').replaceAll('```', '').trim();
    final start = clean.indexOf('{');
    final end = clean.lastIndexOf('}');
    if (start == -1 || end == -1) {
      throw const FormatException('Invalid expiry date AI response');
    }

    final map = jsonDecode(clean.substring(start, end + 1)) as Map<String, dynamic>;
    final rawCandidates = map['candidates'] as List<dynamic>? ?? [];
    final candidates = <DateTime>[];
    for (final item in rawCandidates) {
      try {
        candidates.add(DateTime.parse(item.toString()));
      } catch (_) {}
    }

    return ExpiryDateNormalizationResult(
      candidates: candidates,
      isAmbiguous: map['ambiguous'] as bool? ?? candidates.length > 1,
      notes: map['notes'] as String?,
    );
  }
}
