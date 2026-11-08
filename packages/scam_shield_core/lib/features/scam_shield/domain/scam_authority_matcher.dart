import 'package:scam_shield_core/features/scam_shield/data/scam_authority_directory_config.dart';
import 'package:scam_shield_core/features/scam_shield/domain/scam_risk_signal.dart';
import 'package:scam_shield_core/features/scam_shield/domain/scam_shield_models.dart';

enum ScamAuthorityMatchKind {
  none,
  verifiedOfficialChannel,
  domainMismatch,
  lookalikeDomain,
  claimWithoutDomain,
}

class ScamAuthorityMatchResult {
  const ScamAuthorityMatchResult({
    required this.kind,
    required this.matchedEntries,
    required this.claimedEntries,
    required this.domainEntries,
    this.mismatchEntryId,
  });

  final ScamAuthorityMatchKind kind;
  final List<ScamAuthorityEntry> matchedEntries;
  final List<ScamAuthorityEntry> claimedEntries;
  final List<ScamAuthorityEntry> domainEntries;
  final String? mismatchEntryId;

  bool get verifiedChannel => kind == ScamAuthorityMatchKind.verifiedOfficialChannel;

  bool get domainMismatch => kind == ScamAuthorityMatchKind.domainMismatch;

  String? get primaryEntryNameKey =>
      matchedEntries.isNotEmpty ? matchedEntries.first.nameKey : null;
}

/// Matches pasted content against the bundled authority directory.
abstract final class ScamAuthorityMatcher {
  static ScamAuthorityMatchResult match({
    required String text,
    required List<ScamShieldUrlFinding> urlFindings,
    required Set<ScamRiskSignal> signals,
  }) {
    final claimed = ScamAuthorityDirectoryConfig.findClaimedInText(text);
    final domainEntries = <ScamAuthorityEntry>[];
    var hasLookalike = false;
    var hasSuspiciousUrl = false;

    for (final finding in urlFindings) {
      if (finding.flags.contains('ss_flag_lookalike_domain') ||
          finding.flags.contains('ss_flag_nonstandard_gov_tld')) {
        hasLookalike = true;
      }
      if (finding.flags.isNotEmpty && !finding.isKnownLegitimate) {
        hasSuspiciousUrl = true;
      }
      final entry = ScamAuthorityDirectoryConfig.findByDomain(finding.domain);
      if (entry != null && !domainEntries.contains(entry)) {
        domainEntries.add(entry);
      }
    }

    if (hasLookalike) {
      return ScamAuthorityMatchResult(
        kind: ScamAuthorityMatchKind.lookalikeDomain,
        matchedEntries: const [],
        claimedEntries: claimed,
        domainEntries: domainEntries,
      );
    }

    if (claimed.isNotEmpty && domainEntries.isEmpty) {
      return ScamAuthorityMatchResult(
        kind: ScamAuthorityMatchKind.claimWithoutDomain,
        matchedEntries: const [],
        claimedEntries: claimed,
        domainEntries: domainEntries,
      );
    }

    if (claimed.isNotEmpty && domainEntries.isNotEmpty) {
      final claimedIds = claimed.map((e) => e.id).toSet();
      final domainIds = domainEntries.map((e) => e.id).toSet();
      if (claimedIds.intersection(domainIds).isEmpty) {
        return ScamAuthorityMatchResult(
          kind: ScamAuthorityMatchKind.domainMismatch,
          matchedEntries: const [],
          claimedEntries: claimed,
          domainEntries: domainEntries,
          mismatchEntryId: claimed.first.id,
        );
      }
    }

    if (domainEntries.isNotEmpty &&
        !hasSuspiciousUrl &&
        _eligibleForVerified(signals, urlFindings)) {
      return ScamAuthorityMatchResult(
        kind: ScamAuthorityMatchKind.verifiedOfficialChannel,
        matchedEntries: domainEntries,
        claimedEntries: claimed,
        domainEntries: domainEntries,
      );
    }

    return ScamAuthorityMatchResult(
      kind: ScamAuthorityMatchKind.none,
      matchedEntries: domainEntries,
      claimedEntries: claimed,
      domainEntries: domainEntries,
    );
  }

  static bool _eligibleForVerified(
    Set<ScamRiskSignal> signals,
    List<ScamShieldUrlFinding> urlFindings,
  ) {
    final allUrlsOfficial = urlFindings.isNotEmpty &&
        urlFindings.every((f) => f.isKnownLegitimate && f.flags.isEmpty);

    final effective = allUrlsOfficial
        ? signals.difference({
            ScamRiskSignal.unexpectedLink,
            ScamRiskSignal.financialImpersonation,
            ScamRiskSignal.authorityImpersonation,
            ScamRiskSignal.telecomImpersonation,
          })
        : signals;

    const blocking = {
      ScamRiskSignal.otpRequest,
      ScamRiskSignal.pinRequest,
      ScamRiskSignal.passwordRequest,
      ScamRiskSignal.cvvRequest,
      ScamRiskSignal.cardRequest,
      ScamRiskSignal.remoteAccessRequest,
      ScamRiskSignal.screenShareRequest,
      ScamRiskSignal.paymentRequest,
      ScamRiskSignal.transferRequest,
      ScamRiskSignal.cashWithdrawalRequest,
      ScamRiskSignal.arrestThreat,
      ScamRiskSignal.accountLockThreat,
      ScamRiskSignal.lookalikeDomain,
      ScamRiskSignal.unexpectedLink,
    };
    return !effective.any(blocking.contains);
  }
}
