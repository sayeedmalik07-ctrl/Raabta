import 'package:flutter/foundation.dart';
import 'package:raabta/core/l10n/app_locale.dart';
import 'package:raabta/core/l10n/locale_catalog_coverage.dart';

/// Cross-feature action labels (Cancel, Save, Call, WhatsApp, etc.).
abstract final class CommonActionStrings {
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

  static const _catalog = <String, Map<String, String>>{
    'action_cancel': {
      'English': 'Cancel',
      'Arabic': 'إلغاء',
      'Hindi': 'रद्द करें',
      'Urdu': 'منسوخ',
      'Malayalam': 'Cancel',
      'Nepali': 'Cancel',
      'Bengali': 'বাতিল',
      'Filipino': 'Cancel',
    },
    'action_save': {
      'English': 'Save',
      'Arabic': 'حفظ',
      'Hindi': 'सेव करें',
      'Urdu': 'محفوظ کریں',
      'Malayalam': 'Save',
      'Nepali': 'Save',
      'Bengali': 'সংরক্ষণ',
      'Filipino': 'Save',
    },
    'action_saved': {
      'English': 'Saved',
      'Arabic': 'محفوظ',
      'Hindi': 'सेव किया',
      'Urdu': 'محفوظ شدہ',
      'Malayalam': 'Saved',
      'Nepali': 'Saved',
      'Bengali': 'সংরক্ষিত',
      'Filipino': 'Saved',
    },
    'action_unsave': {
      'English': 'Unsave',
      'Arabic': 'إلغاء الحفظ',
      'Hindi': 'सेव हटाएँ',
      'Urdu': 'محفوظ ہٹائیں',
      'Malayalam': 'Unsave',
      'Nepali': 'Unsave',
      'Bengali': 'সংরক্ষণ সরান',
      'Filipino': 'Unsave',
    },
    'action_retry': {
      'English': 'Retry',
      'Arabic': 'إعادة المحاولة',
      'Hindi': 'पुनः प्रयास',
      'Urdu': 'دوبارہ کوشش',
      'Malayalam': 'Retry',
      'Nepali': 'Retry',
      'Bengali': 'আবার চেষ্টা',
      'Filipino': 'Retry',
    },
    'action_back': {
      'English': 'Back',
      'Arabic': 'رجوع',
      'Hindi': 'वापस',
      'Urdu': 'واپس',
      'Malayalam': 'Back',
      'Nepali': 'Back',
      'Bengali': 'পিছনে',
      'Filipino': 'Back',
    },
    'action_call': {
      'English': 'Call',
      'Arabic': 'اتصال',
      'Hindi': 'कॉल',
      'Urdu': 'کال',
      'Malayalam': 'Call',
      'Nepali': 'Call',
      'Bengali': 'কল',
      'Filipino': 'Call',
    },
    'action_whatsapp': {
      'English': 'WhatsApp',
      'Arabic': 'واتساب',
      'Hindi': 'WhatsApp',
      'Urdu': 'واٹس ایپ',
      'Malayalam': 'WhatsApp',
      'Nepali': 'WhatsApp',
      'Bengali': 'WhatsApp',
      'Filipino': 'WhatsApp',
    },
    'action_call_contact': {
      'English': 'Call {contact}',
      'Arabic': 'اتصل {contact}',
      'Hindi': '{contact} पर कॉल करें',
      'Urdu': '{contact} پر کال',
      'Malayalam': 'Call {contact}',
      'Nepali': 'Call {contact}',
      'Bengali': '{contact}-এ কল',
      'Filipino': 'Call {contact}',
    },
    'action_call_compact': {
      'English': '📞 Call',
      'Arabic': '📞 اتصال',
      'Hindi': '📞 कॉल',
      'Urdu': '📞 کال',
      'Malayalam': '📞 Call',
      'Nepali': '📞 Call',
      'Bengali': '📞 কল',
      'Filipino': '📞 Call',
    },
    'action_whatsapp_compact': {
      'English': '💬 WhatsApp',
      'Arabic': '💬 واتساب',
      'Hindi': '💬 WhatsApp',
      'Urdu': '💬 واٹس ایپ',
      'Malayalam': '💬 WhatsApp',
      'Nepali': '💬 WhatsApp',
      'Bengali': '💬 WhatsApp',
      'Filipino': '💬 WhatsApp',
    },
    'error_whatsapp_unavailable': {
      'English': 'Could not open WhatsApp',
      'Arabic': 'تعذّر فتح واتساب',
      'Hindi': 'WhatsApp नहीं खोल सके',
      'Urdu': 'واٹس ایپ نہیں کھل سکی',
      'Malayalam': 'Could not open WhatsApp',
      'Nepali': 'Could not open WhatsApp',
      'Bengali': 'WhatsApp খোলা যায়নি',
      'Filipino': 'Could not open WhatsApp',
    },
    'action_share': {
      'English': 'Share',
      'Arabic': 'مشاركة',
      'Hindi': 'Share karein',
      'Urdu': 'Share karein',
      'Malayalam': 'Share',
      'Nepali': 'Share',
      'Bengali': 'Share karein',
      'Tamil': 'பகிர்',
      'Filipino': 'I-share',
    },
  };
}
