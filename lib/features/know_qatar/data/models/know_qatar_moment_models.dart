/// Stable moment identifiers — never logged to analytics.
enum KnowQatarMomentId {
  justArrived,
  startingChangingJob,
  bringingFamily,
  hostingVisitors,
  settingUpHome,
  visitingQatar,
  goingHome,
  whenSomethingGoesWrong,
  allTopics,
}

/// Reference to a Know Qatar section, app route, or audited external official link.
enum KnowQatarMomentItemKind { section, route, external }

class KnowQatarMomentItemRef {
  const KnowQatarMomentItemRef.section(this.sectionKey)
      : kind = KnowQatarMomentItemKind.section,
        route = null,
        externalLinkId = null,
        titleKeyOverride = null,
        summaryKeyOverride = null;

  const KnowQatarMomentItemRef.route(
    this.route, {
    this.titleKeyOverride,
    this.summaryKeyOverride,
  })  : kind = KnowQatarMomentItemKind.route,
        sectionKey = null,
        externalLinkId = null;

  const KnowQatarMomentItemRef.external(this.externalLinkId)
      : kind = KnowQatarMomentItemKind.external,
        sectionKey = null,
        route = null,
        titleKeyOverride = null,
        summaryKeyOverride = null;

  final KnowQatarMomentItemKind kind;
  final String? sectionKey;
  final String? route;
  final String? externalLinkId;
  final String? titleKeyOverride;
  final String? summaryKeyOverride;
}

class KnowQatarMomentDefinition {
  const KnowQatarMomentDefinition({
    required this.id,
    required this.titleKey,
    required this.introKey,
    required this.items,
  });

  final KnowQatarMomentId id;
  final String titleKey;
  final String introKey;
  final List<KnowQatarMomentItemRef> items;
}

/// Resolved row for UI / Next Step (metadata from catalog or route labels).
class KnowQatarMomentResolvedItem {
  const KnowQatarMomentResolvedItem({
    required this.destinationKey,
    required this.isSection,
    required this.route,
    required this.titleKey,
    required this.summaryKey,
    this.isExternal = false,
    this.externalUrl,
    this.trustSourceNameKey,
    this.urlVerifiedIso,
  });

  /// Opaque resolver key, e.g. `section:residency_documents` or `route:/visa`.
  final String destinationKey;
  final bool isSection;
  final String route;
  final String titleKey;
  final String summaryKey;
  final bool isExternal;
  final String? externalUrl;
  final String? trustSourceNameKey;
  final String? urlVerifiedIso;
}

enum NextStepKind {
  deadline,
  momentItem,
  lastOpened,
  genericFallback,
}

enum NextStepSeverity { critical, amber, neutral }

class NextStepRecommendation {
  const NextStepRecommendation({
    required this.kind,
    required this.route,
    required this.titleKey,
    this.titleParams = const {},
    required this.actionKey,
    required this.severity,
    this.useDeadlineExpiryLabel = false,
  });

  final NextStepKind kind;
  final String route;
  final String titleKey;
  final Map<String, String> titleParams;
  final String actionKey;
  final NextStepSeverity severity;

  /// When true, UI may append live [DocumentDeadline.expiryLabel] (user data).
  final bool useDeadlineExpiryLabel;
}
