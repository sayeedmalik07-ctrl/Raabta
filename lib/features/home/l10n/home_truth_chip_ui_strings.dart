import 'package:flutter/foundation.dart';
import 'package:raabta/core/l10n/app_locale.dart';
import 'package:raabta/core/l10n/locale_catalog_coverage.dart';
import 'package:raabta/core/l10n/locale_catalog_entry.dart';

/// Shared Truth chip UI chrome (Start CTA, masked placeholder).
abstract final class HomeTruthChipUiStrings {
  static const supportedLocales = AppLocale.supportedLocales;

  static String t(String key, [String locale = 'English']) {
    final normalized = AppLocale.normalize(locale);
    final map = _catalog[key];
    if (map == null) return key;
    return map[normalized] ?? map['English'] ?? key;
  }

  /// Strict nine-locale coverage inventory (J1 — no runtime behavior change).
  static Map<String, Map<String, String>> get catalogForStrictCoverage =>
      _catalog;

  @visibleForTesting
  static Map<String, Set<String>> get localeCoverageReport =>
      buildLocaleCoverageReport(
        catalog: _catalog,
        supportedLocales: supportedLocales,
      );

  @visibleForTesting
  static Map<String, Set<String>> get strictLocaleCoverageReport =>
      buildLocaleCoverageReport(
        catalog: catalogForStrictCoverage,
        supportedLocales: supportedLocales,
        fillMissingWithEnglish: false,
      );

  static final _catalog = <String, Map<String, String>>{
    'truth_chip_start_cta': l10nEntry(
      english: 'Start ›',
      arabic: 'ابدأ ›',
      hindi: 'शुरू करें ›',
      urdu: 'شروع کریں ›',
      malayalam: 'ആരംഭിക്കുക ›',
      nepali: 'सुरु गर्नुहोस् ›',
      bengali: 'শুরু করুন ›',
      tamil: 'தொடங்கு ›',
      filipino: 'Simulan ›',
    ),
    'truth_chip_status_unavailable': l10nEntry(
      english: 'Status unavailable',
      arabic: 'الحالة غير متاحة',
      hindi: 'स्थिति उपलब्ध नहीं',
      urdu: 'اسٹیٹس دستیاب نہیں',
      malayalam: 'സ്റ്റാറ്റസ് ലഭ്യമല്ല',
      nepali: 'अवस्था उपलब्ध छैन',
      bengali: 'স্ট্যাটাস উপলব্ধ নয়',
      tamil: 'நிலை கிடைக்கவில்லை',
      filipino: 'Hindi available ang status',
    ),
    'truth_chip_masked_placeholder': l10nEntry(
      english: '•••••',
      arabic: 'واجهة المستخدم لشريحة الحقيقة الرئيسية: •••••',
      hindi: 'होम ट्रुथ चिप यूआई: •••••',
      urdu: 'ہوم ٹروتھ چپ UI: •••••',
      malayalam: 'ഹോം ട്രൂത്ത് ചിപ്പ് യുഐ: •••••',
      nepali: 'गृह सत्य चिप UI: •••••',
      bengali: 'হোম ট্রুথ চিপ UI: •••••',
      tamil: 'முகப்பு உண்மை சிப் UI: •••••',
      filipino: 'Home truth chip UI: •••••'
    ),
  };
}
