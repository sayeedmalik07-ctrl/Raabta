import 'package:flutter_test/flutter_test.dart';
import 'package:raabta/core/l10n/app_locale.dart';
import 'package:raabta/features/eosb/presentation/l10n/eosb_strings.dart';

const _slice2dKeys = [
  'eosb_history_corrupt_empty_title',
  'eosb_history_corrupt_empty_desc',
  'eosb_history_corrupt_banner',
  'eosb_history_corrupt_write_blocked',
  'eosb_history_corrupt_delete_blocked',
  'eosb_history_load_error',
  'eosb_history_load_error_desc',
  'ot_history_corrupt_empty_title',
  'ot_history_corrupt_empty_desc',
  'ot_history_corrupt_banner',
  'ot_history_hydration_failed',
  'ot_history_hydration_failed_desc',
];

void main() {
  group('Slice 2D corrupt history l10n', () {
    test('localeCoverageReport includes new keys', () {
      expect(EosbStrings.localeCoverageReport, isEmpty);
    });

    test('all nine locales have non-English translations', () {
      for (final key in _slice2dKeys) {
        final english = EosbStrings.t(key, 'English');
        expect(english, isNotEmpty);
        expect(english, isNot(equals(key)));

        for (final locale in AppLocale.supportedLocales) {
          if (locale == 'English') continue;
          final localized = EosbStrings.t(key, locale);
          expect(localized, isNotEmpty);
          expect(
            localized,
            isNot(equals(english)),
            reason: '$key should differ from English in $locale',
          );
        }
      }
    });
  });
}
