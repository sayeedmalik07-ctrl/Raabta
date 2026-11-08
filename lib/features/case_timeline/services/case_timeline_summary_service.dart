import 'package:raabta/features/case_timeline/case_timeline_config.dart';
import 'package:raabta/features/case_timeline/domain/case_timeline_entry.dart';
import 'package:raabta/features/case_timeline/domain/case_timeline_entry_type.dart';
import 'package:raabta/features/case_timeline/presentation/l10n/case_timeline_strings.dart';
import 'package:raabta/features/case_timeline/services/case_timeline_service.dart';
import 'package:raabta/services/ai/claude_ai_service.dart';

/// Optional capped AI — chronological summary only; no case-strength language.
class CaseTimelineSummaryService {
  CaseTimelineSummaryService(this._ai);

  final ClaudeAIService _ai;

  Future<String?> summarize({
    required List<CaseTimelineEntry> entries,
    required String locale,
    String? userId,
  }) async {
    if (entries.isEmpty) return null;

    final sorted = CaseTimelineService.sortedChronologically(entries);
    final lines = sorted.map((e) {
      final date = e.entryDate.toIso8601String().split('T').first;
      final type = CaseTimelineStrings.t(
        'ct_entry_type_${e.entryType.storageValue}',
        locale,
      );
      return '- $date | $type | ${e.title}';
    }).join('\n');

    final prompt = '''
Summarize the following personal case timeline entries in plain language for the user to review.
Write ONE chronological paragraph (max 120 words). Use neutral, factual wording only.

FORBIDDEN:
- Do NOT assess case strength, predict outcomes, or say anyone violated the law.
- Do NOT invent facts not listed below.
- Do NOT include document OCR content or legal advice.

Timeline entries (titles and dates only):
$lines

Language context: $locale
''';

    final reply = await _ai.sendMessage(
      prompt,
      language: locale,
      requestType: CaseTimelineConfig.aiRequestType,
      userId: userId,
    );

    final trimmed = reply.trim();
    return trimmed.isEmpty ? null : trimmed;
  }
}
