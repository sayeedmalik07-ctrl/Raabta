import 'package:flutter_test/flutter_test.dart';
import 'package:raabta/core/l10n/app_locale.dart';
import 'package:raabta/features/home/l10n/home_currency_rail_strings.dart';

void main() {
  group('HomeCurrencyRailStrings home_currency_rail_rate', () {
    const key = 'home_currency_rail_rate';

    test('all supported locales have explicit non-English templates (no English fallback)',
        () {
      final englishTemplate = HomeCurrencyRailStrings.t(key, 'English');
      expect(englishTemplate, isNotEmpty);

      for (final locale in AppLocale.supportedLocales) {
        if (locale == 'English') continue;

        final template = HomeCurrencyRailStrings.t(key, locale);
        expect(
          template,
          isNot(equals(englishTemplate)),
          reason:
              '$locale must not fall back to the English template for $key',
        );
        expect(template, isNotEmpty, reason: locale);
      }
    });

    test('{rate} and {code} placeholders are preserved per locale', () {
      for (final locale in AppLocale.supportedLocales) {
        final formatted = HomeCurrencyRailStrings.format(
          key,
          locale,
          params: {'rate': '24.50', 'code': 'INR'},
        );
        expect(formatted, contains('24.50'), reason: locale);
        expect(formatted, contains('INR'), reason: locale);
      }
    });
  });
}
