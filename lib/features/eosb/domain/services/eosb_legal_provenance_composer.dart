import 'package:raabta/features/eosb/domain/models/eosb_certificate_models.dart';
import 'package:raabta/features/eosb/domain/rules/eosb_certificate_constants.dart';
import 'package:raabta/features/eosb/domain/services/eosb_certificate_decimal_format.dart';
import 'package:raabta/features/legal_sources/data/legal_sources_seed_catalog.dart';

/// Composes legal provenance from [LegalSourcesSeedCatalog] — no hardcoded dates.
abstract final class EosbLegalProvenanceComposer {
  static const disclaimerKey = 'eosb_cert_legal_disclaimer';
  static const raabtaRulesetLabel = 'Raabta EOSB Calculation Layer';

  static EosbLegalProvenanceSnapshot compose({
    required List<EosbBreakdownSnapshotItem> breakdown,
  }) {
    final primary = _requireCatalogEntry(EosbCertificateLegalCatalog.primaryLawId);
    final refs = _breakdownRefs(breakdown);
    final supplementaryIds = <String>{};
    for (final ref in refs) {
      if (ref.lawCatalogId != primary.catalogId) {
        supplementaryIds.add(ref.lawCatalogId);
      }
    }

    final supplementary = supplementaryIds
        .map(_requireCatalogEntry)
        .toList()
      ..sort((a, b) => a.catalogId.compareTo(b.catalogId));

    final verifiedDate = primary.dateLastVerified;

    return EosbLegalProvenanceSnapshot(
      primaryLaw: primary,
      supplementaryLaws: supplementary,
      breakdownLegalRefs: refs,
      raabtaRulesetLabel: raabtaRulesetLabel,
      raabtaRulesetVersion: EosbRulesetVersion.current,
      sourceVerifiedDate: verifiedDate,
      disclaimerKey: disclaimerKey,
    );
  }

  /// `{catalogId}@{YYYY-MM-DD}` for primary law — frozen at generation.
  static String legalSourceVersionKey() {
    final primary = _requireCatalogEntry(EosbCertificateLegalCatalog.primaryLawId);
    return '${primary.catalogId}@${primary.dateLastVerified}';
  }

  static EosbLegalReferenceSnapshot _requireCatalogEntry(String catalogId) {
    final source = LegalSourcesSeedCatalog.defaults.firstWhere(
      (s) => s.id == catalogId,
      orElse: () => throw StateError('Missing legal catalog entry: $catalogId'),
    );
    final verified = source.dateLastVerified;
    if (verified == null) {
      throw StateError('Legal catalog entry $catalogId has no dateLastVerified');
    }
    return EosbLegalReferenceSnapshot(
      catalogId: source.id,
      lawIdentifier: source.lawIdentifier,
      sourceUrl: source.sourceUrl,
      dateLastVerified: EosbCertificateDecimalFormat.isoDate(
        DateTime(verified.year, verified.month, verified.day),
      ),
    );
  }

  static List<EosbBreakdownLegalRefSnapshot> _breakdownRefs(
    List<EosbBreakdownSnapshotItem> breakdown,
  ) {
    final sorted = [...breakdown]..sort((a, b) => a.id.compareTo(b.id));
    return sorted
        .map((item) {
          final mapping = _mapRuleKey(item.id, item.ruleKey);
          return EosbBreakdownLegalRefSnapshot(
            breakdownId: item.id,
            ruleKey: item.ruleKey,
            lawCatalogId: mapping.lawCatalogId,
            articles: mapping.articles,
          );
        })
        .toList(growable: false);
  }

  static _RuleMapping _mapRuleKey(String breakdownId, String ruleKey) {
    if (ruleKey.contains('strike_incitement_law9')) {
      return const _RuleMapping(
        lawCatalogId: EosbCertificateLegalCatalog.supplementaryLaw9Id,
        articles: [],
      );
    }
    switch (breakdownId) {
      case 'gratuity':
        return const _RuleMapping(
          lawCatalogId: EosbCertificateLegalCatalog.primaryLawId,
          articles: ['54'],
        );
      case 'leave':
        return const _RuleMapping(
          lawCatalogId: EosbCertificateLegalCatalog.primaryLawId,
          articles: ['79', '80', '81', '82', '83'],
        );
      case 'notice':
        return const _RuleMapping(
          lawCatalogId: EosbCertificateLegalCatalog.primaryLawId,
          articles: ['49', '50'],
        );
      case 'overtime':
        return const _RuleMapping(
          lawCatalogId: EosbCertificateLegalCatalog.primaryLawId,
          articles: ['73', '74'],
        );
      case 'return_ticket':
      case 'family_ticket':
        return const _RuleMapping(
          lawCatalogId: EosbCertificateLegalCatalog.molGuidanceId,
          articles: [],
        );
      default:
        return const _RuleMapping(
          lawCatalogId: EosbCertificateLegalCatalog.primaryLawId,
          articles: [],
        );
    }
  }
}

class _RuleMapping {
  const _RuleMapping({required this.lawCatalogId, required this.articles});
  final String lawCatalogId;
  final List<String> articles;
}
