import 'package:flutter/foundation.dart';
import 'package:raabta/core/l10n/app_locale.dart';
import 'package:raabta/core/l10n/locale_catalog_coverage.dart';
import 'package:raabta/core/l10n/locale_catalog_entry.dart';

/// Localized copy for Health Insurance Truth Engine Home chip.
abstract final class TruthChipHealthInsuranceStrings {
  static const supportedLocales = AppLocale.supportedLocales;

  /// Annual policy window — matches HI provider history upsert (364 days).
  static const annualCoverageDays = 364;

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

  static String monthShort(int month, String locale) {
    if (month < 1 || month > 12) return '';
    return t('truth_chip_hi_month_$month', locale);
  }

  @visibleForTesting
  static Map<String, Set<String>> get localeCoverageReport =>
      buildLocaleCoverageReport(
        catalog: _catalog,
        supportedLocales: supportedLocales,
      );

  static final _catalog = <String, Map<String, String>>{
    'truth_chip_hi_invite': l10nEntry(
      english: 'Check your policy',
      arabic: 'تحقق من بوليصتك',
      hindi: 'अपनी पॉलिसी जाँचें',
      urdu: 'اپنی پالیسی چیک کریں',
      malayalam: 'നിങ്ങളുടെ പോളിസി പരിശോധിക്കുക',
      nepali: 'आफ्नो पालिसी जाँच गर्नुहोस्',
      bengali: 'আপনার পলিসি যাচাই করুন',
      tamil: 'உங்கள் காப்பீட்டை சரிபாருங்கள்',
      filipino: 'Suriin ang iyong policy',
    ),
    'truth_chip_hi_tracked_covered': l10nEntry(
      english: 'Covered until {month}',
      arabic: 'التغطية حتى {month}',
      hindi: '{month} तक कवर',
      urdu: '{month} تک کور',
      malayalam: '{month} വരെ കവറേജ്',
      nepali: '{month} सम्म कभर',
      bengali: '{month} পর্যন্ত কভার',
      tamil: '{month} வரை காப்பீடு',
      filipino: 'Sakop hanggang {month}',
    ),
    'truth_chip_hi_tracked_saved': l10nEntry(
      english: 'Policy check on file',
      arabic: 'فحص البوليصة محفوظ',
      hindi: 'पॉलिसी जाँच दर्ज है',
      urdu: 'پالیسی چیک محفوظ ہے',
      malayalam: 'പോളിസി പരിശോധന സേവ് ചെയ്തു',
      nepali: 'पालिसी जाँच सुरक्षित छ',
      bengali: 'পলিসি যাচাই সংরক্ষিত',
      tamil: 'காப்பீட்டு சரிபார்ப்பு சேமிக்கப்பட்டது',
      filipino: 'Naka-save ang policy check',
    ),
    'truth_chip_hi_tracked_exempt': l10nEntry(
      english: 'Exemption recorded',
      arabic: 'تم تسجيل الإعفاء',
      hindi: 'छूट दर्ज है',
      urdu: 'استثنیٰ محفوظ ہے',
      malayalam: 'ഒഴിവാക്കൽ രേഖപ്പെടുത്തി',
      nepali: 'छुट दर्ता भयो',
      bengali: 'ছাড় নথিভুক্ত',
      tamil: 'விலக்கு பதிவு செய்யப்பட்டது',
      filipino: 'Naitala ang exemption',
    ),
    'truth_chip_hi_attention_renew': l10nEntry(
      english: 'Renews in {days} days',
      arabic: 'تجديد خلال {days} يوم',
      hindi: '{days} दिन में नवीनीकरण',
      urdu: '{days} دن میں تجدید',
      malayalam: '{days} ദിവസത്തിനുള്ളിൽ പുതുക്കൽ',
      nepali: '{days} दिनमा नवीकरण',
      bengali: '{days} দিনে নবায়ন',
      tamil: '{days} நாட்களில் புதுப்பிப்பு',
      filipino: 'Renew sa {days} araw',
    ),
    'truth_chip_hi_urgent_gap': l10nEntry(
      english: 'Coverage gap flagged',
      arabic: 'تم رصد فجوة في التغطية',
      hindi: 'कवरेज अंतर दर्ज',
      urdu: 'کوریج گیپ نشان زد',
      malayalam: 'കവറേജ് ഗ്യാപ് കണ്ടെത്തി',
      nepali: 'कभरेज खालीता चिन्हित',
      bengali: 'কভারেজ গ্যাপ চিহ্নিত',
      tamil: 'காப்பீட்டு இடைவெளி குறிக்கப்பட்டது',
      filipino: 'May na-flag na coverage gap',
    ),
    'truth_chip_hi_urgent_ended': l10nEntry(
      english: 'Cover ended',
      arabic: 'انتهت التغطية',
      hindi: 'कवर समाप्त',
      urdu: 'کور ختم',
      malayalam: 'കവറേജ് അവസാനിച്ചു',
      nepali: 'कभर समाप्त',
      bengali: 'কভার শেষ',
      tamil: 'காப்பீடு முடிந்தது',
      filipino: 'Natapos ang cover',
    ),
    'truth_chip_hi_urgent_issue': l10nEntry(
      english: 'Compliance issue flagged',
      arabic: 'تم رصد مشكلة امتثال',
      hindi: 'अनुपालन मुद्दा दर्ज',
      urdu: 'تعمیل کا مسئلہ نشان زد',
      malayalam: 'കമ്പ്ലയൻസ് പ്രശ്നം കണ്ടെത്തി',
      nepali: 'अनुपालन समस्या चिन्हित',
      bengali: 'কমপ্লায়েন্স ইস্যু চিহ্নিত',
      tamil: 'இணக்கம் சிக்கல் குறிக்கப்பட்டது',
      filipino: 'May na-flag na compliance issue',
    ),
    'truth_chip_hi_stale': l10nEntry(
      english: 'Review your policy check',
      arabic: 'راجع فحص البوليصة المحفوظ',
      hindi: 'अपनी पॉलिसी जाँच की समीक्षा करें',
      urdu: 'محفوظ پالیسی چیک کا جائزہ لیں',
      malayalam: 'സേവ് ചെയ്ത പോളിസി പരിശോധന അവലോകനം ചെയ്യുക',
      nepali: 'सुरक्षित पालिसी जाँच समीक्षा गर्नुहोस्',
      bengali: 'সংরক্ষিত পলিসি যাচাই পর্যালোচনা করুন',
      tamil: 'சேமித்த காப்பீட்டு சரிபார்ப்பை மதிப்பாய்வு செய்யுங்கள்',
      filipino: 'Suriin ang na-save na policy check',
    ),
    'truth_chip_hi_freshness': l10nEntry(
      english: 'From your policy check',
      arabic: 'من فحص بوليصتك المحفوظ',
      hindi: 'आपकी पॉलिसी जाँच से',
      urdu: 'آپ کی پالیسی چیک سے',
      malayalam: 'നിങ്ങളുടെ പോളിസി ചെക്കിൽ നിന്ന്',
      nepali: 'तपाईंको पालिसी जाँचबाट',
      bengali: 'আপনার পলিসি যাচাই থেকে',
      tamil: 'உங்கள் காப்பீட்டு சரிபார்ப்பிலிருந்து',
      filipino: 'Mula sa iyong policy check',
    ),
    'truth_chip_hi_pill_action': l10nEntry(
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
    'truth_chip_hi_pill_refresh': l10nEntry(
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
    'truth_chip_hi_revealed': l10nEntry(
      english: '{insurer} · ends {date}',
      arabic: '{insurer} · ينتهي {date}',
      hindi: '{insurer} · समाप्ति {date}',
      urdu: '{insurer} · اختتام {date}',
      malayalam: '{insurer} · അവസാനം {date}',
      nepali: '{insurer} · समाप्ति {date}',
      bengali: '{insurer} · শেষ {date}',
      tamil: '{insurer} · முடிவு {date}',
      filipino: '{insurer} · matapos {date}',
    ),
    'truth_chip_hi_month_1': l10nEntry(
      english: 'Jan',
      arabic: 'يناير',
      hindi: 'जन',
      urdu: 'جنوری',
      malayalam: 'ജനു',
      nepali: 'जन',
      bengali: 'জান',
      tamil: 'ஜன',
      filipino: 'Ene',
    ),
    'truth_chip_hi_month_2': l10nEntry(
      english: 'Feb',
      arabic: 'فبراير',
      hindi: 'फ़र',
      urdu: 'فروری',
      malayalam: 'ഫെബ്രു',
      nepali: 'फेब',
      bengali: 'ফেব',
      tamil: 'பிப்',
      filipino: 'Peb',
    ),
    'truth_chip_hi_month_3': l10nEntry(
      english: 'Mar',
      arabic: 'مارس',
      hindi: 'मार्च',
      urdu: 'مارچ',
      malayalam: 'മാർ',
      nepali: 'मार्च',
      bengali: 'মার্চ',
      tamil: 'மார்',
      filipino: 'Mar',
    ),
    'truth_chip_hi_month_4': l10nEntry(
      english: 'Apr',
      arabic: 'أبريل',
      hindi: 'अप्रै',
      urdu: 'اپریل',
      malayalam: 'ഏപ്രി',
      nepali: 'अप्रिल',
      bengali: 'এপ্রি',
      tamil: 'ஏப்',
      filipino: 'Abr',
    ),
    'truth_chip_hi_month_5': l10nEntry(
      english: 'May',
      arabic: 'مايو',
      hindi: 'मई',
      urdu: 'مئی',
      malayalam: 'മേയ്',
      nepali: 'मे',
      bengali: 'মে',
      tamil: 'மே',
      filipino: 'May',
    ),
    'truth_chip_hi_month_6': l10nEntry(
      english: 'Jun',
      arabic: 'يونيو',
      hindi: 'जून',
      urdu: 'جون',
      malayalam: 'ജൂൺ',
      nepali: 'जुन',
      bengali: 'জুন',
      tamil: 'ஜூன்',
      filipino: 'Hun',
    ),
    'truth_chip_hi_month_7': l10nEntry(
      english: 'Jul',
      arabic: 'يوليو',
      hindi: 'जुल',
      urdu: 'جولائی',
      malayalam: 'ജൂലൈ',
      nepali: 'जुलाई',
      bengali: 'জুল',
      tamil: 'ஜூலை',
      filipino: 'Hul',
    ),
    'truth_chip_hi_month_8': l10nEntry(
      english: 'Aug',
      arabic: 'أغسطس',
      hindi: 'अग',
      urdu: 'اگست',
      malayalam: 'ഓഗ',
      nepali: 'अग',
      bengali: 'আগ',
      tamil: 'ஆக',
      filipino: 'Ago',
    ),
    'truth_chip_hi_month_9': l10nEntry(
      english: 'Sep',
      arabic: 'سبتمبر',
      hindi: 'सित',
      urdu: 'ستمبر',
      malayalam: 'സെപ്തം',
      nepali: 'सेप्ट',
      bengali: 'সেপ',
      tamil: 'செப்',
      filipino: 'Sep',
    ),
    'truth_chip_hi_month_10': l10nEntry(
      english: 'Oct',
      arabic: 'أكتوبر',
      hindi: 'अक्ट',
      urdu: 'اکتوبر',
      malayalam: 'ഒക്ടോ',
      nepali: 'अक्ट',
      bengali: 'অক্ট',
      tamil: 'அக்',
      filipino: 'Okt',
    ),
    'truth_chip_hi_month_11': l10nEntry(
      english: 'Nov',
      arabic: 'نوفمبر',
      hindi: 'नव',
      urdu: 'نومبر',
      malayalam: 'നവം',
      nepali: 'नोभ',
      bengali: 'নভে',
      tamil: 'நவ',
      filipino: 'Nob',
    ),
    'truth_chip_hi_month_12': l10nEntry(
      english: 'Dec',
      arabic: 'ديسمبر',
      hindi: 'दिस',
      urdu: 'دسمبر',
      malayalam: 'ഡിസം',
      nepali: 'डिसे',
      bengali: 'ডিসে',
      tamil: 'டிச',
      filipino: 'Dis',
    ),
  };
}
