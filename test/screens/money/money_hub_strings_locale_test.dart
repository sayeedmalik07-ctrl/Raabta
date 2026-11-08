import 'package:flutter_test/flutter_test.dart';
import 'package:raabta/core/l10n/app_locale.dart';
import 'package:raabta/screens/money/l10n/money_hub_strings.dart';

void main() {
  group('MoneyHubStrings locale coverage', () {
    test('dashboard_compliance_footer and hero_rate_series_change have all locales',
        () {
      final report = MoneyHubStrings.localeCoverageReport;
      expect(
        report['dashboard_compliance_footer'],
        isNull,
        reason: 'All AppLocale.supportedLocales must have non-empty strings',
      );
      expect(
        report['hero_rate_series_change'],
        isNull,
        reason: 'All AppLocale.supportedLocales must have non-empty strings',
      );
    });

    test('hero_rate_series_change placeholder {percent} is preserved per locale',
        () {
      for (final locale in AppLocale.supportedLocales) {
        final s = MoneyHubStrings.format(
          'hero_rate_series_change',
          locale,
          params: {'percent': '+0.4%'},
        );
        expect(s, contains('+0.4%'), reason: locale);
      }
    });
  });
}
