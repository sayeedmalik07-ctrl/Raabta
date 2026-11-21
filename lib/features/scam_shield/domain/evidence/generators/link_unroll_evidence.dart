import 'package:raabta/features/scam_shield/domain/evidence/link_unroll_models.dart';
import 'package:raabta/features/scam_shield/domain/evidence/scam_evidence_models.dart';
import 'package:raabta/features/scam_shield/domain/official_directory.dart';
import 'package:raabta/features/scam_shield/domain/official_directory_domain_utils.dart';
import 'package:raabta/features/scam_shield/domain/official_directory_models.dart';

abstract final class LinkUnrollEvidenceGenerator {
  static const destinationPriority = 640;
  static const chainLongPriority = 710;
  static const lookalikeFinalPriority = 905;

  static List<ScamEvidence> fromUnroll({
    required LinkUnrollResult result,
    required String locale,
    required String shortHost,
  }) {
    if (!result.resolved || result.finalRegistrableDomain == null) {
      return const [];
    }

    final finalDomain = result.finalRegistrableDomain!;
    final out = <ScamEvidence>[
      ScamEvidence(
        kind: ScamEvidenceKind.shortLinkDestination,
        priority: destinationPriority,
        textKey: 'ss_evidence_short_link_destination',
        params: {
          'domain': finalDomain,
          'shortHost': shortHost,
        },
        sourceLabel: 'ss_evidence_short_link_source',
        direction: ScamEvidenceDirection.informational,
      ),
    ];

    final distinctChain = result.chain.toSet().length;
    if (distinctChain >= 3) {
      out.add(
        ScamEvidence(
          kind: ScamEvidenceKind.redirectChainLong,
          priority: chainLongPriority,
          textKey: 'ss_evidence_redirect_chain_long',
          params: {'count': '$distinctChain'},
          sourceLabel: 'ss_evidence_short_link_source',
          direction: ScamEvidenceDirection.concern,
        ),
      );
    }

    if (OfficialDirectory.detectLookalikeDomain(finalDomain)) {
      final entry = _lookalikeEntry(finalDomain, locale);
      out.add(
        ScamEvidence(
          kind: ScamEvidenceKind.lookalikeDomain,
          priority: lookalikeFinalPriority,
          textKey: 'ss_evidence_short_final_lookalike',
          params: {
            'domain': finalDomain,
            'entity': entry?.displayName(locale) ?? 'a known organisation',
          },
          sourceLabel: 'ss_evidence_short_link_source',
          direction: ScamEvidenceDirection.concern,
        ),
      );
    }

    return out;
  }

  static OfficialDirectoryEntry? _lookalikeEntry(String domain, String locale) {
    for (final entry in OfficialDirectory.snapshot.verifiedEntries) {
      for (final official in entry.officialDomains) {
        if (OfficialDirectoryDomainUtils.isLookalikeOf(domain, official)) {
          return entry;
        }
      }
    }
    return null;
  }
}
