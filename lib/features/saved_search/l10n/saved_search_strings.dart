import 'package:flutter/foundation.dart';
import 'package:raabta/core/l10n/app_locale.dart';
import 'package:raabta/core/l10n/locale_catalog_coverage.dart';
import 'package:raabta/core/l10n/locale_catalog_entry.dart';
import 'package:raabta/features/saved_search/domain/saved_search_vertical.dart';

abstract final class SavedSearchStrings {
  static const supportedLocales = AppLocale.supportedLocales;

  static String t(String key, [String locale = 'English']) {
    final normalized = AppLocale.normalize(locale);
    final map = _catalog[key];
    if (map == null) return key;
    return map[normalized] ?? map['English'] ?? key;
  }

  static String format(
    String key,
    String locale, {
    Map<String, String> params = const {},
  }) {
    var text = t(key, locale);
    params.forEach((name, value) {
      text = text.replaceAll('{$name}', value);
    });
    return text;
  }

  static String verticalLabel(SavedSearchVertical vertical, String locale) {
    return t('vertical_${vertical.storageValue}', locale);
  }

  @visibleForTesting
  static Map<String, Set<String>> get localeCoverageReport =>
      buildLocaleCoverageReport(
        catalog: _catalog,
        supportedLocales: supportedLocales,
      );

  static final _catalog = <String, Map<String, String>>{
    'save_search_action': l10nEntry(
      english: 'Save this search',
      arabic: 'حفظ هذا البحث',
      hindi: 'Is search ko save karein',
    ),
    'save_search_title': l10nEntry(
      english: 'Save search',
      arabic: 'حفظ البحث',
      hindi: 'Search save karein',
    ),
    'save_search_name_hint': l10nEntry(
      english: 'Search name',
      arabic: 'اسم البحث',
      hindi: 'Search ka naam',
    ),
    'save_search_saved': l10nEntry(
      english: 'Search saved. You will be notified when new matches appear.',
      arabic: 'تم حفظ البحث. سيتم إشعارك عند ظهور نتائج جديدة.',
      hindi: 'Search save ho gaya. Naye matches par aapko notify kiya jayega.',
    ),
    'save_search_sign_in': l10nEntry(
      english: 'Sign in to save searches and get alerts.',
      arabic: 'سجّل الدخول لحفظ عمليات البحث والحصول على تنبيهات.',
      hindi: 'Search save aur alerts ke liye sign in karein.',
    ),
    'saved_searches_title': l10nEntry(
      english: 'Saved Searches',
      arabic: 'عمليات البحث المحفوظة',
      hindi: 'Saved searches',
    ),
    'saved_searches_subtitle': l10nEntry(
      english: 'Alerts for new matches in your hubs',
      arabic: 'تنبيهات للنتائج الجديدة في أقسامك',
      hindi: 'Hubs mein naye matches ke alerts',
    ),
    'saved_searches_empty_title': l10nEntry(
      english: 'No saved searches',
      arabic: 'لا توجد عمليات بحث محفوظة',
      hindi: 'Koi saved search nahi',
    ),
    'saved_searches_empty': l10nEntry(
      english: 'No saved searches yet. Save a search from any browse screen.',
      arabic: 'لا توجد عمليات بحث محفوظة بعد. احفظ بحثاً من أي شاشة تصفح.',
      hindi: 'Abhi koi saved search nahi. Kisi browse screen se search save karein.',
    ),
    'saved_searches_rename': l10nEntry(
      english: 'Rename',
      arabic: 'إعادة تسمية',
      hindi: 'Naam badlein',
    ),
    'saved_searches_delete': l10nEntry(
      english: 'Delete',
      arabic: 'حذف',
      hindi: 'Delete karein',
    ),
    'saved_searches_deleted': l10nEntry(
      english: 'Saved search deleted.',
      arabic: 'تم حذف البحث المحفوظ.',
      hindi: 'Saved search delete ho gaya.',
    ),
    'saved_searches_renamed': l10nEntry(
      english: 'Saved search renamed.',
      arabic: 'تمت إعادة تسمية البحث المحفوظ.',
      hindi: 'Saved search ka naam badla gaya.',
    ),
    'saved_search_notif_title': l10nEntry(
      english: 'New match for your saved search',
      arabic: 'نتيجة جديدة لبحثك المحفوظ',
      hindi: 'Aapki saved search ke liye naya match',
    ),
    'saved_search_notif_body': l10nEntry(
      english: '{title} matches "{searchName}"',
      arabic: '{title} يطابق "{searchName}"',
      hindi: '{title} "{searchName}" se match karta hai',
    ),
    'settings_saved_searches': l10nEntry(
      english: 'Saved Searches',
      arabic: 'عمليات البحث المحفوظة',
      hindi: 'Saved searches',
    ),
    'vertical_housing': l10nEntry(
      english: 'Housing',
      arabic: 'السكن',
      hindi: 'Housing',
    ),
    'vertical_jobs': l10nEntry(
      english: 'Jobs',
      arabic: 'الوظائف',
      hindi: 'Jobs',
    ),
    'vertical_business': l10nEntry(
      english: 'Business',
      arabic: 'الأعمال',
      hindi: 'Business',
    ),
    'vertical_services': l10nEntry(
      english: 'Services',
      arabic: 'الخدمات',
      hindi: 'Services',
    ),
    'vertical_marketplace': l10nEntry(
      english: 'Marketplace',
      arabic: 'السوق',
      hindi: 'Marketplace',
    ),
  };
}
