/// Gold Intelligence — Qatar spot rates, calculator, locker, and alerts.
import 'package:flutter/foundation.dart';
import 'package:raabta/core/l10n/app_locale.dart';
import 'package:raabta/core/l10n/locale_catalog_coverage.dart';
import 'package:raabta/core/l10n/locale_catalog_entry.dart';
import 'package:raabta/features/gold_intelligence/domain/gold_qatar_constants.dart';
import 'package:raabta/features/gold_intelligence/domain/gold_qatar_models.dart';

abstract final class GoldIntelligenceStrings {
  static const supportedLocales = AppLocale.supportedLocales;

  /// Tamil / Malayalam / Nepali legal and finance copy ships English until native review.
  static const keysNeedingProfessionalReview = <String>{
    'ai_disclaimer',
    'market_label',
    'refresh_cadence_label',
    'jewelry_subtitle_necklace',
    'jewelry_subtitle_coin',
    'jewelry_subtitle_bar',
    'calc_making_charge_subtitle',
    'calc_vat_toggle_subtitle',
    'calc_investment_grade_note',
    'calc_composition_summary',
    'calc_unrealised_pl',
    'calc_breakdown_resale_sublabel',
    'alerts_smart_engine_body',
    'alert_display_locker_gain',
    'alert_display_rises_above',
    'alert_display_drops_below',
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

  // ── Lookup helpers ────────────────────────────────────────────────────────

  static String weightUnitLabel(GoldWeightUnit unit, [String locale = 'English']) {
    switch (unit) {
      case GoldWeightUnit.gram:
        return t('weight_unit_gram', locale);
      case GoldWeightUnit.tola:
        return t('weight_unit_tola', locale);
      case GoldWeightUnit.sovereign:
        return t('weight_unit_sovereign', locale);
      case GoldWeightUnit.ounce:
        return t('weight_unit_ounce', locale);
      case GoldWeightUnit.kilogram:
        return t('weight_unit_kilogram', locale);
    }
  }

  static String jewelryTypeLabel(GoldJewelryType type, [String locale = 'English']) {
    switch (type) {
      case GoldJewelryType.necklace:
        return t('jewelry_type_necklace', locale);
      case GoldJewelryType.ring:
        return t('jewelry_type_ring', locale);
      case GoldJewelryType.bracelet:
        return t('jewelry_type_bracelet', locale);
      case GoldJewelryType.coin:
        return t('jewelry_type_coin', locale);
      case GoldJewelryType.bar:
        return t('jewelry_type_bar', locale);
    }
  }

  static String jewelryTypeSubtitle(GoldJewelryType type, [String locale = 'English']) {
    switch (type) {
      case GoldJewelryType.necklace:
        return t('jewelry_subtitle_necklace', locale);
      case GoldJewelryType.ring:
        return t('jewelry_subtitle_ring', locale);
      case GoldJewelryType.bracelet:
        return t('jewelry_subtitle_bracelet', locale);
      case GoldJewelryType.coin:
        return t('jewelry_subtitle_coin', locale);
      case GoldJewelryType.bar:
        return t('jewelry_subtitle_bar', locale);
    }
  }

  static String weightRowLabel(String key, [String locale = 'English']) {
    switch (key) {
      case '1_gram':
        return t('weight_row_1_gram', locale);
      case '8_gram_sovereign':
        return t('weight_row_8_gram_sovereign', locale);
      case '10_grams':
        return t('weight_row_10_grams', locale);
      case 'tola':
        return t('weight_row_tola', locale);
      case 'ounce':
        return t('weight_row_ounce', locale);
      case '100_grams':
        return t('weight_row_100_grams', locale);
      case 'kilogram':
        return t('weight_row_kilogram', locale);
      default:
        return key;
    }
  }

  static String popularWeightLabel(String key, [String locale = 'English']) {
    switch (key) {
      case '1g':
        return t('popular_weight_1g', locale);
      case '8g_sovereign':
        return t('popular_weight_8g_sovereign', locale);
      case '10g':
        return t('popular_weight_10g', locale);
      case 'tola':
        return t('popular_weight_tola', locale);
      default:
        return key;
    }
  }

  static String karatMetaLabel(int purity, [String locale = 'English']) {
    switch (purity) {
      case 24:
        return t('karat_meta_24', locale);
      case 22:
        return t('karat_meta_22', locale);
      case 21:
        return t('karat_meta_21', locale);
      case 18:
        return t('karat_meta_18', locale);
      default:
        return '$purity K';
    }
  }

  static String? karatBadgeLabel(int purity, [String locale = 'English']) {
    switch (purity) {
      case 24:
        return t('karat_badge_investment', locale);
      case 22:
        return t('karat_badge_popular', locale);
      default:
        return null;
    }
  }

  static String chartRangeLabel(GoldChartRange range, [String locale = 'English']) {
    switch (range) {
      case GoldChartRange.today:
        return t('chart_range_today', locale);
      case GoldChartRange.d7:
        return t('chart_range_7d', locale);
      case GoldChartRange.d30:
        return t('chart_range_30d', locale);
      case GoldChartRange.m6:
        return t('chart_range_6m', locale);
      case GoldChartRange.y1:
        return t('chart_range_1y', locale);
    }
  }

  static final _catalog = <String, Map<String, String>>{
    // ── Domain constants ────────────────────────────────────────────────────
    'ai_disclaimer': l10nEntry(
      english: 'Not financial advice — market reference data only',
      arabic: 'ليست نصيحة مالية — بيانات مرجعية للسوق فقط',
      hindi: 'वित्तीय सलाह नहीं — केवल बाज़ार संदर्भ डेटा',
      urdu: 'مالی مشورہ نہیں — صرف مارکیٹ حوالہ ڈیٹا',
      bengali: 'আর্থিক পরামর্শ নয় — শুধু বাজারের তথ্য',
      filipino: 'Hindi payong pinansyal — sanggunian lang sa merkado',
    ),
    'market_label': l10nEntry(
      english: 'Doha Gold Souq · Qatar (QAR)',
      arabic: 'سوق الذهب في الدوحة · قطر (ريال قطري)',
      hindi: 'दोहा गोल्ड सूक · क़तर (QAR)',
      urdu: 'دوحہ گولڈ سوق · قطر (QAR)',
      bengali: 'দোহা গোল্ড সূক · কাতার (QAR)',
      filipino: 'Doha Gold Souq · Qatar (QAR)',
    ),
    'refresh_cadence_label': l10nEntry(
      english:
          'Rates refresh about every 30 minutes during the day (Qatar time), '
          'converted from international spot via the QAR 3.64 USD peg.',
      arabic:
          'تُحدَّث الأسعار كل نحو 30 دقيقة نهاراً (بتوقيت قطر)، '
          'محوّلة من السعر الفوري الدولي عبر ربط الريال 3.64 بالدولار.',
      hindi:
          'दिन में लगभग हर 30 मिनट (क़तर समय) दरें अपडेट होती हैं, '
          'QAR 3.64 USD पेग के ज़रिए अंतरराष्ट्रीय स्पॉट से परिवर्तित।',
      urdu:
          'دن میں تقریباً ہر 30 منٹ (قطر وقت) نرخ اپ ڈیٹ ہوتے ہیں، '
          'QAR 3.64 USD پیگ کے ذریعے بین الاقوامی اسپاٹ سے تبدیل۔',
      bengali:
          'দিনে প্রায় প্রতি 30 মিনিটে (কatar সময়) হার আপডেট হয়, '
          'QAR 3.64 USD পেগের মাধ্যমে আন্তর্জাতিক স্পট থেকে রূপান্তরিত।',
      filipino:
          'Ina-update ang rate tuwing ~30 min (Qatar time), '
          'mula sa international spot via QAR 3.64 USD peg.',
    ),

    // ── Weight rows ─────────────────────────────────────────────────────────
    'weight_row_1_gram': l10nEntry(
      english: '1 Gram',
      arabic: '1 غرام',
      hindi: '1 ग्राम',
      urdu: '1 گرام',
      bengali: '১ গ্রাম',
      filipino: '1 Gram',
    ),
    'weight_row_8_gram_sovereign': l10nEntry(
      english: '8 Grams (Sovereign)',
      arabic: '8 غرامات (سوفيرين)',
      hindi: '8 ग्राम (सॉवरेन)',
      urdu: '8 گرام (سوفیرین)',
      bengali: '৮ গ্রাম (সোভারিয়ন)',
      filipino: '8 Grams (Sovereign)',
    ),
    'weight_row_10_grams': l10nEntry(
      english: '10 Grams',
      arabic: '10 غرامات',
      hindi: '10 ग्राम',
      urdu: '10 گرام',
      bengali: '১০ গ্রাম',
      filipino: '10 Grams',
    ),
    'weight_row_tola': l10nEntry(
      english: 'Tola (11.6638 g)',
      arabic: 'تولة (11.6638 غ)',
      hindi: 'तोला (11.6638 ग्राम)',
      urdu: 'تولہ (11.6638 گرام)',
      bengali: 'তোলা (11.6638 গ্রাম)',
      filipino: 'Tola (11.6638 g)',
    ),
    'weight_row_ounce': l10nEntry(
      english: 'Ounce (31.1035 g)',
      arabic: 'أونصة (31.1035 غ)',
      hindi: 'औंस (31.1035 ग्राम)',
      urdu: 'اونس (31.1035 گرام)',
      bengali: 'আউন্স (31.1035 গ্রাম)',
      filipino: 'Ounce (31.1035 g)',
    ),
    'weight_row_100_grams': l10nEntry(
      english: '100 Grams',
      arabic: '100 غرام',
      hindi: '100 ग्राम',
      urdu: '100 گرام',
      bengali: '১০০ গ্রাম',
      filipino: '100 Grams',
    ),
    'weight_row_kilogram': l10nEntry(
      english: 'Kilogram',
      arabic: 'كيلوغرام',
      hindi: 'किलोग्राम',
      urdu: 'کلوگرام',
      bengali: 'কিলোগ্রাম',
      filipino: 'Kilogram',
    ),

    // ── Weight row short chips ──────────────────────────────────────────────
    'weight_row_short_1g': l10nEntry(
      english: '1g',
      arabic: '1غ',
      hindi: '1g',
      urdu: '1g',
      bengali: '1g',
      filipino: '1g',
    ),
    'weight_row_short_8g': l10nEntry(
      english: '8g',
      arabic: '8غ',
      hindi: '8g',
      urdu: '8g',
      bengali: '8g',
      filipino: '8g',
    ),
    'weight_row_short_10g': l10nEntry(
      english: '10g',
      arabic: '10غ',
      hindi: '10g',
      urdu: '10g',
      bengali: '10g',
      filipino: '10g',
    ),
    'weight_row_short_tola': l10nEntry(
      english: 'Tola',
      arabic: 'تولة',
      hindi: 'तोला',
      urdu: 'تولہ',
      bengali: 'তোলা',
      filipino: 'Tola',
    ),
    'weight_row_short_oz': l10nEntry(
      english: 'Oz',
      arabic: 'أونصة',
      hindi: 'Oz',
      urdu: 'اونس',
      bengali: 'আউন্স',
      filipino: 'Oz',
    ),
    'weight_row_short_100g': l10nEntry(
      english: '100g',
      arabic: '100غ',
      hindi: '100g',
      urdu: '100g',
      bengali: '100g',
      filipino: '100g',
    ),
    'weight_row_short_1kg': l10nEntry(
      english: '1kg',
      arabic: '1كغ',
      hindi: '1kg',
      urdu: '1kg',
      bengali: '1kg',
      filipino: '1kg',
    ),
    'weight_panel_live_base': l10nEntry(
      english: '{grams} g · live 24K base',
      arabic: '{grams} غ · أساس 24 قيراط مباشر',
      hindi: '{grams} g · लाइव 24K आधार',
      urdu: '{grams} g · لائیو 24K بیس',
      bengali: '{grams} g · লাইভ 24K বেস',
      filipino: '{grams} g · live 24K base',
    ),

    // ── Popular weights ─────────────────────────────────────────────────────
    'popular_weight_1g': l10nEntry(
      english: '1g',
      arabic: '1غ',
      hindi: '1g',
      urdu: '1g',
      bengali: '1g',
      filipino: '1g',
    ),
    'popular_weight_8g_sovereign': l10nEntry(
      english: '8g Sovereign',
      arabic: '8غ Sovereign',
      hindi: '8g सॉवरेन',
      urdu: '8g Sovereign',
      bengali: '8g Sovereign',
      filipino: '8g Sovereign',
    ),
    'popular_weight_10g': l10nEntry(
      english: '10g',
      arabic: '10غ',
      hindi: '10g',
      urdu: '10g',
      bengali: '10g',
      filipino: '10g',
    ),
    'popular_weight_tola': l10nEntry(
      english: 'Tola',
      arabic: 'تولة',
      hindi: 'तोला',
      urdu: 'تولہ',
      bengali: 'তোলা',
      filipino: 'Tola',
    ),

    // ── Weight units ────────────────────────────────────────────────────────
    'weight_unit_gram': l10nEntry(
      english: 'Gram',
      arabic: 'غرام',
      hindi: 'ग्राम',
      urdu: 'گرام',
      bengali: 'গ্রাম',
      filipino: 'Gram',
    ),
    'weight_unit_tola': l10nEntry(
      english: 'Tola',
      arabic: 'تولة',
      hindi: 'तोला',
      urdu: 'تولہ',
      bengali: 'তোলা',
      filipino: 'Tola',
    ),
    'weight_unit_sovereign': l10nEntry(
      english: 'Sovereign (8g)',
      arabic: 'Sovereign (8غ)',
      hindi: 'सॉवरेन (8g)',
      urdu: 'Sovereign (8g)',
      bengali: 'Sovereign (8g)',
      filipino: 'Sovereign (8g)',
    ),
    'weight_unit_ounce': l10nEntry(
      english: 'Ounce',
      arabic: 'أونصة',
      hindi: 'औंस',
      urdu: 'اونس',
      bengali: 'আউন্স',
      filipino: 'Ounce',
    ),
    'weight_unit_kilogram': l10nEntry(
      english: 'Kilogram',
      arabic: 'كيلوغرام',
      hindi: 'किलोग्राम',
      urdu: 'کلوگرام',
      bengali: 'কিলোগ্রাম',
      filipino: 'Kilogram',
    ),

    // ── Jewelry types ───────────────────────────────────────────────────────
    'jewelry_type_necklace': l10nEntry(
      english: 'Necklace',
      arabic: 'قلادة',
      hindi: 'हार',
      urdu: 'ہار',
      bengali: 'নেকলেস',
      filipino: 'Kuwintas',
    ),
    'jewelry_type_ring': l10nEntry(
      english: 'Ring',
      arabic: 'خاتم',
      hindi: 'अंगूठी',
      urdu: 'انگوٹھی',
      bengali: 'আংটি',
      filipino: 'Singsing',
    ),
    'jewelry_type_bracelet': l10nEntry(
      english: 'Bracelet',
      arabic: 'سوار',
      hindi: 'कंगन',
      urdu: 'کنگن',
      bengali: 'ব্রেসলেট',
      filipino: 'Pulseras',
    ),
    'jewelry_type_coin': l10nEntry(
      english: 'Coin',
      arabic: 'عملة ذهبية',
      hindi: 'सिक्का',
      urdu: 'سکہ',
      bengali: 'কয়েন',
      filipino: 'Barya',
    ),
    'jewelry_type_bar': l10nEntry(
      english: 'Bar',
      arabic: 'سبيكة',
      hindi: 'बार',
      urdu: 'بار',
      bengali: 'বার',
      filipino: 'Bar',
    ),
    'jewelry_subtitle_necklace': l10nEntry(
      english: 'Often 10–20% in souq',
      arabic: 'غالباً 10–20% في السوق',
      hindi: 'सूक में अक्सर 10–20% मेकिंग',
      urdu: 'سوق میں اکثر 10–20%',
      bengali: 'সূকে প্রায় 10–20%',
      filipino: 'Kadalasang 10–20% sa souq',
    ),
    'jewelry_subtitle_ring': l10nEntry(
      english: 'Compact piece',
      arabic: 'قطعة صغيرة',
      hindi: 'छोटा टुकड़ा',
      urdu: 'چھوٹا ٹوکرا',
      bengali: 'ছোট টুক্রো',
      filipino: 'Maliit na piraso',
    ),
    'jewelry_subtitle_bracelet': l10nEntry(
      english: 'Medium labour',
      arabic: 'مصنعية متوسطة',
      hindi: 'मध्यम श्रम शुल्क',
      urdu: 'درمیانہ مزدوری',
      bengali: 'মাঝারি শ্রম',
      filipino: 'Katamtamang labour',
    ),
    'jewelry_subtitle_coin': l10nEntry(
      english: 'VAT-free metal',
      arabic: 'معدن معفى من ضريبة القيمة المضافة',
      hindi: 'VAT-मुक्त धातु',
      urdu: 'VAT سے مستثنیٰ دھات',
      bengali: 'VAT-মুক্ত ধাতু',
      filipino: 'Metal na walang VAT',
    ),
    'jewelry_subtitle_bar': l10nEntry(
      english: 'Investment grade',
      arabic: 'درجة استثمارية',
      hindi: 'निवेश श्रेणी',
      urdu: 'سرمایہ کاری گریڈ',
      bengali: 'বিনিয়োগ মান',
      filipino: 'Investment grade',
    ),

    // ── Karat meta & badges ─────────────────────────────────────────────────
    'karat_meta_24': l10nEntry(
      english: 'Pure gold',
      arabic: 'ذهب خالص',
      hindi: 'शुद्ध सोना',
      urdu: 'خالص سونا',
      bengali: 'খাঁটি সোনা',
      filipino: 'Purong ginto',
    ),
    'karat_meta_22': l10nEntry(
      english: 'Jewellery standard',
      arabic: 'معيار المجوهرات',
      hindi: 'गहने का मानक',
      urdu: 'زیورات کا معیار',
      bengali: 'গহনার মান',
      filipino: 'Pamantayan sa alahas',
    ),
    'karat_meta_21': l10nEntry(
      english: 'Gulf retail',
      arabic: 'تجزئة الخليج',
      hindi: 'खाड़ी रिटेल',
      urdu: 'خلیجی ریٹیل',
      bengali: 'খাড়ি রিটেইল',
      filipino: 'Gulf retail',
    ),
    'karat_meta_18': l10nEntry(
      english: 'Daily wear',
      arabic: 'للاستخدام اليومي',
      hindi: 'रोज़ पहनने के लिए',
      urdu: 'روزانہ پہننے کے لیے',
      bengali: 'দৈনন্দিন পরার',
      filipino: 'Pang-araw-araw',
    ),
    'karat_badge_investment': l10nEntry(
      english: 'Investment',
      arabic: 'استثمار',
      hindi: 'निवेश',
      urdu: 'سرمایہ کاری',
      bengali: 'বিনিয়োগ',
      filipino: 'Investment',
    ),
    'karat_badge_popular': l10nEntry(
      english: 'Popular',
      arabic: 'الأكثر شيوعاً',
      hindi: 'लोकप्रिय',
      urdu: 'مقبول',
      bengali: 'জনপ্রিয়',
      filipino: 'Popular',
    ),

    // ── Chart ranges ────────────────────────────────────────────────────────
    'chart_range_today': l10nEntry(
      english: 'Today',
      arabic: 'اليوم',
      hindi: 'आज',
      urdu: 'آج',
      bengali: 'আজ',
      filipino: 'Ngayon',
    ),
    'chart_range_7d': l10nEntry(
      english: '7D',
      arabic: '7 أيام',
      hindi: '7D',
      urdu: '7D',
      bengali: '7D',
      filipino: '7D',
    ),
    'chart_range_30d': l10nEntry(
      english: '30D',
      arabic: '30 يوماً',
      hindi: '30D',
      urdu: '30D',
      bengali: '30D',
      filipino: '30D',
    ),
    'chart_range_6m': l10nEntry(
      english: '6M',
      arabic: '6 أشهر',
      hindi: '6M',
      urdu: '6M',
      bengali: '6M',
      filipino: '6M',
    ),
    'chart_range_1y': l10nEntry(
      english: '1Y',
      arabic: 'سنة',
      hindi: '1Y',
      urdu: '1Y',
      bengali: '1Y',
      filipino: '1Y',
    ),

    // ── Dashboard ───────────────────────────────────────────────────────────
    'dashboard_title': l10nEntry(
      english: 'Gold Intelligence',
      arabic: 'ذكاء الذهب',
      hindi: 'गोल्ड इंटेलिजेंस',
      urdu: 'گولڈ انٹیلیجنس',
      bengali: 'গোল্ড ইন্টেলিজেন্স',
      filipino: 'Gold Intelligence',
    ),
    'dashboard_subtitle': l10nEntry(
      english: 'Live spot, calculator, locker & price alerts',
      arabic: 'السعر المباشر، الحاسبة، الخزنة والتنبيهات',
      hindi: 'लाइव स्पॉट, कैलकुलेटर, लॉकर और कीमत अलर्ट',
      urdu: 'لائیو اسپاٹ، کیلکولیٹر، لاکر اور قیمت الرٹ',
      bengali: 'লাইভ স্পট, ক্যালকুলেটর, লকার ও দামের সতর্কতা',
      filipino: 'Live spot, calculator, locker at price alerts',
    ),
    'tab_market': l10nEntry(
      english: 'Market',
      arabic: 'السوق',
      hindi: 'बाज़ार',
      urdu: 'مارکیٹ',
      bengali: 'বাজার',
      filipino: 'Merkado',
    ),
    'tab_calculator': l10nEntry(
      english: 'Calculator',
      arabic: 'الحاسبة',
      hindi: 'कैलकुलेटर',
      urdu: 'کیلکولیٹر',
      bengali: 'ক্যালকুলেটর',
      filipino: 'Calculator',
    ),
    'tab_locker': l10nEntry(
      english: 'Locker',
      arabic: 'الخزنة',
      hindi: 'लॉकर',
      urdu: 'لاکر',
      bengali: 'লকার',
      filipino: 'Locker',
    ),
    'tab_alerts': l10nEntry(
      english: 'Alerts',
      arabic: 'التنبيهات',
      hindi: 'अलर्ट',
      urdu: 'الرٹس',
      bengali: 'সতর্কতা',
      filipino: 'Mga alerto',
    ),
    'refresh_live_rate_tooltip': l10nEntry(
      english: 'Refresh live rate',
      arabic: 'تحديث السعر المباشر',
      hindi: 'लाइव दर रिफ्रेश करें',
      urdu: 'لائیو نرخ ریفریش کریں',
      bengali: 'লাইভ হার রিফ্রেশ করুন',
      filipino: 'I-refresh ang live rate',
    ),
    'purity_ladder_title': l10nEntry(
      english: 'Purity Ladder',
      arabic: 'سلم النقاوة',
      hindi: 'शुद्धता सीढ़ी',
      urdu: 'خالصیت کی سیڑھی',
      bengali: 'বিশুদ্ধতার সিঁড়ি',
      filipino: 'Purity Ladder',
    ),
    'purity_ladder_subtitle': l10nEntry(
      english: 'Per-gram rates across common karats',
      arabic: 'أسعار الغرام عبر العيارات الشائعة',
      hindi: 'सामान्य कैरेट पर प्रति ग्राम दर',
      urdu: 'عام قیراط پر فی گرام نرخ',
      bengali: 'সাধারণ ক্যারেটে প্রতি গ্রাম হার',
      filipino: 'Rate bawat gramo sa karat',
    ),
    'value_by_weight_title': l10nEntry(
      english: 'Value by Weight',
      arabic: 'القيمة حسب الوزن',
      hindi: 'वज़न के अनुसार मूल्य',
      urdu: 'وزن کے حساب سے قیمت',
      bengali: 'ওজন অনুযায়ী মূল্য',
      filipino: 'Halaga ayon sa timbang',
    ),
    'value_by_weight_subtitle': l10nEntry(
      english: 'Tap a unit — all karats update instantly',
      arabic: 'اضغط وحدة — تتحدث كل العيارات فوراً',
      hindi: 'इकाई चुनें — सभी कैरेट तुरंत अपडेट',
      urdu: 'یونٹ ٹیپ کریں — تمام قیراط فوری اپ ڈیٹ',
      bengali: 'একটি ইউনিট ট্যাপ করুন — সব ক্যারেট আপডেট',
      filipino: 'Pindutin ang unit — lahat ng karat mag-update',
    ),
    'market_movement_title': l10nEntry(
      english: 'Market Movement',
      arabic: 'حركة السوق',
      hindi: 'बाज़ार गति',
      urdu: 'مارکیٹ کی حرکت',
      bengali: 'বাজারের গতি',
      filipino: 'Galaw ng merkado',
    ),
    'market_movement_subtitle': l10nEntry(
      english: 'Track intraday and historical trends',
      arabic: 'تتبع الاتجاهات اليومية والتاريخية',
      hindi: 'दिनभर और ऐतिहासिक रुझान देखें',
      urdu: 'دن بھر اور تاریخی رجحانات دیکھیں',
      bengali: 'দিনভিত্তিক ও ঐতিহাসিক প্রবণতা',
      filipino: 'Subaybayan ang intraday at history',
    ),
    'retry': l10nEntry(
      english: 'Retry',
      arabic: 'إعادة المحاولة',
      hindi: 'पुनः प्रयास',
      urdu: 'دوبارہ کوشش',
      bengali: 'আবার চেষ্টা',
      filipino: 'Subukan muli',
    ),
    'error_load_gold_data': l10nEntry(
      english: 'Could not load gold data',
      arabic: 'تعذّر تحميل بيانات الذهب',
      hindi: 'गोल्ड डेटा लोड नहीं हो सका',
      urdu: 'گولڈ ڈیٹا لوڈ نہیں ہو سکا',
      bengali: 'সোনার তথ্য লোড হয়নি',
      filipino: 'Hindi ma-load ang gold data',
    ),
    'rate_unavailable': l10nEntry(
      english: 'Rate unavailable',
      arabic: 'السعر غير متاح',
      hindi: 'दर उपलब्ध नहीं',
      urdu: 'نرخ دستیاب نہیں',
      bengali: 'হার উপলব্ধ নয়',
      filipino: 'Walang rate',
    ),
    'ai_insight_title': l10nEntry(
      english: 'AI Insight',
      arabic: 'رؤية الذكاء الاصطناعي',
      hindi: 'AI इनसाइट',
      urdu: 'AI بصیرت',
      bengali: 'AI ইনসাইট',
      filipino: 'AI Insight',
    ),
    'faq_title': l10nEntry(
      english: 'Frequently Asked Questions',
      arabic: 'الأسئلة الشائعة',
      hindi: 'अक्सर पूछे जाने वाले प्रश्न',
      urdu: 'اکثر پوچھے گئے سوالات',
      bengali: 'প্রায়শই জিজ্ঞাসিত প্রশ্ন',
      filipino: 'Mga Madalas Itanong',
    ),

    // ── Home card ───────────────────────────────────────────────────────────
    'home_card_title': l10nEntry(
      english: 'Qatar Gold (24K)',
      arabic: 'ذهب قطر (24 قيراط)',
      hindi: 'क़तर गोल्ड (24K)',
      urdu: 'قطر گولڈ (24K)',
      bengali: 'কাতার সোনা (24K)',
      filipino: 'Qatar Gold (24K)',
    ),
    'home_price_per_gram': l10nEntry(
      english: 'QAR {price} / g',
      arabic: '{price} ر.ق / غ',
      hindi: 'QAR {price} / g',
      urdu: 'QAR {price} / g',
      bengali: 'QAR {price} / g',
      filipino: 'QAR {price} / g',
    ),
    'home_rate_unavailable_retry': l10nEntry(
      english: 'Rate unavailable — tap to retry',
      arabic: 'السعر غير متاح — اضغط لإعادة المحاولة',
      hindi: 'दर उपलब्ध नहीं — पुनः प्रयास के लिए टैप करें',
      urdu: 'نرخ دستیاب نہیں — دوبارہ کوشش کے لیے ٹیپ کریں',
      bengali: 'হার নেই — আবার চেষ্টা করতে ট্যাপ করুন',
      filipino: 'Walang rate — i-tap para subukan muli',
    ),
    'home_cached_rate_refresh': l10nEntry(
      english: 'Cached rate — tap to refresh',
      arabic: 'سعر مخزّن — اضغط للتحديث',
      hindi: 'कैश्ड दर — रिफ्रेश के लिए टैप करें',
      urdu: 'کیشڈ نرخ — ریفریش کے لیے ٹیپ کریں',
      bengali: 'ক্যাশড হার — রিফ্রেশ করতে ট্যাপ করুন',
      filipino: 'Cached rate — i-tap para i-refresh',
    ),
    'home_indicative_spot': l10nEntry(
      english: 'Indicative spot',
      arabic: 'سعر فوري إرشادي',
      hindi: 'संकेतक स्पॉट',
      urdu: 'اشاریہ اسپاٹ',
      bengali: 'ইঙ্গিতমূলক স্পট',
      filipino: 'Indicative spot',
    ),
    'home_delta_vs_yesterday': l10nEntry(
      english: '{delta} QAR vs yesterday',
      arabic: '{delta} ر.ق مقارنة بالأمس',
      hindi: 'कल से {delta} QAR',
      urdu: 'کل سے {delta} QAR',
      bengali: 'গতকালের তুলনায় {delta} QAR',
      filipino: '{delta} QAR vs kahapon',
    ),
    'home_today_hl': l10nEntry(
      english: 'Today H {high} · L {low} QAR/g',
      arabic: 'اليوم أعلى {high} · أدنى {low} ر.ق/غ',
      hindi: 'आज H {high} · L {low} QAR/g',
      urdu: 'آج H {high} · L {low} QAR/g',
      bengali: 'আজ H {high} · L {low} QAR/g',
      filipino: 'Ngayon H {high} · L {low} QAR/g',
    ),
    'home_updated_at': l10nEntry(
      english: 'Updated {time}',
      arabic: 'تم التحديث {time}',
      hindi: 'अपडेट {time}',
      urdu: 'اپ ڈیٹ {time}',
      bengali: 'আপডেট {time}',
      filipino: 'Na-update {time}',
    ),

    // ── Hero card ───────────────────────────────────────────────────────────
    'hero_live_spot': l10nEntry(
      english: 'LIVE SPOT',
      arabic: 'سعر فوري مباشر',
      hindi: 'लाइव स्पॉट',
      urdu: 'لائیو اسپاٹ',
      bengali: 'লাইভ স্পট',
      filipino: 'LIVE SPOT',
    ),
    'hero_qatar_24k': l10nEntry(
      english: 'QATAR 24K',
      arabic: 'قطر 24 قيراط',
      hindi: 'QATAR 24K',
      urdu: 'QATAR 24K',
      bengali: 'QATAR 24K',
      filipino: 'QATAR 24K',
    ),
    'hero_per_gram_24k': l10nEntry(
      english: 'per gram · 24 karat',
      arabic: 'لكل غرام · 24 قيراط',
      hindi: 'प्रति ग्राम · 24 कैरेट',
      urdu: 'فی گرام · 24 قیراط',
      bengali: 'প্রতি গ্রাম · 24 ক্যারেট',
      filipino: 'bawat gramo · 24 karat',
    ),
    'hero_today_high': l10nEntry(
      english: 'Today high',
      arabic: 'أعلى اليوم',
      hindi: 'आज का उच्च',
      urdu: 'آج کا زیادہ',
      bengali: 'আজকের সর্বোচ্চ',
      filipino: 'Mataas ngayon',
    ),
    'hero_today_low': l10nEntry(
      english: 'Today low',
      arabic: 'أدنى اليوم',
      hindi: 'आज का निम्न',
      urdu: 'آج کا کم',
      bengali: 'আজকের সর্বনিম্ন',
      filipino: 'Mababa ngayon',
    ),
    'hero_cached_rate_pull': l10nEntry(
      english: 'Cached rate — pull to refresh',
      arabic: 'سعر مخزّن — اسحب للتحديث',
      hindi: 'कैश्ड दर — रिफ्रेश के लिए खींचें',
      urdu: 'کیشڈ نرخ — ریفریش کے لیے کھینچیں',
      bengali: 'ক্যাশড হার — রিফ্রেশ করতে টানুন',
      filipino: 'Cached rate — hilahin para i-refresh',
    ),
    'hero_updated_at': l10nEntry(
      english: 'Updated {datetime}',
      arabic: 'تم التحديث {datetime}',
      hindi: 'अपडेट {datetime}',
      urdu: 'اپ ڈیٹ {datetime}',
      bengali: 'আপডেট {datetime}',
      filipino: 'Na-update {datetime}',
    ),

    // ── Trend chart ─────────────────────────────────────────────────────────
    'chart_low': l10nEntry(
      english: 'Low',
      arabic: 'أدنى',
      hindi: 'निम्न',
      urdu: 'کم',
      bengali: 'নিম্ন',
      filipino: 'Mababa',
    ),
    'chart_high': l10nEntry(
      english: 'High',
      arabic: 'أعلى',
      hindi: 'उच्च',
      urdu: 'زیادہ',
      bengali: 'উচ্চ',
      filipino: 'Mataas',
    ),
    'chart_subtitle_per_gram': l10nEntry(
      english: '24K per gram · {range}',
      arabic: '24 قيراط للغرام · {range}',
      hindi: '24K प्रति ग्राम · {range}',
      urdu: '24K فی گرام · {range}',
      bengali: '24K প্রতি গ্রাম · {range}',
      filipino: '24K bawat gramo · {range}',
    ),
    'chart_empty_intraday': l10nEntry(
      english: 'Intraday curve fills in as live rates refresh',
      arabic: 'تُملأ منحنى اليوم مع تحديث الأسعار المباشرة',
      hindi: 'लाइव दर रिफ्रेश होने पर दिन का ग्राफ भरता है',
      urdu: 'لائیو نرخ ریفریش پر دن کا گراف بھرتا ہے',
      bengali: 'লাইভ হার আপডেট হলে দিনের গ্রাফ পূর্ণ হয়',
      filipino: 'Mapupuno ang intraday curve habang nagre-refresh ang rate',
    ),
    'chart_empty_history': l10nEntry(
      english: 'History builds over the next few days',
      arabic: 'يُبنى السجل خلال الأيام القادمة',
      hindi: 'अगले कुछ दिनों में इतिहास बनेगा',
      urdu: 'اگلے چند دنوں میں تاریخ بنے گی',
      bengali: 'আগামী কয়েক দিনে ইতিহাস তৈরি হবে',
      filipino: 'Magbu-build ang history sa susunod na araw',
    ),

    // ── Alerts panel ────────────────────────────────────────────────────────
    'alerts_sign_in': l10nEntry(
      english: 'Sign in to set gold alerts',
      arabic: 'سجّل الدخول لتعيين تنبيهات الذهب',
      hindi: 'गोल्ड अलर्ट सेट करने के लिए साइन इन करें',
      urdu: 'گولڈ الرٹس کے لیے سائن ان کریں',
      bengali: 'সোনার সতর্কতার জন্য সাইন ইন করুন',
      filipino: 'Mag-sign in para sa gold alerts',
    ),
    'alerts_price_saved': l10nEntry(
      english: 'Price alert saved — smart push enabled',
      arabic: 'تم حفظ تنبيه السعر — الإشعار الذكي مفعّل',
      hindi: 'कीमत अलर्ट सहेजा — स्मार्ट पुश सक्षम',
      urdu: 'قیمت الرٹ محفوظ — سمارٹ پش فعال',
      bengali: 'দামের সতর্কতা সংরক্ষিত — স্মার্ট পুশ চালু',
      filipino: 'Na-save ang price alert — smart push on',
    ),
    'alerts_gain_saved': l10nEntry(
      english: 'Gain alert saved',
      arabic: 'تم حفظ تنبيه الربح',
      hindi: 'लाभ अलर्ट सहेजा',
      urdu: 'منافع الرٹ محفوظ',
      bengali: 'লাভের সতর্কতা সংরক্ষিত',
      filipino: 'Na-save ang gain alert',
    ),
    'alerts_save_failed': l10nEntry(
      english: 'Could not save alert',
      arabic: 'تعذّر حفظ التنبيه',
      hindi: 'अलर्ट सहेजा नहीं जा सका',
      urdu: 'الرٹ محفوظ نہیں ہو سکا',
      bengali: 'সতর্কতা সংরক্ষণ হয়নি',
      filipino: 'Hindi ma-save ang alert',
    ),
    'alerts_price_alert_title': l10nEntry(
      english: 'Price alert',
      arabic: 'تنبيه السعر',
      hindi: 'कीमत अलर्ट',
      urdu: 'قیمت الرٹ',
      bengali: 'দামের সতর্কতা',
      filipino: 'Price alert',
    ),
    'alerts_price_alert_subtitle': l10nEntry(
      english: 'Notify when karat rate crosses your target',
      arabic: 'أبلغني عند تجاوز سعر العيار هدفك',
      hindi: 'कैरेट दर आपके लक्ष्य को पार करे तो सूचित करें',
      urdu: 'جب قیراط نرخ آپ کے ہدف سے گزرے تو مطلع کریں',
      bengali: 'ক্যারেট হার লক্ষ্য পার হলে জানান',
      filipino: 'Abisuhan kapag tumawid ang karat sa target mo',
    ),
    'alerts_live_rate': l10nEntry(
      english: 'Live {purity}K: QAR {price}/g',
      arabic: 'مباشر {purity}K: {price} ر.ق/غ',
      hindi: 'लाइव {purity}K: QAR {price}/g',
      urdu: 'لائیو {purity}K: QAR {price}/g',
      bengali: 'লাইভ {purity}K: QAR {price}/g',
      filipino: 'Live {purity}K: QAR {price}/g',
    ),
    'alerts_drops_below': l10nEntry(
      english: 'Drops below',
      arabic: 'ينخفض دون',
      hindi: 'नीचे गिरे',
      urdu: 'نیچے گرے',
      bengali: 'নিচে নামলে',
      filipino: 'Bumaba sa',
    ),
    'alerts_rises_above': l10nEntry(
      english: 'Rises above',
      arabic: 'يرتفع فوق',
      hindi: 'ऊपर बढ़े',
      urdu: 'اوپر بڑھے',
      bengali: 'উপরে উঠলে',
      filipino: 'Tumaas sa',
    ),
    'alerts_target_label': l10nEntry(
      english: 'Target (QAR / g)',
      arabic: 'الهدف (ر.ق / غ)',
      hindi: 'लक्ष्य (QAR / g)',
      urdu: 'ہدف (QAR / g)',
      bengali: 'লক্ষ্য (QAR / g)',
      filipino: 'Target (QAR / g)',
    ),
    'alerts_saving': l10nEntry(
      english: 'Saving…',
      arabic: 'جاري الحفظ…',
      hindi: 'सहेजा जा रहा…',
      urdu: 'محفوظ ہو رہا…',
      bengali: 'সংরক্ষণ হচ্ছে…',
      filipino: 'Sine-save…',
    ),
    'alerts_enable_price': l10nEntry(
      english: 'Enable price alert',
      arabic: 'تفعيل تنبيه السعر',
      hindi: 'कीमत अलर्ट सक्षम करें',
      urdu: 'قیمت الرٹ فعال کریں',
      bengali: 'দামের সতর্কতা চালু করুন',
      filipino: 'I-enable ang price alert',
    ),
    'alerts_portfolio_gain_title': l10nEntry(
      english: 'Portfolio gain alert',
      arabic: 'تنبيه ربح المحفظة',
      hindi: 'पोर्टफोलियो लाभ अलर्ट',
      urdu: 'پورٹ فولیو منافع الرٹ',
      bengali: 'পোর্টফোলিও লাভের সতর্কতা',
      filipino: 'Portfolio gain alert',
    ),
    'alerts_portfolio_gain_subtitle': l10nEntry(
      english: 'When locker total gain exceeds target',
      arabic: 'عند تجاوز إجمالي ربح الخزنة الهدف',
      hindi: 'जब लॉकर का कुल लाभ लक्ष्य से अधिक हो',
      urdu: 'جب لاکر کا کل منافع ہدف سے زیادہ ہو',
      bengali: 'লকারের মোট লাভ লক্ষ্য ছাড়ালে',
      filipino: 'Kapag lumampas ang locker gain sa target',
    ),
    'alerts_gain_threshold_label': l10nEntry(
      english: 'Notify when gain exceeds (QAR)',
      arabic: 'أبلغني عند تجاوز الربح (ر.ق)',
      hindi: 'लाभ अधिक होने पर सूचित करें (QAR)',
      urdu: 'منافع بڑھنے پر مطلع کریں (QAR)',
      bengali: 'লাভ বাড়লে জানান (QAR)',
      filipino: 'Abisuhan kapag lumampas ang gain (QAR)',
    ),
    'alerts_enable_gain': l10nEntry(
      english: 'Enable gain alert',
      arabic: 'تفعيل تنبيه الربح',
      hindi: 'लाभ अलर्ट सक्षम करें',
      urdu: 'منافع الرٹ فعال کریں',
      bengali: 'লাভের সতর্কতা চালু করুন',
      filipino: 'I-enable ang gain alert',
    ),
    'alerts_active_title': l10nEntry(
      english: 'Active alerts',
      arabic: 'التنبيهات النشطة',
      hindi: 'सक्रिय अलर्ट',
      urdu: 'فعال الرٹس',
      bengali: 'সক্রিয় সতর্কতা',
      filipino: 'Aktibong alerto',
    ),
    'alerts_active_subtitle': l10nEntry(
      english: 'Managed via Raabta Smart Notifications',
      arabic: 'تُدار عبر إشعارات Raabta الذكية',
      hindi: 'Raabta Smart Notifications द्वारा प्रबंधित',
      urdu: 'Raabta Smart Notifications کے ذریعے',
      bengali: 'Raabta Smart Notifications দ্বারা পরিচালিত',
      filipino: 'Pinamamahalaan ng Raabta Smart Notifications',
    ),
    'alerts_load_failed': l10nEntry(
      english: 'Could not load alerts',
      arabic: 'تعذّر تحميل التنبيهات',
      hindi: 'अलर्ट लोड नहीं हो सके',
      urdu: 'الرٹس لوڈ نہیں ہو سکے',
      bengali: 'সতর্কতা লোড হয়নি',
      filipino: 'Hindi ma-load ang alerts',
    ),
    'alerts_empty': l10nEntry(
      english:
          'No alerts yet — create one above. Raabta Smart Notifications checks on each rate refresh.',
      arabic:
          'لا تنبيهات بعد — أنشئ واحداً أعلاه. تفحص إشعارات Raabta الذكية عند كل تحديث.',
      hindi:
          'अभी कोई अलर्ट नहीं — ऊपर बनाएं। Raabta Smart Notifications हर रिफ्रेश पर जाँचता है।',
      urdu:
          'ابھی کوئی الرٹ نہیں — اوپر بنائیں۔ Raabta Smart Notifications ہر ریفریش پر چیک کرتا ہے۔',
      bengali:
          'এখনো সতর্কতা নেই — উপরে তৈরি করুন। Raabta Smart Notifications প্রতি আপডেটে চেক করে।',
      filipino:
          'Walang alert pa — gumawa sa itaas. Sinusuri ng Raabta Smart Notifications sa bawat refresh.',
    ),
    'alerts_smart_push_deduped': l10nEntry(
      english: 'Smart push · deduped daily',
      arabic: 'إشعار ذكي · بدون تكرار يومي',
      hindi: 'स्मार्ट पुश · दैनिक डिडुप',
      urdu: 'سمارٹ پش · دوبارہ دہرائی چیک',
      bengali: 'স্মার্ট পুশ · দৈনিক ডিশশুল্ক',
      filipino: 'Smart push · deduped daily',
    ),
    'alerts_smart_engine_title': l10nEntry(
      english: 'Raabta Smart Notifications',
      arabic: 'إشعارات Raabta الذكية',
      hindi: 'Raabta Smart Notifications',
      urdu: 'Raabta Smart Notifications',
      bengali: 'Raabta Smart Notifications',
      filipino: 'Raabta Smart Notifications',
    ),
    'alerts_smart_engine_body': l10nEntry(
      english:
          'Alerts respect quiet hours, dedup, and your notification prefs. '
          'Server checks on each refresh when online; device checks when on direct spot.',
      arabic:
          'تحترم التنبيهات ساعات الهدوء وإزالة التكرار وتفضيلاتك. '
          'يفحص الخادم عند كل تحديث عبر الإنترنت؛ والجهاز عند السعر المباشر.',
      hindi:
          'अलर्ट शांत घंटे, डिडुप और आपकी सूचना प्राथमिकताओं का पालन करते हैं। '
          'ऑनलाइन होने पर सर्वर हर रिफ्रेश पर; डायरेक्ट स्पॉट पर डिवाइस जाँचता है।',
      urdu:
          'الرٹس خاموش اوقات، ڈیڈup اور آپ کی ترجیحات کا احترام کرتے ہیں۔ '
          'آن لائن ہونے پر سرور ہر ریفریش پر؛ ڈائریکٹ اسپاٹ پر ڈivice چیک کرتا ہے۔',
      bengali:
          'সতর্কতা শান্ত সময়, ডিডup এবং আপনার পছন্দ মেনে চলে। '
          'অনলাইনে সার্ভার প্রতি আপডেটে; ডাইরেক্ট স্পটে ডিভাইস চেক করে।',
      filipino:
          'Sinusunod ng alerts ang quiet hours, dedup, at prefs mo. '
          'Sinusuri ng server sa bawat refresh online; device kapag direct spot.',
    ),
    'alert_display_locker_gain': l10nEntry(
      english: 'Portfolio gain ≥ QAR {gain}',
      arabic: 'ربح المحفظة ≥ {gain} ر.ق',
      hindi: 'पोर्टफोलियो लाभ ≥ QAR {gain}',
      urdu: 'پورٹ فولیو منافع ≥ QAR {gain}',
      bengali: 'পোর্টফোলিও লাভ ≥ QAR {gain}',
      filipino: 'Portfolio gain ≥ QAR {gain}',
    ),
    'alert_display_rises_above': l10nEntry(
      english: '{purity}K rises above QAR {threshold}/g',
      arabic: '{purity}K يرتفع فوق {threshold} ر.ق/غ',
      hindi: '{purity}K QAR {threshold}/g से ऊपर',
      urdu: '{purity}K QAR {threshold}/g سے اوپر',
      bengali: '{purity}K QAR {threshold}/g এর উপরে',
      filipino: '{purity}K tumaas sa QAR {threshold}/g',
    ),
    'alert_display_drops_below': l10nEntry(
      english: '{purity}K drops below QAR {threshold}/g',
      arabic: '{purity}K ينخفض دون {threshold} ر.ق/غ',
      hindi: '{purity}K QAR {threshold}/g से नीचे',
      urdu: '{purity}K QAR {threshold}/g سے نیچے',
      bengali: '{purity}K QAR {threshold}/g এর নিচে',
      filipino: '{purity}K bumaba sa QAR {threshold}/g',
    ),

    // ── Locker panel ────────────────────────────────────────────────────────
    'locker_sign_in': l10nEntry(
      english: 'Sign in to track your jewelry',
      arabic: 'سجّل الدخول لتتبع مجوهراتك',
      hindi: 'अपने गहने ट्रैक करने के लिए साइन इन करें',
      urdu: 'اپنے زیورات ٹrack کرنے کے لیے سائن ان کریں',
      bengali: 'আপনার গহনা ট্র্যাক করতে সাইন ইন করুন',
      filipino: 'Mag-sign in para i-track ang alahas mo',
    ),
    'locker_load_failed': l10nEntry(
      english: 'Could not load locker',
      arabic: 'تعذّر تحميل الخزنة',
      hindi: 'लॉकर लोड नहीं हो सका',
      urdu: 'لاکر لوڈ نہیں ہو سکا',
      bengali: 'লকার লোড হয়নি',
      filipino: 'Hindi ma-load ang locker',
    ),
    'locker_portfolio_value': l10nEntry(
      english: 'Portfolio value',
      arabic: 'قيمة المحفظة',
      hindi: 'पोर्टफोलियो मूल्य',
      urdu: 'پورٹ فولیو قیمت',
      bengali: 'পোর্টফোলিও মূল্য',
      filipino: 'Halaga ng portfolio',
    ),
    'locker_pieces_count': l10nEntry(
      english: '{count} pieces',
      arabic: '{count} قطعة',
      hindi: '{count} टुकड़े',
      urdu: '{count} ٹوکرے',
      bengali: '{count} টুক্রো',
      filipino: '{count} piraso',
    ),
    'locker_paid': l10nEntry(
      english: 'Paid',
      arabic: 'المدفوع',
      hindi: 'भुगतान',
      urdu: 'ادا شدہ',
      bengali: 'পেয়েদ',
      filipino: 'Binayaran',
    ),
    'locker_live_est': l10nEntry(
      english: 'Live est.',
      arabic: 'تقدير مباشر',
      hindi: 'लाइव अनु.',
      urdu: 'لائیو تخمینہ',
      bengali: 'লাইভ অনু.',
      filipino: 'Live est.',
    ),
    'locker_your_pieces_title': l10nEntry(
      english: 'Your pieces',
      arabic: 'قطعك',
      hindi: 'आपके टुकड़े',
      urdu: 'آپ کے ٹوکرے',
      bengali: 'আপনার টুক্রো',
      filipino: 'Mga piraso mo',
    ),
    'locker_items_tracked': l10nEntry(
      english: '{count} item tracked',
      arabic: 'عنصر واحد متتبع',
      hindi: '{count} आइटम ट्रैक',
      urdu: '{count} آئٹم نگرانی',
      bengali: '{count} আইটেম ট্র্যাক',
      filipino: '{count} item na-track',
    ),
    'locker_items_tracked_plural': l10nEntry(
      english: '{count} items tracked',
      arabic: '{count} عناصر متتبعة',
      hindi: '{count} आइटम ट्रैक',
      urdu: '{count} آئٹمز نگرانی',
      bengali: '{count} আইটেম ট্র্যাক',
      filipino: '{count} items na-track',
    ),
    'locker_add_piece': l10nEntry(
      english: 'Add jewelry piece',
      arabic: 'إضافة قطعة مجوهرات',
      hindi: 'गहने का टुकड़ा जोड़ें',
      urdu: 'زیورات کا ٹوکرا شامل کریں',
      bengali: 'গহনার টুক্রো যোগ করুন',
      filipino: 'Magdagdag ng alahas',
    ),
    'locker_add_sheet_title': l10nEntry(
      english: 'Add to locker',
      arabic: 'إضافة إلى الخزنة',
      hindi: 'लॉकर में जोड़ें',
      urdu: 'لاکر میں شامل کریں',
      bengali: 'লকারে যোগ করুন',
      filipino: 'Idagdag sa locker',
    ),
    'locker_item_name': l10nEntry(
      english: 'Item name',
      arabic: 'اسم القطعة',
      hindi: 'आइटम का नाम',
      urdu: 'آئٹم کا نام',
      bengali: 'আইটেমের নাম',
      filipino: 'Pangalan ng item',
    ),
    'locker_weight_label': l10nEntry(
      english: 'Weight (g)',
      arabic: 'الوزن (غ)',
      hindi: 'वज़न (g)',
      urdu: 'وزن (g)',
      bengali: 'ওজন (g)',
      filipino: 'Timbang (g)',
    ),
    'locker_paid_label': l10nEntry(
      english: 'Paid (QAR)',
      arabic: 'المدفوع (ر.ق)',
      hindi: 'भुगतान (QAR)',
      urdu: 'ادا شدہ (QAR)',
      bengali: 'পেয়েদ (QAR)',
      filipino: 'Binayaran (QAR)',
    ),
    'locker_save_piece': l10nEntry(
      english: 'Save piece',
      arabic: 'حفظ القطعة',
      hindi: 'टुकड़ा सहेजें',
      urdu: 'ٹوکرا محفوظ کریں',
      bengali: 'টুক্রো সংরক্ষণ',
      filipino: 'I-save ang piraso',
    ),
    'locker_empty_title': l10nEntry(
      english: 'Track your gold & jewelry',
      arabic: 'تتبع ذهبك ومجوهراتك',
      hindi: 'अपना सोना और गहने ट्रैक करें',
      urdu: 'اپنا سونا اور زیورات ٹیل کرنا',
      bengali: 'আপনার সোনা ও গহনা ট্র্যাক করুন',
      filipino: 'I-track ang ginto at alahas mo',
    ),
    'locker_empty_body': l10nEntry(
      english: 'Add pieces to see live portfolio value and gain/loss.',
      arabic: 'أضف قطعاً لرؤية قيمة المحفظة المباشرة والربح/الخسارة.',
      hindi: 'लाइव पोर्टफोलियो मूल्य और लाभ/हानि देखने के लिए टुकड़े जोड़ें।',
      urdu: 'لائیو پورٹ فولیو قیمت اور منافع/نقصان دیکھنے کے لیے ٹوکرے شامل کریں۔',
      bengali: 'লাইভ পোর্টফোলিও মূল্য ও লাভ/ক্ষতি দেখতে টুক্রো যোগ করুন।',
      filipino: 'Magdagdag ng piraso para makita ang live value at gain/loss.',
    ),
    'locker_add_first': l10nEntry(
      english: 'Add first piece',
      arabic: 'إضافة أول قطعة',
      hindi: 'पहला टुकड़ा जोड़ें',
      urdu: 'پہلا ٹوکرا شامل کریں',
      bengali: 'প্রথম টুক্রো যোগ করুন',
      filipino: 'Magdagdag ng unang piraso',
    ),
    'locker_item_detail': l10nEntry(
      english: '{weight}g · {purity}K · Paid QAR {price}',
      arabic: '{weight}غ · {purity}K · دُفع {price} ر.ق',
      hindi: '{weight}g · {purity}K · भुगतान QAR {price}',
      urdu: '{weight}g · {purity}K · ادا QAR {price}',
      bengali: '{weight}g · {purity}K · পেয়েদ QAR {price}',
      filipino: '{weight}g · {purity}K · Binayaran QAR {price}',
    ),

    // ── Calculator panel ────────────────────────────────────────────────────
    'calc_quick_weights_title': l10nEntry(
      english: 'Quick weights',
      arabic: 'أوزان سريعة',
      hindi: 'त्वरित वज़न',
      urdu: 'فوری وزن',
      bengali: 'দ্রুত ওজন',
      filipino: 'Mabilis na timbang',
    ),
    'calc_quick_weights_subtitle': l10nEntry(
      english: '22K jewellery reference — tap to fill',
      arabic: 'مرجع مجوهرات 22K — اضغط للملء',
      hindi: '22K गहने संदर्भ — भरने के लिए टैप',
      urdu: '22K زیورات حوالہ — بھرنے کے لیے ٹیپ',
      bengali: '22K গহনার রেফারেন্স — পূরণ করতে ট্যাপ',
      filipino: '22K jewellery reference — i-tap para punan',
    ),
    'calc_pricing_title': l10nEntry(
      english: 'What are you pricing?',
      arabic: 'ماذا تُسعّر؟',
      hindi: 'आप क्या मूल्य निर्धारित कर रहे हैं?',
      urdu: 'آپ کیا قیمت لگا رہے ہیں؟',
      bengali: 'আপনি কী মূল্য নির্ধারণ করছেন?',
      filipino: 'Ano ang ipinapresyo mo?',
    ),
    'calc_pricing_subtitle': l10nEntry(
      english: 'Item type sets typical making charges',
      arabic: 'نوع القطعة يحدد رسوم المصنعية المعتادة',
      hindi: 'आइटम प्रकार सामान्य मेकिंग चार्ज तय करता है',
      urdu: 'آئٹم کی قسم عام میکنگ چارجز طے کرتی ہے',
      bengali: 'আইটেমের ধরন সাধারণ মেকিং চার্জ নির্ধারণ করে',
      filipino: 'Ang uri ng item ang nagtatakda ng making charge',
    ),
    'calc_purity_weight_title': l10nEntry(
      english: 'Purity & weight',
      arabic: 'النقاوة والوزن',
      hindi: 'शुद्धता और वज़न',
      urdu: 'خالصیت اور وزن',
      bengali: 'বিশুদ্ধতা ও ওজন',
      filipino: 'Purity at timbang',
    ),
    'calc_purity_weight_subtitle': l10nEntry(
      english: 'Updates instantly as you adjust',
      arabic: 'يتحدث فوراً مع تعديلك',
      hindi: 'समायोजन पर तुरंत अपडेट',
      urdu: 'ایڈجسٹ کرتے ہی فوری اپ ڈیٹ',
      bengali: 'সাময়েজ্য করলে সাথে সাথে আপডেট',
      filipino: 'Agad na-update habang ina-adjust',
    ),
    'calc_weight_label': l10nEntry(
      english: 'Weight',
      arabic: 'الوزن',
      hindi: 'वज़न',
      urdu: 'وزن',
      bengali: 'ওজন',
      filipino: 'Timbang',
    ),
    'calc_weight_equiv': l10nEntry(
      english: '= {grams} g · QAR {price}/g {purity}K',
      arabic: '= {grams} غ · {price} ر.ق/غ {purity}K',
      hindi: '= {grams} g · QAR {price}/g {purity}K',
      urdu: '= {grams} g · QAR {price}/g {purity}K',
      bengali: '= {grams} g · QAR {price}/g {purity}K',
      filipino: '= {grams} g · QAR {price}/g {purity}K',
    ),
    'calc_making_charge_title': l10nEntry(
      english: 'Making charge',
      arabic: 'رسوم المصنعية',
      hindi: 'मेकिंग चार्ज',
      urdu: 'میکنگ چارج',
      bengali: 'মেকিং চার্জ',
      filipino: 'Making charge',
    ),
    'calc_making_charge_subtitle': l10nEntry(
      english: '1–25% — varies by piece & souq shop',
      arabic: '1–25% — يختلف حسب القطعة ومحل السوق',
      hindi: '1–25% — टुकड़े और सूक दुकान के अनुसार',
      urdu: '1–25% — ٹوکرے اور سوق دکان کے مطابق',
      bengali: '1–25% — টুক্রো ও সূক দোকান অনুযায়ী',
      filipino: '1–25% — depende sa piraso at souq shop',
    ),
    'calc_making_low': l10nEntry(
      english: 'Low',
      arabic: 'منخفض',
      hindi: 'कम',
      urdu: 'کم',
      bengali: 'কম',
      filipino: 'Mababa',
    ),
    'calc_making_typical': l10nEntry(
      english: 'Typical',
      arabic: 'معتاد',
      hindi: 'सामान्य',
      urdu: 'عام',
      bengali: 'সাধারণ',
      filipino: 'Karaniwan',
    ),
    'calc_making_high': l10nEntry(
      english: 'High',
      arabic: 'مرتفع',
      hindi: 'अधिक',
      urdu: 'زیادہ',
      bengali: 'উচ্চ',
      filipino: 'Mataas',
    ),
    'calc_advanced_options': l10nEntry(
      english: 'Advanced options',
      arabic: 'خيارات متقدمة',
      hindi: 'उन्नत विकल्प',
      urdu: 'اعلیٰ اختیارات',
      bengali: 'উন্নত বিকল্প',
      filipino: 'Advanced options',
    ),
    'calc_purchase_price_label': l10nEntry(
      english: 'Your purchase price (QAR)',
      arabic: 'سعر شرائك (ر.ق)',
      hindi: 'आपकी खरीद कीमत (QAR)',
      urdu: 'آپ کی خرید قیمت (QAR)',
      bengali: 'আপনার ক্রয় মূল্য (QAR)',
      filipino: 'Presyo ng binili mo (QAR)',
    ),
    'calc_purchase_price_hint': l10nEntry(
      english: 'Optional — for profit / loss',
      arabic: 'اختياري — للربح / الخسارة',
      hindi: 'वैकल्पिक — लाभ / हानि के लिए',
      urdu: 'اختیاری — منافع / نقصان کے لیے',
      bengali: 'ঐচ্ছিক — লাভ / ক্ষতির জন্য',
      filipino: 'Opsyonal — para sa profit / loss',
    ),
    'calc_vat_toggle_title': l10nEntry(
      english: 'Include VAT on total',
      arabic: 'إضافة ضريبة القيمة المضافة على الإجمالي',
      hindi: 'कुल पर VAT शामिल करें',
      urdu: 'کل پر VAT شامل کریں',
      bengali: 'মোটে VAT অন্তর্ভুক্ত করুন',
      filipino: 'Isama ang VAT sa total',
    ),
    'calc_vat_toggle_subtitle': l10nEntry(
      english: 'Off by default — Qatar investment gold is typically VAT-free.',
      arabic: 'معطّل افتراضياً — ذهب الاستثمار في قطر عادة معفى من ضريبة القيمة المضافة.',
      hindi: 'डिफ़ॉल्ट बंद — क़तर में निवेश सोना आमतौर पर VAT-मुक्त।',
      urdu: 'ڈیفالٹ بند — قطر میں سرمایہ کاری سونا عام طور پر VAT سے مستثنیٰ۔',
      bengali: 'ডিফল্ট বন্ধ — কাতার-এ বিনিয়োগ সোনা সাধারণত VAT-মুক্ত।',
      filipino: 'Off by default — investment gold sa Qatar ay karaniwang walang VAT.',
    ),
    'calc_estimated_pay': l10nEntry(
      english: 'Estimated pay',
      arabic: 'الدفع التقديري',
      hindi: 'अनुमानित भुगतान',
      urdu: 'تخمینی ادائیگی',
      bengali: 'আনুমানিক পরিশোধ',
      filipino: 'Tinatayang bayad',
    ),
    'calc_metal_value_today': l10nEntry(
      english: 'Metal value today',
      arabic: 'قيمة المعدن اليوم',
      hindi: 'आज धातु मूल्य',
      urdu: 'آج دھات کی قیمت',
      bengali: 'আজ ধাতুর মূল্য',
      filipino: 'Halaga ng metal ngayon',
    ),
    'calc_buy_price': l10nEntry(
      english: 'Buy price',
      arabic: 'سعر الشراء',
      hindi: 'खरीद मूल्य',
      urdu: 'خرید قیمت',
      bengali: 'ক্রয় মূল্য',
      filipino: 'Presyo ng bili',
    ),
    'calc_resale': l10nEntry(
      english: 'Resale',
      arabic: 'إعادة البيع',
      hindi: 'पुनर्विक्रय',
      urdu: 'دوبارہ فروخت',
      bengali: 'পুনঃবিক্রয়',
      filipino: 'Resale',
    ),
    'calc_live_purity_chip': l10nEntry(
      english: 'Live {purity}K',
      arabic: 'مباشر {purity}K',
      hindi: 'लाइव {purity}K',
      urdu: 'لائیو {purity}K',
      bengali: 'লাইভ {purity}K',
      filipino: 'Live {purity}K',
    ),
    'calc_grams_chip': l10nEntry(
      english: '{grams} g',
      arabic: '{grams} غ',
      hindi: '{grams} g',
      urdu: '{grams} g',
      bengali: '{grams} g',
      filipino: '{grams} g',
    ),
    'calc_spot_chip': l10nEntry(
      english: 'Spot QAR {price}/g',
      arabic: 'فوري {price} ر.ق/غ',
      hindi: 'स्पॉट QAR {price}/g',
      urdu: 'اسپاٹ QAR {price}/g',
      bengali: 'স্পট QAR {price}/g',
      filipino: 'Spot QAR {price}/g',
    ),
    'calc_breakdown_title': l10nEntry(
      english: 'Price breakdown',
      arabic: 'تفصيل السعر',
      hindi: 'मूल्य विवरण',
      urdu: 'قیمت کی تفصیل',
      bengali: 'মূল্যের বিবরণ',
      filipino: 'Price breakdown',
    ),
    'calc_breakdown_metal_value': l10nEntry(
      english: 'Gold metal value',
      arabic: 'قيمة الذهب الخالص',
      hindi: 'सोने की धातु मूल्य',
      urdu: 'سونے کی دھات کی قیمت',
      bengali: 'সোনার ধাতুর মূল্য',
      filipino: 'Halaga ng ginto',
    ),
    'calc_breakdown_metal_sublabel': l10nEntry(
      english: '{purity}K · {grams} g',
      arabic: '{purity}K · {grams} غ',
      hindi: '{purity}K · {grams} g',
      urdu: '{purity}K · {grams} g',
      bengali: '{purity}K · {grams} g',
      filipino: '{purity}K · {grams} g',
    ),
    'calc_breakdown_making': l10nEntry(
      english: 'Making charge',
      arabic: 'رسوم المصنعية',
      hindi: 'मेकिंग चार्ज',
      urdu: 'میکنگ چارج',
      bengali: 'মেকিং চার্জ',
      filipino: 'Making charge',
    ),
    'calc_breakdown_making_sublabel': l10nEntry(
      english: '{pct}% on metal',
      arabic: '{pct}% على المعدن',
      hindi: 'धातु पर {pct}%',
      urdu: 'دھات پر {pct}%',
      bengali: 'ধাতুর উপর {pct}%',
      filipino: '{pct}% sa metal',
    ),
    'calc_breakdown_vat': l10nEntry(
      english: 'VAT',
      arabic: 'ضريبة القيمة المضافة',
      hindi: 'VAT',
      urdu: 'VAT',
      bengali: 'VAT',
      filipino: 'VAT',
    ),
    'calc_breakdown_total_pay': l10nEntry(
      english: 'Total to pay (est.)',
      arabic: 'الإجمالي للدفع (تقديري)',
      hindi: 'कुल भुगतान (अनु.)',
      urdu: 'کل ادائیگی (تخمینہ)',
      bengali: 'মোট পরিশোধ (আনু.)',
      filipino: 'Kabuuang babayaran (est.)',
    ),
    'calc_breakdown_resale_live': l10nEntry(
      english: 'Resale at live rate',
      arabic: 'إعادة البيع بالسعر المباشر',
      hindi: 'लाइव दर पर पुनर्विक्रय',
      urdu: 'لائیو نرخ پر دوبارہ فروخت',
      bengali: 'লাইভ হারে পুনঃবিক্রয়',
      filipino: 'Resale sa live rate',
    ),
    'calc_breakdown_resale_metal': l10nEntry(
      english: 'Resale value (metal only)',
      arabic: 'قيمة إعادة البيع (المعدن فقط)',
      hindi: 'पुनर्विक्रय मूल्य (केवल धातु)',
      urdu: 'دوبارہ فروخت (صرف دھات)',
      bengali: 'পুনঃবিক্রয় (শুধু ধাতু)',
      filipino: 'Resale value (metal lang)',
    ),
    'calc_breakdown_resale_sublabel': l10nEntry(
      english: 'What the gold is worth today',
      arabic: 'ما يساويه الذهب اليوم',
      hindi: 'आज सोने की कीमत',
      urdu: 'آج سونے کی قیمت',
      bengali: 'আজ সোনার মূল্য',
      filipino: 'Halaga ng ginto ngayon',
    ),
    'calc_investment_grade_note': l10nEntry(
      english: 'Investment grade — no making charge, typically VAT-free in Qatar',
      arabic: 'درجة استثمارية — بدون مصنعية، عادة معفى من ضريبة القيمة المضافة في قطر',
      hindi: 'निवेश श्रेणी — कोई मेकिंग चार्ज नहीं, क़तर में आमतौर पर VAT-मुक्त',
      urdu: 'سرمایہ کاری گریڈ — کوئی میکنگ نہیں، قطر میں عام طور پر VAT سے مستثنیٰ',
      bengali: 'বিনিয়োগ মান — মেকিং নেই, কাতার-এ সাধারণত VAT-মুক্ত',
      filipino: 'Investment grade — walang making charge, karaniwang walang VAT sa Qatar',
    ),
    'calc_composition_summary': l10nEntry(
      english: '{metalPct}% metal · {premiumPct}% premium over spot',
      arabic: '{metalPct}% معدن · {premiumPct}% علاوة فوق السعر الفوري',
      hindi: '{metalPct}% धातु · स्पॉट पर {premiumPct}% प्रीमियम',
      urdu: '{metalPct}% دھات · اسپاٹ پر {premiumPct}% پریمیم',
      bengali: '{metalPct}% ধাতু · স্পটের উপর {premiumPct}% প্রিমিয়াম',
      filipino: '{metalPct}% metal · {premiumPct}% premium over spot',
    ),
    'calc_unrealised_pl': l10nEntry(
      english: 'Unrealised P/L vs your price',
      arabic: 'ربح/خسارة غير محققة مقابل سعرك',
      hindi: 'अप्राप्त लाभ/हानि बनाम आपकी कीमत',
      urdu: 'غیر حقیقی منافع/نقصان بمقابلہ آپ کی قیمت',
      bengali: 'অ unrealised লাভ/ক্ষতি বনাম আপনার দাম',
      filipino: 'Unrealised P/L vs presyo mo',
    ),
  };
}
