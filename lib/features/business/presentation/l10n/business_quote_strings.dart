import 'package:flutter/foundation.dart';
import 'package:raabta/core/l10n/app_locale.dart';
import 'package:raabta/core/l10n/locale_catalog_coverage.dart';
import 'package:raabta/core/l10n/locale_catalog_entry.dart';

abstract final class BusinessQuoteStrings {
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
    params.forEach((p, r) => value = value.replaceAll('{$p}', r));
    return value;
  }

  @visibleForTesting
  static Map<String, Set<String>> get localeCoverageReport =>
      buildLocaleCoverageReport(
        catalog: _catalog,
        supportedLocales: supportedLocales,
      );

  static final _catalog = <String, Map<String, String>>{
    'biz_quote_cta': l10nEntry(
      english: 'Request a Quote',
      arabic: 'طلب عرض سعر',
      hindi: 'Quote request karein',
    ),
    'biz_quote_request_title': l10nEntry(
      english: 'Request a quote',
      arabic: 'طلب عرض سعر',
      hindi: 'Quote request',
    ),
    'biz_quote_request_subtitle': l10nEntry(
      english: 'Describe what you need. The business will respond with a quote or decline.',
      arabic: 'صف ما تحتاجه. سيرد النشاط التجاري بعرض سعر أو بالرفض.',
      hindi: 'Apni zaroorat batayein. Business quote ya decline karega.',
    ),
    'biz_quote_description_label': l10nEntry(
      english: 'What do you need?',
      arabic: 'ماذا تحتاج؟',
      hindi: 'Aapko kya chahiye?',
    ),
    'biz_quote_budget_label': l10nEntry(
      english: 'Budget (QAR, optional)',
      arabic: 'الميزانية (ريال، اختياري)',
      hindi: 'Budget (QAR, optional)',
    ),
    'biz_quote_submit': l10nEntry(
      english: 'Send request',
      arabic: 'إرسال الطلب',
      hindi: 'Request bhejein',
    ),
    'biz_quote_invalid_description': l10nEntry(
      english: 'Enter a description (at least a few words).',
      arabic: 'أدخل وصفًا (بضع كلمات على الأقل).',
      hindi: 'Description likhein (kam se kam kuch shabd).',
    ),
    'biz_quote_open_exists': l10nEntry(
      english: 'You already have an open quote request for this business.',
      arabic: 'لديك بالفعل طلب عرض سعر مفتوح.',
      hindi: 'Is business ke liye open quote request pehle se hai.',
    ),
    'biz_quote_response_title': l10nEntry(
      english: 'Submit quote',
      arabic: 'إرسال عرض السعر',
      hindi: 'Quote submit karein',
    ),
    'biz_quote_price_label': l10nEntry(
      english: 'Price (QAR)',
      arabic: 'السعر (ريال)',
      hindi: 'Price (QAR)',
    ),
    'biz_quote_included_label': l10nEntry(
      english: 'What is included',
      arabic: 'ما المشمول',
      hindi: 'Kya shamil hai',
    ),
    'biz_quote_note_label': l10nEntry(
      english: 'Note (optional)',
      arabic: 'ملاحظة (اختياري)',
      hindi: 'Note (optional)',
    ),
    'biz_quote_status_pending': l10nEntry(
      english: 'Pending',
      arabic: 'قيد الانتظار',
      hindi: 'Pending',
    ),
    'biz_quote_status_quoted': l10nEntry(
      english: 'Quoted',
      arabic: 'تم إرسال عرض السعر',
      hindi: 'Quoted',
    ),
    'biz_quote_status_declined': l10nEntry(
      english: 'Declined',
      arabic: 'مرفوض',
      hindi: 'Declined',
    ),
    'biz_quote_status_cancelled': l10nEntry(
      english: 'Cancelled',
      arabic: 'ملغى',
      hindi: 'Cancelled',
    ),
    'biz_quote_status_expired': l10nEntry(
      english: 'Expired',
      arabic: 'منتهي',
      hindi: 'Expired',
    ),
    'biz_quote_section_title': l10nEntry(
      english: 'Quote requests',
      arabic: 'طلبات عروض الأسعار',
      hindi: 'Quote requests',
    ),
    'biz_quote_your_quote': l10nEntry(
      english: 'Quote: {price} QAR — {detail}',
      arabic: 'عرض السعر: {price} ريال — {detail}',
      hindi: 'Quote: {price} QAR — {detail}',
    ),
    'biz_quote_notif_received_title': l10nEntry(
      english: 'New quote request',
      arabic: 'طلب عرض سعر جديد',
      hindi: 'Naya quote request',
    ),
    'biz_quote_notif_received_body': l10nEntry(
      english: '{name}',
      arabic: '{name}',
      hindi: '{name}',
    ),
    'biz_quote_notif_quoted_title': l10nEntry(
      english: 'Quote received',
      arabic: 'تم استلام عرض السعر',
      hindi: 'Quote mila',
    ),
    'biz_quote_notif_quoted_body': l10nEntry(
      english: '{name} — {detail} QAR',
      arabic: '{name} — {detail} ريال',
      hindi: '{name} — {detail} QAR',
    ),
    'biz_quote_notif_declined_title': l10nEntry(
      english: 'Quote request declined',
      arabic: 'تم رفض طلب عرض السعر',
      hindi: 'Quote request decline hua',
    ),
    'biz_quote_notif_declined_body': l10nEntry(
      english: '{name}',
      arabic: '{name}',
      hindi: '{name}',
    ),
    'biz_quote_notif_cancelled_title': l10nEntry(
      english: 'Quote request cancelled',
      arabic: 'تم إلغاء طلب عرض السعر',
      hindi: 'Quote request cancel hua',
    ),
    'biz_quote_notif_cancelled_body': l10nEntry(
      english: '{name}',
      arabic: '{name}',
      hindi: '{name}',
    ),
  };
}
