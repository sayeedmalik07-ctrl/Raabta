import 'package:raabta/features/community/domain/rumour_check/rumour_check_models.dart';
import 'package:raabta/features/scam_shield/domain/official_directory.dart';

/// Validates a user-supplied source URL against the ScamShield official directory.
///
/// This confirms only that the **link host** is on the allowlist (or is rejected).
/// It does **not** verify that the forwarded rumour claim is true.
class RumourOfficialSourceValidation {
  const RumourOfficialSourceValidation({
    required this.outcome,
    this.normalizedHost,
    this.directoryEntryId,
  });

  final RumourOfficialSourceOutcome outcome;
  final String? normalizedHost;

  /// Official directory entity id when [outcome] is [RumourOfficialSourceOutcome.officialAllowlisted].
  final String? directoryEntryId;

  bool get isOfficialAllowlisted =>
      outcome == RumourOfficialSourceOutcome.officialAllowlisted;

  bool get permitsContextNoteWithoutOfficialSource =>
      outcome == RumourOfficialSourceOutcome.unverified;

  bool get shouldBlockSubmission =>
      outcome == RumourOfficialSourceOutcome.rejectedInvalid ||
      outcome == RumourOfficialSourceOutcome.rejectedDeceptive;
}

abstract final class RumourOfficialSourceValidator {
  /// Deterministic, offline validation — no redirect following or network I/O.
  static RumourOfficialSourceValidation validate(String rawUrl) {
    final trimmed = rawUrl.trim();
    if (trimmed.isEmpty) {
      return const RumourOfficialSourceValidation(
        outcome: RumourOfficialSourceOutcome.rejectedInvalid,
      );
    }

    final uri = _parseUri(trimmed);
    if (uri == null) {
      return const RumourOfficialSourceValidation(
        outcome: RumourOfficialSourceOutcome.rejectedInvalid,
      );
    }

    if (uri.userInfo.isNotEmpty) {
      return const RumourOfficialSourceValidation(
        outcome: RumourOfficialSourceOutcome.rejectedInvalid,
      );
    }

    final host = uri.host.trim();
    if (host.isEmpty || !_isPlausiblePublicHost(host)) {
      return const RumourOfficialSourceValidation(
        outcome: RumourOfficialSourceOutcome.rejectedInvalid,
      );
    }

    final scheme = uri.scheme.toLowerCase();
    if (scheme != 'https') {
      return RumourOfficialSourceValidation(
        outcome: RumourOfficialSourceOutcome.rejectedInvalid,
        normalizedHost: host.toLowerCase(),
      );
    }

    final entry = OfficialDirectory.lookupByDomain(host);
    if (entry != null) {
      return RumourOfficialSourceValidation(
        outcome: RumourOfficialSourceOutcome.officialAllowlisted,
        normalizedHost: host.toLowerCase(),
        directoryEntryId: entry.id,
      );
    }

    if (OfficialDirectory.detectLookalikeDomain(host)) {
      return RumourOfficialSourceValidation(
        outcome: RumourOfficialSourceOutcome.rejectedDeceptive,
        normalizedHost: host.toLowerCase(),
      );
    }

    return RumourOfficialSourceValidation(
      outcome: RumourOfficialSourceOutcome.unverified,
      normalizedHost: host.toLowerCase(),
    );
  }

  static Uri? _parseUri(String input) {
    final direct = Uri.tryParse(input);
    if (direct != null && direct.hasScheme && direct.host.isNotEmpty) {
      return direct;
    }
    if (!input.contains('://')) {
      return Uri.tryParse('https://$input');
    }
    return direct;
  }

  /// Official Qatar sources use public DNS names (not bare words or IPs here).
  static bool _isPlausiblePublicHost(String host) {
    if (host.contains(' ')) return false;
    return host.contains('.');
  }
}
