import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raabta/features/home/domain/home_truth_engine_reveal_controller.dart';
import 'package:raabta/features/home/domain/truth_chip_status.dart';
import 'package:raabta/features/home/providers/truth_chip_status_providers.dart';

/// Whether Truth Engine sensitive chip details are temporarily revealed on Home.
final homeTruthEngineDetailsRevealedProvider =
    StateProvider<bool>((ref) => false);

final homeTruthEngineRevealControllerProvider =
    Provider<HomeTruthEngineRevealController>((ref) {
  late final HomeTruthEngineRevealController controller;
  controller = HomeTruthEngineRevealController(
    onRevealedChanged: () {
      ref.read(homeTruthEngineDetailsRevealedProvider.notifier).state =
          controller.isRevealed;
    },
  );
  ref.onDispose(controller.dispose);
  return controller;
});

/// Attention badge count — urgent + attention chips (not stale-only).
final homeTruthEngineAttentionCountProvider = Provider<int>((ref) {
  var count = 0;
  for (final engine in TruthChipEngine.values) {
    final status = ref.watch(truthChipWatchStatusProvider(engine));
    if (status.countsTowardAttentionBadge) count++;
  }
  return count;
});
