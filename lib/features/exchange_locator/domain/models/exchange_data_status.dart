/// Directory data completeness — drives honest UI labels (no inflated branch counts).
enum ExchangeDataStatus {
  verified('verified', 'Verified listing'),
  partial('partial', 'Partial listing'),
  pendingVerification('pending_verification', 'Details being confirmed');

  const ExchangeDataStatus(this.value, this.label);

  final String value;
  final String label;

  static ExchangeDataStatus fromValue(String? raw) {
    return ExchangeDataStatus.values.firstWhere(
      (s) => s.value == raw,
      orElse: () => ExchangeDataStatus.verified,
    );
  }
}

/// How precisely branch coordinates were resolved at seed time.
enum ExchangeGeocodePrecision {
  exact('exact'),
  landmark('landmark'),
  area('area');

  const ExchangeGeocodePrecision(this.value);

  final String value;

  static ExchangeGeocodePrecision? fromValue(String? raw) {
    if (raw == null || raw.isEmpty) return null;
    return ExchangeGeocodePrecision.values.firstWhere(
      (s) => s.value == raw,
      orElse: () => ExchangeGeocodePrecision.area,
    );
  }
}
