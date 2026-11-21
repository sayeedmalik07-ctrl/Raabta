/// UI strings for Daily Utilities batch (USSD, phrases).
import 'package:flutter/foundation.dart';
import 'package:raabta/core/l10n/app_locale.dart';
import 'package:raabta/core/l10n/locale_catalog_coverage.dart';

abstract final class DailyUtilitiesStrings {
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

  static const _strings = {
    'ussd_title': {
      'English': 'SIM USSD Codes',
      'Arabic': 'أكواد USSD',
      'Hindi': 'SIM USSD कोड',
      'Urdu': 'SIM USSD کوڈز',
      'Filipino': 'SIM USSD Codes',
      'Bengali': 'SIM USSD কোড',
    },
    'ussd_subtitle': {
      'English': 'Ooredoo & Vodafone Qatar — verify on operator site if a code changes',
      'Arabic': 'أوريدoo وفودافون قطر — تحقق من موقع المشغل إذا تغيّر الكود',
      'Hindi': 'Ooredoo और Vodafone Qatar — कोड बदले तो ऑपरेटर साइट पर जाँचें',
      'Urdu': 'Ooredoo اور Vodafone Qatar — کوڈ بدلے تو آپریٹر سائٹ چیک کریں',
      'Filipino': 'Ooredoo at Vodafone Qatar — i-verify sa operator site kung magbago ang code',
      'Bengali': 'Ooredoo ও Vodafone Qatar — কোড বদলালে অপারেটর সাইটে যাচাই করুন',
    },
    'search_hint': {
      'English': 'Search balance, roaming, recharge…',
      'Arabic': 'ابحث عن الرصيد، التجوال، الشحن…',
      'Hindi': 'बैलेंस, रोमिंग, रिचार्ज खोजें…',
      'Urdu': 'بیلنس، رومنگ، ریچارج تلاش…',
      'Filipino': 'Hanapin ang balance, roaming, recharge…',
      'Bengali': 'ব্যালেন্স, রোমিং, রিচার্জ খুঁজুন…',
    },
    'copy': {
      'English': 'Copy',
      'Arabic': 'نسخ',
      'Hindi': 'कॉपी',
      'Urdu': 'کاپی',
      'Filipino': 'Kopyahin',
      'Bengali': 'কপি',
    },
    'dial': {
      'English': 'Dial',
      'Arabic': 'اتصال',
      'Hindi': 'डायल',
      'Urdu': 'ڈائل',
      'Filipino': 'I-dial',
      'Bengali': 'ডায়াল',
    },
    'dial_hint': {
      'English': 'Opens your phone dialer — you may need to press Call',
      'Arabic': 'يفتح لوحة الاتصال — قد تحتاج للضغط على اتصال',
      'Hindi': 'फ़ोन डायलर खोलता है — Call दबाना पड़ सकता है',
      'Urdu': 'فون ڈائلر کھولتا ہے — Call دبانا پڑ سکتا ہے',
      'Filipino': 'Bubuksan ang dialer — baka kailangan pindutin ang Call',
      'Bengali': 'ডায়ালার খোলে — Call চাপতে হতে পারে',
    },
    'copied': {
      'English': 'Code copied',
      'Arabic': 'تم نسخ الرمز',
      'Hindi': 'कोड कॉपी हुआ',
      'Urdu': 'کوڈ کاپی ہو گیا',
      'Filipino': 'Nakopya ang code',
      'Bengali': 'কোড কপি হয়েছে',
    },
    'phrases_title': {
      'English': 'Arabic Phrases',
      'Arabic': 'عبارات عربية',
      'Hindi': 'अरबी वाक्य',
      'Urdu': 'عربی جملے',
      'Filipino': 'Arabic Phrases',
      'Bengali': 'আরবি বাক্য',
    },
    'phrases_subtitle': {
      'English': 'Everyday Qatar Arabic — meaning shown in your app language',
      'Arabic': 'عربية يومية في قطر — المعنى بلغتك',
      'Hindi': 'कतर की रोज़मर्रा अरबी — अर्थ आपकी भाषा में',
      'Urdu': 'قطر کی روزمرہ عربی — معنی آپ کی زبان میں',
      'Filipino': 'Pang-araw-araw na Arabic sa Qatar — sa wika mo ang kahulugan',
      'Bengali': 'কatar-এর দৈনন্দিন আরবি — অর্থ আপনার ভাষায়',
    },
    'phrases_dialect_note': {
      'English':
          'Gulf/Qatari colloquial Arabic — confirm dialect approach with native review before marketing',
      'Arabic': 'لهجة خليجية/قطرية — تحتاج مراجعة قبل النشر',
      'Hindi': 'खाड़ी/कतरी बोली — मूल वक्ता समीक्षा अनुशंसित',
      'Urdu': 'خلیجی/قطری بولی — مقامی جائزے کی سفارش',
      'Filipino': 'Gulf/Qatari colloquial — kailangan ng native review',
      'Bengali': 'উপসাগরীয়/কatarি উপভাষা — স্থানীয় 검토 প্রয়োজন',
    },
    'phrases_search_hint': {
      'English': 'Search phrases, transliteration, meaning…',
      'Arabic': 'ابحث في العبارات…',
      'Hindi': 'वाक्य, उच्चारण, अर्थ खोजें…',
      'Urdu': 'جملے، تلفظ، معنی تلاش…',
      'Filipino': 'Hanapin ang phrase, bigkas, kahulugan…',
      'Bengali': 'বাক্য, উচ্চারণ, অর্থ খুঁজুন…',
    },
    'phrases_count_label': {
      'English': 'phrases',
      'Arabic': 'عبارة',
      'Hindi': 'वाक्य',
      'Urdu': 'جملے',
      'Filipino': 'phrases',
      'Bengali': 'বাক্য',
    },
    'phrases_no_results': {
      'English': 'No phrases match your search',
      'Arabic': 'لا توجد عبارات مطابقة',
      'Hindi': 'कोई वाक्य नहीं मिला',
      'Urdu': 'کوئی جملہ نہیں ملا',
      'Filipino': 'Walang tumugmang phrase',
      'Bengali': 'কোনো বাক্য পাওয়া যায়নি',
    },
    'review_pending': {
      'English': 'PENDING REVIEW',
      'Arabic': 'بانتظار المراجعة',
      'Hindi': 'समीक्षा लंबित',
      'Urdu': 'جائزہ باقی',
      'Filipino': 'PENDING REVIEW',
      'Bengali': 'পর্যালোচনা বাকি',
    },
    'audio_unavailable': {
      'English': 'Audio unavailable',
      'Arabic': 'الصوت غير متاح',
      'Hindi': 'ऑडियो उपलब्ध नहीं',
      'Urdu': 'آڈیو دستیاب نہیں',
      'Filipino': 'Hindi available ang audio',
      'Bengali': 'অডিও unavailable',
    },
    'favorites': {
      'English': 'Favorites',
      'Arabic': 'المفضلة',
      'Hindi': 'पसंदीदा',
      'Urdu': 'پسندیدہ',
      'Filipino': 'Mga Paborito',
      'Bengali': 'পছন্দের',
    },
    'play_audio': {
      'English': 'Listen',
      'Arabic': 'استماع',
      'Hindi': 'सुनें',
      'Urdu': 'سنیں',
      'Filipino': 'Pakinggan',
      'Bengali': 'শুনুন',
    },
    'companion_title': {
      'English': 'Arabic Companion',
      'Arabic': 'رفيق العربية',
      'Hindi': 'Arabic Companion',
      'Urdu': 'Arabic Companion',
      'Filipino': 'Arabic Companion',
      'Bengali': 'Arabic Companion',
    },
    'companion_translate_cta_title': {
      'English': 'Translate something else',
      'Arabic': 'ترجم شيئاً آخر',
      'Hindi': 'कुछ और अनुवाद करें',
      'Urdu': 'کچھ اور ترجمہ کریں',
      'Filipino': 'Isalin ang iba pa',
      'Bengali': 'অন্য কিছু অনুবাদ করুন',
    },
    'companion_translate_cta_subtitle': {
      'English':
          'Free-text Gulf Arabic for taxis, delivery & directions — AI when phrasebook is not enough',
      'Arabic':
          'عربية خليجية للتكسي والتوصيل — ذكاء اصطناعي عندما لا تكفي العبارات',
      'Hindi':
          'Taxi, delivery & directions ke liye Gulf Arabic — jab phrasebook kaafi na ho',
      'Urdu':
          'Taxi, delivery aur rasta ke liye Khaleeji Arabic — jab phrases kaafi na hon',
      'Filipino':
          'Gulf Arabic para sa taxi, delivery at direksyon — AI kapag kulang ang phrasebook',
      'Bengali':
          'ট্যাক্সি, ডেলিভারি ও দিকনির্দেশনার জন্য Gulf Arabic — phrasebook যখন যথেষ্ট নয়',
    },
    'companion_back_categories': {
      'English': 'All categories',
      'Arabic': 'كل الفئات',
      'Hindi': 'सभी श्रेणियाँ',
      'Urdu': 'تمام زمرے',
      'Filipino': 'Lahat ng kategorya',
      'Bengali': 'সব বিভাগ',
    },
  };
}
