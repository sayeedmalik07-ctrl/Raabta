import 'package:flutter/foundation.dart';
import 'package:raabta/core/l10n/app_locale.dart';
import 'package:raabta/core/l10n/locale_catalog_coverage.dart';
import 'package:raabta/core/l10n/locale_catalog_entry.dart';

/// User-visible TruthPackage assumption/unknown copy for confidence banners.
abstract final class TruthPackageStrings {
  static const supportedLocales = AppLocale.supportedLocales;

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
    'tp_eosb_assumption_0': l10nEntry(
      english:
          'Document OCR text is complete and legible where fields were extracted.',
      arabic: 'نص OCR للمستند كامل وواضح حيث تم استخراج الحقول.',
    ),
    'tp_eosb_assumption_1': l10nEntry(
      english:
          'Extracted salary and date fields reflect the uploaded document as read.',
      arabic:
          'حقول الراتب والتاريخ المستخرجة تعكس المستند المرفوع كما قُرئ.',
    ),
    'tp_eosb_assumption_2': l10nEntry(
      english:
          'Gratuity is estimated on your final basic wage only; housing, transport, and other allowances are excluded unless separately owed.',
      arabic:
          'تُقدَّر المكافأة على الأجر الأساسي النهائي فقط؛ السكن والنقل والبدلات الأخرى مستثناة ما لم تكن مستحقة بشكل منفصل.',
    ),
    'tp_eosb_unknown_0': l10nEntry(
      english:
          'Whether your employer will accept this calculation or offer is not something Raabta can predict.',
      arabic:
          'ما إذا كان صاحب العمل سيقبل هذا الحساب أو العرض ليس من Raabta التنبؤ به.',
    ),
    'tp_eosb_unknown_1': l10nEntry(
      english:
          'Whether additional contract clauses or side agreements exist beyond the uploaded document.',
      arabic:
          'ما إذا كانت هناك بنود عقد إضافية أو اتفاقات جانبية خارج المستند المرفوع.',
    ),
    'tp_eosb_unknown_2': l10nEntry(
      english:
          'Final entitlement may depend on MoL/LDRC findings not available to this app.',
      arabic:
          'قد يعتمد الاستحقاق النهائي على نتائج MoL/LDRC غير المتاحة لهذا التطبيق.',
    ),
    'tp_eosb_unknown_3': l10nEntry(
      english:
          'Whether a court or LDRC would find a dismissal arbitrary or unlawful under Article 64 depends on evidence Raabta cannot assess — any compensation is at court discretion with no fixed formula.',
      arabic:
          'ما إذا كانت المحكمة أو لجنة فض المنازعات العمالية ستجد الفصل تعسفياً أو مخالفاً للقانون بموجب المادة 64 يعتمد على أدلة لا يمكن لـ Raabta تقييمها — أي تعويض يخضع لتقدير المحكمة دون صيغة ثابتة.',
    ),
    'tp_eosb_ot_assumption_0': l10nEntry(
      english:
          'Shift timestamps reflect what was entered or imported — not a full payroll audit.',
      arabic:
          'طوابع الورديات تعكس ما أُدخل أو استُورد — وليس تدقيق رواتب كاملاً.',
    ),
    'tp_eosb_ot_assumption_1': l10nEntry(
      english:
          'Rounding direction is inferred from paired clock-in/clock-out differences.',
      arabic:
          'اتجاه التقريب يُستنتج من فروقات الدخول/الخروج المزدوجة.',
    ),
    'tp_eosb_ot_unknown_0': l10nEntry(
      english:
          'This is a pattern summary from entered shifts — not proof of employer misconduct.',
      arabic:
          'هذا ملخص أنماط من الورديات المدخلة — وليس دليلاً على سوء سلوك صاحب العمل.',
    ),
    'tp_eosb_ot_unknown_1': l10nEntry(
      english:
          'Whether lost minutes qualify as payable overtime depends on contract and MoL review.',
      arabic:
          'ما إذا كانت الدقائق المفقودة overtime قابلة للدفع يعتمد على العقد ومراجعة MoL.',
    ),
    'tp_eosb_ot_unknown_2': l10nEntry(
      english:
          'Employer rounding policies not shown in the summary cannot be verified here.',
      arabic:
          'سياسات التقريب لدى صاحب العمل غير الظاهرة في الملخص لا يمكن التحقق منها هنا.',
    ),
    'tp_hi_policy_assumption_0': l10nEntry(
      english: 'OCR text reflects the uploaded policy document as scanned.',
      arabic: 'نص OCR يعكس وثيقة التأمين المرفوعة كما تم مسحها.',
    ),
    'tp_hi_policy_unknown_0': l10nEntry(
      english:
          'Whether your specific insurer or policy has additional clauses not shown in the document.',
      arabic:
          'ما إذا كان لدى المؤمّن أو الوثيقة بنود إضافية غير ظاهرة في المستند.',
    ),
    'tp_hi_policy_unknown_1': l10nEntry(
      english:
          'Network hospital lists and live benefit limits may differ from the scanned copy.',
      arabic:
          'قوائم المستشفيات الشبكية وحدود المنافع الفعلية قد تختلف عن النسخة الممسوحة.',
    ),
    'tp_hi_policy_unknown_2': l10nEntry(
      english:
          'This summary is not a substitute for the insurer’s official policy wording.',
      arabic:
          'هذا الملخص لا يغني عن صياغة الوثيقة الرسمية لدى المؤمّن.',
    ),
    'tp_hi_dispute_assumption_0': l10nEntry(
      english: 'Step text and user-entered dispute facts are taken as provided.',
      arabic: 'نص الخطوات وحقائق النزاع المدخلة تُؤخذ كما قُدمت.',
    ),
    'tp_hi_dispute_unknown_0': l10nEntry(
      english:
          'Whether your insurer or regulator will overturn the denial cannot be predicted.',
      arabic:
          'ما إذا كان المؤمّن أو الجهة التنظيمية سيلغون الرفض لا يمكن التنبؤ به.',
    ),
    'tp_hi_dispute_unknown_1': l10nEntry(
      english:
          'Response times and outcomes from QCB or QFCRA are not confirmed here.',
      arabic:
          'أوقات الاستجابة ونتائج QCB أو QFCRA غير مؤكدة هنا.',
    ),
    'tp_hi_dispute_unknown_2': l10nEntry(
      english:
          'Medical necessity or clinical details not provided are outside this review.',
      arabic:
          'الضرورة الطبية أو التفاصيل السريرية غير المقدمة خارج نطاق هذا المراجعة.',
    ),
    'tp_hi_crc_unknown_0': l10nEntry(
      english:
          'Raabta does not know your specific policy terms unless you uploaded a document or entered details in Policy Explainer.',
      arabic:
          'Raabta لا تعرف شروط وثيقتك المحددة ما لم ترفع مستنداً أو أدخلت تفاصيل في شرح الوثيقة.',
    ),
    'tp_hi_crc_unknown_1': l10nEntry(
      english:
          'Whether your insurer applies these common exclusion patterns to your policy cannot be stated without your policy schedule.',
      arabic:
          'ما إذا كان مؤمّنك يطبق هذه الأنماط على وثيقتك لا يمكن الجزم به دون جدول الوثيقة.',
    ),
    'tp_hi_crc_unknown_2': l10nEntry(
      english:
          'Network lists, live benefit limits, and sub-limit figures are not confirmed here.',
      arabic:
          'قوائم الشبكة وحدود المنافع الفعلية والحدود الفرعية غير مؤكدة هنا.',
    ),
    'tp_tenancy_assumption_0': l10nEntry(
      english:
          'Lease figures and registration status reflect what you entered in the checker.',
      arabic:
          'أرقام الإيجار وحالة التسجيل تعكس ما أدخلته في الفاحص.',
    ),
    'tp_tenancy_assumption_registration_unknown': l10nEntry(
      english:
          'Lease registration status was not confirmed — checks assume highest uncertainty.',
      arabic:
          'لم يُؤكَّد تسجيل الإيجار — الفحوصات تفترض أعلى درجة من عدم اليقين.',
    ),
    'tp_tenancy_unknown_0': l10nEntry(
      english:
          'Rent-increase caps and specific notice day-counts for eviction are not verified as flat facts in this assistant — confirm notice figures with the Committee.',
      arabic:
          'سقوف زيادة الإيجار وأعداد أيام الإشعار المحددة للإخلاء غير موثقة كحقائق ثابتة — أكد أرقام الإشعار مع اللجنة.',
    ),
    'tp_tenancy_unknown_1': l10nEntry(
      english:
          'Whether your landlord will agree to registration or deposit terms cannot be predicted.',
      arabic:
          'ما إذا كان المالك سيوافق على التسجيل أو شروط الوديعة لا يمكن التنبؤ به.',
    ),
    'tp_tenancy_unknown_2': l10nEntry(
      english:
          'Committee or court outcomes are not something Raabta can confirm in advance.',
      arabic:
          'نتائج اللجنة أو المحكمة ليست مما يمكن لـ Raabta تأكيده مسبقاً.',
    ),
    'tp_sponsorship_assumption_0': l10nEntry(
      english:
          'Readiness dates and notice status reflect what you entered in the checker.',
      arabic:
          'تواريخ الجاهزية وحالة الإشعار تعكس ما أدخلته في الفاحص.',
    ),
    'tp_sponsorship_assumption_notice_unknown': l10nEntry(
      english:
          'Formal notice status was not confirmed — permit window checks use entered dates only.',
      arabic:
          'لم يُؤكَّد الإشعار الرسمي — فحوصات نافذة التصريح تستخدم التواريخ المدخلة فقط.',
    ),
    'tp_sponsorship_unknown_0': l10nEntry(
      english:
          'Whether MOI will approve a transfer or how long processing takes cannot be predicted.',
      arabic:
          'ما إذا وافق MOI على النقل أو مدة المعالجة لا يمكن التنبؤ بها.',
    ),
    'tp_sponsorship_unknown_1': l10nEntry(
      english:
          'Employer cooperation, NOC issuance, and internal HR policies are not visible to Raabta.',
      arabic:
          'تعاون صاحب العمل وإصدار NOC وسياسات HR الداخلية غير مرئية لـ Raabta.',
    ),
    'tp_sponsorship_unknown_2': l10nEntry(
      english:
          'Domestic worker transfers (Law 15/2017) are outside this assistant’s scope.',
      arabic:
          'نقل العمالة المنزلية (القانون 15/2017) خارج نطاق هذا المساعد.',
    ),
  };
}
