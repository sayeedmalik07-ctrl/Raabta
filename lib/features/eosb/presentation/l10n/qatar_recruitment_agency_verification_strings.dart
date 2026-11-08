import 'package:raabta/core/l10n/app_locale.dart';

/// Qatar-side MOL recruitment-agency verification copy — separate from origin-country flow.
abstract final class QatarRecruitmentAgencyVerificationStrings {
  static String t(String key, [String locale = 'English']) {
    final normalized = AppLocale.normalize(locale);
    final map = _catalog[key];
    if (map == null) return key;
    return map[normalized] ?? map['English'] ?? key;
  }

  static const _catalog = <String, Map<String, String>>{
    'section_title': {
      'English': 'Qatar licensed recruitment agencies',
      'Arabic': 'وكالات التوظيف المرخّصة في قطر',
    },
    'section_body': {
      'English':
          'Qatar\'s Ministry of Labour publishes an official public list of licensed recruitment agencies. The Ministry has warned that unlicensed offices sometimes impersonate licensed agencies on social media — check the official list before paying any agency or agreeing to any arrangement.',
      'Arabic':
          'تنشر وزارة العمل في قطر قائمة رسمية عامة لوكالات التوظيف المرخّصة. حذّرت الوزارة من أن مكاتب غير مرخّصة قد تنتحل هوية وكالات مرخّصة على وسائل التواصل — تحقق من القائمة الرسمية قبل دفع أي وكالة أو الموافقة على أي ترتيب.',
    },
    'open_mol_list': {
      'English': 'Open MOL agency list',
      'Arabic': 'فتح قائمة الوزارة',
    },
    'disclaimer': {
      'English':
          'Raabta does not certify, rate, or verify any recruitment agency. Confirm licensing directly on the official Ministry of Labour source.',
      'Arabic':
          'رابطة لا تصادق ولا تقيّم ولا تتحقق من أي وكالة توظيف. أكّد الترخيص مباشرة على المصدر الرسمي لوزارة العمل.',
    },
  };
}
