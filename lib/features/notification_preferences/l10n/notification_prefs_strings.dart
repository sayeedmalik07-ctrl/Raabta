/// Notification preferences localized strings (8 languages + RTL).
import 'package:flutter/foundation.dart';
import 'package:raabta/core/l10n/locale_catalog_coverage.dart';

abstract final class NotificationPrefsStrings {
  static const supportedLocales = [
    'English',
    'Arabic',
    'Hindi',
    'Urdu',
    'Malayalam',
    'Nepali',
    'Filipino',
    'Bengali',
  ];

  static String t(String key, [String locale = 'English']) {
    final map = _catalog[key];
    if (map == null) return key;
    return map[locale] ?? map['English'] ?? key;
  }

  /// Exposed for catalog parity regression tests only.
  @visibleForTesting
  static Map<String, Set<String>> get localeCoverageReport =>
      buildLocaleCoverageReport(
        catalog: _catalog,
        supportedLocales: supportedLocales,
      );

  static const _catalog = <String, Map<String, String>>{
    'prefs_title': {
      'English': 'Notification Preferences',
      'Arabic': 'تفضيلات الإشعارات',
      'Hindi': 'सूचना प्राथमिकताएँ',
      'Urdu': 'اطلاعات کی ترجیحات',
      'Malayalam': 'അറിയിപ്പ് മുൻഗണനകൾ',
      'Nepali': 'सूचना प्राथमिकताहरू',
      'Filipino': 'அறிவிப்பு விருப்பத்தேர்வுகள்',
      'Bengali': 'বিজ্ঞপ্তি পছন্দ',
    },
    'prefs_subtitle': {
      'English': 'Control alerts by category, quiet hours, and frequency.',
      'Arabic': 'تحكم في التنبيهات حسب الفئة وساعات الهدوء.',
      'Hindi': 'श्रेणी, शांत समय और आवृत्ति के अनुसार अलर्ट नियंत्रित करें।',
      'Urdu': 'زمرے، خاموش اوقات اور تعدد کے مطابق الرٹس کنٹرول کریں۔',
    },
    'group_bills': {
      'English': 'Bills & Warranty',
      'Arabic': 'الفواتير والضمان',
      'Hindi': 'बिल और वारंटी',
      'Urdu': 'بل اور وارنٹی',
    },
    'group_eosb': {
      'English': 'EOSB Calculator',
      'Arabic': 'حاسبة مكافأة نهاية الخدمة',
      'Hindi': 'EOSB कैलकुलेटर',
      'Urdu': 'EOSB کیلکولیٹر',
    },
    'group_scam_shield': {
      'English': 'Scam Shield',
      'Arabic': 'درع الاحتيال',
      'Hindi': 'Scam Shield',
      'Urdu': 'Scam Shield',
    },
    'group_scam_security_alerts': {
      'English': 'Scam & security alerts',
      'Arabic': 'تنبيهات الاحتيال والأمان',
      'Hindi': 'Scam & security alerts',
      'Urdu': 'Scam & security alerts',
    },
    'notif_scam_advisory_alert': {
      'English': 'Scam alerts from official advisories',
      'Arabic': 'تنبيهات من التحذيرات الرسمية',
      'Hindi': 'Scam alerts from official advisories',
      'Urdu': 'Scam alerts from official advisories',
    },
    'notif_scam_advisory_alert_hint': {
      'English': 'Rare push when Raabta publishes an elevated official advisory.',
      'Arabic': 'إشعار نادر عند نشر تحذير رسمي مرتفع.',
      'Hindi': 'Rare push when Raabta publishes an elevated official advisory.',
      'Urdu': 'Rare push when Raabta publishes an elevated official advisory.',
    },
    'notif_security_tip': {
      'English': 'Monthly security tip',
      'Arabic': 'نصيحة أمان شهرية',
      'Hindi': 'Monthly security tip',
      'Urdu': 'Monthly security tip',
    },
    'notif_security_tip_hint': {
      'English': 'About once every 4 weeks — one short reminder, rotating wording.',
      'Arabic': 'حوالي مرة كل 4 أسابيع — تذكير قصير بصياغة متجددة.',
      'Hindi': 'About once every 4 weeks — one short reminder, rotating wording.',
      'Urdu': 'About once every 4 weeks — one short reminder, rotating wording.',
    },
    'notif_security_tip_flag_review': {
      'English': 'Default ON pending product review (kSecurityTipDefaultEnabled).',
      'Arabic': 'مفعّل افتراضياً بانتظار مراجعة المنتج.',
      'Hindi': 'Default ON pending product review.',
      'Urdu': 'Default ON pending product review.',
    },
    'notif_security_today_cards': {
      'English': 'Show security cards on Today',
      'Arabic': 'إظهار بطاقات الأمان في «اليوم»',
      'Hindi': 'Show security cards on Today',
      'Urdu': 'Show security cards on Today',
    },
    'notif_security_today_cards_hint': {
      'English': 'Short, time-limited guidance on Home — no personal details.',
      'Arabic': 'إرشاد قصير محدود على الرئيسية — بدون بيانات شخصية.',
      'Hindi': 'Short, time-limited guidance on Home — no personal details.',
      'Urdu': 'Short, time-limited guidance on Home — no personal details.',
    },
    'scam_security_turn_all_off': {
      'English': 'Turn all off',
      'Arabic': 'إيقاف الكل',
      'Hindi': 'Turn all off',
      'Urdu': 'Turn all off',
    },
    'prefs_os_blocked_title': {
      'English': 'Notifications blocked',
      'Arabic': 'الإشعارات محظورة',
      'Hindi': 'Notifications blocked',
      'Urdu': 'Notifications blocked',
    },
    'prefs_os_blocked_body': {
      'English': 'Enable notifications in system settings to receive scam and security alerts.',
      'Arabic': 'فعّل الإشعارات من إعدادات النظام لتلقي تنبيهات الأمان.',
      'Hindi': 'Enable notifications in system settings to receive scam and security alerts.',
      'Urdu': 'Enable notifications in system settings to receive scam and security alerts.',
    },
    'prefs_open_settings': {
      'English': 'Open settings',
      'Arabic': 'فتح الإعدادات',
      'Hindi': 'Open settings',
      'Urdu': 'Open settings',
    },
    'group_community': {
      'English': 'Community',
      'Arabic': 'المجتمع',
      'Hindi': 'समुदाय',
      'Urdu': 'کمیونٹی',
    },
    'group_jobs': {
      'English': 'Jobs & Housing',
      'Arabic': 'الوظائف والسكن',
      'Hindi': 'नौकरियाँ और आवास',
      'Urdu': 'نوکریاں اور رہائش',
    },
    'group_groups': {
      'English': 'Groups',
      'Arabic': 'المجموعات',
      'Hindi': 'समूह',
      'Urdu': 'گروپس',
    },
    'group_admin': {
      'English': 'Admin',
      'Arabic': 'الإدارة',
      'Hindi': 'एडमिन',
      'Urdu': 'ایڈمن',
    },
    'notif_bill_tracker': {
      'English': 'Bill due reminders',
      'Arabic': 'تذكير موعد الفاتورة',
      'Hindi': 'बिल देय अनुस्मारक',
      'Urdu': 'بل کی یاد دہانی',
    },
    'notif_friends_family_loans': {
      'English': 'Friends & Family loan reminders',
      'Arabic': 'تذكير قروض الأصدقاء والعائلة',
      'Hindi': 'मित्र/परिवार ऋण अनुस्मारक',
      'Urdu': 'دوست و خاندان قرض یاد دہانیاں',
    },
    'notif_health_insurance': {
      'English': 'Health Insurance Truth Engine reminders',
      'Arabic': 'تذكيرات محرك حقيقة التأمين الصحي',
      'Hindi': 'हेल्थ इंश्योरेंस Truth Engine अनुस्मारक',
      'Urdu': 'ہیلتھ انشورنس Truth Engine یاد دہانیاں',
    },
    'notif_life_intelligence': {
      'English': 'Life Intelligence insights',
      'Arabic': 'رؤى Life Intelligence',
      'Hindi': 'Life Intelligence insights',
      'Urdu': 'Life Intelligence insights',
      'Malayalam': 'Life Intelligence insights',
      'Nepali': 'Life Intelligence insights',
      'Filipino': 'Life Intelligence insights',
      'Bengali': 'Life Intelligence insights',
    },
    'notif_life_event_correlation': {
      'English': 'Life event health coverage reminders',
      'Arabic': 'تذكيرات تغطية التأمين المرتبطة بأحداث الحياة',
      'Hindi': 'Life event health coverage reminders',
      'Urdu': 'Life event health coverage reminders',
    },
    'notif_concierge_90_day': {
      'English': '90-day settling-in concierge',
      'Arabic': 'مرافق الاستقرار 90 يوماً',
      'Hindi': '90-दिन settling-in concierge',
      'Urdu': '90 دن settling-in concierge',
    },
    'notif_warranty': {
      'English': 'Warranty expiry warnings',
      'Arabic': 'تحذير انتهاء الضمان',
      'Hindi': 'वारंटी समाप्ति चेतावनी',
      'Urdu': 'وارنٹی ختم ہونے کی وارننگ',
    },
    'notif_eosb_reengagement': {
      'English': 'EOSB estimate reminders',
      'Arabic': 'تذكيرات تقدير مكافأة نهاية الخدمة',
      'Hindi': 'EOSB अनुमान अनुस्मारक',
      'Urdu': 'EOSB تخمینہ یاد دہانیاں',
    },
    'notif_legal_source_update': {
      'English': 'Legal rule updates affecting your calculations',
      'Arabic': 'تحديثات قانونية تؤثر على حساباتك',
      'Hindi': 'Legal rule updates affecting your calculations',
      'Urdu': 'Legal rule updates affecting your calculations',
    },
    'notif_scam_shield_incident': {
      'English': 'Scam Shield incident response alerts',
      'Arabic': 'تنبيهات استجابة حوادث Scam Shield',
      'Hindi': 'Scam Shield incident response alerts',
      'Urdu': 'Scam Shield incident response alerts',
    },
    'notif_scam_shield_share_alert': {
      'English': 'High-risk shared message alerts',
      'Arabic': 'تنبيهات الرسائل المشتركة عالية الخطورة',
      'Hindi': 'High-risk shared message alerts',
      'Urdu': 'High-risk shared message alerts',
    },
    'notif_intelligence_daily_review': {
      'English': 'Daily risk & opportunity review',
      'Arabic': 'مراجعة المخاطر والفرص اليومية',
      'Hindi': 'Daily risk & opportunity review',
      'Urdu': 'Daily risk & opportunity review',
    },
    'notif_ask_qatar': {
      'English': 'Ask Qatar replies',
      'Arabic': 'ردود اسأل قطر',
      'Hindi': 'Ask Qatar उत्तर',
      'Urdu': 'Ask Qatar جوابات',
    },
    'notif_event_approved': {
      'English': 'Event approved',
      'Arabic': 'تمت الموافقة على الفعالية',
      'Hindi': 'इवेंट स्वीकृत',
      'Urdu': 'ایونٹ منظور',
    },
    'notif_event_rejected': {
      'English': 'Event rejected',
      'Arabic': 'تم رفض الفعالية',
      'Hindi': 'इवेंट अस्वीकृत',
      'Urdu': 'ایونٹ مسترد',
    },
    'notif_event_group': {
      'English': 'New events in your groups',
      'Arabic': 'فعاليات جديدة في مجموعاتك',
      'Hindi': 'आपके समूहों में नए इवेंट',
      'Urdu': 'آپ کے گروپس میں نئے ایونٹس',
    },
    'notif_lost_found': {
      'English': 'Lost & Found posts',
      'Arabic': 'منشورات المفقودات',
      'Hindi': 'Lost & Found पोस्ट',
      'Urdu': 'Lost & Found پوسٹس',
    },
    'notif_groups_digest': {
      'English': 'Group activity digest',
      'Arabic': 'ملخص نشاط المجموعة',
      'Hindi': 'समूह गतिविधि सारांश',
      'Urdu': 'گروپ سرگرمی خلاصہ',
    },
    'notif_jobs_match': {
      'English': 'Job matches',
      'Arabic': 'تطابق الوظائف',
      'Hindi': 'नौकरी मिलान',
      'Urdu': 'نوکری میچ',
    },
    'notif_housing_match': {
      'English': 'Housing matches',
      'Arabic': 'تطابق السكن',
      'Hindi': 'आवास मिलान',
      'Urdu': 'رہائش میچ',
    },
    'notif_admin_broadcast': {
      'English': 'Admin announcements',
      'Arabic': 'إعلانات الإدارة',
      'Hindi': 'एडमिन घोषणाएँ',
      'Urdu': 'ایڈمن اعلانات',
    },
    'quiet_hours': {
      'English': 'Quiet hours (Qatar time)',
      'Arabic': 'ساعات الهدوء (توقيت قطر)',
      'Hindi': 'शांत समय (कतर समय)',
      'Urdu': 'خاموش اوقات (قطر وقت)',
    },
    'quiet_hours_hint': {
      'English': '10:00 PM – 7:00 AM Asia/Qatar. Urgent admin alerts may still deliver.',
      'Arabic': '10 مساءً – 7 صباحاً بتوقيت قطر.',
      'Hindi': 'रात 10 – सुबह 7 (Asia/Qatar)।',
      'Urdu': 'رات 10 – صبح 7 (Asia/Qatar)۔',
    },
    'start_time': {
      'English': 'Start',
      'Arabic': 'البداية',
      'Hindi': 'शुरू',
      'Urdu': 'شروع',
    },
    'end_time': {
      'English': 'End',
      'Arabic': 'النهاية',
      'Hindi': 'अंत',
      'Urdu': 'اختتام',
    },
  };
}
