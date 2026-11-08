/// Read-only pending-action row for the Profile My Activity screen.
enum MyActivityVertical {
  marketplace,
  housing,
  services,
  jobs,
  business,
}

class MyActivityItem {
  const MyActivityItem({
    required this.vertical,
    required this.title,
    required this.statusLabel,
    required this.route,
    required this.sortTime,
    this.subtitle,
    this.sourceId,
  });

  final MyActivityVertical vertical;
  final String title;
  final String? subtitle;
  final String statusLabel;
  final String route;
  final DateTime sortTime;

  /// Stable identity from the source record (e.g. viewing request doc id).
  final String? sourceId;
}

abstract final class MyActivityFilters {
  static bool marketplaceOfferNeedsAttention(
    String uid, {
    required String sellerId,
    required String buyerId,
    required String status,
    required bool isExpired,
  }) {
    if (isExpired) return false;
    if (sellerId == uid && status == 'pending') return true;
    if (buyerId == uid && status == 'awaiting_buyer') return true;
    return false;
  }

  static bool housingViewingNeedsAttention(
    String uid, {
    required String ownerId,
    required String viewerId,
    required String status,
    required bool isExpired,
  }) {
    if (isExpired) return false;
    if (ownerId == uid && status == 'pending') return true;
    if (viewerId == uid && status == 'awaiting_viewer') return true;
    return false;
  }

  static bool businessAppointmentNeedsAttention(
    String uid, {
    required String ownerId,
    required String requesterId,
    required String status,
    required bool isExpired,
  }) {
    if (isExpired) return false;
    if (ownerId == uid && status == 'pending') return true;
    if (requesterId == uid && status == 'awaiting_requester') return true;
    return false;
  }

  static bool businessQuoteNeedsAttention(
    String uid, {
    required String ownerId,
    required String requesterId,
    required String status,
    required bool isExpired,
  }) {
    if (isExpired) return false;
    if (ownerId == uid && status == 'pending') return true;
    if (requesterId == uid && status == 'quoted') return true;
    return false;
  }

  static bool jobApplicationNeedsAttention(
    String uid, {
    required String applicantUid,
    required String status,
    required String? jobPosterUid,
  }) {
    if (applicantUid == uid) {
      return status == 'under_review' || status == 'contacted';
    }
    if (jobPosterUid == uid && applicantUid != uid) {
      return status == 'applied';
    }
    return false;
  }
}
