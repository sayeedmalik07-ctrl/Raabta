/// Deterministic red-flag tally for investment check — nothing persisted.
abstract final class InvestmentRedFlagTally {
  static const tallyKeys = [
    'guaranteed',
    'pressure',
    'personal_crypto',
    'whatsapp_telegram',
    'withdraw_fee',
  ];

  static bool showSummary(Set<String> selected) => selected.length >= 2;
}
