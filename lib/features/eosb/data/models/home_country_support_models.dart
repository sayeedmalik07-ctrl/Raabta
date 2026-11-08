/// Static home-country support resource definitions (client-side config).
enum HomeCountrySupportContactType { phone, email, url, text }

class HomeCountrySupportContactDef {
  const HomeCountrySupportContactDef({
    required this.labelKey,
    required this.value,
    required this.type,
  });

  final String labelKey;
  final String value;
  final HomeCountrySupportContactType type;
}

class HomeCountrySupportResourceDef {
  const HomeCountrySupportResourceDef({
    required this.id,
    required this.titleKey,
    required this.descriptionKey,
    this.url,
    this.contacts = const [],
    this.needsVerification = false,
  });

  final String id;
  final String titleKey;
  final String descriptionKey;
  final String? url;
  final List<HomeCountrySupportContactDef> contacts;
  final bool needsVerification;
}

class HomeCountrySupportRegionDef {
  const HomeCountrySupportRegionDef({
    required this.regionId,
    required this.titleKey,
    required this.resources,
    this.regionAliases = const [],
  });

  final String regionId;
  final String titleKey;
  final List<String> regionAliases;
  final List<HomeCountrySupportResourceDef> resources;
}

class HomeCountrySupportCountryDef {
  const HomeCountrySupportCountryDef({
    required this.countryId,
    required this.nationalityAliases,
    required this.displayNameKey,
    required this.nationalResources,
    this.regions = const {},
    this.beforeYouSign,
  });

  final String countryId;
  final List<String> nationalityAliases;
  final String displayNameKey;
  final List<HomeCountrySupportResourceDef> nationalResources;
  final Map<String, HomeCountrySupportRegionDef> regions;
  final BeforeYouSignChecklistDef? beforeYouSign;
}

/// Universal job-offer authenticity checklist — same for all origin countries.
class OfferAuthenticityChecklistDef {
  const OfferAuthenticityChecklistDef({
    required this.introKey,
    required this.communicationRedFlagKeys,
    required this.paymentRedFlagKeys,
    required this.documentationRedFlagKeys,
    required this.verificationActionKeys,
  });

  final String introKey;
  final List<String> communicationRedFlagKeys;
  final List<String> paymentRedFlagKeys;
  final List<String> documentationRedFlagKeys;
  final List<String> verificationActionKeys;

  List<String> get allItemKeys => [
        ...communicationRedFlagKeys,
        ...paymentRedFlagKeys,
        ...documentationRedFlagKeys,
        ...verificationActionKeys,
      ];
}

/// Static "Before You Sign" checklist tied to a home country.
class BeforeYouSignChecklistDef {
  const BeforeYouSignChecklistDef({
    required this.maxFeeRuleKey,
    this.maxFeeNeedsVerification = true,
    this.staleWarningKey,
    this.staleWarningNeedsVerification = false,
    required this.redFlagKeys,
    required this.originVerificationChannels,
  });

  final String maxFeeRuleKey;
  final bool maxFeeNeedsVerification;
  final String? staleWarningKey;
  final bool staleWarningNeedsVerification;
  final List<String> redFlagKeys;
  final List<HomeCountrySupportResourceDef> originVerificationChannels;
}

enum BeforeYouSignStatus { hidden, supported }

class BeforeYouSignView {
  const BeforeYouSignView.hidden()
      : status = BeforeYouSignStatus.hidden,
        countryId = null,
        checklist = null,
        offerAuthenticityChecklist = null,
        qatarVerificationChannels = const [];

  const BeforeYouSignView.supported({
    required this.countryId,
    required this.checklist,
    required this.offerAuthenticityChecklist,
    required this.qatarVerificationChannels,
  })  : status = BeforeYouSignStatus.supported;

  final BeforeYouSignStatus status;
  final String? countryId;
  final BeforeYouSignChecklistDef? checklist;
  final OfferAuthenticityChecklistDef? offerAuthenticityChecklist;
  final List<HomeCountrySupportResourceDef> qatarVerificationChannels;
}

enum HomeCountrySupportStatus { hidden, comingSoon, supported }

class HomeCountrySupportView {
  const HomeCountrySupportView.hidden()
      : status = HomeCountrySupportStatus.hidden,
        countryId = null,
        countryLabel = null,
        nationalResources = const [],
        regionalSections = const [],
        qatarProcedureChannels = const [];

  const HomeCountrySupportView.comingSoon({
    required this.countryLabel,
    this.qatarProcedureChannels = const [],
  })  : status = HomeCountrySupportStatus.comingSoon,
        countryId = null,
        nationalResources = const [],
        regionalSections = const [];

  const HomeCountrySupportView.supported({
    required this.countryId,
    required this.nationalResources,
    required this.regionalSections,
    this.qatarProcedureChannels = const [],
  })  : status = HomeCountrySupportStatus.supported,
        countryLabel = null;

  final HomeCountrySupportStatus status;
  final String? countryId;
  final String? countryLabel;
  final List<HomeCountrySupportResourceDef> nationalResources;
  final List<HomeCountrySupportRegionDef> regionalSections;

  /// Qatar-side MoL/ADLSA complaint channels — counterpart to home-country resources.
  final List<HomeCountrySupportResourceDef> qatarProcedureChannels;
}

class HomeCountryUserContext {
  const HomeCountryUserContext({
    required this.nationality,
    this.homeState = '',
  });

  final String nationality;
  final String homeState;

  bool get hasNationality => nationality.trim().isNotEmpty;
}
