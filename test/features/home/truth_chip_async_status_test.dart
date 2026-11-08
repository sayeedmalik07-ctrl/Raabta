import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:raabta/features/home/domain/truth_chip_status.dart';
import 'package:raabta/features/home/l10n/home_truth_chip_ui_strings.dart';
import 'package:raabta/features/home/l10n/truth_chip_eosb_strings.dart';
import 'package:raabta/features/home/providers/home_truth_engine_reveal_provider.dart';
import 'package:raabta/features/home/providers/truth_chip_status_providers.dart';
import 'package:raabta/features/home/providers/truth_home_priority_provider.dart';
import 'package:raabta/features/home/domain/truth_home_priority.dart';
import 'package:raabta/providers/visa_providers.dart';

TruthChipStatus _urgent(TruthChipEngine engine) => TruthChipStatus(
      engine: engine,
      state: TruthChipState.urgent,
      tone: TruthChipTone.red,
      titleKey: 'k',
      statusText: 'Act now',
      freshnessText: '',
      deepLink: engine.homeRoute,
    );

TruthChipStatus _invite(TruthChipEngine engine) => TruthChipStatus(
      engine: engine,
      state: TruthChipState.invite,
      tone: TruthChipTone.neutral,
      titleKey: 'k',
      statusText: TruthChipEosbStrings.t('truth_chip_eosb_invite', 'English'),
      freshnessText: '',
      deepLink: engine.homeRoute,
    );

void main() {
  group('mapTruthChipAsyncStatus', () {
    test('loading uses skeleton factory', () {
      final status = mapTruthChipAsyncStatus(
        async: const AsyncLoading(),
        engine: TruthChipEngine.eosb,
        locale: 'English',
      );
      expect(status.isLoading, isTrue);
      expect(status.isInvite, isFalse);
      expect(status.isUnavailable, isFalse);
      expect(status.state, TruthChipState.invite);
    });

    test('error uses unavailable, not invite', () {
      final status = mapTruthChipAsyncStatus(
        async: AsyncError(Exception('fail'), StackTrace.empty),
        engine: TruthChipEngine.tenancy,
        locale: 'English',
      );
      expect(status.isUnavailable, isTrue);
      expect(status.isInvite, isFalse);
      expect(status.isLoading, isFalse);
      expect(
        status.statusText,
        HomeTruthChipUiStrings.t('truth_chip_status_unavailable', 'English'),
      );
    });

    test('data invite from empty saved data is genuine invite', () {
      final invite = _invite(TruthChipEngine.eosb);
      final status = mapTruthChipAsyncStatus(
        async: AsyncData(invite),
        engine: TruthChipEngine.eosb,
        locale: 'English',
      );
      expect(status.isInvite, isTrue);
      expect(status.isUnavailable, isFalse);
    });
  });

  group('truthChipWatchStatusProvider integration', () {
    test('single engine failure is unavailable', () async {
      final container = ProviderContainer(
        overrides: [
          userLanguageProvider.overrideWith((ref) => 'English'),
          truthChipStatusProvider(TruthChipEngine.eosb).overrideWith(
            (ref) async => throw Exception('fail'),
          ),
        ],
      );
      addTearDown(container.dispose);

      await expectLater(
        container.read(truthChipStatusProvider(TruthChipEngine.eosb).future),
        throwsA(isA<Exception>()),
      );
      final status = container.read(truthChipWatchStatusProvider(TruthChipEngine.eosb));
      expect(status.isUnavailable, isTrue);
      expect(status.isInvite, isFalse);
    });

    test('partial failures: priority from healthy engines', () async {
      final container = ProviderContainer(
        overrides: [
          userLanguageProvider.overrideWith((ref) => 'English'),
          truthChipStatusProvider(TruthChipEngine.eosb).overrideWith(
            (ref) async => throw Exception('fail'),
          ),
          truthChipStatusProvider(TruthChipEngine.tenancy).overrideWith(
            (ref) async => _urgent(TruthChipEngine.tenancy),
          ),
          for (final engine in [
            TruthChipEngine.sponsorshipTransfer,
            TruthChipEngine.healthInsurance,
          ])
            truthChipStatusProvider(engine).overrideWith(
              (ref) async => _invite(engine),
            ),
        ],
      );
      addTearDown(container.dispose);

      for (final engine in TruthChipEngine.values) {
        if (engine == TruthChipEngine.eosb) {
          await expectLater(
            container.read(truthChipStatusProvider(engine).future),
            throwsA(isA<Exception>()),
          );
        } else {
          await container.read(truthChipStatusProvider(engine).future);
        }
      }

      final priority = container.read(truthHomePriorityProvider);
      expect(priority, isA<TruthHomePriorityReady>());
      expect(
        (priority as TruthHomePriorityReady).status.engine,
        TruthChipEngine.tenancy,
      );
    });

    test('all providers fail yields priority error', () async {
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

    test('loading blocks priority until resolved', () {
      final pending = Completer<TruthChipStatus>();
      final container = ProviderContainer(
        overrides: [
          truthChipStatusProvider(TruthChipEngine.eosb).overrideWith(
            (ref) => pending.future,
          ),
          for (final engine in TruthChipEngine.values)
            if (engine != TruthChipEngine.eosb)
              truthChipStatusProvider(engine).overrideWith(
                (ref) async => _invite(engine),
              ),
        ],
      );
      addTearDown(container.dispose);

      expect(
        container.read(truthHomePriorityProvider),
        isA<TruthHomePriorityLoading>(),
      );
    });

    test('attention count ignores unavailable, counts urgent on data', () async {
      final container = ProviderContainer(
        overrides: [
          userLanguageProvider.overrideWith((ref) => 'English'),
          truthChipStatusProvider(TruthChipEngine.eosb).overrideWith(
            (ref) async => throw Exception('fail'),
          ),
          truthChipStatusProvider(TruthChipEngine.tenancy).overrideWith(
            (ref) async => _urgent(TruthChipEngine.tenancy),
          ),
          truthChipStatusProvider(TruthChipEngine.sponsorshipTransfer)
              .overrideWith(
            (ref) async => _urgent(TruthChipEngine.sponsorshipTransfer),
          ),
          truthChipStatusProvider(TruthChipEngine.healthInsurance).overrideWith(
            (ref) async => _invite(TruthChipEngine.healthInsurance),
          ),
        ],
      );
      addTearDown(container.dispose);

      for (final engine in TruthChipEngine.values) {
        if (engine == TruthChipEngine.eosb) continue;
        await container.read(truthChipStatusProvider(engine).future);
      }
      await expectLater(
        container.read(truthChipStatusProvider(TruthChipEngine.eosb).future),
        throwsA(isA<Exception>()),
      );

      expect(container.read(homeTruthEngineAttentionCountProvider), 2);
    });
  });
}
