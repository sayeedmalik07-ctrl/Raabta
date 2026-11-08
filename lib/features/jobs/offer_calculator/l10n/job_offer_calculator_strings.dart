import 'package:flutter/foundation.dart';
import 'package:raabta/core/l10n/app_locale.dart';
import 'package:raabta/core/l10n/locale_catalog_coverage.dart';
import 'package:raabta/core/l10n/locale_catalog_entry.dart';

abstract final class JobOfferCalculatorStrings {
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

  @visibleForTesting
  static Map<String, Set<String>> get localeCoverageReport =>
      buildLocaleCoverageReport(
        catalog: _catalog,
        supportedLocales: supportedLocales,
      );

  static final _catalog = <String, Map<String, String>>{
    'joc_title': l10nEntry(
      english: 'Job Offer True-Value Calculator',
      arabic: 'حاسبة القيمة الحقيقية لعرض العمل',
      hindi: 'Job Offer True-Value Calculator',
    ),
    'joc_subtitle': l10nEntry(
      english:
          'Enter the numbers from your offer letter yourself. This is a planning tool before you accept — not bank-statement monitoring or a scam verdict.',
      arabic:
          'أدخل الأرقام من خطاب العرض بنفسك. أداة تخطيط قبل القبول — وليست مراقبة كشوف أو حكمًا على الاحتيال.',
      hindi:
          'Offer letter ke numbers khud enter karein. Accept karne se pehle planning tool — bank monitoring ya scam verdict nahi.',
    ),
    'joc_disclaimer': l10nEntry(
      english:
          'Factual figures and ratios only. You decide whether the offer works for you.',
      arabic: 'أرقام ونسب واقعية فقط. أنت تقرر ما إذا كان العرض مناسبًا.',
      hindi: 'Sirf factual figures aur ratios. Offer aapke liye sahi hai ya nahi — aap decide karein.',
    ),
    'joc_section_salary': l10nEntry(
      english: 'Offered gross monthly salary (QAR)',
      arabic: 'الراتب الشهري الإجمالي المعروض (ريال)',
      hindi: 'Offered gross monthly salary (QAR)',
    ),
    'joc_section_accommodation': l10nEntry(
      english: 'Accommodation',
      arabic: 'السكن',
      hindi: 'Accommodation',
    ),
    'joc_section_food': l10nEntry(
      english: 'Food',
      arabic: 'الطعام',
      hindi: 'Food',
    ),
    'joc_benefit_in_kind': l10nEntry(
      english: 'Provided in-kind by employer',
      arabic: 'يوفره صاحب العمل (عينيًا)',
      hindi: 'Employer in-kind provide karta hai',
    ),
    'joc_benefit_cash_allowance': l10nEntry(
      english: 'Paid as monthly cash allowance',
      arabic: 'بدل نقدي شهري',
      hindi: 'Monthly cash allowance',
    ),
    'joc_benefit_not_included': l10nEntry(
      english: 'Not included — I pay my own costs',
      arabic: 'غير مشمول — أتحمل التكلفة',
      hindi: 'Included nahi — khud pay karta hoon',
    ),
    'joc_allowance_amount': l10nEntry(
      english: 'Monthly allowance amount (QAR)',
      arabic: 'مبلغ البدل الشهري (ريال)',
      hindi: 'Monthly allowance (QAR)',
    ),
    'joc_section_recruitment_fee': l10nEntry(
      english: 'Recruitment / agent fee (optional)',
      arabic: 'رسوم التوظيف / الوكيل (اختياري)',
      hindi: 'Recruitment / agent fee (optional)',
    ),
    'joc_recruitment_fee_hint': l10nEntry(
      english: 'Leave at 0 if no fee was requested.',
      arabic: 'اتركه 0 إذا لم تُطلب رسوم.',
      hindi: 'Fee nahi hai to 0 rakhein.',
    ),
    'joc_calculate': l10nEntry(
      english: 'Calculate true value',
      arabic: 'احسب القيمة الحقيقية',
      hindi: 'True value calculate karein',
    ),
    'joc_result_true_value': l10nEntry(
      english: 'True monthly value',
      arabic: 'القيمة الشهرية الحقيقية',
      hindi: 'True monthly value',
    ),
    'joc_result_true_value_body': l10nEntry(
      english:
          'Gross salary plus any cash allowances you entered. In-kind housing or food is not given a cash value here.',
      arabic:
          'الراتب الإجمالي زائد أي بدلات نقدية أدخلتها. السكن أو الطعام العيني لا يُقدّر نقدًا هنا.',
      hindi:
          'Gross salary + jo cash allowance aapne enter ki. In-kind housing/food ka cash value yahan nahi.',
    ),
    'joc_result_minimum_title': l10nEntry(
      english: 'Minimum wage floor comparison',
      arabic: 'مقارنة بحد الحد الأدنى للأجور',
      hindi: 'Minimum wage floor comparison',
    ),
    'joc_result_minimum_applicable': l10nEntry(
      english:
          'Applicable minimum for this structure: QAR {amount}/month ({citation}).',
      arabic:
          'الحد الأدنى لهذا الهيكل: {amount} ريال/شهر ({citation}).',
      hindi:
          'Is structure ke liye minimum: QAR {amount}/month ({citation}).',
    ),
    'joc_result_minimum_below': l10nEntry(
      english:
          'Your entered true value (QAR {value}) is below the applicable minimum (QAR {minimum}). Verify the offer terms against Qatari law before signing.',
      arabic:
          'قيمتك المدخلة ({value} ريال) أقل من الحد الأدنى ({minimum} ريال). تحقق من شروط العرض قبل التوقيع.',
      hindi:
          'Aapki value (QAR {value}) applicable minimum (QAR {minimum}) se kam hai. Sign karne se pehle terms verify karein.',
    ),
    'joc_result_minimum_near': l10nEntry(
      english:
          'Your true value (QAR {value}) is at or near the applicable minimum wage floor (QAR {minimum}). Many roles pay above this legal floor — compare carefully.',
      arabic:
          'قيمتك ({value} ريال) عند أو قريبة من الحد الأدنى ({minimum} ريال). كثير من الوظائف أعلى — قارن بعناية.',
      hindi:
          'True value (QAR {value}) minimum floor (QAR {minimum}) ke paas hai. Kai roles isse upar pay karte hain — carefully compare karein.',
    ),
    'joc_result_minimum_above': l10nEntry(
      english:
          'Your true value (QAR {value}) is above the applicable minimum (QAR {minimum}). This does not mean the offer is “good” — only that it clears this legal floor.',
      arabic:
          'قيمتك ({value} ريال) فوق الحد الأدنى ({minimum} ريال). هذا لا يعني أن العرض «جيد» — فقط أنه يتجاوز هذا الحد.',
      hindi:
          'True value (QAR {value}) minimum (QAR {minimum}) se upar hai. Iska matlab “good offer” nahi — sirf legal floor clear hai.',
    ),
    'joc_result_national_title': l10nEntry(
      english: 'National average context',
      arabic: 'سياق المتوسط الوطني',
      hindi: 'National average context',
    ),
    'joc_data_currency_note': l10nEntry(
      english:
          'Official Qatar wage data is published periodically, not monthly. The survey figure below may be several quarters old — the reporting period is always shown.',
      arabic:
          'بيانات الأجور الرسمية تُنشر دوريًا وليست شهرية. قد يكون رقم المسح قديمًا بعدة أ quarters — تُعرض الفترة دائمًا.',
      hindi:
          'Official Qatar wage data periodically publish hoti hai, monthly nahi. Neeche wala figure kuch quarters purana ho sakta hai — period hamesha dikhaya jata hai.',
    ),
    'joc_result_national_body': l10nEntry(
      english:
          '{period} average: QAR {amount}/month across all sectors and nationalities (age 15+, paid employment) — {citation}. National average across a very wide range of roles; general context only, not a target for any specific job. Your offer is {percent}% of this average.',
      arabic:
          'متوسط {period}: {amount} ريال/شهر لجميع القطاعات والجنسيات — {citation}. متوسط وطني واسع؛ سياق عام فقط. عرضك {percent}% من هذا المتوسط.',
      hindi:
          '{period} average: QAR {amount}/month sab sectors/nationalities — {citation}. Bahut wide range ka national average; sirf context. Aapka offer is average ka {percent}% hai.',
    ),
    'joc_result_fee_title': l10nEntry(
      english: 'Recruitment fee ratio',
      arabic: 'نسبة رسوم التوظيف',
      hindi: 'Recruitment fee ratio',
    ),
    'joc_result_fee_body': l10nEntry(
      english:
          'The fee you entered (QAR {fee}) equals {months} months of this offer\'s true monthly value (QAR {value}). This is a factual ratio only — not a scam verdict.',
      arabic:
          'الرسوم ({fee} ريال) = {months} شهرًا من القيمة الشهرية ({value} ريال). نسبة واقعية فقط — ليس حكمًا على الاحتيال.',
      hindi:
          'Fee (QAR {fee}) = {months} months of true value (QAR {value}). Sirf factual ratio — scam verdict nahi.',
    ),
    'joc_fee_mol_reminder': l10nEntry(
      english:
          'Legitimate employers and licensed agencies in Qatar do not charge candidates fees at any stage of hiring.',
      arabic:
          'أصحاب العمل المشروعون ووكالات التوظيف المرخّصة لا يفرضون رسومًا على المرشحين.',
      hindi:
          'Qatar mein legitimate employers aur licensed agencies hiring ke kisi bhi stage par candidates se fee nahi lete.',
    ),
    'joc_fee_mol_link': l10nEntry(
      english: 'Recruitment safety checklist →',
      arabic: 'قائمة سلامة التوظيف →',
      hindi: 'Recruitment safety checklist →',
    ),
    'joc_entry_title': l10nEntry(
      english: 'Evaluate a job offer',
      arabic: 'قيّم عرض عمل',
      hindi: 'Job offer evaluate karein',
    ),
    'joc_entry_subtitle': l10nEntry(
      english:
          'True-value calculator — enter offer numbers yourself before you accept.',
      arabic: 'حاسبة القيمة الحقيقية — أدخل أرقام العرض قبل القبول.',
      hindi: 'True-value calculator — accept se pehle offer numbers enter karein.',
    ),
    'joc_detail_link': l10nEntry(
      english: 'Check this offer\'s true value →',
      arabic: 'تحقق من القيمة الحقيقية للعرض →',
      hindi: 'Is offer ki true value check karein →',
    ),
    'joc_invalid_salary': l10nEntry(
      english: 'Enter a valid gross monthly salary.',
      arabic: 'أدخل راتبًا شهريًا إجماليًا صالحًا.',
      hindi: 'Valid gross monthly salary enter karein.',
    ),
    'joc_qar_per_month': l10nEntry(
      english: 'QAR {amount}/month',
      arabic: '{amount} ريال/شهر',
      hindi: 'QAR {amount}/month',
    ),
    'joc_amount_hint': l10nEntry(
      english: '0',
      arabic: '0',
      hindi: '0',
      urdu: '0',
      malayalam: '0',
      nepali: '0',
      bengali: '0',
      tamil: '0',
      filipino: '0',
    ),
    'joc_a11y_results_region': l10nEntry(
      english: 'Calculation results',
      arabic: 'نتائج الحساب',
      hindi: 'Calculation results',
      urdu: 'حساب کے نتائج',
      malayalam: 'Calculation results',
      nepali: 'Calculation results',
      bengali: 'Calculation results',
      tamil: 'Calculation results',
      filipino: 'Calculation results',
    ),
  };
}
