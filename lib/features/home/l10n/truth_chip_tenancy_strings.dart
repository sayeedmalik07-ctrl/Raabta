import 'package:flutter/foundation.dart';
import 'package:raabta/core/l10n/app_locale.dart';
import 'package:raabta/core/l10n/locale_catalog_coverage.dart';
import 'package:raabta/core/l10n/locale_catalog_entry.dart';

/// Localized copy for Tenancy Truth Engine Home chip.
abstract final class TruthChipTenancyStrings {
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

  @visibleForTesting
  static Map<String, Set<String>> get localeCoverageReport =>
      buildLocaleCoverageReport(
        catalog: _catalog,
        supportedLocales: supportedLocales,
      );

  static final _catalog = <String, Map<String, String>>{
    'truth_chip_tenancy_invite': l10nEntry(
      english: 'Check your lease',
      arabic: 'تحقق من عقد الإيجار',
      hindi: 'अपना लीज़ जाँचें',
      urdu: 'اپنا لیز چیک کریں',
      malayalam: 'നിങ്ങളുടെ ലീസ് പരിശോധിക്കുക',
      nepali: 'आफ्नो लीज जाँच गर्नुहोस्',
      bengali: 'আপনার লিজ যাচাই করুন',
      tamil: 'உங்கள் குத்தகை ஒப்பந்தத்தை சரிபாருங்கள்',
      filipino: 'Suriin ang iyong lease',
    ),
    'truth_chip_tenancy_tracked_lease_end': l10nEntry(
      english: 'Lease ends in {days} days',
      arabic: 'ينتهي العقد خلال {days} يوم',
      hindi: 'लीज़ {days} दिन में समाप्त',
      urdu: 'لیز {days} دن میں ختم',
      malayalam: 'ലീസ് {days} ദിവസത്തിനുള്ളിൽ അവസാനിക്കും',
      nepali: 'लीज {days} दिनमा सकिन्छ',
      bengali: 'লিজ {days} দিনে শেষ',
      tamil: 'குத்தகை {days} நாட்களில் முடியும்',
      filipino: 'Matatapos ang lease sa {days} araw',
    ),
    'truth_chip_tenancy_tracked_saved': l10nEntry(
      english: 'Lease check on file',
      arabic: 'فحص العقد محفوظ',
      hindi: 'लीज़ जाँच दर्ज है',
      urdu: 'لیز چیک محفوظ ہے',
      malayalam: 'ലീസ് പരിശോധന സേവ് ചെയ്തു',
      nepali: 'लीज जाँच सुरक्षित छ',
      bengali: 'লিজ যাচাই সংরক্ষিত',
      tamil: 'குத்தகை சரிபார்ப்பு சேமிக்கப்பட்டது',
      filipino: 'Naka-save ang lease check',
    ),
    'truth_chip_tenancy_urgent_unregistered': l10nEntry(
      english: 'Lease not registered',
      arabic: 'العقد غير مسجل',
      hindi: 'लीज़ पंजीकृत नहीं',
      urdu: 'لیز رجسٹرڈ نہیں',
      malayalam: 'ലീസ് രജിസ്റ്റർ ചെയ്തിട്ടില്ല',
      nepali: 'लीज दर्ता भएको छैन',
      bengali: 'লিজ নিবন্ধিত নয়',
      tamil: 'குத்தகை பதிவு செய்யப்படவில்லை',
      filipino: 'Hindi rehistrado ang lease',
    ),
    'truth_chip_tenancy_attention_lease_end': l10nEntry(
      english: 'Lease ends in {days} days',
      arabic: 'ينتهي العقد خلال {days} يوم',
      hindi: 'लीज़ {days} दिन में समाप्त',
      urdu: 'لیز {days} دن میں ختم',
      malayalam: 'ലീസ് {days} ദിവസത്തിനുള്ളിൽ അവസാനിക്കും',
      nepali: 'लीज {days} दिनमा सकिन्छ',
      bengali: 'লিজ {days} দিনে শেষ',
      tamil: 'குத்தகை {days} நாட்களில் முடியும்',
      filipino: 'Matatapos ang lease sa {days} araw',
    ),
    'truth_chip_tenancy_urgent_lease_end': l10nEntry(
      english: 'Lease ending soon',
      arabic: 'العقد على وشك الانتهاء',
      hindi: 'लीज़ जल्द समाप्त हो रही है',
      urdu: 'لیز جلد ختم ہونے والی ہے',
      malayalam: 'ലീസ് ഉടൻ അവസാനിക്കും',
      nepali: 'लीज चाँडै समाप्त हुँदै',
      bengali: 'লিজ শীঘ্র শেষ হচ্ছে',
      tamil: 'குத்தகை விரைவில் முடிவடைகிறது',
      filipino: 'Malapit nang matapos ang lease',
    ),
    'truth_chip_tenancy_attention_deposit': l10nEntry(
      english: 'Deposit window · {days} days',
      arabic: 'مهلة الوديعة · {days} يوم',
      hindi: 'जमा अवधि · {days} दिन',
      urdu: 'ڈپازٹ کی مدت · {days} دن',
      malayalam: 'ഡിപ്പോസിറ്റ് കാലയളവ് · {days} ദിവസം',
      nepali: 'धरौती अवधि · {days} दिन',
      bengali: 'ডিপোজিট সময় · {days} দিন',
      tamil: 'வைப்புத் காலம் · {days} நாட்கள்',
      filipino: 'Deposit window · {days} araw',
    ),
    'truth_chip_tenancy_urgent_appeal': l10nEntry(
      english: 'Appeal window closing',
      arabic: 'مهلة الاستئناف تقترب من الانتهاء',
      hindi: 'अपील अवधि समाप्त हो रही है',
      urdu: 'اپیل کی مدت ختم ہونے والی ہے',
      malayalam: 'അപ്പീൽ കാലയളവ് അവസാനിക്കുന്നു',
      nepali: 'पुनरावेदन अवधि समाप्त हुँदै',
      bengali: 'আপিল সময় শেষ হচ্ছে',
      tamil: 'மேல்முறையீட்டுக் காலம் முடிவடைகிறது',
      filipino: 'Sasara na ang appeal window',
    ),
    'truth_chip_tenancy_urgent_deposit': l10nEntry(
      english: 'Deposit window closing',
      arabic: 'مهلة الوديعة تقترب من الانتهاء',
      hindi: 'जमा अवधि समाप्त हो रही है',
      urdu: 'ڈپازٹ کی مدت ختم ہونے والی ہے',
      malayalam: 'ഡിപ്പോസിറ്റ് കാലയളവ് അവസാനിക്കുന്നു',
      nepali: 'धरौती अवधि समाप्त हुँदै',
      bengali: 'ডিপোজিট সময় শেষ হচ্ছে',
      tamil: 'வைப்புக் காலம் முடிவடைகிறது',
      filipino: 'Sasara na ang deposit window',
    ),
    'truth_chip_tenancy_stale': l10nEntry(
      english: 'Review your lease check',
      arabic: 'راجع فحص العقد المحفوظ',
      hindi: 'अपनी लीज़ जाँच की समीक्षा करें',
      urdu: 'محفوظ لیز چیک کا جائزہ لیں',
      malayalam: 'സേവ് ചെയ്ത ലീസ് പരിശോധന അവലോകനം ചെയ്യുക',
      nepali: 'सुरक्षित लीज जाँच समीक्षा गर्नुहोस्',
      bengali: 'সংরক্ষিত লিজ যাচাই পর্যালোচনা করুন',
      tamil: 'சேமித்த குத்தகை சரிபார்ப்பை மதிப்பாய்வு செய்யுங்கள்',
      filipino: 'Suriin ang na-save na lease check',
    ),
    'truth_chip_tenancy_freshness': l10nEntry(
      english: 'From your lease entry',
      arabic: 'من إدخال عقدك المحفوظ',
      hindi: 'आपकी लीज़ प्रविष्टि से',
      urdu: 'آپ کے لیز اندراج سے',
      malayalam: 'നിങ്ങളുടെ ലീസ് എൻട്രിയിൽ നിന്ന്',
      nepali: 'तपाईंको लीज प्रविष्टिबाट',
      bengali: 'আপনার লিজ এন্ট্রি থেকে',
      tamil: 'உங்கள் குத்தகை பதிவிலிருந்து',
      filipino: 'Mula sa iyong lease entry',
    ),
    'truth_chip_tenancy_pill_action': l10nEntry(
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
    'truth_chip_tenancy_pill_refresh': l10nEntry(
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
  };
}
