import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raabta/features/home/domain/truth_chip_status.dart';
import 'package:raabta/features/home/providers/home_truth_engine_reveal_provider.dart';
import 'package:raabta/features/home/providers/truth_chip_status_providers.dart';
import 'package:raabta/providers/visa_providers.dart';

TruthChipStatus _attentionStatus(TruthChipEngine engine) => TruthChipStatus(
      engine: engine,
      state: TruthChipState.attention,
      tone: TruthChipTone.amber,
      titleKey: 'k',
      statusText: 'needs attention',
      pillText: '3d',
      freshnessText: 'fresh',
      deepLink: engine.homeRoute,
    );

TruthChipStatus _trackedStatus(TruthChipEngine engine) => TruthChipStatus(
      engine: engine,
      state: TruthChipState.tracked,
      tone: TruthChipTone.ok,
      titleKey: 'k',
      statusText: 'ok',
      freshnessText: 'fresh',
      deepLink: engine.homeRoute,
    );

void main() {
  group('homeTruthEngineAttentionCountProvider', () {
    test('counts urgent and attention only', () async {
      final container = ProviderContainer(
        overrides: [
          userLanguageProvider.overrideWith((ref) => 'English'),
          truthChipStatusProvider(TruthChipEngine.eosb)
              .overrideWith((ref) async => _attentionStatus(TruthChipEngine.eosb)),
          truthChipStatusProvider(TruthChipEngine.sponsorshipTransfer)
              .overrideWith(
            (ref) async => _trackedStatus(TruthChipEngine.sponsorshipTransfer),
          ),
          truthChipStatusProvider(TruthChipEngine.tenancy).overrideWith(
            (ref) async => const TruthChipStatus(
              engine: TruthChipEngine.tenancy,
              state: TruthChipState.urgent,
              tone: TruthChipTone.red,
              titleKey: 'k',
              statusText: 'act',
              freshnessText: '',
              deepLink: '/tenancy',
            ),
          ),
          truthChipStatusProvider(TruthChipEngine.healthInsurance)
              .overrideWith(
            (ref) async => _trackedStatus(TruthChipEngine.healthInsurance),
          ),
        ],
      );
      addTearDown(container.dispose);

      for (final engine in TruthChipEngine.values) {
        await container.read(truthChipStatusProvider(engine).future);
      }
      expect(container.read(homeTruthEngineAttentionCountProvider), 2);
    });

    test('stale alone does not count', () async {
      final container = ProviderContainer(
        overrides: [
          userLanguageProvider.overrideWith((ref) => 'English'),
          for (final engine in TruthChipEngine.values)
            truthChipStatusProvider(engine).overrideWith(
              (ref) async => TruthChipStatus(
                engine: engine,
                state: TruthChipState.stale,
                tone: TruthChipTone.neutral,
                titleKey: 'k',
                statusText: 'stale',
                freshnessText: '',
                deepLink: engine.homeRoute,
              ),
            ),
        ],
      );
      addTearDown(container.dispose);

      for (final engine in TruthChipEngine.values) {
        await container.read(truthChipStatusProvider(engine).future);
      }
      expect(container.read(homeTruthEngineAttentionCountProvider), 0);
    });
  });
}
