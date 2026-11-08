import 'package:flutter/foundation.dart';
import 'package:raabta/core/l10n/app_locale.dart';
import 'package:raabta/core/l10n/locale_catalog_coverage.dart';
import 'package:raabta/core/l10n/locale_catalog_entry.dart';
import 'package:raabta/screens/profile/progressive_profile_flow.dart';

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

abstract final class ProgressiveProfileStrings {
  ProgressiveProfileStrings._();

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

  static String stepLabelKey(ProgressiveProfileField field) {
    return switch (field) {
      ProgressiveProfileField.profession => 'step_label_profession',
      ProgressiveProfileField.nationality => 'step_label_nationality',
      ProgressiveProfileField.preferredArea => 'step_label_preferred_area',
    };
  }

  static String questionKey(ProgressiveProfileField field) {
    return switch (field) {
      ProgressiveProfileField.profession => 'question_profession',
      ProgressiveProfileField.nationality => 'question_nationality',
      ProgressiveProfileField.preferredArea => 'question_preferred_area',
    };
  }

  static String hintKey(ProgressiveProfileField field) {
    return switch (field) {
      ProgressiveProfileField.profession => 'hint_profession',
      ProgressiveProfileField.nationality => 'hint_nationality',
      ProgressiveProfileField.preferredArea => 'hint_preferred_area',
    };
  }

  @visibleForTesting
  static Map<String, Set<String>> get localeCoverageReport =>
      buildLocaleCoverageReport(
        catalog: _catalog,
        supportedLocales: supportedLocales,
        fillMissingWithEnglish: false,
      );

  static final _catalog = <String, Map<String, String>>{
    'flow_step_of': _e(
      'Step {current} of {total}',
      arabic: 'الخطوة {current} من {total}',
      hindi: 'चरण {current} / {total}',
      urdu: 'مرحلہ {current} از {total}',
      bengali: 'ধাপ {current} / {total}',
      filipino: 'Hakbang {current} ng {total}',
      malayalam: 'ഘട്ടം {current} / {total}',
      nepali: 'चरण {current} / {total}',
      tamil: 'படி {current} / {total}',
    ),
    'step_label_profession': _e(
      'Profession',
      arabic: 'المهنة',
      hindi: 'पेशा',
      urdu: 'پیشہ',
      bengali: 'পেশা',
      filipino: 'Propesyon',
      malayalam: 'തൊഴിൽ',
      nepali: 'पेशा',
      tamil: 'தொழில்',
    ),
    'step_label_nationality': _e(
      'Nationality',
      arabic: 'الجنسية',
      hindi: 'राष्ट्रीयता',
      urdu: 'قومیت',
      bengali: 'জাতীয়তা',
      filipino: 'Nasyonalidad',
      malayalam: 'ദേശीयത',
      nepali: 'राष्ट्रियता',
      tamil: 'தேசியம்',
    ),
    'step_label_preferred_area': _e(
      'Preferred area',
      arabic: 'المنطقة المفضلة',
      hindi: 'पसंदीदा क्षेत्र',
      urdu: 'پسندیدہ علاقہ',
      bengali: 'পছন্দের এলাকা',
      filipino: 'Preferred area',
      malayalam: 'ഇഷ്ടപ്പെട്ട പ്രദേശം',
      nepali: 'मनपर्ने क्षेत्र',
      tamil: 'விருப்பமான பகுதி',
    ),
    'question_profession': _e(
      'What do you do in Qatar?',
      arabic: 'ما مهنتك في قطر؟',
      hindi: 'क़तर में आप क्या करते हैं?',
      urdu: 'قطر میں آپ کیا کرتے ہیں؟',
      bengali: 'Qatar-এ আপনি কী করেন?',
      filipino: 'Ano ang ginagawa mo sa Qatar?',
      malayalam: 'Qatar-ൽ നിങ്ങൾ എന്താണ് ചെയ്യുന്നത്?',
      nepali: 'Qatar मा तपाईं के गर्नुहुन्छ?',
      tamil: 'Qatar-ல் நீங்கள் என்ன செய்கிறீர்கள்?',
    ),
    'question_nationality': _e(
      'What is your nationality?',
      arabic: 'ما جنسيتك؟',
      hindi: 'आपकी राष्ट्रीयता क्या है?',
      urdu: 'آپ کی قومیت کیا ہے؟',
      bengali: 'আপনার জাতীয়তা কী?',
      filipino: 'Ano ang iyong nasyonalidad?',
      malayalam: 'നിങ്ങളുടെ ദേശीयത എന്താണ്?',
      nepali: 'तपाईंको राष्ट्रियता के हो?',
      tamil: 'உங்கள் தேசியம் என்ன?',
    ),
    'question_preferred_area': _e(
      'Which area in Qatar do you prefer?',
      arabic: 'ما المنطقة المفضلة لديك في قطر؟',
      hindi: 'क़तर में आप कौन-सा क्षेत्र पसंद करते हैं?',
      urdu: 'قطر میں آپ کون سا علاقہ پسند کرتے ہیں؟',
      bengali: 'Qatar-এ আপনি কোন এলাকা পছন্দ করেন?',
      filipino: 'Aling area sa Qatar ang gusto mo?',
      malayalam: 'Qatar-ൽ നിങ്ങൾ ഏത് പ്രദേശമാണ് prefer ചെയ്യുന്നത്?',
      nepali: 'Qatar मा तपाईं कुन क्षेत्र रुचाउनुहुन्छ?',
      tamil: 'Qatar-ல் எந்த பகுதியை விரும்புகிறீர்கள்?',
    ),
    'hint_profession': _e(
      'e.g. Engineer, Nurse, Driver',
      arabic: 'مثال: مهندس، ممرض، سائق',
      hindi: 'उदा. इंजीनियर, नर्स, ड्राइवर',
      urdu: 'مثال: انجینئر، نرس، ڈرائیور',
      bengali: 'যেমন: Engineer, Nurse, Driver',
      filipino: 'hal. Engineer, Nurse, Driver',
      malayalam: 'ഉദാ. Engineer, Nurse, Driver',
      nepali: 'जस्तै Engineer, Nurse, Driver',
      tamil: 'எ.கா. Engineer, Nurse, Driver',
    ),
    'hint_nationality': _e(
      'e.g. Indian, Filipino, Nepali',
      arabic: 'مثال: هندي، فلبيني، نيبالي',
      hindi: 'उदा. भारतीय, फिलिपino, नेपाली',
      urdu: 'مثال: بھارتی، فلپini، نیپالی',
      bengali: 'যেমন: Indian, Filipino, Nepali',
      filipino: 'hal. Indian, Filipino, Nepali',
      malayalam: 'ഉദാ. Indian, Filipino, Nepali',
      nepali: 'जस्तै Indian, Filipino, Nepali',
      tamil: 'எ.கா. Indian, Filipino, Nepali',
    ),
    'hint_preferred_area': _e(
      'e.g. Doha, Al Wakrah, Lusail',
      arabic: 'مثال: الدوحة، الوكرة، لوسيل',
      hindi: 'उदा. Doha, Al Wakrah, Lusail',
      urdu: 'مثال: Doha, Al Wakrah, Lusail',
      bengali: 'যেমন: Doha, Al Wakrah, Lusail',
      filipino: 'hal. Doha, Al Wakrah, Lusail',
      malayalam: 'ഉദാ. Doha, Al Wakrah, Lusail',
      nepali: 'जस्तै Doha, Al Wakrah, Lusail',
      tamil: 'எ.கா. Doha, Al Wakrah, Lusail',
    ),
    'action_continue': _e(
      'Continue',
      arabic: 'متابعة',
      hindi: 'जारी रखें',
      urdu: 'جاری رکھیں',
      bengali: 'চালিয়ে যান',
      filipino: 'Magpatuloy',
      malayalam: 'തുടരുക',
      nepali: 'जारी राख्नुहोस्',
      tamil: 'தொடரவும்',
    ),
    'action_skip': _e(
      'Skip for now',
      arabic: 'تخطي الآن',
      hindi: 'अभी छोड़ें',
      urdu: 'ابھی چھوڑ دیں',
      bengali: 'এখন skip করুন',
      filipino: 'Laktawan muna',
      malayalam: 'ഇപ്പോൾ skip ചെയ്യുക',
      nepali: 'अहिले skip गर्नुहोस्',
      tamil: 'இப்போது skip செய்யவும்',
    ),
    'action_done': _e(
      'Done',
      arabic: 'تم',
      hindi: 'हो गया',
      urdu: 'مکمل',
      bengali: 'সম্পন্ন',
      filipino: 'Tapos na',
      malayalam: 'പൂർത്തിയായി',
      nepali: 'सकियो',
      tamil: 'முடிந்தது',
    ),
    'sem_progress': _e(
      'Profile setup step {current} of {total}, {field}',
      arabic: 'إعداد الملف — الخطوة {current} من {total}، {field}',
      hindi: 'Profile setup — चरण {current} / {total}, {field}',
      urdu: 'Profile setup — مرحلہ {current} از {total}، {field}',
      bengali: 'Profile setup — ধাপ {current} / {total}, {field}',
      filipino: 'Profile setup — hakbang {current} ng {total}, {field}',
      malayalam: 'Profile setup — ഘട്ടം {current} / {total}, {field}',
      nepali: 'Profile setup — चरण {current} / {total}, {field}',
      tamil: 'Profile setup — படி {current} / {total}, {field}',
    ),
    'error_empty_value': _e(
      'Enter a value or tap Skip for now.',
      arabic: 'أدخل قيمة أو اضغط تخطي الآن.',
      hindi: 'कोई मान दर्ज करें या अभी छोड़ें पर टैप करें।',
      urdu: 'کوئی قدر درج کریں یا ابھی skip کریں۔',
      bengali: 'একটি মান লিখুন অথবা skip করুন।',
      filipino: 'Maglagay ng value o i-tap ang Skip for now.',
      malayalam: 'ഒരു value നൽകുക അല്ലെങ്കിൽ Skip for now ടാപ്പ് ചെയ്യുക.',
      nepali: 'मान प्रविष्ट गर्नुहोस् वा Skip for now ट्याप गर्नुहोस्।',
      tamil: 'ஒரு மதிப்பை உள்ளிடவும் அல்லது Skip for now-ஐ தட்டவும்.',
    ),
    'error_sign_in_required': _e(
      'Sign in to personalize your profile.',
      arabic: 'سجّل الدخول لتخصيص ملفك.',
      hindi: 'अपनी profile personalize करने के लिए साइन इन करें।',
      urdu: 'اپنی profile personalize کرنے کے لیے سائن ان کریں۔',
      bengali: 'Profile personalize করতে সাইন ইন করুন।',
      filipino: 'Mag-sign in para i-personalize ang profile.',
      malayalam: 'Profile personalize ചെയ്യാൻ sign in ചെയ്യുക.',
      nepali: 'Profile personalize गर्न sign in गर्नुहोस्।',
      tamil: 'Profile-ஐ personalize செய்ய sign in செய்யவும்.',
    ),
  };
}
