import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:raabta/features/scam_shield/data/link_shortener_config.dart';
import 'package:raabta/features/scam_shield/domain/evidence/domain_age_evidence_loader.dart';
import 'package:raabta/features/scam_shield/domain/evidence/generators/domain_age_evidence.dart';
import 'package:raabta/features/scam_shield/domain/evidence/generators/link_unroll_evidence.dart';
import 'package:raabta/features/scam_shield/domain/evidence/scam_evidence_models.dart';
import 'package:raabta/features/scam_shield/domain/official_directory.dart';
import 'package:raabta/features/scam_shield/domain/official_directory_domain_utils.dart';
import 'package:raabta/features/scam_shield/domain/scam_shield_models.dart';
import 'package:raabta/features/scam_shield/services/scam_domain_age_service.dart';
import 'package:raabta/features/scam_shield/services/scam_link_unroll_service.dart';

class LinkUnrollEvidenceSession {
  final _unrolled = <String>{};

  bool markUnroll(String url) {
    final key = url.split('#').first.trim().toLowerCase();
    if (_unrolled.contains(key)) return false;
    _unrolled.add(key);
    return true;
  }

  void reset() => _unrolled.clear();
}

abstract final class LinkUnrollEvidenceLoader {
  static const maxUnrollsPerSubmission = 2;

  @visibleForTesting
  static Future<List<ConnectivityResult>> Function()? connectivityOverride;

  static Future<List<ScamEvidence>> loadAsync({
    required List<ScamShieldUrlFinding> urlFindings,
    required String locale,
    required bool featureEnabled,
    required bool domainAgeEnabled,
    LinkUnrollEvidenceSession? unrollSession,
    ScamLinkUnrollService? unrollService,
    ScamDomainAgeService? domainAgeService,
  }) async {
    if (!featureEnabled) return const [];

    await LinkShortenerConfig.ensureLoaded();

    final conn = await (connectivityOverride?.call() ??
        Connectivity().checkConnectivity());
    if (conn.every((c) => c == ConnectivityResult.none)) {
      return const [];
    }

    final candidates = _candidateShortUrls(urlFindings);
    if (candidates.isEmpty) return const [];

    final session = unrollSession ?? LinkUnrollEvidenceSession();
    final api = unrollService ?? ScamLinkUnrollService();
    final ageApi = domainAgeService ?? ScamDomainAgeService();
    final out = <ScamEvidence>[];

    for (final item in candidates.take(maxUnrollsPerSubmission)) {
      if (!session.markUnroll(item.url)) continue;

      final result = await api.unrollShortUrl(item.url);
      out.addAll(
        LinkUnrollEvidenceGenerator.fromUnroll(
          result: result,
          locale: locale,
          shortHost: item.host,
        ),
      );

      final finalDomain = result.finalRegistrableDomain;
      if (domainAgeEnabled &&
          result.resolved &&
          finalDomain != null &&
          finalDomain.isNotEmpty &&
          !_isOfficialDomain(finalDomain)) {
        final age = await ageApi.lookupRegistrableDomain(finalDomain);
        final ageEvidence = DomainAgeEvidenceGenerator.fromLookup(
          domain: finalDomain,
          locale: locale,
          result: age,
        );
        if (ageEvidence != null) out.add(ageEvidence);
      }
    }

    return out;
  }

  static List<_ShortUrlCandidate> _candidateShortUrls(
    List<ScamShieldUrlFinding> findings,
  ) {
    int score(ScamShieldUrlFinding f) {
      if (!f.flags.contains('ss_flag_url_shortener')) return -1;
      var s = 0;
      if (f.flags.contains('ss_flag_unusual_payment')) s += 3;
      if (f.flags.contains('ss_flag_upfront_fee')) s += 3;
      return s;
    }

    final ranked = [...findings]..sort((a, b) => score(b).compareTo(score(a)));
    final seen = <String>{};
    final out = <_ShortUrlCandidate>[];

    for (final f in ranked) {
      if (!f.flags.contains('ss_flag_url_shortener')) continue;
      if (!LinkShortenerConfig.isShortenerUrl(f.url)) continue;
      final key = f.url.split('#').first.trim().toLowerCase();
      if (seen.add(key)) {
        out.add(_ShortUrlCandidate(url: f.url, host: f.domain));
      }
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
  static List<_ShortUrlCandidate> candidatesForTest(
    List<ScamShieldUrlFinding> findings,
  ) =>
      _candidateShortUrls(findings);
}

class _ShortUrlCandidate {
  const _ShortUrlCandidate({required this.url, required this.host});
  final String url;
  final String host;
}
