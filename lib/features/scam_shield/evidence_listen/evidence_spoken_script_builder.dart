import 'package:raabta/features/scam_shield/domain/evidence/scam_evidence_models.dart';
import 'package:raabta/features/scam_shield/evidence_listen/evidence_verdict_pictogram.dart';
import 'package:raabta/features/scam_shield/presentation/l10n/scam_shield_strings.dart';

/// Pure spoken script from existing localized keys — no untrusted message text.
class EvidenceSpokenScriptBuilder {
  const EvidenceSpokenScriptBuilder({
    required this.locale,
    required this.verdict,
    required this.headlineKey,
    this.headlineParams = const {},
    this.evidence = const [],
    this.nextStepLabel,
  });

  final String locale;
  final EvidenceVerdictPictogramState verdict;
  final String headlineKey;
  final Map<String, String> headlineParams;
  final List<ScamEvidence> evidence;
  final String? nextStepLabel;

  static const maxEvidenceLines = 2;

  String build() {
    final parts = <String>[];

    parts.add(
      ScamShieldStrings.format(
        EvidenceVerdictPictogramResolver.headlineKey(verdict),
        locale,
        const {},
      ),
    );

    final headline = ScamShieldStrings.format(
      headlineKey,
      locale,
      headlineParams,
    );
    if (headline.isNotEmpty && headline != headlineKey) {
      parts.add(
        ScamShieldStrings.format('ss_listen_part_detail', locale, {
          'detail': headline,
        }),
      );
    }

    final lines = evidence.take(maxEvidenceLines);
    for (final e in lines) {
      parts.add(
        ScamShieldStrings.format('ss_listen_part_evidence', locale, {
          'point': ScamShieldStrings.format(e.textKey, locale, e.params),
        }),
      );
    }

    if (nextStepLabel != null && nextStepLabel!.trim().isNotEmpty) {
      parts.add(
        ScamShieldStrings.format('ss_listen_part_next', locale, {
          'step': nextStepLabel!,
        }),
      );
    }

    return parts.join(' ');
  }

  /// Redacted user message — separate optional script.
  static String buildReadMessage(String locale, String maskedMessage) {
    if (maskedMessage.trim().isEmpty) return '';
    return ScamShieldStrings.format('ss_listen_read_message_script', locale, {
      'message': maskedMessage.trim(),
    });
  }
}
