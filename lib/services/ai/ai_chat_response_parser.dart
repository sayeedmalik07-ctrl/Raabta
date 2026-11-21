class AiChatAction {
  const AiChatAction({required this.route, required this.label});

  final String route;
  final String label;
}

class AiChatCitation {
  const AiChatCitation({required this.source, required this.label});

  final String source;
  final String label;
}

/// Parses structured markers from assistant markdown.
abstract final class AiChatResponseParser {
  static final _actionPattern =
      RegExp(r'\[\[action:([^|\]]+)\|([^\]]+)\]\]');
  static final _citePattern =
      RegExp(r'\[\[cite:([^|\]]+)\|([^\]]+)\]\]');

  static ParsedAiResponse parse(String text) {
    final actions = <AiChatAction>[];
    final citations = <AiChatCitation>[];

    var clean = text.replaceAllMapped(_actionPattern, (match) {
      actions.add(
        AiChatAction(
          route: match.group(1)!.trim(),
          label: match.group(2)!.trim(),
        ),
      );
      return '';
    });

    clean = clean.replaceAllMapped(_citePattern, (match) {
      citations.add(
        AiChatCitation(
          source: match.group(1)!.trim(),
          label: match.group(2)!.trim(),
        ),
      );
      return '';
    });

    return ParsedAiResponse(
      displayText: clean.replaceAll(RegExp(r'\n{3,}'), '\n\n').trim(),
      actions: actions,
      citations: citations,
    );
  }
}

class ParsedAiResponse {
  const ParsedAiResponse({
    required this.displayText,
    this.actions = const [],
    this.citations = const [],
  });

  final String displayText;
  final List<AiChatAction> actions;
  final List<AiChatCitation> citations;
}
