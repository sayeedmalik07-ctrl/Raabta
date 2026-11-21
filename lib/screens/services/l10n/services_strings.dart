import 'package:flutter/foundation.dart';
import 'package:raabta/core/l10n/app_locale.dart';
import 'package:raabta/core/l10n/locale_catalog_coverage.dart';

/// Services feature UI strings — 8 locales, RTL via [AppLocale.isRtl].
abstract final class ServicesStrings {
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
    required Map<String, String> params,
  }) {
    var value = t(key, locale);
    params.forEach((placeholder, replacement) {
      value = value.replaceAll('{$placeholder}', replacement);
    });
    return value;
  }

  static String statusLabel(String status, String locale) {
    switch (status.toLowerCase()) {
      case 'contacted':
        return t('status_contacted', locale);
      case 'completed':
        return t('status_completed', locale);
      default:
        return t('status_new', locale);
    }
  }

  /// Exposed for catalog parity regression tests only.
  @visibleForTesting
  static Map<String, Set<String>> get localeCoverageReport =>
      buildLocaleCoverageReport(
        catalog: _catalog,
        supportedLocales: supportedLocales,
      );

  static const _catalog = <String, Map<String, String>>{
    'title': {
      'English': 'Services',
      'Arabic': 'الخدمات',
      'Hindi': 'सेवाएँ',
      'Urdu': 'خدمات',
      'Malayalam': 'Services',
      'Nepali': 'Services',
      'Bengali': 'সেবা',
      'Filipino': 'Services',
    },
    'subtitle': {
      'English': 'Post your service or browse listings from providers in Qatar',
      'Arabic': 'انشر خدمتك أو تصفح إعلانات مقدمي الخدمات في قطر',
      'Hindi': 'अपनी सेवा पोस्ट करें या कतर में प्रदाताओं की लिस्टिंग देखें',
      'Urdu': 'اپنی خدمت پوسٹ کریں یا قطر میں فراہم کنندگان کی فہرست دیکھیں',
      'Malayalam':
          'Post your service or browse listings from providers in Qatar',
      'Nepali': 'Post your service or browse listings from providers in Qatar',
      'Bengali':
          'আপনার সেবা পোস্ট করুন বা কাতারে প্রদানকারীদের তালিকা দেখুন',
      'Filipino':
          'Post your service or browse listings from providers in Qatar',
    },
    'search_hint': {
      'English': 'Search services across all categories…',
      'Arabic': 'ابحث عن الخدمات في جميع الفئات…',
      'Hindi': 'सभी श्रेणियों में सेवाएँ खोजें…',
      'Urdu': 'تمام زمرے میں خدمات تلاش کریں…',
      'Malayalam': 'Search services across all categories…',
      'Nepali': 'Search services across all categories…',
      'Bengali': 'সব বিভাগে সেবা খুঁজুন…',
      'Filipino': 'Search services across all categories…',
    },
    'hub_search_hint_main': {
      'English': 'What do you need help with?',
      'Arabic': 'بماذا تحتاج مساعدة؟',
      'Hindi': 'आपको किस चीज़ में मदद चाहिए?',
      'Urdu': 'آپ کو کس چیز میں مدد درکار ہے؟',
      'Malayalam': 'What do you need help with?',
      'Nepali': 'What do you need help with?',
      'Bengali': 'আপনার কী সাহায্য দরকার?',
      'Filipino': 'What do you need help with?',
    },
    'hub_front_groups_section': {
      'English': 'Browse by category',
      'Arabic': 'تصفح حسب الفئة',
      'Hindi': 'श्रेणी के अनुसार देखें',
      'Urdu': 'زمرے کے لحاظ سے دیکھیں',
      'Malayalam': 'Browse by category',
      'Nepali': 'Browse by category',
      'Bengali': 'বিভাগ অনুসারে ব্রাউজ করুন',
      'Filipino': 'Browse by category',
    },
    'hub_describe_title': {
      'English': 'Describe what you need',
      'Arabic': 'صف ما تحتاجه',
      'Hindi': 'बताएँ आपको क्या चाहिए',
      'Urdu': 'بتائیں آپ کو کیا درکار ہے',
      'Malayalam': 'Describe what you need',
      'Nepali': 'Describe what you need',
      'Bengali': 'আপনার প্রয়োজন বর্ণনা করুন',
      'Filipino': 'Describe what you need',
    },
    'hub_describe_subtitle': {
      'English':
          'Post a request — we help match providers. AI suggestions are optional.',
      'Arabic':
          'انشر طلباً — نساعدك في المطابقة. اقتراحات الذكاء الاصطناعي اختيارية.',
      'Hindi':
          'अनुरोध पोस्ट करें — हम प्रदाता से मिलान में मदद करते हैं। AI वैकल्पिक है।',
      'Urdu':
          'درخواست پوسٹ کریں — ہم فراہم کنندگان سے ملا کرتے ہیں۔ AI اختیاری ہے۔',
      'Malayalam':
          'Post a request — we help match providers. AI suggestions are optional.',
      'Nepali':
          'Post a request — we help match providers. AI suggestions are optional.',
      'Bengali':
          'একটি অনুরোধ পোস্ট করুন — আমরা প্রদানকারী খুঁজতে সাহায্য করি। AI ঐচ্ছিক।',
      'Filipino':
          'Post a request — we help match providers. AI suggestions are optional.',
    },
    'hub_all_services_title': {
      'English': 'All services',
      'Arabic': 'جميع الخدمات',
      'Hindi': 'सभी सेवाएँ',
      'Urdu': 'تمام خدمات',
      'Malayalam': 'All services',
      'Nepali': 'All services',
      'Bengali': 'সব সেবা',
      'Filipino': 'All services',
    },
    'hub_all_services_subtitle': {
      'English': 'Search 24 groups and all specialties',
      'Arabic': 'ابحث في 24 مجموعة وجميع التخصصات',
      'Hindi': '24 समूहों और सभी विशेषताओं में खोजें',
      'Urdu': '24 گروپس اور تمام سپیشلٹیز تلاش کریں',
      'Malayalam': 'Search 24 groups and all specialties',
      'Nepali': 'Search 24 groups and all specialties',
      'Bengali': '২৪টি গ্রুপ ও সব বিশেষতায় খুঁজুন',
      'Filipino': 'Search 24 groups and all specialties',
    },
    'hub_all_services_screen_subtitle': {
      'English': '24 service groups · 184 specialties',
      'Arabic': '٢٤ مجموعة · ١٨٤ تخصصاً',
      'Hindi': '24 समूह · 184 विशेषताएँ',
      'Urdu': '24 گروپس · 184 سپیشلٹیز',
      'Malayalam': '24 service groups · 184 specialties',
      'Nepali': '24 service groups · 184 specialties',
      'Bengali': '২৪টি গ্রুপ · ১৮৪টি বিশেষতা',
      'Filipino': '24 service groups · 184 specialties',
    },
    'hub_all_services_search_label': {
      'English': 'Search groups',
      'Arabic': 'ابحث في المجموعات',
      'Hindi': 'समूह खोजें',
      'Urdu': 'گروپس تلاش کریں',
      'Malayalam': 'Search groups',
      'Nepali': 'Search groups',
      'Bengali': 'গ্রুপ অনুসন্ধান',
      'Filipino': 'Search groups',
    },
    'hub_all_services_search_hint': {
      'English': 'Type a service or synonym…',
      'Arabic': 'اكتب خدمة أو مرادفاً…',
      'Hindi': 'सेवा या समानार्थी लिखें…',
      'Urdu': 'خدمت یا ہم معنی لکھیں…',
      'Malayalam': 'Type a service or synonym…',
      'Nepali': 'Type a service or synonym…',
      'Bengali': 'সেবা বা প্রতিশব্দ লিখুন…',
      'Filipino': 'Type a service or synonym…',
    },
    'hub_all_services_groups_section': {
      'English': '12 groups',
      'Arabic': '١٢ مجموعة',
      'Hindi': '12 समूह',
      'Urdu': '12 گروپس',
      'Malayalam': '12 groups',
      'Nepali': '12 groups',
      'Bengali': '১২টি গ্রুপ',
      'Filipino': '12 groups',
    },
    'hub_all_services_category_count': {
      'English': '{count} categories',
      'Arabic': '{count} فئات',
      'Hindi': '{count} श्रेणियाँ',
      'Urdu': '{count} زمرے',
      'Malayalam': '{count} categories',
      'Nepali': '{count} categories',
      'Bengali': '{count}টি বিভাগ',
      'Filipino': '{count} categories',
    },
    'hub_all_services_no_groups': {
      'English': 'No groups match your search',
      'Arabic': 'لا مجموعات مطابقة لبحثك',
      'Hindi': 'आपकी खोज से कोई समूह मेल नहीं खाता',
      'Urdu': 'آپ کی تلاش سے کوئی گروپ نہیں ملا',
      'Malayalam': 'No groups match your search',
      'Nepali': 'No groups match your search',
      'Bengali': 'আপনার অনুসন্ধানের সাথে কোনো গ্রুপ মেলেনি',
      'Filipino': 'No groups match your search',
    },
    'hub_all_services_no_groups_body': {
      'English': 'Try another word — search matches group names, categories, and specialties.',
      'Arabic': 'جرّب كلمة أخرى — البحث يطابق أسماء المجموعات والفئات والتخصصات.',
      'Hindi': 'दूसरा शब्द आज़माएँ — खोज समूह नाम, श्रेणियाँ और विशेषताएँ से मिलाती है।',
      'Urdu': 'دوسرا لفظ آزمائیں — تلاش گروپ، زمرے اور سپیشلٹی سے میل کھاتی ہے۔',
      'Malayalam':
          'Try another word — search matches group names, categories, and specialties.',
      'Nepali':
          'Try another word — search matches group names, categories, and specialties.',
      'Bengali':
          'অন্য শব্দ চেষ্টা করুন — অনুসন্ধান গ্রুপের নাম, বিভাগ ও বিশেষতার সাথে মেলায়।',
      'Filipino':
          'Try another word — search matches group names, categories, and specialties.',
    },
    'hub_all_services_long_tail_note': {
      'English':
          'Every specialty is searchable here — open a group for full lists.',
      'Arabic':
          'كل التخصصات قابلة للبحث هنا — افتح مجموعة للقوائم الكاملة.',
      'Hindi':
          'हर विशेषता यहाँ खोजी जा सकती है — पूरी सूची के लिए समूह खोलें।',
      'Urdu':
          'ہر سپیشلٹی یہاں تلاش کی جا سکتی ہے — مکمل فہرست کے لیے گروپ کھولیں۔',
      'Malayalam':
          'Every specialty is searchable here — open a group for full lists.',
      'Nepali':
          'Every specialty is searchable here — open a group for full lists.',
      'Bengali':
          'প্রতিটি বিশেষতা এখানে খোঁজা যায় — পূর্ণ তালিকার জন্য একটি গ্রুপ খুলুন।',
      'Filipino':
          'Every specialty is searchable here — open a group for full lists.',
    },
    'hub_verified_providers': {
      'English': 'Verified providers',
      'Arabic': 'مقدمو خدمات موثّقون',
      'Hindi': 'सत्यापित प्रदाता',
      'Urdu': 'تصدیق شدہ فراہم کنندگان',
      'Malayalam': 'Verified providers',
      'Nepali': 'Verified providers',
      'Bengali': 'যাচাইকৃত প্রদানকারী',
      'Filipino': 'Verified providers',
    },
    'hub_empty_search_title': {
      'English': 'No listings match your search',
      'Arabic': 'لا إعلانات مطابقة لبحثك',
      'Hindi': 'आपकी खोज से कोई लिस्टिंग मेल नहीं खाती',
      'Urdu': 'آپ کی تلاش سے کوئی فہرست نہیں ملی',
      'Malayalam': 'No listings match your search',
      'Nepali': 'No listings match your search',
      'Bengali': 'আপনার অনুসন্ধানের সাথে কোনো তালিকা মেলেনি',
      'Filipino': 'No listings match your search',
    },
    'hub_empty_search_description': {
      'English':
          'Try a different word — or browse categories below and post a request.',
      'Arabic':
          'جرّب كلمة أخرى — أو تصفح الفئات أدناه وانشر طلباً.',
      'Hindi':
          'दूसरा शब्द आज़माएँ — या नीचे श्रेणियाँ देखें और अनुरोध पोस्ट करें।',
      'Urdu':
          'ایک اور لفظ آزمائیں — یا نیچے زمرے دیکھیں اور درخواست پوسٹ کریں۔',
      'Malayalam':
          'Try a different word — or browse categories below and post a request.',
      'Nepali':
          'Try a different word — or browse categories below and post a request.',
      'Bengali':
          'অন্য শব্দ চেষ্টা করুন — অথবা নীচে বিভাগ ব্রাউজ করে অনুরোধ পোস্ট করুন।',
      'Filipino':
          'Try a different word — or browse categories below and post a request.',
    },
    'hub_clear_search': {
      'English': 'Clear search',
      'Arabic': 'مسح البحث',
      'Hindi': 'खोज साफ़ करें',
      'Urdu': 'تلاش صاف کریں',
      'Malayalam': 'Clear search',
      'Nepali': 'Clear search',
      'Bengali': 'অনুসন্ধান মুছুন',
      'Filipino': 'Clear search',
    },
    'hub_category_more_chips': {
      'English': 'More',
      'Arabic': 'المزيد',
      'Hindi': 'और',
      'Urdu': 'مزید',
      'Malayalam': 'More',
      'Nepali': 'More',
      'Bengali': 'আরও',
      'Filipino': 'More',
    },
    'hub_category_more_sheet_title': {
      'English': 'All specialties',
      'Arabic': 'جميع التخصصات',
      'Hindi': 'सभी विशेषताएँ',
      'Urdu': 'تمام سپیشلٹیز',
      'Malayalam': 'All specialties',
      'Nepali': 'All specialties',
      'Bengali': 'সব বিশেষতা',
      'Filipino': 'All specialties',
    },
    'hub_category_no_providers_inline': {
      'English':
          'No providers yet for {leaf}. Post a request so providers can respond.',
      'Arabic':
          'لا مقدمي خدمات بعد لـ {leaf}. انشر طلباً ليتمكن المقدمون من الرد.',
      'Hindi':
          'अभी {leaf} के लिए कोई प्रदाता नहीं। प्रदाता जुड़ सकें इसलिए अनुरोध पोस्ट करें।',
      'Urdu':
          'ابھی {leaf} کے لیے کوئی فراہم کنندہ نہیں۔ درخواست پوسٹ کریں تاکہ جواب آ سکے۔',
      'Malayalam':
          'No providers yet for {leaf}. Post a request so providers can respond.',
      'Nepali':
          'No providers yet for {leaf}. Post a request so providers can respond.',
      'Bengali':
          'এখনও {leaf}-এর জন্য কোনো প্রদানকারী নেই। অনুরোধ পোস্ট করুন যাতে তারা জবাব দিতে পারে।',
      'Filipino':
          'No providers yet for {leaf}. Post a request so providers can respond.',
    },
    'hub_category_no_providers_all': {
      'English':
          'No providers in this category yet. Post a request so providers can respond.',
      'Arabic':
          'لا مقدمي خدمات في هذه الفئة بعد. انشر طلباً ليتمكن المقدمون من الرد.',
      'Hindi':
          'इस श्रेणी में अभी कोई प्रदाता नहीं। अनुरोध पोस्ट करें।',
      'Urdu':
          'اس زمرے میں ابھی کوئی فراہم کنندہ نہیں۔ درخواست پوسٹ کریں۔',
      'Malayalam':
          'No providers in this category yet. Post a request so providers can respond.',
      'Nepali':
          'No providers in this category yet. Post a request so providers can respond.',
      'Bengali':
          'এই বিভাগে এখনও কোনো প্রদানকারী নেই। অনুরোধ পোস্ট করুন।',
      'Filipino':
          'No providers in this category yet. Post a request so providers can respond.',
    },
    'hub_category_no_requests_inline': {
      'English':
          'No open requests for {leaf} yet. Offer your service or check back soon.',
      'Arabic':
          'لا طلبات مفتوحة لـ {leaf} بعد. قدّم خدمتك أو تعا لاحقاً.',
      'Hindi':
          'अभी {leaf} के लिए कोई खुला अनुरोध नहीं। अपनी सेवा दें या बाद में देखें।',
      'Urdu':
          'ابھی {leaf} کے لیے کوئی کھلی درخواست نہیں۔ اپنی خدمت پیش کریں۔',
      'Malayalam':
          'No open requests for {leaf} yet. Offer your service or check back soon.',
      'Nepali':
          'No open requests for {leaf} yet. Offer your service or check back soon.',
      'Bengali':
          'এখনও {leaf} এর জন্য কোনো খোলা অনুরোধ নেই। আপনার সেবা অফার করুন।',
      'Filipino':
          'No open requests for {leaf} yet. Offer your service or check back soon.',
    },
    'hub_category_no_requests_all': {
      'English':
          'No open requests in this category yet. Offer your service or check back soon.',
      'Arabic':
          'لا طلبات مفتوحة في هذه الفئة بعد. قدّم خدمتك أو تعا لاحقاً.',
      'Hindi':
          'इस श्रेणी में अभी कोई खुला अनुरोध नहीं। अपनी सेवा दें या बाद में देखें।',
      'Urdu':
          'اس زمرے میں ابھی کوئی کھلی درخواست نہیں۔ اپنی خدمت پیش کریں۔',
      'Malayalam':
          'No open requests in this category yet. Offer your service or check back soon.',
      'Nepali':
          'No open requests in this category yet. Offer your service or check back soon.',
      'Bengali':
          'এই বিভাগে এখনও কোনো খোলা অনুরোধ নেই। আপনার সেবা অফার করুন।',
      'Filipino':
          'No open requests in this category yet. Offer your service or check back soon.',
    },
    'my_requests': {
      'English': 'My Requests',
      'Arabic': 'طلباتي',
      'Hindi': 'मेरे अनुरोध',
      'Urdu': 'میری درخواستیں',
      'Malayalam': 'My Requests',
      'Nepali': 'My Requests',
      'Bengali': 'আমার অনুরোধ',
      'Filipino': 'My Requests',
    },
    'no_results': {
      'English': 'No services match your search',
      'Arabic': 'لا توجد خدمات مطابقة لبحثك',
      'Hindi': 'आपकी खोज से कोई सेवा मेल नहीं खाती',
      'Urdu': 'آپ کی تلاش سے کوئی خدمت نہیں ملی',
      'Malayalam': 'No services match your search',
      'Nepali': 'No services match your search',
      'Bengali': 'আপনার অনুসন্ধানের সাথে কোনো সেবা মেলেনি',
      'Filipino': 'No services match your search',
    },
    'services_count': {
      'English': '{count} services',
      'Arabic': '{count} خدمات',
      'Hindi': '{count} सेवाएँ',
      'Urdu': '{count} خدمات',
      'Malayalam': '{count} services',
      'Nepali': '{count} services',
      'Bengali': '{count}টি সেবা',
      'Filipino': '{count} services',
    },
    'request_service': {
      'English': 'Request Service',
      'Arabic': 'طلب خدمة',
      'Hindi': 'सेवा का अनुरोध',
      'Urdu': 'خدمت کی درخواست',
      'Malayalam': 'Request Service',
      'Nepali': 'Request Service',
      'Bengali': 'সেবার অনুরোধ',
      'Filipino': 'Request Service',
    },
    'field_name': {
      'English': 'Your name',
      'Arabic': 'اسمك',
      'Hindi': 'आपका नाम',
      'Urdu': 'آپ کا نام',
      'Malayalam': 'Your name',
      'Nepali': 'Your name',
      'Bengali': 'আপনার নাম',
      'Filipino': 'Your name',
    },
    'field_phone': {
      'English': 'Phone / WhatsApp',
      'Arabic': 'الهاتف / واتساب',
      'Hindi': 'फ़ोन / WhatsApp',
      'Urdu': 'فون / واٹس ایپ',
      'Malayalam': 'Phone / WhatsApp',
      'Nepali': 'Phone / WhatsApp',
      'Bengali': 'ফোন / WhatsApp',
      'Filipino': 'Phone / WhatsApp',
    },
    'field_area': {
      'English': 'Preferred area / location',
      'Arabic': 'المنطقة / الموقع المفضل',
      'Hindi': 'पसंदीदा क्षेत्र / स्थान',
      'Urdu': 'پسندیدہ علاقہ / مقام',
      'Malayalam': 'Preferred area / location',
      'Nepali': 'Preferred area / location',
      'Bengali': 'পছন্দের এলাকা / অবস্থান',
      'Filipino': 'Preferred area / location',
    },
    'field_preferred_time': {
      'English': 'Preferred date / time (optional)',
      'Arabic': 'التاريخ / الوقت المفضل (اختياري)',
      'Hindi': 'पसंदीदा तारीख / समय (वैकल्पिक)',
      'Urdu': 'پسندیدہ تاریخ / وقت (اختیاری)',
      'Malayalam': 'Preferred date / time (optional)',
      'Nepali': 'Preferred date / time (optional)',
      'Bengali': 'পছন্দের তারিখ / সময় (ঐচ্ছিক)',
      'Filipino': 'Preferred date / time (optional)',
    },
    'field_notes': {
      'English': 'Additional notes',
      'Arabic': 'ملاحظات إضافية',
      'Hindi': 'अतिरिक्त नोट्स',
      'Urdu': 'اضافی نوٹس',
      'Malayalam': 'Additional notes',
      'Nepali': 'Additional notes',
      'Bengali': 'অতিরিক্ত নোট',
      'Filipino': 'Additional notes',
    },
    'field_service': {
      'English': 'Selected service',
      'Arabic': 'الخدمة المختارة',
      'Hindi': 'चयनित सेवा',
      'Urdu': 'منتخب خدمت',
      'Malayalam': 'Selected service',
      'Nepali': 'Selected service',
      'Bengali': 'নির্বাচিত সেবা',
      'Filipino': 'Selected service',
    },
    'submit': {
      'English': 'Submit Request',
      'Arabic': 'إرسال الطلب',
      'Hindi': 'अनुरोध भेजें',
      'Urdu': 'درخواست بھیجیں',
      'Malayalam': 'Submit Request',
      'Nepali': 'Submit Request',
      'Bengali': 'অনুরোধ জমা দিন',
      'Filipino': 'Submit Request',
    },
    'success_title': {
      'English': 'Request sent',
      'Arabic': 'تم إرسال الطلب',
      'Hindi': 'अनुरोध भेज दिया गया',
      'Urdu': 'درخواست بھیج دی گئی',
      'Malayalam': 'Request sent',
      'Nepali': 'Request sent',
      'Bengali': 'অনুরোধ পাঠানো হয়েছে',
      'Filipino': 'Request sent',
    },
    'success_body': {
      'English':
          "Request sent — we'll match you with a verified provider shortly.",
      'Arabic': 'تم إرسال الطلب — سنوصلّك بمزوّد موثوق قريباً.',
      'Hindi':
          'अनुरोध भेज दिया गया — हम जल्द ही आपको एक सत्यापित प्रदाता से जोड़ेंगे।',
      'Urdu':
          'درخواست بھیج دی گئی — ہم جلد آپ کو تصدیق شدہ فراہم کنندہ سے ملائیں گے۔',
      'Malayalam':
          "Request sent — we'll match you with a verified provider shortly.",
      'Nepali':
          "Request sent — we'll match you with a verified provider shortly.",
      'Bengali':
          'অনুরোধ পাঠানো হয়েছে — আমরা শীঘ্রই আপনাকে যাচাইকৃত প্রদানকারীর সাথে মিলিয়ে দেব।',
      'Filipino':
          "Request sent — we'll match you with a verified provider shortly.",
    },
    'sign_in_required': {
      'English': 'Sign in to submit a service request',
      'Arabic': 'سجّل الدخول لإرسال طلب خدمة',
      'Hindi': 'सेवा अनुरोध भेजने के लिए साइन इन करें',
      'Urdu': 'خدمت کی درخواست بھیجنے کے لیے سائن ان کریں',
      'Malayalam': 'Sign in to submit a service request',
      'Nepali': 'Sign in to submit a service request',
      'Bengali': 'সেবার অনুরোধ জমা দিতে সাইন ইন করুন',
      'Filipino': 'Sign in to submit a service request',
    },
    'my_requests_empty_title': {
      'English': 'No requests yet',
      'Arabic': 'لا توجد طلبات بعد',
      'Hindi': 'अभी तक कोई अनुरोध नहीं',
      'Urdu': 'ابھی تک کوئی درخواست نہیں',
      'Malayalam': 'No requests yet',
      'Nepali': 'No requests yet',
      'Bengali': 'এখনও কোনো অনুরোধ নেই',
      'Filipino': 'No requests yet',
    },
    'my_requests_empty_body': {
      'English': 'Browse services and submit your first request.',
      'Arabic': 'تصفح الخدمات وأرسل طلبك الأول.',
      'Hindi': 'सेवाएँ देखें और अपना पहला अनुरोध भेजें।',
      'Urdu': 'خدمات دیکھیں اور اپنی پہلی درخواست بھیجیں۔',
      'Malayalam': 'Browse services and submit your first request.',
      'Nepali': 'Browse services and submit your first request.',
      'Bengali': 'সেবা দেখুন এবং আপনার প্রথম অনুরোধ জমা দিন।',
      'Filipino': 'Browse services and submit your first request.',
    },
    'status_new': {
      'English': 'New',
      'Arabic': 'جديد',
      'Hindi': 'नया',
      'Urdu': 'نیا',
      'Malayalam': 'New',
      'Nepali': 'New',
      'Bengali': 'নতুন',
      'Filipino': 'New',
    },
    'status_contacted': {
      'English': 'Contacted',
      'Arabic': 'تم التواصل',
      'Hindi': 'संपर्क किया',
      'Urdu': 'رابطہ کیا',
      'Malayalam': 'Contacted',
      'Nepali': 'Contacted',
      'Bengali': 'যোগাযোগ করা হয়েছে',
      'Filipino': 'Contacted',
    },
    'status_completed': {
      'English': 'Completed',
      'Arabic': 'مكتمل',
      'Hindi': 'पूर्ण',
      'Urdu': 'مکمل',
      'Bengali': 'সম্পন্ন',
      'Malayalam': 'Completed',
      'Nepali': 'Completed',
      'Filipino': 'Completed',
    },
    'whatsapp_note': {
      'English': 'We also open WhatsApp so our team can follow up quickly.',
      'Arabic': 'سنفتح واتساب أيضاً لمتابعة فريقنا بسرعة.',
      'Hindi': 'हम WhatsApp भी खोलेंगे ताकि हमारी टीम जल्दी फॉलो-अप कर सके।',
      'Urdu': 'ہم WhatsApp بھی کھولیں گے تاکہ ہماری ٹیم فوری فالو اپ کر سکے۔',
      'Malayalam':
          'We also open WhatsApp so our team can follow up quickly.',
      'Nepali': 'We also open WhatsApp so our team can follow up quickly.',
      'Bengali':
          'আমরা WhatsApp-ও খুলব যাতে আমাদের দল দ্রুত ফলো-আপ করতে পারে।',
      'Filipino':
          'We also open WhatsApp so our team can follow up quickly.',
    },
    'back_to_services': {
      'English': 'Back to Services',
      'Arabic': 'العودة إلى الخدمات',
      'Hindi': 'सेवाओं पर वापस',
      'Urdu': 'خدمات پر واپس',
      'Malayalam': 'Back to Services',
      'Nepali': 'Back to Services',
      'Bengali': 'সেবায় ফিরে যান',
      'Filipino': 'Back to Services',
    },
    'validation_name': {
      'English': 'Please enter your name',
      'Arabic': 'يرجى إدخال اسمك',
      'Hindi': 'कृपया अपना नाम दर्ज करें',
      'Urdu': 'براہ کرم اپنا نام درج کریں',
      'Malayalam': 'Please enter your name',
      'Nepali': 'Please enter your name',
      'Bengali': 'অনুগ্রহ করে আপনার নাম লিখুন',
      'Filipino': 'Please enter your name',
    },
    'validation_phone': {
      'English': 'Please enter a valid phone number',
      'Arabic': 'يرجى إدخال رقم هاتف صالح',
      'Hindi': 'कृपया एक मान्य फ़ोन नंबर दर्ज करें',
      'Urdu': 'براہ کرم درست فون نمبر درج کریں',
      'Malayalam': 'Please enter a valid phone number',
      'Nepali': 'Please enter a valid phone number',
      'Bengali': 'অনুগ্রহ করে একটি বৈধ ফোন নম্বর লিখুন',
      'Filipino': 'Please enter a valid phone number',
    },
    'validation_area': {
      'English': 'Please enter your preferred area',
      'Arabic': 'يرجى إدخال المنطقة المفضلة',
      'Hindi': 'कृपया अपना पसंदीदा क्षेत्र दर्ज करें',
      'Urdu': 'براہ کرم پسندیدہ علاقہ درج کریں',
      'Malayalam': 'Please enter your preferred area',
      'Nepali': 'Please enter your preferred area',
      'Bengali': 'অনুগ্রহ করে পছন্দের এলাকা লিখুন',
      'Filipino': 'Please enter your preferred area',
    },
    'submit_error': {
      'English': 'Something went wrong. Please try again.',
      'Arabic': 'حدث خطأ. حاول مرة أخرى.',
      'Hindi': 'कुछ गलत हो गया। कृपया पुनः प्रयास करें।',
      'Urdu': 'کچھ غلط ہوا۔ دوبارہ کوشش کریں۔',
      'Malayalam': 'Something went wrong. Please try again.',
      'Nepali': 'Something went wrong. Please try again.',
      'Bengali': 'কিছু ভুল হয়েছে। আবার চেষ্টা করুন।',
      'Filipino': 'Something went wrong. Please try again.',
    },
    'post_listing': {
      'English': 'Post Service',
      'Arabic': 'نشر خدمة',
      'Hindi': 'सेवा पोस्ट करें',
      'Urdu': 'خدمت پوسٹ کریں',
      'Malayalam': 'Post Service',
      'Nepali': 'Post Service',
      'Bengali': 'সেবা পোস্ট করুন',
      'Filipino': 'Post Service',
    },
    'publish_listing': {
      'English': 'Publish Listing',
      'Arabic': 'نشر الإعلان',
      'Hindi': 'लिस्टिंग प्रकाशित करें',
      'Urdu': 'فہرست شائع کریں',
      'Malayalam': 'Publish Listing',
      'Nepali': 'Publish Listing',
      'Bengali': 'তালিকা প্রকাশ করুন',
      'Filipino': 'Publish Listing',
    },
    'my_listings': {
      'English': 'My Listings',
      'Arabic': 'إعلاناتي',
      'Hindi': 'मेरी लिस्टिंग',
      'Urdu': 'میری فہرستیں',
      'Malayalam': 'My Listings',
      'Nepali': 'My Listings',
      'Bengali': 'আমার তালিকা',
      'Filipino': 'My Listings',
    },
    'post_success_title': {
      'English': 'Listing published',
      'Arabic': 'تم نشر الإعلان',
      'Hindi': 'लिस्टिंग प्रकाशित',
      'Urdu': 'فہرست شائع ہو گئی',
      'Malayalam': 'Listing published',
      'Nepali': 'Listing published',
      'Bengali': 'তালিকা প্রকাশিত',
      'Filipino': 'Listing published',
    },
    'post_success_body': {
      'English':
          'Your service is live on Raabta. People can browse your listing and contact you directly.',
      'Arabic':
          'خدمتك متاحة الآن على رابطة. يمكن للناس تصفح إعلانك والتواصل معك مباشرة.',
      'Hindi':
          'आपकी सेवा Raabta पर लाइव है। लोग आपकी लिस्टिंग देखकर सीधे संपर्क कर सकते हैं।',
      'Urdu':
          'آپ کی خدمت Raabta پر لائیو ہے۔ لوگ آپ کی فہرست دیکھ کر براہ راست رابطہ کر سکتے ہیں۔',
      'Malayalam':
          'Your service is live on Raabta. People can browse your listing and contact you directly.',
      'Nepali':
          'Your service is live on Raabta. People can browse your listing and contact you directly.',
      'Bengali':
          'আপনার সেবা Raabta-তে লাইভ। মানুষ আপনার তালিকা দেখে সরাসরি যোগাযোগ করতে পারবে।',
      'Filipino':
          'Your service is live on Raabta. People can browse your listing and contact you directly.',
    },
    'my_listings_empty_title': {
      'English': 'No listings yet',
      'Arabic': 'لا توجد إعلانات بعد',
      'Hindi': 'अभी कोई लिस्टिंग नहीं',
      'Urdu': 'ابھی کوئی فہرست نہیں',
      'Malayalam': 'No listings yet',
      'Nepali': 'No listings yet',
      'Bengali': 'এখনও কোনো তালিকা নেই',
      'Filipino': 'No listings yet',
    },
    'my_listings_empty_body': {
      'English': 'Post your first service to reach a wider audience on Raabta.',
      'Arabic': 'انشر خدمتك الأولى للوصول إلى جمهور أوسع على رابطة.',
      'Hindi': 'Raabta पर व्यापक दर्शकों तक पहुँचने के लिए अपनी पहली सेवा पोस्ट करें।',
      'Urdu': 'Raabta پر وسیع سامعین تک پہنچنے کے لیے اپنی پہلی خدمت پوسٹ کریں۔',
      'Malayalam':
          'Post your first service to reach a wider audience on Raabta.',
      'Nepali': 'Post your first service to reach a wider audience on Raabta.',
      'Bengali':
          'Raabta-তে বড় শ্রোতা পর্যন্ত পৌঁছাতে আপনার প্রথম সেবা পোস্ট করুন।',
      'Filipino':
          'Post your first service to reach a wider audience on Raabta.',
    },
    'listings_empty_title': {
      'English': 'No listings in this category yet',
      'Arabic': 'لا توجد إعلانات في هذه الفئة بعد',
      'Hindi': 'इस श्रेणी में अभी कोई लिस्टिंग नहीं',
      'Urdu': 'اس زمرے میں ابھی کوئی فہرست نہیں',
      'Malayalam': 'No listings in this category yet',
      'Nepali': 'No listings in this category yet',
      'Bengali': 'এই বিভাগে এখনও কোনো তালিকা নেই',
      'Filipino': 'No listings in this category yet',
    },
    'listings_empty_body': {
      'English': 'Be the first to post your service here.',
      'Arabic': 'كن أول من ينشر خدمته هنا.',
      'Hindi': 'यहाँ अपनी सेवा पोस्ट करने वाले पहले व्यक्ति बनें।',
      'Urdu': 'یahan اپنی خدمت پوسٹ کرنے والے پہلے بنیں۔',
      'Malayalam': 'Be the first to post your service here.',
      'Nepali': 'Be the first to post your service here.',
      'Bengali': 'এখানে আপনার সেবা পোস্ট করা প্রথম ব্যক্তি হন।',
      'Filipino': 'Be the first to post your service here.',
    },
    'tab_categories': {
      'English': 'Categories',
      'Arabic': 'الفئات',
      'Hindi': 'श्रेणियाँ',
      'Urdu': 'زمرے',
      'Malayalam': 'Categories',
      'Nepali': 'Categories',
      'Bengali': 'বিভাগ',
      'Filipino': 'Categories',
    },
    'tab_listings': {
      'English': 'Listings',
      'Arabic': 'الإعلانات',
      'Hindi': 'लिस्टिंग',
      'Urdu': 'فہرستیں',
      'Malayalam': 'Listings',
      'Nepali': 'Listings',
      'Bengali': 'তালিকা',
      'Filipino': 'Listings',
    },
    'browse_providers': {
      'English': 'Browse providers',
      'Arabic': 'تصفح مقدمي الخدمة',
      'Hindi': 'प्रदाता देखें',
      'Urdu': 'فراہم کنندگان دیکھیں',
      'Malayalam': 'Browse providers',
      'Nepali': 'Browse providers',
      'Bengali': 'প্রদানকারী দেখুন',
      'Filipino': 'Browse providers',
    },
    'browse_requests': {
      'English': 'Find work',
      'Arabic': 'البحث عن عمل',
      'Hindi': 'काम खोजें',
      'Urdu': 'کام تلاش کریں',
      'Malayalam': 'Find work',
      'Nepali': 'Find work',
      'Bengali': 'কাজ খুঁজুন',
      'Filipino': 'Find work',
    },
    'find_work_hint': {
      'English': 'Open customer requests in your category and area',
      'Arabic': 'اطلع على طلبات العملاء في فئتك ومنطقتك',
      'Hindi': 'अपनी श्रेणी और क्षेत्र में ग्राहक अनुरोध देखें',
      'Urdu': 'اپنی قسم اور علاقے میں گاہک کی درخواستیں دیکھیں',
      'Malayalam': 'Open customer requests in your category and area',
      'Nepali': 'Open customer requests in your category and area',
      'Bengali': 'আপনার বিভাগ ও এলাকায় গ্রাহকের অনুরোধ দেখুন',
      'Filipino': 'Open customer requests in your category and area',
    },
    'listing_request_badge': {
      'English': 'Customer request',
      'Arabic': 'طلب عميل',
      'Hindi': 'ग्राहक अनुरोध',
      'Urdu': 'گاہک کی درخواست',
      'Malayalam': 'Customer request',
      'Nepali': 'Customer request',
      'Bengali': 'গ্রাহকের অনুরোধ',
      'Filipino': 'Customer request',
    },
    'contact_customer_whatsapp': {
      'English': 'WhatsApp customer',
      'Arabic': 'واتساب العميل',
      'Hindi': 'ग्राहक को WhatsApp',
      'Urdu': 'گاہک کو واٹس ایپ',
      'Malayalam': 'WhatsApp customer',
      'Nepali': 'WhatsApp customer',
      'Bengali': 'গ্রাহককে WhatsApp',
      'Filipino': 'WhatsApp customer',
    },
    'posted_by_customer': {
      'English': 'Posted by',
      'Arabic': 'نشر بواسطة',
      'Hindi': 'द्वारा पोस्ट',
      'Urdu': 'پوسٹ کیا',
      'Malayalam': 'Posted by',
      'Nepali': 'Posted by',
      'Bengali': 'পোস্ট করেছেন',
      'Filipino': 'Posted by',
    },
    'browse_category': {
      'English': 'Browse',
      'Arabic': 'تصفح',
      'Hindi': 'देखें',
      'Urdu': 'دیکھیں',
      'Malayalam': 'Browse',
      'Nepali': 'Browse',
      'Bengali': 'দেখুন',
      'Filipino': 'Browse',
    },
    'filter_all': {
      'English': 'All',
      'Arabic': 'الكل',
      'Hindi': 'सभी',
      'Urdu': 'سب',
      'Malayalam': 'All',
      'Nepali': 'All',
      'Bengali': 'সব',
      'Filipino': 'All',
    },
    'field_category': {
      'English': 'Category',
      'Arabic': 'الفئة',
      'Hindi': 'श्रेणी',
      'Urdu': 'زمرہ',
      'Malayalam': 'Category',
      'Nepali': 'Category',
      'Bengali': 'বিভাগ',
      'Filipino': 'Category',
    },
    'field_service_type': {
      'English': 'Service type',
      'Arabic': 'نوع الخدمة',
      'Hindi': 'सेवा प्रकार',
      'Urdu': 'خدمت کی قسم',
      'Malayalam': 'Service type',
      'Nepali': 'Service type',
      'Bengali': 'সেবার ধরন',
      'Filipino': 'Service type',
    },
    'field_title': {
      'English': 'Listing title',
      'Arabic': 'عنوان الإعلان',
      'Hindi': 'लिस्टिंग शीर्षक',
      'Urdu': 'فہرست کا عنوان',
      'Malayalam': 'Listing title',
      'Nepali': 'Listing title',
      'Bengali': 'তালিকার শিরোনাম',
      'Filipino': 'Listing title',
    },
    'field_description': {
      'English': 'Description',
      'Arabic': 'الوصف',
      'Hindi': 'विवरण',
      'Urdu': 'تفصیل',
      'Malayalam': 'Description',
      'Nepali': 'Description',
      'Bengali': 'বিবরণ',
      'Filipino': 'Description',
    },
    'add_photo': {
      'English': 'Add service photo',
      'Arabic': 'أضف صورة الخدمة',
      'Hindi': 'सेवा फ़ोटो जोड़ें',
      'Urdu': 'خدمت کی تصویر شامل کریں',
      'Malayalam': 'Add service photo',
      'Nepali': 'Add service photo',
      'Bengali': 'সেবার ছবি যোগ করুন',
      'Filipino': 'Add service photo',
    },
    'photo_hint': {
      'English': 'Add a clear photo of your work or service for better visibility',
      'Arabic': 'أضف صورة واضحة لعملك أو خدمتك لظهور أفضل',
      'Hindi': 'बेहतर दृश्यता के लिए अपने काम की स्पष्ट फ़ोटो जोड़ें',
      'Urdu': 'بہتر نظر آنے کے لیے اپنے کام کی واضح تصویر شامل کریں',
      'Malayalam':
          'Add a clear photo of your work or service for better visibility',
      'Nepali':
          'Add a clear photo of your work or service for better visibility',
      'Bengali':
          'ভালো দৃশ্যমানতার জন্য আপনার কাজের স্পষ্ট ছবি যোগ করুন',
      'Filipino':
          'Add a clear photo of your work or service for better visibility',
    },
    'photo_camera': {
      'English': 'Take photo',
      'Arabic': 'التقاط صورة',
      'Hindi': 'फ़ोटो लें',
      'Urdu': 'تصویر لیں',
      'Malayalam': 'Take photo',
      'Nepali': 'Take photo',
      'Bengali': 'ছবি তুলুন',
      'Filipino': 'Take photo',
    },
    'photo_gallery': {
      'English': 'Choose from gallery',
      'Arabic': 'اختر من المعرض',
      'Hindi': 'गैलरी से चुनें',
      'Urdu': 'گیلری سے منتخب کریں',
      'Malayalam': 'Choose from gallery',
      'Nepali': 'Choose from gallery',
      'Bengali': 'গ্যালারি থেকে বেছে নিন',
      'Filipino': 'Choose from gallery',
    },
    'validation_photo': {
      'English': 'Please add a photo of your service',
      'Arabic': 'يرجى إضافة صورة لخدمتك',
      'Hindi': 'कृपया अपनी सेवा की फ़ोटो जोड़ें',
      'Urdu': 'براہ کرم اپنی خدمت کی تصویر شامل کریں',
      'Malayalam': 'Please add a photo of your service',
      'Nepali': 'Please add a photo of your service',
      'Bengali': 'অনুগ্রহ করে আপনার সেবার ছবি যোগ করুন',
      'Filipino': 'Please add a photo of your service',
    },
    'validation_description': {
      'English': 'Please add a description (at least 10 characters)',
      'Arabic': 'يرجى إضافة وصف (10 أحرف على الأقل)',
      'Hindi': 'कृपया विवरण जोड़ें (कम से कम 10 अक्षर)',
      'Urdu': 'براہ کرم تفصیل شامل کریں (کم از کم 10 حروف)',
      'Malayalam':
          'Please add a description (at least 10 characters)',
      'Nepali': 'Please add a description (at least 10 characters)',
      'Bengali': 'অনুগ্রহ করে বিবরণ যোগ করুন (কমপক্ষে ১০ অক্ষর)',
      'Filipino':
          'Please add a description (at least 10 characters)',
    },
    'listing_detail': {
      'English': 'Service listing',
      'Arabic': 'إعلان الخدمة',
      'Hindi': 'सेवा लिस्टिंग',
      'Urdu': 'خدمت کی فہرست',
      'Malayalam': 'Service listing',
      'Nepali': 'Service listing',
      'Bengali': 'সেবার তালিকা',
      'Filipino': 'Service listing',
    },
    'contact_whatsapp': {
      'English': 'WhatsApp provider',
      'Arabic': 'واتساب المزوّد',
      'Hindi': 'WhatsApp करें',
      'Urdu': 'واٹس ایپ کریں',
      'Malayalam': 'WhatsApp provider',
      'Nepali': 'WhatsApp provider',
      'Bengali': 'WhatsApp করুন',
      'Filipino': 'WhatsApp provider',
    },
    'contact_call': {
      'English': 'Call provider',
      'Arabic': 'اتصل بالمزوّد',
      'Hindi': 'कॉल करें',
      'Urdu': 'کال کریں',
      'Malayalam': 'Call provider',
      'Nepali': 'Call provider',
      'Bengali': 'কল করুন',
      'Filipino': 'Call provider',
    },
    'provider_profile_title': {
      'English': 'About this provider',
      'Arabic': 'عن مقدم الخدمة',
      'Hindi': 'इस प्रदाता के बारे में',
      'Urdu': 'فراہم کنندہ کے بارے میں',
      'Malayalam': 'About this provider',
      'Nepali': 'About this provider',
      'Bengali': 'এই প্রদানকারী সম্পর্কে',
      'Filipino': 'About this provider',
    },
    'provider_services_offered': {
      'English': 'Services offered',
      'Arabic': 'الخدمات المقدمة',
      'Hindi': 'दी जाने वाली सेवाएँ',
      'Urdu': 'فراہم کردہ خدمات',
      'Malayalam': 'Services offered',
      'Nepali': 'Services offered',
      'Bengali': 'প্রদত্ত সেবা',
      'Filipino': 'Services offered',
    },
    'provider_areas_served': {
      'English': 'Areas served',
      'Arabic': 'المناطق المخدومة',
      'Hindi': 'सेवा क्षेत्र',
      'Urdu': 'خدمت کے علاقے',
      'Malayalam': 'Areas served',
      'Nepali': 'Areas served',
      'Bengali': 'সেবার এলাকা',
      'Filipino': 'Areas served',
    },
    'provider_identity_verified': {
      'English': 'Identity verified',
      'Arabic': 'الهوية موثّقة',
      'Hindi': 'पहचान सत्यापित',
      'Urdu': 'شناخت تصدیق شدہ',
      'Malayalam': 'Identity verified',
      'Nepali': 'Identity verified',
      'Bengali': 'পরিচয় যাচাইকৃত',
      'Filipino': 'Identity verified',
    },
    'svc_sponsorship_awareness_title': {
      'English': 'Hiring a service provider in Qatar',
      'Arabic': 'توظيف مقدم خدمة في قطر',
      'Hindi': 'Qatar mein service provider hire karna',
      'Urdu': 'Qatar mein service provider hire karna',
      'Malayalam': 'Hiring a service provider in Qatar',
      'Nepali': 'Hiring a service provider in Qatar',
      'Bengali': 'Qatar-e service provider নিয়োগ',
      'Filipino': 'Hiring a service provider in Qatar',
    },
    'svc_sponsorship_awareness_teaser': {
      'English':
          'General information about sponsorship rules — not about this listing',
      'Arabic':
          'معلومات عامة عن قواعد الكفالة — وليست عن هذا الإعلان',
      'Hindi':
          'Sponsorship rules ki general jankari — is listing ke baare mein nahi',
      'Urdu':
          'Sponsorship rules ki general jankari — is listing ke baare mein nahi',
      'Malayalam':
          'General information about sponsorship rules — not about this listing',
      'Nepali':
          'General information about sponsorship rules — not about this listing',
      'Bengali':
          'Sponsorship rules-er general info — ei listing-er judgment na',
      'Filipino':
          'General information about sponsorship rules — not about this listing',
    },
    'svc_sponsorship_awareness_body': {
      'English':
          'Qatar\'s employment system requires every worker to be sponsored by a specific employer. Informal arrangements sometimes called a "freelance visa," "free visa," or similar are widely described in community sources — but a worker is only legally authorized to work for their actual sponsor.',
      'Arabic':
          'يتطلب نظام التوظيف في قطر أن يكون لكل عامل كفيلاً محدداً. الترتيبات غير الرسمية — أحياناً "تأشيرة عمل حر" أو ما شابه — شائعة في المصادر المجتمعية، لكن العامل مخوّل قانونياً بالعمل لكفيله الفعلي فقط.',
      'Hindi':
          'Qatar mein har worker ka specific employer sponsor hona zaroori hai. "Freelance visa" jaisi informal arrangements community mein common hain — lekin worker legally sirf apne asli sponsor ke liye kaam kar sakta hai.',
      'Urdu':
          'Qatar mein har worker ka specific employer sponsor hona zaroori hai. "Freelance visa" jaisi informal arrangements community mein common hain — lekin worker legally sirf apne asli sponsor ke liye kaam kar sakta hai.',
      'Malayalam':
          'Qatar\'s employment system requires every worker to be sponsored by a specific employer. Informal "freelance visa" arrangements are common in community sources — but a worker is only legally authorized to work for their actual sponsor.',
      'Nepali':
          'Qatar\'s employment system requires every worker to be sponsored by a specific employer. Informal "freelance visa" arrangements are common in community sources — but a worker is only legally authorized to work for their actual sponsor.',
      'Bengali':
          'Qatar-e pratyek worker-er ekti specific employer sponsor thakte hoy. Informal "freelance visa" arrangement common — kintu worker legally shudhu tar asol sponsor-er jonno kaaj korte pare.',
      'Filipino':
          'Qatar\'s employment system requires every worker to be sponsored by a specific employer. Informal "freelance visa" arrangements are common in community sources — but a worker is only legally authorized to work for their actual sponsor.',
    },
    'svc_sponsorship_awareness_art15': {
      'English':
          'Known: Under Article 15 of Labour Law No. 14 of 2004, it is prohibited to allow a worker to work for someone other than their sponsoring employer, and to employ a worker who is not under your sponsorship — even informally or for a single job. Secondary legal guides cite criminal penalties of up to three years\' imprisonment and/or a fine of up to QAR 50,000 for whoever hires the worker. Verify directly on Al Meezan.',
      'Arabic':
          'معروف: بموجب المادة 15 من قانون العمل رقم 14 لسنة 2004، يُحظر السماح للعامل بالعمل لغير كفيله أو توظيف عامل ليس تحت كفالتك — حتى بشكل غير رسمي. مصادر قانونية ثانوية تذكر عقوبات جنائية (حتى 3 سنوات سجن و/أو غرامة حتى 50,000 ر.ق) لمن يوظّف العامل. تحقق على الميزان.',
      'Hindi':
          'Known: Labour Law 14/2004 Article 15 ke under, worker ko apne sponsor ke alawa kaam karne dena ya bina apni sponsorship ke worker hire karna mana hai — chahe informal ho. Secondary sources ke mutabiq hiring party par criminal penalty ho sakti hai (3 saal tak jail aur/ya QAR 50,000 tak fine). Al Meezan par verify karein.',
      'Urdu':
          'Known: Labour Law 14/2004 Article 15 ke under, worker ko apne sponsor ke alawa kaam karne dena ya bina apni sponsorship ke worker hire karna mana hai — chahe informal ho. Secondary sources ke mutabiq hiring party par criminal penalty ho sakti hai (3 saal tak jail aur/ya QAR 50,000 tak fine). Al Meezan par verify karein.',
      'Malayalam':
          'Known: Under Article 15 of Labour Law No. 14 of 2004, hiring a worker outside your sponsorship — even informally — is prohibited. Secondary guides cite penalties up to three years\' imprisonment and/or QAR 50,000. Verify on Al Meezan.',
      'Nepali':
          'Known: Under Article 15 of Labour Law No. 14 of 2004, hiring a worker outside your sponsorship — even informally — is prohibited. Secondary guides cite penalties up to three years\' imprisonment and/or QAR 50,000. Verify on Al Meezan.',
      'Bengali':
          'Known: Labour Law 14/2004 Article 15 — apnar sponsorship chara worker hire kora nishiddho, informal holeo. Secondary sources-onujayi penalty 3 bochor jail o/ ba QAR 50,000 porjonto. Al Meezan-e verify korun.',
      'Filipino':
          'Known: Under Article 15 of Labour Law No. 14 of 2004, hiring a worker outside your sponsorship — even informally — is prohibited. Secondary guides cite penalties up to three years\' imprisonment and/or QAR 50,000. Verify on Al Meezan.',
    },
    'svc_sponsorship_awareness_licensed': {
      'English':
          'Possible lower-risk approach: using a properly licensed company that sponsors its own staff for the same type of service, rather than hiring an individual through an informal arrangement.',
      'Arabic':
          'نهج قد يكون أقل مخاطرة: استخدام شركة مرخّصة تكفّل موظفيها لنفس نوع الخدمة، بدلاً من توظيف فرد عبر ترتيب غير رسمي.',
      'Hindi':
          'Kam risk wala option: licensed company jo apne staff ko sponsor karti hai, individual informal arrangement ke bajaye.',
      'Urdu':
          'Kam risk wala option: licensed company jo apne staff ko sponsor karti hai, individual informal arrangement ke bajaye.',
      'Malayalam':
          'Possible lower-risk approach: a licensed company sponsoring its own staff, rather than an individual informal arrangement.',
      'Nepali':
          'Possible lower-risk approach: a licensed company sponsoring its own staff, rather than an individual informal arrangement.',
      'Bengali':
          'Kom risk: licensed company tar nijer staff sponsor kore — individual informal arrangement-er bodole.',
      'Filipino':
          'Possible lower-risk approach: a licensed company sponsoring its own staff, rather than an individual informal arrangement.',
    },
    'svc_sponsorship_awareness_freelance_link': {
      'English': 'More on informal work arrangements →',
      'Arabic': 'المزيد عن الترتيبات غير الرسمية →',
      'Hindi': 'Informal arrangements par aur →',
      'Urdu': 'Informal arrangements par aur →',
      'Malayalam': 'More on informal work arrangements →',
      'Nepali': 'More on informal work arrangements →',
      'Bengali': 'Informal arrangement samporke aro →',
      'Filipino': 'More on informal work arrangements →',
    },
    'report_listing': {
      'English': 'Report this listing',
      'Arabic': 'أبلغ عن هذا الإعلان',
      'Hindi': 'Is listing ki report karein',
      'Urdu': 'Is listing ki report karein',
    },
    'report_submitted': {
      'English': 'Report submitted — thank you.',
      'Arabic': 'تم إرسال البلاغ — شكراً لك.',
      'Hindi': 'Report submit ho gayi — shukriya.',
      'Urdu': 'Report submit ho gayi — shukriya.',
    },
    'hub_browse_categories': {
      'English': 'Browse categories',
      'Arabic': 'تصفح الفئات',
      'Hindi': 'श्रेणियाँ देखें',
      'Urdu': 'زمرے دیکھیں',
      'Malayalam': 'Browse categories',
      'Nepali': 'Browse categories',
      'Bengali': 'বিভাগ ব্রাউজ করুন',
      'Filipino': 'Browse categories',
    },
    'hub_segment_providers': {
      'English': 'Providers',
      'Arabic': 'مقدمو الخدمة',
      'Hindi': 'प्रदाता',
      'Urdu': 'فراہم کنندگان',
      'Malayalam': 'Providers',
      'Nepali': 'Providers',
      'Bengali': 'প্রদানকারী',
      'Filipino': 'Providers',
    },
    'hub_segment_requests': {
      'English': 'Requests',
      'Arabic': 'الطلبات',
      'Hindi': 'अनुरोध',
      'Urdu': 'درخواستیں',
      'Malayalam': 'Requests',
      'Nepali': 'Requests',
      'Bengali': 'অনুরোধ',
      'Filipino': 'Requests',
    },
    'quick_post_request': {
      'English': 'Post a request',
      'Arabic': 'انشر طلباً',
      'Hindi': 'अनुरोध पोस्ट करें',
      'Urdu': 'درخواست پوسٹ کریں',
      'Malayalam': 'Post a request',
      'Nepali': 'Post a request',
      'Bengali': 'অনুরোধ পোস্ট করুন',
      'Filipino': 'Post a request',
    },
    'quick_offer_service': {
      'English': 'Offer a service',
      'Arabic': 'قدّم خدمة',
      'Hindi': 'सेवा ऑफर करें',
      'Urdu': 'خدمت پیش کریں',
      'Malayalam': 'Offer a service',
      'Nepali': 'Offer a service',
      'Bengali': 'সেবা অফার করুন',
      'Filipino': 'Offer a service',
    },
    'quick_saved': {
      'English': 'Saved',
      'Arabic': 'محفوظ',
      'Hindi': 'सहेजे',
      'Urdu': 'محفوظ',
      'Malayalam': 'Saved',
      'Nepali': 'Saved',
      'Bengali': 'সংরক্ষিত',
      'Filipino': 'Saved',
    },
    'quick_near_me': {
      'English': 'Near me',
      'Arabic': 'قريب مني',
      'Hindi': 'मेरे पास',
      'Urdu': 'میرے قریب',
      'Malayalam': 'Near me',
      'Nepali': 'Near me',
      'Bengali': 'আমার কাছে',
      'Filipino': 'Near me',
    },
    'filter_category': {
      'English': 'Category',
      'Arabic': 'الفئة',
      'Hindi': 'श्रेणी',
      'Urdu': 'زمرہ',
      'Malayalam': 'Category',
      'Nepali': 'Category',
      'Bengali': 'বিভাগ',
      'Filipino': 'Category',
    },
    'filter_area': {
      'English': 'Area',
      'Arabic': 'المنطقة',
      'Hindi': 'क्षेत्र',
      'Urdu': 'علاقہ',
      'Malayalam': 'Area',
      'Nepali': 'Area',
      'Bengali': 'এলাকা',
      'Filipino': 'Area',
    },
    'filter_verified_only': {
      'English': 'Verified only',
      'Arabic': 'موثّق فقط',
      'Hindi': 'केवल सत्यापित',
      'Urdu': 'صرف تصدیق شدہ',
      'Malayalam': 'Verified only',
      'Nepali': 'Verified only',
      'Bengali': 'শুধু যাচাইকৃত',
      'Filipino': 'Verified only',
    },
    'hub_filters_semantics': {
      'English': 'Service filters',
      'Arabic': 'فلاتر الخدمات',
      'Hindi': 'सेवा फ़िल्टर',
      'Urdu': 'خدمت فلٹر',
      'Malayalam': 'Service filters',
      'Nepali': 'Service filters',
      'Bengali': 'সেবা ফিল্টার',
      'Filipino': 'Service filters',
    },
    'hub_my_listings_count': {
      'English': '{count} listings',
      'Arabic': '{count} إعلانات',
      'Hindi': '{count} लिस्टिंग',
      'Urdu': '{count} فہرستیں',
      'Malayalam': '{count} listings',
      'Nepali': '{count} listings',
      'Bengali': '{count} তালিকা',
      'Filipino': '{count} listings',
    },
    'hub_my_listings_all': {
      'English': 'All',
      'Arabic': 'الكل',
      'Hindi': 'सभी',
      'Urdu': 'سب',
      'Malayalam': 'All',
      'Nepali': 'All',
      'Bengali': 'সব',
      'Filipino': 'All',
    },
    'hub_my_listings_subtitle': {
      'English': 'Manage your service posts',
      'Arabic': 'إدارة إعلانات خدماتك',
      'Hindi': 'अपनी सेवा पोस्ट प्रबंधित करें',
      'Urdu': 'اپنی سروس پوسٹس منظم کریں',
      'Malayalam': 'Manage your service posts',
      'Nepali': 'Manage your service posts',
      'Bengali': 'আপনার সেবা পোস্ট পরিচালনা করুন',
      'Filipino': 'Manage your service posts',
    },
    'hub_strip_open_requests': {
      'English': 'Open requests',
      'Arabic': 'طلبات مفتوحة',
      'Hindi': 'खुले अनुरोध',
      'Urdu': 'کھلی درخواستیں',
      'Malayalam': 'Open requests',
      'Nepali': 'Open requests',
      'Bengali': 'খোলা অনুরোধ',
      'Filipino': 'Open requests',
    },
    'hub_picker_category_title': {
      'English': 'Category',
      'Arabic': 'الفئة',
      'Hindi': 'श्रेणी',
      'Urdu': 'زمرہ',
      'Malayalam': 'Category',
      'Nepali': 'Category',
      'Bengali': 'বিভাগ',
      'Filipino': 'Category',
    },
    'hub_picker_category_subtitle': {
      'English': 'Filter listings by service category',
      'Arabic': 'تصفية الإعلانات حسب فئة الخدمة',
      'Hindi': 'सेवा श्रेणी से लिस्टिंग फ़िल्टर करें',
      'Urdu': 'خدمت کی قسم سے فہرستیں فلٹر کریں',
      'Malayalam': 'Filter listings by service category',
      'Nepali': 'Filter listings by service category',
      'Bengali': 'সেবার বিভাগ অনুযায়ী তালিকা ফিল্টার করুন',
      'Filipino': 'Filter listings by service category',
    },
    'hub_empty_filtered_title': {
      'English': 'No listings match your filters',
      'Arabic': 'لا توجد إعلانات مطابقة للفلاتر',
      'Hindi': 'आपके फ़िल्टर से कोई लिस्टिंग मेल नहीं खाती',
      'Urdu': 'آپ کے فلٹر سے کوئی فہرست نہیں ملی',
      'Malayalam': 'No listings match your filters',
      'Nepali': 'No listings match your filters',
      'Bengali': 'আপনার ফিল্টারের সাথে কোনো তালিকা মেলেনি',
      'Filipino': 'No listings match your filters',
    },
    'hub_empty_filtered_description': {
      'English': 'Try clearing a filter or post your own listing.',
      'Arabic': 'جرّب مسح فلتر أو انشر إعلانك.',
      'Hindi': 'फ़िल्टर हटाएँ या अपनी लिस्टिंग पोस्ट करें।',
      'Urdu': 'فلٹر صاف کریں یا اپنی فہرست پوسٹ کریں۔',
      'Malayalam': 'Try clearing a filter or post your own listing.',
      'Nepali': 'Try clearing a filter or post your own listing.',
      'Bengali': 'একটি ফিল্টার মুছুন বা নিজের তালিকা পোস্ট করুন।',
      'Filipino': 'Try clearing a filter or post your own listing.',
    },
    'hub_load_error_title': {
      'English': 'Could not load services',
      'Arabic': 'تعذّر تحميل الخدمات',
      'Hindi': 'सेवाएँ लोड नहीं हो सकीं',
      'Urdu': 'خدمات لوڈ نہیں ہو سکیں',
      'Malayalam': 'Could not load services',
      'Nepali': 'Could not load services',
      'Bengali': 'সেবা লোড করা যায়নি',
      'Filipino': 'Could not load services',
    },
    'hub_open_request_badge': {
      'English': 'Open request',
      'Arabic': 'طلب مفتوح',
      'Hindi': 'खुला अनुरोध',
      'Urdu': 'کھلا درخواست',
      'Malayalam': 'Open request',
      'Nepali': 'Open request',
      'Bengali': 'খোলা অনুরোধ',
      'Filipino': 'Open request',
    },
    'hub_needs_prefix': {
      'English': 'Needs:',
      'Arabic': 'يحتاج:',
      'Hindi': 'चाहिए:',
      'Urdu': 'ضرورت:',
      'Malayalam': 'Needs:',
      'Nepali': 'Needs:',
      'Bengali': 'প্রয়োজন:',
      'Filipino': 'Needs:',
    },
    'hub_rate_from': {
      'English': 'From QAR {amount}',
      'Arabic': 'من {amount} ر.ق',
      'Hindi': 'QAR {amount} से',
      'Urdu': 'QAR {amount} سے',
      'Malayalam': 'From QAR {amount}',
      'Nepali': 'From QAR {amount}',
      'Bengali': 'QAR {amount} থেকে',
      'Filipino': 'From QAR {amount}',
    },
    'hub_posted_days_ago': {
      'English': 'Posted {count}d ago',
      'Arabic': 'نُشر منذ {count} ي',
      'Hindi': '{count} दिन पहले पोस्ट',
      'Urdu': '{count} دن پہلے پوسٹ',
      'Malayalam': 'Posted {count}d ago',
      'Nepali': 'Posted {count}d ago',
      'Bengali': '{count} দিন আগে পোস্ট',
      'Filipino': 'Posted {count}d ago',
    },
    'hub_posted_hours_ago': {
      'English': 'Posted {count}h ago',
      'Arabic': 'نُشر منذ {count} س',
      'Hindi': '{count} घंटे पहले पोस्ट',
      'Urdu': '{count} گھنٹے پہلے پوسٹ',
      'Malayalam': 'Posted {count}h ago',
      'Nepali': 'Posted {count}h ago',
      'Bengali': '{count} ঘণ্টা আগে পোস্ট',
      'Filipino': 'Posted {count}h ago',
    },
    'detail_call': {
      'English': 'Call',
      'Arabic': 'اتصال',
      'Hindi': 'कॉल',
      'Urdu': 'کال',
      'Malayalam': 'Call',
      'Nepali': 'Call',
      'Bengali': 'কল',
      'Filipino': 'Call',
    },
    'detail_message': {
      'English': 'Message',
      'Arabic': 'رسالة',
      'Hindi': 'संदेश',
      'Urdu': 'پیغام',
      'Malayalam': 'Message',
      'Nepali': 'Message',
      'Bengali': 'বার্তা',
      'Filipino': 'Message',
    },
    'detail_share_message': {
      'English': 'Raabta — {title}',
      'Arabic': 'رابطة — {title}',
      'Hindi': 'Raabta — {title}',
      'Urdu': 'Raabta — {title}',
      'Malayalam': 'Raabta — {title}',
      'Nepali': 'Raabta — {title}',
      'Bengali': 'Raabta — {title}',
      'Filipino': 'Raabta — {title}',
    },
    'hub_posted_just_now': {
      'English': 'Posted just now',
      'Arabic': 'نُشر للتو',
      'Hindi': 'अभी पोस्ट',
      'Urdu': 'ابھی پوسٹ',
      'Malayalam': 'Posted just now',
      'Nepali': 'Posted just now',
      'Bengali': 'এইমাত্র পোস্ট',
      'Filipino': 'Posted just now',
    },
    'svc_sponsorship_awareness_disclaimer': {
      'English':
          'General information only — not legal advice and not a judgment about this provider. Raabta has not verified any listing\'s sponsorship status. Verify on Al Meezan / mol.gov.qa or consult a qualified lawyer.',
      'Arabic':
          'معلومات عامة فقط — ليست استشارة قانونية وليست حكماً على هذا المقدم. Raabta لم تتحقق من وضع الكفالة. تحقق على الميزان / mol.gov.qa أو استشر محامياً.',
      'Hindi':
          'Sirf general information — legal advice nahi, is provider par judgment nahi. Raabta ne sponsorship verify nahi ki. Al Meezan / mol.gov.qa par verify karein ya lawyer se salah lein.',
      'Urdu':
          'Sirf general information — legal advice nahi, is provider par judgment nahi. Raabta ne sponsorship verify nahi ki. Al Meezan / mol.gov.qa par verify karein ya lawyer se salah lein.',
      'Malayalam':
          'General information only — not legal advice and not a judgment about this provider. Verify on Al Meezan / mol.gov.qa.',
      'Nepali':
          'General information only — not legal advice and not a judgment about this provider. Verify on Al Meezan / mol.gov.qa.',
      'Bengali':
          'General info matra — legal advice na, ei provider-er judgment na. Al Meezan / mol.gov.qa-te verify korun.',
      'Filipino':
          'General information only — not legal advice and not a judgment about this provider. Verify on Al Meezan / mol.gov.qa.',
    },
  };
}
