enum LinkSafetyLabelType {
  lookalikeOfficial,
  shortenedLink,
  apkLink,
  paymentLinkInChat,
}

enum LinkSafetySurface {
  communityFeed,
  askQatar,
  lostFound,
  events,
  marketplaceListing,
  marketplaceChat,
  housingListing,
  housingChat,
  servicesListing,
  servicesChat,
  jobsListing,
  jobsChat,
  businessListing,
}

class LinkSafetyUrlLabel {
  const LinkSafetyUrlLabel({
    required this.url,
    required this.type,
    this.officialOrganisationName,
  });

  final String url;
  final LinkSafetyLabelType type;
  final String? officialOrganisationName;

  bool get isConcern =>
      type == LinkSafetyLabelType.lookalikeOfficial ||
      type == LinkSafetyLabelType.apkLink ||
      type == LinkSafetyLabelType.paymentLinkInChat;
}

class LinkSafetyTextAssessment {
  const LinkSafetyTextAssessment({
    required this.urls,
    required this.labels,
  });

  static const empty = LinkSafetyTextAssessment(urls: [], labels: []);

  final List<String> urls;
  final List<LinkSafetyUrlLabel> labels;
}
