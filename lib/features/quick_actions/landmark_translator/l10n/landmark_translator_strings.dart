/// UI strings for Landmark Translator.
import 'package:flutter/foundation.dart';
import 'package:raabta/core/l10n/app_locale.dart';
import 'package:raabta/core/l10n/locale_catalog_coverage.dart';

abstract final class LandmarkTranslatorStrings {
  static const supportedLocales = AppLocale.supportedLocales;

  static String t(String key, [String locale = 'English']) {
    final map = _strings[key];
    if (map == null) return key;
    return map[locale] ?? map['English'] ?? key;
  }

  /// Exposed for catalog parity regression tests only.
  @visibleForTesting
  static Map<String, Set<String>> get localeCoverageReport =>
      buildLocaleCoverageReport(
        catalog: Map<String, Map<String, String>>.from(_strings),
        supportedLocales: supportedLocales,
      );

  static String inputHint(String locale) => t('input_hint', locale);

  static const _strings = {
    'title': {
      'English': 'Landmark Translator',
      'Arabic': 'مترجم المعالم',
      'Hindi': 'लैंडमार्क अनुवादक',
      'Urdu': 'لینڈمارک مترجم',
      'Malayalam': 'Landmark Translator',
      'Nepali': 'Landmark Translator',
      'Bengali': 'ল্যান্ডমার্ক অনুবাদক',
      'Filipino': 'Landmark Translator',
    },
    'clear': {
      'English': 'Clear',
      'Arabic': 'مسح',
      'Hindi': 'साफ़ करें',
      'Urdu': 'صاف کریں',
      'Filipino': 'Clear',
      'Bengali': 'মুছুন',
    },
    'saved_destinations': {
      'English': 'Saved Destinations',
      'Arabic': 'وجهات محفوظة',
      'Hindi': 'सहेजे गए स्थान',
      'Urdu': 'محفوظ مقامات',
      'Filipino': 'Saved Destinations',
      'Bengali': 'সংরক্ষিত গন্তব্য',
    },
    'how_to_title': {
      'English': 'How to use',
      'Arabic': 'كيفية الاستخدام',
      'Hindi': 'कैसे उपयोग करें',
      'Urdu': 'کیسے استعمال کریں',
      'Filipino': 'Paano gamitin',
      'Bengali': 'কীভাবে ব্যবহার করবেন',
    },
    'how_to_body': {
      'English':
          'Describe your location in your language using landmarks. RAABTA translates to Gulf Arabic and reads it aloud — for Karwa taxis, ride apps, delivery drivers, or anyone who needs directions without a street address.',
      'Arabic':
          'صف موقعك بلغتك باستخدام معالم. يترجم RAABTA إلى عربية خليجية وينطقها — لتكسي كروه، تطبيقات التوصيل، أو أي سائق.',
      'Hindi':
          'अपनी भाषा में लैंडमार्क से पता बताएँ। RAABTA खाड़ी अरबी में अनुवाद करके बोलता है — Karwa टैक्सी, राइड ऐप, डिलीवरी या किसी भी ड्राइवर के लिए।',
      'Urdu':
          'اپنی زبان میں لینڈمارک سے پتہ بتائیں۔ RAABTA خلیجی عربی میں ترجمہ کر کے سناتا ہے — Karwa، ride apps، delivery یا کسی بھی ڈرائیور کے لیے۔',
      'Filipino':
          'Ilarawan ang lokasyon sa iyong wika gamit ang landmarks. Isasalin ng RAABTA sa Gulf Arabic — para sa Karwa, ride apps, delivery, o kahit sinong driver.',
      'Bengali':
          'ল্যান্ডমার্ক দিয়ে আপনার ভাষায় ঠিকানা বলুন। RAABTA উপসাগরীয় আরবিতে অনুবাদ করে শোনায় — Karwa, ride app, ডেলিভারি বা যেকোনো চালকের জন্য।',
    },
    'input_label': {
      'English': 'Your address or landmark',
      'Arabic': 'عنوانك أو معلم',
      'Hindi': 'आपका पता या लैंडमार्क',
      'Urdu': 'آپ کا پتہ یا لینڈمارک',
      'Filipino': 'Address o landmark mo',
      'Bengali': 'আপনার ঠিকানা বা ল্যান্ডমার্ক',
    },
    'input_hint': {
      'English':
          'e.g. Villa 23, opposite Lulu Hypermarket, Street 12, near mosque, Al Khor',
      'Arabic':
          'مثال: فيلا ٢٣، مقابل اللولو، شارع ١٢، قرب المسجد، الخور',
      'Hindi':
          'जैसे: Villa 23, Lulu Hypermarket के सामने, Street 12, masjid ke paas, Al Khor',
      'Urdu':
          'مثال: Villa 23, Lulu Hypermarket کے سامنے, Street 12, masjid ke qareeb, Al Khor',
      'Filipino':
          'hal. Villa 23, tapat ng Lulu, Street 12, malapit sa mosque, Al Khor',
      'Bengali':
          'যেমন: Villa 23, Lulu Hypermarket-এর বিপরীতে, Street 12, mosque-এর কাছে, Al Khor',
    },
    'listening': {
      'English': 'Listening… speak your address',
      'Arabic': 'يستمع… تكلم بعنوانك',
      'Hindi': 'सुन रहा है… अपना पता बोलें',
      'Urdu': 'سن رہا ہے… اپنا پتہ بولیں',
      'Filipino': 'Nakikinig… sabihin ang address',
      'Bengali': 'শুনছে… ঠিকানা বলুন',
    },
    'quick_landmarks': {
      'English': 'Quick add Qatar landmarks:',
      'Arabic': 'إضافة معالم قطر:',
      'Hindi': 'कतर के लैंडमार्क जोड़ें:',
      'Urdu': 'قطر کے لینڈمارک شامل کریں:',
      'Filipino': 'Magdagdag ng Qatar landmarks:',
      'Bengali': 'কatar ল্যান্ডমার্ক যোগ করুন:',
    },
    'error_empty': {
      'English': 'Please enter your address or landmark description.',
      'Arabic': 'أدخل عنوانك أو وصف المعلم.',
      'Hindi': 'कृपया पता या लैंडमार्क दर्ज करें।',
      'Urdu': 'براہ کرم پتہ یا لینڈمارک درج کریں۔',
      'Filipino': 'Ilagay ang address o landmark.',
      'Bengali': 'ঠিকানা বা ল্যান্ডমার্ক লিখুন।',
    },
    'error_translate': {
      'English': 'Translation failed. Check your connection and try again.',
      'Arabic': 'فشل الترجمة. تحقق من الاتصال.',
      'Hindi': 'अनुवाद विफल। कनेक्शन जाँचें।',
      'Urdu': 'ترجمہ ناکام۔ کنکشن چیک کریں۔',
      'Filipino': 'Nabigo ang translation. Check connection.',
      'Bengali': 'অনুবাদ ব্যর্থ। সংযোগ পরীক্ষা করুন।',
    },
    'translate_btn': {
      'English': 'Translate to Arabic',
      'Arabic': 'ترجم إلى العربية',
      'Hindi': 'अरबी में अनुवाद करें',
      'Urdu': 'عربی میں ترجمہ کریں',
      'Filipino': 'Isalin sa Arabic',
      'Bengali': 'আরবিতে অনুবাদ',
    },
    'translating_btn': {
      'English': 'Translating with AI…',
      'Arabic': 'جاري الترجمة…',
      'Hindi': 'AI से अनुवाद…',
      'Urdu': 'AI سے ترجمہ…',
      'Filipino': 'Nagsasalin…',
      'Bengali': 'অনুবাদ হচ্ছে…',
    },
    'gps_label': {
      'English': 'GPS Description',
      'Arabic': 'وصف GPS',
      'Hindi': 'GPS विवरण',
      'Urdu': 'GPS تفصیل',
      'Filipino': 'GPS Description',
      'Bengali': 'GPS বিবরণ',
    },
    'arabic_for_driver': {
      'English': 'Arabic for your driver',
      'Arabic': 'العربية للسائق',
      'Hindi': 'ड्राइवर के लिए अरबी',
      'Urdu': 'ڈرائیور کے لیے عربی',
      'Filipino': 'Arabic para sa driver',
      'Bengali': 'চালকের জন্য আরবি',
    },
    'confidence_high': {
      'English': 'High confidence',
      'Arabic': 'ثقة عالية',
      'Hindi': 'उच्च विश्वास',
      'Urdu': 'اعلیٰ اعتماد',
      'Filipino': 'High confidence',
      'Bengali': 'উচ্চ আস্থা',
    },
    'confidence_medium': {
      'English': 'Medium confidence',
      'Arabic': 'ثقة متوسطة',
      'Hindi': 'मध्यम विश्वास',
      'Urdu': 'درمیانہ اعتماد',
      'Filipino': 'Medium confidence',
      'Bengali': 'মাঝারি আস্থা',
    },
    'confidence_low': {
      'English': 'Low confidence — verify with driver',
      'Arabic': 'ثقة منخفضة — تأكد مع السائق',
      'Hindi': 'कम विश्वास — ड्राइवर से पुष्टि करें',
      'Urdu': 'کم اعتماد — ڈرائیور سے تصدیق کریں',
      'Filipino': 'Low confidence — verify sa driver',
      'Bengali': 'কম আস্থা — চালকের সাথে যাচাই করুন',
    },
    'play_driver': {
      'English': '▶  Play for Driver',
      'Arabic': '▶  تشغيل للسائق',
      'Hindi': '▶  ड्राइवर को सुनाएँ',
      'Urdu': '▶  ڈرائیور کو سنائیں',
      'Filipino': '▶  Play for Driver',
      'Bengali': '▶  চালককে শুনান',
    },
    'stop': {
      'English': 'Stop',
      'Arabic': 'إيقاف',
      'Hindi': 'रोकें',
      'Urdu': 'روکیں',
      'Filipino': 'Stop',
      'Bengali': 'থামুন',
    },
    'copied_arabic': {
      'English': 'Arabic address copied to clipboard',
      'Arabic': 'تم نسخ العنوان العربي',
      'Hindi': 'अरबी पता कॉपी हुआ',
      'Urdu': 'عربی پتہ کاپی ہو گیا',
      'Filipino': 'Nakopya ang Arabic address',
      'Bengali': 'আরবি ঠিকানা কপি হয়েছে',
    },
    'nav_rides_btn': {
      'English': 'Maps & rides',
      'Arabic': 'الخرائط والتوصيل',
      'Hindi': 'Maps और rides',
      'Urdu': 'Maps اور rides',
      'Filipino': 'Maps & rides',
      'Bengali': 'Maps ও rides',
    },
    'save_btn': {
      'English': 'Save',
      'Arabic': 'حفظ',
      'Hindi': 'सहेजें',
      'Urdu': 'محفوظ',
      'Filipino': 'Save',
      'Bengali': 'সংরক্ষণ',
    },
    'nav_hint': {
      'English':
          'Open Maps, Uber if installed, or copy Arabic for Careem, Karwa, delivery & WhatsApp',
      'Arabic':
          'افتح الخرائط أو Uber أو انسخ العربية لأي تطبيق',
      'Hindi':
          'Maps, Uber खोलें, या Careem/Karwa/WhatsApp के लिए Arabic कॉपी करें',
      'Urdu':
          'Maps، Uber کھولیں، یا Careem/Karwa/WhatsApp کے لیے Arabic کاپی کریں',
      'Filipino':
          'Buksan ang Maps, Uber, o kopyahin ang Arabic para sa anumang app',
      'Bengali':
          'Maps, Uber খুলুন, অথবা যেকোনো app-এর জন্য Arabic কপি করুন',
    },
    'show_driver_hint': {
      'English': 'Show this screen to your driver or tap Play',
      'Arabic': 'اعرض الشاشة للسائق أو اضغط تشغيل',
      'Hindi': 'ड्राइवर को स्क्रीन दिखाएँ या Play दबाएँ',
      'Urdu': 'ڈرائیور کو اسکرین دکھائیں یا Play دبائیں',
      'Filipino': 'Ipakita sa driver o i-tap ang Play',
      'Bengali': 'চালককে স্ক্রিন দেখান বা Play চাপুন',
    },
    'voice_unavailable': {
      'English': 'Voice input not available on this device.',
      'Arabic': 'الإدخال الصوتي غير متاح.',
      'Hindi': 'वॉइस इनपुट उपलब्ध नहीं।',
      'Urdu': 'وائس ان پٹ دستیاب نہیں۔',
      'Filipino': 'Hindi available ang voice input.',
      'Bengali': 'ভয়েস ইনপুট unavailable।',
    },
    'destination_saved': {
      'English': 'Destination saved!',
      'Arabic': 'تم حفظ الوجهة!',
      'Hindi': 'स्थान सहेजा गया!',
      'Urdu': 'منزل محفوظ!',
      'Filipino': 'Na-save ang destination!',
      'Bengali': 'গন্তব্য সংরক্ষিত!',
    },
    'arabic_copied_apps': {
      'English':
          'Arabic copied — paste into any ride app, delivery chat, or WhatsApp',
      'Arabic': 'تم النسخ — الصق في أي تطبيق',
      'Hindi': 'Arabic कॉपी — किसी भी ride/delivery app में पेस्ट करें',
      'Urdu': 'Arabic کاپی — کisi bhi app میں پیسٹ کریں',
      'Filipino': 'Nakopya — i-paste sa ride o delivery app',
      'Bengali': 'Arabic কপি — যেকোনো app-এ পেস্ট করুন',
    },
    'nav_sheet_title': {
      'English': 'Navigation & rides',
      'Arabic': 'الملاحة والتوصيل',
      'Hindi': 'Navigation & rides',
      'Urdu': 'Navigation & rides',
      'Filipino': 'Navigation & rides',
      'Bengali': 'Navigation & rides',
    },
    'open_maps': {
      'English': 'Open in Google Maps',
      'Arabic': 'فتح في خرائط Google',
      'Hindi': 'Google Maps में खोलें',
      'Urdu': 'Google Maps میں کھولیں',
      'Filipino': 'Buksan sa Google Maps',
      'Bengali': 'Google Maps-এ খুলুন',
    },
    'open_uber': {
      'English': 'Open in Uber',
      'Arabic': 'فتح في Uber',
      'Hindi': 'Uber में खोलें',
      'Urdu': 'Uber میں کھولیں',
      'Filipino': 'Buksan sa Uber',
      'Bengali': 'Uber-এ খুলুন',
    },
    'copy_for_ride_apps': {
      'English': 'Copy Arabic for ride & delivery apps',
      'Arabic': 'نسخ العربية للتطبيقات',
      'Hindi': 'Ride/delivery apps के लिए Arabic कॉपी',
      'Urdu': 'Ride apps کے لیے Arabic کاپی',
      'Filipino': 'Kopyahin ang Arabic para sa apps',
      'Bengali': 'Ride app-এর জন্য Arabic কপি',
    },
    'sign_in_to_save': {
      'English': 'Sign in to save destinations',
      'Arabic': 'سجّل الدخول للحفظ',
      'Hindi': 'सहेजने के लिए साइन इन करें',
      'Urdu': 'محفوظ کرنے کے لیے سائن ان کریں',
      'Filipino': 'Mag-sign in para mag-save',
      'Bengali': 'সংরক্ষণে সাইন ইন করুন',
    },
    'save_sheet_title': {
      'English': 'Save as Destination',
      'Arabic': 'حفظ كوجهة',
      'Hindi': 'गंतव्य के रूप में सहेजें',
      'Urdu': 'منزل کے طور پر محفوظ',
      'Filipino': 'Save as Destination',
      'Bengali': 'গন্তব্য হিসেবে সংরক্ষণ',
    },
    'choose_label': {
      'English': 'Choose a label',
      'Arabic': 'اختر تسمية',
      'Hindi': 'लेबल चुनें',
      'Urdu': 'لیبل منتخب کریں',
      'Filipino': 'Pumili ng label',
      'Bengali': 'লেবেল বেছে নিন',
    },
    'save_destination_btn': {
      'English': 'Save Destination',
      'Arabic': 'حفظ الوجهة',
      'Hindi': 'गंतव्य सहेजें',
      'Urdu': 'منزل محفوظ کریں',
      'Filipino': 'Save Destination',
      'Bengali': 'গন্তব্য সংরক্ষণ',
    },
    'area_label': {
      'English': 'Area',
      'Arabic': 'المنطقة',
      'Hindi': 'क्षेत्र',
      'Urdu': 'علاقہ',
      'Filipino': 'Area',
      'Bengali': 'এলাকা',
    },
    'tts_unavailable': {
      'English': 'Arabic audio unavailable on this device — show the text to your driver',
      'Arabic': 'الصوت غير متاح — اعرض النص للسائق',
      'Hindi': 'अरबी ऑडियो उपलब्ध नहीं — ड्राइवर को टेक्स्ट दिखाएँ',
      'Urdu': 'عربی آڈیو دستیاب نہیں — ڈرائیور کو متن دکھائیں',
      'Filipino': 'Hindi available ang Arabic audio — ipakita ang text',
      'Bengali': 'আরবি অডিও unavailable — চালককে টেক্সট দেখান',
    },
    'voice_mobile_only': {
      'English': 'Voice input is available on iPhone and Android only',
      'Arabic': 'الإدخال الصوتي متاح على iPhone وAndroid فقط',
      'Hindi': 'वॉइस इनपुट केवल iPhone और Android पर',
      'Urdu': 'وائس ان پٹ صرف iPhone اور Android پر',
      'Filipino': 'Voice input sa iPhone at Android lang',
      'Bengali': 'ভয়েস ইনপুট শুধু iPhone ও Android-এ',
    },
    'offline_cache_banner': {
      'English': 'Showing your last saved translation — connection unavailable',
      'Arabic': 'عرض آخر ترجمة محفوظة — لا يوجد اتصال',
      'Hindi': 'पिछला सहेजा अनुवाद दिखाया जा रहा है — कनेक्शन नहीं',
      'Urdu': 'آخری محفوظ ترجمہ — کنکشن نہیں',
      'Filipino': 'Huling na-save na translation — walang connection',
      'Bengali': 'সংরক্ষিত অনুবাদ দেখানো হচ্ছে — সংযোগ নেই',
    },
    'shared_cache_banner': {
      'English': 'Instant translation from shared cache — no AI call used',
      'Arabic': 'ترجمة فورية من ذاكرة مشتركة — بدون استدعاء AI',
      'Hindi': 'Shared cache से तुरंत अनुवाद — कोई AI call नहीं',
      'Urdu': 'Shared cache سے فوری ترجمہ — AI call نہیں',
      'Filipino': 'Mula sa shared cache — walang AI call',
      'Bengali': 'Shared cache থেকে তাৎক্ষণিক — কোনো AI call নয়',
    },
    'companion_translate_title': {
      'English': 'Live translation',
      'Arabic': 'ترجمة مباشرة',
      'Hindi': 'Live translation',
      'Urdu': 'Live translation',
      'Filipino': 'Live translation',
      'Bengali': 'Live translation',
    },
    'quick_translate_shortcuts': {
      'English': 'Quick translate shortcuts:',
      'Arabic': 'اختصارات ترجمة سريعة:',
      'Hindi': 'Quick translate shortcuts:',
      'Urdu': 'Quick translate shortcuts:',
      'Filipino': 'Quick translate shortcuts:',
      'Bengali': 'Quick translate shortcuts:',
    },
    'ai_limit_reached': {
      'English':
          'Free AI translation limit reached this month. Use the phrasebook or try again next month.',
      'Arabic':
          'تم الوصول لحد الترجمة المجانية هذا الشهر. استخدم العبارات أو حاول الشهر القادم.',
      'Hindi':
          'Is mahine ki free AI limit poori ho gayi. Phrasebook use karein ya agle mahine try karein.',
      'Urdu':
          'Is mahine ki free AI limit khatam. Phrases use karein ya agle mahine try karein.',
      'Filipino':
          'Naabot na ang free AI limit ngayong buwan. Gamitin ang phrasebook o subukan sa susunod na buwan.',
      'Bengali':
          'এই মাসের free AI সীমা শেষ। phrasebook ব্যবহার করুন বা পরের মাসে চেষ্টা করুন।',
    },
    'ai_remaining': {
      'English': 'AI translations left this month',
      'Arabic': 'ترجمات AI متبقية هذا الشهر',
      'Hindi': 'Is mahine bachi AI translations',
      'Urdu': 'Is mahine bachi AI translations',
      'Filipino': 'Natitirang AI translations ngayong buwan',
      'Bengali': 'এই মাসে বাকি AI translations',
    },
    'error_save': {
      'English': 'Could not save destination',
      'Arabic': 'تعذّر حفظ الوجهة',
      'Hindi': 'गंतव्य सहेज नहीं सके',
      'Urdu': 'منزل محفوظ نہیں ہو سکی',
      'Filipino': 'Hindi ma-save ang destination',
      'Bengali': 'গন্তব্য সংরক্ষণ ব্যর্থ',
    },
  };
}
