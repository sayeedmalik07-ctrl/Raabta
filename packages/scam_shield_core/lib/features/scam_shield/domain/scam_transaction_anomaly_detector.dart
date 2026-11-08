import 'package:scam_shield_core/features/scam_shield/data/scam_multilingual_dictionary_config.dart';
import 'package:scam_shield_core/features/scam_shield/data/scam_transaction_thresholds_config.dart';
import 'package:scam_shield_core/features/scam_shield/domain/scam_multilingual_matcher.dart';
import 'package:scam_shield_core/features/scam_shield/domain/scam_transaction_anomaly_models.dart';

/// Deterministic transaction pattern detection from pasted text — no AI, no bank API.
abstract final class ScamTransactionAnomalyDetector {
  static final _amountPattern = RegExp(
    r'(?:QAR|QR|ريال|qar)\s*([0-9]{1,3}(?:,[0-9]{3})*(?:\.[0-9]{1,2})?|[0-9]+(?:\.[0-9]{1,2})?)',
    caseSensitive: false,
  );

  static final _unauthorizedPatterns =
      ScamMultilingualDictionaryConfig.unauthorizedTransactionPatterns;

  static ScamTransactionAnomalyResult analyze(String text) {
    final amounts = _extractAmounts(text);
    if (amounts.isEmpty && !_hasUnauthorizedLanguage(text)) {
      return ScamTransactionAnomalyResult.empty;
    }

    final anomalies = <ScamTransactionAnomaly>[];
    var total = 0.0;

    for (final amount in amounts) {
      total += amount;
      anomalies.add(
        ScamTransactionAnomaly(
          kind: ScamTransactionAnomalyKind.amountMentioned,
          amountQar: amount,
        ),
      );
      if (amount >= ScamTransactionThresholdsConfig.largeTransferQar) {
        anomalies.add(
          ScamTransactionAnomaly(
            kind: ScamTransactionAnomalyKind.largeTransfer,
            amountQar: amount,
          ),
        );
      }
    }

    if (amounts.length >= ScamTransactionThresholdsConfig.multipleChargeMinCount) {
      anomalies.add(
        const ScamTransactionAnomaly(
          kind: ScamTransactionAnomalyKind.multipleCharges,
        ),
      );
    }

    if (_hasUnauthorizedLanguage(text)) {
      anomalies.add(
        ScamTransactionAnomaly(
          kind: ScamTransactionAnomalyKind.unauthorizedLanguage,
          amountQar: amounts.isEmpty ? null : amounts.first,
        ),
      );
    }

    return ScamTransactionAnomalyResult(
      anomalies: anomalies,
      totalMentionedQar: total,
    );
  }

  static List<double> _extractAmounts(String text) {
    final amounts = <double>[];
    for (final match in _amountPattern.allMatches(text)) {
      final raw = match.group(1)?.replaceAll(',', '') ?? '';
      final value = double.tryParse(raw);
      if (value != null && value > 0) {
        amounts.add(value);
      }
    }
    return amounts;
  }

  static bool _hasUnauthorizedLanguage(String text) {
    return _unauthorizedPatterns.any(
      (p) => ScamMultilingualMatcher.containsPattern(text, p),
    );
  }
}
