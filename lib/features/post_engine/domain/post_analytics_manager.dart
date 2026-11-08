import 'package:firebase_auth/firebase_auth.dart';
import 'package:raabta/features/post_engine/data/listing_events_service.dart';

/// Post funnel analytics — writes lightweight events to [ListingEventsService].
class PostAnalyticsManager {
  const PostAnalyticsManager();

  void trackSchemaLoaded(String verticalId, {required bool fromCache}) {}

  void trackFieldError(String verticalId, String fieldId) {}

  void trackPublishAttempt(String verticalId, {required bool success}) {}

  void trackPublish({
    required String verticalId,
    required String categoryPath,
    required String listingId,
    String? userId,
  }) {
    trackPublishAttempt(verticalId, success: true);
    final uid = userId ?? FirebaseAuth.instance.currentUser?.uid;
    ListingEventsService.recordCreatedAndPublished(
      listingId: listingId,
      verticalId: verticalId,
      userId: uid,
    );
  }

  void trackView({
    required String listingId,
    required String verticalId,
    String? userId,
  }) {
    ListingEventsService.record(
      eventType: ListingEventsService.listingViewed,
      listingId: listingId,
      verticalId: verticalId,
      userId: userId ?? FirebaseAuth.instance.currentUser?.uid,
    );
  }

  void trackSave({
    required String listingId,
    required String verticalId,
    String? userId,
  }) {
    ListingEventsService.record(
      eventType: ListingEventsService.listingSaved,
      listingId: listingId,
      verticalId: verticalId,
      userId: userId ?? FirebaseAuth.instance.currentUser?.uid,
    );
  }

  void trackEnquiry({
    required String listingId,
    required String verticalId,
    String? userId,
  }) {
    ListingEventsService.record(
      eventType: ListingEventsService.listingContacted,
      listingId: listingId,
      verticalId: verticalId,
      userId: userId ?? FirebaseAuth.instance.currentUser?.uid,
    );
  }

  void trackCompletion({
    required String listingId,
    required String verticalId,
    String? userId,
  }) {
    ListingEventsService.record(
      eventType: ListingEventsService.completionEventForVertical(verticalId),
      listingId: listingId,
      verticalId: verticalId,
      userId: userId ?? FirebaseAuth.instance.currentUser?.uid,
    );
  }

  void trackExpired({
    required String listingId,
    required String verticalId,
    String? userId,
  }) {
    ListingEventsService.record(
      eventType: ListingEventsService.listingExpired,
      listingId: listingId,
      verticalId: verticalId,
      userId: userId ?? FirebaseAuth.instance.currentUser?.uid,
    );
  }
}
