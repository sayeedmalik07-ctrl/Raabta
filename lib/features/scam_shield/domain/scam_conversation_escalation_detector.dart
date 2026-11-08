import 'package:raabta/features/scam_shield/data/scam_multilingual_dictionary_config.dart';
import 'package:raabta/features/scam_shield/domain/scam_conversation_models.dart';
import 'package:raabta/features/scam_shield/domain/scam_multilingual_matcher.dart';

/// Deterministic multi-turn escalation flags — no AI.
abstract final class ScamConversationEscalationDetector {
  static const urgencyFlag = 'ss_flag_escalation_urgency';
  static const rapportAskFlag = 'ss_flag_escalation_rapport_ask';
  static const topicShiftFlag = 'ss_flag_escalation_topic_shift';

  static const _casualPatterns = [
    'hi',
    'hello',
    'hey',
    'good morning',
    'good evening',
    'how are you',
    'how r u',
    'friend',
    'nice to meet',
    'مرحب',
    'السلام',
    'كيف حال',
    'नमस्ते',
    'hello ji',
  ];

  static final _financialPatterns = [
    ...?ScamMultilingualDictionaryConfig.legacyFlagPatterns['ss_flag_unusual_payment'],
    ...?ScamMultilingualDictionaryConfig.legacyFlagPatterns['ss_flag_upfront_fee'],
    ...?ScamMultilingualDictionaryConfig.legacyFlagPatterns['ss_flag_otp'],
    'bank',
    'transfer',
    'payment',
    'qar',
    'deposit',
    'fee',
    'البنك',
    'تحويل',
    'دفع',
  ];

  static final _sensitivePatterns = [
    ...?ScamMultilingualDictionaryConfig.legacyFlagPatterns['ss_flag_otp'],
    ...?ScamMultilingualDictionaryConfig.legacyFlagPatterns['ss_flag_unusual_payment'],
    ...?ScamMultilingualDictionaryConfig.legacyFlagPatterns['ss_flag_upfront_fee'],
    'qid',
    'passport',
    'iban',
    'account number',
    'card number',
    'cvv',
    'pin',
  ];

  static ScamConversationEscalationResult analyze(
    ScamConversationParseResult parse,
  ) {
    if (!parse.hasStructure || parse.turns.length < 2) {
      return ScamConversationEscalationResult.empty;
    }
    if (parse.confidence == ScamConversationParseConfidence.none ||
        parse.confidence == ScamConversationParseConfidence.low) {
      return ScamConversationEscalationResult.empty;
    }

    final flags = <String>{};
    if (_hasUrgencyEscalation(parse.turns)) flags.add(urgencyFlag);
    if (_hasRapportThenAsk(parse.turns)) flags.add(rapportAskFlag);
    if (_hasTopicShift(parse.turns)) flags.add(topicShiftFlag);

    return ScamConversationEscalationResult(flags: flags.toList()..sort());
  }

  static bool _hasUrgencyEscalation(List<ScamConversationTurn> turns) {
    final urgencyPatterns =
        ScamMultilingualDictionaryConfig.legacyFlagPatterns['ss_flag_urgency']!;
    final midpoint = turns.length ~/ 2;
    final early = turns.take(midpoint).map((t) => t.text).join(' ');
    final late = turns.skip(midpoint).map((t) => t.text).join(' ');
    final earlyCount = _countPatternHits(early, urgencyPatterns);
    final lateCount = _countPatternHits(late, urgencyPatterns);
    return lateCount >= 1 && lateCount > earlyCount;
  }

  static bool _hasRapportThenAsk(List<ScamConversationTurn> turns) {
    if (turns.length < 3) return false;
    final rapportEnd = (turns.length * 0.55).floor().clamp(1, turns.length - 1);
    final early = turns.take(rapportEnd).map((t) => t.text).join(' ');
    final late = turns.skip(rapportEnd).map((t) => t.text).join(' ');
    final earlySensitive = _containsAnyPattern(early, _sensitivePatterns);
    final lateSensitive = _containsAnyPattern(late, _sensitivePatterns);
    final earlyCasual = _containsAnyPattern(early, _casualPatterns);
    return !earlySensitive && lateSensitive && earlyCasual;
  }

  static bool _hasTopicShift(List<ScamConversationTurn> turns) {
    final midpoint = turns.length ~/ 2;
    if (midpoint <= 0) return false;
    final early = turns.take(midpoint).map((t) => t.text).join(' ');
    final late = turns.skip(midpoint).map((t) => t.text).join(' ');
    final earlyCasual = _containsAnyPattern(early, _casualPatterns);
    final earlyFinancial = _containsAnyPattern(early, _financialPatterns);
    final lateFinancial = _containsAnyPattern(late, _financialPatterns);
    return earlyCasual && !earlyFinancial && lateFinancial;
  }

  static int _countPatternHits(String text, List<String> patterns) {
    var count = 0;
    for (final pattern in patterns) {
      if (ScamMultilingualMatcher.containsPattern(text, pattern)) count++;
    }
    return count;
  }

  static bool _containsAnyPattern(String text, List<String> patterns) {
    for (final pattern in patterns) {
      if (ScamMultilingualMatcher.containsPattern(text, pattern)) return true;
    }
    return false;
  }
}
