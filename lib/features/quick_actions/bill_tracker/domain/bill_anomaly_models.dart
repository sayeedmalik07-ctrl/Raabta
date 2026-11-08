/// A bill whose amount is unusually high vs the user's recent history for that provider.
class BillAnomaly {
  const BillAnomaly({
    required this.billId,
    required this.provider,
    required this.displayProvider,
    required this.currentAmount,
    required this.averageAmount,
    required this.percentAboveAverage,
    required this.baselineBillCount,
    required this.currency,
  });

  final String billId;
  final String provider;
  final String displayProvider;
  final double currentAmount;
  final double averageAmount;
  final double percentAboveAverage;
  final int baselineBillCount;
  final String currency;

  int get roundedPercentAbove => percentAboveAverage.round();
}
