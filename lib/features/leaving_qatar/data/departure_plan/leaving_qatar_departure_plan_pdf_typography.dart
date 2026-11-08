import 'package:flutter/foundation.dart';
import 'package:raabta/core/l10n/app_locale.dart';

/// PDF-only text shaping for Helvetica (LTR) — UI strings stay unchanged.
abstract final class LeavingQatarDeparturePlanPdfTypography {
  /// Replaces punctuation Helvetica cannot draw when exporting LTR PDFs.
  @visibleForTesting
  static String normalizeForLtrPdf(String text) {
    return text
        .replaceAll('\u2014', '-')
        .replaceAll('\u2013', '-')
        .replaceAll('\u00b7', '-');
  }

  static String forPdf(String text, String locale) {
    if (AppLocale.isRtl(locale)) return text;
    return normalizeForLtrPdf(text);
  }
}
