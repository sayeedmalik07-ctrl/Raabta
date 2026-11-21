import 'package:flutter_test/flutter_test.dart';
import 'package:raabta/features/home/domain/home_chip_status.dart';
import 'package:raabta/features/home/domain/home_truth_chip_legacy_adapter.dart';
import 'package:raabta/features/home/domain/truth_chip_status.dart';
import 'package:raabta/features/home/l10n/home_chip_status_strings.dart';

void main() {
  group('HomeTruthChipLegacyAdapter', () {
    test('maps eosb empty invite', () {
      final legacy = HomeChipStatus.ready(
        line: HomeChipStatusStrings.t('home_chip_eosb_empty', 'English'),
      );
      final status = HomeTruthChipLegacyAdapter.fromHomeChip(
        route: '/eosb',
        locale: 'English',
        legacy: legacy,
      )!;
      expect(status.isInvite, isTrue);
      expect(status.engine, TruthChipEngine.eosb);
    });

    test('maps eosb saved as tracked', () {
      final line = HomeChipStatusStrings.t('home_chip_eosb_saved', 'English');
      final status = HomeTruthChipLegacyAdapter.fromHomeChip(
        route: '/eosb',
        locale: 'English',
        legacy: HomeChipStatus.ready(line: line),
      )!;
      expect(status.state, TruthChipState.tracked);
      expect(status.statusText, line);
      expect(status.tone, TruthChipTone.ok);
    });

    test('returns null for non-truth route', () {
      expect(
        HomeTruthChipLegacyAdapter.fromHomeChip(
          route: '/trip-planner',
          locale: 'English',
          legacy: const HomeChipStatus.ready(line: 'x'),
        ),
        isNull,
      );
    });
  });
}
