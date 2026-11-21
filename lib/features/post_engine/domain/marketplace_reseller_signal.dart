import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:raabta/features/post_engine/data/post_schema_adapter.dart';
import 'package:raabta/features/post_engine/domain/post_trust_engine.dart';

/// Private poster-only nudge — not shown on published listings.
class MarketplaceResellerSignal {
  const MarketplaceResellerSignal({required this.reasonKey});

  final String reasonKey;

  bool get shouldShow => reasonKey.isNotEmpty;
}

/// Lightweight deterministic reseller-pattern detection for marketplace posters.
class MarketplaceResellerSignalEvaluator {
  const MarketplaceResellerSignalEvaluator({
    this.recentListingThreshold = 5,
    this.recentWindowDays = 7,
    this.similarListingThreshold = 2,
    this.newConditionRatioThreshold = 0.8,
    this.newConditionMinListings = 3,
  });

  final int recentListingThreshold;
  final int recentWindowDays;
  final int similarListingThreshold;
  final double newConditionRatioThreshold;
  final int newConditionMinListings;

  MarketplaceResellerSignal evaluate({
    required List<Map<String, dynamic>> ownerListings,
    required Map<String, dynamic> draftValues,
    required String categoryPath,
    DateTime? now,
  }) {
    if (ownerListings.isEmpty) return const MarketplaceResellerSignal(reasonKey: '');

    final clock = now ?? DateTime.now();
    final cutoff = clock.subtract(Duration(days: recentWindowDays));

    final recent = ownerListings.where((listing) {
      final created = listing['createdAt'];
      if (created is DateTime) return !created.isBefore(cutoff);
      return true;
    }).toList();

    if (recent.length >= recentListingThreshold) {
      return const MarketplaceResellerSignal(
        reasonKey: 'marketplace_reseller_nudge_frequency',
      );
    }

    final draftFingerprint = postListingFingerprint(
      fieldValues: draftValues,
      categoryPath: categoryPath,
    );
    var similarCount = 0;
    for (final listing in ownerListings) {
      final other = postListingFingerprint(
        fieldValues: listing,
        categoryPath: categoryPath,
      );
      if (other == draftFingerprint) similarCount++;
    }
    if (similarCount >= similarListingThreshold) {
      return const MarketplaceResellerSignal(
        reasonKey: 'marketplace_reseller_nudge_similar',
      );
    }

    final newCount = ownerListings.where((listing) {
      final condition =
          (listing['condition'] ?? listing['conditionLabel'])?.toString() ?? '';
      return _isNewCondition(condition);
    }).length;

    if (ownerListings.length >= newConditionMinListings &&
        newCount / ownerListings.length >= newConditionRatioThreshold) {
      return const MarketplaceResellerSignal(
        reasonKey: 'marketplace_reseller_nudge_new_items',
      );
    }

    return const MarketplaceResellerSignal(reasonKey: '');
  }

  static bool _isNewCondition(String raw) {
    final value = raw.trim().toLowerCase();
    return value.contains('new') || value.contains('brand new');
  }
}

/// Loads all active marketplace listings for one owner (any category).
Future<List<Map<String, dynamic>>> loadOwnerMarketplaceListingMaps({
  required FirebaseFirestore firestore,
  required String ownerUserId,
  int limit = 50,
}) async {
  if (ownerUserId.isEmpty) return const [];

  final snap = await firestore
      .collection('marketplace_listings')
      .where('ownerUserId', isEqualTo: ownerUserId)
      .where('status', isEqualTo: 'active')
      .limit(limit)
      .get();

  return snap.docs.map((doc) {
    final data = doc.data();
    DateTime? createdAt;
    final raw = data['createdAt'];
    if (raw is Timestamp) {
      createdAt = raw.toDate();
    } else if (raw is DateTime) {
      createdAt = raw;
    }
    return {
      'id': doc.id,
      ...data,
      if (createdAt != null) 'createdAt': createdAt,
      'categoryPath': PostSchemaAdapter.leafCategoryId(
        data['categoryId']?.toString() ?? '',
      ),
    };
  }).toList();
}
