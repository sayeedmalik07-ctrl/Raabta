import 'package:flutter/foundation.dart';
import 'package:raabta/core/l10n/app_locale.dart';
import 'package:raabta/core/l10n/locale_catalog_entry.dart';
import 'package:raabta/core/l10n/locale_catalog_coverage.dart';
import 'package:raabta/features/post_engine/l10n/post_engine_part5_l10n.dart';
import 'package:raabta/features/post_engine/l10n/post_engine_part8_l10n.dart';
import 'package:raabta/features/post_engine/l10n/post_engine_part11_l10n.dart';
import 'package:raabta/features/post_engine/l10n/post_engine_part12_l10n.dart';
import 'package:raabta/features/post_engine/l10n/post_engine_marketplace_photo_l10n.dart';
import 'package:raabta/features/post_engine/l10n/post_engine_business_l10n.dart';

/// Post engine localization — all schema label/placeholder/error keys.
abstract final class PostEngineStrings {
  static const supportedLocales = AppLocale.supportedLocales;

  @visibleForTesting
  static Map<String, Set<String>> get localeCoverageReport =>
      buildLocaleCoverageReport(
        catalog: _catalog,
        supportedLocales: supportedLocales,
      );

  static String t(String key, [String locale = 'English']) {
    final normalized = AppLocale.normalize(locale);
    final map = _catalog[key];
    if (map == null) return key;
    return map[normalized] ?? map['English'] ?? key;
  }

  static String label(String key, String locale, {String? fallback}) {
    final resolved = t(key, locale);
    if (resolved != key) return resolved;
    if (fallback != null && fallback.isNotEmpty) return fallback;
    if (key.startsWith('year_')) return key.substring(5);
    if (key.startsWith('make_')) {
      return humanizeKey(key.substring(5));
    }
    if (key.startsWith('cat_')) return humanizeCategoryKey(key);
    return humanizeKey(key);
  }

  /// Strips schema key prefixes before humanizing — avoids "Cat Svc Home Maintenance".
  static String humanizeCategoryKey(String key) {
    var stripped = key;
    const prefixes = [
      'cat_svc_',
      'cat_job_',
      'cat_biz_',
      'cat_housing_',
    ];
    for (final prefix in prefixes) {
      if (stripped.startsWith(prefix)) {
        stripped = stripped.substring(prefix.length);
        break;
      }
    }
    if (stripped.startsWith('cat_')) {
      stripped = stripped.substring(4);
    }
    return humanizeKey(stripped);
  }

  /// Readable fallback when Firestore keys are missing from the catalog.
  static String humanizeKey(String key) {
    return key
        .replaceAll('-', '_')
        .split('_')
        .where((part) => part.isNotEmpty)
        .map(
          (part) =>
              part.length == 1 ? part.toUpperCase() : '${part[0].toUpperCase()}${part.substring(1)}',
        )
        .join(' ');
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

  static Map<String, Map<String, String>> get catalog => _catalog;

  /// Maps stored English benefit tokens to localized labels.
  static String benefitLabel(String benefit, String locale) {
    final key = switch (benefit.trim().toLowerCase()) {
      'housing' => 'benefit_housing',
      'flight' => 'benefit_flight',
      'medical' => 'benefit_medical',
      'other' => 'benefit_other',
      _ => null,
    };
    return key != null ? t(key, locale) : benefit;
  }

  static final Map<String, Map<String, String>> _catalog = {
    ..._fieldKeys,
    ..._optionKeys,
    ..._categoryKeys,
    ..._errorKeys,
    ..._actionKeys,
    ...postEnginePart5FieldKeys,
    ...postEnginePart5OptionKeys,
    ...postEnginePart8FieldKeys,
    ...postEnginePart8OptionKeys,
    ...postEnginePart11Keys,
    ...postEnginePart12Keys,
    ...postEngineMarketplacePhotoKeys,
    ...postEngineBusinessFieldKeys,
    ...postEngineBusinessOptionKeys,
  };
}

final Map<String, Map<String, String>> _actionKeys = {
  'action_add_photo': l10nEntry(english: 'Add photo'),
  'photo_pick_error': l10nEntry(
    english: 'Could not open photos. Check permissions and try again.',
    arabic: 'تعذّر فتح الصور. تحقق من الأذونات وحاول مرة أخرى.',
  ),
  'photo_count': l10nEntry(
    english: '{count} of {max} photos',
    arabic: '{count} من {max} صورة',
  ),
  'photo_category_mismatch': l10nEntry(
    english: 'This photo may not match the selected category. Add a relevant photo or continue manually.',
    arabic: 'قد لا تتطابق هذه الصورة مع الفئة المختارة. أضف صورة مناسبة أو تابع يدوياً.',
  ),
  'schema_load_error': l10nEntry(english: 'Could not load form schema. Check connection and retry.'),
  'schema_retry': l10nEntry(english: 'Retry'),
  'action_save_draft': l10nEntry(english: 'Save Draft', arabic: 'حفظ المسودة'),
  'action_save_business': l10nEntry(english: 'Save Business'),
  'action_preview_housing': l10nEntry(english: 'Preview Housing'),
  'action_preview_job': l10nEntry(english: 'Preview Job'),
  'action_preview_business': l10nEntry(english: 'Preview Business'),
  'action_preview_service': l10nEntry(english: 'Preview Service'),
  'action_preview_item': l10nEntry(english: 'Preview Item'),
  'action_publish_housing': l10nEntry(english: 'Publish Housing'),
  'action_publish_job': l10nEntry(english: 'Publish Job'),
  'action_publish_business': l10nEntry(english: 'Publish Business'),
  'action_publish_service': l10nEntry(english: 'Publish Service'),
  'action_publish_item': l10nEntry(english: 'Publish Item'),
  'action_back_to_edit': l10nEntry(english: 'Back to edit'),
  'action_choose_visibility': l10nEntry(
    english: 'Choose Visibility',
    arabic: 'اختر مستوى الظهور',
  ),
  'action_skip_visibility': l10nEntry(
    english: 'Publish without boost',
    arabic: 'النشر بدون تعزيز',
  ),
  'trust_review_required': l10nEntry(
    english: 'Additional verification required before publishing',
    arabic: 'مطلوب تحقق إضافي قبل النشر',
  ),
  'flow_title_housing': l10nEntry(english: 'Post Housing'),
  'flow_title_job': l10nEntry(english: 'Post Job'),
  'flow_title_business': l10nEntry(english: 'Create Business'),
  'flow_title_service': l10nEntry(english: 'Post Service'),
  'flow_subtitle_service': l10nEntry(
    english: 'Offer a service or post what you need',
    arabic: 'قدّم خدمة أو انشر ما تحتاجه',
  ),
  'flow_subtitle_service_request': l10nEntry(
    english: 'Describe what you need — we suggest a category',
    arabic: 'صف ما تحتاجه — نقترح الفئة المناسبة',
  ),
  'flow_title_marketplace': l10nEntry(english: 'Post Item'),
  'flow_subtitle_marketplace': l10nEntry(
    english: 'Add photos, pick a category, and list your item',
    arabic: 'أضف الصور، اختر فئة، وأدرج سلعتك',
  ),
  'pick_category': l10nEntry(english: 'Choose category'),
  'category_search_label': l10nEntry(
    english: 'What are you posting?',
    arabic: 'ماذا تريد أن تنشر؟',
  ),
  'category_search_hint': l10nEntry(
    english: 'e.g. iPhone 13, 2 bedroom apartment, AC repair',
    arabic: 'مثال: آيفون 13، شقة غرفتين، صيانة مكيف',
  ),
  'category_search_or_browse': l10nEntry(
    english: 'Or browse categories',
    arabic: 'أو تصفح الفئات',
  ),
  'category_search_no_results': l10nEntry(
    english: 'No matching categories — browse below',
    arabic: 'لا توجد فئات مطابقة — تصفح أدناه',
  ),
  'flow_step_of': l10nEntry(english: 'Step {current} of {total}'),
  'flow_step_photos': l10nEntry(
    english: 'Add photos',
    arabic: 'إضافة صور',
  ),
  'flow_step_category': l10nEntry(english: 'Choose category'),
  'flow_step_listing_type': l10nEntry(
    english: 'Offering or need',
    arabic: 'عرض أو طلب',
  ),
  'flow_step_details': l10nEntry(english: 'Listing details'),
  'listing_type_prompt': l10nEntry(
    english: 'What would you like to post?',
    arabic: 'ماذا تريد أن تنشر؟',
  ),
  'listing_type_subtitle': l10nEntry(
    english: 'Choose whether you are offering a service or looking for help.',
    arabic: 'اختر ما إذا كنت تقدم خدمة أو تبحث عن مساعدة.',
  ),
  'listing_type_offering': l10nEntry(
    english: "I'm offering this service",
    arabic: 'أقدم هذه الخدمة',
  ),
  'listing_type_offering_hint': l10nEntry(
    english: 'Post your skills, rates, and availability for customers to find.',
    arabic: 'انشر مهاراتك وأسعارك وتوفرك ليجدك العملاء.',
  ),
  'listing_type_need': l10nEntry(
    english: 'I need this service',
    arabic: 'أحتاج هذه الخدمة',
  ),
  'listing_type_need_hint': l10nEntry(
    english: 'Describe what you need so providers in your area can respond.',
    arabic: 'صف ما تحتاجه ليرد مقدمو الخدمة في منطقتك.',
  ),
  'action_use_current_location': l10nEntry(
    english: 'Use current location',
    arabic: 'استخدم موقعي الحالي',
  ),
  'location_visibility_hint': l10nEntry(
    english: 'Your listing will be shown to people browsing in the selected area.',
    arabic: 'سيظهر إعلانك للأشخاص الذين يتصفحون في المنطقة المحددة.',
  ),
  'location_manual_hint': l10nEntry(
    english: 'Or select area manually',
    arabic: 'أو اختر المنطقة يدوياً',
  ),
  'location_permission_denied': l10nEntry(
    english: 'Location permission is required to auto-fill your area.',
    arabic: 'يلزم إذن الموقع لملء منطقتك تلقائياً.',
  ),
  'draft_saved_just_now': l10nEntry(english: 'Saved just now', arabic: 'تم الحفظ الآن'),
  'draft_saved_ago': l10nEntry(english: 'Draft saved {seconds} seconds ago'),
  'quality_percent': l10nEntry(english: '{percent}% Complete'),
  'quality_to_improve': l10nEntry(english: 'To improve your listing:'),
  'quality_missing_field': l10nEntry(english: 'Add {field}'),
  'quality_missing_photos': l10nEntry(english: 'Add {needed} more photo(s) (minimum {min})'),
  'quality_publish_blocked': l10nEntry(english: 'Complete required fields before publishing'),
  'sign_in_required': l10nEntry(english: 'Sign in to publish'),
  'publish_success': l10nEntry(english: 'Published successfully'),
  'publish_failed': l10nEntry(english: 'Could not publish'),
  'publish_media_incomplete': l10nEntry(
    english:
        'Your listing was created but photos are incomplete. Fix photos and tap Publish again to resume.',
    arabic:
        'تم إنشاء إعلانك لكن الصور غير مكتملة. أصلح الصور واضغط نشر للمتابعة.',
  ),
  'publish_in_flight': l10nEntry(
    english: 'Publish is already in progress',
    arabic: 'النشر قيد التنفيذ بالفعل',
  ),
  'publish_missing_photos': l10nEntry(
    english: 'Required photos are missing on this device. Re-add them and retry.',
    arabic: 'الصور المطلوبة غير متوفرة على هذا الجهاز. أعد إضافتها وحاول مرة أخرى.',
  ),
  'publish_ownership_denied': l10nEntry(
    english: 'This listing cannot be resumed for your account.',
    arabic: 'لا يمكن استئناف هذا الإعلان لحسابك.',
  ),
  'preview_untitled': l10nEntry(english: 'Untitled listing'),
  'my_posts_title': l10nEntry(english: 'My Posts'),
  'tab_all': l10nEntry(english: 'All'),
  'tab_drafts': l10nEntry(english: 'Drafts'),
  'tab_pending': l10nEntry(english: 'Pending Review'),
  'tab_published': l10nEntry(english: 'Published'),
  'tab_expiring': l10nEntry(english: 'Expiring Soon'),
  'tab_expired': l10nEntry(english: 'Expired'),
  'tab_rejected': l10nEntry(english: 'Rejected'),
  'tab_archived': l10nEntry(english: 'Archived'),
  'filter_housing': l10nEntry(english: 'Housing'),
  'filter_jobs': l10nEntry(english: 'Jobs'),
  'filter_business': l10nEntry(english: 'Business'),
  'filter_services': l10nEntry(english: 'Services'),
  'filter_marketplace': l10nEntry(english: 'Marketplace'),
  'requirements_section': l10nEntry(english: 'Requirements'),
  'requirements_hint': l10nEntry(english: 'Add skills, experience, qualifications, or languages'),
  'ui_schema_preview_title': l10nEntry(english: 'Schema Preview'),
  'action_validate': l10nEntry(english: 'Validate'),
  'field_skills_comma_separated': l10nEntry(english: 'Skills (comma-separated)'),
  'field_minimum_experience_label': l10nEntry(english: 'Minimum experience'),
  'field_qualifications_label': l10nEntry(english: 'Qualifications'),
  'field_language_requirements_label': l10nEntry(english: 'Language requirements'),
  'benefit_housing': l10nEntry(english: 'Housing', arabic: 'سكن'),
  'benefit_flight': l10nEntry(english: 'Flight', arabic: 'تذكرة طيران'),
  'benefit_medical': l10nEntry(english: 'Medical', arabic: 'تأمين طبي'),
  'benefit_other': l10nEntry(english: 'Other', arabic: 'أخرى'),
  'field_job_title': l10nEntry(english: 'Job title'),
  'field_company': l10nEntry(english: 'Company'),
  'field_salary': l10nEntry(english: 'Salary'),
  'field_contact': l10nEntry(english: 'WhatsApp / contact'),
  'field_email': l10nEntry(english: 'Email'),
  'field_business_name': l10nEntry(english: 'Business name'),
  'field_phone': l10nEntry(english: 'Phone'),
  'field_whatsapp': l10nEntry(english: 'WhatsApp'),
  'field_languages': l10nEntry(english: 'Languages spoken'),
  'field_housing_title': l10nEntry(english: 'Listing title'),
  'field_gender_preference': l10nEntry(english: 'Gender preference'),
};

final Map<String, Map<String, String>> _errorKeys = {
  'error_required': l10nEntry(
    english: 'This field is required',
    arabic: 'هذا الحقل مطلوب',
  ),
  'error_required_field': l10nEntry(
    english: 'Please enter {field}',
    arabic: 'يرجى إدخال {field}',
  ),
  'error_required_select': l10nEntry(
    english: 'Please select {field}',
    arabic: 'يرجى اختيار {field}',
  ),
  'error_required_photos': l10nEntry(
    english: 'Please add at least one photo',
    arabic: 'يرجى إضافة صورة واحدة على الأقل',
  ),
  'error_min_length': l10nEntry(english: 'Enter at least {min} characters'),
  'error_min_length_field': l10nEntry(
    english: 'Please enter at least {min} characters for {field}',
  ),
  'error_min_value': l10nEntry(english: 'Enter a valid amount'),
  'error_min_value_field': l10nEntry(
    english: 'Please enter a valid amount for {field}',
  ),
  'error_min_photos': l10nEntry(english: 'Add at least {min} photo'),
  'error_max_photos': l10nEntry(
    english: 'Maximum {max} photos allowed for this category',
    arabic: 'الحد الأقصى {max} صورة لهذه الفئة',
  ),
  'validation_success': l10nEntry(
    english: 'All required fields are valid',
    arabic: 'جميع الحقول المطلوبة صحيحة',
  ),
  'error_email': l10nEntry(english: 'Enter a valid email'),
  'error_url': l10nEntry(
    english: 'Enter a valid URL starting with https://',
    arabic: 'أدخل رابطًا صالحًا يبدأ بـ https://',
  ),
  'error_phone': l10nEntry(english: 'Enter a valid phone number'),
};

final Map<String, Map<String, String>> _fieldKeys = {
  'field_condition': l10nEntry(
    english: 'Condition',
    arabic: 'الحالة',
    hindi: 'स्थिति',
  ),
  'field_condition_placeholder': l10nEntry(
    english: 'Select condition',
    arabic: 'اختر الحالة',
  ),
  'field_select_placeholder': l10nEntry(
    english: 'Select an option',
    arabic: 'اختر خياراً',
  ),
  'field_price': l10nEntry(
    english: 'Price (QAR)',
    arabic: 'السعر (ريال)',
  ),
  'field_price_placeholder': l10nEntry(english: 'Enter price in QAR'),
  'field_price_monthly': l10nEntry(english: 'Monthly rent (QAR)'),
  'field_location': l10nEntry(
    english: 'Location',
    arabic: 'الموقع',
  ),
  'field_location_placeholder': l10nEntry(
    english: 'Select area',
    arabic: 'اختر المنطقة',
  ),
  'field_photos': l10nEntry(
    english: 'Photos',
    arabic: 'الصور',
  ),
  'field_photos_placeholder': l10nEntry(
    english: 'Add at least one photo',
    arabic: 'أضف صورة واحدة على الأقل',
  ),
  'field_description': l10nEntry(
    english: 'Description',
    arabic: 'الوصف',
  ),
  'field_description_placeholder': l10nEntry(
    english: 'Describe your item',
    arabic: 'صف المنتج',
  ),
  'field_brand': l10nEntry(english: 'Brand', arabic: 'العلامة التجارية'),
  'field_model': l10nEntry(english: 'Model', arabic: 'الموديل'),
  'field_storage': l10nEntry(english: 'Storage'),
  'field_ram': l10nEntry(english: 'RAM'),
  'field_age': l10nEntry(english: 'Age / Usage'),
  'field_warranty': l10nEntry(english: 'Warranty'),
  'field_accessories': l10nEntry(english: 'Accessories included'),
  'field_make': l10nEntry(english: 'Make'),
  'field_year': l10nEntry(english: 'Year'),
  'field_variant': l10nEntry(english: 'Variant'),
  'field_mileage': l10nEntry(english: 'Mileage (km)'),
  'field_transmission': l10nEntry(english: 'Transmission'),
  'field_fuel': l10nEntry(english: 'Fuel type'),
  'field_engine': l10nEntry(english: 'Engine'),
  'field_body_type': l10nEntry(english: 'Body type'),
  'field_ownership': l10nEntry(english: 'Ownership'),
  'field_registration': l10nEntry(english: 'Registration details'),
  'field_service_history': l10nEntry(english: 'Service history'),
  'field_processor': l10nEntry(english: 'Processor'),
  'field_screen_size': l10nEntry(english: 'Screen size'),
  'field_device_type': l10nEntry(english: 'Device type'),
  'field_camera_type': l10nEntry(english: 'Camera type'),
  'field_lens_included': l10nEntry(english: 'Lens included'),
  'field_lens_spec': l10nEntry(english: 'Lens specification'),
  'field_ac_type': l10nEntry(english: 'AC type'),
  'field_capacity': l10nEntry(english: 'Capacity'),
  'field_inverter': l10nEntry(english: 'Inverter'),
  'field_installation': l10nEntry(english: 'Installation'),
  'field_fridge_type': l10nEntry(english: 'Refrigerator type'),
  'field_capacity_liters': l10nEntry(english: 'Capacity (liters)'),
  'field_doors': l10nEntry(english: 'Number of doors'),
  'field_appliance_type': l10nEntry(english: 'Appliance type'),
  'field_capacity_wattage': l10nEntry(english: 'Capacity / Wattage'),
  'field_fashion_category': l10nEntry(english: 'Category'),
  'field_fashion_type': l10nEntry(english: 'Type'),
  'field_size': l10nEntry(english: 'Size'),
  'field_job_title': l10nEntry(english: 'Job title'),
  'field_company': l10nEntry(english: 'Company'),
  'field_salary': l10nEntry(english: 'Salary'),
  'field_contact': l10nEntry(english: 'Contact number'),
  'field_email': l10nEntry(english: 'Email'),
  'field_business_name': l10nEntry(english: 'Business name'),
  'field_phone': l10nEntry(english: 'Phone'),
  'field_whatsapp': l10nEntry(english: 'WhatsApp'),
  'field_languages': l10nEntry(english: 'Languages spoken'),
  'field_service_title': l10nEntry(english: 'Listing title'),
  'field_provider_name': l10nEntry(english: 'Provider name'),
  'field_housing_title': l10nEntry(english: 'Listing title'),
  'field_gender_preference': l10nEntry(english: 'Gender preference'),
  'field_tv_screen_size': l10nEntry(
    english: 'Screen size (inches)',
    arabic: 'حجم الشاشة (بوصة)',
  ),
  'field_display_type': l10nEntry(
    english: 'Display type',
    arabic: 'نوع الشاشة',
  ),
  'field_resolution': l10nEntry(
    english: 'Resolution',
    arabic: 'الدقة',
  ),
  'field_smart_tv': l10nEntry(
    english: 'Smart TV',
    arabic: 'تلفزيون ذكي',
  ),
  'field_tv_accessories': l10nEntry(english: 'Accessories included'),
  'field_gaming_accessories': l10nEntry(english: 'Accessories included'),
  'field_audio_product_type': l10nEntry(english: 'Product type'),
  'field_audio_connection': l10nEntry(english: 'Connection type'),
  'field_accessory_type': l10nEntry(
    english: 'Accessory type',
    arabic: 'نوع الملحق',
  ),
  'field_compatibility': l10nEntry(english: 'Compatibility'),
  'field_compatibility_placeholder': l10nEntry(
    english: 'e.g. USB-C, Mac, Windows laptops',
  ),
};

final Map<String, Map<String, String>> _optionKeys = {
  'condition_new': l10nEntry(english: 'New', arabic: 'جديد'),
  'condition_used': l10nEntry(english: 'Used', arabic: 'مستخدم'),
  'condition_refurbished': l10nEntry(english: 'Refurbished', arabic: 'مجدّد'),
  'transmission_automatic': l10nEntry(english: 'Automatic'),
  'transmission_manual': l10nEntry(english: 'Manual'),
  'fuel_petrol': l10nEntry(english: 'Petrol'),
  'fuel_diesel': l10nEntry(english: 'Diesel'),
  'fuel_hybrid': l10nEntry(english: 'Hybrid'),
  'fuel_electric': l10nEntry(english: 'Electric'),
  'body_sedan': l10nEntry(english: 'Sedan'),
  'body_suv': l10nEntry(english: 'SUV'),
  'body_hatchback': l10nEntry(english: 'Hatchback'),
  'body_coupe': l10nEntry(english: 'Coupe'),
  'body_pickup': l10nEntry(english: 'Pickup'),
  'body_van': l10nEntry(english: 'Van'),
  'ownership_first': l10nEntry(english: 'First owner'),
  'ownership_second': l10nEntry(english: 'Second owner'),
  'ownership_third_plus': l10nEntry(english: 'Third owner or more'),
  'service_full': l10nEntry(english: 'Full service history'),
  'service_partial': l10nEntry(english: 'Partial service history'),
  'service_none': l10nEntry(english: 'No service history'),
  'warranty_yes': l10nEntry(english: 'Yes'),
  'warranty_no': l10nEntry(english: 'No'),
  'storage_64': l10nEntry(english: '64 GB'),
  'storage_128': l10nEntry(english: '128 GB'),
  'storage_256': l10nEntry(english: '256 GB'),
  'storage_512': l10nEntry(english: '512 GB'),
  'storage_1tb': l10nEntry(english: '1 TB'),
  'storage_2tb': l10nEntry(english: '2 TB'),
  'ram_4': l10nEntry(english: '4 GB'),
  'ram_6': l10nEntry(english: '6 GB'),
  'ram_8': l10nEntry(english: '8 GB'),
  'ram_12': l10nEntry(english: '12 GB'),
  'ram_16': l10nEntry(english: '16 GB'),
  'ram_32': l10nEntry(english: '32 GB'),
  'ram_64': l10nEntry(english: '64 GB'),
  'age_brand_new': l10nEntry(english: 'Brand new'),
  'age_under_6m': l10nEntry(english: 'Under 6 months'),
  'age_6_12m': l10nEntry(english: '6–12 months'),
  'age_1_2y': l10nEntry(english: '1–2 years'),
  'age_2y_plus': l10nEntry(english: '2+ years'),
  'device_laptop': l10nEntry(english: 'Laptop'),
  'device_desktop': l10nEntry(english: 'Desktop'),
  'screen_13': l10nEntry(english: '13"'),
  'screen_14': l10nEntry(english: '14"'),
  'screen_15': l10nEntry(english: '15"'),
  'screen_16': l10nEntry(english: '16"'),
  'screen_17_plus': l10nEntry(english: '17"+'),
  'camera_dslr': l10nEntry(english: 'DSLR'),
  'camera_mirrorless': l10nEntry(english: 'Mirrorless'),
  'camera_point_shoot': l10nEntry(english: 'Point & Shoot'),
  'camera_action': l10nEntry(english: 'Action cam'),
  'lens_yes': l10nEntry(english: 'Yes'),
  'lens_no': l10nEntry(english: 'No'),
  'ac_split': l10nEntry(english: 'Split AC'),
  'ac_window': l10nEntry(english: 'Window AC'),
  'ac_central': l10nEntry(english: 'Central AC'),
  'ac_portable': l10nEntry(english: 'Portable AC'),
  'cap_1_ton': l10nEntry(english: '1 Ton'),
  'cap_1_5_ton': l10nEntry(english: '1.5 Ton'),
  'cap_2_ton': l10nEntry(english: '2 Ton'),
  'cap_2_5_ton_plus': l10nEntry(english: '2.5 Ton+'),
  'inverter_yes': l10nEntry(english: 'Inverter'),
  'inverter_no': l10nEntry(english: 'Non-inverter'),
  'install_included': l10nEntry(english: 'Installation included'),
  'install_not_included': l10nEntry(english: 'Installation not included'),
  'fridge_single': l10nEntry(english: 'Single door'),
  'fridge_double': l10nEntry(english: 'Double door'),
  'fridge_side_by_side': l10nEntry(english: 'Side by side'),
  'fridge_mini': l10nEntry(english: 'Mini fridge'),
  'doors_1': l10nEntry(english: '1 door'),
  'doors_2': l10nEntry(english: '2 doors'),
  'doors_3': l10nEntry(english: '3 doors'),
  'doors_4_plus': l10nEntry(english: '4+ doors'),
  'appliance_microwave': l10nEntry(english: 'Microwave'),
  'appliance_oven': l10nEntry(english: 'Oven'),
  'appliance_mixer': l10nEntry(english: 'Mixer'),
  'appliance_grinder': l10nEntry(english: 'Grinder'),
  'fashion_mens': l10nEntry(english: "Men's"),
  'fashion_womens': l10nEntry(english: "Women's"),
  'fashion_kids': l10nEntry(english: "Kids'"),
  'gender_male': l10nEntry(english: 'Male only'),
  'gender_female': l10nEntry(english: 'Female only'),
  'gender_family': l10nEntry(english: 'Family'),
  'gender_any': l10nEntry(english: 'Any'),
  'tv_screen_32': l10nEntry(english: '32"'),
  'tv_screen_43': l10nEntry(english: '43"'),
  'tv_screen_50': l10nEntry(english: '50"'),
  'tv_screen_55': l10nEntry(english: '55"'),
  'tv_screen_65': l10nEntry(english: '65"'),
  'tv_screen_75': l10nEntry(english: '75"'),
  'tv_screen_85_plus': l10nEntry(english: '85"+'),
  'display_led': l10nEntry(english: 'LED'),
  'display_oled': l10nEntry(english: 'OLED'),
  'display_qled': l10nEntry(english: 'QLED'),
  'display_plasma': l10nEntry(english: 'Plasma'),
  'display_other': l10nEntry(english: 'Other'),
  'res_hd': l10nEntry(english: 'HD'),
  'res_fhd': l10nEntry(english: 'Full HD'),
  'res_4k': l10nEntry(english: '4K'),
  'res_8k': l10nEntry(english: '8K'),
  'audio_speakers': l10nEntry(english: 'Speakers'),
  'audio_headphones': l10nEntry(english: 'Headphones'),
  'audio_earbuds': l10nEntry(english: 'Earbuds'),
  'audio_other': l10nEntry(english: 'Other'),
  'audio_wired': l10nEntry(english: 'Wired'),
  'audio_wireless': l10nEntry(english: 'Wireless'),
  'audio_bluetooth': l10nEntry(english: 'Bluetooth'),
  'accessory_keyboard': l10nEntry(english: 'Keyboard'),
  'accessory_mouse': l10nEntry(english: 'Mouse'),
  'accessory_monitor': l10nEntry(english: 'Monitor'),
  'accessory_docking': l10nEntry(english: 'Dock / hub'),
  'accessory_storage': l10nEntry(english: 'External storage'),
  'accessory_cable': l10nEntry(english: 'Cable / adapter'),
  'accessory_other': l10nEntry(english: 'Other'),
};

final Map<String, Map<String, String>> _categoryKeys = {
  'cat_vehicles': l10nEntry(english: 'Vehicles'),
  'cat_cars': l10nEntry(english: 'Cars'),
  'cat_electronics': l10nEntry(english: 'Electronics'),
  'cat_mobiles': l10nEntry(
    english: 'Mobile Phones',
    arabic: 'هواتف محمولة',
  ),
  'cat_tablets': l10nEntry(english: 'Tablets'),
  'cat_laptops': l10nEntry(english: 'Laptops', arabic: 'أجهزة لابتوب'),
  'cat_desktops': l10nEntry(english: 'Desktops / Computers', arabic: 'أجهزة مكتبية'),
  'cat_computer_accessories': l10nEntry(english: 'Computer accessories'),
  'cat_tvs': l10nEntry(english: 'TVs', arabic: 'تلفزيونات'),
  'cat_cameras': l10nEntry(english: 'Cameras'),
  'cat_audio': l10nEntry(english: 'Audio'),
  'cat_gaming': l10nEntry(english: 'Gaming consoles'),
  'cat_miscellaneous': l10nEntry(english: 'Other / Miscellaneous'),
  'cat_other': l10nEntry(english: 'Other'),
  'cat_home_appliances': l10nEntry(english: 'Home Appliances'),
  'cat_air_conditioners': l10nEntry(english: 'Air Conditioners'),
  'cat_furniture': l10nEntry(english: 'Furniture'),
  'cat_fashion': l10nEntry(english: 'Fashion'),
  'cat_baby_kids': l10nEntry(english: 'Baby & Kids'),
  'cat_sports_fitness': l10nEntry(english: 'Sports & Fitness'),
  'cat_books_hobbies': l10nEntry(english: 'Books, Hobbies & Collectibles'),
  'cat_home_garden': l10nEntry(english: 'Home & Garden'),
  'cat_jobs': l10nEntry(english: 'Jobs'),
  'cat_businesses': l10nEntry(english: 'Businesses'),
  'cat_housing': l10nEntry(english: 'Housing'),
  'cat_svc_home_cleaning': l10nEntry(english: 'Home Cleaning'),
};
