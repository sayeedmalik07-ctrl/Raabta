import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raabta/features/eosb/providers/eosb_providers.dart';
import 'package:raabta/features/home/providers/home_truth_chip_invalidation.dart';
import 'package:raabta/features/home/domain/truth_chip_status.dart';
import 'package:raabta/features/home/providers/truth_chip_status_providers.dart';

void main() {
  test('invalidateHomeTruthChips marks truth and eosb history stale', () {
    var truthFetches = 0;
    var historyFetches = 0;

    final container = ProviderContainer(
      overrides: [
        eosbHistoryProvider.overrideWith((ref) async {
          historyFetches++;
          return [];
        }),
        truthChipStatusProvider(TruthChipEngine.eosb).overrideWith((ref) async {
          truthFetches++;
          await ref.watch(eosbHistoryProvider.future);
          return TruthChipStatus.loading(
            engine: TruthChipEngine.eosb,
            titleKey: 'tool_eosb_title',
            deepLink: '/eosb',
          );
        }),
      ],
    );
    addTearDown(container.dispose);

    container.read(truthChipStatusProvider(TruthChipEngine.eosb));
    container.read(eosbHistoryProvider);
    expect(truthFetches, 1);
    expect(historyFetches, 1);

    invalidateHomeTruthChips(container);

    container.read(truthChipStatusProvider(TruthChipEngine.eosb));
    container.read(eosbHistoryProvider);
    expect(truthFetches, 2);
    expect(historyFetches, 2);
  });
}
