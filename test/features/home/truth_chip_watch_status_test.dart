import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:raabta/features/home/domain/truth_chip_status.dart';
import 'package:raabta/features/home/providers/truth_chip_status_providers.dart';
import 'package:raabta/providers/visa_providers.dart';

void main() {
  test('truthChipWatchStatusProvider maps errors to unavailable status', () async {
    final container = ProviderContainer(
      overrides: [
        userLanguageProvider.overrideWith((ref) => 'English'),
        truthChipStatusProvider(TruthChipEngine.eosb).overrideWith(
          (ref) async => throw Exception('guest'),
        ),
      ],
    );
    addTearDown(container.dispose);

    await expectLater(
      container.read(truthChipStatusProvider(TruthChipEngine.eosb).future),
      throwsA(isA<Exception>()),
    );
    final status = container.read(
      truthChipWatchStatusProvider(TruthChipEngine.eosb),
    );
    expect(status.isUnavailable, isTrue);
    expect(status.isInvite, isFalse);
    expect(status.isLoading, isFalse);
    expect(status.statusText, isNotEmpty);
  });
}
