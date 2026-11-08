/// Quick Actions Hub — tool titles, short labels, and hub chrome.
import 'package:flutter/foundation.dart';
import 'package:raabta/core/l10n/app_locale.dart';
import 'package:raabta/core/l10n/locale_catalog_coverage.dart';
import 'package:raabta/core/l10n/locale_catalog_entry.dart';

abstract final class QuickActionsStrings {
  static const supportedLocales = AppLocale.supportedLocales;

  /// Longer copy and descriptions pending native review for ML/NE/BN/TA/TL.
  static const keysNeedingProfessionalReview = <String>{
    'hub_subtitle',
    'tool_services_description',
    'tool_scanner_description',
    'tool_vault_description',
    'tool_barcode_description',
    'tool_arabic_companion_description',
    'tool_bill_splitter_description',
    'tool_warranty_description',
    'tool_scam_shield_description',
    'tool_climate_description',
    'tool_queue_description',
    'tool_bill_tracker_description',
    'tool_know_qatar_description',
    'tool_trip_description',
    'tool_prayer_description',
    'tool_eosb_description',
    'tool_health_insurance_description',
    'tool_tenancy_description',
    'tool_sponsorship_transfer_description',
    'tool_ussd_description',
    'tool_driving_description',
    'tool_ramadan_description',
  };

  static String t(String key, [String locale = 'English']) {
    final normalized = AppLocale.normalize(locale);
    final map = _catalog[key];
    if (map == null) return key;
    return map[normalized] ?? map['English'] ?? key;
  }

  /// Exposed for catalog parity regression tests only.
  @visibleForTesting
  static Map<String, Set<String>> get localeCoverageReport =>
      buildLocaleCoverageReport(
        catalog: _catalog,
        supportedLocales: supportedLocales,
      );

  static final _catalog = <String, Map<String, String>>{
    // ── Hub chrome ──────────────────────────────────────────────────────────
    'hub_title': l10nEntry(
      english: 'Quick Actions',
      arabic: 'إجراءات سريعة',
      hindi: 'त्वरित कार्य',
      urdu: 'فوری اقدامات',
    ),
    'hub_subtitle': l10nEntry(
      english: 'Your most used AI powered tools',
      arabic: 'أدواتك الأكثر استخداماً المدعومة بالذكاء الاصطناعي',
      hindi: 'आपके सबसे ज़्यादा इस्तेमाल किए AI उपकरण',
      urdu: 'آپ کے سب سے زیادہ استعمال ہونے والے AI ٹولز',
    ),
    'hub_section_documents': l10nEntry(
      english: 'Documents',
      arabic: 'المستندات',
      hindi: 'Documents',
      urdu: 'Documents',
    ),
    'hub_section_money_bills': l10nEntry(
      english: 'Money & Bills',
      arabic: 'المال والفواتير',
      hindi: 'Money & Bills',
      urdu: 'Money & Bills',
    ),
    'hub_section_protection': l10nEntry(
      english: 'Protection',
      arabic: 'الحماية',
      hindi: 'Protection',
      urdu: 'Protection',
    ),
    'hub_section_utilities': l10nEntry(
      english: 'Utilities & More',
      arabic: 'المرافق والمزيد',
      hindi: 'Utilities & More',
      urdu: 'Utilities & More',
    ),
    'hub_section_other': l10nEntry(
      english: 'Other',
      arabic: 'أخرى',
      hindi: 'Other',
      urdu: 'Other',
    ),

    // ── Services ──────────────────────────────────────────────────────────────
    'tool_services_title': l10nEntry(
      english: 'Services',
      arabic: 'الخدمات',
      hindi: 'सेवाएँ',
      urdu: 'خدمات',
    ),
    'tool_services_short_label': l10nEntry(
      english: 'Services',
      arabic: 'الخدمات',
      hindi: 'सेवाएँ',
      urdu: 'خدمات',
    ),
    'tool_services_description': l10nEntry(
      english: 'Post your service or browse classified listings',
      arabic: 'انشر خدمتك أو تصفح الإعلانات',
      hindi: 'अपनी सेवा पोस्ट करें या लिस्टिंग देखें',
      urdu: 'اپنی سروس پوسٹ کریں یا لسٹنگز دیکھیں',
    ),

    // ── PDF Studio / Scanner ──────────────────────────────────────────────────
    'tool_scanner_title': l10nEntry(
      english: 'PDF Studio',
      arabic: 'استوديو PDF',
      hindi: 'PDF Studio',
      urdu: 'PDF Studio',
    ),
    'tool_scanner_short_label': l10nEntry(
      english: 'Scanner',
      arabic: 'مسح',
      hindi: 'स्कैनर',
      urdu: 'اسکینر',
    ),
    'tool_scanner_description': l10nEntry(
      english: 'Scan, OCR, PDF tools & vault',
      arabic: 'مسح، OCR، أدوات PDF والخزنة',
      hindi: 'Scan, OCR, PDF tools & vault',
      urdu: 'Scan, OCR, PDF tools & vault',
    ),

    // ── Document Vault ────────────────────────────────────────────────────────
    'tool_vault_title': l10nEntry(
      english: 'Document Vault',
      arabic: 'خزنة المستندات',
      hindi: 'Document Vault',
      urdu: 'Document Vault',
    ),
    'tool_vault_short_label': l10nEntry(
      english: 'Vault',
      arabic: 'خزنة',
      hindi: 'वॉल्ट',
      urdu: 'والٹ',
    ),
    'tool_vault_description': l10nEntry(
      english: 'View & chat with your documents',
      arabic: 'اعرض مستنداتك وتحدث معها',
      hindi: 'View & chat with your documents',
      urdu: 'View & chat with your documents',
    ),

    // ── Barcode Scanner ───────────────────────────────────────────────────────
    'tool_barcode_title': l10nEntry(
      english: 'Barcode Scanner',
      arabic: 'ماسح الباركود',
      hindi: 'Barcode Scanner',
      urdu: 'Barcode Scanner',
    ),
    'tool_barcode_short_label': l10nEntry(
      english: 'Barcode',
      arabic: 'باركود',
      hindi: 'बारकोड',
      urdu: 'بارکوڈ',
    ),
    'tool_barcode_description': l10nEntry(
      english: 'Scan any product barcode',
      arabic: 'امسح باركود أي منتج',
      hindi: 'Scan any product barcode',
      urdu: 'Scan any product barcode',
    ),

    // ── Arabic Companion ──────────────────────────────────────────────────────
    'tool_arabic_companion_title': l10nEntry(
      english: 'Arabic Companion',
      arabic: 'رفيق العربية',
      hindi: 'Arabic Companion',
      urdu: 'Arabic Companion',
    ),
    'tool_arabic_companion_short_label': l10nEntry(
      english: 'Arabic',
      arabic: 'عربي',
      hindi: 'अरबी',
      urdu: 'عربی',
    ),
    'tool_arabic_companion_description': l10nEntry(
      english: 'Phrasebook + live Gulf Arabic translation',
      arabic: 'عبارات + ترجمة خليجية مباشرة',
      hindi: 'Phrasebook + live Gulf Arabic translation',
      urdu: 'Phrasebook + live Gulf Arabic translation',
    ),

    // ── Bill Splitter ─────────────────────────────────────────────────────────
    'tool_bill_splitter_title': l10nEntry(
      english: 'Split Bills',
      arabic: 'تقسيم الفواتير',
      hindi: 'बिल बाँटें',
      urdu: 'بل تقسیم کریں',
      malayalam: 'ബില്ലുകൾ പങ്കിടുക',
      nepali: 'बिल बाँट्नुहोस्',
      bengali: 'বিল ভাগ করুন',
      tamil: 'பில்களைப் பிரிக்கவும்',
      filipino: 'Split Bills',
    ),
    'tool_bill_splitter_short_label': l10nEntry(
      english: 'Split Bills',
      arabic: 'تقسيم الفواتير',
      hindi: 'बिल बाँट',
      urdu: 'بل تقسیم',
      malayalam: 'ബിൽ പങ്കിടൽ',
      nepali: 'बिल बाँट',
      bengali: 'বিল ভাগ',
      tamil: 'பில் பிரிப்பு',
      filipino: 'Split Bills',
    ),
    'tool_bill_splitter_description': l10nEntry(
      english: 'Split bills in any currency',
      arabic: 'قسّم الفواتير بأي عملة',
      hindi: 'Split bills in any currency',
      urdu: 'Split bills in any currency',
    ),

    // ── Warranty Shield ───────────────────────────────────────────────────────
    'tool_warranty_title': l10nEntry(
      english: 'Warranty Shield',
      arabic: 'درع الضمان',
      hindi: 'Warranty Shield',
      urdu: 'Warranty Shield',
    ),
    'tool_warranty_short_label': l10nEntry(
      english: 'Warranty Shield',
      arabic: 'درع الضمان',
      hindi: 'वारंटी शील्ड',
      urdu: 'Warranty Shield',
      malayalam: 'Warranty Shield',
      nepali: 'Warranty Shield',
      bengali: 'Warranty Shield',
      tamil: 'Warranty Shield',
      filipino: 'Warranty Shield',
    ),
    'tool_warranty_description': l10nEntry(
      english: 'Track your Qatar warranties',
      arabic: 'تتبع ضماناتك في قطر',
      hindi: 'Track your Qatar warranties',
      urdu: 'Track your Qatar warranties',
    ),

    // ── Scam Shield ───────────────────────────────────────────────────────────
    'tool_scam_shield_title': l10nEntry(
      english: 'Scam Shield',
      arabic: 'درع الاحتيال',
      hindi: 'Scam Shield',
      urdu: 'Scam Shield',
    ),
    'tool_scam_shield_short_label': l10nEntry(
      english: 'Scam Shield',
      arabic: 'درع الاحتيال',
      hindi: 'Scam Shield',
      urdu: 'Scam Shield',
    ),
    'tool_scam_shield_description': l10nEntry(
      english: 'Check suspicious messages before you act',
      arabic: 'تحقق من الرسائل المشبوهة قبل التصرف',
      hindi: 'Check suspicious messages before you act',
      urdu: 'Check suspicious messages before you act',
    ),

    // ── Heat Safety ───────────────────────────────────────────────────────────
    'tool_climate_title': l10nEntry(
      english: 'Heat Safety',
      arabic: 'السلامة من الحر',
      hindi: 'गर्मी से सुरक्षा',
      urdu: 'گرمی سے تحفظ',
      malayalam: 'ചൂടിൽ സുരക്ഷ',
      nepali: 'ताप सुरक्षा',
      bengali: 'তাপ সুরক্ষা',
      tamil: 'வெப்ப பாதுகாப்பு',
      filipino: 'Heat Safety',
    ),
    'tool_climate_short_label': l10nEntry(
      english: 'Heat Safety',
      arabic: 'السلامة من الحر',
      hindi: 'गर्मी सुरक्षा',
      urdu: 'گرمی تحفظ',
      malayalam: 'ചൂട് സുരക്ഷ',
      nepali: 'ताप सुरक्षा',
      bengali: 'তাপ সুরক্ষা',
      tamil: 'வெப்ப பாதுகாப்பு',
      filipino: 'Heat Safety',
    ),
    'tool_climate_description': l10nEntry(
      english: 'Indoor & shaded routes',
      arabic: 'مسارات داخلية ومظللة',
      hindi: 'Indoor & shaded routes',
      urdu: 'Indoor & shaded routes',
    ),

    // ── Skip the Queue ──────────────────────────────────────────────────────
    'tool_queue_title': l10nEntry(
      english: 'Skip the Queue',
      arabic: 'تخطَّ الطابور',
      hindi: 'कतार छोड़ें',
      urdu: 'قطار چھوڑیں',
      malayalam: 'ക്യൂ വിട്ടുപോകുക',
      nepali: 'लाम छोड्नुहोस्',
      bengali: 'সারি এড়িয়ে যান',
      tamil: 'வரிசையைத் தவிர்க்கவும்',
      filipino: 'Laktawan ang pila',
    ),
    'tool_queue_short_label': l10nEntry(
      english: 'Skip the Queue',
      arabic: 'تخطَّ الطابور',
      hindi: 'कतार छोड़ें',
      urdu: 'قطار چھوڑیں',
      malayalam: 'ക്യൂ വിട്ടുപോകുക',
      nepali: 'लाम छोड्नुहोस्',
      bengali: 'সারি এড়িয়ে যান',
      tamil: 'வரிசை தவிர்',
      filipino: 'Laktawan ang pila',
    ),
    'tool_queue_description': l10nEntry(
      english: 'Live wait times in Qatar',
      arabic: 'أوقات الانتظار المباشرة في قطر',
      hindi: 'Live wait times in Qatar',
      urdu: 'Live wait times in Qatar',
    ),

    // ── Bill Reminders ────────────────────────────────────────────────────────
    'tool_bill_tracker_title': l10nEntry(
      english: 'Bill Reminders',
      arabic: 'تذكيرات الفواتير',
      hindi: 'बिल अनुस्मारक',
      urdu: 'بل یاددہانیاں',
      malayalam: 'ബിൽ റിമൈൻഡറുകൾ',
      nepali: 'बिल सम्झना',
      bengali: 'বিল অনুস্মারক',
      tamil: 'பில் நினைவூட்டல்கள்',
      filipino: 'Bill Reminders',
    ),
    'tool_bill_tracker_short_label': l10nEntry(
      english: 'Bill Reminders',
      arabic: 'تذكيرات الفواتير',
      hindi: 'बिल अनुस्मारक',
      urdu: 'بل یاددہانیاں',
      malayalam: 'ബിൽ റിമൈൻഡർ',
      nepali: 'बिल सम्झना',
      bengali: 'বিল অনুস্মারক',
      tamil: 'பில் நினைவூட்டல்',
      filipino: 'Bill Reminders',
    ),
    'tool_bill_tracker_description': l10nEntry(
      english: 'Track Qatar utility bills',
      arabic: 'تتبع فواتير قطر',
      hindi: 'Track Qatar utility bills',
      urdu: 'Track Qatar utility bills',
    ),

    // ── Know Qatar ────────────────────────────────────────────────────────────
    'tool_know_qatar_title': l10nEntry(
      english: 'Know Qatar',
      arabic: 'تعرّف على قطر',
      hindi: 'क़तर जानें',
      urdu: 'قطر جانیں',
    ),
    'tool_know_qatar_short_label': l10nEntry(
      english: 'Know Qatar',
      arabic: 'تعرّف على قطر',
      hindi: 'क़तर जानें',
      urdu: 'قطر جانیں',
      malayalam: 'ഖത്തർ അറിയുക',
      nepali: 'कतर जान्नुहोस्',
      bengali: 'কাতার জানুন',
      tamil: 'கத்தார் அறியுங்கள்',
      filipino: 'Know Qatar',
    ),
    'tool_know_qatar_description': l10nEntry(
      english: 'History, culture, work & living guides with official sources',
      arabic: 'دليل التاريخ والثقافة والعمل والمعيشة بمصادر رسمية',
      hindi: 'History, culture, work & living guides with official sources',
      urdu: 'History, culture, work & living guides with official sources',
    ),

    // ── Telecom contract decoder ─────────────────────────────────────────────
    'tool_telecom_decoder_title': l10nEntry(
      english: 'Sign or Cancel Telecom',
      arabic: 'توقيع أو إلغاء الاتصالات',
      hindi: 'Telecom Sign/Cancel',
      urdu: 'Telecom Sign/Cancel',
    ),
    'tool_telecom_decoder_short_label': l10nEntry(
      english: 'Telecom',
      arabic: 'اتصالات',
      hindi: 'Telecom',
      urdu: 'Telecom',
    ),
    'tool_telecom_decoder_description': l10nEntry(
      english: 'Contract traps, early termination fees & CRA escalation path',
      arabic: 'فخاخ العقود ورسوم الإنهاء المبكر والتصعيد إلى CRA',
      hindi: 'Contract traps, early termination fees & CRA escalation',
      urdu: 'Contract traps, early termination fees & CRA escalation',
    ),

    // ── Buying a car ──────────────────────────────────────────────────────────
    'tool_buying_car_title': l10nEntry(
      english: 'Buying a Car',
      arabic: 'شراء سيارة',
      hindi: 'Car khareedna',
      urdu: 'Car khareedna',
    ),
    'tool_buying_car_short_label': l10nEntry(
      english: 'Used cars',
      arabic: 'سيارات مستعملة',
      hindi: 'Used cars',
      urdu: 'Used cars',
    ),
    'tool_buying_car_description': l10nEntry(
      english: 'As-is private-sale risks, transfer steps & MOCI consumer rights',
      arabic: 'مخاطر البيع الخاص as-is وخطوات النقل وحقوق MOCI',
      hindi: 'As-is private-sale risks, transfer steps & MOCI rights',
      urdu: 'As-is private-sale risks, transfer steps & MOCI rights',
    ),

    // ── Freelance visa explainer ──────────────────────────────────────────────
    'tool_freelance_visa_title': l10nEntry(
      english: 'Freelance Visa Facts',
      arabic: 'حقائق تأشيرة العمل الحر',
      hindi: 'Freelance Visa Facts',
      urdu: 'Freelance Visa Facts',
    ),
    'tool_freelance_visa_short_label': l10nEntry(
      english: 'Freelance visa',
      arabic: 'تأشيرة العمل الحر',
      hindi: 'Freelance visa',
      urdu: 'Freelance visa',
    ),
    'tool_freelance_visa_description': l10nEntry(
      english:
          'No official "freelance visa" — real pathways, Jusour contact & informal-arrangement risks',
      arabic:
          'لا "تأشيرة عمل حر" رسمية — مسارات حقيقية وجسور ومخاطر الترتيبات غير الرسمية',
      hindi:
          'No official "freelance visa" — real pathways, Jusour contact & informal risks',
      urdu:
          'No official "freelance visa" — real pathways, Jusour contact & informal risks',
    ),

    // ── Leaving Qatar ─────────────────────────────────────────────────────────
    'tool_leaving_qatar_title': l10nEntry(
      english: 'Leaving Qatar',
      arabic: 'مغادرة قطر',
      hindi: 'क़तर छोड़ना',
      urdu: 'قطر چھوڑنا',
    ),
    'tool_leaving_qatar_short_label': l10nEntry(
      english: 'Leaving',
      arabic: 'مغادرة',
      hindi: 'Leaving',
      urdu: 'Leaving',
    ),
    'tool_leaving_qatar_description': l10nEntry(
      english: 'Departure checklist, travel ban check, exit guidance & EOSB owed',
      arabic: 'قائمة مغادرة، فحص حظر السفر، إرشادات الخروج والمستحقات',
      hindi: 'Departure checklist, travel ban check, exit guidance & EOSB owed',
      urdu: 'Departure checklist, travel ban check, exit guidance & EOSB owed',
    ),

    // ── Trip Planner ──────────────────────────────────────────────────────────
    'tool_trip_title': l10nEntry(
      english: 'Trip Planner',
      arabic: 'مخطط الرحلات',
      hindi: 'Trip Planner',
      urdu: 'Trip Planner',
    ),
    'tool_trip_short_label': l10nEntry(
      english: 'Trip Planner',
      arabic: 'مخطط الرحلات',
      hindi: 'यात्रा योजना',
      urdu: 'سفر پلانر',
      malayalam: 'ട്രിപ്പ് പ്ലാനർ',
      nepali: 'यात्रा योजना',
      bengali: 'ট্রিপ প্ল্যানার',
      tamil: 'பயண திட்டம்',
      filipino: 'Trip Planner',
    ),
    'tool_trip_description': l10nEntry(
      english: 'AI-powered Qatar itineraries',
      arabic: 'خطط سفر قطر بالذكاء الاصطناعي',
      hindi: 'AI-powered Qatar itineraries',
      urdu: 'AI-powered Qatar itineraries',
    ),

    // ── Prayer & Mosque ───────────────────────────────────────────────────────
    'tool_prayer_title': l10nEntry(
      english: 'Prayer & Mosque',
      arabic: 'الصلاة والمسجد',
      hindi: 'Prayer & Mosque',
      urdu: 'Prayer & Mosque',
    ),
    'tool_prayer_short_label': l10nEntry(
      english: 'Prayer',
      arabic: 'صلاة',
      hindi: 'नमाज़',
      urdu: 'نماز',
    ),
    'tool_prayer_description': l10nEntry(
      english: 'Prayer times, Qibla & nearby mosques',
      arabic: 'مواقيت الصلاة والقبلة والمساجد القريبة',
      hindi: 'Prayer times, Qibla & nearby mosques',
      urdu: 'Prayer times, Qibla & nearby mosques',
    ),

    // ── End of service pay ────────────────────────────────────────────────────
    'tool_eosb_title': l10nEntry(
      english: 'End of service pay',
      arabic: 'مكافأة نهاية الخدمة',
      hindi: 'सेवा समाप्ति वेतन',
      urdu: 'خدمت کے اختتام پر ادائیگی',
      malayalam: 'സേവന അവസാന പേ',
      nepali: 'सेवा अन्त्य भुक्तानी',
      bengali: 'চাকরি শেষে পেমেন্ট',
      tamil: 'சேவை முடிவு ஊதியம்',
      filipino: 'End of service pay',
    ),
    'tool_eosb_short_label': l10nEntry(
      english: 'EOSB',
      arabic: 'EOSB',
      hindi: 'EOSB',
      urdu: 'EOSB',
    ),
    'tool_eosb_description': l10nEntry(
      english: 'Gratuity and overtime check',
      arabic: 'فحص المكافأة والعمل الإضافي',
      hindi: 'ग्रेच्युटी और ओवरटाइम जाँच',
      urdu: 'گریچuity اور overtime چیک',
      malayalam: 'ഗ്രാച്ചuity, ഓവർടൈം പരിശോധന',
      nepali: 'ग्रेच्युटी र ओभरटाइम जाँच',
      bengali: 'গratuity ও overtime যাচাই',
      tamil: 'Gratuity மற்றும் overtime சரிபார்ப்பு',
      filipino: 'Gratuity and overtime check',
    ),

    // ── Health cover check ──────────────────────────────────────────────────
    'tool_health_insurance_title': l10nEntry(
      english: 'Health cover check',
      arabic: 'فحص التغطية الصحية',
      hindi: 'स्वास्थ्य कवर जाँच',
      urdu: 'صحت کور چیک',
      malayalam: 'ആരോഗ്യ കവർ പരിശോധന',
      nepali: 'स्वास्थ्य कभर जाँच',
      bengali: 'স্বাস্থ্য কভার যাচাই',
      tamil: 'சுகாதார கவர் சரிபார்ப்பு',
      filipino: 'Health cover check',
    ),
    'tool_health_insurance_short_label': l10nEntry(
      english: 'Health Ins.',
      arabic: 'تأمين',
      hindi: 'स्वास्थ्य बीमा',
      urdu: 'صحت انشورنس',
    ),
    'tool_health_insurance_description': l10nEntry(
      english: 'What your insurer must pay',
      arabic: 'ما يجب أن يدفعه تأمينك',
      hindi: 'आपका बीमाकर्ता क्या दे',
      urdu: 'آپ کا انشورر کیا ادا کرے',
      malayalam: 'ഇൻഷurer നൽകേണ്ടത്',
      nepali: 'बीमाकर्ताले तिर्नुपर्ने',
      bengali: 'বীমাকারী কী দেবে',
      tamil: 'காப்பீட்டாளர் செலுத்த வேண்டியது',
      filipino: 'What your insurer must pay',
    ),

    // ── Rent & tenancy ────────────────────────────────────────────────────────
    'tool_tenancy_title': l10nEntry(
      english: 'Rent & tenancy',
      arabic: 'الإيجار والسكن',
      hindi: 'किराया और किरायेदारी',
      urdu: 'کرایہ اور رہائش',
      malayalam: 'വാടകയും താമസവും',
      nepali: 'भाडा र भाडामा',
      bengali: 'ভাড়া ও ভাড়াটে',
      tamil: 'வாடகை & குடியிருப்பு',
      filipino: 'Rent & tenancy',
    ),
    'tool_tenancy_short_label': l10nEntry(
      english: 'Tenancy',
      arabic: 'إيجار',
      hindi: 'किराया',
      urdu: 'کرایہ',
    ),
    'tool_tenancy_description': l10nEntry(
      english: 'Lease and deposit rights',
      arabic: 'حقوق العقد والتأمين',
      hindi: 'लीज और जमानत अधिकार',
      urdu: 'لیز اور ڈپازٹ حقوق',
      malayalam: 'ലീസ്, ഡിപ്പോസിറ്റ് അവകാശങ്ങൾ',
      nepali: 'लीज र धरौटी अधिकार',
      bengali: 'লিজ ও ডিপোজিট অধিকার',
      tamil: 'குத்தகை & வைப்பு உரிமைகள்',
      filipino: 'Lease and deposit rights',
    ),

    // ── Change employer ───────────────────────────────────────────────────────
    'tool_sponsorship_transfer_title': l10nEntry(
      english: 'Change employer',
      arabic: 'تغيير صاحب العمل',
      hindi: 'नियोक्ता बदलें',
      urdu: 'آجر تبدیل کریں',
      malayalam: 'തൊഴിലുടമ മാറ്റം',
      nepali: 'Employer परिवर्तन',
      bengali: 'নিয়োগকর্তা পরিবর্তন',
      tamil: 'Employer மாற்றம்',
      filipino: 'Change employer',
    ),
    'tool_sponsorship_transfer_short_label': l10nEntry(
      english: 'Transfer',
      arabic: 'نقل',
      hindi: 'स्थानांतरण',
      urdu: 'منتقلی',
    ),
    'tool_sponsorship_transfer_description': l10nEntry(
      english: 'NOC and transfer rules',
      arabic: 'قواعد NOC والنقل',
      hindi: 'NOC और स्थानांतरण नियम',
      urdu: 'NOC اور منتقلی کے قواعد',
      malayalam: 'NOC, ട്രാൻസ്ഫർ നിയമങ്ങൾ',
      nepali: 'NOC र transfer नियम',
      bengali: 'NOC ও transfer নিয়ম',
      tamil: 'NOC & transfer விதிகள்',
      filipino: 'NOC and transfer rules',
    ),

    // ── SIM USSD Codes ──────────────────────────────────────────────────────────
    'tool_ussd_title': l10nEntry(
      english: 'SIM USSD Codes',
      arabic: 'رموز USSD',
      hindi: 'SIM USSD Codes',
      urdu: 'SIM USSD Codes',
    ),
    'tool_ussd_short_label': l10nEntry(
      english: 'USSD',
      arabic: 'USSD',
      hindi: 'USSD',
      urdu: 'USSD',
    ),
    'tool_ussd_description': l10nEntry(
      english: 'Ooredoo & Vodafone Qatar codes',
      arabic: 'رموز Ooredoo و Vodafone قطر',
      hindi: 'Ooredoo & Vodafone Qatar codes',
      urdu: 'Ooredoo & Vodafone Qatar codes',
    ),

    // ── Driving & Traffic ─────────────────────────────────────────────────────
    'tool_driving_title': l10nEntry(
      english: 'Driving & Traffic',
      arabic: 'القيادة والمرور',
      hindi: 'Driving & Traffic',
      urdu: 'Driving & Traffic',
    ),
    'tool_driving_short_label': l10nEntry(
      english: 'Driving',
      arabic: 'قيادة',
      hindi: 'ड्राइविंग',
      urdu: 'ڈرائیونگ',
    ),
    'tool_driving_description': l10nEntry(
      english: 'MOI fees, fines guide & theory quiz',
      arabic: 'رسوم وزارة الداخلية والغرامات واختبار النظرية',
      hindi: 'MOI fees, fines guide & theory quiz',
      urdu: 'MOI fees, fines guide & theory quiz',
    ),

    // ── Ramadan (seasonal) ──────────────────────────────────────────────────────
    'tool_ramadan_title': l10nEntry(
      english: 'Ramadan',
      arabic: 'رمضان',
      hindi: 'रमज़ान',
      urdu: 'رمضان',
    ),
    'tool_ramadan_short_label': l10nEntry(
      english: 'Ramadan',
      arabic: 'رمضان',
      hindi: 'रमज़ान',
      urdu: 'رمضان',
    ),
    'tool_ramadan_description': l10nEntry(
      english: 'Prayer times, Qibla, Zakat & Iftar',
      arabic: 'مواقيت الصلاة والقبلة والزكاة والإفطار',
      hindi: 'Prayer times, Qibla, Zakat & Iftar',
      urdu: 'Prayer times, Qibla, Zakat & Iftar',
    ),
  };
}
