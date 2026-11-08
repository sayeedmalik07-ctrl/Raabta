import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

/// Lightweight listing lifecycle event log — top-level `listingEvents` collection.
///
/// Pattern mirrors [ReferralAnalyticsService] (debug + Firestore append) but uses
/// a dedicated collection scoped to listings rather than user analytics_events.
abstract final class ListingEventsService {
  static const collection = 'listingEvents';

  static const listingCreated = 'listing_created';
  static const listingPublished = 'listing_published';
  static const listingViewed = 'listing_viewed';
  static const listingSaved = 'listing_saved';
  static const listingContacted = 'listing_contacted';
  static const listingSold = 'listing_sold';
  static const listingRented = 'listing_rented';
  static const listingFilled = 'listing_filled';
  static const listingExpired = 'listing_expired';

  /// Vertical-appropriate completion event for mark-as-done actions.
  static String completionEventForVertical(String verticalId) {
    return switch (verticalId) {
      'housing' => listingRented,
      'jobs' => listingFilled,
      _ => listingSold,
    };
  }

  static Future<void> record({
    required String eventType,
    required String listingId,
    required String verticalId,
    String? userId,
  }) async {
    debugPrint(
      '[ListingEvents] $eventType listing=$listingId vertical=$verticalId user=${userId ?? '-'}',
    );
    try {
      await FirebaseFirestore.instance.collection(collection).add({
        'eventType': eventType,
        'listingId': listingId,
        'verticalId': verticalId,
        if (userId != null && userId.isNotEmpty) 'userId': userId,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('[ListingEvents] persist failed: $e');
    }
  }

  static Future<void> recordCreatedAndPublished({
    required String listingId,
    required String verticalId,
    String? userId,
  }) async {
    await record(
      eventType: listingCreated,
      listingId: listingId,
      verticalId: verticalId,
      userId: userId,
    );
    await record(
      eventType: listingPublished,
      listingId: listingId,
      verticalId: verticalId,
      userId: userId,
    );
  }
}
