/// Static returnee-support definitions — link-out only, client-side.
enum ReturnSupportState { available, notAvailable }

class ReturnSupportHotlineDef {
  const ReturnSupportHotlineDef({
    required this.labelKey,
    required this.number,
    this.dialUri,
  });

  final String labelKey;
  final String number;
  final String? dialUri;
}

class ReturnSupportProgramDef {
  const ReturnSupportProgramDef({
    required this.id,
    required this.nameKey,
    required this.summaryKey,
    required this.officialUrl,
    required this.urlVerifiedIso,
  });

  final String id;
  final String nameKey;
  final String summaryKey;
  final String officialUrl;
  final String urlVerifiedIso;
}

class ReturnSupportBundleDef {
  const ReturnSupportBundleDef({
    required this.state,
    required this.authorityNameKey,
    required this.programs,
    required this.requirementsNoteKey,
    required this.lastVerifiedIso,
    required this.recheckNoteKey,
    this.hotlines = const [],
    this.preReturnPortalNoteKey,
  });

  final ReturnSupportState state;
  final String authorityNameKey;
  final List<ReturnSupportProgramDef> programs;
  final List<ReturnSupportHotlineDef> hotlines;
  final String requirementsNoteKey;
  final String lastVerifiedIso;
  final String recheckNoteKey;

  /// Philippines: online registration before return (portal only — no eligibility claim).
  final String? preReturnPortalNoteKey;
}

class ReturnSupportFallbackLinkDef {
  const ReturnSupportFallbackLinkDef({
    required this.id,
    required this.titleKey,
    required this.descriptionKey,
    this.url,
    this.phone,
  });

  final String id;
  final String titleKey;
  final String descriptionKey;
  final String? url;
  final String? phone;
}

enum WelcomeHomeMatchKind {
  profileSupported,
  sessionCountry,
  unsupportedNationality,
  noNationality,
}

class WelcomeHomeReturnSupportView {
  const WelcomeHomeReturnSupportView({
    required this.matchKind,
    this.countryId,
    this.countryDisplayNameKey,
    this.regionId,
    required this.bundle,
    this.fallbackLinks = const [],
  });

  final WelcomeHomeMatchKind matchKind;
  final String? countryId;
  final String? countryDisplayNameKey;
  final String? regionId;
  final ReturnSupportBundleDef bundle;
  final List<ReturnSupportFallbackLinkDef> fallbackLinks;
}
