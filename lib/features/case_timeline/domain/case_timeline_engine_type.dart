/// Truth Engine identifier — each engine keeps an independent timeline.
enum CaseTimelineEngineType {
  eosb,
  healthInsurance,
  tenancy,
  sponsorshipTransfer,
}

extension CaseTimelineEngineTypeX on CaseTimelineEngineType {
  String get storageValue => switch (this) {
        CaseTimelineEngineType.eosb => 'eosb',
        CaseTimelineEngineType.healthInsurance => 'healthInsurance',
        CaseTimelineEngineType.tenancy => 'tenancy',
        CaseTimelineEngineType.sponsorshipTransfer => 'sponsorshipTransfer',
      };

  static CaseTimelineEngineType? fromStorage(String? raw) {
    return switch (raw) {
      'eosb' => CaseTimelineEngineType.eosb,
      'healthInsurance' => CaseTimelineEngineType.healthInsurance,
      'tenancy' => CaseTimelineEngineType.tenancy,
      'sponsorshipTransfer' => CaseTimelineEngineType.sponsorshipTransfer,
      _ => null,
    };
  }
}
