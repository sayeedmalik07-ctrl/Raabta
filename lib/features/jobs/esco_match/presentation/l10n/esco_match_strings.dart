import 'package:flutter/foundation.dart';
import 'package:raabta/core/l10n/app_locale.dart';
import 'package:raabta/core/l10n/locale_catalog_coverage.dart';
import 'package:raabta/core/l10n/locale_catalog_entry.dart';

/// ESCO skill match UI strings — 9 locales via [AppLocale.supportedLocales].
abstract final class EscoMatchStrings {
  static const supportedLocales = AppLocale.supportedLocales;

  static String t(String key, [String locale = 'English']) {
    final normalized = AppLocale.normalize(locale);
    final map = _catalog[key];
    if (map == null) return key;
    return map[normalized] ?? map['English'] ?? key;
  }

  static String tf(
    String key,
    String locale,
    Map<String, String> params,
  ) {
    var text = t(key, locale);
    for (final entry in params.entries) {
      text = text.replaceAll('{${entry.key}}', entry.value);
    }
    return text;
  }

  @visibleForTesting
  static Map<String, Set<String>> get localeCoverageReport =>
      buildLocaleCoverageReport(
        catalog: _catalog,
        supportedLocales: supportedLocales,
      );

  static final _catalog = <String, Map<String, String>>{
    'esco_match_header': l10nEntry(
      english: 'ESCO Skill Match',
      arabic: 'مطابقة مهارات ESCO',
      hindi: 'ESCO कौशल मिलान',
      urdu: 'ESCO مہارت میچ',
      malayalam: 'ESCO Skill Match',
      nepali: 'ESCO Skill Match',
      bengali: 'ESCO দক্ষতা মিল',
      tamil: 'ESCO Skill Match',
      filipino: 'ESCO Skill Match',
    ),
    'esco_match_subtitle': l10nEntry(
      english: 'Official EU skills taxonomy · explainable match',
      arabic: 'تصنيف مهارات الاتحاد الأوروبي الرسمي · مطابقة واضحة',
      hindi: 'आधिकारिक EU कौशल वर्गीकरण · स्पष्ट मिलान',
      urdu: 'سرکاری EU مہارت درجہ بندی · واضح میچ',
    ),
    'esco_match_score': l10nEntry(
      english: '{score}% Profile Match',
      arabic: '{score}% مطابقة الملف',
      hindi: '{score}% प्रोफ़ाइल मिलान',
      urdu: '{score}% پروفائل میچ',
    ),
    'esco_match_compact': l10nEntry(
      english: '{score}% Match',
      arabic: '{score}% مطابقة',
      hindi: '{score}% मिलान',
      urdu: '{score}% میچ',
    ),
    'esco_match_level_excellent': l10nEntry(
      english: 'Excellent Match',
      arabic: 'مطابقة ممتازة',
      hindi: 'उत्कृष्ट मिलान',
      urdu: 'بہترین میچ',
    ),
    'esco_match_level_strong': l10nEntry(
      english: 'Strong Match',
      arabic: 'مطابقة قوية',
      hindi: 'मज़बूत मिलान',
      urdu: 'مضبوط میچ',
    ),
    'esco_match_level_good': l10nEntry(
      english: 'Good Match',
      arabic: 'مطابقة جيدة',
      hindi: 'अच्छा मिलान',
      urdu: 'اچھا میچ',
    ),
    'esco_match_level_fair': l10nEntry(
      english: 'Fair Match',
      arabic: 'مطابقة مقبولة',
      hindi: 'ठीक मिलान',
      urdu: 'مناسب میچ',
    ),
    'esco_match_level_low': l10nEntry(
      english: 'Low Match',
      arabic: 'مطابقة منخفضة',
      hindi: 'कम मिलान',
      urdu: 'کم میچ',
    ),
    'esco_match_matched_label': l10nEntry(
      english: 'Matched skills',
      arabic: 'المهارات المتطابقة',
      hindi: 'मेल खाते कौशल',
      urdu: 'مماثل مہارتیں',
    ),
    'esco_match_missing_label': l10nEntry(
      english: 'Missing skills',
      arabic: 'المهارات الناقصة',
      hindi: 'अनुपस्थित कौशल',
      urdu: 'غائب مہارتیں',
    ),
    'esco_match_blocked_label': l10nEntry(
      english: 'Required qualification missing',
      arabic: 'مؤهل مطلوب غير متوفر',
      hindi: 'आवश्यक योग्यता अनुपस्थित',
      urdu: 'مطلوبہ قابلیت غائب',
    ),
    'esco_match_skill_overlap': l10nEntry(
      english: '{percent}% skill overlap',
      arabic: '{percent}% تطابق مهارات',
      hindi: '{percent}% कौशल ओवरलैप',
      urdu: '{percent}% مہارت اوورلیپ',
    ),
    'esco_gap_title': l10nEntry(
      english: 'Skills you\'re missing for {role}',
      arabic: 'مهارات ناقصة لدور {role}',
      hindi: '{role} के लिए अनुपस्थित कौशल',
      urdu: '{role} کے لیے غائب مہارتیں',
    ),
    'esco_gap_subtitle': l10nEntry(
      english:
          'Based on ESCO essential skills for this occupation in Qatar\'s labour market.',
      arabic:
          'استناداً إلى المهارات الأساسية في ESCO لهذه المهنة في سوق العمل القطري.',
      hindi:
          'क़तर के श्रम बाज़ार में इस व्यवसाय के लिए ESCO आवश्यक कौशल के आधार पर।',
      urdu:
          'قطر کی لیبر مارکیٹ میں اس پیشے کے لیے ESCO ضروری مہارتوں کی بنیاد پر۔',
    ),
    'esco_gap_no_role': l10nEntry(
      english:
          'Add a job title in Work Experience to see ESCO skill gaps for your target role.',
      arabic:
          'أضف مسمى وظيفي في الخبرة العملية لعرض فجوات مهارات ESCO لدورك المستهدف.',
      hindi:
          'अपने लक्ष्य भूमिका के लिए ESCO कौशल अंतराल देखने के लिए कार्य अनुभव में नौकरी का शीर्षक जोड़ें।',
      urdu:
          'اپنے ہدف کردہ کردار کے لیے ESCO مہارت کے فرق دیکھنے کے لیے کام کے تجربے میں ملازمت کا عنوان شامل کریں۔',
    ),
    'esco_gap_unmapped_role': l10nEntry(
      english:
          'We could not map "{role}" to an ESCO occupation yet — try a standard title like Warehouse Manager or HSE Officer.',
      arabic:
          'تعذر ربط "{role}" بمهنة ESCO — جرّب عنواناً شائعاً مثل مدير مستودع أو مسؤول HSE.',
      hindi:
          '"{role}" को ESCO व्यवसाय से नहीं जोड़ा जा सका — Warehouse Manager या HSE Officer जैसा मानक शीर्षक आज़माएं।',
      urdu:
          '"{role}" کو ESCO پیشے سے نہیں جوڑا جا سکا — Warehouse Manager یا HSE Officer جیسا معیاری عنوان آزمائیں۔',
    ),
    'esco_gap_all_matched': l10nEntry(
      english: 'Your CV covers the essential ESCO skills for {role}.',
      arabic: 'سيرتك الذاتية تغطي المهارات الأساسية في ESCO لدور {role}.',
      hindi: 'आपका CV {role} के लिए आवश्यक ESCO कौशल को कवर करता है।',
      urdu: 'آپ کا CV {role} کے لیے ضروری ESCO مہارتوں کو شامل کرتا ہے۔',
    ),
    'esco_gap_matched_heading': l10nEntry(
      english: 'Already on your CV',
      arabic: 'موجودة في سيرتك',
      hindi: 'पहले से CV में',
      urdu: 'پہلے سے CV میں',
    ),
  };

  static String matchLevelLabel(String englishLevel, String locale) {
    switch (englishLevel) {
      case 'Excellent Match':
        return t('esco_match_level_excellent', locale);
      case 'Strong Match':
        return t('esco_match_level_strong', locale);
      case 'Good Match':
        return t('esco_match_level_good', locale);
      case 'Fair Match':
        return t('esco_match_level_fair', locale);
      case 'Low Match':
        return t('esco_match_level_low', locale);
      default:
        return englishLevel;
    }
  }
}
