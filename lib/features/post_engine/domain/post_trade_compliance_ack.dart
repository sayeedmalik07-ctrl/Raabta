/// Listing-level trade compliance acknowledgment (Decision 25 Part D).
abstract final class PostTradeComplianceAck {
  static const fieldAckAt = 'listingTradeComplianceAckAt';
  static const fieldAckVersion = 'listingTradeComplianceAckVersion';
  static const currentVersion = 1;

  static Map<String, dynamic> fields() => {
        fieldAckAt: DateTime.now().toUtc().toIso8601String(),
        fieldAckVersion: currentVersion,
      };
}
