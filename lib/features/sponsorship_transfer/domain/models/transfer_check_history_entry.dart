import 'package:raabta/features/sponsorship_transfer/domain/models/transfer_readiness_input.dart';
import 'package:raabta/features/sponsorship_transfer/domain/models/transfer_readiness_models.dart';

/// A past transfer readiness check loaded from Firestore.
class TransferCheckHistoryEntry {
  const TransferCheckHistoryEntry({
    required this.id,
    required this.checkedAt,
    required this.input,
    required this.result,
  });

  final String id;
  final DateTime checkedAt;
  final TransferReadinessInput input;
  final TransferReadinessResult result;
}
