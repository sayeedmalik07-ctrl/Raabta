import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:raabta/features/scam_shield/domain/evidence/domain_age_models.dart';
import 'package:raabta/features/scam_shield/domain/evidence/generators/domain_age_evidence.dart';
import 'package:raabta/features/scam_shield/domain/evidence/scam_evidence_models.dart';
import 'package:raabta/features/scam_shield/domain/official_directory.dart';
import 'package:raabta/features/scam_shield/domain/official_directory_domain_utils.dart';
import 'package:raabta/features/scam_shield/domain/scam_shield_models.dart';
import 'package:raabta/features/scam_shield/services/scam_domain_age_service.dart';

/// Per-assessment cap and official-directory skip for async domain-age evidence.
class DomainAgeEvidenceSession {
  DomainAgeEvidenceSession();

  /// Legacy singleton — tests only; production uses per-widget sessions.
  static final instance = DomainAgeEvidenceSession();

  final _lookedUp = <String>{};

  void reset() => _lookedUp.clear();

  bool markLookup(String domain) {
    if (_lookedUp.contains(domain)) return false;
    _lookedUp.add(domain);
    return true;
  }
}

abstract final class DomainAgeEvidenceLoader {
  static const maxDomainsPerSubmission = 2;

  @visibleForTesting
  static Future<List<ConnectivityResult>> Function()? connectivityOverride;

  static Future<List<ScamEvidence>> loadAsync({
    required List<ScamShieldUrlFinding> urlFindings,
    required String locale,
    required bool featureEnabled,
    DomainAgeEvidenceSession? lookupSession,
    ScamDomainAgeService? service,
    Future<List<ConnectivityResult>> Function()? connectivity,
  }) async {
    if (!featureEnabled) return const [];

    final conn = await (connectivity?.call() ??
        connectivityOverride?.call() ??
        Connectivity().checkConnectivity());
    if (conn.every((c) => c == ConnectivityResult.none)) {
      return const [];
    }

    final domains = _candidateDomains(urlFindings);
    if (domains.isEmpty) return const [];

    final session = lookupSession ?? DomainAgeEvidenceSession();
    final api = service ?? ScamDomainAgeService();
    final out = <ScamEvidence>[];

    for (final domain in domains.take(maxDomainsPerSubmission)) {
      if (!session.markLookup(domain)) continue;

      final result = await api.lookupRegistrableDomain(domain);
      final evidence = DomainAgeEvidenceGenerator.fromLookup(
        domain: domain,
        locale: locale,
        result: result,
      );
      if (evidence != null) out.add(evidence);
    }

    return out;
  }

  static List<String> _candidateDomains(List<ScamShieldUrlFinding> findings) {
    int score(ScamShieldUrlFinding f) {
      if (f.isKnownLegitimate) return -100;
      var s = 0;
      if (f.flags.contains('ss_flag_unusual_payment')) s += 3;
      if (f.flags.contains('ss_flag_upfront_fee')) s += 3;
      if (f.flags.contains('ss_flag_lookalike_domain')) s += 2;
      if (f.flags.contains('ss_flag_url_shortener')) s += 1;
      return s;
    }

    final ranked = [...findings]..sort((a, b) => score(b).compareTo(score(a)));
    final seen = <String>{};
    final out = <String>[];

    for (final f in ranked) {
      if (f.isKnownLegitimate) continue;
      final reg = OfficialDirectoryDomainUtils.registrableDomain(f.domain);
      if (reg.isEmpty) continue;
      if (_isOfficialDomain(reg)) continue;
      if (seen.add(reg)) out.add(reg);
    }
    return out;
  }

  static bool _isOfficialDomain(String registrable) {
    for (final entry in OfficialDirectory.snapshot.verifiedEntries) {
      for (final official in entry.officialDomains) {
        if (OfficialDirectoryDomainUtils.exactRegistrableMatch(
          registrable,
          official,
        )) {
          return true;
        }
      }
    }
    return false;
  }

  @visibleForTesting
  static List<String> candidateDomainsForTest(List<ScamShieldUrlFinding> f) =>
      _candidateDomains(f);
}
