import 'package:flutter/foundation.dart';
import 'package:raabta/core/l10n/app_locale.dart';
import 'package:raabta/core/l10n/locale_catalog_coverage.dart';

/// Sponsorship / Iqama Transfer Truth Engine — 8-language catalog.
abstract final class SponsorshipTransferStrings {
  static const supportedLocales = AppLocale.supportedLocales;

  static String t(String key, [String locale = 'English']) {
    final normalized = AppLocale.normalize(locale);
    final map = _catalog[key];
    if (map == null) return key;
    return map[normalized] ?? map['English'] ?? key;
  }

  static String format(
    String key,
    String locale,
    Map<String, String> params,
  ) {
    var text = t(key, locale);
    for (final entry in params.entries) {
      text = text.replaceAll('{${entry.key}}', entry.value);
    }
    return text;
  }

  @visibleForTesting
  static Map<String, Set<String>> get localeCoverageReport =>
      buildLocaleCoverageReport(
        catalog: _catalog,
        supportedLocales: supportedLocales,
      );

  static final _catalog = <String, Map<String, String>>{
    'st_title': _e(
      'Change employer',
      'تغيير صاحب العمل',
      'नियोक्ता बदलें',
    ),
    'st_subtitle': _e(
      'NOC and transfer rules',
      'قواعد NOC والنقل',
      'NOC और स्थानांतरण नियम',
    ),
    'st_disclaimer': _e(
      'Informational readiness check only — not legal advice. Verify on Al Meezan / mol.gov.qa / moi.gov.qa. For disputes consider LDRC or a qualified lawyer.',
      'فحص جاهزية إرشادي فقط — ليس استشارة قانونية. تحقق على الميزان / mol.gov.qa / moi.gov.qa.',
      'केवल सूचनात्मक जांच — कानूनी सलाह नहीं। Al Meezan / mol.gov.qa पर verify करें।',
    ),
    'st_law_disambiguation': _e(
      'Law 19/2020 = sponsorship (NOC removal). Law 18/2020 = labour notice period. Law 17/2020 = minimum wage. Three separate 2020 laws.',
      'القانون 19/2020 = الكفالة (إلغاء NOC). القانون 18/2020 = إشعار العمل. القانون 17/2020 = الحد الأدنى للأجور.',
      'Law 19/2020 = sponsorship. Law 18/2020 = notice. Law 17/2020 = minimum wage. अलग कानून।',
    ),
    'st_dashboard_cta': _e(
      'Run Transfer Readiness Check',
      'إجراء فحص الجاهزية',
      'Readiness जांच चलाएं',
    ),
    'st_dashboard_results_cta': _e(
      'View Last Results',
      'عرض آخر النتائج',
      'पिछले परिणाम',
    ),
    'st_visa_guide_link': _e(
      'For Metrash steps & fees → Visa & Documents → Sponsor Transfer',
      'لخطوات Metrash والرسوم → التأشيرة والمستندات → نقل الكفالة',
      'Metrash steps → Visa & Documents → Sponsor Transfer',
    ),
    'st_form_title': _e(
      'Transfer Readiness',
      'جاهزية النقل',
      'स्थानांतरण तैयारी',
    ),
    'st_form_submit': _e(
      'Check My Readiness',
      'افحص جاهزيتي',
      'मेरी तैयारी जांचें',
    ),
    'st_form_permit_expiry': _e(
      'Residence permit / Iqama expiry date',
      'تاريخ انتهاء الإقامة / الإقامة',
      'Residence permit expiry',
    ),
    'st_form_employment_start': _e(
      'Current employment start date',
      'تاريخ بدء العمل الحالي',
      'Current job start date',
    ),
    'st_form_contract_type': _e('Contract type', 'نوع العقد', 'Contract type'),
    'st_form_fixed_term': _e('Fixed-term', 'محدد المدة', 'Fixed-term'),
    'st_form_indefinite': _e('Indefinite', 'غير محدد', 'Indefinite'),
    'st_form_formal_notice': _e(
      'Have you given formal written notice to your current employer?',
      'هل قدمت إشعاراً كتابياً رسمياً لصاحب العمل الحالي؟',
      'Formal written notice given to employer?',
    ),
    'st_form_notice_yes': _e('Yes', 'نعم', 'हाँ'),
    'st_form_notice_no': _e('No', 'لا', 'नहीं'),
    'st_form_notice_unsure': _e('Not sure', 'غير متأكد', 'पक्का नहीं'),
    'st_results_title': _e(
      'Rights & Process Summary',
      'ملخص الحقوق والإجراء',
      'अधिकार और प्रक्रिया सारांश',
    ),
    'st_results_empty': _e(
      'Run the readiness check first to see your notice period and permit timing.',
      'أجرِ فحص الجاهزية أولاً لرؤية مدة الإشعار وتوقيت الإقامة.',
      'पहले readiness check चलाएं।',
    ),
    'st_critical_banner_title': _e(
      'Outside 90-day permit window',
      'خارج نافذة الـ 90 يوماً',
      '90-day window के बाहर',
    ),
    'st_critical_banner_body': _e(
      'MOI Decree 51/2020 allows employer change during permit validity or within 90 days after expiry. Your permit appears outside that verified window — seek official guidance urgently.',
      'مرسوم وزير الداخلية 51/2020 يسمح بالنقل أثناء صلاحية الإقامة أو خلال 90 يوماً من انتهائها. إقامتك تبدو خارج هذه النافذة — اطلب إرشاداً رسمياً.',
      'Decree 51/2020: transfer during validity or 90 days after expiry. आपकी permit उस window के बाहर लगती है।',
    ),
    'st_warning_banner_title': _e(
      'Within 90-day grace window',
      'ضمن نافذة السماح 90 يوماً',
      '90-day grace window में',
    ),
    'st_warning_banner_body': _e(
      'Your permit has expired but may still fall within the 90-day post-expiry window under MOI Decree 51/2020. Complete the transfer promptly via official channels.',
      'انتهت إقامتك لكنها قد تكون ضمن نافذة 90 يوماً بموجب مرسوم 51/2020. أكمل النقل عبر القنوات الرسمية.',
      'Permit expired but may be within 90-day grace (Decree 51/2020). जल्दी official channels से transfer पूरा करें।',
    ),
    'st_status_compliant': _e('On track', 'في المسار', 'On track'),
    'st_status_warning': _e('Attention', 'انتباه', 'Attention'),
    'st_status_critical': _e('Critical', 'حرج', 'Critical'),
    'st_status_needs_verification': _e('Verify', 'تحقق', 'Verify'),
    'st_status_informational': _e('Your rights', 'حقوقك', 'Your rights'),
    'st_cite_law18_notice': _e(
      'Law No. 18 of 2020 (Labour Law termination notice — NOT Law 19/2020)',
      'القانون 18/2020 (إشعار إنهاء العمل — ليس 19/2020)',
      'Law 18/2020 (labour notice — NOT 19/2020)',
    ),
    'st_cite_law14_art39': _e(
      'Article 39, Qatar Labour Law No. 14 of 2004 (probation provisions) — Al Meezan',
      'المادة 39، قانون العمل 14/2004 (أحكام فترة التجربة) — الميزان',
      'Art. 39, Labour Law 14/2004 (probation) — Al Meezan',
    ),
    'st_cite_law19_noc': _e(
      'Law No. 19 of 2020, Art. 21 as amended (sponsorship — NOT labour notice)',
      'القانون 19/2020 م.21 (الكفالة — ليس إشعار العمل)',
      'Law 19/2020 Art.21 (sponsorship — NOT notice)',
    ),
    'st_cite_moi_decree_51': _e(
      'MOI Decree No. (51) of 2020',
      'مرسوم وزير الداخلية رقم (51) لسنة 2020',
      'MOI Decree 51/2020',
    ),
    'st_cite_cabinet_res_6': _e(
      'Cabinet Resolution No. 6 of 2018 (LDRC)',
      'قرار مجلس الوزراء رقم 6 لسنة 2018 (لجان فض المنازعات)',
      'Cabinet Resolution 6/2018 (LDRC)',
    ),
    'st_cite_german_law_journal': _e(
      'German Law Journal / Cambridge Core, March 2024 (dated statistics — not a current guarantee)',
      'German Law Journal / Cambridge Core، مارس 2024 (إحصاءات بتاريخ — ليست ضماناً حالياً)',
      'German Law Journal, Mar 2024 (dated stats — not current guarantee)',
    ),
    'st_check_notice_title': _e(
      'Resignation notice period',
      'مدة إشعار الاستقالة',
      'Resignation notice',
    ),
    'st_check_notice_one_month': _e(
      'Based on your start date, you appear to have under 2 years with this employer — written notice of about 1 month may apply when resigning (Law No. 18 of 2020, labour law — separate from sponsorship Law 19/2020).',
      'بناءً على تاريخ بدئك، يبدو أن مدة عملك أقل من سنتين — قد ينطبق إشعار كتابي بحوالي شهر (القانون 18/2020 — منفصل عن 19/2020).',
      'Under 2 years — ~1 month written notice may apply (Law 18/2020 labour — separate from 19/2020).',
    ),
    'st_check_notice_two_months': _e(
      'Based on your start date, you appear to have 2+ years with this employer — written notice of about 2 months may apply when resigning (Law No. 18 of 2020, labour law — separate from sponsorship Law 19/2020).',
      'بناءً على تاريخ بدئك، يبدو أن مدة عملك سنتان فأكثر — قد ينطبق إشعار كتابي بحوالي شهرين (القانون 18/2020 — منفصل عن 19/2020).',
      '2+ years — ~2 months written notice may apply (Law 18/2020 labour — separate from 19/2020).',
    ),
    'st_check_notice_needs_start': _e(
      'Enter your employment start date to calculate the 1-month vs 2-month notice threshold under Law No. 18 of 2020.',
      'أدخل تاريخ بدء العمل لحساب عتبة شهر مقابل شهرين بموجب القانون 18/2020.',
      'Enter start date for 1 vs 2 month notice under Law 18/2020.',
    ),
    'st_check_notice_action': _e(
      'Give written notice before leaving and keep a dated copy.',
      'قدّم إشعاراً كتابياً قبل المغادرة واحتفظ بنسخة مؤرخة.',
      'Give written notice; keep dated copy.',
    ),
    'st_check_notice_action_needs_start': _e(
      'Add your employment start date on the form.',
      'أضف تاريخ بدء العمل في النموذج.',
      'Add employment start date.',
    ),
    'st_check_notice_probation': _e(
      'You indicated you are still within probation — written notice of 1 month applies when changing employer during probation (Article 39, Labour Law 14/2004). Probation may last up to 6 months maximum and is usable only once with the same employer — verify your contract.',
      'أشرت أنك ما زلت في فترة التجربة — ينطبق إشعار كتابي لمدة شهر عند تغيير صاحب العمل أثناء التجربة (المادة 39، قانون العمل 14/2004). قد تمتد التجربة حتى 6 أشهر كحد أقصى ومرة واحدة فقط مع نفس صاحب العمل — تحقق من عقدك.',
      'Still on probation — 1 month written notice (Art. 39). Max 6 months, once per employer — verify contract.',
    ),
    'st_check_notice_probation_unanswered': _e(
      'You are within the first 6 months of employment — confirm whether you are still on probation. If yes, 1-month notice applies under Article 39 (Labour Law 14/2004), not the standard post-probation 1-month/2-month rule under Law 18/2020.',
      'أنت ضمن أول 6 أشهر — أكد ما إذا كنت ما زلت في التجربة. إن كانت الإجابة نعم، ينطبق إشعار شهر (المادة 39) وليس قاعدة ما بعد التجربة (18/2020).',
      'Within first 6 months — confirm probation status. If yes, 1-month Art. 39 notice applies, not Law 18/2020 post-probation rule.',
    ),
    'st_check_notice_probation_unsure': _e(
      'You are within the first 6 months and are unsure about probation — if still on probation, 1-month notice applies (Article 39). Confirm with HR before relying on the post-probation 1-month/2-month rule (Law 18/2020).',
      'أنت ضمن أول 6 أشهر وغير متأكد من التجربة — إن كنت ما زلت فيها، ينطبق إشعار شهر (المادة 39). أكد مع HR قبل الاعتماد على قاعدة ما بعد التجربة (18/2020).',
      'First 6 months, probation unsure — if still on probation, 1-month Art. 39 notice. Confirm with HR before Law 18/2020 rule.',
    ),
    'st_check_notice_probation_conflict': _e(
      'You indicated probation but your start date is 6+ months ago — statutory probation is up to 6 months only. Post-probation notice under Law 18/2020 may apply instead — confirm your actual notice obligation with HR or MoL.',
      'أشرت التجربة لكن تاريخ بدئك منذ 6+ أشهر — التجربة النظامية حتى 6 أشهر فقط. قد ينطبق إشعار ما بعد التجربة (18/2020) — أكد مع HR أو MoL.',
      'Probation selected but 6+ months employed — statutory probation max 6 months. Law 18/2020 post-probation notice may apply — confirm with HR/MoL.',
    ),
    'st_check_notice_action_probation': _e(
      'Give 1 month written notice before leaving and keep a dated copy.',
      'قدّم إشعاراً كتابياً لمدة شهر واحد واحتفظ بنسخة مؤرخة.',
      'Give 1 month written notice; keep dated copy.',
    ),
    'st_check_notice_action_probation_unanswered': _e(
      'Return to the form and answer the probation question.',
      'عد إلى النموذج وأجب عن سؤال التجربة.',
      'Answer the probation question on the form.',
    ),
    'st_check_notice_action_probation_unsure': _e(
      'Check your contract or HR records to confirm probation status.',
      'تحقق من عقدك أو HR لتأكيد حالة التجربة.',
      'Check contract or HR for probation status.',
    ),
    'st_check_notice_action_probation_conflict': _e(
      'Confirm with HR whether probation ended and which notice rule applies.',
      'أكد مع HR ما إذا انتهت التجربة وأي قاعدة إشعار تنطبق.',
      'Confirm with HR which notice rule applies.',
    ),
    'st_form_probation': _e(
      'Are you still within your probation period?',
      'هل ما زلت في فترة التجربة؟',
      'Still within probation period?',
    ),
    'st_form_probation_yes': _e('Yes', 'نعم', 'Yes'),
    'st_form_probation_no': _e('No', 'لا', 'No'),
    'st_form_probation_unsure': _e('Not sure', 'غير متأكد', 'Not sure'),
    'st_check_formal_notice_no_probation': _e(
      'You have not given formal notice yet. While on probation, Article 39 may require 1 month written notice before changing employer — distinct from the post-probation Law 18/2020 rule.',
      'لم تقدم إشعاراً رسمياً بعد. أثناء التجربة قد تتطلب المادة 39 إشعاراً لمدة شهر — منفصل عن قانون 18/2020.',
      'No formal notice yet — on probation, Art. 39 may require 1 month notice.',
    ),
    'st_check_permit_title': _e(
      'Residence permit timing',
      'توقيت تصريح الإقامة',
      'Permit timing',
    ),
    'st_check_permit_valid': _e(
      'Your permit appears valid. Employer change should be completed during permit validity (MOI Decree 51/2020).',
      'يبدو أن إقامتك سارية. يجب إتمام نقل صاحب العمل أثناء صلاحية الإقامة (مرسوم 51/2020).',
      'Permit valid — complete transfer during validity (Decree 51/2020).',
    ),
    'st_check_permit_grace': _e(
      'Your permit has expired but may still be within the 90-day post-expiry window (MOI Decree 51/2020). Act promptly through Metrash / MoL channels.',
      'انتهت إقامتك لكنها قد تكون ضمن 90 يوماً بعد الانتهاء (مرسوم 51/2020). تصرف بسرعة عبر Metrash / MoL.',
      'Expired but possibly within 90-day window (Decree 51/2020). Act promptly.',
    ),
    'st_check_permit_outside_grace': _e(
      'Your permit expiry appears more than 90 days ago — outside the verified post-expiry window in MOI Decree 51/2020. Seek MOI / MoL guidance before assuming you can transfer.',
      'يبدو أن انتهاء إقامتك منذ أكثر من 90 يوماً — خارج النافذة في مرسوم 51/2020. اطلب إرشاد MOI / MoL.',
      'Expiry 90+ days ago — outside Decree 51/2020 window. Seek MOI/MoL guidance.',
    ),
    'st_check_permit_unknown': _e(
      'Enter your residence permit expiry date to check the 90-day window under MOI Decree 51/2020.',
      'أدخل تاريخ انتهاء الإقامة للتحقق من نافذة 90 يوماً (مرسوم 51/2020).',
      'Enter permit expiry for 90-day window check.',
    ),
    'st_check_permit_action_valid': _e(
      'Plan transfer before permit expires.',
      'خطط للنقل قبل انتهاء الإقامة.',
      'Plan before expiry.',
    ),
    'st_check_permit_action_grace': _e(
      'Do not delay — grace window is limited to 90 days.',
      'لا تتأخر — نافذة السماح 90 يوماً فقط.',
      'Do not delay — 90 days only.',
    ),
    'st_check_permit_action_outside_grace': _e(
      'Contact MOI / MoL or qualified advisor about your status.',
      'اتصل بـ MOI / MoL أو مستشار مؤهل.',
      'Contact MOI/MoL or advisor.',
    ),
    'st_check_permit_action_unknown': _e(
      'Check expiry on your QID / Metrash.',
      'تحقق من الانتهاء على QID / Metrash.',
      'Check QID / Metrash.',
    ),
    'st_check_noc_title': _e(
      'No NOC required',
      'لا حاجة لـ NOC',
      'No NOC required',
    ),
    'st_check_noc_exp': _e(
      'Since 9 September 2020, employer No Objection Certificate (NOC) is not required to change employer for workers covered by these rules (Law No. 19 of 2020 amending Law 21/2015 — sponsorship law, not labour notice Law 18/2020).',
      'منذ 9 سبتمبر 2020، لا يلزم شهادة عدم ممانعة (NOC) لتغيير صاحب العمل (القانون 19/2020 — قانون الكفالة، ليس 18/2020).',
      'Since 9 Sep 2020, NOC not required (Law 19/2020 sponsorship — not Law 18/2020 notice).',
    ),
    'st_check_noc_action': _e(
      'Follow MoLADSA / Metrash employer-change procedures instead of seeking NOC.',
      'اتبع إجراءات MoLADSA / Metrash بدلاً من طلب NOC.',
      'Use MoLADSA / Metrash procedures.',
    ),
    'st_check_formal_notice_title': _e(
      'Formal notice to employer',
      'الإشعار الرسمي لصاحب العمل',
      'Formal notice',
    ),
    'st_check_formal_notice_yes': _e(
      'You indicated formal written notice was given — keep proof dated and signed if possible.',
      'أشرت إلى تقديم إشعار كتابي — احتفظ بإثبات مؤرخ.',
      'Keep dated proof of notice.',
    ),
    'st_check_formal_notice_no': _e(
      'You have not given formal notice yet. Law No. 18 of 2020 may require 1 or 2 months written notice before resignation depending on service length.',
      'لم تقدم إشعاراً رسمياً بعد. قد يتطلب القانون 18/2020 إشعاراً 1 أو 2 شهر.',
      'No formal notice yet — Law 18/2020 may require 1–2 months.',
    ),
    'st_check_formal_notice_unsure': _e(
      'Confirm whether you sent written notice — it affects labour-law obligations under Law 18/2020.',
      'تأكد مما إذا أرسلت إشعاراً كتابياً — يؤثر على التزامات القانون 18/2020.',
      'Confirm written notice status under Law 18/2020.',
    ),
    'st_check_formal_notice_unanswered': _e(
      'Answer the formal-notice question on the form.',
      'أجب عن سؤال الإشعار الرسمي.',
      'Answer formal-notice question.',
    ),
    'st_check_formal_notice_action_yes': _e('Retain copies for any dispute.', 'احتفظ بنسخ.', 'Retain copies.'),
    'st_check_formal_notice_action_no': _e(
      'Draft and send written notice before resigning.',
      'أعد وأرسل إشعاراً كتابياً قبل الاستقالة.',
      'Send written notice before resigning.',
    ),
    'st_check_formal_notice_action_unsure': _e(
      'Check email/HR records or send notice now.',
      'راجع سجلات HR أو أرسل إشعاراً الآن.',
      'Check HR records or send notice.',
    ),
    'st_check_formal_notice_action_unanswered': _e(
      'Return to the form to complete this field.',
      'عد إلى النموذج.',
      'Complete the form.',
    ),
    'st_right_ldrc_title': _e(
      'If employer disputes the transfer',
      'إذا اعترض صاحب العمل على النقل',
      'Employer disputes transfer',
    ),
    'st_right_ldrc_exp': _e(
      'Labour Dispute Resolution Committees (LDRC) were established by Cabinet Resolution No. 6 of 2018 — judge-led panels that can order reinstatement or compensation in wrongful dismissal cases, with appeal to the Court of Appeal.',
      'أنشئت لجان فض منازعات العمل (LDRC) بقرار مجلس الوزراء 6/2018 — panels بقيادة قاضٍ.',
      'LDRC (Cabinet Res. 6/2018) — judge-led panels; appeal to Court of Appeal.',
    ),
    'st_right_ldrc_action': _e(
      'Use MoL complaint channels first; LDRC if dispute escalates.',
      'استخدم قنوات شكاوى MoL أولاً؛ LDRC عند التصعيد.',
      'MoL complaints first; LDRC if needed.',
    ),
    'st_right_stats_title': _e(
      'Verified context (dated)',
      'سياق موثق (بتاريخ)',
      'Verified context (dated)',
    ),
    'st_right_stats_exp': _e(
      'Peer-reviewed data (German Law Journal / Cambridge Core, March 2024): 348,500+ change-of-employer applications approved Nov 2020–Aug 2022; 67% of MoL complaints Oct 2021–Oct 2022 settled in mediation. Dated figures — not a guarantee of your outcome.',
      'بيانات مراجعة الأقران: 348,500+ طلب نقل صاحب عمل (نوف 2020–أغ 2022)؛ 67% تسوية وساطة (أكتو 2021–أكتو 2022). أرقام بتاريخ — ليست ضماناً.',
      '348,500+ approvals Nov 2020–Aug 2022; 67% mediation settlement Oct 2021–Oct 2022 (German Law Journal, Mar 2024). Dated — not your guarantee.',
    ),
    'st_right_stats_action': _e(
      'Use as context only — this app does not predict approval or processing time.',
      'استخدم كسياق فقط — التطبيق لا يتنبأ بالموافقة أو المدة.',
      'Context only — no approval/time prediction.',
    ),
    'st_right_domestic_title': _e(
      'Domestic workers — separate regime',
      'العمالة المنزلية — نظام منفصل',
      'Domestic workers — separate',
    ),
    'st_right_domestic_exp': _e(
      'This tool covers general sponsorship transfer under Law 21/2015 as amended. Domestic workers follow separate procedures under Law No. 15 of 2017 — not covered here.',
      'هذه الأداة للنقل العام. العمالة المنزلية بموجب القانون 15/2017 — غير مشمولة هنا.',
      'Domestic workers: Law 15/2017 separate regime — not covered here.',
    ),
    'st_right_domestic_action': _e(
      'Contact Domestic Workers Department / mol.gov.qa for domestic-worker transfers.',
      'اتصل بقسم العمالة المنزلية / mol.gov.qa.',
      'See mol.gov.qa domestic worker section.',
    ),
    'st_right_art22_title': _e(
      'Deleted Article 22',
      'المادة 22 المحذوفة',
      'Deleted Art. 22',
    ),
    'st_right_art22_exp': _e(
      'Law 19/2020 deleted Article 22 of Law 21/2015 (previously covered workers outside the Labour Law). Raabta does not state further detail beyond verified sources — domestic workers are under Law 15/2017 separately.',
      'حذف القانون 19/2020 المادة 22. لا نذكر تفاصيل غير موثقة — العمالة المنزلية بموجب 15/2017.',
      'Art. 22 deleted in Law 19/2020 reform. No speculation — domestic workers under Law 15/2017.',
    ),
    'st_right_art22_action': _e(
      'Ask the AI assistant for the limited verified answer only.',
      'اسأل المساعد للإجابة المحدودة الموثقة فقط.',
      'Use AI for limited verified answer.',
    ),
    'st_edit_details': _e('Edit details', 'تعديل التفاصيل', 'Edit details'),

    // ── Phase 2: Document checklist ─────────────────────────────────────────
    'st_checklist_title': _e(
      'Transfer Document Checklist',
      'قائمة مستندات النقل',
      'Transfer Document Checklist',
    ),
    'st_checklist_subtitle': _e(
      'Verified preparation items only — this app does not file with MADLSA on your behalf.',
      'عناصر تحضير موثقة فقط — التطبيق لا يقدّم لدى MADLSA نيابة عنك.',
      'Verified prep only — no in-app MADLSA filing.',
    ),
    'st_checklist_verified_section': _e(
      'Verified preparation checklist',
      'قائمة التحضير الموثقة',
      'Verified preparation checklist',
    ),
    'st_checklist_informal_section': _e(
      'Informal checks (not legal requirements)',
      'فحوصات غير رسمية (ليست متطلبات قانونية)',
      'Informal checks (not legal requirements)',
    ),
    'st_checklist_informal_note': _e(
      'These can affect transfers in practice but are NOT confirmed legal rules in this app.',
      'قد تؤثر عملياً لكنها ليست قواعد قانونية مؤكدة في هذا التطبيق.',
      'May affect transfers in practice — not confirmed legal rules here.',
    ),
    'st_checklist_progress': _e(
      '{collected} of {total} marked ready',
      '{collected} من {total} جاهز',
      '{collected} of {total} marked ready',
    ),
    'st_checklist_scan': _e('Scan document', 'مسح المستند', 'Scan document'),
    'st_checklist_open_vault': _e('Document Vault', 'خزنة المستندات', 'Document Vault'),
    'st_doc_previous_contract': _e(
      'Previous / current employer contract',
      'عقد صاحب العمل السابق/الحالي',
      'Previous employer contract',
    ),
    'st_doc_previous_contract_sub': _e(
      'Contract with current sponsor — scan or vault.',
      'عقد الكفيل الحالي — امسح أو خزّن.',
      'Current sponsor contract — scan or vault.',
    ),
    'st_doc_change_employer_form': _e(
      'Change Employer form (Metrash / MoL)',
      'نموذج تغيير صاحب العمل',
      'Change Employer form',
    ),
    'st_doc_change_employer_form_sub': _e(
      'Completed employer-change application — keep dated proof.',
      'طلب تغيير الكفيل المكتمل — احتفظ بإثبات مؤرخ.',
      'Completed change-employer application proof.',
    ),
    'st_doc_formal_notice': _e(
      'Formal written notice to current employer',
      'إشعار كتابي رسمي لصاحب العمل الحالي',
      'Formal written notice to employer',
    ),
    'st_doc_formal_notice_sub': _e(
      'Law 18/2020 notice obligations — keep dated proof (Law 18/2020, not Law 19/2020).',
      'التزامات الإشعار بموجب القانون 18/2020 — احتفظ بإثبات مؤرخ.',
      'Law 18/2020 notice — keep dated proof.',
    ),
    'st_doc_madlsa': _e(
      'MADLSA / MoL notification',
      'إخطار MADLSA / وزارة العمل',
      'MADLSA / MoL notification',
    ),
    'st_doc_madlsa_sub': _e(
      'Notify the concerned department per established procedures (user-initiated — not in-app).',
      'أبلغ الجهة المعنية وفق الإجراءات (من طرفك — ليس داخل التطبيق).',
      'Notify concerned department — user-initiated, not in-app.',
    ),
    'st_doc_new_contract': _e(
      'Signed contract with new employer',
      'عقد موقع مع صاحب العمل الجديد',
      'Signed contract with new employer',
    ),
    'st_doc_new_contract_sub': _e(
      'Valid employment contract for the transfer — scan or store in Document Vault.',
      'عقد عمل ساري للنقل — امسح أو خزّن في Vault.',
      'Valid contract — scan or vault.',
    ),
    'st_doc_permit_qid': _e(
      'Residence permit / QID copies',
      'نسخ الإقامة / QID',
      'Residence permit / QID copies',
    ),
    'st_doc_permit_qid_sub': _e(
      'Current permit and QID — check expiry against the 90-day window (Decree 51/2020).',
      'الإقامة وQID الحالية — تحقق من الانتهاء مقابل 90 يوماً (مرسوم 51/2020).',
      'Check expiry vs 90-day window (Decree 51/2020).',
    ),
    'st_doc_informal_wps': _e(
      'WPS / salary transfer status (informal)',
      'حالة WPS / تحويل الراتب (غير رسمي)',
      'WPS status (informal)',
    ),
    'st_doc_informal_wps_sub': _e(
      'Worth confirming with HR — NOT a verified legal blocker in this app.',
      'يستحق التأكيد مع HR — ليس حاجزاً قانونياً موثقاً هنا.',
      'Confirm with HR — not a verified legal blocker.',
    ),
    'st_doc_informal_fines': _e(
      'Outstanding fines or holds (informal)',
      'غرامات أو حجوزات معلقة (غير رسمي)',
      'Outstanding fines (informal)',
    ),
    'st_doc_informal_fines_sub': _e(
      'May complicate Metrash steps in practice — NOT confirmed as a legal rule here.',
      'قد تعقّد Metrash عملياً — غير مؤكدة كقاعدة قانونية هنا.',
      'May complicate Metrash — not confirmed legal rule.',
    ),
    'st_dashboard_checklist_cta': _e(
      'Document Checklist',
      'قائمة المستندات',
      'Document Checklist',
    ),
    'st_documents_title': _e(
      'Generate Transfer Packet',
      'إنشاء حزمة النقل',
      'Generate Transfer Packet',
    ),
    'st_documents_cta': _e(
      'Generate & Share PDF',
      'إنشاء ومشاركة PDF',
      'Generate & Share PDF',
    ),
    'st_documents_need_check': _e(
      'Run a readiness check first to personalize your packet.',
      'أجرِ فحص الجاهزية أولاً لتخصيص حزمتك.',
      'Run readiness check first to personalize packet.',
    ),
    'st_packet_title': _e(
      'Sponsorship Transfer Preparation Packet',
      'حزمة تجهيز نقل الكفالة',
      'Sponsorship Transfer Preparation Packet',
    ),
    'st_packet_disclaimer': _e(
      'This PDF is a preparation aid only — not legal advice and NOT a filed document. Verify on Al Meezan / mol.gov.qa / moi.gov.qa before acting.',
      'هذا PDF للتجهيز فقط — ليس استشارة قانونية وليس مستنداً مقدّماً. تحقق قبل التصرف.',
      'Preparation aid only — not legal advice, NOT filed. Verify on official portals.',
    ),
    'st_packet_summary_heading': _e(
      'Your details',
      'تفاصيلك',
      'Your details',
    ),
    'st_packet_permit_expiry': _e(
      'Residence permit expiry: {date}',
      'انتهاء الإقامة: {date}',
      'Permit expiry: {date}',
    ),
    'st_packet_employment_start': _e(
      'Employment start: {date}',
      'بدء العمل: {date}',
      'Employment start: {date}',
    ),
    'st_packet_contract_type': _e(
      'Contract type: {type}',
      'نوع العقد: {type}',
      'Contract type: {type}',
    ),
    'st_packet_formal_notice': _e(
      'Formal notice given: {status}',
      'إشعار رسمي: {status}',
      'Formal notice: {status}',
    ),
    'st_packet_readiness_heading': _e(
      'Readiness summary',
      'ملخص الجاهزية',
      'Readiness summary',
    ),
    'st_packet_docs_heading': _e(
      'Document checklist',
      'قائمة المستندات',
      'Document checklist',
    ),
    'st_packet_not_filing_form': _e(
      'This packet does NOT include an auto-drafted MADLSA filing or Metrash submission. Complete official steps separately.',
      'هذه الحزمة لا تتضمن تقديماً تلقائياً لـ MADLSA أو Metrash. أكمل الخطوات الرسمية بشكل منفصل.',
      'NOT an auto-drafted MADLSA filing or Metrash submission. Complete official steps separately.',
    ),
    'st_packet_share_text': _e(
      'Sponsorship transfer preparation packet from Raabta — verify before filing.',
      'حزمة تجهيز نقل الكفالة من رابطة — تحقق قبل التقديم.',
      'Sponsorship transfer preparation packet from Raabta — verify before filing.',
    ),
    'st_dashboard_ai_cta': _e(
      'Ask Transfer Assistant',
      'اسأل مساعد النقل',
      'Ask Transfer Assistant',
    ),

    // ── Phase 2: AI assistant ───────────────────────────────────────────────
    'st_ai_title': _e(
      'Sponsorship Transfer Assistant',
      'مساعد نقل الكفالة',
      'Transfer Assistant',
    ),
    'st_ai_subtitle': _e(
      'Verified Law 19/2020, 18/2020, Decree 51/2020 & LDRC facts only — not legal advice.',
      'حقائق موثقة فقط — ليس استشارة قانونية.',
      'Verified facts only — not legal advice.',
    ),
    'st_ai_ask_hint': _e('Ask about NOC, notice, 90-day window…', 'اسأل عن NOC، الإشعار، 90 يوماً…', 'Ask a question…'),
    'st_ai_send': _e('Send', 'إرسال', 'Send'),
    'st_ai_empty_question': _e('Enter a question first.', 'أدخل سؤالاً أولاً.', 'Enter a question.'),
    'st_ai_unavailable': _e(
      'Assistant unavailable. Try again when online.',
      'المساعد غير متاح. حاول لاحقاً.',
      'Assistant unavailable.',
    ),
    'st_ai_stall_decline': _e(
      'The "70% stall" and "24-hour fixer" claims are not verified by independent sources. Peer-reviewed data (German Law Journal, Mar 2024) reports 348,500+ approvals (Nov 2020–Aug 2022) and 67% mediation settlements (Oct 2021–Oct 2022) — dated figures, not a guarantee for your case.',
      'ادعاءات "70% تعطل" و"24 ساعة" غير موثقة. بيانات مراجعة الأقران: 348,500+ موافقة و67% تسوية وساطة — أرقام بتاريخ وليست ضماناً.',
      '"70% stall" / "24-hour fixer" unverified. Use dated 348,500+ / 67% stats instead — not a guarantee.',
    ),
    'st_ai_domestic_redirect': _e(
      'Domestic worker sponsorship transfer follows separate procedures under Law No. 15 of 2017 — not covered by this general sponsorship tool. See mol.gov.qa domestic worker section or qualified advice.',
      'نقل كفالة العمالة المنزلية بموجب القانون 15/2017 — نظام منفصل. راجع mol.gov.qa.',
      'Domestic workers: Law 15/2017 separate regime — not this tool.',
    ),
    'st_ai_prompt_noc': _e(
      'Why is NOC no longer required?',
      'لماذا لم يعد NOC مطلوباً؟',
      'Why no NOC?',
    ),
    'st_ai_prompt_notice': _e(
      'How much notice do I owe my employer?',
      'كم مدة الإشعار لصاحب العمل؟',
      'How much notice?',
    ),
    'st_ai_prompt_90day': _e(
      'What is the 90-day permit window?',
      'ما هي نافذة 90 يوماً للإقامة؟',
      'What is the 90-day window?',
    ),
    'st_ai_prompt_employer_refuses': _e(
      'What if my employer refuses the transfer?',
      'ماذا لو رفض صاحب العمل النقل؟',
      'Employer refuses transfer?',
    ),
    'st_hub_explore': _e('Explore', 'استكشف', 'Explore'),
    'st_scenarios': _e('What-if scenarios', 'سيناريوهات ماذا لو', 'What-if scenarios'),
    'st_scenarios_desc': _e(
      'Compare hypothetical transfer readiness outcomes side by side. These are not saved as real checks.',
      'قارن نتائج جاهزية النقل الافتراضية. لا تُحفظ كفحوصات حقيقية.',
      'Compare hypothetical outcomes. Not saved as real checks.',
    ),
    'st_scenarios_empty_title': _e(
      'Add transfer details first',
      'أضف تفاصيل النقل أولاً',
      'Add transfer details first',
    ),
    'st_scenarios_empty_desc': _e(
      'Enter your permit and employment dates to explore what-if scenarios.',
      'أدخل تواريخ الإقامة والعمل لاستكشاف السيناريوهات.',
      'Enter permit and employment dates first.',
    ),
    'st_scenario_base': _e('Your current case', 'حالتك الحالية', 'Your current case'),
    'st_scenario_hypothetical': _e(
      'Hypothetical only — not a saved readiness check',
      'افتراضي فقط — ليس فحص جاهزية محفوظ',
      'Hypothetical only — not saved',
    ),
    'st_scenario_tap_expand': _e('Tap to expand details', 'اضغط للتفاصيل', 'Tap to expand'),
    'st_scenario_permit_valid_title': _e(
      'If your permit is still valid',
      'إذا كانت إقامتك سارية',
      'If permit still valid',
    ),
    'st_scenario_permit_valid_desc': _e(
      'Permit expiry 60 days in the future',
      'انتهاء الإقامة بعد 60 يوماً',
      'Permit expiry 60 days ahead',
    ),
    'st_scenario_permit_grace_title': _e(
      'If you wait past expiry (grace window)',
      'إذا انتظرت بعد الانتهاء (نافذة السماح)',
      'Past expiry — grace window',
    ),
    'st_scenario_permit_grace_desc': _e(
      'Permit expired 45 days ago — inside 90-day grace',
      'انتهت الإقامة منذ 45 يوماً — ضمن 90 يوم',
      'Expired 45 days ago — in grace',
    ),
    'st_scenario_permit_outside_title': _e(
      'If you wait past the 90-day grace window',
      'إذا تجاوزت نافذة 90 يوم',
      'Past 90-day grace window',
    ),
    'st_scenario_permit_outside_desc': _e(
      'Permit expired 100 days ago — outside grace',
      'انتهت الإقامة منذ 100 يوم — خارج السماح',
      'Expired 100 days ago — outside grace',
    ),
    'st_scenario_formal_notice_no_title': _e(
      'If formal notice was not given',
      'إذا لم يُقدَّم إشعار رسمي',
      'If no formal notice',
    ),
    'st_scenario_formal_notice_no_desc': _e(
      'Employer consent / notice path may be affected',
      'مسار موافقة صاحب العمل قد يتأثر',
      'Notice/consent path affected',
    ),
    'st_scenario_start_30_title': _e(
      'If you start the process in 30 days',
      'إذا بدأت العملية بعد 30 يوماً',
      'Start in 30 days',
    ),
    'st_scenario_start_30_desc': _e(
      'Same details, evaluated 30 days from today',
      'نفس البيانات بعد 30 يوماً من اليوم',
      'Evaluated 30 days from today',
    ),
    'st_scenario_start_60_title': _e(
      'If you start the process in 60 days',
      'إذا بدأت العملية بعد 60 يوماً',
      'Start in 60 days',
    ),
    'st_scenario_start_60_desc': _e(
      'Same details, evaluated 60 days from today',
      'نفس البيانات بعد 60 يوماً من اليوم',
      'Evaluated 60 days from today',
    ),
    'st_scenario_diff_permit_valid': _e(
      'Permit window: valid',
      'نافذة الإقامة: سارية',
      'Permit: valid',
    ),
    'st_scenario_diff_permit_graceWindow': _e(
      'Permit window: grace period',
      'نافذة الإقامة: فترة السماح',
      'Permit: grace period',
    ),
    'st_scenario_diff_permit_outsideGrace': _e(
      'Permit window: outside grace',
      'نافذة الإقامة: خارج السماح',
      'Permit: outside grace',
    ),
    'st_scenario_diff_permit_unknown': _e(
      'Permit window: unknown',
      'نافذة الإقامة: غير معروف',
      'Permit: unknown',
    ),
    'st_scenario_diff_critical_added': _e(
      'Critical issue appears',
      'تظهر مشكلة حرجة',
      'Critical issue appears',
    ),
    'st_scenario_diff_critical_removed': _e(
      'Critical issue removed',
      'تزول المشكلة الحرجة',
      'Critical issue removed',
    ),
    'st_scenario_diff_warning_added': _e(
      'Warning appears',
      'يظهر تحذير',
      'Warning appears',
    ),
    'st_scenario_diff_warning_removed': _e(
      'Warning removed',
      'يزول التحذير',
      'Warning removed',
    ),
    'st_scenario_diff_status_changed': _e(
      'Status changed vs current',
      'تغيرت الحالة عن الحالية',
      'Status changed',
    ),
    'st_history': _e('Check history', 'سجل الفحوصات', 'Check history'),
    'st_empty_history': _e('No past checks yet', 'لا فحوصات سابقة', 'No past checks'),
    'st_empty_history_desc': _e(
      'Run a transfer readiness check to build your history.',
      'أجرِ فحص جاهزية النقل لبناء السجل.',
      'Run a check to build history.',
    ),
    'st_history_error': _e(
      'Could not load history',
      'تعذر تحميل السجل',
      'Could not load history',
    ),
    'st_result_summary_heading': _e(
      'Transfer readiness',
      'جاهزية النقل',
      'Transfer readiness',
    ),
    'st_history_summary_critical': _e(
      'Critical issue flagged',
      'مشكلة حرجة',
      'Critical issue flagged',
    ),
    'st_history_summary_warning': _e(
      'Warning flagged',
      'تحذير',
      'Warning flagged',
    ),
    'st_history_summary_compliant': _e(
      'Ready — no critical issues',
      'جاهز — لا مشاكل حرجة',
      'Ready — no critical issues',
    ),
    'st_history_permit_valid': _e('Permit valid', 'إقامة سارية', 'Permit valid'),
    'st_history_permit_grace': _e('Grace window', 'نافذة السماح', 'Grace window'),
    'st_history_permit_outside_grace': _e(
      'Outside grace',
      'خارج السماح',
      'Outside grace',
    ),
    'st_employer_cost_section_title': _e(
      'Employer costs during transfer',
      'تكاليف أصحاب العمل أثناء النقل',
      'Employer costs during transfer',
    ),
    'st_employer_cost_section_subtitle': _e(
      'Context on costs between employers — not deducted from your pay.',
      'سياق التكاليف بين أصحاب العمل — لا تُخصم من راتبك.',
      'Costs between employers — not from your pay.',
    ),
    'st_employer_cost_recruitment_known': _e(
      'When you change employers, your new employer may compensate your current employer for a portion of recruitment costs and your one-way air ticket, at an amount agreed between the two employers — capped by law at no more than 2 months of your current basic wage. This is a cost between employers, not something deducted from your pay.',
      'عند تغيير صاحب العمل، قد يعوّض صاحب العمل الجديد الحالي عن جزء من تكاليف الت recruitment وتذكرة السفر ذات الاتجاه، بمبلغ يتفق عليه الطرفان — بحد أقصى نظامي لا يتجاوز شهرين من أجرك الأساسي الحالي. هذه تكلفة بين أصحاب العمل وليست خصماً من راتبك.',
      'New employer may compensate current employer for recruitment + one-way ticket — amount agreed between them, capped at 2 months current basic wage. Cost between employers, not from your pay.',
    ),
    'st_employer_cost_return_flight_known': _e(
      'Upon termination, the employer bears the cost of returning you to the place from which you were recruited, or another place agreed between you and the employer (Article 57, Labour Law 14/2004). If you join another employer in Qatar before leaving, that return obligation shifts to the new employer.',
      'عند انتهاء علاقة العمل، يتحمل صاحب العمل تكلفة إعادتك إلى المكان الذي جُندت منه، أو إلى مكان آخر يتفق عليه الطرفان (المادة 57، قانون العمل 14/2004). إذا التحقت بصاحب عمل آخر في قطر قبل المغادرة، ينتقل التزام إعادة السفر إلى صاحب العمل الجديد.',
      'On termination, employer bears return travel cost to recruitment origin or agreed place (Art. 57). If you join another employer in Qatar before leaving, obligation shifts to the new employer.',
    ),
    'st_employer_cost_delay_possible': _e(
      'Understanding these employer-to-employer costs may help explain (though never excuse) delays some employers cause during the transfer process.',
      'فهم هذه التكاليف بين أصحاب العمل قد يفسر (دون أن يبرر) تأخيرات يسببها بعض أصحاب العمل أثناء النقل.',
      'May help explain (never excuse) employer delays during transfer.',
    ),
    'st_employer_cost_unknown': _e(
      'The actual compensation amount agreed between your current and new employer is not visible to Raabta — only the statutory cap and rule are verified here.',
      'المبلغ الفعلي المتفق عليه بين صاحبي العمل غير ظاهر لـ Raabta — فقط الحد النظامي والقاعدة موثقان هنا.',
      'Actual agreed amount between employers is not visible to Raabta — only rule and cap verified.',
    ),

    // ── QID cancellation emergency (distinct from voluntary transfer flow) ──
    'st_qid_cancel_urgency_badge': _e(
      'URGENT — different from a planned transfer',
      'عاجل — مختلف عن نقل مخطّط',
      'URGENT — not a planned transfer',
    ),
    'st_qid_cancel_section_title': _e(
      'QID cancelled — what to do now',
      'إلغاء QID — ماذا تفعل الآن',
      'QID cancelled — what to do now',
    ),
    'st_qid_cancel_section_subtitle': _e(
      'This section is for when your residence permit (QID) has already been cancelled — company closure, retaliation, or another unexpected reason. It is NOT the same as using the readiness check below to plan a voluntary employer change while your permit is still valid.',
      'هذا القسم عندما أُلغيت إقامتك (QID) فعلياً — إغلاق شركة، انتقام، أو سبب غير متوقع. ليس نفس فحص الجاهزية أدناه للنقل الطوعي بينما الإقامة سارية.',
      'For when QID is already cancelled — not the voluntary transfer readiness check below.',
    ),
    'st_qid_cancel_countdown_heading': _e(
      'The 14-day countdown',
      'مهلة 14 يوماً',
      'The 14-day countdown',
    ),
    'st_qid_cancel_countdown_known': _e(
      'If your QID has been cancelled, you generally have 14 days to either leave Qatar, transfer to a new sponsor, or otherwise regularize your status. After this period, fines of QAR 10 per day may apply. If you\'re unsure why your QID was cancelled or believe it was done improperly, act quickly — don\'t wait to find out later.',
      'إذا أُلغي QID، لديك عموماً 14 يوماً للمغادرة أو النقل لكفيل جديد أو تنظيم وضعك. بعدها قد تُفرض غرامة 10 ر.ق يومياً. إن لم تكن متأكداً من السبب أو ظننت الإلغاء غير مشروع، تصرف بسرعة.',
      'Generally 14 days to leave, transfer, or regularize; then QAR 10/day fines may apply. Act quickly if reason is unclear or improper.',
    ),
    'st_qid_cancel_countdown_action': _e(
      'Action: Check your QID status immediately yourself through the official Metrash app or MOI e-services portal — Raabta cannot see your live QID status. If the cancellation seems improper or retaliatory, contact MADLSA on 16008 (24/7) and keep any evidence you have.',
      'إجراء: تحقق من حالة QID فوراً عبر تطبيق Metrash أو بوابة MOI — Raabta لا ترى حالتك الحية. إن بدا الإلغاء غير مشروع، اتصل بـ MADLSA 16008 (24/7) واحتفظ بأدلتك.',
      'Check QID status via Metrash/MOI yourself — Raabta cannot. Call MADLSA 16008 if improper/retaliatory.',
    ),
    'st_qid_cancel_countdown_unknown': _e(
      'Unknown: The specific reason your QID was cancelled in your case — only official channels (Metrash/MOI, MADLSA 16008) can confirm that. Retaliatory cancellation, company closure, and routine end-of-contract cancellation can have different practical next steps.',
      'غير معروف: سبب إلغاء QID في حالتك — فقط القنوات الرسمية (Metrash/MOI، MADLSA 16008) تؤكده. الإلغاء الانتقامي وإغلاق الشركة ونهاية العقد الروتينية قد تختلف خطواتها.',
      'Unknown: Your specific cancellation reason — confirm via Metrash/MOI or MADLSA 16008. Scenarios differ.',
    ),
    'st_qid_cancel_active_transfer_early_title': _e(
      'Protection during an active transfer application',
      'الحماية أثناء طلب نقل نشط',
      'Protection during active transfer',
    ),
    'st_qid_cancel_active_transfer_heading': _e(
      'Protection during an active transfer application',
      'الحماية أثناء طلب نقل نشط',
      'Protection during active transfer',
    ),
    'st_qid_cancel_active_transfer_known': _e(
      'Once you have formally submitted a job-change/transfer application through the official electronic system, your current employer is not permitted to cancel your QID or file a false absconding report against you during that process.',
      'بمجرد تقديم طلب تغيير/نقل وظيفة رسمياً عبر النظام الإلكتروني، لا يجوز لصاحب العمل الحالي إلغاء QID أو تقديم بلاغ هروب كاذب أثناء المعالجة.',
      'After formal transfer application submitted, employer should not cancel QID or file false absconding during process.',
    ),
    'st_qid_cancel_active_transfer_action': _e(
      'If this happens anyway, it may constitute retaliation — contact MADLSA (16008) immediately and keep a record of your submitted application (reference number, screenshots, SMS confirmations).',
      'إن حدث ذلك، قد يكون انتقاماً — اتصل بـ MADLSA (16008) فوراً واحتفظ بسجل طلبك (رقم مرجع، لقطات، رسائل).',
      'If it happens anyway, call MADLSA 16008 and keep application proof.',
    ),
    'st_qid_cancel_employer_closure_heading': _e(
      'Employer disappeared or company closed',
      'اختفاء صاحب العمل أو إغلاق الشركة',
      'Employer gone / company closed',
    ),
    'st_qid_cancel_employer_closure_known': _e(
      'If your employer\'s company has closed or become unreachable and you haven\'t been paid or had your status addressed, this is a recognized situation. A MADLSA complaint can still be processed even if the employer is unresponsive — it may support wage or end-of-service claims through the Labour Dispute Resolution Committee. QID reactivation is possible in some cases, particularly for retaliatory or improper cancellations — MADLSA can coordinate with the Ministry of Interior.',
      'إذا أُغلقت الشركة أو أصبح صاحب العمل غير متاح ولم تُدفع أو يُنظّم وضعك، هذا وضع معروف. يمكن معالجة شكوى MADLSA حتى دون استجابة صاحب العمل — وقد تدعم مطالبات الأجور/EOSB عبر LDRC. إعادة تفعيل QID ممكنة في بعض الحالات — MADLSA تنسق مع MOI.',
      'Company closed/unreachable: MADLSA complaint still possible; LDRC for wages/EOSB; QID reactivation sometimes possible via MADLSA/MOI.',
    ),
    'st_qid_cancel_employer_closure_action': _e(
      'Action: File a complaint with MADLSA (16008 or mol.gov.qa Unified Complaints Portal) even if the employer is gone. Keep payslips, contract, and any cancellation notice. If a Committee ruling is issued but there is no employer left to pay, see EOSB guidance on the Workers\' Support and Insurance Fund — Raabta does not duplicate that process here.',
      'إجراء: قدّم شكوى لـ MADLSA (16008 أو mol.gov.qa) حتى لو غاب صاحب العمل. احتفظ بالرواتب والعقد وإشعار الإلغاء. إن صدر حكم LDRC بلا صاحب عمل للدفع، راجع إرشادات EOSB لصندوق دعم العمال — دون تكرار هنا.',
      'File MADLSA complaint (16008/mol.gov.qa); keep documents. For unpaid LDRC ruling, see EOSB WSIF guidance.',
    ),
    'st_qid_cancel_scenarios_note': _e(
      'Possible: Next steps differ — retaliatory cancellation during a dispute, abandonment after company closure, and routine end-of-contract cancellation are not identical situations. Do not assume one generic checklist fits every case.',
      'محتمل: الخطوات تختلف — إلغاء انتقامي، إغلاق شركة، ونهاية عقد روتينية ليست حالات متطابقة. لا تفترض قائمة واحدة لكل الحالات.',
      'Possible: Retaliatory, company closure, and routine end-of-contract paths differ — no one-size checklist.',
    ),
    'st_qid_cancel_wsif_link': _e(
      'EOSB → Legal warnings — Workers\' Support and Insurance Fund escalation',
      'EOSB → تحذيرات قانونية — صندوق دعم العمال والتأمين',
      'EOSB → Legal warnings — WSIF escalation',
    ),
    'st_qid_cancel_disclaimer': _e(
      'Informational guidance only — not legal advice. Raabta does not check your QID status or file complaints for you.',
      'إرشاد فقط — ليس استشارة قانونية. Raabta لا تتحقق من QID ولا تقدّم شكاوى نيابة عنك.',
      'Informational only. Raabta does not check QID or file for you.',
    ),
  };
}

Map<String, String> _e(String en, String ar, String hi) => {
      'English': en,
      'Arabic': ar,
      'Hindi': hi,
      'Urdu': hi,
      'Malayalam': en,
      'Nepali': en,
      'Bengali': hi,
      'Filipino': en,
    };
