import 'package:intl/intl.dart';
import 'package:raabta/core/l10n/app_locale.dart';

/// Locale-safe calendar labels for acclimatization start dates.
abstract final class ClimateAcclimatizationDateFormat {
  static String format(DateTime calendarDate, String locale) {
    final normalized = AppLocale.normalize(locale);
    final candidates = <String>[
      AppLocale.toLanguageCode(normalized),
      if (normalized == 'Filipino') 'en_PH',
      'en',
    ];
    for (final code in candidates) {
      try {
        return DateFormat.yMMMd(code).format(calendarDate);
      } catch (_) {
        continue;
      }
    }
    return _manualEnglishFallback(calendarDate);
  }

  static String _manualEnglishFallback(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}
