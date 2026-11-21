import 'package:flutter/foundation.dart';
import 'package:raabta/core/l10n/app_locale.dart';
import 'package:raabta/core/l10n/locale_catalog_coverage.dart';

/// Tenancy / Housing Rights Truth Engine — 8-language catalog.
abstract final class TenancyStrings {
  static const supportedLocales = AppLocale.supportedLocales;

  static String t(String key, [String locale = 'English']) {
    final normalized = AppLocale.normalize(locale);
    final map = _catalog[key];
    if (map == null) return key;
    var text = map[normalized] ?? map['English'] ?? key;
    return text;
  }

  /// Replace `{name}` placeholders in catalog strings.
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
    'tenancy_title': _e(
      'Rent & tenancy',
      'الإيجار والسكن',
      'किराया और किरायेदारी',
    ),
    'tenancy_subtitle': _e(
      'Lease and deposit rights',
      'حقوق العقد والتأمين',
      'लीज और जमानत अधिकार',
    ),
    'tenancy_disclaimer': _e(
      'Informational compliance check only — not legal advice. Law 8/2026 amends tenancy; Law 9/2026 amends labour (EOSB) — separate laws. Verify on Al Meezan. For disputes contact the Rental Dispute Committee or a qualified lawyer.',
      'فحص إرشادي فقط — ليس استشارة قانونية. القانون 8/2026 يعدّل الإيجار؛ القانون 9/2026 يعدّل العمل (EOSB) — قوانين منفصلة. تحقق على الميزان.',
      'केवल सूचनात्मक जांच — कानूनी सलाह नहीं। Law 8/2026 tenancy; Law 9/2026 labour (EOSB) — अलग कानून।',
    ),
    'tenancy_law_disambiguation': _e(
      'Law 8/2026 = property leasing. Law 9/2026 = labour law (EOSB). These are unrelated amendments.',
      'القانون 8/2026 = إيجار العقارات. القانون 9/2026 = قانون العمل (EOSB). تعديلات منفصلة.',
      'Law 8/2026 = leasing. Law 9/2026 = labour (EOSB). अलग संशोधन।',
    ),
    'tenancy_dashboard_cta': _e(
      'Check My Lease',
      'افحص عقدي',
      'मेरा लीज जांचें',
    ),
    'tenancy_dashboard_results_cta': _e(
      'View Last Results',
      'عرض آخر النتائج',
      'पिछले परिणाम देखें',
    ),
    'tenancy_form_title': _e(
      'Lease Details',
      'تفاصيل عقد الإيجار',
      'लीज विवरण',
    ),
    'tenancy_form_submit': _e(
      'Run Compliance Check',
      'إجراء فحص الامتثال',
      'अनुपालन जांच चलाएं',
    ),
    'tenancy_form_rent': _e('Monthly rent (QAR)', 'الإيجار الشهري (ر.ق)', 'मासिक किराया (QAR)'),
    'tenancy_form_deposit': _e('Security deposit (QAR)', 'وديعة التأمين (ر.ق)', 'सुरक्षा जमा (QAR)'),
    'tenancy_form_landlord': _e('Landlord name (optional)', 'اسم المالك (اختياري)', 'मकान मालिक (वैकल्पिक)'),
    'tenancy_form_start': _e('Lease start date', 'تاريخ بداية العقد', 'लीज शुरू तिथि'),
    'tenancy_form_end': _e('Lease end date (optional)', 'تاريخ نهاية العقد (اختياري)', 'लीज समाप्ति (वैकल्पिक)'),
    'tenancy_form_property_type': _e('Property type', 'نوع العقار', 'संपत्ति प्रकार'),
    'tenancy_form_residential': _e('Residential', 'سكني', 'आवासीय'),
    'tenancy_form_commercial': _e('Commercial', 'تجاري', 'व्यावसायिक'),
    'tenancy_form_registration': _e(
      'Registered at the Municipality Rental Office?',
      'مسجّل في مكتب الإيجار البلدي؟',
      'Municipality Rental Office में पंजीकृत?',
    ),
    'tenancy_form_reg_yes': _e('Yes', 'نعم', 'हाँ'),
    'tenancy_form_reg_no': _e('No', 'لا', 'नहीं'),
    'tenancy_form_reg_unsure': _e('Not sure', 'غير متأكد', 'पक्का नहीं'),
    'tenancy_form_vault': _e(
      'Lease scanned to Document Vault?',
      'هل تم مسح العقد إلى الخزنة؟',
      'Document Vault में स्कैन?',
    ),
    'tenancy_form_committee_decision': _e(
      'Committee decision date (optional — for appeal deadline)',
      'تاريخ قرار اللجنة (اختياري — لموعد الاستئناف)',
      'Committee निर्णय तिथि (वैकल्पिक — अपील समय सीमा)',
    ),
    'tenancy_form_pick_date': _e('Select date', 'اختر التاريخ', 'तिथि चुनें'),
    'tenancy_form_clear_date': _e('Clear', 'مسح', 'हटाएँ'),
    'tenancy_results_title': _e('Compliance Summary', 'ملخص الامتثال', 'अनुपालन सारांश'),
    'tenancy_results_empty': _e(
      'Enter your lease details to see registration and deposit compliance.',
      'أدخل تفاصيل عقدك لعرض امتثال التسجيل والوديعة.',
      'पंजीकरण और जमा जांच के लिए लीज विवरण दर्ज करें।',
    ),
    'tenancy_critical_banner_title': _e(
      'Unregistered lease — no dispute remedy',
      'عقد غير مسجّل — لا سبل للنزاع',
      'अपंजीकृत लीज — कोई विवाद उपाय नहीं',
    ),
    'tenancy_critical_banner_body': _e(
      'Under Article 3 (Law 4/2008), the Rental Dispute Committee and courts will NOT consider your case unless the lease is registered at the Office. This is a hard bar — not weaker protection. Law No. 8 of 2026 also reduced the registration-violation settlement fee to QAR 1,000 (from QAR 5,000) to encourage regularization — registering now is both legally necessary for dispute recourse and cheaper to settle if a violation fee applies.',
      'بموجب المادة 3 (القانون 4/2008)، لن تنظر لجنة النزاعات أو المحاكم في طلبك ما لم يكن العقد مسجّلاً. القانون 8/2026 خفّض رسوم تسوية مخالفة التسجيل إلى 1000 ر.ق (من 5000) لتشجيع التسوية.',
      'Article 3 (Law 4/2008) के तहत पंजीकरण के बिना Committee/कोर्ट नहीं सुनेंगे। Law 8/2026 ने registration-violation settlement fee QAR 1,000 (पहले 5,000) किया — अब regularize करना सस्ता और जरूरी है।',
    ),
    'tenancy_critical_banner_settlement': _e(
      'Three separate figures — do not confuse them: (1) QR 250 standard registration fee at the Office (Art. 20(2)); (2) QAR 1,000 registration-violation settlement fee if regularizing a late/unregistered lease (Law 8/2026 — not a dispute-filing fee); (3) 15-day appeal window to the Court of Appeal after a Committee decision (Art. 24).',
      'ثلاثة مبالغ منفصلة: (1) 250 ر.ق رسوم التسجيل؛ (2) 1000 ر.ق تسوية مخالفة التسجيل (قانون 8/2026)؛ (3) 15 يوماً للاستئناف أمام محكمة الاستئناف.',
      'तीन अलग राशि: (1) QAR 250 पंजीकरण शुल्क; (2) QAR 1,000 registration-violation settlement (Law 8/2026); (3) 15-day अपील Court of Appeal को।',
    ),
    'tenancy_critical_banner_action': _e(
      'Register at the Municipality Rental Office. Raabta cannot register on your behalf.',
      'سجّل في مكتب الإيجار البلدي. Raabta لا يمكنها التسجيل نيابة عنك.',
      'Municipality Rental Office में पंजीकरण करें। Raabta आपकी ओर से नहीं कर सकता।',
    ),
    'tenancy_check_registration_title': _e(
      'Lease registration',
      'تسجيل عقد الإيجار',
      'लीज पंजीकरण',
    ),
    'tenancy_check_registration_pass': _e(
      'You indicated the lease is registered at the Office.',
      'أشرت إلى أن العقد مسجّل في المكتب.',
      'आपने बताया कि लीज Office में पंजीकृत है।',
    ),
    'tenancy_check_registration_action_pass': _e(
      'Keep your registered contract copy safe for any dispute filing.',
      'احتفظ بنسخة العقد المسجّل لأي تقديم نزاع.',
      'विवाद के लिए पंजीकृत अनुबंध की प्रति सुरक्षित रखें।',
    ),
    'tenancy_check_registration_critical_no': _e(
      'You said the lease is NOT registered. Article 3 blocks ANY Rental Dispute Committee or court remedy until registration.',
      'ذكرت أن العقد غير مسجّل. المادة 3 تمنع أي سبل أمام لجنة النزاعات أو المحاكم حتى التسجيل.',
      'लीज पंजीकृत नहीं है। Article 3 पंजीकरण तक कोई Committee/कोर्ट उपाय रोकता है।',
    ),
    'tenancy_check_registration_action_no': _e(
      'Register at the Municipality Rental Office before relying on dispute channels. Regularizing now matters: Article 3 blocks all Committee/court recourse until registration, and Law No. 8 of 2026 lowered the registration-violation settlement fee to QAR 1,000 (from QAR 5,000) — separate from the QR 250 Office registration fee.',
      'سجّل في مكتب الإيجار البلدي. التسوية الآن: المادة 3 تمنع السبل حتى التسجيل، ورسوم تسوية المخالفة 1000 ر.ق (قانون 8/2026) — منفصلة عن 250 ر.ق.',
      'Office में पंजीकरण करें। Law 8/2026: settlement fee QAR 1,000 (पहले 5,000) — QAR 250 Office fee से अलग।',
    ),
    'tenancy_check_registration_critical_unsure': _e(
      'Registration status unknown. If the lease is not registered, Article 3 blocks ALL dispute remedies — treat unregistered as highest risk until confirmed.',
      'حالة التسجيل غير معروفة. إن لم يكن مسجّلاً، المادة 3 تمنع كل سبل النزاع — اعتبره خطراً حتى التأكد.',
      'पंजीकरण अज्ञात। अपंजीकृत होने पर Article 3 सभी उपाय रोकता है — पुष्टि तक उच्च जोखिम मानें।',
    ),
    'tenancy_check_registration_action_unsure': _e(
      'Confirm registration status with your landlord or the Municipality Rental Office.',
      'تحقق من التسجيل مع المالك أو مكتب الإيجار البلدي.',
      'मकान मालिक या Office से पंजीकरण स्थिति पुष्टि करें।',
    ),
    'tenancy_check_registration_unanswered': _e(
      'Please indicate whether your lease is registered.',
      'يرجى الإشارة إلى ما إذا كان العقد مسجّلاً.',
      'कृपया बताएं कि लीज पंजीकृत है या नहीं।',
    ),
    'tenancy_check_registration_action_unanswered': _e(
      'Select Yes, No, or Not sure on the form.',
      'اختر نعم أو لا أو غير متأكد.',
      'फॉर्म पर Yes/No/Not sure चुनें।',
    ),
    'tenancy_check_deposit_title': _e(
      'Security deposit cap',
      'حد وديعة التأمين',
      'सुरक्षा जमा सीमा',
    ),
    'tenancy_check_deposit_pass': _e(
      'Deposit is within the two-month cap for residential premises.',
      'الوديعة ضمن حد شهرين للعقارات السكنية.',
      'जमा आवासीय दो महीने की सीमा के भीतर है।',
    ),
    'tenancy_check_deposit_action_pass': _e(
      'Non-residential deposits may be otherwise agreed.',
      'ودائع غير السكنية قد تُتفق عليها بخلاف ذلك.',
      'गैर-आवासीय जमा अन्यथा तय हो सकता है।',
    ),
    'tenancy_check_deposit_violation': _e(
      'Deposit exceeds two months\' rent for residential premises — this may violate Law 4/2008 deposit rules.',
      'الوديعة تتجاوز شهرين إيجار للسكن — قد تخالف قواعد وديعة القانون 4/2008.',
      'आवासीय जमा दो महीने के किराए से अधिक — Law 4/2008 उल्लंघन हो सकता है।',
    ),
    'tenancy_check_deposit_action_violation': _e(
      'Document the amount and seek guidance from the Rental Dispute Committee or a lawyer.',
      'وثّق المبلغ واطلب إرشاداً من لجنة النزاعات أو محامٍ.',
      'राशि दर्ज करें और Committee/वकील से मार्गदर्शन लें।',
    ),
    'tenancy_check_deposit_commercial': _e(
      'Commercial premises — deposit cap may be otherwise agreed (residential cap is two months).',
      'عقار تجاري — قد تُتفق الوديعة بخلاف ذلك (السكن: شهران).',
      'व्यावसायिक — जमा अन्यथा तय; आवासीय सीमा दो महीने।',
    ),
    'tenancy_check_deposit_action_commercial': _e(
      'Review your contract for the agreed deposit amount.',
      'راجع العقد للمبلغ المتفق عليه.',
      'अनुबंध में तय जमा देखें।',
    ),
    'tenancy_check_deposit_needs_rent': _e(
      'Enter monthly rent to evaluate the residential deposit cap.',
      'أدخل الإيجار الشهري لتقييم حد الوديعة.',
      'जमा सीमा के लिए मासिक किराया दर्ज करें।',
    ),
    'tenancy_check_deposit_action_needs_rent': _e(
      'Add your monthly rent on the lease form.',
      'أضف الإيجار الشهري في النموذج.',
      'फॉर्म में मासिक किराया जोड़ें।',
    ),
    'tenancy_check_late_fee_title': _e(
      'Registration fee (Law 8/2026)',
      'رسوم التسجيل (القانون 8/2026)',
      'पंजीकरण शुल्क (Law 8/2026)',
    ),
    'tenancy_check_late_fee_base': _e(
      'Standard registration fee: QR 250 per lease transaction (Art. 20(2)). Payable at the Municipality Rental Office.',
      'رسوم التسجيل: 250 ر.ق لكل معاملة (م. 20(2)). تُدفع في مكتب الإيجار.',
      'मानक शुल्क: QAR 250 प्रति लेनदेन (Art. 20(2))। Office में देय।',
    ),
    'tenancy_check_late_fee_with_penalty': _e(
      'Late registration adds penalties on top of QR 250: +25% month 1, +50% month 2, +75% month 3, +100% beyond (partial month = full month). This is a fee schedule — separate from the Article 3 dispute bar.',
      'التأخر يضيف غرامات على 250 ر.ق: +25% الشهر 1، +50% الشهر 2، +75% الشهر 3، +100% بعدها (جزء الشهر = شهر كامل). جدول رسوم — منفصل عن حظر المادة 3.',
      'देरी पर QAR 250 पर जुर्माना: +25% माह 1, +50% माह 2, +75% माह 3, +100% उसके बाद। शुल्क अनुसूची — Article 3 से अलग।',
    ),
    'tenancy_check_late_fee_action': _e(
      'Register as soon as possible at the Municipality Rental Office. If you are regularizing a late registration, Law No. 8 of 2026 sets a QAR 1,000 settlement fee for registration-related violations (reduced from QAR 5,000) — this is NOT the QR 250 Office fee and NOT a dispute-filing charge.',
      'سجّل في أقرب وقت. تسوية مخالفة التسجيل 1000 ر.ق (قانون 8/2026) — ليست 250 ر.ق ولا رسوم تقديم نزاع.',
      'जल्द Office में पंजीकरण करें। Law 8/2026: registration-violation settlement QAR 1,000 — QAR 250 Office fee या dispute fee नहीं।',
    ),
    'tenancy_right_rent_payment_title': _e(
      'Rent payment timing',
      'موعد دفع الإيجار',
      'किराया भुगतान समय',
    ),
    'tenancy_right_rent_payment_exp': _e(
      'Rent must be paid to the landlord no later than 7 days after its due date.',
      'يجب دفع الإيجار للمالك خلال 7 أيام من تاريخ الاستحقاق.',
      'किराया due date के 7 दिनों के भीतर मकान मालिक को देना होगा।',
    ),
    'tenancy_right_rent_payment_action': _e(
      'Keep payment records (transfer receipts, messages).',
      'احتفظ بسجلات الدفع.',
      'भुगतान रिकॉर्ड रखें।',
    ),
    'tenancy_right_maintenance_title': _e(
      'Maintenance rent-reduction claim',
      'مطالبة خفض الإيجار بسبب الصيانة',
      'रखरखाव किराया कटौती',
    ),
    'tenancy_right_maintenance_exp': _e(
      'If premises are impaired by maintenance and you stay 30 days without objection without bringing the matter to the Committee, the right to reduce/withhold rent on that basis is waived.',
      'إذا تأثرت الوحدة بالصيانة واستمررت 30 يوماً دون اعتراض دون اللجوء للجنة، يسقط حق خفض/حجب الإيجار.',
      '30 दिन बिना आपत्ति रहने पर रखरखाव पर किराया कम करने का अधिकार समाप्त।',
    ),
    'tenancy_right_maintenance_action': _e(
      'Raise maintenance issues with the Committee within 30 days if rent reduction is needed.',
      'اطرح قضية الصيانة على اللجنة خلال 30 يوماً.',
      '30 दिनों में Committee में मुद्दा उठाएं।',
    ),
    'tenancy_right_refused_rent_title': _e(
      'Landlord refuses rent',
      'رفض المالك استلام الإيجار',
      'मकान मालिक किराया अस्वीकार',
    ),
    'tenancy_right_refused_rent_exp': _e(
      'If the landlord refuses to accept rent, deposit it with the Rental Dispute Committee within the first week of refusal. Funds can only be withdrawn with the landlord\'s consent once deposited.',
      'إذا رفض المالك الإيجار، أودعه لدى لجنة النزاعات خلال الأسبوع الأول من الرفض. لا يُسحب إلا بموافقة المالك.',
      'मकान मालिक किराया अस्वीकार करे तो पहले सप्ताह में Committee में जमा करें।',
    ),
    'tenancy_right_refused_rent_action': _e(
      'Get a deposit receipt from the Committee office.',
      'احصل على إيصال إيداع من اللجنة.',
      'Committee से जमा रसीद लें।',
    ),
    'tenancy_right_ownership_title': _e(
      'Ownership transfer',
      'نقل الملكية',
      'स्वामित्व हस्तांतरण',
    ),
    'tenancy_right_ownership_exp': _e(
      'A new owner must notify you and the Office within 30 days of the ownership change, by registered letter.',
      'يجب على المالك الجديد إخطارك والمكتب خلال 30 يوماً من نقل الملكية بخطاب مسجّل.',
      'नया मालिक 30 दिनों में registered letter से आपको और Office को सूचित करे।',
    ),
    'tenancy_right_ownership_action': _e(
      'Keep proof of notifications if ownership changes during your lease.',
      'احتفظ بإثبات الإخطار عند تغيير الملكية.',
      'स्वामित्व बदलने पर सूचना का प्रमाण रखें।',
    ),
    'tenancy_right_committee_jurisdiction_title': _e(
      'Rental Dispute Committee — jurisdiction & court precondition',
      'لجنة النزاعات — الاختصاص وشرط المحكمة',
      'Committee — अधिकार क्षेत्र और court precondition',
    ),
    'tenancy_right_committee_jurisdiction_exp': _e(
      'Law No. 8 of 2026 expanded Art. 22: the Committee has jurisdiction over all disputes arising from lease relationships between landlords and tenants — including disputes from cases exempt under Art. 2 of Law 4/2008. You must bring your case to the Committee first; a Qatar court will not admit a rental lawsuit until the Committee has ruled (mandatory precondition, not an optional channel). Appeals go to the single Court of Appeal within 15 days (Art. 24).',
      'القانون 8/2026 وسّع م. 22: اختصاص اللجنة بجميع نزاعات الإيجار بما فيها المستثناة من م. 2. يجب اللجوء للجنة أولاً — لا تقبل المحكمة دعوى قبل حكم اللجنة. الاستئناف لمحكمة الاستئناف خلال 15 يوماً.',
      'Law 8/2026 Art. 22: Committee सभी lease disputes — Art. 2 exempt cases सहित। Court से पहले Committee mandatory। 15-day Court of Appeal अपील।',
    ),
    'tenancy_right_committee_jurisdiction_action': _e(
      'File with the Rental Dispute Committee before considering any court action. Prepare your registered lease and Arabic documents.',
      'قدّم للجنة قبل أي إجراء محكمة. جهّز العقد المسجّل.',
      'Court से पहले Committee में दायर करें। पंजीकृत लीज तैयार रखें।',
    ),
    'tenancy_right_committee_title': _e(
      'Rental Dispute Committee timing',
      'مدة لجنة نزاعات الإيجار',
      'Rental Dispute Committee समय',
    ),
    'tenancy_right_committee_exp': _e(
      'As reported Dec 2025 by the Committee office head (Rosa Al-Shammari interview): decisions often within ~21 days. Statutory ceiling under Cabinet Resolution 37/2008: 3 months, extendable to 6 months maximum — shown for context only, not a tenant filing deadline.',
      'كما أفادت رئيسة مكتب اللجنة (ديسمبر 2025): قرارات غالباً خلال ~21 يوماً. السقف النظامي: 3–6 أشهر — للسياق فقط، وليس مهلة لتقديم المستأجر.',
      'Dec 2025 Committee head interview: ~21 दिन। वैधानिक सीमा 3–6 महीने — संदर्भ के लिए; tenant filing deadline नहीं।',
    ),
    'tenancy_right_committee_action': _e(
      'Prepare registered lease and Arabic documents before filing.',
      'جهّز العقد المسجّل والمستندات العربية قبل التقديم.',
      'दायर करने से पहले पंजीकृत लीज और Arabic दस्तावेज तैयार करें।',
    ),
    'tenancy_right_appeal_title': _e(
      'Appeal window',
      'مهلة الاستئناف',
      'अपील अवधि',
    ),
    'tenancy_right_appeal_exp': _e(
      '15 days to appeal to the Court of Appeal (single consolidated forum) — from an in-person Committee decision, or from the day after notification for an absentia decision (Art. 24). This is separate from the QR 250 registration fee and the QAR 1,000 registration-violation settlement fee. Not a security-deposit return timeline.',
      '15 يوماً للاستئناف أمام محكمة الاستئناف — منفصل عن 250 ر.ق و1000 ر.ق تسوية التسجيل. ليست مهلة إرجاع وديعة.',
      '15 दिन Court of Appeal अपील — QAR 250/1,000 fees से अलग। deposit return timeline नहीं।',
    ),
    'tenancy_right_appeal_action': _e(
      'Mark appeal deadlines on your calendar if you receive a Committee decision.',
      'سجّل موعد الاستئناف عند استلام قرار اللجنة.',
      'Committee निर्णय पर अपील deadline नोट करें।',
    ),
    'tenancy_cite_law4_art3': _e(
      'Law 4/2008 Art. 3 — Al Meezan',
      'القانون 4/2008 م. 3 — الميزان',
      'Law 4/2008 Art. 3 — Al Meezan',
    ),
    'tenancy_cite_law4_deposit': _e(
      'Law 4/2008 — security deposit (residential cap: 2 months)',
      'القانون 4/2008 — وديعة (سكن: شهران)',
      'Law 4/2008 — deposit (residential: 2 months)',
    ),
    'tenancy_cite_law8_art20': _e(
      'Law 8/2026 Art. 20(2) — QR 250 registration fee',
      'القانون 8/2026 م. 20(2) — 250 ر.ق',
      'Law 8/2026 Art. 20(2) — QAR 250',
    ),
    'tenancy_cite_law8_art22': _e(
      'Law 8/2026 Art. 22 — expanded Committee jurisdiction',
      'القانون 8/2026 م. 22 — توسيع اختصاص اللجنة',
      'Law 8/2026 Art. 22 — expanded jurisdiction',
    ),
    'tenancy_cite_committee_interview': _e(
      'Committee office head interview, 28 Dec 2025 (Rosa Al-Shammari)',
      'مقابلة رئيسة مكتب اللجنة، 28 ديسمبر 2025',
      'Committee head interview, 28 Dec 2025',
    ),
    'tenancy_status_compliant': _e('Compliant', 'ممتثل', 'अनुपालित'),
    'tenancy_status_violation': _e('Violation', 'مخالفة', 'उल्लंघन'),
    'tenancy_status_critical': _e('Critical', 'حرج', 'गंभीर'),
    'tenancy_status_needs_verification': _e('Needs verification', 'يحتاج تحقق', 'सत्यापन चाहिए'),
    'tenancy_status_informational': _e('Information', 'معلومات', 'जानकारी'),
    'tenancy_late_fee_estimate': _e(
      'Estimated late registration fee: QR {amount} ({months} month(s) late, +{percent}% penalty on QR 250 base)',
      'رسوم التأخير التقديرية: {amount} ر.ق ({months} شهر/أشهر، +{percent}% على 250)',
      'अनुमानित देरी शुल्क: QAR {amount} ({months} माह, +{percent}%)',
    ),
    'tenancy_edit_lease': _e('Edit lease details', 'تعديل تفاصيل العقد', 'लीज विवरण संपादित करें'),

    // ── Phase 2: Dispute checklist & packet ───────────────────────────────────
    'tenancy_checklist_title': _e(
      'Dispute Filing Checklist',
      'قائمة تقديم النزاع',
      'Dispute Filing Checklist',
    ),
    'tenancy_checklist_subtitle': _e(
      'Mark documents as you collect them. Raabta does not file on your behalf.',
      'علّم المستندات عند جمعها. Raabta لا يقدّم نيابة عنك.',
      'Mark documents as collected. Raabta does not file for you.',
    ),
    'tenancy_checklist_progress': _e(
      '{collected} of {total} collected',
      '{collected} من {total} جُمع',
      '{collected} / {total} collected',
    ),
    'tenancy_checklist_scan_lease': _e(
      'Scan lease in PDF Studio',
      'امسح العقد في PDF Studio',
      'Scan lease in PDF Studio',
    ),
    'tenancy_checklist_open_vault': _e(
      'Open Document Vault',
      'افتح خزنة المستندات',
      'Open Document Vault',
    ),
    'tenancy_doc_claim_form': _e(
      'Arabic-language claim form',
      'نموذج المطالبة بالعربية',
      'Arabic-language claim form',
    ),
    'tenancy_doc_claim_form_sub': _e(
      'Required by the Rental Dispute Committee',
      'مطلوب من لجنة نزاعات الإيجار',
      'Required by the Rental Dispute Committee',
    ),
    'tenancy_doc_memo': _e(
      'Explanatory memo',
      'مذكرة توضيحية',
      'Explanatory memo',
    ),
    'tenancy_doc_memo_sub': _e(
      'Plain summary of your dispute basis',
      'ملخص واضح لأساس نزاعك',
      'Plain summary of your dispute basis',
    ),
    'tenancy_doc_lease': _e(
      'Registered lease contract (original + copy)',
      'عقد الإيجار المسجّل (أصل + نسخة)',
      'Registered lease contract (original + copy)',
    ),
    'tenancy_doc_lease_sub': _e(
      'Must be registered at the Municipality Rental Office',
      'يجب أن يكون مسجّلاً في مكتب الإيجار البلدي',
      'Must be registered at the Municipality Rental Office',
    ),
    'tenancy_doc_ownership': _e(
      'Ownership deed or commercial registration',
      'سند الملكية أو السجل التجاري',
      'Ownership deed or commercial registration',
    ),
    'tenancy_doc_ownership_sub': _e(
      'Deed for individuals; CR for companies',
      'سند للأفراد؛ سجل تجاري للشركات',
      'Deed for individuals; CR for companies',
    ),
    'tenancy_doc_ids': _e(
      'ID copies — both parties',
      'نسخ الهوية — الطرفان',
      'ID copies — both parties',
    ),
    'tenancy_doc_ids_sub': _e(
      'QID or passport copies for tenant and landlord',
      'QID أو جواز للمستأجر والمالك',
      'QID or passport copies for tenant and landlord',
    ),
    'tenancy_doc_poa': _e(
      'Power of attorney (if applicable)',
      'توكيل (إن وجد)',
      'Power of attorney (if applicable)',
    ),
    'tenancy_doc_poa_sub': _e(
      'Optional — if someone files on your behalf',
      'اختياري — إذا قدّم شخص عنك',
      'Optional — if someone files on your behalf',
    ),
    'tenancy_doc_translation': _e(
      'Official Arabic translation',
      'ترجمة عربية رسمية',
      'Official Arabic translation',
    ),
    'tenancy_doc_translation_sub': _e(
      'All documents must be Arabic or officially translated',
      'يجب أن تكون المستندات بالعربية أو مترجمة رسمياً',
      'All documents must be Arabic or officially translated',
    ),
    'tenancy_documents_title': _e(
      'Generate Dispute Packet',
      'إنشاء حزمة النزاع',
      'Generate Dispute Packet',
    ),
    'tenancy_documents_cta': _e(
      'Generate & Share PDF',
      'إنشاء ومشاركة PDF',
      'Generate & Share PDF',
    ),
    'tenancy_documents_need_check': _e(
      'Run a compliance check first to personalize your packet.',
      'أجرِ فحص الامتثال أولاً لتخصيص حزمتك.',
      'Run compliance check first to personalize packet.',
    ),
    'tenancy_packet_title': _e(
      'Tenancy Dispute Preparation Packet',
      'حزمة تجهيز نزاع الإيجار',
      'Tenancy Dispute Preparation Packet',
    ),
    'tenancy_packet_disclaimer': _e(
      'This PDF is a preparation aid only — not legal advice and NOT a filed document. Consult the Rental Dispute Committee or a qualified lawyer before filing.',
      'هذا PDF للتجهيز فقط — ليس استشارة قانونية وليس مستنداً مقدّماً. استشر اللجنة أو محامٍ.',
      'Preparation aid only — not legal advice, NOT filed. Consult Committee or lawyer.',
    ),
    'tenancy_packet_summary_heading': _e('Lease summary', 'ملخص العقد', 'Lease summary'),
    'tenancy_packet_landlord': _e('Landlord: {name}', 'المالك: {name}', 'Landlord: {name}'),
    'tenancy_packet_rent': _e('Monthly rent: QAR {amount}', 'الإيجار: {amount} ر.ق', 'Rent: QAR {amount}'),
    'tenancy_packet_deposit': _e(
      'Security deposit: QAR {amount}',
      'الوديعة: {amount} ر.ق',
      'Deposit: QAR {amount}',
    ),
    'tenancy_packet_claim_basis_heading': _e(
      'Implicated legal basis (informational)',
      'الأساس القانوني (إرشادي)',
      'Implicated legal basis (informational)',
    ),
    'tenancy_packet_docs_heading': _e(
      'Document checklist status',
      'حالة قائمة المستندات',
      'Document checklist status',
    ),
    'tenancy_packet_not_claim_form': _e(
      'This packet does NOT include an auto-drafted Arabic claim form. Prepare official forms separately at the Rental Dispute Committee.',
      'لا يتضمن هذا PDF نموذج مطالبة عربي مُعدّاً تلقائياً. جهّز النماذج الرسمية لدى اللجنة.',
      'Does NOT include auto-drafted Arabic claim form. Prepare official forms at the Committee.',
    ),
    'tenancy_packet_share_text': _e(
      'Tenancy Dispute Preparation Packet',
      'حزمة تجهيز نزاع الإيجار',
      'Tenancy Dispute Preparation Packet',
    ),
    'tenancy_claim_art3_unregistered': _e(
      'Article 3 — unregistered lease blocks Committee/court remedy',
      'المادة 3 — عقد غير مسجّل يمنع سبل اللجنة/المحكمة',
      'Art. 3 — unregistered lease blocks remedy',
    ),
    'tenancy_claim_deposit_cap': _e(
      'Residential deposit exceeds two-month cap (Law 4/2008)',
      'وديعة سكنية تتجاوز حد شهرين (القانون 4/2008)',
      'Deposit exceeds two-month cap',
    ),
    'tenancy_claim_late_registration': _e(
      'Late registration fee schedule may apply (Law 8/2026 Art. 20(2))',
      'قد تنطبق رسوم تأخر التسجيل (القانون 8/2026 م. 20(2))',
      'Late registration fees may apply (Law 8/2026)',
    ),
    'tenancy_claim_general_rights': _e(
      'General tenancy rights review under Law 4/2008',
      'مراجعة حقوق الإيجار العامة بموجب القانون 4/2008',
      'General tenancy rights under Law 4/2008',
    ),
    'tenancy_dashboard_checklist_cta': _e(
      'Dispute Document Checklist',
      'قائمة مستندات النزاع',
      'Dispute Document Checklist',
    ),
    'tenancy_dashboard_ai_cta': _e(
      'Ask Tenancy Assistant',
      'اسأل مساعد الإيجار',
      'Ask Tenancy Assistant',
    ),
    'tenancy_ai_title': _e(
      'Tenancy Legal Assistant',
      'مساعد الإيجار القانوني',
      'Tenancy Legal Assistant',
    ),
    'tenancy_ai_subtitle': _e(
      'Plain-language answers from verified facts only — not legal advice.',
      'إجابات بلغة بسيطة من حقائق موثّقة فقط — ليست استشارة قانونية.',
      'Verified facts only — not legal advice.',
    ),
    'tenancy_ai_ask_hint': _e(
      'Ask about registration, deposits, Committee process…',
      'اسأل عن التسجيل، الوديعة، اللجنة…',
      'Ask about registration, deposits, Committee…',
    ),
    'tenancy_ai_send': _e('Ask', 'اسأل', 'Ask'),
    'tenancy_ai_empty_question': _e(
      'Please enter a question.',
      'يرجى إدخال سؤال.',
      'Please enter a question.',
    ),
    'tenancy_ai_out_of_scope': _e(
      'That topic has not been verified in this app yet. Please contact the Rental Dispute Committee or a qualified lawyer — Raabta cannot answer from unverified sources.',
      'هذا الموضوع لم يُتحقق منه في التطبيق بعد. تواصل مع لجنة النزاعات أو محامٍ.',
      'That topic is not verified in this app. Contact the Rental Dispute Committee or a lawyer.',
    ),
    'tenancy_ai_unavailable': _e(
      'Assistant unavailable offline. Connect and try again.',
      'المساعد غير متاح دون اتصال. اتصل وحاول مجدداً.',
      'Assistant unavailable offline. Try again when online.',
    ),
    'tenancy_ai_prompt_registration': _e(
      'What happens if my lease is not registered?',
      'ماذا يحدث إن لم يُسجّل عقدي؟',
      'What if my lease is not registered?',
    ),
    'tenancy_ai_prompt_deposit': _e(
      'Is my security deposit legal?',
      'هل وديعتي قانونية؟',
      'Is my deposit legal?',
    ),
    'tenancy_ai_prompt_committee': _e(
      'How long does the Rental Dispute Committee take?',
      'كم تستغرق لجنة النزاعات؟',
      'How long does the Committee take?',
    ),
    'tenancy_deposit_evidence_cta': _e(
      'Protect your move-out evidence',
      'احمِ أدلة حالة الخروج',
      'Move-out evidence सुरक्षित करें',
    ),
    'tenancy_condition_photo_time_vault': _e(
      'Timestamp from vault scan record',
      'الوقت من سجل المسح في الخزنة',
      'Vault scan record से timestamp',
    ),
    'tenancy_condition_photo_time_linked': _e(
      'Linked at save time (vault scan time unavailable)',
      'وقت الربط عند الحفظ (وقت المسح غير متاح)',
      'Save time par link (vault scan time unavailable)',
    ),
    'tenancy_condition_pdf_photo_unavailable': _e(
      'Photo unavailable — reference: vault:{ref}',
      'الصورة غير متاحة — مرجع: vault:{ref}',
      'Photo unavailable — ref: vault:{ref}',
    ),
    'tenancy_dashboard_condition_cta': _e(
      'Property Condition Record',
      'سجل حالة العقار',
      'Property Condition Record',
    ),
    'tenancy_condition_title': _e(
      'Property Condition Record',
      'سجل حالة العقار',
      'Property Condition Record',
    ),
    'tenancy_condition_subtitle': _e(
      'Room-by-room photos with capture timestamps — your personal record for deposit disputes. Not legal advice; Raabta does not file on your behalf.',
      'صور لكل غرفة مع وقت الالتقاط — سجل شخصي لنزاعات الوديعة. ليس استشارة قانونية.',
      'Room photos with timestamps — personal record only.',
    ),
    'tenancy_condition_need_lease': _e(
      'Enter your lease details first to link condition records.',
      'أدخل تفاصيل عقدك أولاً لربط سجل الحالة.',
      'Enter lease details first.',
    ),
    'tenancy_condition_load_error': _e(
      'Could not load condition records.',
      'تعذّر تحميل سجل الحالة.',
      'Could not load records.',
    ),
    'tenancy_condition_move_in': _e('Move-in', 'دخول', 'Move-in'),
    'tenancy_condition_move_out': _e('Move-out', 'خروج', 'Move-out'),
    'tenancy_condition_move_in_cta': _e(
      'Record move-in condition',
      'سجّل حالة الدخول',
      'Record move-in condition',
    ),
    'tenancy_condition_move_in_hint': _e(
      'Photograph each room before you move in — timestamps are shown on each photo.',
      'صوّر كل غرفة قبل الدخول — يُعرض وقت الالتقاط على كل صورة.',
      'Photo each room before move-in.',
    ),
    'tenancy_condition_start_move_in': _e(
      'Start move-in record',
      'بدء سجل الدخول',
      'Start move-in record',
    ),
    'tenancy_condition_move_out_cta': _e(
      'Record move-out condition',
      'سجّل حالة الخروج',
      'Record move-out condition',
    ),
    'tenancy_condition_move_out_hint': _e(
      'Photograph the same rooms when you leave — compare with move-in later.',
      'صوّر نفس الغرف عند المغادرة — قارن لاحقاً مع الدخول.',
      'Photo rooms when you leave.',
    ),
    'tenancy_condition_start_move_out': _e(
      'Start move-out record',
      'بدء سجل الخروج',
      'Start move-out record',
    ),
    'tenancy_condition_compare_cta': _e(
      'Compare move-in vs move-out',
      'قارن الدخول والخروج',
      'Compare move-in vs move-out',
    ),
    'tenancy_condition_export_pdf': _e(
      'Generate condition report (PDF)',
      'إنشاء تقرير الحالة (PDF)',
      'Generate condition report (PDF)',
    ),
    'tenancy_condition_summary': _e(
      '{rooms} rooms · {photos} photos',
      '{rooms} غرف · {photos} صور',
      '{rooms} rooms · {photos} photos',
    ),
    'tenancy_condition_recapture': _e(
      'Update this record',
      'تحديث هذا السجل',
      'Update this record',
    ),
    'tenancy_condition_capture_hint': _e(
      'Add rooms one at a time. Use the document scanner to capture photos — each photo shows when it was taken on this device.',
      'أضف الغرف واحدة تلو الأخرى. استخدم الماسح — كل صورة تعرض وقت الالتقاط.',
      'Add rooms and scan photos with visible capture time.',
    ),
    'tenancy_condition_room_label': _e('Room name', 'اسم الغرفة', 'Room name'),
    'tenancy_condition_add_room': _e('Add room', 'إضافة غرفة', 'Add room'),
    'tenancy_condition_add_timeline': _e(
      'Add to case timeline',
      'إضافة للجدول الزمني',
      'Add to case timeline',
    ),
    'tenancy_condition_add_timeline_sub': _e(
      'Optional — records move-in/out date in your dispute timeline',
      'اختياري — يسجل التاريخ في الجدول الزمني',
      'Optional timeline milestone',
    ),
    'tenancy_condition_scan_photo': _e(
      'Scan/Upload photo',
      'مسح/رفع صورة',
      'Scan/Upload photo',
    ),
    'tenancy_condition_photo_time': _e(
      'Captured: {time}',
      'التقاط: {time}',
      'Captured: {time}',
    ),
    'tenancy_condition_photo_note': _e(
      'Note (optional)',
      'ملاحظة (اختياري)',
      'Note (optional)',
    ),
    'tenancy_condition_save_session': _e(
      'Save condition record',
      'حفظ سجل الحالة',
      'Save condition record',
    ),
    'tenancy_condition_saved': _e(
      'Condition record saved.',
      'تم حفظ سجل الحالة.',
      'Condition record saved.',
    ),
    'tenancy_condition_compare_title': _e(
      'Compare conditions',
      'مقارنة الحالة',
      'Compare conditions',
    ),
    'tenancy_condition_compare_need_both': _e(
      'Both move-in and move-out records are needed to compare.',
      'يلزم سجل الدخول والخروج للمقارنة.',
      'Need both move-in and move-out records.',
    ),
    'tenancy_condition_compare_hint': _e(
      'Review photos side by side and add your own notes — Raabta does not detect damage automatically.',
      'راجع الصور جنباً إلى جنب وأضف ملاحظاتك — لا كشف تلقائي للأضرار.',
      'Human review only — no automatic damage detection.',
    ),
    'tenancy_condition_unmatched': _e(
      'Unmatched room',
      'غرفة غير مطابقة',
      'Unmatched room',
    ),
    'tenancy_condition_no_photos': _e(
      'No photos',
      'لا صور',
      'No photos',
    ),
    'tenancy_condition_vault_ref': _e(
      'Vault ref: {id}…',
      'مرجع: {id}…',
      'Vault ref: {id}…',
    ),
    'tenancy_condition_comparison_note': _e(
      'Your comparison note',
      'ملاحظة المقارنة',
      'Your comparison note',
    ),
    'tenancy_condition_save_notes': _e(
      'Save comparison notes',
      'حفظ ملاحظات المقارنة',
      'Save comparison notes',
    ),
    'tenancy_condition_notes_saved': _e(
      'Comparison notes saved.',
      'تم حفظ الملاحظات.',
      'Notes saved.',
    ),
    'tenancy_condition_report_title': _e(
      'Condition report',
      'تقرير الحالة',
      'Condition report',
    ),
    'tenancy_condition_report_body': _e(
      'Export a PDF with lease summary, room photos, timestamps, and your comparison notes.',
      'صدّر PDF يتضمن ملخص العقد والصور والأوقات وملاحظاتك.',
      'Export PDF with photos, timestamps, and notes.',
    ),
    'tenancy_condition_report_empty': _e(
      'Record move-in condition first to generate a report.',
      'سجّل حالة الدخول أولاً لإنشاء تقرير.',
      'Record move-in first.',
    ),
    'tenancy_condition_generate_report': _e(
      'Generate condition report',
      'إنشاء تقرير الحالة',
      'Generate condition report',
    ),
    'tenancy_condition_report_pdf_title': _e(
      'Property Condition Report',
      'تقرير حالة العقار',
      'Property Condition Report',
    ),
    'tenancy_condition_comparison_notes_heading': _e(
      'Comparison notes',
      'ملاحظات المقارنة',
      'Comparison notes',
    ),
    'tenancy_condition_report_share': _e(
      'My tenancy property condition report — RAABTA',
      'تقرير حالة العقار — RAABTA',
      'My property condition report — RAABTA',
    ),
    'tenancy_doc_condition': _e(
      'Property condition evidence (move-in/out photos)',
      'إثبات حالة العقار (صور الدخول/الخروج)',
      'Property condition evidence',
    ),
    'tenancy_doc_condition_sub': _e(
      'Room-by-room photos with timestamps from Property Condition Record',
      'صور لكل غرفة مع وقت الالتقاط من سجل الحالة',
      'Room photos with timestamps',
    ),
    'tenancy_checklist_condition_ready': _e(
      'Condition record on file — open Property Condition Record',
      'سجل الحالة موجود — افتح سجل حالة العقار',
      'Condition record on file',
    ),
    'tenancy_hub_explore': _e('Explore', 'استكشف', 'Explore'),
    'tenancy_scenarios': _e('What-if scenarios', 'سيناريوهات ماذا لو', 'What-if scenarios'),
    'tenancy_scenarios_desc': _e(
      'Compare hypothetical lease compliance outcomes. Not saved as real checks.',
      'قارن نتائج امتثال الإيجار الافتراضية. لا تُحفظ كفحوصات حقيقية.',
      'Compare hypothetical outcomes. Not saved.',
    ),
    'tenancy_scenarios_empty_title': _e(
      'Add lease details first',
      'أضف تفاصيل العقد أولاً',
      'Add lease details first',
    ),
    'tenancy_scenarios_empty_desc': _e(
      'Enter rent and registration details to explore what-if scenarios.',
      'أدخل الإيجار وتفاصيل التسجيل لاستكشاف السيناريوهات.',
      'Enter lease details first.',
    ),
    'tenancy_scenario_base': _e('Your current case', 'حالتك الحالية', 'Your current case'),
    'tenancy_scenario_hypothetical': _e(
      'Hypothetical only — not a saved compliance check',
      'افتراضي فقط — ليس فحص امتثال محفوظ',
      'Hypothetical only — not saved',
    ),
    'tenancy_scenario_tap_expand': _e('Tap to expand details', 'اضغط للتفاصيل', 'Tap to expand'),
    'tenancy_scenario_deposit_over_title': _e(
      'If your deposit exceeds the legal cap',
      'إذا تجاوز التأمين الحد القانوني',
      'Deposit over legal cap',
    ),
    'tenancy_scenario_deposit_over_desc': _e(
      'Security deposit set to 3 months rent (residential cap is 2)',
      'تأمين 3 أشهر (الحد السكني شهران)',
      'Deposit = 3 months (cap is 2)',
    ),
    'tenancy_scenario_late_reg_title': _e(
      'If you register your lease late',
      'إذا سجّلت العقد متأخراً',
      'Late lease registration',
    ),
    'tenancy_scenario_late_reg_desc': _e(
      'Unregistered lease started 4 months ago',
      'عقد غير مسجل بدأ منذ 4 أشهر',
      'Unregistered, started 4 months ago',
    ),
    'tenancy_scenario_late_reg_recent_title': _e(
      'If registration is delayed slightly',
      'إذا تأخر التسجيل قليلاً',
      'Slight registration delay',
    ),
    'tenancy_scenario_late_reg_recent_desc': _e(
      'Unregistered lease started 20 days ago',
      'عقد غير مسجل بدأ منذ 20 يوماً',
      'Unregistered, started 20 days ago',
    ),
    'tenancy_scenario_diff_critical_added': _e(
      'Critical issue appears',
      'تظهر مشكلة حرجة',
      'Critical issue appears',
    ),
    'tenancy_scenario_diff_critical_removed': _e(
      'Critical issue removed',
      'تزول المشكلة الحرجة',
      'Critical issue removed',
    ),
    'tenancy_scenario_diff_violation_added': _e(
      'Violation appears',
      'تظهر مخالفة',
      'Violation appears',
    ),
    'tenancy_scenario_diff_violation_removed': _e(
      'Violation removed',
      'تزول المخالفة',
      'Violation removed',
    ),
    'tenancy_scenario_diff_late_fee_changed': _e(
      'Late registration fee estimate changed',
      'تغير تقدير رسوم التأخير',
      'Late fee estimate changed',
    ),
    'tenancy_scenario_diff_status_changed': _e(
      'Status changed vs current',
      'تغيرت الحالة عن الحالية',
      'Status changed',
    ),
    'tenancy_history': _e('Check history', 'سجل الفحوصات', 'Check history'),
    'tenancy_empty_history': _e('No past checks yet', 'لا فحوصات سابقة', 'No past checks'),
    'tenancy_empty_history_desc': _e(
      'Run a lease compliance check to build your history.',
      'أجرِ فحص امتثال العقد لبناء السجل.',
      'Run a check to build history.',
    ),
    'tenancy_history_error': _e(
      'Could not load history',
      'تعذر تحميل السجل',
      'Could not load history',
    ),
    'tenancy_result_summary_heading': _e(
      'Your lease position',
      'وضع عقد الإيجار',
      'Your lease position',
    ),
    'tenancy_history_summary_critical': _e(
      'Critical issue flagged',
      'مشكلة حرجة',
      'Critical issue flagged',
    ),
    'tenancy_history_summary_compliant': _e(
      'Compliant — no violations',
      'ممتثل — لا مخالفات',
      'Compliant — no violations',
    ),
    'tenancy_room_living_room': _e('Living Room', 'غرفة المعيشة', 'Living Room'),
    'tenancy_room_master_bedroom': _e(
      'Master Bedroom',
      'غرفة النوم الرئيسية',
      'Master Bedroom',
    ),
    'tenancy_room_bedroom': _e('Bedroom', 'غرفة نوم', 'Bedroom'),
    'tenancy_room_kitchen': _e('Kitchen', 'المطبخ', 'Kitchen'),
    'tenancy_room_bathroom': _e('Bathroom', 'الحمام', 'Bathroom'),
    'tenancy_room_balcony': _e('Balcony', 'الشرفة', 'Balcony'),
    'tenancy_room_hallway': _e('Hallway', 'الممر', 'Hallway'),
    'tenancy_room_storage': _e('Storage', 'المخزن', 'Storage'),
    'tenancy_listing_title': _e(
      'Listing consistency check',
      'فحص اتساق الإعلان',
      'Listing consistency check',
    ),
    'tenancy_listing_subtitle': _e(
      'Before you commit — compare listing details against Qatar tenancy rules and ScamShield patterns. Raabta does not verify this specific landlord or property.',
      'قبل الالتزام — قارن تفاصيل الإعلان بقواعد الإيجار في قطر وأنماط ScamShield. Raabta لا تتحقق من هذا المالك أو العقار تحديداً.',
      'Before you commit — compare listing details against Qatar rules and ScamShield patterns.',
    ),
    'tenancy_listing_framing': _e(
      'Raabta could not independently verify these listing details — this check compares what you entered against known rules and common scam patterns only.',
      'Raabta لم تتحقق بشكل مستقل من تفاصيل هذا الإعلان — هذه المقارنة تعتمد على ما أدخلته مقابل القواعد المعروفة وأنماط الاحتيال الشائعة فقط.',
      'Raabta could not independently verify these details — rules and pattern comparison only.',
    ),
    'tenancy_listing_dashboard_cta': _e(
      'Check a listing before you commit',
      'تحقق من الإعلان قبل الالتزام',
      'Check a listing before you commit',
    ),
    'tenancy_listing_rent': _e(
      'Monthly rent (QAR)',
      'الإيجار الشهري (ر.ق)',
      'Monthly rent (QAR)',
    ),
    'tenancy_listing_deposit': _e(
      'Deposit requested (QAR)',
      'الوديعة المطلوبة (ر.ق)',
      'Deposit requested (QAR)',
    ),
    'tenancy_listing_payment': _e(
      'Payment method requested',
      'طريقة الدفع المطلوبة',
      'Payment method requested',
    ),
    'tenancy_listing_reservation': _e(
      'Upfront reservation / holding fee (if any)',
      'رسوم حجز / تأمين مقدم (إن وُجد)',
      'Upfront reservation fee (if any)',
    ),
    'tenancy_listing_contact': _e(
      'Contact information given',
      'معلومات التواصل المقدمة',
      'Contact information given',
    ),
    'tenancy_listing_property': _e(
      'Property details from listing',
      'تفاصيل العقار من الإعلان',
      'Property details from listing',
    ),
    'tenancy_listing_message': _e(
      'Message from landlord/agent (optional)',
      'رسالة من المالك/الوكيل (اختياري)',
      'Message from landlord/agent (optional)',
    ),
    'tenancy_listing_message_hint': _e(
      'Paste WhatsApp or email text — enables ScamShield AI review within your monthly cap.',
      'الصق نص واتساب أو بريد — يفعّل مراجعة ScamShield AI ضمن حدك الشهري.',
      'Paste message text for ScamShield AI review within your cap.',
    ),
    'tenancy_listing_run': _e(
      'Run consistency check',
      'إجراء فحص الاتساق',
      'Run consistency check',
    ),
    'tenancy_listing_results': _e(
      'Check results',
      'نتائج الفحص',
      'Check results',
    ),
    'tenancy_listing_deposit_over_cap': _e(
      'The requested deposit (QAR {deposit}) exceeds the {capMonths}-month rent cap (QAR {maxDeposit} on QAR {rent}/month) under Qatar tenancy law — worth confirming before you pay.',
      'الوديعة المطلوبة ({deposit} ر.ق) تتجاوز حد {capMonths} أشهر إيجار ({maxDeposit} ر.ق على {rent} ر.ق/شهر) بموجب قانون الإيجار — يستحق التأكيد قبل الدفع.',
      'Deposit QAR {deposit} exceeds {capMonths}-month cap QAR {maxDeposit} on rent QAR {rent} — confirm before paying.',
    ),
    'tenancy_listing_registration_reminder': _e(
      'Factual reminder: leases must be registered at the Municipality Rental Office (standard fee QR {fee}, Law 8/2026). Raabta cannot confirm whether this specific listing will be registered.',
      'تذكير واقعي: يجب تسجيل عقود الإيجار في مكتب الإيجار البلدي (رسوم قياسية {fee} ر.ق، قانون 8/2026). Raabta لا تستطيع تأكيد تسجيل هذا الإعلان تحديداً.',
      'Leases must be registered (QR {fee} fee, Law 8/2026). Raabta cannot confirm this listing will be registered.',
    ),
    'tenancy_listing_action': _e(
      'View the property in person, verify the landlord through official channels, and keep records before transferring money.',
      'اعرض العقار شخصياً، تحقق من المالك عبر القنوات الرسمية، واحتفظ بالسجلات قبل تحويل المال.',
      'View in person, verify through official channels, keep records before paying.',
    ),
    'tenancy_listing_lease_cta': _e(
      'Have a draft lease? Check it separately',
      'لديك مسودة عقد؟ تحقق منها بشكل منفصل',
      'Have a draft lease? Check it separately',
    ),
    'tenancy_maintenance_section_title': _e(
      'Maintenance & repairs (Art. 6)',
      'الصيانة والإصلاحات (المادة 6)',
      'Maintenance & repairs (Art. 6)',
    ),
    'tenancy_maintenance_section_subtitle': _e(
      'Who pays for what during your lease — and the correct process if the landlord refuses a necessary repair.',
      'من يتحمل ماذا أثناء الإيجار — والإجراء الصحيح إذا رفض المالك إصلاحاً ضرورياً.',
      'Who pays during lease — and correct process if landlord refuses necessary repair.',
    ),
    'tenancy_maintenance_split_known': _e(
      'Landlord: structural repairs and keeping the property fit for its agreed use. Tenant: routine/minor upkeep from daily use (e.g. light bulbs, standard drain clogs from daily use, AC filters if agreed) — and report needed repairs to the landlord in writing. Your lease may specify differently — always check the contract; a clause shifting all maintenance (including structural) to the tenant may be challengeable.',
      'المالك: الإصلاحات الإنشائية وإبقاء العقار صالحاً للاستخدام المتفق عليه. المستأجر: الصيانة الروتينية/البسيطة من الاستخدام اليومي (مثل المصابيح، انسدادات الصرف العادية، فلاتر التكييف إن اتُفق) — وإبلاغ المالك كتابياً بالإصلاحات المطلوبة. قد ينص العقد بخلاف ذلك — راجع العقد؛ شرط يحوّل كل الصيانة (بما فيها الإنشائية) للمستأجر قد يُطعن فيه.',
      'Landlord: structural + fit-for-use. Tenant: routine daily upkeep + written repair reports. Check lease — all-maintenance-on-tenant clauses may be challengeable.',
    ),
    'tenancy_maintenance_process_known': _e(
      'If a necessary repair is refused or ignored after written notice: (1) Notify the landlord of the needed repair in writing — keep a copy and timestamp. (2) If they refuse or fail to act, apply to the Rental Disputes Settlement Committee for permission to carry out the repair and deduct the documented cost from rent (Article 6, Law 4/2008 as amended).',
      'إذا رُفض إصلاح ضروري أو تُجاهل بعد إخطار كتابي: (1) أبلغ المالك كتابياً — احتفظ بنسخة وتاريخ. (2) إذا رفض أو لم يتحرك، قدّم للجنة فض منازعات الإيجار طلب إذن لتنفيذ الإصلاح وخصم التكلفة الموثقة من الإيجار (المادة 6، قانون 4/2008 المعدّل).',
      'After written notice: (1) notify landlord in writing with copy/timestamp. (2) if refused/inaction, apply to Rental Disputes Settlement Committee for permission to repair and deduct documented cost (Art. 6, Law 4/2008).',
    ),
    'tenancy_maintenance_process_warning': _e(
      'Important: You do not have the right to pay for repairs yourself and deduct from rent — or withhold rent as pressure — without this Committee permission first. Doing so without permission could create a rent-arrears dispute against you.',
      'مهم: ليس لك الحق في دفع الإصلاح وخصمه من الإيجار — أو حجب الإيجار كضغط — دون إذن اللجنة أولاً. فعل ذلك دون إذن قد يخلق نزاع تأخر إيجار ضدك.',
      'Important: no self-paid repair deduction or rent withholding without Committee permission first — could create rent-arrears dispute against you.',
    ),
    'tenancy_maintenance_action': _e(
      'Document your written notice to the landlord, then apply to the Rental Disputes Settlement Committee for permission before you spend money on the repair or deduct anything from rent.',
      'وثّق إخطارك الكتابي للمالك، ثم قدّم للجنة فض منازعات الإيجار طلب إذن قبل إنفاق أي مبلغ على الإصلاح أو خصم أي شيء من الإيجار.',
      'Document written notice, then apply to Committee for permission before spending on repair or deducting from rent.',
    ),
    'tenancy_maintenance_unknown': _e(
      'Whether a specific repair qualifies as "necessary" under the law is for the Committee to decide — Raabta cannot determine that for your case.',
      'هل يُعد إصلاح معيّن "ضرورياً" نظاماً — للجنة أن تقرر؛ Raabta لا تحكم في حالتك.',
      'Whether a repair is "necessary" is for the Committee — Raabta cannot decide for your case.',
    ),
    'tenancy_shared_housing_section_title': _e(
      'Shared housing & subletting',
      'السكن المشترك والتأجير من الباطن',
      'Shared housing & subletting',
    ),
    'tenancy_shared_housing_section_subtitle': _e(
      'For bedspaces, flat-shares, and renting from another tenant — not the same as being named on the main lease.',
      'لغرف النوم والمشاركة والإيجار من مستأجر آخر — ليس كالظهور في العقد الرئيسي.',
      'Bedspaces, flat-shares, renting from another tenant — different from main lease.',
    ),
    'tenancy_shared_housing_distinction_known': _e(
      'Joint lease: multiple people named on the same approved tenancy contract with the landlord — follow the lease terms. Subletting: one person holds the contract and rents all or part of the property to others — under Article 14 (Law No. 4 of 2008), this requires the landlord\'s written consent. Shared housing and subletting are legal WITH that consent; without it, the arrangement is unauthorized and can expose the main tenant to eviction proceedings.',
      'الإيجار المشترك: عدة أشخاص مذكورون في عقد إيجار معتمد مع المالك — اتبع شروط العقد. التأجير من الباطن: شخص واحد يحمل العقد ويؤجر كل أو جزء من العقار لآخرين — بموجب المادة 14 (قانون 4/2008) يتطلب موافقة المالك الكتابية. السكن المشترك والتأجير من الباطن قانونيان بموافقة المالك؛ دونها يكون الترتيب غير مصرح به وقد يعرّض المستأجر الرئيسي لإجراءات الإخلاء.',
      'Joint lease: all named on approved contract. Subletting (Art. 14): requires landlord written consent — legal with consent; unauthorized without it.',
    ),
    'tenancy_shared_housing_subtenant_action': _e(
      'If you rent a room or bedspace from a main tenant (not the landlord): (1) Ask to see their tenancy contract and confirm it is current. (2) Ask for evidence of the landlord\'s written consent to sublet or share. (3) Get your arrangement with the main tenant in writing — rent, deposit, notice period, what is included. (4) Understand your legal position as a subtenant is NOT the same as being on the main lease — the original lease governs landlord/main-tenant; your agreement governs you and the main tenant only. (5) Keys alone do not prove permission to sublet.',
      'إذا أجرت غرفة أو سريراً من مستأجر رئيسي: (1) اطلب رؤية عقد إيجاره وتأكد أنه ساري. (2) اطلب دليل موافقة المالك الكتابية على التأجير من الباطن أو المشاركة. (3) احصل على ترتيبك كتابياً — الإيجار، الوديعة، الإشعار، المشمول. (4) موقعك كمستأجر من الباطن ليس كالظهور في العقد الرئيسي. (5) المفاتيح وحدها لا تثبت إذن التأجير من الباطن.',
      'Subtenant checklist: see main lease, landlord written consent, your written agreement, know subtenant ≠ main lease, keys ≠ permission.',
    ),
    'tenancy_shared_housing_md105_known': _e(
      'Ministerial Decision No. 105 of 2020 (narrow scope): restricts groups of MORE than five workers living together in DESIGNATED family residential areas. It explicitly EXCLUDES female workers (regardless of occupation) and domestic or comparable household workers from this specific worker-group definition. This does NOT mean any pair of male flatmates, or any unmarried worker generally, is barred from a family residential area — the rule targets larger worker groupings in specific designated areas. Municipality enforcement exists; heavily overcrowded or informally partitioned properties are worth avoiding regardless of the precise threshold.',
      'القرار الوزاري 105/2020 (نطاق ضيق): يقيّد مجموعات أكثر من خمسة عمال يعيشون معاً في مناطق سكن عائلي مُحددة. يستثني صراحة العاملات (بغض النظر عن المهنة) والعمالة المنزلية أو المماثلة من تعريف مجموعة العمال هذا. لا يعني ذلك منع أي شابين شريكين أو أي عامل أعزب عموماً — القاعدة عن مجموعات أكبر في مناطق مُحددة. للبلدية سلطات؛ العقارات المزدحمة أو المقسمة بشكل غير رسمي تستحق الحذر.',
      'MD 105/2020: >5 workers in designated family residential areas; excludes female & domestic workers from definition. Not a general ban on flatmates.',
    ),
    'tenancy_shared_housing_partition_warning': _e(
      'An apartment or villa divided into multiple makeshift rooms or partitions without landlord and municipal approval may face enforcement action. A cheap bedspace advertisement is not proof the alteration was approved — heavily subdivided or overcrowded properties are worth avoiding regardless of price.',
      'تقسيم شقة أو فيلا إلى غرف أو حواجز مؤقتة دون موافقة المالك والبلدية قد يتعرض لإجراءات تنفيذية. إعلان سرير رخيص لا يثبت أن التعديل مُعتمد — العقارات المقسمة بكثافة أو المزدحمة تستحق التجنب بغض النظر عن السعر.',
      'Makeshift partitions without landlord/municipal approval may face enforcement. Cheap bedspace ads ≠ approved alteration.',
    ),
    'tenancy_shared_housing_unknown': _e(
      'Whether a specific shared-housing arrangement has genuine landlord consent — or whether a property complies with municipal rules — is something only you can verify directly with documents and the landlord or municipality. Raabta cannot confirm it for a particular listing or main tenant.',
      'هل لترتيب سكن مشترك معيّن موافقة مالك حقيقية — أو هل العقار يلتزم بقواعد البلدية — شيء تتحقق منه أنت بالمستندات والمالك أو البلدية. Raabta لا تستطيع تأكيد ذلك لإعلان أو مستأجر محدد.',
      'Whether a specific arrangement has genuine landlord consent — verify yourself; Raabta cannot confirm for a particular listing.',
    ),
    'tenancy_eviction_section_title': _e(
      'Eviction grounds & your protections',
      'أسباب الإخلاء وحمايتك',
      'Eviction grounds & protections',
    ),
    'tenancy_eviction_section_subtitle': _e(
      'If a landlord asks you to leave — including for renovation or demolition — these rules apply regardless of the stated reason.',
      'إذا طلب منك المالك المغادرة — بما في ذلك للترميم أو الهدم — تنطبق هذه القواعد بغض النظر عن السبب المذكور.',
      'If asked to leave for any reason — including renovation — these rules apply.',
    ),
    'tenancy_eviction_committee_first': _e(
      'A landlord may request the Rental Disputes Settlement Committee to order vacation or eviction for the grounds in Article 19 of Law No. 4 of 2008 (as amended by Law No. 20 of 2009). A landlord cannot simply treat a notice as a Committee eviction order. If you dispute the eviction or the landlord seeks eviction under Article 19, the statutory route is through the Rental Disputes Settlement Committee.',
      'يجوز للمالك أن يطلب من لجنة فض منازعات الإيجار الإخلاء للأسباب الواردة في المادة 19 من قانون 4/2008 (المعدّل بقانون 20/2009). لا يمكن للمالك أن يعامل إشعاراً كأنه أمر إخلاء من اللجنة. إذا اعترضت على الإخلاء أو سعى المالك للإخلاء بموجب المادة 19، فالمسار النظامي عبر لجنة فض منازعات الإيجار.',
      'Landlord may request Committee vacation order under Art. 19 (Law 4/2008, amended by Law 20/2009). Notice alone is not a Committee order — statutory route is through the Committee.',
    ),
    'tenancy_eviction_grounds_known': _e(
      'Article 19 grounds include: non-payment of rent; unauthorized subletting or other lease breach (see Article 14 in shared-housing guidance); structural damage or misuse of the property; demolition of a building meeting age/condition criteria; landlord requiring the property for personal/family use; or additions or modifications requiring licences. Secondary sources commonly cite approximately 90 days\' notice for some grounds — confirm the specific notice figure for your situation with the Committee, not from this app alone.',
      'تشمل أسباب المادة 19: عدم دفع الإيجار؛ التأجير من الباطن دون إذن أو خرق العقد (راجع المادة 14)؛ ضرر إنشائي أو سوء استخدام؛ هدم مبنى يستوفي معايير العمر/الحالة؛ حاجة المالك الشخصية/العائلية؛ أو إضافات/تعديلات تتطلب تراخيص. المصادر الثانوية تشير غالباً إلى نحو 90 يوماً إشعاراً لبعض الأسباب — أكد الرقم المحدد لحالتك مع اللجنة.',
      'Art. 19 grounds: non-payment, unauthorized sublet/breach (Art. 14), damage/misuse, demolition, personal use, licensed additions/modifications. ~90 days commonly cited — confirm with Committee.',
    ),
    'tenancy_eviction_renovation_heading': _e(
      'Additions & modifications (Article 19)',
      'الإضافات والتعديلات (المادة 19)',
      'Additions & modifications (Art. 19)',
    ),
    'tenancy_eviction_renovation_known': _e(
      'For additions or modifications under Article 19 (Law No. 4 of 2008, as amended by Law No. 20 of 2009): the landlord must obtain the required licences; the modification must not be possible while the tenant remains in the premises, as determined by the licensing authority; the tenant must receive at least six months from the date the required licences are obtained to vacate; the landlord must commence the licensed works within six months after the premises are vacated; if the landlord does not carry out the licensed works, or rents the premises to another tenant before doing so, the tenant may seek compensation if warranted.',
      'للإضافات أو التعديلات بموجب المادة 19 (قانون 4/2008 المعدّل بقانون 20/2009): يجب على المالك الحصول على التراخيص المطلوبة؛ لا يجوز أن يكون التعديل ممكناً أثناء بقاء المستأجر، وفق ما تحدده جهة الترخيص؛ يستحق المستأجر ستة أشهر على الأقل من تاريخ الحصول على التراخيص للإخلاء؛ يجب على المالك بدء الأعمال المرخصة خلال ستة أشهر من الإخلاء؛ إذا لم ينفذ المالك الأعمال المرخصة أو أعاد التأجير قبل ذلك، قد يسعى المستأجر للتعويض إن كان ذلك مستحقاً.',
      'Art. 19 additions/modifications: licences required; tenant gets ≥6 months from licence date to vacate; landlord must start works within 6 months after vacate; if not done or re-let first, tenant may seek compensation if warranted.',
    ),
    'tenancy_eviction_renovation_action': _e(
      'Keep any written notice, licence or permit information if available, your move-out date, and evidence of what happens to the property afterward — whether licensed work starts, or the premises are re-let. Use your case timeline to record these dates and observations.',
      'احتفظ بأي إشعار كتابي، ومعلومات الترخيص أو التصريح إن وُجدت، وتاريخ مغادرتك، ودليل على ما يحدث للعقار بعد ذلك — سواء بدأت أعمال مرخصة أو أُعيد التأجير. استخدم الجدول الزمني لتسجيل هذه التواريخ والملاحظات.',
      'Keep notice, licence/permit info, move-out date, and post-vacate evidence — use case timeline to log dates and observations.',
    ),
    'tenancy_eviction_renovation_unknown': _e(
      'Raabta cannot determine whether a particular renovation claim is genuine or whether compensation is legally due. Confirm the specifics of your case directly with the Rental Disputes Settlement Committee.',
      'لا تستطيع Raabta تحديد ما إذا كان ادعاء ترميم معيّناً حقيقياً أو ما إذا كان التعويض مستحقاً نظاماً. أكد تفاصيل حالتك مباشرة مع لجنة فض منازعات الإيجار.',
      'Raabta cannot determine if a renovation claim is genuine or compensation is due — confirm with the Committee.',
    ),

    // ── Rent increase at renewal (Art. 10, Law 4/2008) ─────────────────────
    'tenancy_rent_increase_section_title': _e(
      'Rent increases at renewal',
      'زيادة الإيجار عند التجديد',
      'Rent increases at renewal',
    ),
    'tenancy_rent_increase_section_subtitle': _e(
      'Article 10 rent-increase rules, lease terms, and Committee dispute options.',
      'قواعد المادة 10 لزيادة الإيجار وشروط العقد وخيارات اللجنة.',
      'Art. 10 rules, lease terms, and Committee dispute options.',
    ),
    'tenancy_rent_increase_cap_known': _e(
      'Article 10 (Law No. 4 of 2008) does not set a fixed percentage such as 10%. Rent increases are subject to the applicable rules, periods and rates established by the Council of Ministers. The applicable position can depend on the type of premises and the relevant decision. Do not assert a universal 10% maximum or convert historical Council percentages into a current residential cap.',
      'المادة 10 (قانون 4/2008) لا تحدد نسبة ثابتة مثل 10%. زيادات الإيجار تخضع للقواعد والفترات والأسعار التي يحددها مجلس الوزراء. الموقف المعمول به قد يختلف حسب نوع العقار والقرار ذي الصلة. لا تُدّعِ سقفاً عاماً 10% ولا تحوّل نسباً تاريخية إلى سقف سكني حالي.',
      'Art. 10: no fixed % like 10%; subject to Council of Ministers rules/rates; depends on premises type and relevant decision. Do not assert universal 10% max.',
    ),
    'tenancy_rent_increase_timing_known': _e(
      'Check your lease first. A landlord cannot simply impose an increase contrary to the applicable lease terms and legal rules. Whether an increase during an existing lease is valid can depend on the agreement and applicable rules — do not assume every mid-lease increase is automatically illegal.',
      'راجع عقدك أولاً. لا يمكن للمالk فرض زيادة مخالفة لشروط العقد والقواعد المعمول بها. صحة زيادة أثناء العقد قد تعتمد على الاتفاق والقواعد — لا تفترض أن كل زيادة أثناء العقد غير قانونية تلقائياً.',
      'Check lease first; landlord cannot impose increase contrary to lease terms and rules. Mid-lease validity depends on agreement and rules.',
    ),
    'tenancy_rent_increase_notice_known': _e(
      'Review the lease and any written notice carefully before renewal. If the proposed increase or notice is disputed, confirm the applicable rule with the Rental Disputes Settlement Committee.',
      'راجع العقد وأي إشعار كتابي بعناية قبل التجديد. إذا اعترضت على الزيادة أو الإشعار، أكد القاعدة المعمول بها مع لجنة فض منازعات الإيجار.',
      'Review lease and written notice before renewal; if disputed, confirm applicable rule with Committee.',
    ),
    'tenancy_rent_increase_benefit_possible': _e(
      'Possible: An increase tied to a genuine new benefit provided by the landlord (e.g., added parking, a guard\'s room, new fixtures the tenant did not previously have) may fall outside normal renewal-increase restrictions, since it corresponds to something new being offered — this helps distinguish a legitimate value-based increase from an arbitrary one.',
      'محتمل: زيادة مرتبطة بميزة جديدة حقيقية (موقف إضافي، غرفة حارس، تجهيزات جديدة) قد تختلف عن زيادة تعسفية — لتمييز الزيادة المبررة.',
      'Possible: Increase tied to genuine new benefit (parking, fixtures) may differ from arbitrary increase.',
    ),
    'tenancy_rent_increase_withhold_warning': _e(
      'Important: Do not simply stop paying rent because you dispute an increase. Continue following the applicable payment terms or use the Committee\'s statutory rent-deposit/dispute process if the landlord refuses to accept payment (Article 11, Law 4/2008). Withholding rent as protest can create late-payment liability.',
      'مهم: لا تتوقف عن دفع الإيجار لمجرد اعتراضك على زيادة. التزم بشروط الدفع المعمول بها أو استخدم آلية إيداع الإيجار/النزاع لدى اللجنة إذا رفض المالك استلام الدفع (المادة 11، قانون 4/2008). حجب الإيجار احتجاجاً قد يخلق مسؤولية تأخر.',
      'Do not stop paying due to disputed increase — follow payment terms or use Art. 11 Committee rent-deposit if landlord refuses.',
    ),
    'tenancy_rent_increase_action': _e(
      'If you disagree with a proposed increase: continue paying under the applicable terms, gather the written notice and lease, and file with the Rental Disputes Settlement Committee — the same Committee route used for other tenancy disputes. The Committee considers market rates, property condition, and the rental index when determining what is fair. Prepare your registered lease and documents using your dispute checklist.',
      'إذا رفضت الزيادة: استمر بدفع الإيجار الحالي، احتفظ بالإشعار الكتابي، وقدّم للجنة — نفس مسار نزاعات الإيجار الأخرى. تراعي اللجنة أسعار السوق وحالة العقار والمؤشر. جهّز عقدك المسجّل عبر قائمة النزاع.',
      'Disagree? Continue applicable payment; file with Committee. Use dispute checklist.',
    ),
    'tenancy_rent_increase_unknown': _e(
      'Unknown: Which Council of Ministers decision applies to your premises type and the current applicable rates or periods — confirm with the Committee rather than relying on historical percentages or general summaries.',
      'غير معروف: أي قرار مجلس الوزراء ينطبق على نوع عقارك والأسعار/الفترات الحالية — أكد مع اللجنة بدلاً من الاعتماد على نسب تاريخية.',
      'Unknown: Which Council decision applies to your premises — confirm with Committee.',
    ),
    'tenancy_rent_increase_checklist_link': _e(
      'Open dispute checklist — Committee filing preparation',
      'فتح قائمة النزاع — تحضير التقديم للجنة',
      'Dispute checklist — Committee filing prep',
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
