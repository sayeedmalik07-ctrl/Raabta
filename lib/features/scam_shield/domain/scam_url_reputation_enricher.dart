import 'package:raabta/features/scam_shield/domain/scam_qatar_domain_allowlist.dart';
import 'package:raabta/features/scam_shield/domain/scam_shield_models.dart';
import 'package:raabta/features/scam_shield/domain/scam_shield_sanitized_uri.dart';
import 'package:raabta/features/scam_shield/services/scam_shield_off_device_gateway.dart';
import 'package:raabta/features/scam_shield/services/scam_web_risk_service.dart';

/// Allowlist + local heuristics first; Web Risk only for unknown hosts.
abstract final class ScamUrlReputationEnricher {
  static const webRiskFlagKey = 'ss_flag_web_risk_threat';
  static const webRiskCleanKey = 'ss_flag_web_risk_not_indexed';

  static List<String> urisNeedingWebRisk(List<ScamShieldUrlFinding> findings) {
    return findings
        .where((f) => !f.isKnownLegitimate && !f.webRiskChecked)
        .map((f) => f.url)
        .toSet()
        .toList();
  }

  static String _normalizeForLookup(String url) {
    var value = url.trim();
    if (!value.startsWith('http://') && !value.startsWith('https://')) {
      value = 'https://$value';
    }
    return value;
  }

  static Future<List<ScamShieldUrlFinding>> enrichWithWebRisk({
    required List<ScamShieldUrlFinding> findings,
    required ScamWebRiskService webRiskService,
    String? userId,
  }) async {
    final candidates = urisNeedingWebRisk(findings);
    if (candidates.isEmpty) return findings;

    final sanitizedUris = candidates
        .map(ScamShieldSanitizedUri.forWebRiskLookup)
        .toList();

    final batch = await ScamShieldOffDeviceGateway.lookupWebRisk(
      webRiskService: webRiskService,
      uris: sanitizedUris,
      userId: userId,
    );

    if (batch.byUri.isEmpty && !batch.capReached) {
      return findings
          .map(
            (f) => candidates.contains(f.url)
                ? f.copyWith(webRiskChecked: true, webRiskUnavailable: true)
                : f,
          )
          .toList();
    }

    return findings.map((finding) {
      if (finding.isKnownLegitimate || finding.webRiskChecked) {
        return finding;
      }

      final sanitized = ScamShieldSanitizedUri.forWebRiskLookup(finding.url).value;
      final lookupKey = batch.byUri.keys.firstWhere(
        (key) =>
            key == sanitized ||
            key == finding.url ||
            key == _normalizeForLookup(finding.url) ||
            key.contains(finding.domain),
        orElse: () => '',
      );

      if (lookupKey.isEmpty) {
        return finding.copyWith(
          webRiskChecked: true,
          webRiskUnavailable: true,
        );
      }

      final verdict = batch.byUri[lookupKey]!;
      final extraFlags = [...finding.flags];
      if (verdict.flagged) {
        if (!extraFlags.contains(webRiskFlagKey)) {
          extraFlags.add(webRiskFlagKey);
        }
      } else if (!verdict.unavailable) {
        if (!extraFlags.contains(webRiskCleanKey)) {
          extraFlags.add(webRiskCleanKey);
        }
      }

      return finding.copyWith(
        flags: extraFlags,
        webRiskChecked: true,
        webRiskFlagged: verdict.flagged,
        webRiskThreatTypes: verdict.threatTypes,
        webRiskUnavailable: verdict.unavailable,
      );
    }).toList();
  }

  static bool shouldSkipWebRisk(String domain) {
    return ScamQatarDomainAllowlist.isKnownLegitimate(domain);
  }
}
