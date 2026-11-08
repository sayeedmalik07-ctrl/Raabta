/// Multi-channel input normalization for ScamShield Phase 4.
enum ScamShieldInputChannel {
  pasteText,
  phoneCallNotes,
  smsThread,
  emailMessage,
  urlOnly,
  marketplaceChat,
  osShare,
}

extension ScamShieldInputChannelX on ScamShieldInputChannel {
  String get labelKey => switch (this) {
        ScamShieldInputChannel.pasteText => 'ss_input_paste',
        ScamShieldInputChannel.phoneCallNotes => 'ss_input_phone',
        ScamShieldInputChannel.smsThread => 'ss_input_sms',
        ScamShieldInputChannel.emailMessage => 'ss_input_email',
        ScamShieldInputChannel.urlOnly => 'ss_input_url',
        ScamShieldInputChannel.marketplaceChat => 'ss_input_marketplace',
        ScamShieldInputChannel.osShare => 'ss_input_os_share',
      };

  String get hintKey => switch (this) {
        ScamShieldInputChannel.pasteText => 'ss_paste_hint',
        ScamShieldInputChannel.phoneCallNotes => 'ss_input_phone_hint',
        ScamShieldInputChannel.smsThread => 'ss_input_sms_hint',
        ScamShieldInputChannel.emailMessage => 'ss_input_email_hint',
        ScamShieldInputChannel.urlOnly => 'ss_input_url_hint',
        ScamShieldInputChannel.marketplaceChat => 'ss_input_marketplace_hint',
        ScamShieldInputChannel.osShare => 'ss_share_review_hint',
      };
}

class ScamInputParseResult {
  const ScamInputParseResult({
    required this.normalizedText,
    required this.channel,
    this.sender,
    this.subject,
  });

  final String normalizedText;
  final ScamShieldInputChannel channel;
  final String? sender;
  final String? subject;
}

abstract final class ScamInputChannelParser {
  static ScamInputParseResult parse({
    required String raw,
    required ScamShieldInputChannel channel,
  }) {
    return switch (channel) {
      ScamShieldInputChannel.pasteText ||
      ScamShieldInputChannel.phoneCallNotes ||
      ScamShieldInputChannel.marketplaceChat ||
      ScamShieldInputChannel.osShare =>
        ScamInputParseResult(
          normalizedText: raw.trim(),
          channel: channel,
        ),
      ScamShieldInputChannel.smsThread => _parseSms(raw),
      ScamShieldInputChannel.emailMessage => _parseEmail(raw),
      ScamShieldInputChannel.urlOnly => ScamInputParseResult(
          normalizedText: raw.trim(),
          channel: channel,
        ),
    };
  }

  static ScamInputParseResult _parseSms(String raw) {
    var sender = _firstMatch(raw, _fromPattern);
    var body = _firstMatch(raw, _bodyPattern);

    if (body == null) {
      final lines = raw.split('\n').map((l) => l.trim()).where((l) => l.isNotEmpty);
      final list = lines.toList();
      if (list.length >= 2 && sender != null) {
        body = list.last;
      } else {
        body = raw.trim();
      }
    }

    return ScamInputParseResult(
      normalizedText: body.trim(),
      channel: ScamShieldInputChannel.smsThread,
      sender: sender,
    );
  }

  static ScamInputParseResult _parseEmail(String raw) {
    final from = _firstMatch(raw, _fromPattern);
    final subject = _firstMatch(raw, _subjectPattern);
    final body = _extractEmailBody(raw);

    final buffer = StringBuffer();
    if (from != null) buffer.writeln('From: $from');
    if (subject != null) buffer.writeln('Subject: $subject');
    buffer.write(body);

    return ScamInputParseResult(
      normalizedText: buffer.toString().trim(),
      channel: ScamShieldInputChannel.emailMessage,
      sender: from,
      subject: subject,
    );
  }

  static String _extractEmailBody(String raw) {
    final divider = RegExp(r'^-{2,}\s*$', multiLine: true);
    final parts = raw.split(divider);
    if (parts.length >= 2) return parts.last.trim();

    final lines = raw.split('\n');
    final bodyLines = <String>[];
    var passedHeaders = false;
    for (final line in lines) {
      if (!passedHeaders &&
          (line.toLowerCase().startsWith('from:') ||
              line.toLowerCase().startsWith('subject:') ||
              line.toLowerCase().startsWith('to:') ||
              line.toLowerCase().startsWith('reply-to:'))) {
        continue;
      }
      passedHeaders = true;
      bodyLines.add(line);
    }
    final body = bodyLines.join('\n').trim();
    return body.isEmpty ? raw.trim() : body;
  }

  static String? _firstMatch(String text, RegExp pattern) {
    final match = pattern.firstMatch(text);
    return match?.group(1)?.trim();
  }

  static final _fromPattern = RegExp(
    r'^(?:from|sender)\s*:\s*(.+)$',
    multiLine: true,
    caseSensitive: false,
  );
  static final _subjectPattern = RegExp(
    r'^subject\s*:\s*(.+)$',
    multiLine: true,
    caseSensitive: false,
  );
  static final _bodyPattern = RegExp(
    r'(?:^body\s*:\s*)(.+)$',
    multiLine: true,
    caseSensitive: false,
    dotAll: true,
  );
}
