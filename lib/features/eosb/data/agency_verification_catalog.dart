import 'models/agency_verification_models.dart';

/// Official recruitment-agency verification portals — confirmed entries only.
///
/// Do not add countries without an independently verified self-service lookup.
abstract final class AgencyVerificationCatalog {
  static const nepal = AgencyVerificationCountryEntry(
    countryId: 'nepal',
    status: AgencyVerificationPortalStatus.verified,
    portal: AgencyVerificationPortalDef(
      authorityNameKey: 'agency_verify_nepal_authority',
      portalUrl: 'https://dofe.gov.np',
      searchInstructionKey: 'agency_verify_nepal_search',
      goodStandingStatusKey: 'agency_verify_nepal_good_standing',
      additionalVerificationKey: 'agency_verify_nepal_vacancy',
    ),
  );

  static const philippines = AgencyVerificationCountryEntry(
    countryId: 'philippines',
    status: AgencyVerificationPortalStatus.verified,
    portal: AgencyVerificationPortalDef(
      authorityNameKey: 'agency_verify_ph_authority',
      portalUrl: 'https://www.dmw.gov.ph',
      searchInstructionKey: 'agency_verify_ph_search',
      goodStandingStatusKey: 'agency_verify_ph_good_standing',
    ),
  );

  /// India — eMigrate/PGE noted in prior research; no confirmed public agency-search
  /// portal equivalent to Nepal/Philippines in this pass.
  static const india = AgencyVerificationCountryEntry(
    countryId: 'india',
    status: AgencyVerificationPortalStatus.notYetConfirmed,
    notConfirmedReasonKey: 'agency_verify_india_not_confirmed',
  );

  static AgencyVerificationCountryEntry? entryForCountryId(String countryId) {
    switch (countryId.trim().toLowerCase()) {
      case 'nepal':
        return nepal;
      case 'philippines':
        return philippines;
      case 'india':
        return india;
      default:
        return null;
    }
  }
}
