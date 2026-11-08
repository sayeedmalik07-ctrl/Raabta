import 'package:flutter/material.dart';

/// Visitor personas — ready for roadmap item 4 filtering (not applied in v1 UI).
enum LocalLifeAudience {
  tourist,
  businessVisitor,
  residentTrack,
  all,
}

enum LocalLifeDurationBand {
  shortStay,
  extendedVisit,
  residentTrack,
  all,
}

enum LocalLifePriority {
  mustKnow,
  useful,
  situational,
}

enum LocalLifeCategory {
  cultureEtiquette,
  moneyPayments,
  connectivity,
  gettingAround,
  healthSafety,
  governmentDocuments,
  homeEssentials,
  familyPets,
  relationships,
}

extension LocalLifeCategoryExt on LocalLifeCategory {
  String get id => switch (this) {
        LocalLifeCategory.cultureEtiquette => 'culture_etiquette',
        LocalLifeCategory.moneyPayments => 'money_payments',
        LocalLifeCategory.connectivity => 'connectivity',
        LocalLifeCategory.gettingAround => 'getting_around',
        LocalLifeCategory.healthSafety => 'health_safety',
        LocalLifeCategory.governmentDocuments => 'government_documents',
        LocalLifeCategory.homeEssentials => 'home_essentials',
        LocalLifeCategory.familyPets => 'family_pets',
        LocalLifeCategory.relationships => 'relationships',
      };

  String get titleKey => 'll_cat_${id}_title';

  String get descriptionKey => 'll_cat_${id}_desc';

  IconData get icon => switch (this) {
        LocalLifeCategory.cultureEtiquette => Icons.menu_book_outlined,
        LocalLifeCategory.moneyPayments => Icons.payments_outlined,
        LocalLifeCategory.connectivity => Icons.sim_card_outlined,
        LocalLifeCategory.gettingAround => Icons.directions_transit,
        LocalLifeCategory.healthSafety => Icons.health_and_safety_outlined,
        LocalLifeCategory.governmentDocuments => Icons.account_balance_outlined,
        LocalLifeCategory.homeEssentials => Icons.home_outlined,
        LocalLifeCategory.familyPets => Icons.family_restroom_outlined,
        LocalLifeCategory.relationships => Icons.favorite_outline,
      };

  static LocalLifeCategory? fromId(String? raw) {
    if (raw == null) return null;
    for (final c in LocalLifeCategory.values) {
      if (c.id == raw) return c;
    }
    return null;
  }
}

/// Static, sourced local-life entry — base content is never AI-generated.
class LocalLifeEntry {
  const LocalLifeEntry({
    required this.id,
    required this.category,
    required this.titleKey,
    required this.summaryKey,
    required this.actionKey,
    this.tipKeys = const [],
    this.audience = const [LocalLifeAudience.all],
    this.durationBand = LocalLifeDurationBand.all,
    this.priority = LocalLifePriority.useful,
    this.sourceLabelKey,
    this.sourceUrl,
    this.dateLastVerified,
    this.ambiguousGuidance = false,
    this.fairPriceItemId,
    this.relatedRoute,
  });

  final String id;
  final LocalLifeCategory category;
  final String titleKey;
  final String summaryKey;
  final String actionKey;
  final List<String> tipKeys;
  final List<LocalLifeAudience> audience;
  final LocalLifeDurationBand durationBand;
  final LocalLifePriority priority;
  final String? sourceLabelKey;
  final String? sourceUrl;
  final String? dateLastVerified;
  final bool ambiguousGuidance;
  final String? fairPriceItemId;
  final String? relatedRoute;

  String get priorityKey => switch (priority) {
        LocalLifePriority.mustKnow => 'll_priority_must_know',
        LocalLifePriority.useful => 'll_priority_useful',
        LocalLifePriority.situational => 'll_priority_situational',
      };
}
