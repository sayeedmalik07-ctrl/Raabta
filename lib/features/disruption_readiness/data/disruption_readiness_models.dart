/// Bundled disruption-readiness content — static only, no live status.
enum DisruptionEntryProfile {
  leavingQatar,
  knowQatar,
  tripPlanner,
}

enum DisruptionPublicationStatus {
  /// Shown when verified and included in profile lists.
  published,

  /// Stored in catalog but hidden from user-facing lists.
  draft,
}

enum DisruptionSourceVerification {
  verified,
  unavailable,
}

class DisruptionOfficialSourceRef {
  const DisruptionOfficialSourceRef({
    required this.nameKey,
    this.officialUrl,
    required this.lastVerifiedIso,
    required this.verification,
  });

  final String nameKey;
  final String? officialUrl;
  final String lastVerifiedIso;
  final DisruptionSourceVerification verification;

  bool get hasLiveLink =>
      verification == DisruptionSourceVerification.verified &&
      officialUrl != null &&
      officialUrl!.trim().isNotEmpty;
}

class DisruptionExternalLink {
  const DisruptionExternalLink({
    required this.labelKey,
    this.officialUrl,
    required this.lastVerifiedIso,
    required this.verification,
  });

  final String labelKey;
  final String? officialUrl;
  final String lastVerifiedIso;
  final DisruptionSourceVerification verification;

  bool get showInUi => verification == DisruptionSourceVerification.verified &&
      officialUrl != null &&
      officialUrl!.trim().isNotEmpty;
}

class DisruptionContentBlock {
  const DisruptionContentBlock({
    required this.id,
    required this.titleKey,
    required this.bodyKey,
    required this.publicationStatus,
    this.source,
    this.links = const [],
    this.profiles = const [
      DisruptionEntryProfile.leavingQatar,
      DisruptionEntryProfile.knowQatar,
      DisruptionEntryProfile.tripPlanner,
    ],
  });

  final String id;
  final String titleKey;
  final String bodyKey;
  final DisruptionPublicationStatus publicationStatus;
  final DisruptionOfficialSourceRef? source;
  final List<DisruptionExternalLink> links;
  final List<DisruptionEntryProfile> profiles;

  bool get isPublished => publicationStatus == DisruptionPublicationStatus.published;

  bool appliesTo(DisruptionEntryProfile profile) => profiles.contains(profile);
}

enum DisruptionEmbassyPortalStatus {
  verified,
  notYetConfirmed,
}

class DisruptionEmbassyCountryEntry {
  const DisruptionEmbassyCountryEntry({
    required this.countryId,
    required this.status,
    this.portalUrl,
    this.authorityNameKey,
    this.notConfirmedReasonKey,
    this.lastVerifiedIso,
  });

  final String countryId;
  final DisruptionEmbassyPortalStatus status;
  final String? portalUrl;
  final String? authorityNameKey;
  final String? notConfirmedReasonKey;
  final String? lastVerifiedIso;
}
