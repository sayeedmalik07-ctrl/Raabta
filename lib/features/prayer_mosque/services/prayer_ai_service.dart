import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:raabta/features/prayer_mosque/domain/models/prayer_assistant_reply.dart';
import 'package:raabta/features/prayer_mosque/domain/models/prayer_schedule.dart';
import 'package:raabta/features/prayer_mosque/domain/models/prayer_settings.dart';
import 'package:raabta/features/prayer_mosque/presentation/l10n/prayer_strings.dart';
import 'package:raabta/features/prayer_mosque/services/islamic_faq_matcher.dart';
import 'package:raabta/features/prayer_mosque/services/prayer_routing_log.dart';
import 'package:raabta/services/ai/claude_ai_service.dart';

class PrayerAiService {
  PrayerAiService(this._claude);

  final ClaudeAIService _claude;

  Future<PrayerAssistantReply> ask({
    required String question,
    required PrayerScheduleDay schedule,
    required PrayerSettings settings,
    String? nearestMosqueName,
  }) async {
    final faqMatch = IslamicFaqMatcher.tryMatch(question, settings.locale);
    if (faqMatch != null) {
      PrayerRoutingLog.faqHit(
        entryId: faqMatch.entry.id,
        category: faqMatch.entry.category,
        confidence: faqMatch.confidence,
      );
      return faqMatch.toReply(settings.locale);
    }

    final bestScore = IslamicFaqMatcher.bestEffortScore(question, settings.locale);
    PrayerRoutingLog.claudeFallback(
      sanitizedQuestion: IslamicFaqMatcher.sanitizeForLog(question),
      reason: bestScore >= 0.35 ? 'ambiguous_or_below_threshold' : 'no_faq_match',
      bestFaqScore: bestScore > 0 ? bestScore : null,
    );

    final text = await _askClaude(
      question: question,
      schedule: schedule,
      settings: settings,
      nearestMosqueName: nearestMosqueName,
    );
    return PrayerAssistantReply(text: text, source: PrayerReplySource.claude);
  }

  Future<String> _askClaude({
    required String question,
    required PrayerScheduleDay schedule,
    required PrayerSettings settings,
    String? nearestMosqueName,
  }) async {
    final fmt = settings.timeFormat.name.contains('24')
        ? DateFormat.Hm()
        : DateFormat.jm();
    final times = schedule.entries
        .map(
          (e) =>
              '${PrayerStrings.t(e.labelKey, settings.locale)}: ${fmt.format(e.time)}',
        )
        .join('\n');

    final prompt = '''
You are RAABTA Islamic Companion assistant for Muslims in Qatar.
Answer clearly and respectfully in ${settings.locale}.
Provide general, widely accepted Islamic guidance for expatriates, tourists, and residents.
Do NOT issue personal fatwas. If a question needs a scholar, say so.
When uncertain, recommend consulting local imam or official guidance.

Location: ${schedule.locationLabel}
Today's prayer times:
$times
${nearestMosqueName != null ? 'Nearest mosque: $nearestMosqueName' : ''}

User question: $question

Keep the answer practical, concise, and travel-friendly when relevant.
''';

    return _claude.sendMessage(
      prompt,
      language: settings.locale,
      requestType: 'prayer_assistant',
    );
  }
}

final prayerAiServiceProvider = Provider<PrayerAiService>((ref) {
  return PrayerAiService(ref.watch(claudeAIServiceProvider));
});
