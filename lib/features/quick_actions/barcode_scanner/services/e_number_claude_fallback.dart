import 'dart:convert';

import 'package:raabta/services/ai/claude_ai_service.dart';

import '../food_local_analyzer.dart';
import '../models/e_number_entry.dart';

/// Claude fallback for E-number codes missing from bundled/shared reference.
class ENumberClaudeFallback {
  ENumberClaudeFallback(this._claude);

  final ClaudeAIService _claude;

  Future<List<LocalAdditiveInfo>> decodeUnknownCodes({
    required List<String> codes,
    required String uiLanguage,
  }) async {
    if (codes.isEmpty) return const [];

    final prompt = '''
You are a food additive reference expert. Decode ONLY these E-number or additive codes.
Respond ONLY with valid JSON — no markdown, no explanation.

Codes: ${codes.join(', ')}
Response language for plainName and reason: $uiLanguage

Return EXACTLY this JSON array:
[
  {
    "code": "<E-number or additive code>",
    "plainName": "<common name, max 8 words>",
    "status": "<safe|caution|avoid>",
    "reason": "<one factual line about typical use and any well-established concerns>"
  }
]

Rules:
- Use only established regulatory or scientific reference facts.
- Do not speculate or alarm; status "avoid" only for well-established serious concerns.
- Include one entry per requested code.
''';

    final rawResponse = await _claude.sendMessage(
      prompt,
      language: uiLanguage,
      requestType: 'food_inspector',
    );

    final clean = rawResponse
        .replaceAll('```json', '')
        .replaceAll('```', '')
        .trim();

    final start = clean.indexOf('[');
    final end = clean.lastIndexOf(']');
    if (start == -1 || end == -1) {
      throw const FormatException('Invalid E-number AI response');
    }

    final list = jsonDecode(clean.substring(start, end + 1)) as List<dynamic>;
    return list.map((item) {
      final map = Map<String, dynamic>.from(item as Map);
      return LocalAdditiveInfo(
        code: (map['code'] as String? ?? '').toUpperCase(),
        plainName: map['plainName'] as String? ?? 'Food additive',
        status: _normalizeStatus(map['status'] as String?),
        reason: map['reason'] as String? ?? 'Reference data pending verification.',
      );
    }).toList();
  }

  List<ENumberEntry> toReferenceEntries(List<LocalAdditiveInfo> additives) {
    return additives
        .where((a) => a.code.isNotEmpty)
        .map(
          (a) => ENumberEntry(
            code: a.code,
            plainName: a.plainName,
            category: 'additive',
            status: a.status,
            reason: a.reason,
            source: ENumberSource.claudeFallback,
          ),
        )
        .toList();
  }

  static String _normalizeStatus(String? status) {
    return switch (status?.toLowerCase()) {
      'safe' => 'safe',
      'avoid' => 'avoid',
      _ => 'caution',
    };
  }
}
