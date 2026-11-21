import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:raabta/core/l10n/app_locale.dart';

/// Locale-aware date formatting for Bill Tracker UI and share text.
abstract final class BillTrackerDateFormatter {
  static final Set<String> _initializedLocales = {};

  /// Preloads intl date symbols for app locales. Safe to call multiple times.
  static Future<void> warmUp({Iterable<String>? locales}) async {
    final codes = <String>{'en'};
    for (final locale in locales ?? AppLocale.supportedLocales) {
      codes.add(_languageCode(locale));
    }
    for (final code in codes) {
      if (_initializedLocales.contains(code)) continue;
      try {
        await initializeDateFormatting(code);
        _initializedLocales.add(code);
      } catch (_) {
        // Some codes (e.g. fil) may fall back to manual formatting.
      }
    }
  }

  /// Ensures a single locale is ready before formatting in async flows.
  static Future<void> ensureLocale(String locale) async {
    final code = _languageCode(locale);
    if (_initializedLocales.contains(code)) return;
    try {
      await initializeDateFormatting(code);
      _initializedLocales.add(code);
    } catch (_) {}
    if (!_initializedLocales.contains('en')) {
      try {
        await initializeDateFormatting('en');
        _initializedLocales.add('en');
      } catch (_) {}
    }
  }

  static String formatDueDate(DateTime date, String locale) {
    return _format(date, locale, (code) => DateFormat.yMMMd(code));
  }

  static String formatPickerDate(DateTime date, String locale) {
    return _format(date, locale, (code) => DateFormat.yMd(code));
  }

  static String formatShareShort(DateTime date, String locale) {
    return _format(date, locale, (code) => DateFormat.Md(code));
  }

  static String _format(
    DateTime date,
    String locale,
    DateFormat Function(String code) builder,
  ) {
    final local = date.toLocal();
    final code = _languageCode(locale);
    if (_initializedLocales.contains(code)) {
      return builder(code).format(local);
    }
    try {
      return builder(code).format(local);
    } catch (_) {
      return _fallbackFormat(local, code, builder);
    }
  }

  static String _fallbackFormat(
    DateTime local,
    String code,
    DateFormat Function(String code) builder,
  ) {
    if (code != 'en') {
      try {
        if (_initializedLocales.contains('en')) {
          return builder('en').format(local);
        }
        return builder('en').format(local);
      } catch (_) {
        // fall through to manual format
      }
    }
    return _manualFormat(local);
  }

  static String _manualFormat(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    return '$day/$month/${date.year}';
  }

  static String _languageCode(String locale) =>
      AppLocale.toLanguageCode(locale);
}
