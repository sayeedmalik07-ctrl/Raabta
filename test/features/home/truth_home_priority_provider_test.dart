import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:raabta/features/home/domain/truth_chip_status.dart';
import 'package:raabta/features/home/domain/truth_home_priority.dart';
import 'package:raabta/features/home/providers/truth_chip_status_providers.dart';
import 'package:raabta/features/home/providers/truth_home_priority_provider.dart';
import 'package:raabta/providers/visa_providers.dart';

TruthChipStatus _trackedStatus(TruthChipEngine engine) => TruthChipStatus(
      engine: engine,
      state: TruthChipState.tracked,
      tone: TruthChipTone.ok,
      titleKey: 'k',
      statusText: 'On track',
      freshnessText: '',
      deepLink: engine.homeRoute,
    );

TruthChipStatus _urgentStatus(TruthChipEngine engine) => TruthChipStatus(
      engine: engine,
      state: TruthChipState.urgent,
      tone: TruthChipTone.red,
      titleKey: 'k',
      statusText: 'Act now',
      freshnessText: '',
      deepLink: engine.homeRoute,
    );

void main() {
  group('truthHomePriorityProvider', () {
    test('loading when any chip is loading', () {
      final pending = Completer<TruthChipStatus>();
      final container = ProviderContainer(
        overrides: [
          userLanguageProvider.overrideWith((ref) => 'English'),
          truthChipStatusProvider(TruthChipEngine.eosb).overrideWith(
            (ref) async => _urgentStatus(TruthChipEngine.eosb),
          ),
          truthChipStatusProvider(TruthChipEngine.sponsorshipTransfer)
              .overrideWith((ref) => pending.future),
          for (final engine in [
            TruthChipEngine.tenancy,
            TruthChipEngine.healthInsurance,
          ])
            truthChipStatusProvider(engine).overrideWith(
              (ref) async => _trackedStatus(engine),
            ),
        ],
      );
      addTearDown(container.dispose);

      expect(
        container.read(truthHomePriorityProvider),
        isA<TruthHomePriorityLoading>(),
      );
    });

    test('error when all chips fail', () async {
      final container = ProviderContainer(
        overrides: [
          userLanguageProvider.overrideWith((ref) => 'English'),
          for (final engine in TruthChipEngine.values)
            truthChipStatusProvider(engine).overrideWith(
              (ref) async => throw Exception('fail'),
            ),
        ],
      );
      addTearDown(container.dispose);

      for (final engine in TruthChipEngine.values) {
        await expectLater(
          container.read(truthChipStatusProvider(engine).future),
          throwsA(isA<Exception>()),
        );
      }
      expect(
        container.read(truthHomePriorityProvider),
        isA<TruthHomePriorityError>(),
      );
    });

    test('no-action when only tracked/invite', () async {
      final container = ProviderContainer(
        overrides: [
          userLanguageProvider.overrideWith((ref) => 'English'),
          for (final engine in TruthChipEngine.values)
            truthChipStatusProvider(engine).overrideWith(
              (ref) async => _trackedStatus(engine),
            ),
        ],
      );
      addTearDown(container.dispose);

      for (final engine in TruthChipEngine.values) {
        await container.read(truthChipStatusProvider(engine).future);
      }
      expect(
        container.read(truthHomePriorityProvider),
        isA<TruthHomePriorityNoAction>(),
      );
    });

    test('ready selects highest urgent', () async {
      final container = ProviderContainer(
        overrides: [
          userLanguageProvider.overrideWith((ref) => 'English'),
          truthChipStatusProvider(TruthChipEngine.eosb).overrideWith(
            (ref) async => _trackedStatus(TruthChipEngine.eosb),
          ),
          truthChipStatusProvider(TruthChipEngine.sponsorshipTransfer)
              .overrideWith(
            (ref) async =>
                _trackedStatus(TruthChipEngine.sponsorshipTransfer),
          ),
          truthChipStatusProvider(TruthChipEngine.tenancy).overrideWith(
            (ref) async => _urgentStatus(TruthChipEngine.tenancy),
          ),
          truthChipStatusProvider(TruthChipEngine.healthInsurance).overrideWith(
            (ref) async => _trackedStatus(TruthChipEngine.healthInsurance),
          ),
        ],
      );
      addTearDown(container.dispose);

      for (final engine in TruthChipEngine.values) {
        await container.read(truthChipStatusProvider(engine).future);
      }
      final priority = container.read(truthHomePriorityProvider);
      expect(priority, isA<TruthHomePriorityReady>());
      expect(
        (priority as TruthHomePriorityReady).status.engine,
        TruthChipEngine.tenancy,
      );
    });
  });
}
