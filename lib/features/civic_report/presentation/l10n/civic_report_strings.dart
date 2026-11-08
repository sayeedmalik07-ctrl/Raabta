import 'package:flutter/foundation.dart';
import 'package:raabta/core/l10n/app_locale.dart';
import 'package:raabta/core/l10n/locale_catalog_coverage.dart';
import 'package:raabta/core/l10n/locale_catalog_entry.dart';

/// Report It Right (civic report) — Part A strings.
abstract final class CivicReportStrings {
  static const supportedLocales = AppLocale.supportedLocales;

  static const keysNeedingProfessionalReview = <String>{
    'civic_screen_title',
    'civic_screen_intro',
    'civic_screen_short_notice',
    'civic_section_choose_issue',
    'civic_action_continue',
    'civic_action_copy_template',
    'civic_action_open_website',
    'civic_action_call',
    'civic_action_open_ios_app',
    'civic_action_open_android_app',
    'civic_outcome_delegate_eosb',
    'civic_outcome_delegate_climate',
    'civic_outcome_delegate_scam',
    'civic_outcome_delegate_emergency',
    'civic_outcome_delegate_tenancy',
    'civic_outcome_delegate_consumer',
    'civic_outcome_registry_intro',
    'civic_outcome_manual_intro',
    'civic_outcome_verifying_contacts',
    'civic_outcome_other_unsure',
    'civic_outcome_other_unsure_manual_intro', // TODO-TRANSLATE-REVIEW
    'civic_manual_template_header',
    'civic_manual_template_footer',
    'civic_manual_field_issue',
    'civic_manual_field_location',
    'civic_manual_field_when',
    'civic_manual_field_facts',
    'civic_channel_source_label',
    'civic_ch_municipality_name',
    'civic_ch_municipality_authority',
    'civic_ch_ashghal_name',
    'civic_ch_ashghal_authority',
    'civic_ch_kahramaa_name',
    'civic_ch_kahramaa_authority',
    'civic_issue_street_lighting_label',
    'civic_issue_road_damage_label',
    'civic_issue_drainage_sewage_label',
    'civic_issue_water_leak_supply_label',
    'civic_issue_electricity_fault_label',
    'civic_issue_pests_label',
    'civic_issue_abandoned_vehicle_label',
    'civic_issue_waste_collection_label',
    'civic_issue_workers_accommodation_sanitation_label',
    'civic_issue_labour_employer_dispute_label',
    'civic_issue_heat_outdoor_work_label',
    'civic_issue_scam_fraud_cyber_label',
    'civic_issue_immediate_danger_label',
    'civic_issue_tenancy_lease_deposit_label',
    'civic_issue_consumer_dispute_label',
    'civic_issue_other_unsure_label',
  };

  static String t(String key, [String locale = 'English']) {
    final normalized = AppLocale.normalize(locale);
    final map = _catalog[key];
    if (map == null) return key;
    return map[normalized] ?? map['English'] ?? key;
  }

  @visibleForTesting
  static Map<String, Set<String>> get localeCoverageReport =>
      buildLocaleCoverageReport(
        catalog: _catalog,
        supportedLocales: supportedLocales,
      );

  static final _catalog = <String, Map<String, String>>{
    // TODO-TRANSLATE-REVIEW
    'civic_screen_title': l10nEntry(
      english: 'Report a community problem',
      arabic: 'الإبلاغ عن مشكلة في الحي',
      urdu: 'محلے / کمیونٹی کا مسئلہ رپورٹ کریں',
    ),
    // TODO-TRANSLATE-REVIEW
    'civic_screen_intro': l10nEntry(
      english:
          'Choose what happened. Raabta helps you reach the right existing guidance or a safe draft — it does not submit reports for you.',
      arabic:
          'اختر ما حدث. رابطة توجهك للإرشاد المناسب أو مسودة آمنة — ولا ترسل البلاغات نيابة عنك.',
      urdu:
          'بتائیں کیا ہوا۔ Raabta صحیح رہنمائی یا محفوظ مسودہ دکھاتی ہے — آپ کی طرف سے رپورٹ نہیں بھیجتی۔',
    ),
    // TODO-TRANSLATE-REVIEW
    'civic_screen_short_notice': l10nEntry(
      english:
          'Raabta is not a government service and does not represent any authority.',
      arabic: 'رابطة ليست جهة حكومية ولا تمثل أي سلطة.',
      urdu: 'Raabta سرکاری سروس نہیں اور کسی اتھارٹی کی نمائندگی نہیں کرتی۔',
    ),
    'civic_section_choose_issue': l10nEntry(
      english: 'What type of issue is this?',
      arabic: 'ما نوع المشكلة؟',
      urdu: 'مسئلے کی قسم کیا ہے؟',
    ),
    'civic_action_continue': l10nEntry(
      english: 'Continue',
      arabic: 'متابعة',
      urdu: 'آگے بڑھیں',
    ),
    'civic_action_copy_template': l10nEntry(
      english: 'Copy draft to clipboard',
      arabic: 'نسخ المسودة',
      urdu: 'مسودہ کاپی کریں',
    ),
    'civic_action_open_website': l10nEntry(
      english: 'Open official website',
      arabic: 'فتح الموقع الرسمي',
      urdu: 'سرکاری ویب سائٹ کھولیں',
    ),
    'civic_action_call': l10nEntry(
      english: 'Call verified number',
      arabic: 'اتصال برقم موثّق',
      urdu: 'تصدیق شدہ نمبر پر کال',
    ),
    'civic_action_open_ios_app': l10nEntry(
      english: 'Open on App Store',
      arabic: 'فتح في App Store',
      urdu: 'App Store پر کھولیں',
    ),
    'civic_action_open_android_app': l10nEntry(
      english: 'Open on Google Play',
      arabic: 'فتح في Google Play',
      urdu: 'Google Play پر کھولیں',
    ),
    'civic_outcome_delegate_eosb': l10nEntry(
      english:
          'Wages, EOSB, or employer disputes are handled in the End-of-Service & labour guidance flow — not as a municipal report.',
      arabic:
          'الأجور ومكافأة نهاية الخدمة ونزاعات العمل → إرشاد EOSB — وليس بلاغاً بلدياً.',
      urdu:
          'تنخواہ، EOSB، یا employer dispute → EOSB رہنمائی — municipal report نہیں۔',
    ),
    'civic_outcome_delegate_climate': l10nEntry(
      english:
          'Heat safety and outdoor-work education lives in Climate Navigator. Formal employer or labour complaints should use the labour / EOSB option instead.',
      arabic:
          'سلامة الحر والعمل في الخارج → Climate Navigator. شكاوى العمل الرسمية → خيار EOSB.',
      urdu:
          'گرمی / outdoor کام → Climate Navigator۔ Formal labour شکایت → EOSB آپشن۔',
    ),
    'civic_outcome_delegate_scam': l10nEntry(
      english:
          'Scams, fraud, and cybercrime use the ScamShield incident flow with evidence-safe steps.',
      arabic: 'الاحتيال والجرائم الإلكترونية → مسار ScamShield.',
      urdu: 'دھوکہ دہی / سائبر کرائم → ScamShield incident flow۔',
    ),
    'civic_outcome_delegate_emergency': l10nEntry(
      english:
          'If someone is in immediate danger, use Qatar emergency contacts — the same list used elsewhere in Raabta.',
      arabic: 'خطر فوري → أرقام الطوارئ في قطر (نفس القائمة في رابطة).',
      urdu: 'فوری خطر → قطر emergency contacts (Raabta کی وہی فہرست)۔',
    ),
    'civic_outcome_delegate_tenancy': l10nEntry(
      english:
          'Lease, deposit, and tenancy disputes belong in the Tenancy Truth Engine — not municipal channels.',
      arabic: 'نزاعات الإيجار والتأمين → محرك الإيجار.',
      urdu: 'لیز / deposit / tenancy → Tenancy Truth Engine۔',
    ),
    'civic_outcome_delegate_consumer': l10nEntry(
      english:
          'Product or service disputes with businesses use the MOCI consumer complaint reference.',
      arabic: 'نزاعات المنتجات والخدمات → مرجع شكاوى MOCI.',
      urdu: 'مصنوعات / سروس dispute → MOCI consumer complaint۔',
    ),
    'civic_outcome_registry_intro': l10nEntry(
      english:
          'When verified, official municipality or utility channels appear here. Until then, use the draft below.',
      arabic: 'عند التحقق تظهر القنوات الرسمية هنا. حتى ذلك الحين استخدم المسودة.',
      urdu: 'تصدیق کے بعد سرکاری channels یہاں۔ ابھی مسودہ استعمال کریں۔',
    ),
    'civic_outcome_manual_intro': l10nEntry(
      english:
          'Edit and copy this neutral draft for your own report. Raabta does not send it automatically.',
      arabic: 'حرّر وانسخ المسودة لبلاغك — رابطة لا ترسلها تلقائياً.',
      urdu: 'مسودہ ایڈٹ/کاپی کریں — Raabta خود نہیں بھیجتی۔',
    ),
    'civic_outcome_verifying_contacts': l10nEntry(
      english:
          'Official contact details for this issue type are still being verified. Use the draft below — do not rely on unverified numbers or links.',
      arabic: 'تفاصيل الاتصال الرسمية قيد التحقق. استخدم المسودة — لا تعتمد على روابط غير موثّقة.',
      urdu: 'سرکاری رابطے ابھی تصدیق میں ہیں۔ مسودہ استعمال کریں — غیر تصدیق شدہ links/numbers نہیں۔',
    ),
    'civic_outcome_other_unsure': l10nEntry(
      english:
          'Not sure? Pick the closest category above so Raabta can route you safely — nothing is sent automatically.',
      arabic: 'غير متأكد؟ اختر أقرب فئة — لا يُرسل شيء تلقائياً.',
      urdu: 'یقین نہیں؟ قریب ترین category چنیں — کچھ خود نہیں جاتا۔',
    ),
    // TODO-TRANSLATE-REVIEW
    'civic_outcome_other_unsure_manual_intro': l10nEntry(
      english:
          'If none of the categories fit, edit and copy this neutral draft for your own report. Raabta does not send it automatically.',
      arabic:
          'If none of the categories fit, edit and copy this neutral draft for your own report. Raabta does not send it automatically.',
      hindi:
          'If none of the categories fit, edit and copy this neutral draft for your own report. Raabta does not send it automatically.',
      urdu:
          'If none of the categories fit, edit and copy this neutral draft for your own report. Raabta does not send it automatically.',
    ),
    'civic_manual_template_header': l10nEntry(
      english: 'Draft report (for your use only)',
      arabic: 'مسودة بلاغ (لاستخدامك فقط)',
      urdu: 'مسودہ رپورٹ (صرف آپ کے لیے)',
    ),
    'civic_manual_template_footer': l10nEntry(
      english:
          '— Prepared with Raabta. Not submitted to any authority. Verify official channels before you report.',
      arabic: '— أعدّتها رابطة. لم تُرسل لأي جهة. تحقق من القنوات الرسمية.',
      urdu: '— Raabta سے تیار۔ کسی authority کو نہیں بھیجی۔ سرکاری channels تصدیق کریں۔',
    ),
    'civic_manual_field_issue': l10nEntry(
      english: 'Issue',
      arabic: 'المشكلة',
      urdu: 'مسئلہ',
    ),
    'civic_manual_field_location': l10nEntry(
      english: 'Approximate location',
      arabic: 'الموقع التقريبي',
      urdu: 'تقریباً مقام',
    ),
    'civic_manual_field_when': l10nEntry(
      english: 'Date / time observed',
      arabic: 'التاريخ / الوقت',
      urdu: 'تاریخ / وقت',
    ),
    'civic_manual_field_facts': l10nEntry(
      english: 'Facts observed (no guesses)',
      arabic: 'ملاحظات (بدون تخمين)',
      urdu: 'مشاہدات (اندازے نہیں)',
    ),
    'civic_channel_source_label': l10nEntry(
      english: 'Source',
      arabic: 'المصدر',
      urdu: 'ماخذ',
    ),
    'civic_ch_municipality_name': l10nEntry(
      english: 'Municipality reporting (Oun)',
      arabic: 'بلاغات البلدية (عون)',
      urdu: 'Municipality reporting (Oun)',
    ),
    'civic_ch_municipality_authority': l10nEntry(
      english: 'Ministry of Municipality',
      arabic: 'وزارة البلدية',
      urdu: 'Ministry of Municipality',
    ),
    'civic_ch_ashghal_name': l10nEntry(
      english: 'Ashghal — roads & drainage',
      arabic: 'أشghal — طرق وصرف',
      urdu: 'Ashghal — roads & drainage',
    ),
    'civic_ch_ashghal_authority': l10nEntry(
      english: 'Public Works Authority (Ashghal)',
      arabic: 'هيئة الأشghal',
      urdu: 'Public Works Authority (Ashghal)',
    ),
    'civic_ch_kahramaa_name': l10nEntry(
      english: 'Kahramaa — water & electricity',
      arabic: 'Kahramaa — ماء وكهرباء',
      urdu: 'Kahramaa — water & electricity',
    ),
    'civic_ch_kahramaa_authority': l10nEntry(
      english: 'Qatar General Electricity & Water Corporation',
      arabic: 'Kahramaa',
      urdu: 'Qatar General Electricity & Water Corporation',
    ),
    'civic_issue_street_lighting_label': l10nEntry(
      english: 'Street lighting fault',
      arabic: 'عطل إنارة الشوارع',
      urdu: 'Street lighting fault',
    ),
    'civic_issue_road_damage_label': l10nEntry(
      english: 'Road damage or pothole',
      arabic: 'تلف طريق أو حفرة',
      urdu: 'Road damage or pothole',
    ),
    'civic_issue_drainage_sewage_label': l10nEntry(
      english: 'Drainage / sewage overflow',
      arabic: 'فيض صرف / مجاري',
      urdu: 'Drainage / sewage overflow',
    ),
    'civic_issue_water_leak_supply_label': l10nEntry(
      english: 'Water leak or supply problem',
      arabic: 'تسرب ماء أو انقطاع',
      urdu: 'Water leak or supply problem',
    ),
    'civic_issue_electricity_fault_label': l10nEntry(
      english: 'Electricity fault or outage',
      arabic: 'عطل كهرباء أو انقطاع',
      urdu: 'Electricity fault or outage',
    ),
    'civic_issue_pests_label': l10nEntry(
      english: 'Pests (public area)',
      arabic: 'آفات (منطقة عامة)',
      urdu: 'Pests (public area)',
    ),
    'civic_issue_abandoned_vehicle_label': l10nEntry(
      english: 'Abandoned vehicle',
      arabic: 'مركبة مهجورة',
      urdu: 'Abandoned vehicle',
    ),
    'civic_issue_waste_collection_label': l10nEntry(
      english: 'Waste / collection issue',
      arabic: 'مشكلة نفايات / جمع',
      urdu: 'Waste / collection issue',
    ),
    'civic_issue_workers_accommodation_sanitation_label': l10nEntry(
      english:
          'Sanitation or physical safety at workers’ accommodation (not wages)',
      arabic: 'صحة / سلامة جسدية في سكن العمال (ليس أجوراً)',
      urdu: 'Workers’ accommodation — sanitation/safety (not wages)',
    ),
    'civic_issue_labour_employer_dispute_label': l10nEntry(
      english: 'Labour / employer dispute (wages, contract)',
      arabic: 'نزاع عمل / صاحب عمل (أجور، عقد)',
      urdu: 'Labour / employer dispute',
    ),
    'civic_issue_heat_outdoor_work_label': l10nEntry(
      english: 'Heat / outdoor work concern',
      arabic: 'قلق حر / عمل في الخارج',
      urdu: 'Heat / outdoor work concern',
    ),
    'civic_issue_scam_fraud_cyber_label': l10nEntry(
      english: 'Scam, fraud, or cybercrime',
      arabic: 'احتيال أو جريمة إلكترونية',
      urdu: 'Scam, fraud, or cybercrime',
    ),
    'civic_issue_immediate_danger_label': l10nEntry(
      english: 'Immediate danger to life',
      arabic: 'خطر فوري على الحياة',
      urdu: 'Immediate danger to life',
    ),
    'civic_issue_tenancy_lease_deposit_label': l10nEntry(
      english: 'Tenancy / lease / deposit',
      arabic: 'إيجار / عقد / تأمين',
      urdu: 'Tenancy / lease / deposit',
    ),
    'civic_issue_consumer_dispute_label': l10nEntry(
      english: 'Consumer product or service dispute',
      arabic: 'نزاع منتج أو خدمة استهلاكية',
      urdu: 'Consumer product or service dispute',
    ),
    'civic_issue_other_unsure_label': l10nEntry(
      english: 'Other / not sure',
      arabic: 'أخرى / غير متأكد',
      urdu: 'Other / not sure',
    ),
  };
}
