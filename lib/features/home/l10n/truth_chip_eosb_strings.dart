import 'package:flutter/foundation.dart';
import 'package:raabta/core/l10n/app_locale.dart';
import 'package:raabta/core/l10n/locale_catalog_coverage.dart';
import 'package:raabta/core/l10n/locale_catalog_entry.dart';

/// Localized copy for EOSB Truth Engine Home chip (mapper output only).
abstract final class TruthChipEosbStrings {
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
    Map<String, String> params = const {},
  }) {
    var text = t(key, locale);
    params.forEach((k, v) => text = text.replaceAll('{$k}', v));
    return text;
  }

  /// Strict nine-locale coverage inventory (J1 — no runtime behavior change).
  static Map<String, Map<String, String>> get catalogForStrictCoverage =>
      _catalog;

  @visibleForTesting
  static Map<String, Set<String>> get localeCoverageReport =>
      buildLocaleCoverageReport(
        catalog: _catalog,
        supportedLocales: supportedLocales,
      );

  @visibleForTesting
  static Map<String, Set<String>> get strictLocaleCoverageReport =>
      buildLocaleCoverageReport(
        catalog: catalogForStrictCoverage,
        supportedLocales: supportedLocales,
        fillMissingWithEnglish: false,
      );

  static final _catalog = <String, Map<String, String>>{
    'truth_chip_eosb_invite': l10nEntry(
      english: 'Check your gratuity',
      arabic: 'تحقق من مكافأة نهاية الخدمة',
      hindi: 'अपनी ग्रेच्युटी जाँचें',
      urdu: 'اپنی گریچuity چیک کریں',
      malayalam: 'നിങ്ങളുടെ ഗ്രാച്ചuity പരിശോധിക്കുക',
      nepali: 'आफ्नो ग्रेच्युटी जाँच गर्नुहोस्',
      bengali: 'আপনার গ্র্যাচুইটি যাচাই করুন',
      tamil: 'உங்கள் கிராசuityயை சரிபாருங்கள்',
      filipino: 'Suriin ang iyong gratuity',
    ),
    'truth_chip_eosb_tracked_year': l10nEntry(
      english: 'Year {year} of service',
      arabic: 'السنة {year} من الخدمة',
      hindi: 'सेवा का वर्ष {year}',
      urdu: 'سروس کا سال {year}',
      malayalam: 'സേവന വർഷം {year}',
      nepali: 'सेवा वर्ष {year}',
      bengali: 'সেবার {year} বছর',
      tamil: 'சேவை ஆண்டு {year}',
      filipino: 'Taon {year} ng serbisyo',
    ),
    'truth_chip_eosb_tracked_saved': l10nEntry(
      english: 'Estimate on file',
      arabic: 'تقدير محفوظ',
      hindi: 'अनुमान दर्ज है',
      urdu: 'تخمینہ محفوظ ہے',
      malayalam: 'അനുമാനം രേഖപ്പെടുത്തി',
      nepali: 'अनुमान सुरक्षित छ',
      bengali: 'অনুমান সংরক্ষিত',
      tamil: 'மதிப்பீடு சேமிக்கப்பட்டது',
      filipino: 'May naka-save na estimate',
    ),
    'truth_chip_eosb_attention_settlement': l10nEntry(
      english: 'Settlement window · {days} days',
      arabic: 'مهلة التسوية · {days} يوم',
      hindi: 'निपटान अवधि · {days} दिन',
      urdu: 'تصفیہ کی مدت · {days} دن',
      malayalam: 'തീർപ്പുകൽപ്പना · {days} ദിവസം',
      nepali: 'मिलाप अवधि · {days} दिन',
      bengali: 'নিষ্পত্তির সময় · {days} দিন',
      tamil: 'தீர்வுக் காலம் · {days} நாட்கள்',
      filipino: 'Settlement window · {days} araw',
    ),
    'truth_chip_eosb_attention_claim': l10nEntry(
      english: 'Filing window · {days} days',
      arabic: 'مهلة التقديم · {days} يوم',
      hindi: 'दायर करने की अवधि · {days} दिन',
      urdu: 'درخواست کی مدت · {days} دن',
      malayalam: 'ഫയൽ ചെയ്യാനുള്ള സമയം · {days} ദിവസം',
      nepali: 'दर्ता अवधि · {days} दिन',
      bengali: 'জমার সময় · {days} দিন',
      tamil: 'தாக்கல் காலம் · {days} நாட்கள்',
      filipino: 'Filing window · {days} araw',
    ),
    'truth_chip_eosb_urgent_settlement': l10nEntry(
      english: 'Settlement window closing',
      arabic: 'مهلة التسوية تقترب',
      hindi: 'निपटान अवधि समाप्त हो रही है',
      urdu: 'تصفیہ کی مدت ختم ہونے والی ہے',
      malayalam: 'തീർപ്പുകൽപ്പना അവസാനിക്കുന്നു',
      nepali: 'मिलाप अवधि समाप्त हुँदै',
      bengali: 'নিষ্পত্তির সময় শেষ হচ্ছে',
      tamil: 'தீர்வுக் காலம் முடிவடைகிறது',
      filipino: 'Malapit nang matapos ang settlement window',
    ),
    'truth_chip_eosb_urgent_claim': l10nEntry(
      english: 'Filing window closing',
      arabic: 'مهلة التقديم تقترب',
      hindi: 'दायर करने की अवधि समाप्त हो रही है',
      urdu: 'درخواست کی مدت ختم ہونے والی ہے',
      malayalam: 'ഫയൽ ചെയ്യാനുള്ള സമയം അവസാനിക്കുന്നു',
      nepali: 'दर्ता अवधि समाप्त हुँदै',
      bengali: 'জমার সময় শেষ হচ্ছে',
      tamil: 'தாக்கல் காலம் முடிவடைகிறது',
      filipino: 'Malapit nang matapos ang filing window',
    ),
    'truth_chip_eosb_stale': l10nEntry(
      english: 'Review your saved estimate',
      arabic: 'راجع تقديرك المحفوظ',
      hindi: 'अपने सहेजे अनुमान की समीक्षा करें',
      urdu: 'محفوظ تخمینے کا جائزہ لیں',
      malayalam: 'സേവ് ചെയ്ത അനുമാനം പരിശോധിക്കുക',
      nepali: 'सुरक्षित अनुमान समीक्षा गर्नुहोस्',
      bengali: 'সংরক্ষিত অনুমান পর্যালোচনা করুন',
      tamil: 'சேமித்த மதிப்பீட்டை மதிப்பாய்வு செய்யுங்கள்',
      filipino: 'Suriin ang na-save na estimate',
    ),
    'truth_chip_eosb_freshness': l10nEntry(
      english: 'From your saved estimate',
      arabic: 'من تقديرك المحفوظ',
      hindi: 'आपके सहेजे अनुमान से',
      urdu: 'آپ کے محفوظ تخمینے سے',
      malayalam: 'നിങ്ങളുടെ സേവ് ചെയ്ത അനുമാനത്തിൽ നിന്ന്',
      nepali: 'तपाईंको सुरक्षित अनुमानबाट',
      bengali: 'আপনার সংরক্ষিত অনুমান থেকে',
      tamil: 'உங்கள் சேமித்த மதிப்பீட்டிலிருந்து',
      filipino: 'Mula sa iyong na-save na estimate',
    ),
    'truth_chip_eosb_pill_action': l10nEntry(
      english: 'Action',
      arabic: 'إجراء',
      hindi: 'कार्रवाई',
      urdu: 'عمل',
      malayalam: 'നടപടി',
      nepali: 'कारबाही',
      bengali: 'পদক্ষেপ',
      tamil: 'நடவடிக்கை',
      filipino: 'Aksyon',
    ),
    'truth_chip_eosb_pill_refresh': l10nEntry(
      english: 'Refresh',
      arabic: 'تحديث',
      hindi: 'रीफ़्रेश',
      urdu: 'ریفریش',
      malayalam: 'പുതുക്കുക',
      nepali: 'रिफ्रेस',
      bengali: 'রিফ্রেশ',
      tamil: 'புதுப்பி',
      filipino: 'I-refresh',
    ),
    'truth_chip_eosb_revealed_estimate': l10nEntry(
      english: 'Estimate · QAR {amount}',
      arabic: 'تقدير · {amount} ر.ق',
      hindi: 'अनुमान · QAR {राशि} {amount}',
      urdu: 'تخمینہ · QAR {رقم} {رقم} {amount}',
      malayalam: 'അനുമാനം · QAR {amount}',
      nepali: 'अनुमान · QAR {amount}',
      bengali: 'অনুমান · QAR {amount}',
      tamil: 'மதிப்பீடு · QAR {amount}',
      filipino: 'Tantyahin · QAR {amount}'
    ),
  };
}
