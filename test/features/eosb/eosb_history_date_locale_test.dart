import 'package:flutter_test/flutter_test.dart';
import 'package:raabta/core/l10n/app_locale.dart';
import 'package:raabta/features/eosb/presentation/eosb_history_date_format.dart';

void main() {
  const sample = '2025-06-15T14:30:00.000';

  setUpAll(() async {
    await EosbHistoryDateFormatter.warmUp();
  });

  group('EosbHistoryDateFormatter', () {
    for (final locale in AppLocale.supportedLocales) {
      test('$locale formats savedAt with locale code', () async {
        await EosbHistoryDateFormatter.ensureLocale(locale);
        final dt = DateTime.parse(sample);
        final formatted = EosbHistoryDateFormatter.formatEntryDateTime(
          dt,
          locale,
        );
        expect(formatted.trim(), isNotEmpty);
        expect(formatted, isNot(contains('2025-06-15T')));
      });
    }

    test('Arabic differs from English formatting', () async {
      await EosbHistoryDateFormatter.ensureLocale('Arabic');
      final dt = DateTime.parse(sample);
      final en = EosbHistoryDateFormatter.formatEntryDateTime(dt, 'English');
      final ar = EosbHistoryDateFormatter.formatEntryDateTime(dt, 'Arabic');
      expect(ar, isNot(equals(en)));
    });

    test('Urdu differs from English formatting', () async {
      await EosbHistoryDateFormatter.ensureLocale('Urdu');
      final dt = DateTime.parse(sample);
      final en = EosbHistoryDateFormatter.formatEntryDateTime(dt, 'English');
      final ur = EosbHistoryDateFormatter.formatEntryDateTime(dt, 'Urdu');
      expect(ur, isNot(equals(en)));
    });
  });
}
