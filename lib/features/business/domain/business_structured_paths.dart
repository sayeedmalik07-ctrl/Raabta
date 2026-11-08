/// Firestore paths for Business structured actions (locks + meta).
abstract final class BusinessStructuredPaths {
  BusinessStructuredPaths._();

  static const appointmentLocksCollection = 'appointment_locks';
  static const quoteLocksCollection = 'quote_locks';
  static const metaCollection = 'internal';
  static const metaDocId = 'structured_meta';
}
