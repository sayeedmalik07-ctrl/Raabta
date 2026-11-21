import 'package:raabta/core/l10n/app_locale.dart';

/// Qatar-side real-estate broker verification copy (Part C) — separate from origin-country flow.
abstract final class QatarRealestateVerificationStrings {
  static String t(String key, [String locale = 'English']) {
    final normalized = AppLocale.normalize(locale);
    final map = _catalog[key];
    if (map == null) return key;
    return map[normalized] ?? map['English'] ?? key;
  }

  static const _catalog = <String, Map<String, String>>{
    'section_title': {
      'English': 'Qatar real estate brokers',
      'Arabic': 'وسطاء العقارات في قطر',
    },
    'section_body': {
      'English':
          'Property listings in Qatar may involve licensed brokers regulated by Aqarat (General Authority for Regulating the Real Estate Sector). The Ministry of Justice also publishes updates to its list of licensed real estate brokers. Marketing materials may carry an Ad License QR code — checking for it is a reasonable extra step.',
      'Arabic':
          'قد تتضمن إعلانات العقارات في قطر وسطاء مرخّصين تنظمهم عقارات (الهيئة العامة لتنظيم القطاع العقاري). وزارة العدل تنشر أيضاً تحديثات لقائمة الوسطاء المرخّصين. قد تحمل مواد التسويق رمز QR لترخيص الإعلان — التحقق منه خطوة إضافية معقولة.',
    },
    'aqarat_heading': {
      'English': 'Aqarat — licensed brokers & developers',
      'Arabic': 'عقارات — الوسطاء والمطورون المرخّصون',
    },
    'aqarat_hint': {
      'English':
          'Browse Aqarat\'s official list of licensed real estate developers and brokers in Qatar.',
      'Arabic':
          'تصفّح القائمة الرسمية لدى عقارات للمطورين والوسطاء المرخّصين في قطر.',
    },
    'moj_heading': {
      'English': 'Ministry of Justice — broker register',
      'Arabic': 'وزارة العدل — سجل الوسطاء',
    },
    'moj_hint': {
      'English':
          'The Ministry of Justice publishes updates to its licensed real estate brokers list on its official website (license numbers and municipal jurisdictions).',
      'Arabic':
          'تنشر وزارة العدل تحديثات لقائمة الوسطاء العقاريين المرخّصين على موقعها الرسمي (أرقام التراخيص والبلديات).',
    },
    'ad_license_note': {
      'English':
          'Some property marketing campaigns require an Ad License with a QR code. If a listing shares promotional materials, look for that QR before you pay.',
      'Arabic':
          'بعض حملات تسويق العقارات تتطلب ترخيص إعلان مع رمز QR. إذا شارك الإعلان مواداً ترويجية، ابحث عن هذا الرمز قبل الدفع.',
    },
    'open_aqarat': {
      'English': 'Open Aqarat',
      'Arabic': 'فتح عقارات',
    },
    'open_moj': {
      'English': 'Open Ministry of Justice site',
      'Arabic': 'فتح موقع وزارة العدل',
    },
    'disclaimer': {
      'English':
          'Raabta does not certify, rate, or verify any broker or agency. Confirm licensing directly on the official government sources.',
      'Arabic':
          'رابطة لا تصادق ولا تقيّم ولا تتحقق من أي وسيط أو وكالة. أكّد الترخيص مباشرة على المصادر الحكومية الرسمية.',
    },
    'origin_country_heading': {
      'English': 'Origin-country recruitment agencies',
      'Arabic': 'وكالات التوظيف في بلد المنشأ',
    },
    'origin_country_hint': {
      'English':
          'If you used a recruitment agency before arriving in Qatar, verify it through your home country\'s official portal below.',
      'Arabic':
          'إذا استخدمت وكالة توظيف قبل الوصول إلى قطر، تحقق منها عبر البوابة الرسمية لبلدك أدناه.',
    },
  };
}
