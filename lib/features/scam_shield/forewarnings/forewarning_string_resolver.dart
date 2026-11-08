import 'package:raabta/features/eosb/presentation/l10n/qatar_recruitment_agency_verification_strings.dart';
import 'package:raabta/features/marketplace/presentation/l10n/marketplace_strings.dart';
import 'package:raabta/features/scam_shield/presentation/l10n/scam_shield_strings.dart';
import 'package:raabta/screens/jobs/l10n/jobs_strings.dart';

/// Resolves bundled reuse keys to existing verified copy — no new legal claims.
abstract final class ForewarningStringResolver {
  static String resolve(String reuseKey, String locale) {
    final parts = reuseKey.split(':');
    if (parts.length != 2) return reuseKey;
    final namespace = parts[0];
    final key = parts[1];
    return switch (namespace) {
      'jobs' => JobsStrings.t(key, locale),
      'ss' => ScamShieldStrings.t(key, locale),
      'mp' => MarketplaceStrings.t(key, locale),
      'qr' => QatarRecruitmentAgencyVerificationStrings.t(key, locale),
      _ => key,
    };
  }
}
