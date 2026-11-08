import 'package:flutter_test/flutter_test.dart';
import 'package:raabta/core/l10n/app_locale.dart';
import 'package:raabta/core/l10n/app_shell_strings.dart';

void main() {
  test('global_search_hint is shorter copy in every locale', () {
    for (final locale in AppLocale.supportedLocales) {
      final hint = AppShellStrings.t('global_search_hint', locale);
      expect(hint, isNotEmpty);
      expect(
        hint.length,
        lessThan(48),
        reason: 'Hint too long for $locale: $hint',
      );
      expect(hint, isNot(contains('…')));
      expect(hint, isNot(contains('...')));
    }

    expect(
      AppShellStrings.t('global_search_hint', 'English'),
      'Search jobs, housing, docs',
    );
  });
}
