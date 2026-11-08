import 'package:raabta/features/scam_shield/domain/scam_conversation_models.dart';

/// Splits pasted chat exports into ordered turns without storing identities.
abstract final class ScamConversationTurnParser {
  static final _forwardedDelimiter = RegExp(
    r'^-{3,}\s*Forwarded message\s*-{3,}$',
    caseSensitive: false,
  );

  /// WhatsApp iOS export: `[23/08/2026, 14:32:15] Sender: message`
  static final _whatsAppBracket = RegExp(
    r'^\[(\d{1,2}/\d{1,2}/\d{2,4}),?\s+(\d{1,2}:\d{2}(?::\d{2})?(?:\s?[APMapm]{2})?)\]\s*([^:]+):\s*(.*)$',
  );

  /// WhatsApp Android export: `23/08/2026, 14:32 - Sender: message`
  static final _whatsAppDash = RegExp(
    r'^(\d{1,2}/\d{1,2}/\d{2,4}),?\s+(\d{1,2}:\d{2}(?::\d{2})?(?:\s?[APMapm]{2})?)\s*[-–—]\s*([^:]+):\s*(.*)$',
  );

  /// Generic chat line: `10:42 AM - message` or `14:32 - message`
  static final _timeOnlyLine = RegExp(
    r'^(\d{1,2}:\d{2}(?::\d{2})?(?:\s?[APMapm]{2})?)\s*[-–—]\s*(.+)$',
  );

  /// Explicit speaker prefix: `John: hello` (no timestamp).
  static final _speakerPrefix = RegExp(r'^([^:]{1,40}):\s+(.+)$');

  static ScamConversationParseResult parse(String text) {
    final trimmed = text.trim();
    if (trimmed.isEmpty) {
      return const ScamConversationParseResult(
        turns: [],
        confidence: ScamConversationParseConfidence.none,
      );
    }

    final lines = trimmed.split('\n');
    final waBracket = _parseWithHeaders(
      lines: lines,
      headerPattern: _whatsAppBracket,
      labelGroup: 3,
      bodyGroup: 4,
    );
    if (waBracket != null) return waBracket;

    final waDash = _parseWithHeaders(
      lines: lines,
      headerPattern: _whatsAppDash,
      labelGroup: 3,
      bodyGroup: 4,
    );
    if (waDash != null) return waDash;

    final speakerLines = _parseSpeakerPrefixLines(lines);
    if (speakerLines != null) return speakerLines;

    final timeLines = _parseTimeOnlyLines(lines);
    if (timeLines != null) return timeLines;

    return ScamConversationParseResult(
      turns: [
        ScamConversationTurn(
          index: 0,
          speaker: ScamConversationSpeaker.unknown,
          text: trimmed,
        ),
      ],
      confidence: ScamConversationParseConfidence.none,
    );
  }

  static ScamConversationParseResult? _parseWithHeaders({
    required List<String> lines,
    required RegExp headerPattern,
    required int labelGroup,
    required int bodyGroup,
  }) {
    final headers = <int>[];
    for (var i = 0; i < lines.length; i++) {
      final line = lines[i].trim();
      if (line.isEmpty || _forwardedDelimiter.hasMatch(line)) continue;
      if (headerPattern.hasMatch(line)) headers.add(i);
    }
    if (headers.length < 2) return null;

    final rawTurns = <({String label, String text})>[];
    for (var h = 0; h < headers.length; h++) {
      final start = headers[h];
      final end = h + 1 < headers.length ? headers[h + 1] : lines.length;
      final headerLine = lines[start].trim();
      final match = headerPattern.firstMatch(headerLine)!;
      final label = match.group(labelGroup)!.trim();
      final bodyParts = <String>[match.group(bodyGroup)!.trim()];
      for (var i = start + 1; i < end; i++) {
        final line = lines[i].trim();
        if (line.isEmpty || _forwardedDelimiter.hasMatch(line)) continue;
        bodyParts.add(line);
      }
      final body = bodyParts.join('\n').trim();
      if (body.isNotEmpty) {
        rawTurns.add((label: label, text: body));
      }
    }
    if (rawTurns.length < 2) return null;

    return _buildResult(
      rawTurns: rawTurns,
      confidence: ScamConversationParseConfidence.high,
    );
  }

  static ScamConversationParseResult? _parseSpeakerPrefixLines(
    List<String> lines,
  ) {
    final rawTurns = <({String label, String text})>[];
    String? currentLabel;
    final bodyParts = <String>[];

    void flush() {
      if (currentLabel == null) return;
      final body = bodyParts.join('\n').trim();
      if (body.isNotEmpty) {
        rawTurns.add((label: currentLabel!, text: body));
      }
      bodyParts.clear();
    }

    for (final line in lines) {
      final trimmed = line.trim();
      if (trimmed.isEmpty || _forwardedDelimiter.hasMatch(trimmed)) continue;
      final match = _speakerPrefix.firstMatch(trimmed);
      if (match != null && !_looksLikeUrl(trimmed)) {
        flush();
        currentLabel = match.group(1)!.trim();
        bodyParts.add(match.group(2)!.trim());
      } else if (currentLabel != null) {
        bodyParts.add(trimmed);
      }
    }
    flush();

    if (rawTurns.length < 2) return null;
    return _buildResult(
      rawTurns: rawTurns,
      confidence: ScamConversationParseConfidence.medium,
    );
  }

  static ScamConversationParseResult? _parseTimeOnlyLines(List<String> lines) {
    final rawTurns = <({String label, String text})>[];
    var turnIndex = 0;
    String? currentLabel;
    final bodyParts = <String>[];

    void flush() {
      if (currentLabel == null) return;
      final body = bodyParts.join('\n').trim();
      if (body.isNotEmpty) {
        rawTurns.add((label: currentLabel!, text: body));
      }
      bodyParts.clear();
    }

    for (final line in lines) {
      final trimmed = line.trim();
      if (trimmed.isEmpty || _forwardedDelimiter.hasMatch(trimmed)) continue;
      final match = _timeOnlyLine.firstMatch(trimmed);
      if (match != null) {
        flush();
        turnIndex++;
        currentLabel = 'turn_$turnIndex';
        bodyParts.add(match.group(2)!.trim());
      } else if (currentLabel != null) {
        bodyParts.add(trimmed);
      }
    }
    flush();

    if (rawTurns.length < 2) return null;
    return _buildResult(
      rawTurns: rawTurns,
      confidence: ScamConversationParseConfidence.low,
    );
  }

  static ScamConversationParseResult _buildResult({
    required List<({String label, String text})> rawTurns,
    required ScamConversationParseConfidence confidence,
  }) {
    final speakerMap = <String, ScamConversationSpeaker>{};
    var partyCount = 0;

    ScamConversationSpeaker speakerFor(String label) {
      final normalized = label.trim().toLowerCase();
      if (_isSelfLabel(normalized)) {
        return ScamConversationSpeaker.partyA;
      }
      if (_isOtherLabel(normalized)) {
        return ScamConversationSpeaker.partyB;
      }
      return speakerMap.putIfAbsent(label, () {
        if (partyCount == 0) {
          partyCount++;
          return ScamConversationSpeaker.partyA;
        }
        if (partyCount == 1) {
          partyCount++;
          return ScamConversationSpeaker.partyB;
        }
        return partyCount.isEven
            ? ScamConversationSpeaker.partyA
            : ScamConversationSpeaker.partyB;
      });
    }

    final turns = <ScamConversationTurn>[];
    for (var i = 0; i < rawTurns.length; i++) {
      final raw = rawTurns[i];
      turns.add(
        ScamConversationTurn(
          index: i,
          speaker: speakerFor(raw.label),
          text: raw.text,
        ),
      );
    }

    return ScamConversationParseResult(
      turns: turns,
      confidence: confidence,
    );
  }

  static bool _isSelfLabel(String label) {
    return const {
      'you',
      'me',
      'أنا',
      'me:',
    }.contains(label.replaceAll(':', '').trim());
  }

  static bool _isOtherLabel(String label) {
    return label.startsWith('turn_');
  }

  static bool _looksLikeUrl(String line) {
    return line.contains('://') || line.startsWith('www.');
  }

  static String speakerLabel(ScamConversationSpeaker speaker) {
    return switch (speaker) {
      ScamConversationSpeaker.partyA => 'Party A',
      ScamConversationSpeaker.partyB => 'Party B',
      ScamConversationSpeaker.unknown => 'Unknown',
    };
  }
}
