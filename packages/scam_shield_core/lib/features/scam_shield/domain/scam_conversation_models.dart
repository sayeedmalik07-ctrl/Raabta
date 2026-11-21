/// Best-effort conversation structure extracted from pasted chat exports.
enum ScamConversationParseConfidence {
  none,
  low,
  medium,
  high,
}

enum ScamConversationSpeaker {
  partyA,
  partyB,
  unknown,
}

class ScamConversationTurn {
  const ScamConversationTurn({
    required this.index,
    required this.speaker,
    required this.text,
  });

  final int index;
  final ScamConversationSpeaker speaker;
  final String text;
}

class ScamConversationParseResult {
  const ScamConversationParseResult({
    required this.turns,
    required this.confidence,
  });

  final List<ScamConversationTurn> turns;
  final ScamConversationParseConfidence confidence;

  bool get hasStructure =>
      turns.length >= 2 &&
      confidence != ScamConversationParseConfidence.none;

  String get combinedText => turns.map((t) => t.text).join('\n');
}

class ScamConversationContext {
  const ScamConversationContext({
    required this.turnCount,
    required this.confidence,
    required this.escalationFlags,
  });

  final int turnCount;
  final ScamConversationParseConfidence confidence;
  final List<String> escalationFlags;
}

class ScamConversationEscalationResult {
  const ScamConversationEscalationResult({
    this.flags = const [],
  });

  final List<String> flags;

  static const empty = ScamConversationEscalationResult();
}
