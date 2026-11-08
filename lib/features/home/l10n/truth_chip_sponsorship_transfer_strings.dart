import 'package:flutter/foundation.dart';
import 'package:raabta/core/l10n/app_locale.dart';
import 'package:raabta/core/l10n/locale_catalog_coverage.dart';
import 'package:raabta/core/l10n/locale_catalog_entry.dart';

/// Localized copy for Sponsorship Transfer Truth Engine Home chip.
abstract final class TruthChipSponsorshipTransferStrings {
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
    'truth_chip_st_invite': l10nEntry(
      english: 'Check your rights',
      arabic: 'تحقق من حقوقك',
      hindi: 'अपने अधिकार जाँचें',
      urdu: 'اپنے حقوق چیک کریں',
      malayalam: 'നിങ്ങളുടെ അവകാശങ്ങൾ പരിശോധിക്കുക',
      nepali: 'आफ्ना अधिकार जाँच गर्नुहोस्',
      bengali: 'আপনার অধিকার যাচাই করুন',
      tamil: 'உங்கள் உரிமைகளை சரிபாருங்கள்',
      filipino: 'Suriin ang iyong mga karapatan',
    ),
    'truth_chip_st_tracked_window_open': l10nEntry(
      english: 'Transfer window open · {days} days',
      arabic: 'نافذة النقل مفتوحة · {days} يوم',
      hindi: 'स्थानांतरण विंडो खुली · {days} दिन',
      urdu: 'منتقلی کی مدت · {days} دن',
      malayalam: 'ട്രാൻസ്ഫർ വിൻഡോ തുറന്നിരിക്കുന്നു · {days} ദിവസം',
      nepali: 'सारांतरण सञ्झ्याल खुला · {days} दिन',
      bengali: 'স্থানান্তরের সময় · {days} দিন',
      tamil: 'மாற்ற சாளரம் திறந்தது · {days} நாட்கள்',
      filipino: 'Bukas ang transfer window · {days} araw',
    ),
    'truth_chip_st_tracked_grace': l10nEntry(
      english: 'Grace window · {days} days left',
      arabic: 'مهلة السماح · {days} يوم',
      hindi: 'ग्रेस अवधि · {days} दिन शेष',
      urdu: 'گریس مدت · {days} دن باقی',
      malayalam: 'ഗ്രേസ് കാലയളവ് · {days} ദിവസം ബാക്കി',
      nepali: 'ग्रेस अवधि · {days} दिन बाँकी',
      bengali: 'গ্রেস সময় · {days} দিন বাকি',
      tamil: 'கிரேஸ் காலம் · {days} நாட்கள் மீதம்',
      filipino: 'Grace window · {days} araw na lang',
    ),
    'truth_chip_st_tracked_saved': l10nEntry(
      english: 'Readiness check on file',
      arabic: 'فحص الجاهزية محفوظ',
      hindi: 'तत्परता जाँच दर्ज है',
      urdu: 'تیاری کی جانچ محفوظ ہے',
      malayalam: 'റെഡിനസ് പരിശോധന സേവ് ചെയ്തു',
      nepali: 'तयारी जाँच सुरक्षित छ',
      bengali: 'প্রস্তুতি যাচাই সংরক্ষিত',
      tamil: 'தயார்நிலை சரிபார்ப்பு சேமிக்கப்பட்டது',
      filipino: 'Naka-save ang readiness check',
    ),
    'truth_chip_st_attention_grace': l10nEntry(
      english: 'Grace window · {days} days',
      arabic: 'مهلة السماح · {days} يوم',
      hindi: 'ग्रेस अवधि · {days} दिन',
      urdu: 'گریس مدت · {days} دن',
      malayalam: 'ഗ്രേസ് · {days} ദിവസം',
      nepali: 'ग्रेस · {days} दिन',
      bengali: 'গ্রেস · {days} দিন',
      tamil: 'கிரேஸ் · {days} நாட்கள்',
      filipino: 'Grace window · {days} araw',
    ),
    'truth_chip_st_urgent_grace_closed': l10nEntry(
      english: 'Post-expiry grace closed',
      arabic: 'انتهت مهلة ما بعد الانتهاء',
      hindi: 'समाप्ति के बाद की अवधि समाप्त',
      urdu: 'میعاد ختم ہونے کے بعد کی مدت ختم',
      malayalam: 'കാലാവധി കഴിഞ്ഞ ഗ്രേസ് അവസാനിച്ചു',
      nepali: 'म्याद सकिएपछिको ग्रेस सकियो',
      bengali: 'মেয়াদোত্তীর্ণের পরের গ্রেস শেষ',
      tamil: 'காலாவதிக்குப் பிறகான கிரேஸ் முடிந்தது',
      filipino: 'Tapos na ang post-expiry grace',
    ),
    'truth_chip_st_stale': l10nEntry(
      english: 'Review your transfer check',
      arabic: 'راجع فحص النقل المحفوظ',
      hindi: 'अपनी स्थानांतरण जाँच की समीक्षा करें',
      urdu: 'محفوظ منتقلی چیک کا جائزہ لیں',
      malayalam: 'സേവ് ചെയ്ത ട്രാൻസ്ഫർ പരിശോധന അവലോകനം ചെയ്യുക',
      nepali: 'सुरक्षित स्थानान्तरण जाँच समीक्षा गर्नुहोस्',
      bengali: 'সংরক্ষিত স্থানান্তর যাচাই পর্যালোচনা করুন',
      tamil: 'சேமித்த மாற்ற சரிபார்ப்பை மதிப்பாய்வு செய்யுங்கள்',
      filipino: 'Suriin ang na-save na transfer check',
    ),
    'truth_chip_st_freshness': l10nEntry(
      english: 'From your transfer readiness check',
      arabic: 'من فحص جاهزية النقل المحفوظ',
      hindi: 'आपकी तत्परता जाँच से',
      urdu: 'آپ کی تیاری کی جانچ سے',
      malayalam: 'നിങ്ങളുടെ റെഡിനസ് ചെക്കിൽ നിന്ന്',
      nepali: 'तपाईंको तयारी जाँचबाट',
      bengali: 'আপনার প্রস্তুতি যাচাই থেকে',
      tamil: 'உங்கள் தயார்நிலை சரிபார்ப்பிலிருந்து',
      filipino: 'Mula sa iyong readiness check',
    ),
    'truth_chip_st_pill_action': l10nEntry(
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
    'truth_chip_st_pill_refresh': l10nEntry(
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
