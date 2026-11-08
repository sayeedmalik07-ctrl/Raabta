/// Versioned thresholds for deterministic transaction anomaly detection.
abstract final class ScamTransactionThresholdsConfig {
  static const version = 1;
  static const largeTransferQar = 10000.0;
  static const multipleChargeMinCount = 2;
}
