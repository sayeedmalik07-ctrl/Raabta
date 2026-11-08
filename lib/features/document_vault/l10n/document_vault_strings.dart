import 'package:flutter/foundation.dart';
import 'package:raabta/core/l10n/app_locale.dart';
import 'package:raabta/core/l10n/locale_catalog_coverage.dart';
import 'package:raabta/core/l10n/locale_catalog_entry.dart';

/// Document Vault chrome — 9-locale catalog.
abstract final class DocumentVaultStrings {
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
    required Map<String, String> params,
  }) {
    var value = t(key, locale);
    params.forEach((placeholder, replacement) {
      value = value.replaceAll('{$placeholder}', replacement);
    });
    return value;
  }

  @visibleForTesting
  static Map<String, Set<String>> get localeCoverageReport =>
      buildLocaleCoverageReport(
        catalog: _catalog,
        supportedLocales: supportedLocales,
      );

  static final _catalog = <String, Map<String, String>>{
    'vault_search_hint': l10nEntry(
      english: 'Search documents…',
      arabic: 'البحث في المستندات…',
      hindi: 'Documents search karein…',
      urdu: 'Documents search karein…',
    ),
    'vault_scan_new_tooltip': l10nEntry(
      english: 'Scan new document',
      arabic: 'مسح مستند جديد',
      hindi: 'Naya document scan karein',
      urdu: 'Naya document scan karein',
    ),
    'vault_fab_scan': l10nEntry(
      english: 'Scan document',
      arabic: 'مسح مستند',
      hindi: 'Document scan',
      urdu: 'Document scan',
    ),
    'vault_rename_title': l10nEntry(
      english: 'Rename document',
      arabic: 'إعادة تسمية المستند',
      hindi: 'Document rename',
      urdu: 'Document rename',
    ),
    'vault_rename_hint': l10nEntry(
      english: 'Document name',
      arabic: 'اسم المستند',
      hindi: 'Document name',
      urdu: 'Document name',
    ),
    'vault_delete_title': l10nEntry(
      english: 'Delete document?',
      arabic: 'حذف المستند؟',
      hindi: 'Document delete karein?',
      urdu: 'Document delete karein?',
    ),
    'vault_delete_body': l10nEntry(
      english: 'This removes the document from your vault.',
      arabic: 'سيُزال المستند من خزنتك.',
      hindi: 'Ye document vault se hata dega.',
      urdu: 'Ye document vault se hata dega.',
    ),
    'vault_empty_title': l10nEntry(
      english: 'Your Document Vault is empty',
      arabic: 'خزنة المستندات فارغة',
      hindi: 'Document Vault khali hai',
      urdu: 'Document Vault khali hai',
    ),
    'vault_empty_body': l10nEntry(
      english:
          'Scan your QID, visa, lease, or any document to store and track it here.',
      arabic:
          'امسح بطاقتك أو التأشيرة أو العقد أو أي مستند لتخزينه وتتبعه هنا.',
      hindi:
          'QID, visa, lease ya koi document scan karke yahan track karein.',
      urdu:
          'QID, visa, lease ya koi document scan karke yahan track karein.',
    ),
    'vault_empty_cta': l10nEntry(
      english: 'Scan first document',
      arabic: 'امسح أول مستند',
      hindi: 'Pehla document scan karein',
      urdu: 'Pehla document scan karein',
    ),
    'vault_no_match': l10nEntry(
      english: 'No documents match your search.',
      arabic: 'لا توجد مستندات تطابق بحثك.',
      hindi: 'Koi document match nahi karta.',
      urdu: 'Koi document match nahi karta.',
    ),
    'vault_rename_action': l10nEntry(
      english: 'Rename',
      arabic: 'إعادة تسمية',
      hindi: 'Rename',
      urdu: 'Rename',
    ),
    'vault_delete_action': l10nEntry(
      english: 'Delete',
      arabic: 'حذف',
      hindi: 'Delete',
      urdu: 'Delete',
    ),
    'vault_status_expired': l10nEntry(
      english: 'Expired',
      arabic: 'منتهٍ',
      hindi: 'Expired',
      urdu: 'Expired',
    ),
    'vault_status_days_left': l10nEntry(
      english: '{days}d left',
      arabic: 'بقي {days}ي',
      hindi: '{days}d baaki',
      urdu: '{days}d baaki',
    ),
    'vault_document_fallback': l10nEntry(
      english: 'Document',
      arabic: 'مستند',
      hindi: 'Document',
      urdu: 'Document',
    ),
  };
}
