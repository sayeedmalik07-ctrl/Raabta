/// Deterministic constants for trip readiness checks — no AI, no weighting.
abstract final class TripReadinessConfig {
  /// Qatar entry guidance: passport valid beyond return date by this buffer.
  static const passportValidityBufferMonths = 6;

  /// Deep-link routes for incomplete categories (GoRouter paths).
  static const routeDocumentVault = '/document-vault';
  static const routeDeadlineTracker = '/visa';
  static const routeBookingImport = '/trip-planner/import-booking';
  static const routeEmergency = '/trip-planner/emergency';
}
