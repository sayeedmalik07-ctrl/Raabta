import 'package:flutter/material.dart';

/// Static local taxonomy entry — not stored in Firestore.
///
/// Browse taxonomy IDs ([id]) are stable forever. Optional presentation fields
/// (Decision §6) drive hub landing tiles and search without new Firestore reads.
class ServiceCategory {
  const ServiceCategory({
    required this.id,
    required this.name,
    required this.icon,
    required this.subServices,
    required this.frontGroupId,
    this.presentationOrder = 0,
    this.isPopular = false,
    this.searchAliases = const [],
  });

  final String id;
  final String name;
  final IconData icon;
  final List<String> subServices;

  /// One of [ServiceFrontGroupIds] — maps this category into a landing tile group.
  final String frontGroupId;

  /// Sort key within the full 24 categories (1..24). Distinct [frontGroupId] buckets
  /// use contiguous bands for stable ordering in "All services" / admin tools.
  final int presentationOrder;

  /// Surface on hub highlights when true (optional; UX batches may ignore).
  final bool isPopular;

  /// Extra English tokens for local search (synonyms). Does not replace [id] or leaf strings.
  final List<String> searchAliases;
}

class ServiceSearchHit {
  const ServiceSearchHit({
    required this.category,
    required this.subService,
  });

  final ServiceCategory category;
  final String subService;
}
