import 'package:flutter/foundation.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:raabta/core/l10n/app_locale.dart';

/// Locale-aware history row timestamps (display only).
abstract final class EosbHistoryDateFormatter {
  static final Set<String> _initializedLocales = {};

  /// Preloads intl symbols for EOSB history locales.
  static Future<void> warmUp({Iterable<String>? locales}) async {
    final codes = <String>{'en'};
    for (final locale in locales ?? AppLocale.supportedLocales) {
      codes.add(AppLocale.toLanguageCode(locale));
    }
    for (final code in codes) {
      if (_initializedLocales.contains(code)) continue;
      try {
        await initializeDateFormatting(code);
        _initializedLocales.add(code);
      } catch (_) {
        // e.g. fil — falls back to English formatting at runtime.
      }
    }
  }

  @visibleForTesting
  static Future<void> ensureLocale(String locale) => warmUp(locales: [locale]);

  static String formatEntryDateTime(DateTime date, String locale) {
    final local = date.toLocal();
    final code = AppLocale.toLanguageCode(locale);
    for (final tryCode in [code, if (code != 'en') 'en']) {
      try {
        return DateFormat.yMMMd(tryCode).add_jm().format(local);
      } catch (_) {
        continue;
      }
    }
    return DateFormat.yMMMd().add_jm().format(local);
  }
}
