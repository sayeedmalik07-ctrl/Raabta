import 'package:flutter/foundation.dart';
import 'package:raabta/core/l10n/app_locale.dart';
import 'package:raabta/core/l10n/locale_catalog_coverage.dart';
import 'package:raabta/core/l10n/locale_catalog_entry.dart';

abstract final class HousingViewingStrings {
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
    'hv_request_viewing': l10nEntry(
      english: 'Request a Viewing',
      arabic: 'طلب معاينة',
      hindi: 'Viewing request karein',
    ),
    'hv_request_viewing_title': l10nEntry(
      english: 'Request a viewing',
      arabic: 'طلب معاينة',
      hindi: 'Viewing request',
    ),
    'hv_request_viewing_subtitle': l10nEntry(
      english:
          'Propose one or more times that work for you. The landlord or agent can confirm, suggest another time, or decline.',
      arabic:
          'اقترح وقتًا أو أكثر يناسبك. يمكن للمالك أو الوكيل التأكيد أو اقتراح وقت آخر أو الرفض.',
      hindi:
          'Ek ya zyada time suggest karein. Landlord confirm, counter ya decline kar sakta hai.',
    ),
    'hv_add_slot': l10nEntry(
      english: 'Add another time option',
      arabic: 'إضافة وقت آخر',
      hindi: 'Ek aur time add karein',
    ),
    'hv_slot_date_label': l10nEntry(
      english: 'Date',
      arabic: 'التاريخ',
      hindi: 'Date',
    ),
    'hv_slot_time_label': l10nEntry(
      english: 'Time',
      arabic: 'الوقت',
      hindi: 'Time',
    ),
    'hv_note_label': l10nEntry(
      english: 'Note (optional)',
      arabic: 'ملاحظة (اختياري)',
      hindi: 'Note (optional)',
    ),
    'hv_note_hint': l10nEntry(
      english: 'e.g. I can only visit after work',
      arabic: 'مثال: أستطيع المعاينة بعد العمل',
      hindi: 'jaise: main kaam ke baad aa sakta hoon',
    ),
    'hv_submit_request': l10nEntry(
      english: 'Send viewing request',
      arabic: 'إرسال طلب المعاينة',
      hindi: 'Request bhejein',
    ),
    'hv_invalid_slots': l10nEntry(
      english: 'Add at least one future date and time.',
      arabic: 'أضف تاريخًا ووقتًا مستقبليًا واحدًا على الأقل.',
      hindi: 'Kam se kam ek future date aur time add karein.',
    ),
    'hv_slot_line': l10nEntry(
      english: '{date} at {time}',
      arabic: '{date} الساعة {time}',
      hindi: '{date}, {time}',
    ),
    'hv_seller_requests_count': l10nEntry(
      english: '{count} pending viewing request(s)',
      arabic: '{count} طلب/طلبات معاينة قيد الانتظار',
      hindi: '{count} pending viewing request',
    ),
    'hv_viewer_status_pending': l10nEntry(
      english: 'Waiting for landlord response',
      arabic: 'في انتظار رد المالك',
      hindi: 'Landlord ke jawab ka intezaar',
    ),
    'hv_viewer_status_counter': l10nEntry(
      english: 'Landlord proposed different times',
      arabic: 'المالك اقترح أوقاتًا مختلفة',
      hindi: 'Landlord ne alag time suggest kiya',
    ),
    'hv_action_confirm': l10nEntry(
      english: 'Confirm',
      arabic: 'تأكيد',
      hindi: 'Confirm',
    ),
    'hv_action_decline': l10nEntry(
      english: 'Decline',
      arabic: 'رفض',
      hindi: 'Decline',
    ),
    'hv_action_propose_time': l10nEntry(
      english: 'Propose different time',
      arabic: 'اقتراح وقت مختلف',
      hindi: 'Alag time suggest karein',
    ),
    'hv_pick_slot_title': l10nEntry(
      english: 'Which time works?',
      arabic: 'أي وقت يناسب؟',
      hindi: 'Kaunsa time theek hai?',
    ),
    'hv_owner_overview_title': l10nEntry(
      english: 'Upcoming viewings',
      arabic: 'المعاينات القادمة',
      hindi: 'Aane wali viewings',
    ),
    'hv_owner_overview_empty': l10nEntry(
      english: 'No pending or confirmed viewing requests yet.',
      arabic: 'لا توجد طلبات معاينة معلقة أو مؤكدة بعد.',
      hindi: 'Abhi koi pending ya confirmed viewing nahi.',
    ),
    'hv_status_confirmed': l10nEntry(
      english: 'Confirmed',
      arabic: 'مؤكد',
      hindi: 'Confirmed',
    ),
    'hv_status_pending': l10nEntry(
      english: 'Pending',
      arabic: 'قيد الانتظار',
      hindi: 'Pending',
    ),
    'hv_chat_title': l10nEntry(
      english: 'Message landlord',
      arabic: 'مراسلة المالك',
      hindi: 'Landlord ko message',
    ),
    'hv_chat_hint': l10nEntry(
      english: 'Type a message…',
      arabic: 'اكتب رسالة…',
      hindi: 'Message likhein…',
    ),
    'hv_chat_confirmed': l10nEntry(
      english:
          'Viewing confirmed for {slot} — message here if plans change.',
      arabic: 'تم تأكيد المعاينة {slot} — راسل هنا إذا تغيرت الخطط.',
      hindi: 'Viewing {slot} ke liye confirm — plans badlein to yahan likhein.',
    ),
    'hv_chat_declined': l10nEntry(
      english: 'Viewing request declined.',
      arabic: 'تم رفض طلب المعاينة.',
      hindi: 'Viewing request decline ho gayi.',
    ),
    'hv_chat_countered': l10nEntry(
      english: 'Landlord proposed: {detail}',
      arabic: 'المالك اقترح: {detail}',
      hindi: 'Landlord ne suggest kiya: {detail}',
    ),
    'hv_notif_received_title': l10nEntry(
      english: 'Viewing request',
      arabic: 'طلب معاينة',
      hindi: 'Viewing request',
    ),
    'hv_notif_received_body': l10nEntry(
      english: '{title}: {slots}',
      arabic: '{title}: {slots}',
      hindi: '{title}: {slots}',
    ),
    'hv_notif_confirmed_title': l10nEntry(
      english: 'Viewing confirmed',
      arabic: 'تم تأكيد المعاينة',
      hindi: 'Viewing confirm',
    ),
    'hv_notif_confirmed_body': l10nEntry(
      english: '{title} — {detail}',
      arabic: '{title} — {detail}',
      hindi: '{title} — {detail}',
    ),
    'hv_notif_declined_title': l10nEntry(
      english: 'Viewing declined',
      arabic: 'تم رفض المعاينة',
      hindi: 'Viewing decline',
    ),
    'hv_notif_declined_body': l10nEntry(
      english: '{title} viewing request was declined.',
      arabic: 'تم رفض طلب معاينة {title}.',
      hindi: '{title} viewing request decline hui.',
    ),
    'hv_notif_countered_title': l10nEntry(
      english: 'New viewing times proposed',
      arabic: 'أوقات معاينة جديدة مقترحة',
      hindi: 'Naye viewing time suggest hue',
    ),
    'hv_notif_countered_body': l10nEntry(
      english: '{title}: {detail}',
      arabic: '{title}: {detail}',
      hindi: '{title}: {detail}',
    ),
  };
}
