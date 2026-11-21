/// Cost of Living — screen, chart, home card, and comparison copy.
import 'package:flutter/foundation.dart';
import 'package:raabta/core/l10n/app_locale.dart';
import 'package:raabta/core/l10n/locale_catalog_coverage.dart';
import 'package:raabta/core/l10n/locale_catalog_entry.dart';
import 'package:raabta/features/cost_of_living/domain/cost_of_living_constants.dart';

abstract final class CostOfLivingStrings {
  static const supportedLocales = AppLocale.supportedLocales;

  /// Tamil / Malayalam / Nepali finance & CPI terminology pending native review.
  static const keysNeedingProfessionalReview = <String>{
    'col_disclaimer',
    'col_section_qatar_cpi_subtitle',
    'col_general_cpi',
    'col_general_cpi_prefix',
    'col_qol_rank',
    'col_numbeo_source',
    'col_section_category_cpi_title',
    'col_section_category_cpi_subtitle',
    'col_section_bills_subtitle',
    'col_ai_summary_disclaimer',
    'col_chart_subtitle',
    'col_home_subtitle',
    'col_qol_score',
    'col_qol_index_label',
    'col_category_index',
    'col_change_vs_prior_month',
    'col_personal_comparison_empty',
    'col_personal_comparison_disclaimer',
  };

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

  /// Exposed for catalog parity regression tests only.
  @visibleForTesting
  static Map<String, Set<String>> get localeCoverageReport =>
      buildLocaleCoverageReport(
        catalog: _catalog,
        supportedLocales: supportedLocales,
      );

  static final _catalog = <String, Map<String, String>>{
    // ── Screen chrome ───────────────────────────────────────────────────────
    'col_title': l10nEntry(
      english: 'Cost of Living',
      arabic: 'تكلفة المعيشة',
      hindi: 'जीवन योग्यता लागत',
      urdu: 'معیشت کی لاگت',
      bengali: 'জীবনযাত্রার খরচ',
      filipino: 'Cost of Living',
    ),
    'col_hub_subtitle': l10nEntry(
      english: 'Official CPI and quality-of-life context for Qatar',
      arabic: 'سياق CPI الرسمي وجودة الحياة في قطر',
      hindi: 'क़तर के लिए आधिकारिक CPI और जीवन-गुणवत्ता संदर्भ',
      urdu: 'قطر کے لیے سرکاری CPI اور معیارِ زندگی کا سیاق',
      bengali: 'কাতারের জন্য সরকারি CPI ও জীবনযাত্রার প্রেক্ষাপট',
      filipino: 'Opisyal na CPI at konteksto ng quality of life sa Qatar',
    ),
    'col_refresh_tooltip': l10nEntry(
      english: 'Refresh data',
      arabic: 'تحديث البيانات',
      hindi: 'डेटा रीफ़्रेश करें',
      urdu: 'ڈیٹا ریفریش کریں',
      bengali: 'ডেটা রিফ্রেশ করুন',
      filipino: 'I-refresh ang data',
    ),
    'col_retry': l10nEntry(
      english: 'Retry',
      arabic: 'إعادة المحاولة',
      hindi: 'पुनः प्रयास',
      urdu: 'دوبارہ کوشش',
      bengali: 'আবার চেষ্টা',
      filipino: 'Subukan muli',
    ),
    'col_cached_snapshot': l10nEntry(
      english: 'Showing last cached snapshot',
      arabic: 'عرض آخر لقطة مخزّنة',
      hindi: 'अंतिम कैश्ड स्नैपशॉट दिखाया जा रहा है',
      urdu: 'آخری محفوظ snapshot دکھایا جا رہا ہے',
      bengali: 'সর্বশেষ ক্যাশ করা snapshot দেখানো হচ্ছে',
      filipino: 'Ipinapakita ang huling naka-cache na snapshot',
    ),

    // ── Disclaimer & data freshness ─────────────────────────────────────────
    'col_disclaimer': l10nEntry(
      english: CostOfLivingConstants.disclaimer,
      arabic:
          'مصدر: بوابة البيانات المفتوحة الرسمية في قطر (data.gov.qa) ومجلس '
          'التخطيط الوطني. التحديث شهرياً (CPI) ونصف سنوي (مؤشر جودة الحياة) — '
          'ليس فورياً. للسياق المعلوماتي فقط، وليس بديلاً عن ميزانيتك.',
      hindi:
          'Qatar के आधिकारिक Open Data portal (data.gov.qa) और National '
          'Planning Council से। CPI मासिक और Quality of Life Index छमाही '
          'अपडेट — real-time नहीं। केवल संदर्भ, आपके बजट का विकल्प नहीं।',
      urdu:
          'Qatar کے سرکاری Open Data portal (data.gov.qa) اور National '
          'Planning Council سے۔ CPI ماہانہ اور Quality of Life Index دو بار '
          'سالانہ — real-time نہیں۔ صرف معلوماتی سیاق، آپ کے بجٹ کا متبادل نہیں۔',
    ),
    'col_data_as_of': l10nEntry(
      english: 'Data as of {date}',
      arabic: 'البيانات حتى {date}',
      hindi: 'डेटा {date} तक',
      urdu: 'ڈیٹا {date} تک',
      bengali: 'ডেটা {date} পর্যন্ত',
      filipino: 'Data hanggang {date}',
    ),
    'col_qol_index_label': l10nEntry(
      english: 'Quality of Life Index: {label}',
      arabic: 'مؤشر جودة الحياة: {label}',
      hindi: 'जीवन गुणवत्ता सूचकांक: {label}',
      urdu: 'معیارِ زندگی انڈیکس: {label}',
      bengali: 'জীবনযাত্রার মান সূচক: {label}',
      filipino: 'Quality of Life Index: {label}',
    ),
    'col_official_npc_not_realtime': l10nEntry(
      english: 'Official NPC / data.gov.qa — not real-time',
      arabic: 'NPC / data.gov.qa الرسمي — ليس فورياً',
      hindi: 'आधिकारिक NPC / data.gov.qa — real-time नहीं',
      urdu: 'سرکاری NPC / data.gov.qa — real-time نہیں',
      bengali: 'সরকারি NPC / data.gov.qa — real-time নয়',
      filipino: 'Opisyal na NPC / data.gov.qa — hindi real-time',
    ),

    // ── Section headers (screen) ────────────────────────────────────────────
    'col_section_official_overline': l10nEntry(
      english: 'Official data',
      arabic: 'بيانات رسمية',
      hindi: 'आधिकारिक डेटा',
      urdu: 'سرکاری ڈیٹا',
      bengali: 'সরকারি ডেটা',
      filipino: 'Opisyal na data',
    ),
    'col_section_qatar_cpi_title': l10nEntry(
      english: 'Qatar CPI',
      arabic: 'CPI قطر',
      hindi: 'क़तर CPI',
      urdu: 'قطر CPI',
      bengali: 'কাতার CPI',
      filipino: 'Qatar CPI',
    ),
    'col_section_qatar_cpi_subtitle': l10nEntry(
      english: 'NPC releases · your bills vs national trends',
      arabic: 'إصدارات NPC · فواتيرك مقابل الاتجاهات الوطنية',
      hindi: 'NPC रिलीज़ · आपके बिल बनाम राष्ट्रीय रुझान',
      urdu: 'NPC ریلیز · آپ کے بل بمقابلہ قومی رجحانات',
      bengali: 'NPC রিলিজ · আপনার বিল বনাম জাতীয় প্রবণতা',
      filipino: 'NPC releases · bills mo vs pambansang trend',
    ),
    'col_section_breakdown_overline': l10nEntry(
      english: 'Breakdown',
      arabic: 'تفصيل',
      hindi: 'विवरण',
      urdu: 'تفصیل',
      bengali: 'বিভাজন',
      filipino: 'Breakdown',
    ),
    'col_section_category_cpi_title': l10nEntry(
      english: 'Category CPI',
      arabic: 'CPI حسب الفئة',
      hindi: 'श्रेणी CPI',
      urdu: 'زمرہ CPI',
      bengali: 'বিভাগ CPI',
      filipino: 'Category CPI',
    ),
    'col_section_category_cpi_subtitle': l10nEntry(
      english:
          'Month-over-month direction from official NPC releases — '
          'not interpolated.',
      arabic:
          'اتجاه شهر بشهر من إصدارات NPC الرسمية — '
          'بدون استيفاء.',
      hindi:
          'आधिकारिक NPC रिलीज़ से महीने-दर-महीने दिशा — '
          'इंटरपोलेट नहीं।',
      urdu:
          'سرکاری NPC ریلیز سے ماہانہ سمت — '
          'interpolated نہیں۔',
      bengali:
          'সরকারি NPC রিলিজ থেকে মাস-প্রতি-মাস দিক — '
          'interpolated নয়।',
      filipino:
          'Month-over-month na direksyon mula sa opisyal na NPC releases — '
          'hindi interpolated.',
    ),
    'col_section_bills_overline': l10nEntry(
      english: 'Your bills',
      arabic: 'فواتيرك',
      hindi: 'आपके बिल',
      urdu: 'آپ کے بل',
      bengali: 'আপনার বিল',
      filipino: 'Mga bill mo',
    ),
    'col_section_bills_title': l10nEntry(
      english: 'Bills vs national trends',
      arabic: 'الفواتير مقابل الاتجاهات الوطنية',
      hindi: 'बिल बनाम राष्ट्रीय रुझान',
      urdu: 'بل بمقابلہ قومی رجحانات',
      bengali: 'বিল বনাম জাতীয় প্রবণতা',
      filipino: 'Bills vs pambansang trend',
    ),
    'col_section_bills_subtitle': l10nEntry(
      english: 'Directional context from Bill Tracker',
      arabic: 'سياق اتجاهي من متتبع الفواتير',
      hindi: 'Bill Tracker से दिशात्मक संदर्भ',
      urdu: 'Bill Tracker سے سمت کا سیاق',
      bengali: 'Bill Tracker থেকে দিকনির্দেশক প্রসঙ্গ',
      filipino: 'Directional context mula sa Bill Tracker',
    ),
    'col_section_insight_overline': l10nEntry(
      english: 'Insight',
      arabic: 'رؤية',
      hindi: 'अंतर्दृष्टि',
      urdu: 'بصیرت',
      bengali: 'অন্তর্দৃষ্টি',
      filipino: 'Insight',
    ),
    'col_section_summary_title': l10nEntry(
      english: 'Summary',
      arabic: 'ملخص',
      hindi: 'सारांश',
      urdu: 'خلاصہ',
      bengali: 'সারাংশ',
      filipino: 'Buod',
    ),
    'col_ai_summary_disclaimer': l10nEntry(
      english: CostOfLivingConstants.aiSummaryDisclaimer,
      arabic: 'ملخص الذكاء الاصطناعي يشرح الأرقام الرسمية فقط — ليس نصيحة مالية.',
      hindi: 'AI सारांश केवल आधिकारिक आँकड़े समझाता है — वित्तीय सलाह नहीं।',
      urdu: 'AI خلاصہ صرف سرکاری اعداد و شمار بیان کرتا ہے — مالی مشورہ نہیں۔',
      bengali: 'AI সারাংশ শুধু সরকারি পরিসংখ্যান ব্যাখ্যা করে — আর্থিক পরামর্শ নয়।',
      filipino:
          'AI summary ay opisyal na figures lang — hindi financial advice.',
    ),

    // ── Overview card ─────────────────────────────────────────────────────────
    'col_overview_title': l10nEntry(
      english: 'Qatar overview',
      arabic: 'نظرة عامة على قطر',
      hindi: 'क़तर अवलोकन',
      urdu: 'قطر کا جائزہ',
      bengali: 'কাতার পরিদর্শন',
      filipino: 'Pangkalahatang-ideya ng Qatar',
    ),
    'col_overview_subtitle': l10nEntry(
      english: 'NPC CPI & Numbeo quality index',
      arabic: 'CPI من NPC ومؤشر Numbeo',
      hindi: 'NPC CPI और Numbeo गुणवत्ता सूचकांक',
      urdu: 'NPC CPI اور Numbeo معیار انڈیکس',
      bengali: 'NPC CPI ও Numbeo মান সূচক',
      filipino: 'NPC CPI at Numbeo quality index',
    ),
    'col_general_cpi': l10nEntry(
      english: 'General CPI',
      arabic: 'CPI العام',
      hindi: 'सामान्य CPI',
      urdu: 'عام CPI',
      bengali: 'সাধারণ CPI',
      filipino: 'General CPI',
    ),
    'col_general_cpi_prefix': l10nEntry(
      english: 'General CPI: ',
      arabic: 'CPI العام: ',
      hindi: 'सामान्य CPI: ',
      urdu: 'عام CPI: ',
      bengali: 'সাধারণ CPI: ',
      filipino: 'General CPI: ',
    ),
    'col_qol_rank': l10nEntry(
      english: 'QoL · #{rank}',
      arabic: 'جودة الحياة · #{rank}',
      hindi: 'QoL · #{rank}',
      urdu: 'QoL · #{rank}',
      bengali: 'QoL · #{rank}',
      filipino: 'QoL · #{rank}',
    ),
    'col_numbeo_source': l10nEntry(
      english: 'Numbeo index via NPC · {source}',
      arabic: 'مؤشر Numbeo عبر NPC · {source}',
      hindi: 'NPC के माध्यम से Numbeo सूचकांक · {source}',
      urdu: 'NPC کے ذریعے Numbeo انڈیکس · {source}',
      bengali: 'NPC-এর মাধ্যমে Numbeo সূচক · {source}',
      filipino: 'Numbeo index via NPC · {source}',
    ),

    // ── Category chart ────────────────────────────────────────────────────────
    'col_chart_overline': l10nEntry(
      english: 'Chart',
      arabic: 'رسم بياني',
      hindi: 'चार्ट',
      urdu: 'چارٹ',
      bengali: 'চার্ট',
      filipino: 'Chart',
    ),
    'col_chart_title': l10nEntry(
      english: 'Category index comparison',
      arabic: 'مقارنة مؤشر الفئات',
      hindi: 'श्रेणी सूचकांक तुलना',
      urdu: 'زمرہ انڈیکس موازنہ',
      bengali: 'বিভাগ সূচক তুলনা',
      filipino: 'Paghahambing ng category index',
    ),
    'col_chart_subtitle': l10nEntry(
      english: 'Relative CPI from latest official release',
      arabic: 'CPI النسبي من أحدث إصدار رسمي',
      hindi: 'नवीनतम आधिकारिक रिलीज़ से सापेक्ष CPI',
      urdu: 'تازہ ترین سرکاری ریلیز سے نسبتی CPI',
      bengali: 'সর্বশেষ সরকারি রিলিজ থেকে আপেক্ষিক CPI',
      filipino: 'Relative CPI mula sa pinakabagong opisyal na release',
    ),

    // ── Home card ───────────────────────────────────────────────────────────
    'col_home_title': l10nEntry(
      english: 'Qatar Cost of Living',
      arabic: 'تكلفة المعيشة في قطر',
      hindi: 'क़तर जीवन योग्यता लागत',
      urdu: 'قطر میں معیشت کی لاگت',
      bengali: 'কাতারে জীবনযাত্রার খরচ',
      filipino: 'Cost of Living sa Qatar',
    ),
    'col_home_subtitle': l10nEntry(
      english: 'Official CPI & context',
      arabic: 'CPI الرسمي والسياق',
      hindi: 'आधिकारिक CPI और संदर्भ',
      urdu: 'سرکاری CPI اور سیاق',
      bengali: 'সরকারি CPI ও প্রসঙ্গ',
      filipino: 'Opisyal na CPI at context',
    ),
    'col_data_unavailable': l10nEntry(
      english: 'Data unavailable — tap to retry',
      arabic: 'البيانات غير متاحة — اضغط لإعادة المحاولة',
      hindi: 'डेटा उपलब्ध नहीं — पुनः प्रयास के लिए टैप करें',
      urdu: 'ڈیٹا دستیاب نہیں — دوبارہ کوشش کے لیے ٹیپ کریں',
      bengali: 'ডেটা unavailable — আবার চেষ্টা করতে ট্যাপ করুন',
      filipino: 'Walang data — i-tap para subukang muli',
    ),
    'col_qol_score': l10nEntry(
      english: 'Quality of Life score: {score}',
      arabic: 'درجة جودة الحياة: {score}',
      hindi: 'जीवन गुणवत्ता स्कोर: {score}',
      urdu: 'معیارِ زندگی اسکور: {score}',
      bengali: 'জীবনযাত্রার মান স্কোর: {score}',
      filipino: 'Quality of Life score: {score}',
    ),
    'col_official_data_gov': l10nEntry(
      english: 'Official data.gov.qa',
      arabic: 'data.gov.qa الرسمي',
      hindi: 'आधिकारिक data.gov.qa',
      urdu: 'سرکاری data.gov.qa',
      bengali: 'সরকারি data.gov.qa',
      filipino: 'Opisyal na data.gov.qa',
    ),
    'col_cached_data': l10nEntry(
      english: 'Cached data',
      arabic: 'بيانات مخزّنة',
      hindi: 'कैश्ड डेटा',
      urdu: 'محفوظ ڈیٹا',
      bengali: 'ক্যাশ করা ডেটা',
      filipino: 'Naka-cache na data',
    ),

    // ── Category tiles ────────────────────────────────────────────────────────
    'col_category_index': l10nEntry(
      english: 'Index {index}',
      arabic: 'المؤشر {index}',
      hindi: 'सूचकांक {index}',
      urdu: 'انڈیکس {index}',
      bengali: 'সূচক {index}',
      filipino: 'Index {index}',
    ),
    'col_trend_rising': l10nEntry(
      english: 'Rising',
      arabic: 'صاعد',
      hindi: 'बढ़ रहा',
      urdu: 'بڑھ رہا',
      bengali: 'বাড়ছে',
      filipino: 'Tumataas',
    ),
    'col_trend_falling': l10nEntry(
      english: 'Falling',
      arabic: 'هابط',
      hindi: 'गिर रहा',
      urdu: 'گر رہا',
      bengali: 'কমছে',
      filipino: 'Bumababa',
    ),
    'col_trend_stable': l10nEntry(
      english: 'Stable',
      arabic: 'مستقر',
      hindi: 'स्थिर',
      urdu: 'مستحکم',
      bengali: 'স্থির',
      filipino: 'Stable',
    ),
    'col_change_vs_prior_month': l10nEntry(
      english: '{change}% vs prior month',
      arabic: '{change}% مقابل الشهر السابق',
      hindi: 'पिछले महीने से {change}%',
      urdu: 'پچھلے مہینے سے {change}%',
      bengali: 'আগের মাসের তুলনায় {change}%',
      filipino: '{change}% vs nakaraang buwan',
    ),

    // ── Personal comparison ───────────────────────────────────────────────────
    'col_personal_comparison_empty': l10nEntry(
      english:
          'Add utility or telecom bills in Bill Tracker to see directional '
          'context against official CPI trends.',
      arabic:
          'أضف فواتير المرافق أو الاتصالات في متتبع الفواتير لرؤية سياق '
          'اتجاهي مقابل اتجاهات CPI الرسمية.',
      hindi:
          'Bill Tracker में उपयोगिता या टेलीकॉम बिल जोड़ें ताकि आधिकारिक '
          'CPI रुझानों के मुकाबले दिशात्मक संदर्भ देख सकें।',
      urdu:
          'Bill Tracker میں utility یا telecom بل شامل کریں تاکہ سرکاری '
          'CPI رجحانات کے مقابلے میں سمت کا سیاق دیکھ سکیں۔',
      bengali:
          'Bill Tracker-এ utility বা telecom বিল যোগ করুন যাতে সরকারি '
          'CPI প্রবণতার বিরুদ্ধে দিকনির্দেশক প্রসঙ্গ দেখতে পারেন।',
      filipino:
          'Magdagdag ng utility o telecom bills sa Bill Tracker para makita '
          'ang directional context laban sa opisyal na CPI trends.',
    ),
    'col_personal_comparison_disclaimer': l10nEntry(
      english: CostOfLivingConstants.personalComparisonDisclaimer,
      arabic:
          'سياق اتجاهي فقط. CPI يتتبع مستويات الأسعار الوطنية لسلة قياسية — '
          'وليس فواتيرك الفردية.',
      hindi:
          'केवल दिशात्मक संदर्भ। CPI राष्ट्रीय मूल्य स्तर ट्रैक करता है — '
          'आपके व्यक्तिगत बिल नहीं।',
      urdu:
          'صرف سمت کا سیاق۔ CPI قومی قیمتوں کو ٹریک کرتا ہے — '
          'آپ کے انفرادی بل نہیں۔',
      bengali:
          'শুধু দিকনির্দেশক প্রসঙ্গ। CPI জাতীয় মূল্য স্তর ট্র্যাক করে — '
          'আপনার ব্যক্তিগত বিল নয়।',
      filipino:
          'Directional context lang. CPI ay pambansang presyo — '
          'hindi ang indibidwal mong bills.',
    ),
  };
}
