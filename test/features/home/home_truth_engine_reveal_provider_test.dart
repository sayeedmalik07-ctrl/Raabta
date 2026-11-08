import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raabta/features/home/providers/home_truth_engine_reveal_provider.dart';

void main() {
  test('details revealed provider defaults to hidden', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    expect(container.read(homeTruthEngineDetailsRevealedProvider), isFalse);
    expect(container.read(homeTruthEngineAttentionCountProvider), 0);
  });
}
