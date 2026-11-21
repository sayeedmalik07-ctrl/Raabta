import 'package:scam_shield_core/features/scam_shield/domain/official_directory.dart';

/// Delegates to [OfficialDirectory] — single source of truth for official domains.
abstract final class ScamQatarDomainAllowlist {
  static bool isKnownLegitimate(String host) {
    return OfficialDirectory.isKnownLegitimateHost(host);
  }
}
