import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raabta/features/home/domain/truth_chip_status.dart';
import 'package:raabta/features/home/domain/truth_home_priority.dart';
import 'package:raabta/features/home/domain/truth_home_priority_resolver.dart';
import 'package:raabta/features/home/providers/truth_chip_status_providers.dart';

/// Highest-priority Know-your-rights item for supplementary Home surfacing.
final truthHomePriorityProvider = Provider<TruthHomePriority>((ref) {
  final mapped = <TruthChipStatus>[
    for (final engine in TruthChipEngine.values)
      ref.watch(truthChipWatchStatusProvider(engine)),
  ];

  if (mapped.any((s) => s.isLoading)) {
    return const TruthHomePriority.loading();
  }

  final resolved = mapped
      .where((s) => s.state != TruthChipState.unavailable)
      .toList(growable: false);
  final unavailableCount =
      mapped.where((s) => s.state == TruthChipState.unavailable).length;

  if (resolved.isEmpty) {
    if (unavailableCount == TruthChipEngine.values.length) {
      return const TruthHomePriority.error();
    }
    return const TruthHomePriority.error();
  }

  final highest = TruthHomePriorityResolver.pickHighest(resolved);
  if (highest == null || !highest.isHomePriorityAction) {
    return const TruthHomePriority.none();
  }

  return TruthHomePriority.ready(highest);
});
