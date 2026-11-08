import 'package:scam_shield_core/features/scam_shield/domain/evidence/scam_evidence_models.dart';
import 'package:scam_shield_core/features/scam_shield/domain/scam_advisory_matcher.dart';
import 'package:scam_shield_core/features/scam_shield/domain/scam_advisory_models.dart';
import 'package:scam_shield_core/features/scam_shield/domain/official_directory.dart';

abstract final class AdvisoryMatchEvidenceGenerator {
  static const priority = 850;

  static List<ScamEvidence> generate({
    required String text,
    required String locale,
    required List<ScamAdvisory> advisories,
  }) {
    if (advisories.isEmpty) return const [];
    final claim = OfficialDirectory.detectClaimedEntity(text, locale);
    final matches = ScamAdvisoryMatcher.match(
      text: text,
      claimedEntityIds: claim.matches,
      locale: locale,
      activeAdvisories: advisories,
    );
    final out = <ScamEvidence>[];
    for (final m in matches) {
      ScamAdvisory? advisory;
      for (final a in advisories) {
        if (a.id == m.advisoryId) {
          advisory = a;
          break;
        }
      }
      if (advisory == null) continue;
      out.add(
        ScamEvidence(
          kind: ScamEvidenceKind.advisoryMatch,
          priority: priority,
          textKey: 'ss_evidence_advisory_match',
          params: {'title': advisory.title},
          sourceLabel: advisory.sourceName,
          sourceDate: advisory.sourceDate,
          sourceUrl: advisory.sourceUrl,
          advisoryId: advisory.id,
        ),
      );
    }
    return out;
  }
}
