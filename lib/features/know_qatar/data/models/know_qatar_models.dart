import 'package:flutter/material.dart';

/// Severity levels aligned with EOSB legal warning visual language.
enum KnowQatarCalloutSeverity {
  info,
  warning,
  violation,
  critical,
}

/// Deep-link to an existing Raabta engine — this feature never acts itself.
class KnowQatarActionLink {
  const KnowQatarActionLink({
    required this.labelKey,
    required this.route,
    required this.icon,
  });

  final String labelKey;
  final String route;
  final IconData icon;
}

class KnowQatarLegalCallout {
  const KnowQatarLegalCallout({
    required this.titleKey,
    required this.bodyKey,
    this.severity = KnowQatarCalloutSeverity.warning,
  });

  final String titleKey;
  final String bodyKey;
  final KnowQatarCalloutSeverity severity;
}

class KnowQatarTimelineMilestone {
  const KnowQatarTimelineMilestone({
    required this.yearKey,
    required this.titleKey,
    required this.subtitleKey,
    required this.icon,
    required this.colorValue,
  });

  final String yearKey;
  final String titleKey;
  final String subtitleKey;
  final IconData icon;
  final int colorValue;
}

class KnowQatarProgressMilestone {
  const KnowQatarProgressMilestone({
    required this.labelKey,
    required this.progress,
    required this.colorValue,
  });

  final String labelKey;
  final double progress;
  final int colorValue;
}

enum KnowQatarSectionPublicationStatus {
  published,
  draft,
}

/// One Know Qatar section — static bundled content.
class KnowQatarSection {
  const KnowQatarSection({
    required this.sectionKey,
    required this.titleKey,
    required this.teaserKey,
    required this.bodyKey,
    required this.lastReviewed,
    required this.sourceLabelKey,
    required this.sourceUrl,
    this.publicationStatus = KnowQatarSectionPublicationStatus.published,
    this.actionLinks = const [],
    this.timelineMilestones = const [],
    this.progressMilestones = const [],
    this.legalCallouts = const [],
    this.showCultureChips = false,
    this.showNationalityHighlight = false,
    this.aiPromptKey,
  });

  final String sectionKey;
  final String titleKey;
  final String teaserKey;
  final String bodyKey;
  final DateTime lastReviewed;
  final String sourceLabelKey;
  final String sourceUrl;
  final KnowQatarSectionPublicationStatus publicationStatus;
  final List<KnowQatarActionLink> actionLinks;
  final List<KnowQatarTimelineMilestone> timelineMilestones;
  final List<KnowQatarProgressMilestone> progressMilestones;
  final List<KnowQatarLegalCallout> legalCallouts;
  final bool showCultureChips;
  final bool showNationalityHighlight;
  final String? aiPromptKey;

  bool get isPublished =>
      publicationStatus == KnowQatarSectionPublicationStatus.published;
}
