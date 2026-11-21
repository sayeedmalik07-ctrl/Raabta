import 'package:flutter_test/flutter_test.dart';
import 'package:raabta/core/l10n/app_locale.dart';
import 'package:raabta/features/money_comparator/presentation/l10n/money_comparator_strings.dart';

void main() {
  group('mc_community_sort_scope_hint', () {
    const key = 'mc_community_sort_scope_hint';

    test('all supported locales have non-empty strings', () {
      for (final locale in AppLocale.supportedLocales) {
        expect(
          MoneyComparatorStrings.t(key, locale),
          isNotEmpty,
          reason: locale,
        );
      }
    });

    test('non-English locales do not fall back to English template', () {
      final english = MoneyComparatorStrings.t(key, 'English');
      expect(english, isNotEmpty);
      for (final locale in AppLocale.supportedLocales) {
        if (locale == 'English') continue;
        expect(
          MoneyComparatorStrings.t(key, locale),
          isNot(equals(english)),
          reason: '$locale should have a dedicated translation for $key',
        );
      }
    });
  });
}
