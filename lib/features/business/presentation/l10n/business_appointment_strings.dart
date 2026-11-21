import 'package:flutter/foundation.dart';
import 'package:raabta/core/l10n/app_locale.dart';
import 'package:raabta/core/l10n/locale_catalog_coverage.dart';
import 'package:raabta/core/l10n/locale_catalog_entry.dart';

abstract final class BusinessAppointmentStrings {
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
    'biz_appt_cta': l10nEntry(
      english: 'Book an Appointment',
      arabic: 'احجز موعدًا',
      hindi: 'Appointment book karein',
    ),
    'biz_appt_request_title': l10nEntry(
      english: 'Book an appointment',
      arabic: 'احجز موعدًا',
      hindi: 'Appointment book karein',
    ),
    'biz_appt_request_subtitle': l10nEntry(
      english:
          'Propose one or more times. The business can confirm, suggest another time, or decline.',
      arabic: 'اقترح وقتًا أو أكثر. يمكن للنشاط التجاري التأكيد أو اقتراح وقت آخر أو الرفض.',
      hindi: 'Ek ya zyada samay suggest karein. Business confirm, counter, ya decline kar sakti hai.',
    ),
    'biz_appt_note_label': l10nEntry(
      english: 'Note (optional)',
      arabic: 'ملاحظة (اختياري)',
      hindi: 'Note (optional)',
    ),
    'biz_appt_submit': l10nEntry(
      english: 'Send request',
      arabic: 'إرسال الطلب',
      hindi: 'Request bhejein',
    ),
    'biz_appt_invalid_slots': l10nEntry(
      english: 'Add at least one future time slot.',
      arabic: 'أضف وقتًا مستقبليًا واحدًا على الأقل.',
      hindi: 'Kam se kam ek future slot add karein.',
    ),
    'biz_appt_open_exists': l10nEntry(
      english: 'You already have an open appointment request for this business.',
      arabic: 'لديك بالفعل طلب موعد مفتوح لهذا النشاط.',
      hindi: 'Is business ke liye aapka pehle se open request hai.',
    ),
    'biz_appt_add_slot': l10nEntry(
      english: 'Add another time',
      arabic: 'إضافة وقت آخر',
      hindi: 'Ek aur samay add karein',
    ),
    'biz_appt_status_pending': l10nEntry(
      english: 'Pending',
      arabic: 'قيد الانتظار',
      hindi: 'Pending',
    ),
    'biz_appt_status_awaiting_requester': l10nEntry(
      english: 'Awaiting your response',
      arabic: 'بانتظار ردك',
      hindi: 'Aapke response ka intezar',
    ),
    'biz_appt_status_confirmed': l10nEntry(
      english: 'Confirmed',
      arabic: 'مؤكد',
      hindi: 'Confirmed',
    ),
    'biz_appt_status_declined': l10nEntry(
      english: 'Declined',
      arabic: 'مرفوض',
      hindi: 'Declined',
    ),
    'biz_appt_status_cancelled': l10nEntry(
      english: 'Cancelled',
      arabic: 'ملغى',
      hindi: 'Cancelled',
    ),
    'biz_appt_status_expired': l10nEntry(
      english: 'Expired',
      arabic: 'منتهي',
      hindi: 'Expired',
    ),
    'biz_appt_confirm': l10nEntry(
      english: 'Confirm',
      arabic: 'تأكيد',
      hindi: 'Confirm',
    ),
    'biz_appt_decline': l10nEntry(
      english: 'Decline',
      arabic: 'رفض',
      hindi: 'Decline',
    ),
    'biz_appt_counter': l10nEntry(
      english: 'Suggest other times',
      arabic: 'اقتراح أوقات أخرى',
      hindi: 'Doosre samay suggest karein',
    ),
    'biz_appt_cancel': l10nEntry(
      english: 'Cancel request',
      arabic: 'إلغاء الطلب',
      hindi: 'Request cancel karein',
    ),
    'biz_appt_accept_counter': l10nEntry(
      english: 'Accept time',
      arabic: 'قبول الوقت',
      hindi: 'Samay accept karein',
    ),
    'biz_appt_section_title': l10nEntry(
      english: 'Appointment requests',
      arabic: 'طلبات المواعيد',
      hindi: 'Appointment requests',
    ),
    'biz_appt_notif_received_title': l10nEntry(
      english: 'New appointment request',
      arabic: 'طلب موعد جديد',
      hindi: 'Naya appointment request',
    ),
    'biz_appt_notif_received_body': l10nEntry(
      english: '{name}: {slots}',
      arabic: '{name}: {slots}',
      hindi: '{name}: {slots}',
    ),
    'biz_appt_notif_confirmed_title': l10nEntry(
      english: 'Appointment confirmed',
      arabic: 'تم تأكيد الموعد',
      hindi: 'Appointment confirm hua',
    ),
    'biz_appt_notif_confirmed_body': l10nEntry(
      english: '{name} — {detail}',
      arabic: '{name} — {detail}',
      hindi: '{name} — {detail}',
    ),
    'biz_appt_notif_declined_title': l10nEntry(
      english: 'Appointment declined',
      arabic: 'تم رفض الموعد',
      hindi: 'Appointment decline hua',
    ),
    'biz_appt_notif_declined_body': l10nEntry(
      english: '{name}',
      arabic: '{name}',
      hindi: '{name}',
    ),
    'biz_appt_notif_countered_title': l10nEntry(
      english: 'New appointment times suggested',
      arabic: 'أوقات موعد جديدة مقترحة',
      hindi: 'Naye appointment samay suggest kiye gaye',
    ),
    'biz_appt_notif_countered_body': l10nEntry(
      english: '{name}: {detail}',
      arabic: '{name}: {detail}',
      hindi: '{name}: {detail}',
    ),
    'biz_appt_notif_cancelled_title': l10nEntry(
      english: 'Appointment request cancelled',
      arabic: 'تم إلغاء طلب الموعد',
      hindi: 'Appointment request cancel hua',
    ),
    'biz_appt_notif_cancelled_body': l10nEntry(
      english: '{name}',
      arabic: '{name}',
      hindi: '{name}',
    ),
  };
}
