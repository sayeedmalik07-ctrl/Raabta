enum ScamTransactionAnomalyKind {
  amountMentioned,
  largeTransfer,
  multipleCharges,
  unauthorizedLanguage,
}

extension ScamTransactionAnomalyKindX on ScamTransactionAnomalyKind {
  String get labelKey => 'ss_tx_anomaly_${name.replaceAllMapped(
        RegExp(r'[A-Z]'),
        (m) => '_${m.group(0)!.toLowerCase()}',
      )}';
}

class ScamTransactionAnomaly {
  const ScamTransactionAnomaly({
    required this.kind,
    this.amountQar,
    this.snippet,
  });

  final ScamTransactionAnomalyKind kind;
  final double? amountQar;
  final String? snippet;
}

class ScamTransactionAnomalyResult {
  const ScamTransactionAnomalyResult({
    required this.anomalies,
    required this.totalMentionedQar,
  });

  static const empty = ScamTransactionAnomalyResult(
    anomalies: [],
    totalMentionedQar: 0,
  );

  final List<ScamTransactionAnomaly> anomalies;
  final double totalMentionedQar;

  bool get hasAnomalies => anomalies.isNotEmpty;

  bool get isHighConcern =>
      anomalies.any((a) => a.kind == ScamTransactionAnomalyKind.unauthorizedLanguage) ||
      anomalies.any((a) => a.kind == ScamTransactionAnomalyKind.largeTransfer);
}
