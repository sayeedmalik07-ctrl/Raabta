import 'package:raabta/features/sponsorship_transfer/domain/models/transfer_readiness_input.dart';
import 'package:raabta/features/sponsorship_transfer/domain/models/transfer_readiness_models.dart';

/// A what-if transfer readiness scenario for comparison.
class TransferScenario {
  const TransferScenario({
    required this.id,
    required this.titleKey,
    required this.descriptionKey,
    required this.input,
    required this.result,
    required this.differenceFromBase,
    required this.differenceSummaryKey,
  });

  final String id;
  final String titleKey;
  final String descriptionKey;
  final TransferReadinessInput input;
  final TransferReadinessResult result;
  /// Positive = worse than base case (higher severity).
  final int differenceFromBase;
  final String differenceSummaryKey;
}
