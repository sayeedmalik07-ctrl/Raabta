import 'package:raabta/features/home/domain/truth_chip_status.dart';
import 'package:raabta/features/home/domain/truth_home_priority.dart';

/// Picks the single highest-priority Truth chip from mapper outputs.
abstract final class TruthHomePriorityResolver {
  TruthHomePriorityResolver._();

  /// Engine enum order — deterministic tie-break (EOSB → ST → Tenancy → HI).
  static const engineOrder = TruthChipEngine.values;

  static TruthChipStatus? pickHighest(Iterable<TruthChipStatus> statuses) {
    TruthChipStatus? best;
    for (final status in statuses) {
      if (status.isLoading || status.state == TruthChipState.unavailable) {
        continue;
      }
      if (best == null) {
        best = status;
        continue;
      }
      if (_compare(status, best) < 0) {
        best = status;
      }
    }
    return best;
  }

  /// Lower sort key = higher priority.
  static int _compare(TruthChipStatus a, TruthChipStatus b) {
    final stateCmp = _stateRank(a.state).compareTo(_stateRank(b.state));
    if (stateCmp != 0) return stateCmp;
    final toneCmp = _toneRank(a.tone).compareTo(_toneRank(b.tone));
    if (toneCmp != 0) return toneCmp;
    return a.engine.index.compareTo(b.engine.index);
  }

  static int _stateRank(TruthChipState state) => switch (state) {
        TruthChipState.urgent => 0,
        TruthChipState.attention => 1,
        TruthChipState.stale => 2,
        TruthChipState.tracked => 3,
        TruthChipState.invite => 4,
        TruthChipState.unavailable => 5,
      };

  static int _toneRank(TruthChipTone tone) => switch (tone) {
        TruthChipTone.red => 0,
        TruthChipTone.amber => 1,
        TruthChipTone.ok => 2,
        TruthChipTone.neutral => 3,
      };

  /// True when [chip] repeats the same primary line as [priority] on Home.
  static bool shouldSuppressChipStatusLine({
    required TruthChipStatus chip,
    required TruthHomePriority priority,
  }) {
    if (priority is! TruthHomePriorityReady) return false;
    final selected = priority.status;
    if (selected.engine != chip.engine) return false;
    return _normalized(selected.statusText) == _normalized(chip.statusText) &&
        _normalized(chip.statusText).isNotEmpty;
  }

  static String _normalized(String text) => text.trim().toLowerCase();

  /// Chip card copy — omits duplicated primary line when shown on the banner.
  static TruthChipStatus forChipDisplay({
    required TruthChipStatus chip,
    required TruthHomePriority priority,
  }) {
    if (!shouldSuppressChipStatusLine(chip: chip, priority: priority)) {
      return chip;
    }
    return TruthChipStatus(
      engine: chip.engine,
      state: chip.state,
      tone: chip.tone,
      titleKey: chip.titleKey,
      statusText: '',
      revealedText: chip.revealedText,
      pillText: chip.pillText,
      progress: chip.progress,
      freshnessText: chip.freshnessText,
      deepLink: chip.deepLink,
      isLoading: chip.isLoading,
    );
  }
}
