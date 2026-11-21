import 'package:flutter/material.dart';

enum SecurityAwarenessCampaignKind {
  elevatedAdvisory,
  monthlyTip,
  postIncident,
}

/// Home Today security guidance campaign (local, preference-gated).
class SecurityAwarenessCampaign {
  const SecurityAwarenessCampaign({
    required this.id,
    required this.kind,
    required this.headline,
    required this.steps,
    required this.sourceLabel,
    required this.ctaLabel,
    required this.ctaRoute,
    required this.expiresAt,
    required this.elevatedVisual,
    required this.attentionComposite,
    this.advisoryId,
    this.topicId,
    this.secondaryCtaLabel,
    this.secondaryCtaRoute,
  });

  final String id;
  final SecurityAwarenessCampaignKind kind;
  final String headline;
  final List<String> steps;
  final String sourceLabel;
  final String ctaLabel;
  final String ctaRoute;
  final DateTime expiresAt;
  final bool elevatedVisual;
  final double attentionComposite;
  final String? advisoryId;
  final String? topicId;
  final String? secondaryCtaLabel;
  final String? secondaryCtaRoute;

  Color accentColor(bool elevated) => elevated
      ? const Color(0xFFE53935)
      : const Color(0xFF26C6DA);
}
