import 'package:flutter/foundation.dart';
import 'package:raabta/core/l10n/app_locale.dart';
import 'package:raabta/core/l10n/locale_catalog_coverage.dart';
import 'package:raabta/core/l10n/locale_catalog_entry.dart';

import '../models/dietary_profile.dart';

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

abstract final class FoodInspectorStrings {
  static const supportedLocales = AppLocale.supportedLocales;

  /// Stable English keys stored in Firestore for allergen matching.
  static const allergenStorageKeys = [
    'Peanuts',
    'Tree Nuts',
    'Milk / Dairy',
    'Eggs',
    'Wheat / Gluten',
    'Soy',
    'Fish',
    'Shellfish',
    'Sesame',
    'Mustard',
    'Celery',
    'Sulphites',
  ];

  static String t(String key, [String locale = 'English']) {
    final map = _strings[key];
    if (map == null) return key;
    final normalized = AppLocale.normalize(locale);
    return map[normalized] ?? map['English'] ?? key;
  }

  static String format(
    String key,
    String locale,
    Map<String, String> params,
  ) {
    var value = t(key, locale);
    for (final entry in params.entries) {
      value = value.replaceAll('{${entry.key}}', entry.value);
    }
    return value;
  }

  static String allergenLabel(String storageKey, String locale) {
    final key = switch (storageKey) {
      'Peanuts' => 'allergen_peanuts',
      'Tree Nuts' => 'allergen_tree_nuts',
      'Milk / Dairy' => 'allergen_milk',
      'Eggs' => 'allergen_eggs',
      'Wheat / Gluten' => 'allergen_wheat',
      'Soy' => 'allergen_soy',
      'Fish' => 'allergen_fish',
      'Shellfish' => 'allergen_shellfish',
      'Sesame' => 'allergen_sesame',
      'Mustard' => 'allergen_mustard',
      'Celery' => 'allergen_celery',
      'Sulphites' => 'allergen_sulphites',
      _ => null,
    };
    if (key == null) return storageKey;
    return t(key, locale);
  }

  static String dietTypeLabel(DietType type, String locale) {
    final key = switch (type) {
      DietType.noRestriction => 'diet_no_restriction',
      DietType.vegetarian => 'diet_vegetarian',
      DietType.vegan => 'diet_vegan',
      DietType.pescatarian => 'diet_pescatarian',
      DietType.keto => 'diet_keto',
      DietType.diabeticFriendly => 'diet_diabetic',
    };
    return t(key, locale);
  }

  static String verdictLabel(int score, String locale) {
    if (score >= 85) return t('verdict_excellent', locale);
    if (score >= 70) return t('verdict_good', locale);
    if (score >= 50) return t('verdict_moderate', locale);
    if (score >= 30) return t('verdict_poor', locale);
    return t('verdict_avoid', locale);
  }

  static String verdictMessage(int score, String locale) {
    if (score >= 85) return t('verdict_msg_excellent', locale);
    if (score >= 70) return t('verdict_msg_good', locale);
    if (score >= 50) return t('verdict_msg_moderate', locale);
    if (score >= 30) return t('verdict_msg_poor', locale);
    return t('verdict_msg_avoid', locale);
  }

  static String nutrientLabel(String nutrientKey, String locale) =>
      t(nutrientKey, locale);

  static String buildSummary({
    required String productName,
    required int score,
    required String verdict,
    required String locale,
    bool useReferenceSummary = false,
  }) {
    if (useReferenceSummary) {
      return format(
        'summary_reference',
        locale,
        {
          'product': productName,
          'score': '$score',
          'verdict': verdict,
        },
      );
    }
    return format(
      'summary_offline',
      locale,
      {
        'product': productName,
        'score': '$score',
        'verdict': verdict,
      },
    );
  }

  @visibleForTesting
  static Map<String, Set<String>> get localeCoverageReport =>
      buildLocaleCoverageReport(
        catalog: Map<String, Map<String, String>>.from(_strings),
        supportedLocales: supportedLocales,
      );

  static final _strings = <String, Map<String, String>>{
    'screen_title': _e(
      'Food Inspector',
      arabic: 'مفتش الغذاء',
      hindi: 'Food Inspector',
      urdu: 'فوڈ انسپکٹر',
      bengali: 'Food Inspector',
      filipino: 'Food Inspector',
    ),
    'rescan': _e('Rescan', arabic: 'إعادة المسح', urdu: 'دوبارہ اسکین'),
    'results_in': _e(
      'Results in: {language}',
      arabic: 'النتائج بـ: {language}',
      urdu: 'نتائج: {language}',
      hindi: 'Results in: {language}',
    ),
    'manual': _e('Manual', arabic: 'يدوي', urdu: 'دستی'),
    'camera': _e('Camera', arabic: 'الكamera', urdu: 'کیمرہ'),
    'scan_hint': _e(
      'Point at any product barcode\nNutrients + chemicals decoded instantly',
      arabic:
          'وجّه نحو باركود أي منتج\nالعناصر الغذائية والمواد الكيميائية فوراً',
      urdu:
          'کسی بھی پروڈکٹ کے بارکوڈ پر رکھیں\nغذائی اجزاء اور کیمیکل فوری ڈیکوڈ',
    ),
    'enter_barcode_manually': _e(
      'Enter barcode manually',
      arabic: 'أدخل الباركود يدوياً',
      urdu: 'بارکوڈ دستی درج کریں',
    ),
    'desktop_no_camera_title': _e(
      'Camera not available on desktop',
      arabic: 'الكamera غير متاحة على سطح المكتب',
      urdu: 'ڈیسک ٹاپ پر کیمرہ دستیاب نہیں',
    ),
    'desktop_no_camera_body': _e(
      'Enter a barcode below or tap a popular Qatar product',
      arabic: 'أدخل باركوداً أدناه أو اختر منتجاً شائعاً في قطر',
      urdu: 'نیچے بارکوڈ درج کریں یا قطر کا مشہور پروڈکٹ منتخب کریں',
    ),
    'popular_in_qatar': _e(
      'Popular in Qatar',
      arabic: 'شائع في قطر',
      urdu: 'قطر میں مقبول',
    ),
    'hint_barcode': _e(
      'Enter barcode number',
      arabic: 'أدخل رقم الباركود',
      urdu: 'بارکوڈ نمبر درج کریں',
    ),
    'search': _e('Search', arabic: 'بحث', urdu: 'تلاش'),
    'loading_title': _e(
      'Analyzing ingredients…',
      arabic: 'جاري تحليل المكونات…',
      urdu: 'اجزاء کا تجزیہ…',
    ),
    'loading_subtitle': _e(
      'Decoding chemicals & calculating health score',
      arabic: 'فك ترميز المواد الكيميائية وحساب درجة الصحة',
      urdu: 'کیمیکل ڈیکوڈ اور صحت کا اسکور',
    ),
    'error_product_not_found': _e(
      'Product not found for barcode {code}.\nTry manual entry or another product.',
      arabic:
          'المنتج غير موجود للباركود {code}.\nجرّب الإدخال اليدوي أو منتجاً آخر.',
      urdu:
          'بارکوڈ {code} کے لیے پروڈکٹ نہیں ملا۔\nدستی درج یا دوسرا پروڈکٹ آزمائیں۔',
    ),
    'error_analyze_failed': _e(
      'Could not analyze product. Check your connection and try again.',
      arabic: 'تعذّر تحليل المنتج. تحقق من الاتصال وحاول مجدداً.',
      urdu: 'پروڈکٹ کا تجزیہ نہیں ہو سکا۔ کنکشن چیک کریں۔',
    ),
    'try_again': _e('Try Again', arabic: 'حاول مجدداً', urdu: 'دوبارہ کوشش'),
    'empty_not_found_title': _e(
      'Product not found',
      arabic: 'المنتج غير موجود',
      urdu: 'پروڈکٹ نہیں ملا',
    ),
    'empty_analyze_title': _e(
      'Could not analyze',
      arabic: 'تعذّر التحليل',
      urdu: 'تجزیہ نہیں ہو سکا',
    ),
    'section_nutrition_overline': _e(
      'Label data',
      arabic: 'بيانات الملصق',
      urdu: 'لیبل ڈیٹا',
    ),
    'section_additives_overline': _e(
      'E-numbers',
      arabic: 'أرقام E',
      urdu: 'E-numbers',
    ),
    'snack_enter_barcode': _e(
      'Enter a barcode number first',
      arabic: 'أدخل رقم الباركود أولاً',
      urdu: 'پہلے بارکوڈ نمبر درج کریں',
    ),
    'snack_saved_gallery': _e(
      'Health Card saved to gallery!',
      arabic: 'تم حفظ بطاقة الصحة في المعرض!',
      urdu: 'ہیلتھ کارڈ گیلری میں محفوظ!',
    ),
    'snack_save_failed': _e(
      'Could not save. Try again.',
      arabic: 'تعذّر الحفظ. حاول مجدداً.',
      urdu: 'محفوظ نہیں ہو سکا۔ دوبارہ کوشش کریں۔',
    ),
    'barcode_label': _e(
      'Barcode: {code}',
      arabic: 'الباركود: {code}',
      urdu: 'بارکوڈ: {code}',
    ),
    'save': _e('Save', arabic: 'حفظ', urdu: 'محفوظ'),
    'share': _e('Share', arabic: 'مشاركة', urdu: 'شیئر'),
    'section_nutrition': _e(
      'Nutrition per 100g',
      arabic: 'التغذية لكل 100غ',
      urdu: '100g میں غذائیت',
    ),
    'section_additives': _e(
      'Additives Decoded',
      arabic: 'المضافات مفكوكة',
      urdu: ' additives ڈیکوڈ',
    ),
    'footer_scanned_by': _e(
      'Scanned by RAABTA  •  {host}',
      arabic: 'مسح بواسطة RAABTA  •  {host}',
      urdu: 'RAABTA سے اسکین  •  {host}',
    ),
    'share_caption': _e(
      '{emoji} {product} — Health Score: {score}/100\n\nScanned with RAABTA Food Inspector\nDownload: {host}',
      arabic:
          '{emoji} {product} — درجة الصحة: {score}/100\n\nمسح بـ RAABTA Food Inspector\nتحميل: {host}',
      urdu:
          '{emoji} {product} — Health Score: {score}/100\n\nRAABTA Food Inspector\n{host}',
    ),
    'edit_dietary_profile': _e(
      'Edit dietary profile',
      arabic: 'تعديل الملف الغذائي',
      urdu: 'غذائی پروفائل میں ترمیم',
    ),
    'unknown_product': _e(
      'Unknown Product',
      arabic: 'منتج غير معروف',
      urdu: 'نامعلوم پروڈکٹ',
    ),
    'verdict_excellent': _e('Excellent', arabic: 'ممتاز', urdu: 'بہترین'),
    'verdict_good': _e('Good', arabic: 'جيد', urdu: 'اچھا'),
    'verdict_moderate': _e('Moderate', arabic: 'متوسط', urdu: 'درمیانہ'),
    'verdict_poor': _e('Poor', arabic: 'ضعيف', urdu: 'کمزور'),
    'verdict_avoid': _e('Avoid', arabic: 'تجنّب', urdu: 'بچیں'),
    'verdict_msg_excellent': _e(
      'Great choice — keep it up!',
      arabic: 'اختيار رائع — واصل!',
      urdu: 'بہترین انتخاب — جاری رکھیں!',
    ),
    'verdict_msg_good': _e(
      'A solid option for everyday use.',
      arabic: 'خيار جيد للاستخدام اليومي.',
      urdu: 'روزمرہ کے لیے اچھا آپشن۔',
    ),
    'verdict_msg_moderate': _e(
      'Okay sometimes — balance with healthier foods.',
      arabic: 'مقبول أحياناً — وازن مع أطعمة أكثر صحة.',
      urdu: 'کبھی کبھار ٹھیک — صحت مند غذا کے ساتھ۔',
    ),
    'verdict_msg_poor': _e(
      'Enjoy occasionally, not every day.',
      arabic: 'استمتع أحياناً، ليس يومياً.',
      urdu: 'کبھی کبھار، روزانہ نہیں۔',
    ),
    'verdict_msg_avoid': _e(
      'Consider a healthier alternative when you can.',
      arabic: 'فكّر في بديل أكثر صحة عندما تستطيع.',
      urdu: 'ممکن ہو تو صحت مند متبادل دیکھیں۔',
    ),
    'nutrient_energy': _e('Energy', arabic: 'الطاقة', urdu: 'توانائی'),
    'nutrient_fat': _e('Fat', arabic: 'الدهون', urdu: 'چربی'),
    'nutrient_saturated_fat': _e(
      'Saturated fat',
      arabic: 'دهون مشبعة',
      urdu: 'سaturated چربی',
    ),
    'nutrient_sugar': _e('Sugar', arabic: 'سكر', urdu: 'شکر'),
    'nutrient_salt': _e('Salt', arabic: 'ملح', urdu: 'نمک'),
    'nutrient_protein': _e('Protein', arabic: 'بروتين', urdu: 'پروٹین'),
    'nutrient_carbs': _e('Carbs', arabic: 'كarbohydrates', urdu: 'کاربohydrates'),
    'nutrient_fiber': _e('Fiber', arabic: 'ألياف', urdu: 'فائبر'),
    // TODO-TRANSLATE-REVIEW: halal-related strings need fluent religious-terminology review.
    'halal_section_title': _e(
      'Halal Information',
      arabic: 'معلومات الحلال',
      hindi: 'Halal Information',
      urdu: 'حلال کی معلومات',
      bengali: 'Halal Information',
      tamil: 'Halal Information',
      filipino: 'Halal Information',
      malayalam: 'Halal Information',
      nepali: 'Halal Information',
    ),
    'halal_no_data': _e(
      'No halal information available for this product — check the physical packaging for an official certification mark.',
      arabic:
          'لا تتوفر معلومات حلال لهذا المنتج — تحقق من العبوة للعلامة الرسمية.',
      hindi:
          'No halal information available — check packaging for official certification mark.',
      urdu:
          'اس پروڈکٹ کے لیے حلال معلومات نہیں — سرکاری سرٹیفیکیشن مارک کے لیے packaging چیک کریں۔',
      bengali:
          'No halal information available — check packaging for official certification mark.',
      tamil:
          'No halal information available — check packaging for official certification mark.',
      filipino:
          'Walang halal info — tingnan ang opisyal na certification mark sa packaging.',
      malayalam:
          'No halal information available — check packaging for official certification mark.',
      nepali:
          'No halal information available — check packaging for official certification mark.',
    ),
    'halal_community_attribution': _e(
      'Community-reported — not independently verified by Raabta.',
      arabic: 'مُبلّغ من المجتمع — لم تتحقق Raabta بشكل مستقل.',
      hindi: 'Community-reported — not independently verified by Raabta.',
      urdu: 'کمیونٹی رپورٹ — Raabta نے آزادانہ تصدیق نہیں کی۔',
      bengali: 'Community-reported — not independently verified by Raabta.',
      tamil: 'Community-reported — not independently verified by Raabta.',
      filipino: 'Community-reported — hindi independently verified ng Raabta.',
      malayalam: 'Community-reported — not independently verified by Raabta.',
      nepali: 'Community-reported — not independently verified by Raabta.',
    ),
    'halal_awareness_title': _e(
      'Ingredients some Muslim consumers check for',
      arabic: 'مكونات يراجعها بعض المسلمين',
      hindi: 'Ingredients some Muslim consumers check for',
      urdu: 'اجزاء جو بعض مسلمان صارفین دیکھتے ہیں',
      bengali: 'Ingredients some Muslim consumers check for',
      tamil: 'Ingredients some Muslim consumers check for',
      filipino: 'Ingredients some Muslim consumers check for',
      malayalam: 'Ingredients some Muslim consumers check for',
      nepali: 'Ingredients some Muslim consumers check for',
    ),
    'halal_awareness_framing': _e(
      'Informational only — not a halal or haram determination. Sourcing and certification require official data.',
      arabic:
          'للمعلومات فقط — ليس حكماً حلالاً أو حراماً. المصدر والشهادة يتطلبان بيانات رسمية.',
      hindi:
          'Informational only — not halal/haram determination. Official certification required for certainty.',
      urdu:
          'صرف معلومات — حلال/حرام فیصلہ نہیں۔ یقین کے لیے سرکاری تصدیق درکار۔',
      bengali:
          'Informational only — not halal/haram determination.',
      tamil: 'Informational only — not halal/haram determination.',
      filipino:
          'Impormasyon lang — hindi halal/haram determination.',
      malayalam:
          'Informational only — not halal/haram determination.',
      nepali: 'Informational only — not halal/haram determination.',
    ),
    'halal_disclaimer': _e(
      'Informational guidance only — not independent halal certification or a personal religious ruling. Check official packaging and qualified sources for matters of certainty.',
      arabic:
          'إرشادات عامة فقط — ليست شهادة حلال مستقلة ولا فتوى شخصية. تحقق من العبوة الرسمية.',
      hindi:
          'Informational guidance only — not halal certification or personal fatwa. Check official packaging.',
      urdu:
          'عام رہنمائی — آزاد حلال سرٹیفیکیشن یا ذاتی فتوا نہیں۔ سرکاری packaging چیک کریں۔',
      bengali:
          'Informational guidance only — not halal certification or personal fatwa.',
      tamil:
          'Informational guidance only — not halal certification or personal fatwa.',
      filipino:
          'Impormasyon lang — hindi independent halal certification o personal fatwa.',
      malayalam:
          'Informational guidance only — not halal certification or personal fatwa.',
      nepali:
          'Informational guidance only — not halal certification or personal fatwa.',
    ),
    'halal_off_contribute': _e(
      'This data is crowdsourced on Open Food Facts — contribute labels',
      arabic: 'البيانات جماعية على Open Food Facts — ساهم بالملصقات',
      hindi: 'Crowdsourced on Open Food Facts — contribute labels',
      urdu: 'Open Food Facts پر crowdsourced — labels شامل کریں',
      bengali: 'Crowdsourced on Open Food Facts — contribute labels',
      tamil: 'Crowdsourced on Open Food Facts — contribute labels',
      filipino: 'Crowdsourced sa Open Food Facts — mag-contribute ng labels',
      malayalam: 'Crowdsourced on Open Food Facts — contribute labels',
      nepali: 'Crowdsourced on Open Food Facts — contribute labels',
    ),
    'awareness_gelatin': _e(
      'Gelatin (source varies — some consumers check certification)',
      arabic: 'جيلاتين (المصدر يختلف — يتحقق البعض من الشهادة)',
      urdu: 'جیلاٹین (ماخذ مختلف — بعض لوگ certification چیک کرتے ہیں)',
    ),
    'awareness_pork': _e(
      'Pork-derived term listed in ingredients',
      arabic: 'مصطلح مشتق من لحم الخنزير في المكونات',
      urdu: 'اجزاء میں pork سے متعلق لفظ',
    ),
    'awareness_lard': _e(
      'Lard listed in ingredients',
      arabic: 'شحم الخنزير (lard) في المكونات',
      urdu: 'اجزاء میں lard',
    ),
    'awareness_pepsin': _e(
      'Pepsin listed in ingredients',
      arabic: 'البسين (pepsin) في المكونات',
      urdu: 'اجزاء میں pepsin',
    ),
    'awareness_rennet': _e(
      'Rennet listed in ingredients (animal/microbial source varies)',
      arabic: 'منفحة (rennet) في المكونات (المصدر يختلف)',
      urdu: 'اجزاء میں rennet (ماخذ مختلف)',
    ),
    'awareness_carmine': _e(
      'Carmine / cochineal (E120) color listed',
      arabic: 'قرمزي / cochineal (E120) في المكونات',
      urdu: 'carmine / cochineal (E120) درج',
    ),
    'awareness_alcohol': _e(
      'Alcohol-related ingredient listed',
      arabic: 'مكون متعلق بالكحول',
      urdu: 'الcohol سے متعلق جزو',
    ),
    'awareness_alcohol_extract': _e(
      'Vanilla extract listed (may contain alcohol carrier)',
      arabic: 'مستخلص الفانيليا (قد يحتوي حامل كحول)',
      urdu: 'vanilla extract (ممکنہ alcohol carrier)',
    ),
    'expiry_scan_entry': _e(
      'Scan Expiry Date',
      arabic: 'مسح تاريخ الانتهاء',
      hindi: 'Scan Expiry Date',
      urdu: 'Expiry تاریخ اسکین کریں',
      bengali: 'Scan Expiry Date',
      tamil: 'Scan Expiry Date',
      filipino: 'Scan Expiry Date',
      malayalam: 'Scan Expiry Date',
      nepali: 'Scan Expiry Date',
    ),
    'expiry_scan_title': _e(
      'Scan printed expiry date',
      arabic: 'امسح تاريخ الانتهاء المطبوع',
      urdu: 'چھapa ہوا expiry date اسکین کریں',
    ),
    'expiry_scan_subtitle': _e(
      'Separate from barcode lookup — reads the date on this physical item via OCR.',
      arabic:
          'منفصل عن البarcode — يقرأ تاريخ هذه العبوة عبر OCR.',
      urdu:
          'Barcode lookup سے الگ — OCR سے اس item کی تاریخ پڑھتا ہے۔',
    ),
    'expiry_capture_cta': _e(
      'Photograph label',
      arabic: 'صوّر الملصق',
      urdu: 'لیبل کی تصویر لیں',
    ),
    'expiry_gallery_cta': _e(
      'Choose from gallery',
      arabic: 'اختر من المعرض',
      urdu: 'گیلری سے منتخب کریں',
    ),
    'expiry_ocr_empty': _e(
      'Could not read text from the image. Try better lighting and focus on the date.',
      arabic: 'تعذّر قراءة النص — حسّن الإضاءة وركّز على التاريخ.',
      urdu: 'تصویر سے متن نہیں پڑھ سکے — روشنی بہتر کریں۔',
    ),
    'expiry_parse_failed': _e(
      'Could not find a clear expiry date. Try again or enter manually later.',
      arabic: 'تعذّر العثور على تاريخ انتهاء واضح.',
      urdu: 'واضح expiry date نہیں ملی۔',
    ),
    'expiry_ambiguous_title': _e(
      'Confirm the date',
      arabic: 'أكّد التاريخ',
      urdu: 'تاریخ کی تصدیق کریں',
    ),
    'expiry_ambiguous_body': _e(
      'Day and month order is unclear — tap the date that matches your label.',
      arabic: 'ترتيب اليوم والشهر غير واضح — اختر التاريخ المطابق للملصق.',
      urdu: 'دن/مہینے کی ترتیب unclear — label سے ملتی تاریخ منتخب کریں۔',
    ),
    'expiry_confirmed_date': _e(
      'Confirmed date: {date}',
      arabic: 'التاريخ المؤكد: {date}',
      urdu: 'تصدیق شدہ تاریخ: {date}',
    ),
    'expiry_days_left': _e(
      '{days} days until expiry',
      arabic: '{days} أيام حتى الانتهاء',
      urdu: 'ختم ہونے میں {days} دن',
    ),
    'expiry_days_past': _e(
      'Expired {days} days ago',
      arabic: 'انتهى منذ {days} أيام',
      urdu: '{days} دن پہلے ختم ہو چکا',
    ),
    'expiry_today': _e(
      'Expires today',
      arabic: 'ينتهي اليوم',
      urdu: 'آج ختم ہوتا ہے',
    ),
    'expiry_reminder_cta': _e(
      'Remind me before expiry',
      arabic: 'ذكّرني قبل الانتهاء',
      urdu: 'ختم ہونے سے پہلے یاد دلائیں',
    ),
    'expiry_reminder_set': _e(
      'Reminder scheduled',
      arabic: 'تم جدولة التذكير',
      urdu: 'یاددہانی شیڈول ہو گئی',
    ),
    'expiry_reminder_product': _e(
      'Scanned product',
      arabic: 'منتج ممسوح',
      urdu: 'اسکین شدہ پروڈکٹ',
    ),
    'allergen_warning_title': _e(
      'ALLERGEN WARNING',
      arabic: 'تحذير حساسية',
      urdu: 'الرجی وارننگ',
    ),
    'allergy_detected': _e(
      'Possible {allergen} detected in ingredients.',
      arabic: 'احتمال وجود {allergen} في المكونات.',
      urdu: 'اجزاء میں {allergen} کا امکان۔',
    ),
    'allergen_peanuts': _e('Peanuts', arabic: 'فول سوداني', urdu: 'مونگ پھلی'),
    'allergen_tree_nuts': _e(
      'Tree Nuts',
      arabic: 'مكسرات',
      urdu: 'درخت کے nuts',
    ),
    'allergen_milk': _e(
      'Milk / Dairy',
      arabic: 'حليب / ألبان',
      urdu: 'دودھ / dairy',
    ),
    'allergen_eggs': _e('Eggs', arabic: 'بيض', urdu: 'انڈے'),
    'allergen_wheat': _e(
      'Wheat / Gluten',
      arabic: 'قمح / gluten',
      urdu: 'گندم / gluten',
    ),
    'allergen_soy': _e('Soy', arabic: 'صويا', urdu: 'سویا'),
    'allergen_fish': _e('Fish', arabic: 'سمك', urdu: 'مچھلی'),
    'allergen_shellfish': _e('Shellfish', arabic: 'محار', urdu: 'شیلفش'),
    'allergen_sesame': _e('Sesame', arabic: 'سمسم', urdu: 'تل'),
    'allergen_mustard': _e('Mustard', arabic: 'خردل', urdu: 'سرسوں'),
    'allergen_celery': _e('Celery', arabic: 'كرفس', urdu: 'اجوائن'),
    'allergen_sulphites': _e('Sulphites', arabic: 'كبريتات', urdu: 'sulphites'),
    'summary_reference': _e(
      '{product} scores {score}/100 ({verdict}) based on Open Food Facts nutrition data and RAABTA additive reference lookup.',
      arabic:
          'نتيجة {product}: {score}/100 ({verdict}). يعتمد على Open Food Facts وجدول RAABTA للمضافات.',
      urdu:
          '{product} کا اسکور {score}/100 ({verdict}) — Open Food Facts اور RAABTA reference سے۔',
      hindi:
          '{product} का स्कोर {score}/100 ({verdict}) — Open Food Facts और RAABTA reference से।',
      bengali:
          '{product} স্কোর {score}/100 ({verdict}) — Open Food Facts ও RAABTA reference থেকে।',
      filipino:
          'Ang {product} ay {score}/100 ({verdict}) batay sa Open Food Facts at RAABTA additive reference.',
    ),
    'summary_offline': _e(
      '{product} scores {score}/100 ({verdict}) using Open Food Facts label data. Offline RAABTA analysis was used because AI review is temporarily unavailable.',
      arabic:
          'نتيجة {product}: {score}/100 ({verdict}). تم استخدام التحليل المحلي لأن مراجعة الذكاء الاصطناعي غير متاحة مؤقتاً.',
      urdu:
          '{product} کا اسکور {score}/100 ({verdict}) — آف لائن RAABTA تجزیہ استعمال ہوا۔',
    ),
    'profile_title': _e(
      'Your Dietary Profile',
      arabic: 'ملفك الغذائي',
      urdu: 'آپ کی غذائی پروفائل',
    ),
    'profile_skip': _e('Skip', arabic: 'تخطّ', urdu: 'چھوڑیں'),
    'profile_info': _e(
      'Set this once. RAABTA will automatically flag allergens, check halal status, and personalize health scores when you scan any product.',
      arabic:
          'اضبط هذا مرة واحدة. RAABTA ستحذّر من مسببات الحساسية وتتحقق من الحلal تلقائياً عند المسح.',
      urdu:
          'ایک بار سیٹ کریں۔ RAABTA الرجی، halal اور اسکور خود چیک کرے گا۔',
    ),
    'profile_halal_section': _e(
      'Halal Requirement',
      arabic: 'متطلبات الحلal',
      urdu: 'حلال کی ضرورت',
    ),
    'profile_halal_toggle': _e(
      'I require Halal-certified products',
      arabic: 'أحتاج منتجات حلal معتمدة',
      urdu: 'مجھے halal-certified پروڈکٹس چاہییں',
    ),
    'profile_halal_hint': _e(
      'RAABTA will show community halal label data (when available) on every scan',
      arabic:
          'ستعرض RAABTA بيانات ملصق الحلال المجتمعية (إن وُجدت) في كل مسح',
      urdu:
          'Raabta ہر اسکین پر community halal label data (اگر موجود) دکھائے گا',
    ),
    'profile_diet_section': _e(
      'Diet Type',
      arabic: 'نوع النظام الغذائي',
      urdu: 'غذائی قسم',
    ),
    'profile_allergen_section': _e(
      'Allergies & Intolerances',
      arabic: 'الحساسية وعدم التحمل',
      urdu: 'الرجی اور intolerance',
    ),
    'profile_allergen_hint': _e(
      'Select all that apply',
      arabic: 'اختر كل ما ينطبق',
      urdu: 'جو لاگو ہو منتخب کریں',
    ),
    'profile_save': _e(
      'Save Profile',
      arabic: 'حفظ الملف',
      urdu: 'پروفائل محفوظ',
    ),
    'profile_save_error': _e(
      'Could not save profile: {error}',
      arabic: 'تعذّر حفظ الملف: {error}',
      urdu: 'پروفائل محفوظ نہیں: {error}',
    ),
    'profile_settings_hint': _e(
      'You can update this anytime from Settings',
      arabic: 'يمكنك التحديث من الإعدادات في أي وقت',
      urdu: 'سیٹنگز سے کسی بھی وقت اپڈیٹ کریں',
    ),
    'diet_no_restriction': _e(
      'No Restriction',
      arabic: 'بدون قيود',
      urdu: 'کوئی پابندی نہیں',
    ),
    'diet_vegetarian': _e('Vegetarian', arabic: 'نباتي', urdu: 'سبزی خور'),
    'diet_vegan': _e('Vegan', arabic: 'نباتي صرف', urdu: 'vegan'),
    'diet_pescatarian': _e('Pescatarian', arabic: 'نباتي + سمك', urdu: 'pescatarian'),
    'diet_keto': _e('Keto', arabic: 'keto', urdu: 'keto'),
    'diet_diabetic': _e(
      'Diabetic-Friendly',
      arabic: 'مناسب لمرضى السكري',
      urdu: 'ذیabetics کے لیے',
    ),
  };
}
