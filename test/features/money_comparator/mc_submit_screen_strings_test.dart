import 'package:flutter_test/flutter_test.dart';
import 'package:raabta/core/l10n/app_locale.dart';
import 'package:raabta/features/money_comparator/presentation/l10n/money_comparator_strings.dart';

void main() {
  group('Submit transfer screen MoneyComparatorStrings', () {
    const keys = [
      'mc_submit_subtitle',
      'mc_submit_error_generic',
      'mc_submit_hero_body',
      'mc_submit_section_destination',
      'mc_submit_section_transfer_details',
      'mc_submit_section_timing',
      'mc_submit_validation_hint',
    ];

    test('non-empty for all nine locales', () {
      for (final key in keys) {
        for (final locale in AppLocale.supportedLocales) {
          expect(
            MoneyComparatorStrings.t(key, locale),
            isNotEmpty,
            reason: '$key / $locale',
          );
        }
      }
    });

    test('non-English locales do not fall back to English', () {
      for (final key in keys) {
        final english = MoneyComparatorStrings.t(key, 'English');
        for (final locale in AppLocale.supportedLocales) {
          if (locale == 'English') continue;
          expect(
            MoneyComparatorStrings.t(key, locale),
            isNot(equals(english)),
            reason: '$key / $locale',
          );
        }
      }
    });
  });
}
