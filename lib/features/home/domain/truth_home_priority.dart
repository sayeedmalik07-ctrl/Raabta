import 'package:flutter/foundation.dart';
import 'package:raabta/features/home/domain/truth_chip_status.dart';

/// Home-level pick among the four Truth Engine chips (does not replace Expat hero).
@immutable
sealed class TruthHomePriority {
  const TruthHomePriority();

  const factory TruthHomePriority.loading() = TruthHomePriorityLoading;
  const factory TruthHomePriority.error() = TruthHomePriorityError;
  const factory TruthHomePriority.none() = TruthHomePriorityNoAction;
  const factory TruthHomePriority.ready(TruthChipStatus status) =
      TruthHomePriorityReady;
}

@immutable
final class TruthHomePriorityLoading extends TruthHomePriority {
  const TruthHomePriorityLoading();
}

@immutable
final class TruthHomePriorityError extends TruthHomePriority {
  const TruthHomePriorityError();
}

@immutable
final class TruthHomePriorityNoAction extends TruthHomePriority {
  const TruthHomePriorityNoAction();
}

@immutable
final class TruthHomePriorityReady extends TruthHomePriority {
  const TruthHomePriorityReady(this.status);

  final TruthChipStatus status;
}

extension TruthHomePriorityAction on TruthChipStatus {
  /// Actionable for Home priority surfacing (not invite / calm tracked).
  bool get isHomePriorityAction =>
      state == TruthChipState.urgent ||
      state == TruthChipState.attention ||
      state == TruthChipState.stale;
}
