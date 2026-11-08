import 'package:raabta/features/scam_shield/domain/scam_input_channel_parser.dart';

/// Heuristic channel suggestions for shared content (never auto-applied).
abstract final class ScamShareChannelDetect {
  static ScamShieldInputChannel? suggest(String text) {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return null;

    final hasFrom = _fromPattern.hasMatch(trimmed);
    final hasSubject = _subjectPattern.hasMatch(trimmed);
    if (hasFrom && hasSubject) {
      return ScamShieldInputChannel.emailMessage;
    }
    if (hasFrom) {
      return ScamShieldInputChannel.smsThread;
    }

    final uri = Uri.tryParse(trimmed);
    if (uri != null &&
        uri.hasScheme &&
        uri.host.isNotEmpty &&
        !trimmed.contains('\n')) {
      return ScamShieldInputChannel.urlOnly;
    }

    return null;
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
}
