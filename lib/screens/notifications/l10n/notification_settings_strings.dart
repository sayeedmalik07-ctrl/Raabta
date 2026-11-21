/// Notification settings screen strings — 9 locales via [l10nEntry].
import 'package:flutter/foundation.dart';
import 'package:raabta/core/l10n/app_locale.dart';
import 'package:raabta/core/l10n/locale_catalog_coverage.dart';
import 'package:raabta/core/l10n/locale_catalog_entry.dart';

Map<String, String> _e(
  String english, {
  String? arabic,
  String? hindi,
  String? urdu,
  String? bengali,
  String? filipino,
  String? malayalam,
  String? nepali,
  String? tamil,
}) =>
    l10nEntry(
      english: english,
      arabic: arabic,
      hindi: hindi,
      urdu: urdu,
      bengali: bengali,
      filipino: filipino,
      malayalam: malayalam,
      nepali: nepali,
      tamil: tamil,
    );

abstract final class NotificationSettingsStrings {
  static const supportedLocales = AppLocale.supportedLocales;

  /// Storage keys for [NotificationSettings.notificationLanguage].
  static const notificationLanguageKeys = [
    'English',
    'Urdu',
    'Hindi',
    'Arabic',
    'Filipino',
    'Bengali',
  ];

  static String t(String key, [String locale = 'English']) {
    final normalized = AppLocale.normalize(locale);
    final map = _catalog[key];
    if (map == null) return key;
    return map[normalized] ?? map['English'] ?? key;
  }

  static String languageLabel(String storageKey, String locale) {
    switch (storageKey) {
      case 'English':
        return t('lang_english', locale);
      case 'Urdu':
        return t('lang_urdu', locale);
      case 'Hindi':
        return t('lang_hindi', locale);
      case 'Arabic':
        return t('lang_arabic', locale);
      case 'Filipino':
        return t('lang_filipino', locale);
      case 'Bengali':
        return t('lang_bengali', locale);
      default:
        return storageKey;
    }
  }

  static String formatHour(int hour, String locale) {
    final period = hour >= 12 ? t('time_pm', locale) : t('time_am', locale);
    final h = hour % 12 == 0 ? 12 : hour % 12;
    return '$h:00 $period';
  }

  static String formatHourOption(int hour, String locale) {
    if (hour == 0) return t('hour_12_am', locale);
    if (hour < 12) {
      return t('hour_am', locale).replaceAll('{h}', '$hour');
    }
    if (hour == 12) return t('hour_12_pm', locale);
    return t('hour_pm', locale).replaceAll('{h}', '${hour - 12}');
  }

  @visibleForTesting
  static Map<String, Set<String>> get localeCoverageReport =>
      buildLocaleCoverageReport(
        catalog: _catalog,
        supportedLocales: supportedLocales,
      );

  static final _catalog = <String, Map<String, String>>{
    'settings_title': _e(
      'Notification Settings',
      arabic: 'إعدادات الإشعارات',
      hindi: 'सूचना सेटिंग',
      urdu: 'اطلاعات کی ترتیبات',
      bengali: 'বিজ্ঞপ্তি সেটিংস',
      filipino: 'Mga Setting ng Notification',
    ),
    'notification_language': _e(
      'Notification language',
      arabic: 'لغة الإشعارات',
      hindi: 'सूचना भाषा',
      urdu: 'اطلاع کی زبان',
      bengali: 'বিজ্ঞপ্তির ভাষা',
      filipino: 'Wika ng notification',
    ),
    'notification_language_hint': _e(
      'Separate from app language — alerts will arrive in this language',
      arabic: 'منفصلة عن لغة التطبيق — ستصل التنبيهات بهذه اللغة',
      hindi: 'ऐप भाषा से अलग — अलर्ट इसी भाषा में आएंगे',
      urdu: 'ایپ کی زبان سے الگ — الرٹس اس زبان میں آئیں گے',
      bengali: 'অ্যাপের ভাষা থেকে আলাদা — সতর্কতা এই ভাষায় আসবে',
      filipino: 'Hiwalay sa wika ng app — darating ang alert sa wikang ito',
    ),
    'notification_types': _e(
      'Notification types',
      arabic: 'أنواع الإشعارات',
      hindi: 'सूचना प्रकार',
      urdu: 'اطلاعات کی اقسام',
      bengali: 'বিজ্ঞপ্তির ধরন',
      filipino: 'Mga uri ng notification',
    ),
    'type_iqama_title': _e(
      '📋 Iqama expiry warnings',
      arabic: '📋 تحذيرات انتهاء الإقامة',
      hindi: '📋 इकामा समाप्ति चेतावनी',
      urdu: '📋 اقامہ ختم ہونے کی وارننگ',
      bengali: '📋 ইকামা মেয়াদ শেষ সতর্কতা',
      filipino: '📋 Babala sa pag-expire ng Iqama',
    ),
    'type_iqama_subtitle': _e(
      '90, 60, 30, 14, 7, 3, 1 days before expiry',
      arabic: '90، 60، 30، 14، 7، 3، 1 يوماً قبل الانتهاء',
      hindi: 'समाप्ति से 90, 60, 30, 14, 7, 3, 1 दिन पहले',
      urdu: 'ختم ہونے سے 90، 60، 30، 14، 7، 3، 1 دن پہلے',
      bengali: 'মেয়াদ শেষের 90, 60, 30, 14, 7, 3, 1 দিন আগে',
      filipino: '90, 60, 30, 14, 7, 3, 1 araw bago mag-expire',
    ),
    'type_housing_title': _e(
      '🏠 Housing matches',
      arabic: '🏠 تطابق السكن',
      hindi: '🏠 आवास मिलान',
      urdu: '🏠 رہائش میچ',
      bengali: '🏠 বাসস্থান মিল',
      filipino: '🏠 Housing match',
    ),
    'type_housing_subtitle': _e(
      'New listings matching your saved search',
      arabic: 'إعلانات جديدة تطابق بحثك المحفوظ',
      hindi: 'आपकी सहेजी खोज से मेल खाती नई लिस्टिंग',
      urdu: 'آپ کی محفوظ تلاش سے ملتی نئی فہرستیں',
      bengali: 'আপনার সংরক্ষিত অনুসন্ধানের সাথে মিলে নতুন তালিকা',
      filipino: 'Bagong listing na tumutugma sa naka-save na search',
    ),
    'type_rate_title': _e(
      '💰 Exchange rate alerts',
      arabic: '💰 تنبيهات سعر الصرف',
      hindi: '💰 विनिमय दर अलर्ट',
      urdu: '💰 شرح مبادلہ الرٹس',
      bengali: '💰 বিনিময় হার সতর্কতা',
      filipino: '💰 Alert sa exchange rate',
    ),
    'type_rate_subtitle': _e(
      'When your target rate is reached',
      arabic: 'عند الوصول إلى سعرك المستهدف',
      hindi: 'जब आपकी लक्ष्य दर पहुँच जाए',
      urdu: 'جب آپ کی ہدف شرح پہنچ جائے',
      bengali: 'যখন আপনার লক্ষ্য হারে পৌঁছাবে',
      filipino: 'Kapag naabot ang target rate mo',
    ),
    'type_community_reply_title': _e(
      '💬 Community replies',
      arabic: '💬 ردود المجتمع',
      hindi: '💬 समुदाय उत्तर',
      urdu: '💬 کمیونٹی جوابات',
      bengali: '💬 কমিউনিটি উত্তর',
      filipino: '💬 Sagot sa community',
    ),
    'type_community_reply_subtitle': _e(
      'When someone answers your question',
      arabic: 'عندما يجيب أحد على سؤالك',
      hindi: 'जब कोई आपके प्रश्न का उत्तर दे',
      urdu: 'جب کوئی آپ کے سوال کا جواب دے',
      bengali: 'যখন কেউ আপনার প্রশ্নের উত্তর দেয়',
      filipino: 'Kapag may sumagot sa tanong mo',
    ),
    'type_job_title': _e(
      '💼 Job matches',
      arabic: '💼 تطابق الوظائف',
      hindi: '💼 नौकरी मिलान',
      urdu: '💼 نوکری میچ',
      bengali: '💼 চাকরির মিল',
      filipino: '💼 Job match',
    ),
    'type_job_subtitle': _e(
      'New jobs matching your profile',
      arabic: 'وظائف جديدة تطابق ملفك',
      hindi: 'आपकी प्रोफ़ाइल से मेल खाती नई नौकरियाँ',
      urdu: 'آپ کے پروفائل سے ملتی نئی نوکریاں',
      bengali: 'আপনার প্রোফাইলের সাথে মিলে নতুন চাকরি',
      filipino: 'Bagong trabaho na tumutugma sa profile mo',
    ),
    'type_weekly_digest_title': _e(
      '📰 Weekly digest',
      arabic: '📰 ملخص أسبوعي',
      hindi: '📰 साप्ताहिक सारांश',
      urdu: '📰 ہفتہ وار خلاصہ',
      bengali: '📰 সাপ্তাহিক সারাংশ',
      filipino: '📰 Lingguhang digest',
    ),
    'type_weekly_digest_subtitle': _e(
      'Top housing + jobs in your area every Sunday',
      arabic: 'أفضل السكن والوظائف في منطقتك كل أحد',
      hindi: 'हर रविवार आपके क्षेत्र में शीर्ष आवास + नौकरियाँ',
      urdu: 'ہر اتوار آپ کے علاقے میں بہترین رہائش + نوکریاں',
      bengali: 'প্রতি রবিবার আপনার এলাকায় শীর্ষ বাসস্থান + চাকরি',
      filipino: 'Nangungunang housing + trabaho sa lugar mo tuwing Linggo',
    ),
    'type_admin_title': _e(
      '📢 Admin announcements',
      arabic: '📢 إعلانات الإدارة',
      hindi: '📢 एडमिन घोषणाएँ',
      urdu: '📢 ایڈمن اعلانات',
      bengali: '📢 অ্যাডমিন ঘোষণা',
      filipino: '📢 Anunsyo ng admin',
    ),
    'type_admin_subtitle': _e(
      'Qatar law changes, holidays, important updates',
      arabic: 'تغييرات القانون القطري، العطل، تحديثات مهمة',
      hindi: 'कतर कानून परिवर्तन, छुट्टियाँ, महत्वपूर्ण अपडेट',
      urdu: 'قطر قانون تبدیلیاں، تعطیلات، اہم اپڈیٹس',
      bengali: 'কাতার আইন পরিবর্তন, ছুটি, গুরুত্বপূর্ণ আপডেট',
      filipino: 'Pagbabago sa batas ng Qatar, holiday, mahalagang update',
    ),
    'type_bill_title': _e(
      '💳 Bill due reminders',
      arabic: '💳 تذكير موعد الفاتورة',
      hindi: '💳 बिल देय अनुस्मारक',
      urdu: '💳 بل کی یاد دہانی',
      bengali: '💳 বিলের সময়সীমা অনুস্মারক',
      filipino: '💳 Paalala sa bill',
    ),
    'type_bill_subtitle': _e(
      '3 days, 1 day, and day-of bill alerts',
      arabic: 'تنبيهات قبل 3 أيام ويوم واحد ويوم الاستحقاق',
      hindi: '3 दिन, 1 दिन और देय दिन के बिल अलर्ट',
      urdu: '3 دن، 1 دن اور ادائیگی کے دن بل الرٹس',
      bengali: '৩ দিন, ১ দিন এবং বিলের দিন সতর্কতা',
      filipino: '3 araw, 1 araw, at sa araw ng bill',
    ),
    'type_warranty_title': _e(
      '🛡️ Warranty expiring',
      arabic: '🛡️ انتهاء الضمان',
      hindi: '🛡️ वारंटी समाप्त हो रही है',
      urdu: '🛡️ وارنٹی ختم ہو رہی ہے',
      bengali: '🛡️ ওয়ারেন্টি শেষ হচ্ছে',
      filipino: '🛡️ Mag-e-expire ang warranty',
    ),
    'type_warranty_subtitle': _e(
      'Before product warranties expire',
      arabic: 'قبل انتهاء ضمان المنتجات',
      hindi: 'उत्पाद वारंटी समाप्त होने से पहले',
      urdu: 'مصنوعات کی وارنٹی ختم ہونے سے پہلے',
      bengali: 'পণ্যের ওয়ারেন্টি শেষ হওয়ার আগে',
      filipino: 'Bago mag-expire ang warranty ng produkto',
    ),
    'type_events_title': _e(
      '📅 Community events',
      arabic: '📅 فعاليات المجتمع',
      hindi: '📅 समुदाय इवेंट',
      urdu: '📅 کمیونٹی ایونٹس',
      bengali: '📅 কমিউনিটি ইভেন্ট',
      filipino: '📅 Community event',
    ),
    'type_events_subtitle': _e(
      'Event approved, rejected, or new in your group',
      arabic: 'فعالية موافق عليها أو مرفوضة أو جديدة في مجموعتك',
      hindi: 'इवेंट स्वीकृत, अस्वीकृत या आपके समूह में नया',
      urdu: 'ایونٹ منظور، مسترد یا آپ کے گروپ میں نیا',
      bengali: 'ইভেন্ট অনুমোদিত, প্রত্যাখ্যাত বা আপনার গ্রুপে নতুন',
      filipino: 'Event na naaprubahan, tinanggihan, o bago sa grupo mo',
    ),
    'type_lost_found_title': _e(
      '🔍 Lost & Found',
      arabic: '🔍 مفقودات وموجودات',
      hindi: '🔍 Lost & Found',
      urdu: '🔍 Lost & Found',
      bengali: '🔍 হারানো ও পাওয়া',
      filipino: '🔍 Lost & Found',
    ),
    'type_lost_found_subtitle': _e(
      'New posts and resolved items in your groups',
      arabic: 'منشورات جديدة وعناصر محلولة في مجموعاتك',
      hindi: 'आपके समूहों में नई पोस्ट और हल की गई वस्तुएँ',
      urdu: 'آپ کے گروپس میں نئی پوسٹس اور حل شدہ اشیاء',
      bengali: 'আপনার গ্রুপে নতুন পোস্ট এবং সমাধানকৃত আইটেম',
      filipino: 'Bagong post at nalutas na item sa mga grupo mo',
    ),
    'type_breaking_news_title': _e(
      '🚨 Breaking news',
      arabic: '🚨 أخبار عاجلة',
      hindi: '🚨 ताज़ा खबर',
      urdu: '🚨 فوری خبریں',
      bengali: '🚨 ব্রেকিং নিউজ',
      filipino: '🚨 Breaking news',
    ),
    'type_breaking_news_subtitle': _e(
      'High-priority Qatar updates only',
      arabic: 'تحديثات قطر ذات الأولوية العالية فقط',
      hindi: 'केवल उच्च-प्राथमिकता कतर अपडेट',
      urdu: 'صرف اعلیٰ ترجیحی قطر اپڈیٹس',
      bengali: 'শুধু উচ্চ-অগ্রাধিকার কাতার আপডেট',
      filipino: 'Mataas na priyoridad na Qatar update lamang',
    ),
    'type_group_activity_title': _e(
      '👥 Group activity',
      arabic: '👥 نشاط المجموعة',
      hindi: '👥 समूह गतिविधि',
      urdu: '👥 گروپ سرگرمی',
      bengali: '👥 গ্রুপ কার্যকলাপ',
      filipino: '👥 Aktibidad sa grupo',
    ),
    'type_group_activity_subtitle': _e(
      'Digested updates from groups you belong to',
      arabic: 'ملخصات من المجموعات التي تنتمي إليها',
      hindi: 'आपके समूहों से संक्षिप्त अपडेट',
      urdu: 'آپ کے گروپس سے خلاصہ اپڈیٹس',
      bengali: 'আপনার গ্রুপ থেকে সংক্ষিপ্ত আপডেট',
      filipino: 'Buod ng update mula sa mga grupo mo',
    ),
    'type_emergency_title': _e(
      '🆘 Emergency & safety',
      arabic: '🆘 الطوارئ والسلامة',
      hindi: '🆘 आपातकाल और सुरक्षा',
      urdu: '🆘 ایمرجنسی اور حفاظت',
      bengali: '🆘 জরুরি ও নিরাপত্তা',
      filipino: '🆘 Emergency at kaligtasan',
    ),
    'type_emergency_subtitle': _e(
      'Urgent safety alerts (separate alert tone)',
      arabic: 'تنبيهات سلامة عاجلة (نغمة تنبيه منفصلة)',
      hindi: 'अत्यावश्यक सुरक्षा अलर्ट (अलग अलर्ट टोन)',
      urdu: 'فوری حفاظتی الرٹس (الگ الرٹ ٹون)',
      bengali: 'জরুরি নিরাপত্তা সতর্কতা (আলাদা সতর্ক টোন)',
      filipino: 'Urgent safety alert (hiwalay na alert tone)',
    ),
    'quiet_hours': _e(
      'Quiet hours',
      arabic: 'ساعات الهدوء',
      hindi: 'शांत समय',
      urdu: 'خاموش اوقات',
      bengali: 'নীরব সময়',
      filipino: 'Quiet hours',
    ),
    'quiet_hours_hint': _e(
      'No push notifications during these hours (Qatar time)',
      arabic: 'لا إشعارات فورية خلال هذه الساعات (توقيت قطر)',
      hindi: 'इन घंटों में कोई पुश सूचना नहीं (कतर समय)',
      urdu: 'ان اوقات میں کوئی push اطلاع نہیں (قطر وقت)',
      bengali: 'এই সময়ে কোনো push বিজ্ঞপ্তি নয় (কাতার সময়)',
      filipino: 'Walang push notification sa oras na ito (Qatar time)',
    ),
    'quiet_hours_enable': _e(
      '🌙 Enable quiet hours',
      arabic: '🌙 تفعيل ساعات الهدوء',
      hindi: '🌙 शांत समय सक्षम करें',
      urdu: '🌙 خاموش اوقات فعال کریں',
      bengali: '🌙 নীরব সময় চালু করুন',
      filipino: '🌙 I-enable ang quiet hours',
    ),
    'start_time': _e(
      'Start',
      arabic: 'البداية',
      hindi: 'शुरू',
      urdu: 'شروع',
      bengali: 'শুরু',
      filipino: 'Simula',
    ),
    'end_time': _e(
      'End',
      arabic: 'النهاية',
      hindi: 'अंत',
      urdu: 'اختتام',
      bengali: 'শেষ',
      filipino: 'Wakas',
    ),
    'time_am': _e(
      'AM',
      arabic: 'ص',
      hindi: 'AM',
      urdu: 'AM',
      bengali: 'AM',
      filipino: 'AM',
    ),
    'time_pm': _e(
      'PM',
      arabic: 'م',
      hindi: 'PM',
      urdu: 'PM',
      bengali: 'PM',
      filipino: 'PM',
    ),
    'hour_12_am': _e(
      '12 AM',
      arabic: '12 ص',
      hindi: '12 AM',
      urdu: '12 AM',
      bengali: '12 AM',
      filipino: '12 AM',
    ),
    'hour_12_pm': _e(
      '12 PM',
      arabic: '12 م',
      hindi: '12 PM',
      urdu: '12 PM',
      bengali: '12 PM',
      filipino: '12 PM',
    ),
    'hour_am': _e(
      '{h} AM',
      arabic: '{h} ص',
      hindi: '{h} AM',
      urdu: '{h} AM',
      bengali: '{h} AM',
      filipino: '{h} AM',
    ),
    'hour_pm': _e(
      '{h} PM',
      arabic: '{h} م',
      hindi: '{h} PM',
      urdu: '{h} PM',
      bengali: '{h} PM',
      filipino: '{h} PM',
    ),
    'lang_english': _e(
      'English',
      arabic: 'الإنجليزية',
      hindi: 'अंग्रेज़ी',
      urdu: 'انگریزی',
      bengali: 'ইংরেজি',
      filipino: 'English',
    ),
    'lang_urdu': _e(
      'Urdu',
      arabic: 'الأردية',
      hindi: 'उर्दू',
      urdu: 'اردو',
      bengali: 'উর্দু',
      filipino: 'Urdu',
    ),
    'lang_hindi': _e(
      'Hindi',
      arabic: 'الهندية',
      hindi: 'हिंदी',
      urdu: 'ہندی',
      bengali: 'হিন্দি',
      filipino: 'Hindi',
    ),
    'lang_arabic': _e(
      'Arabic',
      arabic: 'العربية',
      hindi: 'अरबी',
      urdu: 'عربی',
      bengali: 'আরবি',
      filipino: 'Arabic',
    ),
    'lang_filipino': _e(
      'Filipino',
      arabic: 'الفلبينية',
      hindi: 'Filipino',
      urdu: 'فلپائنی',
      bengali: 'ফিলিপিনো',
      filipino: 'Filipino',
    ),
    'lang_bengali': _e(
      'Bengali',
      arabic: 'بنغالي',
      hindi: 'बंगाली',
      urdu: 'بنگالی',
      bengali: 'বাংলা',
      filipino: 'Bengali',
    ),
  };
}
