/// How money was sent on a Qatar → home-country corridor.
enum CorridorTransferMethod {
  bank('bank', 'Bank transfer', '🏦'),
  mobileWallet('mobile_wallet', 'Mobile wallet', '📱'),
  cashPickup('cash_pickup', 'Cash pickup', '💵');

  const CorridorTransferMethod(this.value, this.label, this.emoji);

  final String value;
  final String label;
  final String emoji;

  static CorridorTransferMethod fromValue(String? raw) {
    return CorridorTransferMethod.values.firstWhere(
      (m) => m.value == raw,
      orElse: () => CorridorTransferMethod.bank,
    );
  }
}
