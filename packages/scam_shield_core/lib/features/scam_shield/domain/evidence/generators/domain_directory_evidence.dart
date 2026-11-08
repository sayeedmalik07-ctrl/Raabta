import 'package:scam_shield_core/features/scam_shield/domain/evidence/scam_evidence_models.dart';
import 'package:scam_shield_core/features/scam_shield/domain/official_directory.dart';
import 'package:scam_shield_core/features/scam_shield/domain/official_directory_models.dart';
import 'package:scam_shield_core/features/scam_shield/domain/scam_shield_models.dart';

abstract final class DomainDirectoryEvidenceGenerator {
  static const lookalikePriority = 900;
  static const exactPriority = 100;

  static List<ScamEvidence> generate({
    required String text,
    required String locale,
    required List<ScamShieldUrlFinding> findings,
  }) {
    final out = <ScamEvidence>[];
    for (final finding in findings) {
      if (finding.isKnownLegitimate) {
        final entry = OfficialDirectory.lookupByDomain(finding.domain);
        if (entry != null) out.add(_exact(entry, locale));
        continue;
      }
      if (finding.flags.contains('ss_flag_lookalike_domain')) {
        final entry = _lookalikeTarget(text, locale, finding.domain);
        out.add(_lookalike(entry, locale));
      }
    }
    return out;
  }

  static OfficialDirectoryEntry? _lookalikeTarget(
    String text,
    String locale,
    String domain,
  ) {
    final claim = OfficialDirectory.detectClaimedEntity(text, locale);
    if (claim.primaryId != null) {
      return OfficialDirectory.lookupById(claim.primaryId!);
    }
    if (OfficialDirectory.detectLookalikeDomain(domain)) {
      for (final entry in OfficialDirectory.snapshot.verifiedEntries) {
        for (final official in entry.officialDomains) {
          if (domain.contains(official.split('.').first)) return entry;
        }
      }
    }
    return null;
  }

  static ScamEvidence _exact(OfficialDirectoryEntry entry, String locale) {
    return ScamEvidence(
      kind: ScamEvidenceKind.exactOfficialDomain,
      priority: exactPriority,
      textKey: 'ss_evidence_exact_domain',
      params: {
        'entity': entry.displayName(locale),
        'date': entry.lastVerified?.toIso8601String().split('T').first ?? '',
      },
      sourceLabel: 'Official directory',
      sourceDate: entry.lastVerified,
      entityId: entry.id,
      direction: ScamEvidenceDirection.informational,
    );
  }

  static ScamEvidence _lookalike(OfficialDirectoryEntry? entry, String locale) {
    return ScamEvidence(
      kind: ScamEvidenceKind.lookalikeDomain,
      priority: lookalikePriority,
      textKey: 'ss_evidence_lookalike_domain',
      params: {
        'entity': entry?.displayName(locale) ?? 'a known organisation',
      },
      sourceLabel: 'Pattern check',
      entityId: entry?.id,
    );
  }
}
