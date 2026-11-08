import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raabta/features/quick_actions/scanner/models/document_intelligence.dart';
import 'package:raabta/services/ai/claude_ai_service.dart';

class ScannerAiService {
  ScannerAiService(this._claude);

  final ClaudeAIService _claude;

  Future<DocumentIntelligenceResult> analyzeDocument(String ocrText) async {
    if (ocrText.trim().isEmpty) {
      return const DocumentIntelligenceResult(
        documentType: 'unknown',
        summary: 'No readable text found.',
      );
    }

    final prompt = '''
You are a document intelligence assistant for Qatar residents and visitors.
Analyze the OCR text and return structured JSON only.

OCR Text:
$ocrText

Respond ONLY with valid JSON:
{
  "documentType": "<passport|visa|qid|invoice|receipt|contract|certificate|unknown>",
  "summary": "<2-3 sentence plain language summary>",
  "names": ["<extracted person or company names>"],
  "dates": ["<important dates found>"],
  "amounts": ["<monetary values with currency if found>"],
  "expiryDate": "<ISO8601 YYYY-MM-DD if expiry found, else empty string>",
  "actionItems": ["<recommended next steps>"],
  "importantClauses": ["<important clauses or terms>"],
  "confidence": <0.0 to 1.0>
}

Rules:
- Informational only — not legal advice
- Prefer Arabic and English field labels when interpreting Qatar documents
- If uncertain, lower confidence below 0.5
''';

    final raw = await _claude.sendMessage(
      prompt,
      requestType: 'document_intelligence',
    );
    final clean = raw.replaceAll('```json', '').replaceAll('```', '').trim();

    try {
      final json = jsonDecode(clean) as Map<String, dynamic>;
      return DocumentIntelligenceResult.fromJson(json);
    } catch (_) {
      return DocumentIntelligenceResult(
        documentType: 'unknown',
        summary: raw.trim().isEmpty ? 'Analysis unavailable.' : raw.trim(),
        confidence: 0.3,
      );
    }
  }
}

final scannerAiServiceProvider = Provider<ScannerAiService>((ref) {
  return ScannerAiService(ref.read(claudeAIServiceProvider));
});
