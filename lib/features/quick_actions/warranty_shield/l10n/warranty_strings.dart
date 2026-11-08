// Warranty Shield UI strings — 9-language pipeline via l10nEntry.
//
// Camera/gallery scan labels reuse [BillTrackerStrings] via [scanCamera] etc.
//
// Keys in [keysNeedingReview] use English for ML/NE/TA/BN/FL pending native
// review of retailer policy summaries and legal disclaimer copy.
import 'package:flutter/foundation.dart';
import 'package:raabta/core/l10n/app_locale.dart';
import 'package:raabta/core/l10n/locale_catalog_entry.dart';
import 'package:raabta/core/l10n/locale_catalog_coverage.dart';
import 'package:raabta/features/quick_actions/bill_tracker/l10n/bill_tracker_strings.dart';

abstract final class WarrantyStrings {
  static const supportedLocales = AppLocale.supportedLocales;

  /// Retailer policy + claim disclaimer copy — English fallback until reviewed.
  static const keysNeedingReview = {
    'warr_claim_disclaimer',
    'warr_claim_expired_body',
    'warr_claim_letter_footer',
    'warr_retailer_verify_note',
    'warr_retailer_jarir_policy',
    'warr_retailer_jarir_service',
    'warr_retailer_carrefour_policy',
    'warr_retailer_carrefour_service',
    'warr_retailer_lulu_policy',
    'warr_retailer_lulu_service',
    'warr_retailer_sharaf_policy',
    'warr_retailer_sharaf_service',
    'warr_retailer_virgin_policy',
    'warr_retailer_virgin_service',
  };

  static const _categoryKeys = <String, String>{
    'Electronics': 'warr_cat_electronics',
    'Appliance': 'warr_cat_appliance',
    'Furniture': 'warr_cat_furniture',
    'Vehicle': 'warr_cat_vehicle',
    'General': 'warr_cat_general',
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

  static String scanConfidenceLabel(double confidence, String locale) {
    if (confidence >= 0.65) return t('warr_confidence_high', locale);
    if (confidence >= 0.40) return t('warr_confidence_medium', locale);
    return t('warr_confidence_low', locale);
  }

  static String categoryLabel(String code, String locale) =>
      t(_categoryKeys[code] ?? 'warr_cat_general', locale);

  static String displayProductName(String raw, String locale) {
    final trimmed = raw.trim();
    if (trimmed.isEmpty || trimmed == 'Unknown Product') {
      return t('warr_fallback_product', locale);
    }
    return trimmed;
  }

  static String displayBrand(String raw, String locale) {
    final trimmed = raw.trim();
    if (trimmed.isEmpty || trimmed == 'N/A') {
      return t('warr_fallback_brand', locale);
    }
    return trimmed;
  }

  // ── Reused Bill Tracker scan capture labels ───────────────────
  static String scanCamera(String locale) =>
      BillTrackerStrings.t('scan_camera', locale);

  static String scanGallery(String locale) =>
      BillTrackerStrings.t('scan_gallery', locale);

  @visibleForTesting
  static Iterable<String> get catalogKeys => _catalog.keys;

  @visibleForTesting
  static Map<String, Set<String>> get localeCoverageReport =>
      buildLocaleCoverageReport(
        catalog: _catalog,
        supportedLocales: supportedLocales,
      );

  static final _catalog = <String, Map<String, String>>{
    'warr_screen_title': l10nEntry(
      english: 'Warranty Shield',
      arabic: 'درع الضمان',
      hindi: 'Warranty Shield',
      urdu: 'Warranty Shield',
    ),
    'warr_add_tooltip': l10nEntry(
      english: 'Add Warranty',
      arabic: 'إضافة ضمان',
      hindi: 'Add Warranty',
      urdu: 'Add Warranty',
    ),
    'warr_stat_active': l10nEntry(
      english: 'Active',
      arabic: 'نشط',
      hindi: 'Active',
      urdu: 'Active',
    ),
    'warr_stat_expiring': l10nEntry(
      english: 'Expiring Soon',
      arabic: 'ينتهي قريباً',
      hindi: 'Expiring Soon',
      urdu: 'Expiring Soon',
    ),
    'warr_stat_expired': l10nEntry(
      english: 'Expired',
      arabic: 'منتهٍ',
      hindi: 'Expired',
      urdu: 'Expired',
    ),
    'warr_empty_title': l10nEntry(
      english: 'No warranties tracked yet',
      arabic: 'لا ضمانات متتبعة بعد',
      hindi: 'No warranties tracked yet',
      urdu: 'No warranties tracked yet',
    ),
    'warr_section_expiring': l10nEntry(
      english: '⚠️ Expiring Soon',
      arabic: '⚠️ ينتهي قريباً',
      hindi: '⚠️ Expiring Soon',
      urdu: '⚠️ Expiring Soon',
    ),
    'warr_section_active': l10nEntry(
      english: '🛡️ Active Warranties',
      arabic: '🛡️ ضمانات نشطة',
      hindi: '🛡️ Active Warranties',
      urdu: '🛡️ Active Warranties',
    ),
    'warr_section_expired': l10nEntry(
      english: '✕ Expired',
      arabic: '✕ منتهٍ',
      hindi: '✕ Expired',
      urdu: '✕ Expired',
    ),
    'warr_scan_receipt_title': l10nEntry(
      english: 'Scan a Receipt',
      arabic: 'امسح إيصالاً',
      hindi: 'Scan a Receipt',
      urdu: 'Scan a Receipt',
    ),
    'warr_scan_receipt_sub': l10nEntry(
      english: 'AI auto-detects product & warranty date',
      arabic: 'AI يكتشف المنتج وتاريخ الضمان',
      hindi: 'AI auto-detects product & warranty date',
      urdu: 'AI auto-detects product & warranty date',
    ),
    'warr_scan_receipt_sub_busy': l10nEntry(
      english: 'AI extracting product & warranty date...',
      arabic: 'AI يستخرج المنتج وتاريخ الضمان...',
      hindi: 'AI extracting product & warranty date...',
      urdu: 'AI extracting product & warranty date...',
    ),
    'warr_scan_button': l10nEntry(
      english: 'Scan',
      arabic: 'مسح',
      hindi: 'Scan',
      urdu: 'Scan',
    ),
    'warr_or_fill_manually': l10nEntry(
      english: 'or fill manually',
      arabic: 'أو أدخل يدوياً',
      hindi: 'or fill manually',
      urdu: 'or fill manually',
    ),
    'warr_add_sheet_title': l10nEntry(
      english: 'Add Warranty',
      arabic: 'إضافة ضمان',
      hindi: 'Add Warranty',
      urdu: 'Add Warranty',
    ),
    'warr_hint_product': l10nEntry(
      english: 'Product name (e.g. LG AC)',
      arabic: 'اسم المنتج (مثلاً LG AC)',
      hindi: 'Product name (e.g. LG AC)',
      urdu: 'Product name (e.g. LG AC)',
    ),
    'warr_hint_brand': l10nEntry(
      english: 'Brand',
      arabic: 'العلامة',
      hindi: 'Brand',
      urdu: 'Brand',
    ),
    'warr_hint_price': l10nEntry(
      english: 'Price paid (QAR)',
      arabic: 'السعر المدفوع (ر.ق)',
      hindi: 'Price paid (QAR)',
      urdu: 'Price paid (QAR)',
    ),
    'warr_label_purchase_date': l10nEntry(
      english: 'Purchase date',
      arabic: 'تاريخ الشراء',
      hindi: 'Purchase date',
      urdu: 'Purchase date',
    ),
    'warr_label_expiry': l10nEntry(
      english: 'Warranty expires',
      arabic: 'انتهاء الضمان',
      hindi: 'Warranty expires',
      urdu: 'Warranty expires',
    ),
    'warr_activate_button': l10nEntry(
      english: 'Activate Shield',
      arabic: 'تفعيل الدرع',
      hindi: 'Activate Shield',
      urdu: 'Activate Shield',
    ),
    'warr_snack_activated': l10nEntry(
      english: '🛡️ Warranty Shield Activated!',
      arabic: '🛡️ تم تفعيل درع الضمان!',
      hindi: '🛡️ Warranty Shield Activated!',
      urdu: '🛡️ Warranty Shield Activated!',
    ),
    'warr_snack_from_receipt': l10nEntry(
      english: '🛡️ Warranty Shield activated from receipt!',
      arabic: '🛡️ تم التفعيل من الإيصال!',
      hindi: '🛡️ Warranty Shield activated from receipt!',
      urdu: '🛡️ Warranty Shield activated from receipt!',
    ),
    'warr_snack_scan_failed': l10nEntry(
      english: 'Receipt scan failed: {error}',
      arabic: 'فشل مسح الإيصال: {error}',
      hindi: 'Receipt scan failed: {error}',
      urdu: 'Receipt scan failed: {error}',
    ),
    'warr_snack_picker_failed': l10nEntry(
      english: 'Could not open image picker: {error}',
      arabic: 'تعذّر فتح المعرض: {error}',
      hindi: 'Could not open image picker: {error}',
      urdu: 'Could not open image picker: {error}',
    ),
    'warr_take_photo': l10nEntry(
      english: 'Take Photo',
      arabic: 'التقاط صورة',
      hindi: 'Take Photo',
      urdu: 'Take Photo',
    ),
    'warr_choose_gallery': l10nEntry(
      english: 'Choose from Gallery',
      arabic: 'اختر من المعرض',
      hindi: 'Choose from Gallery',
      urdu: 'Choose from Gallery',
    ),
    'warr_card_expired': l10nEntry(
      english: 'Expired',
      arabic: 'منتهٍ',
      hindi: 'Expired',
      urdu: 'Expired',
    ),
    'warr_card_days_left_act': l10nEntry(
      english: '{days} days left — Act now!',
      arabic: 'متبقي {days} يوم — تصرف الآن!',
      hindi: '{days} days left — Act now!',
      urdu: '{days} days left — Act now!',
    ),
    'warr_card_days_remaining': l10nEntry(
      english: '{days} days remaining',
      arabic: 'متبقي {days} يوم',
      hindi: '{days} days remaining',
      urdu: '{days} days remaining',
    ),
    'warr_fallback_product': l10nEntry(
      english: 'Unknown product',
      arabic: 'منتج غير معروف',
      hindi: 'Unknown product',
      urdu: 'Unknown product',
    ),
    'warr_fallback_brand': l10nEntry(
      english: 'N/A',
      arabic: 'غ/م',
      hindi: 'N/A',
      urdu: 'N/A',
    ),
    'warr_cat_electronics': l10nEntry(
      english: 'Electronics',
      arabic: 'إلكترونيات',
      hindi: 'Electronics',
      urdu: 'Electronics',
    ),
    'warr_cat_appliance': l10nEntry(
      english: 'Appliance',
      arabic: 'أجهزة منزلية',
      hindi: 'Appliance',
      urdu: 'Appliance',
    ),
    'warr_cat_furniture': l10nEntry(
      english: 'Furniture',
      arabic: 'أثاث',
      hindi: 'Furniture',
      urdu: 'Furniture',
    ),
    'warr_cat_vehicle': l10nEntry(
      english: 'Vehicle',
      arabic: 'مركبة',
      hindi: 'Vehicle',
      urdu: 'Vehicle',
    ),
    'warr_cat_general': l10nEntry(
      english: 'General',
      arabic: 'عام',
      hindi: 'General',
      urdu: 'General',
    ),
    'warr_scan_title': l10nEntry(
      english: 'Scan Receipt to Auto-Fill',
      arabic: 'مسح الإيصال للملء التلقائي',
      hindi: 'Scan Receipt to Auto-Fill',
      urdu: 'Scan Receipt to Auto-Fill',
    ),
    'warr_scan_ai_powered': l10nEntry(
      english: 'AI-powered',
      arabic: 'مدعوم بالذكاء الاصطناعي',
      hindi: 'AI-powered',
      urdu: 'AI-powered',
    ),
    'warr_scan_camera': l10nEntry(
      english: 'Camera',
      arabic: 'الكاميرا',
      hindi: 'Camera',
      urdu: 'Camera',
    ),
    'warr_scan_gallery': l10nEntry(
      english: 'Gallery',
      arabic: 'المعرض',
      hindi: 'Gallery',
      urdu: 'Gallery',
    ),
    'warr_scan_subtitle': l10nEntry(
      english: 'Product name, price & purchase date auto-filled from receipt',
      arabic: 'يُملأ الاسم والسعر وتاريخ الشراء من الإيصال',
      hindi: 'Product name, price & purchase date auto-filled from receipt',
      urdu: 'Product name, price & purchase date auto-filled from receipt',
    ),
    'warr_scan_reading': l10nEntry(
      english: 'Reading receipt text...',
      arabic: 'جاري قراءة الإيصال...',
      hindi: 'Reading receipt text...',
      urdu: 'Reading receipt text...',
    ),
    'warr_scan_extracting': l10nEntry(
      english: 'Extracting product details with AI...',
      arabic: 'جاري استخراج التفاصيل بالذكاء الاصطناعي...',
      hindi: 'Extracting product details with AI...',
      urdu: 'Extracting product details with AI...',
    ),
    'warr_scan_processing': l10nEntry(
      english: 'Processing...',
      arabic: 'جاري المعالجة...',
      hindi: 'Processing...',
      urdu: 'Processing...',
    ),
    'warr_scan_camera_macos': l10nEntry(
      english: 'Camera scanning available on iPhone only. Use "Upload Photo" instead.',
      arabic: 'مسح الكاميرا على iPhone فقط. استخدم رفع صورة.',
      hindi: 'Camera scanning available on iPhone only. Use Upload Photo instead.',
      urdu: 'Camera scanning available on iPhone only. Use Upload Photo instead.',
    ),
    'warr_scan_no_text': l10nEntry(
      english: 'Could not read text from this image. Try a clearer photo.',
      arabic: 'تعذّر قراءة النص. جرّب صورة أوضح.',
      hindi: 'Could not read text from this image. Try a clearer photo.',
      urdu: 'Could not read text from this image. Try a clearer photo.',
    ),
    'warr_scan_process_error': l10nEntry(
      english: 'Could not process receipt. Try again.',
      arabic: 'تعذّرت معالجة الإيصال. حاول مجدداً.',
      hindi: 'Could not process receipt. Try again.',
      urdu: 'Could not process receipt. Try again.',
    ),
    'warr_confidence_high': l10nEntry(
      english: 'High confidence',
      arabic: 'ثقة عالية',
      hindi: 'High confidence',
      urdu: 'High confidence',
    ),
    'warr_confidence_medium': l10nEntry(
      english: 'Medium confidence — verify fields',
      arabic: 'ثقة متوسطة — تحقق من الحقول',
      hindi: 'Medium confidence — verify fields',
      urdu: 'Medium confidence — verify fields',
    ),
    'warr_confidence_low': l10nEntry(
      english: 'Low confidence — please fill manually',
      arabic: 'ثقة منخفضة — أدخل يدوياً',
      hindi: 'Low confidence — please fill manually',
      urdu: 'Low confidence — please fill manually',
    ),
    'warr_repair_shops_title': l10nEntry(
      english: 'Repair Shops Near You',
      arabic: 'ورش إصلاح قريبة',
      hindi: 'Repair Shops Near You',
      urdu: 'Repair Shops Near You',
    ),
    'warr_repair_warranty_badge': l10nEntry(
      english: 'Get it fixed free under warranty',
      arabic: 'أصلح مجاناً تحت الضمان',
      hindi: 'Get it fixed free under warranty',
      urdu: 'Get it fixed free under warranty',
    ),
    'warr_repair_view': l10nEntry(
      english: 'View',
      arabic: 'عرض',
      hindi: 'View',
      urdu: 'View',
    ),
    'warr_repair_shop_fallback': l10nEntry(
      english: 'Repair Shop',
      arabic: 'ورشة إصلاح',
      hindi: 'Repair Shop',
      urdu: 'Repair Shop',
    ),
    'warr_area_qatar': l10nEntry(
      english: 'Qatar',
      arabic: 'قطر',
      hindi: 'Qatar',
      urdu: 'Qatar',
    ),
    'warr_entry_mode_manual': l10nEntry(
      english: 'Manual entry',
      arabic: 'إدخال يدوي',
      hindi: 'Manual entry',
      urdu: 'Manual entry',
    ),
    'warr_entry_mode_scan': l10nEntry(
      english: 'Scan receipt',
      arabic: 'مسح الإيصال',
      hindi: 'Scan receipt',
      urdu: 'Scan receipt',
    ),
    'warr_review_title': l10nEntry(
      english: 'Review warranty details',
      arabic: 'مراجعة تفاصيل الضمان',
      hindi: 'Review warranty details',
      urdu: 'Review warranty details',
    ),
    'warr_review_low_confidence': l10nEntry(
      english:
          'Some details could not be read clearly — please verify every field before saving.',
      arabic:
          'تعذّر قراءة بعض التفاصيل بوضوح — يرجى التحقق من كل حقل قبل الحفظ.',
      hindi:
          'Some details could not be read clearly — please verify every field before saving.',
      urdu:
          'Some details could not be read clearly — please verify every field before saving.',
    ),
    'warr_review_missing_expiry': l10nEntry(
      english:
          'Warranty duration or expiry was not found on the document — set an expiry date so reminders work.',
      arabic:
          'لم يُعثر على مدة أو تاريخ انتهاء الضمان — حدّد تاريخ انتهاء لتفعيل التذكيرات.',
      hindi:
          'Warranty duration or expiry was not found — set an expiry date so reminders work.',
      urdu:
          'Warranty duration or expiry was not found — set an expiry date so reminders work.',
    ),
    'warr_review_need_product': l10nEntry(
      english: 'Enter a product name to continue.',
      arabic: 'أدخل اسم المنتج للمتابعة.',
      hindi: 'Enter a product name to continue.',
      urdu: 'Enter a product name to continue.',
    ),
    'warr_review_expiry_before': l10nEntry(
      english: 'Expiry date must be after the purchase date.',
      arabic: 'يجب أن يكون تاريخ الانتهاء بعد تاريخ الشراء.',
      hindi: 'Expiry date must be after the purchase date.',
      urdu: 'Expiry date must be after the purchase date.',
    ),
    'warr_review_save': l10nEntry(
      english: 'Save warranty',
      arabic: 'حفظ الضمان',
      hindi: 'Save warranty',
      urdu: 'Save warranty',
    ),
    'warr_review_currency_note': l10nEntry(
      english: 'Extracted currency: {currency} — amount stored in QAR field.',
      arabic: 'العملة المستخرجة: {currency} — المبلغ يُحفظ في حقل ر.ق.',
      hindi: 'Extracted currency: {currency} — amount stored in QAR field.',
      urdu: 'Extracted currency: {currency} — amount stored in QAR field.',
    ),
    'warr_field_retailer': l10nEntry(
      english: 'Retailer / store',
      arabic: 'المتجر',
      hindi: 'Retailer / store',
      urdu: 'Retailer / store',
    ),
    'warr_field_category': l10nEntry(
      english: 'Category',
      arabic: 'الفئة',
      hindi: 'Category',
      urdu: 'Category',
    ),
    'warr_field_duration_months': l10nEntry(
      english: 'Warranty duration (months, if known)',
      arabic: 'مدة الضمان (بالأشهر، إن وُجدت)',
      hindi: 'Warranty duration (months, if known)',
      urdu: 'Warranty duration (months, if known)',
    ),
    'warr_claim_file': l10nEntry(
      english: 'File a Claim',
      arabic: 'تقديم مطالبة',
      hindi: 'File a Claim',
      urdu: 'File a Claim',
    ),
    'warr_claim_file_expired': l10nEntry(
      english: 'File a Claim (expired)',
      arabic: 'تقديم مطالبة (منتهٍ)',
      hindi: 'File a Claim (expired)',
      urdu: 'File a Claim (expired)',
    ),
    'warr_claim_expired_hint': l10nEntry(
      english:
          'This warranty appears expired — you will be asked to confirm before drafting.',
      arabic: 'يبدو أن الضمان منتهياً — سيُطلب منك التأكيد قبل المسودة.',
      hindi:
          'This warranty appears expired — confirm before drafting.',
      urdu:
          'This warranty appears expired — confirm before drafting.',
    ),
    'warr_claim_expired_title': l10nEntry(
      english: 'Warranty expired',
      arabic: 'الضمان منتهٍ',
      hindi: 'Warranty expired',
      urdu: 'Warranty expired',
    ),
    'warr_claim_expired_body': l10nEntry(
      english:
          'This item\'s warranty period has passed. Raabta can still help you draft a factual message, but the retailer may not honour an expired warranty. Continue?',
      arabic:
          'انتهت فترة الضمان. يمكن لـ Raabta مساعدتك في صياغة رسالة واقعية، لكن المتجر قد لا يقبل مطالبة منتهية. متابعة؟',
      hindi:
          'Warranty period has passed. Draft is factual only — retailer may reject. Continue?',
      urdu:
          'Warranty period has passed. Draft is factual only — retailer may reject. Continue?',
    ),
    'warr_claim_expired_cancel': l10nEntry(
      english: 'Cancel',
      arabic: 'إلغاء',
      hindi: 'Cancel',
      urdu: 'Cancel',
    ),
    'warr_claim_expired_proceed': l10nEntry(
      english: 'Continue anyway',
      arabic: 'متابعة على أي حال',
      hindi: 'Continue anyway',
      urdu: 'Continue anyway',
    ),
    'warr_claim_title': l10nEntry(
      english: 'Claim Assistant',
      arabic: 'مساعد المطالبات',
      hindi: 'Claim Assistant',
      urdu: 'Claim Assistant',
    ),
    'warr_claim_disclaimer': l10nEntry(
      english:
          'Informational draft only — not legal advice. Contact the retailer first; for unresolved consumer product issues MOCI hotline 16001 may apply. Consult a qualified advisor for case-specific advice.',
      arabic:
          'مسودة إرشادية فقط — ليست استشارة قانونية. تواصل مع المتجر أولاً؛ للشكاوى الاستهلاكية غير المحلولة: MOCI 16001. استشر مستشاراً مؤهلاً.',
      hindi:
          'Informational draft only — not legal advice. Contact retailer first; MOCI 16001 for unresolved issues.',
      urdu:
          'Informational draft only — not legal advice. Contact retailer first; MOCI 16001 for unresolved issues.',
    ),
    'warr_claim_ai_disclaimer': l10nEntry(
      english: 'AI drafts are informational only — not legal advice.',
      arabic: 'مسودات AI إرشادية فقط — ليست استشارة قانونية.',
      hindi: 'AI drafts are informational only — not legal advice.',
      urdu: 'AI drafts are informational only — not legal advice.',
    ),
    'warr_claim_expired_banner': l10nEntry(
      english:
          'You are drafting for an item past its tracked warranty expiry — outcomes are uncertain.',
      arabic: 'أنت تكتب لمنتج تجاوز تاريخ انتهاء الضمان — النتائج غير مؤكدة.',
      hindi: 'Drafting for expired warranty — outcomes uncertain.',
      urdu: 'Drafting for expired warranty — outcomes uncertain.',
    ),
    'warr_claim_product_heading': l10nEntry(
      english: 'Claim for {product}',
      arabic: 'مطالبة لـ {product}',
      hindi: 'Claim for {product}',
      urdu: 'Claim for {product}',
    ),
    'warr_claim_issue_hint': l10nEntry(
      english: 'What is wrong? When did it start?',
      arabic: 'ما المشكلة؟ متى بدأت؟',
      hindi: 'What is wrong? When did it start?',
      urdu: 'What is wrong? When did it start?',
    ),
    'warr_claim_issue_required': l10nEntry(
      english: 'Describe the issue before generating a draft.',
      arabic: 'صف المشكلة قبل إنشاء المسودة.',
      hindi: 'Describe the issue before generating a draft.',
      urdu: 'Describe the issue before generating a draft.',
    ),
    'warr_claim_attach_photo': l10nEntry(
      english: 'Attach fault photo (optional)',
      arabic: 'إرفاق صورة العطل (اختياري)',
      hindi: 'Attach fault photo (optional)',
      urdu: 'Attach fault photo (optional)',
    ),
    'warr_claim_photo_attached': l10nEntry(
      english: 'Photo attached — tap to replace',
      arabic: 'تم إرفاق صورة — اضغط للاستبدال',
      hindi: 'Photo attached — tap to replace',
      urdu: 'Photo attached — tap to replace',
    ),
    'warr_claim_generate': l10nEntry(
      english: 'Generate claim draft',
      arabic: 'إنشاء مسودة المطالبة',
      hindi: 'Generate claim draft',
      urdu: 'Generate claim draft',
    ),
    'warr_claim_draft_failed': l10nEntry(
      english: 'Could not generate draft: {error}',
      arabic: 'تعذّر إنشاء المسودة: {error}',
      hindi: 'Could not generate draft: {error}',
      urdu: 'Could not generate draft: {error}',
    ),
    'warr_claim_draft_label': l10nEntry(
      english: 'Edit your draft before sending',
      arabic: 'عدّل مسودتك قبل الإرسال',
      hindi: 'Edit your draft before sending',
      urdu: 'Edit your draft before sending',
    ),
    'warr_claim_share': l10nEntry(
      english: 'Share via WhatsApp / Email',
      arabic: 'مشاركة عبر واتساب / البريد',
      hindi: 'Share via WhatsApp / Email',
      urdu: 'Share via WhatsApp / Email',
    ),
    'warr_claim_export_pdf': l10nEntry(
      english: 'Export PDF',
      arabic: 'تصدير PDF',
      hindi: 'Export PDF',
      urdu: 'Export PDF',
    ),
    'warr_claim_letter_footer': l10nEntry(
      english:
          'Drafted from the information you provided. Review carefully before sending — you are responsible for its accuracy.',
      arabic:
          'مسودة من المعلومات التي قدمتها. راجعها بعناية قبل الإرسال — أنت مسؤول عن دقتها.',
      hindi:
          'Drafted from your information. Review before sending — you are responsible for accuracy.',
      urdu:
          'Drafted from your information. Review before sending — you are responsible for accuracy.',
    ),
    'warr_claim_pdf_title': l10nEntry(
      english: 'Warranty Claim Draft',
      arabic: 'مسودة مطالبة الضمان',
      hindi: 'Warranty Claim Draft',
      urdu: 'Warranty Claim Draft',
    ),
    'warr_claim_pdf_share_caption': l10nEntry(
      english: 'Warranty claim draft from RAABTA Warranty Shield',
      arabic: 'مسودة مطالبة ضمان من RAABTA',
      hindi: 'Warranty claim draft from RAABTA',
      urdu: 'Warranty claim draft from RAABTA',
    ),
    'warr_claim_share_subject': l10nEntry(
      english: 'Warranty claim: {product}',
      arabic: 'مطالبة ضمان: {product}',
      hindi: 'Warranty claim: {product}',
      urdu: 'Warranty claim: {product}',
    ),
    'warr_retailer_card_title': l10nEntry(
      english: 'Contact {retailer}',
      arabic: 'تواصل مع {retailer}',
      hindi: 'Contact {retailer}',
      urdu: 'Contact {retailer}',
    ),
    'warr_retailer_phone': l10nEntry(
      english: 'Customer service',
      arabic: 'خدمة العملاء',
      hindi: 'Customer service',
      urdu: 'Customer service',
    ),
    'warr_retailer_service': l10nEntry(
      english: 'Service / repairs',
      arabic: 'الخدمة / الإصلاح',
      hindi: 'Service / repairs',
      urdu: 'Service / repairs',
    ),
    'warr_retailer_website': l10nEntry(
      english: 'Official website',
      arabic: 'الموقع الرسمي',
      hindi: 'Official website',
      urdu: 'Official website',
    ),
    'warr_retailer_unconfirmed': l10nEntry(
      english: 'Unconfirmed — verify on official source before relying on this',
      arabic: 'غير مؤكد — تحقق من المصدر الرسمي قبل الاعتماد',
      hindi: 'Unconfirmed — verify on official source',
      urdu: 'Unconfirmed — verify on official source',
    ),
    'warr_retailer_verify_note': l10nEntry(
      english:
          'Policy and contact details are reference-only. Store terms can change — always confirm with the retailer.',
      arabic:
          'تفاصيل السياسة والاتصال للمرجع فقط. قد تتغير شروط المتجر — أكّد دائماً مع البائع.',
      hindi: 'Reference only — confirm with retailer before acting.',
      urdu: 'Reference only — confirm with retailer before acting.',
    ),
    'warr_retailer_start_claim': l10nEntry(
      english: 'Start claim with Claim Assistant',
      arabic: 'ابدأ المطالبة عبر المساعد',
      hindi: 'Start claim with Claim Assistant',
      urdu: 'Start claim with Claim Assistant',
    ),
    'warr_retailer_moci_link': l10nEntry(
      english: 'Unresolved? See MOCI consumer complaint guide',
      arabic: 'لم تُحل؟ راجع دليل شكاوى MOCI',
      hindi: 'Unresolved? See MOCI consumer complaint guide',
      urdu: 'Unresolved? See MOCI consumer complaint guide',
    ),
    'warr_retailer_jarir_policy': l10nEntry(
      english:
          'Electronics are typically covered by manufacturer warranty with in-store support for eligible defects — bring your RAABTA-saved receipt. Exchange/refund windows vary by product; confirm at purchase or on Jarir\'s site.',
      arabic:
          'الإلكترونيات عادةً مشمولة بضمان المصنع مع دعم في المتجر — أحضر إيصالك. فترات الاستبدال تختلف — أكّد على موقع Jarir.',
      hindi:
          'Manufacturer warranty with in-store support — bring receipt. Confirm policy on Jarir site.',
      urdu:
          'Manufacturer warranty with in-store support — bring receipt. Confirm policy on Jarir site.',
    ),
    'warr_retailer_jarir_service': l10nEntry(
      english:
          'In-store customer service desks at Jarir branches; brand authorized centers for major electronics — confirm branch on jarir.com',
      arabic: 'مكاتب خدمة العملاء في فروع Jarir — أكّد الفرع على jarir.com',
      hindi: 'Jarir branch customer service — confirm on jarir.com',
      urdu: 'Jarir branch customer service — confirm on jarir.com',
    ),
    'warr_retailer_carrefour_policy': l10nEntry(
      english:
          'Carrefour Qatar generally honours manufacturer warranty on electronics/appliances with receipt; return/exchange periods depend on product category — verify on carrefourqatar.com or at the service desk.',
      arabic:
          'Carrefour Qatar ي honour ضمان المصنع عادةً مع الإيصال — تحقق من carrefourqatar.com',
      hindi: 'Manufacturer warranty with receipt — verify on carrefourqatar.com',
      urdu: 'Manufacturer warranty with receipt — verify on carrefourqatar.com',
    ),
    'warr_retailer_carrefour_service': l10nEntry(
      english:
          'Customer service at hypermarket branches; large appliances may use brand service partners — ask in-store',
      arabic: 'خدمة العملاء في الفروع — اسأل في المتجر',
      hindi: 'Hypermarket customer service — ask in-store',
      urdu: 'Hypermarket customer service — ask in-store',
    ),
    'warr_retailer_lulu_policy': l10nEntry(
      english:
          'Lulu Hypermarket electronics/appliances usually follow manufacturer warranty terms with original receipt; promotional return windows differ — confirm on luluhypermarket.com.',
      arabic:
          'منتجات Lulu تتبع ضمان المصنع عادةً مع الإيصال — أكّد على luluhypermarket.com',
      hindi: 'Manufacturer warranty with receipt — confirm on luluhypermarket.com',
      urdu: 'Manufacturer warranty with receipt — confirm on luluhypermarket.com',
    ),
    'warr_retailer_lulu_service': l10nEntry(
      english:
          'Visit the customer service counter at your purchase branch; major brands may redirect to authorized repair — confirm in-store',
      arabic: 'مكتب خدمة العملاء في فرع الشراء — أكّد في المتجر',
      hindi: 'Customer service at purchase branch',
      urdu: 'Customer service at purchase branch',
    ),
    'warr_retailer_sharaf_policy': l10nEntry(
      english:
          'Sharaf DG electronics are sold with manufacturer warranty; in-store support assists with eligible claims when you have proof of purchase — see sharafdg.com/qatar for current terms.',
      arabic:
          'Sharaf DG — ضمان المصنع مع إثبات الشراء — راجع sharafdg.com/qatar',
      hindi: 'Manufacturer warranty with proof of purchase — sharafdg.com/qatar',
      urdu: 'Manufacturer warranty with proof of purchase — sharafdg.com/qatar',
    ),
    'warr_retailer_sharaf_service': l10nEntry(
      english:
          'Sharaf DG stores (e.g. Doha Festival City, Mall of Qatar) — confirm service desk hours on official site',
      arabic: 'فروع Sharaf DG — أكّد مواعيد مكتب الخدمة على الموقع',
      hindi: 'Sharaf DG store service desks — confirm on site',
      urdu: 'Sharaf DG store service desks — confirm on site',
    ),
    'warr_retailer_virgin_policy': l10nEntry(
      english:
          'Virgin Megastore Qatar sells brand-warrantied electronics; defects are typically routed through manufacturer or store support with receipt — confirm current policy on virginmegastore.qa.',
      arabic:
          'Virgin Megastore — ضمان العلامة مع الإيصال — أكّد على virginmegastore.qa',
      hindi: 'Brand warranty with receipt — virginmegastore.qa',
      urdu: 'Brand warranty with receipt — virginmegastore.qa',
    ),
    'warr_retailer_virgin_service': l10nEntry(
      english:
          'Villaggio Mall and other listed branches — contact store customer service; confirm locations online',
      arabic: 'فروع مثل Villaggio — تواصل مع خدمة العملاء — أكّد المواقع',
      hindi: 'Store customer service at listed branches',
      urdu: 'Store customer service at listed branches',
    ),
  };
}
