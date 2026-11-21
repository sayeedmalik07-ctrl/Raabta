/// Static agency-verification portal config — Raabta links to authorities only.
enum AgencyVerificationPortalStatus { verified, notYetConfirmed }

class AgencyVerificationPortalDef {
  const AgencyVerificationPortalDef({
    required this.authorityNameKey,
    required this.portalUrl,
    required this.searchInstructionKey,
    required this.goodStandingStatusKey,
    this.additionalVerificationKey,
  });

  final String authorityNameKey;
  final String portalUrl;
  final String searchInstructionKey;

  /// Exact status label(s) from the government portal — not paraphrased.
  final String goodStandingStatusKey;

  /// Optional second check (e.g. Nepal Swikriti / Approved Vacancies).
  final String? additionalVerificationKey;
}

class AgencyVerificationCountryEntry {
  const AgencyVerificationCountryEntry({
    required this.countryId,
    required this.status,
    this.portal,
    this.notConfirmedReasonKey,
  });

  final String countryId;
  final AgencyVerificationPortalStatus status;
  final AgencyVerificationPortalDef? portal;
  final String? notConfirmedReasonKey;
}

enum AgencyVerificationDisplayStatus {
  noCountrySelected,
  verifiedPortal,
  notYetConfirmed,
}

class AgencyVerificationView {
  const AgencyVerificationView.noCountrySelected()
      : status = AgencyVerificationDisplayStatus.noCountrySelected,
        countryId = null,
        countryDisplayNameKey = null,
        portal = null,
        notConfirmedReasonKey = null;

  const AgencyVerificationView.verified({
    required this.countryId,
    required this.countryDisplayNameKey,
    required this.portal,
  })  : status = AgencyVerificationDisplayStatus.verifiedPortal,
        notConfirmedReasonKey = null;

  const AgencyVerificationView.notYetConfirmed({
    required this.countryId,
    required this.countryDisplayNameKey,
    required this.notConfirmedReasonKey,
  })  : status = AgencyVerificationDisplayStatus.notYetConfirmed,
        portal = null;

  final AgencyVerificationDisplayStatus status;
  final String? countryId;
  final String? countryDisplayNameKey;
  final AgencyVerificationPortalDef? portal;
  final String? notConfirmedReasonKey;
}
