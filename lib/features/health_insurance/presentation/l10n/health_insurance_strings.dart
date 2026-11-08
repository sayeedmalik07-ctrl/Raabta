/// Health Insurance Truth Engine — 9-language catalog (RTL via AppLocale).
import 'package:flutter/foundation.dart';
import 'package:raabta/core/l10n/app_locale.dart';
import 'package:raabta/core/l10n/locale_catalog_coverage.dart';

abstract final class HealthInsuranceStrings {
  static const supportedLocales = AppLocale.supportedLocales;

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

  static const _en = 'English';
  static const _ar = 'Arabic';
  static const _hi = 'Hindi';

  static const _catalog = <String, Map<String, String>>{
    'hi_title': {
      'English': 'Health cover check',
      'Arabic': 'فحص التغطية الصحية',
      'Hindi': 'स्वास्थ्य कवर जाँच',
      'Urdu': 'صحت کور چیک',
      'Malayalam': 'ആരോഗ്യ കവർ പരിശോധന',
      'Nepali': 'स्वास्थ्य कभर जाँच',
      'Bengali': 'স্বাস্থ্য কভার যাচাই',
      'Tamil': 'சுகாதார கவர் சரிபார்ப்பு',
      'Filipino': 'Health cover check',
    },
    'hi_subtitle': {
      'English': 'What your insurer must pay',
      'Arabic': 'ما يجب أن يدفعه تأمينك',
      'Hindi': 'आपका बीमाकर्ता क्या दे',
      'Urdu': 'آپ کا انشورر کیا ادا کرے',
      'Malayalam': 'ഇൻഷurer നൽകേണ്ടത്',
      'Nepali': 'बीमाकर्ताले तिर्नुपर्ने',
      'Bengali': 'বীমাকারী কী দেবে',
      'Tamil': 'காப்பீட்டாளர் செலுத்த வேண்டியது',
      'Filipino': 'What your insurer must pay',
    },
    'hi_disclaimer': {
      _en:
          'Legal compliance check only — not legal or medical advice. Verify Law No. 22 of 2021 on Al Meezan. For disputes contact MOPH or Ministry of Labour (ADLSA).',
      _ar:
          'فحص امتثال إرشادي فقط — ليس استشارة قانونية أو طبية. تحقق من القانون 22/2021 على الميزان. للنزاعات تواصل مع MOPH أو وزارة العمل (ADLSA).',
      _hi:
          'केवल अनुपालन जांच — कानूनी/चिकित्सा सलाह नहीं। Law 22/2021 Al Meezan पर verify करें।',
    },
    'hi_policy_explainer_disclaimer': {
      _en:
          'This is a plain-language summary of your uploaded document only — not a coverage guarantee or legal/medical advice. For coverage disputes contact your insurer or the Ministry of Public Health (MOPH).',
      _ar:
          'هذا ملخص بلغة بسيطة لوثيقتك فقط — وليس ضمان تغطية أو استشارة قانونية/طبية.',
      _hi:
          'यह केवल आपके अपलोड दस्तावेज़ का सरल सारांश है — कवरेज गारंटी या कानूनी/चिकित्सा सलाह नहीं।',
    },
    'hi_dashboard_compliance_cta': {
      _en: 'Run Compliance Check',
      _ar: 'إجراء فحص الامتثال',
      _hi: 'अनुपालन जांच चलाएं',
    },
    'hi_dashboard_policy_cta': {
      _en: 'Understand My Policy',
      _ar: 'افهم وثيقتي',
      _hi: 'मेरी पॉलिसी समझें',
    },
    'hi_dashboard_upload_cta': {
      _en: 'Upload Policy Document',
      _ar: 'رفع وثيقة التأمين',
      _hi: 'पॉलिसी दस्तावेज़ अपलोड करें',
    },
    'hi_dashboard_visa_link': {
      _en: 'QID / Residency deadlines',
      _ar: 'مواعيد تجديد الإقامة',
      _hi: 'QID / निवास समय-सीमा',
    },
    'hi_form_title': {
      _en: 'Employer Compliance Check',
      _ar: 'فحص امتثال صاحب العمل',
      _hi: 'नियोक्ता अनुपालन जांच',
    },
    'hi_form_premium_label': {
      _en:
          'Has any amount for your health insurance premium ever been deducted from your salary, or have you been asked to pay toward its cost?',
      _ar:
          'هل تم خصم أي مبلغ من قسط التأمين الصحي من راتبك، أو طُلب منك المساهمة في تكلفته؟',
      _hi:
          'क्या आपके वेतन से स्वास्थ्य बीमा प्रीमियम की कोई राशि काटी गई, या लागत में योगदान देने को कहा गया?',
    },
    'hi_form_card_label': {
      _en: 'Do you have a health insurance card from your employer?',
      _ar: 'هل لديك بطاقة تأمين صحي من صاحب العمل؟',
      _hi: 'क्या आपके पास नियोक्ता की हेल्थ इंश्योरेंस कार्ड है?',
    },
    'hi_form_insurer_label': {
      _en: 'Insurance company name',
      _ar: 'اسم شركة التأمين',
      _hi: 'बीमा कंपनी का नाम',
    },
    'hi_form_qid_label': {
      _en: 'Was proof of health insurance required at your last QID renewal?',
      _ar: 'هل طُلب إثبات التأمين عند آخر تجديد للإقامة؟',
      _hi: 'क्या पिछले QID नवीनीकरण पर बीमा प्रमाण मांगा गया?',
    },
    'hi_form_switch_label': {
      _en: 'Has your employer changed insurance providers since you joined?',
      _ar: 'هل غيّر صاحب العمل شركة التأمين منذ التحاقك؟',
      _hi: 'क्या शामिल होने के बाद नियोक्ता ने बीमा प्रदाता बदला है?',
    },
    'hi_form_old_end_label': {
      _en: 'Previous policy coverage end date',
      _ar: 'تاريخ انتهاء الوثيقة السابقة',
      _hi: 'पिछली पॉलिसी समाप्ति तिथि',
    },
    'hi_form_new_start_label': {
      _en: 'New policy / card coverage start date',
      _ar: 'تاريخ بدء الوثيقة / البطاقة الجديدة',
      _hi: 'नई पॉलिसी / कार्ड प्रारंभ तिथि',
    },
    'hi_form_submit': {
      _en: 'Check Compliance',
      _ar: 'فحص الامتثال',
      _hi: 'अनुपालन जांचें',
    },
    'hi_yes': {_en: 'Yes', _ar: 'نعم', _hi: 'हाँ'},
    'hi_no': {_en: 'No', _ar: 'لا', _hi: 'नहीं'},
    'hi_not_sure': {_en: 'Not sure', _ar: 'غير متأكد', _hi: 'पक्का नहीं'},
    'hi_form_exemption_title': {
      _en: 'Does any of the following describe your situation?',
      _ar: 'هل ينطبق أي مما يلي على وضعك؟',
      _hi: 'क्या निम्न में से कोई आपकी स्थिति बताता है?',
    },
    'hi_form_exemption_subtitle': {
      _en:
          'Optional — most residents select "None of these apply to me" and continue with the employer compliance check.',
      _ar: 'اختياري — معظم المقيمين يختارون "لا ينطبق عليّ أي من هذه".',
      _hi: 'वैकल्पिक — अधिकांश "इनमें से कोई नहीं" चुनते हैं।',
    },
    'hi_exemption_none': {
      _en: 'None of these apply to me',
      _ar: 'لا ينطبق عليّ أي من هذه',
      _hi: 'इनमें से कोई मुझ पर लागू नहीं',
    },
    'hi_exemption_temporaryResidencePermit': {
      _en: 'I hold a temporary residence permit',
      _ar: 'أحمل تصريح إقامة مؤقت',
      _hi: 'मेरे पास अस्थायी निवास परमिट है',
    },
    'hi_exemption_visaOnArrival30DaysOrLess': {
      _en: 'I am visiting on a visa-on-arrival for 30 days or less',
      _ar: 'أزور بتأشيرة عند الوصول لمدة 30 يوماً أو أقل',
      _hi: 'मैं 30 दिन या कम के visa-on-arrival पर हूँ',
    },
    'hi_exemption_temporaryEntryTraveller': {
      _en: 'I am a temporary entry traveller',
      _ar: 'أنا مسافر دخول مؤقت',
      _hi: 'मैं अस्थायी प्रवेश यात्री हूँ',
    },
    'hi_exemption_transitPassenger': {
      _en: 'I am a transit passenger only',
      _ar: 'أنا مسافر ترانزيت فقط',
      _hi: 'मैं केवल ट्रांजिट यात्री हूँ',
    },
    'hi_exemption_diplomatSpouseOrChildUnder16': {
      _en: 'I am a diplomat, diplomat\'s spouse, or diplomat\'s child under 16',
      _ar: 'أنا دبلوماسي أو زوج/زوجة دبلوماسي أو طفل دبلوماسي دون 16',
      _hi: 'मैं राजनयिक, राजनयिक का जीवनसाथी, या 16 से कम उम्र का बच्चा हूँ',
    },
    'hi_exemption_nonQatariWomanMarriedToQatari': {
      _en: 'I am a non-Qatari woman married to a Qatari national',
      _ar: 'أنا امرأة غير قطرية متزوجة من قطري',
      _hi: 'मैं कतरी नागरिक से विवाहित गैर-कतरी महिला हूँ',
    },
    'hi_exemption_childOfQatariMotherNonQatariFather': {
      _en: 'I am a child of a Qatari mother married to a non-Qatari father',
      _ar: 'أنا طفل لأم قطرية متزوجة من غير قطري',
      _hi: 'मैं कतरी माँ और गैर-कतरी पिता की संतान हूँ',
    },
    'hi_exemption_widowOrDivorcedNonQatariWoman': {
      _en:
          'I am a widowed or divorced non-Qatari woman (not remarried to a non-Qatari national)',
      _ar: 'أنا أرملة أو مطلقة غير قطرية (غير متزوجة من غير قطري)',
      _hi: 'मैं विधवा/तलाकशुदा गैर-कतरी महिला हूँ (गैर-कतरी से पुनर्विवाहित नहीं)',
    },
    'hi_exemption_domesticWorkerInQatariHousehold': {
      _en: 'I am one of up to four domestic workers in a Qatari household',
      _ar: 'أنا من بين أربعة عمال منزليين كحد أقصى في أسرة قطرية',
      _hi: 'मैं कतरी परिवार में अधिकतम चार घरेलू कर्मचारियों में से एक हूँ',
    },
    'hi_exemption_detaineeOrPrisoner': {
      _en: 'I am currently a detainee or prisoner',
      _ar: 'أنا محتجز أو سجين حالياً',
      _hi: 'मैं वर्तमान में हिरासत में/कैदी हूँ',
    },
    'hi_exemption_orphanInCareHome': {
      _en: 'I am an orphan in a care home',
      _ar: 'أنا يتيم في دار رعاية',
      _hi: 'मैं देखभाल गृह में अनाथ हूँ',
    },
    'hi_exemption_childWithUnknownFather': {
      _en: 'I am a child whose father is unknown',
      _ar: 'أنا طفل مجهول الأب',
      _hi: 'मैं ऐसा बच्चा हूँ जिसके पिता अज्ञात हैं',
    },
    'hi_exemption_result_title': {
      _en: 'Possible mandatory insurance exemption',
      _ar: 'إمكانية إعفاء من التأمين الإلزامي',
      _hi: 'संभावित अनिवार्य बीमा छूट',
    },
    'hi_exemption_result_action': {
      _en:
          'Contact MOPH (moph.gov.qa) to confirm your status. Raabta did not run employer compliance violation checks for this session.',
      _ar: 'تواصل مع MOPH لتأكيد وضعك. لم يُجرِ Raabta فحص مخالفات الامتثال.',
      _hi: 'स्थिति पुष्टि के लिए MOPH से संपर्क करें।',
    },
    'hi_exemption_confirm_temporaryResidencePermit': {
      _en:
          'Based on what you selected, you may be exempt from Qatar\'s mandatory health insurance requirement as a temporary residence permit holder. This is general information, not a confirmed legal determination — MOPH can confirm your specific status.',
      _ar: 'قد تكون معفياً كحامل تصريح إقامة مؤقت — تحقق من MOPH.',
      _hi: 'अस्थायी निवास परमिट धारक के रूप में छूट संभव — MOPH से पुष्टि करें।',
    },
    'hi_exemption_confirm_visaOnArrival30DaysOrLess': {
      _en:
          'Based on what you selected, you may be exempt for the first 30 days on a visa-on-arrival. If you stay longer, insurance may become required. MOPH can confirm your specific status.',
      _ar: 'قد تكون معفياً لـ 30 يوماً بتأشيرة عند الوصول — تحقق من MOPH إذا طالت الإقامة.',
      _hi: 'Visa-on-arrival पर पहले 30 दिन छूट संभव — MOPH से पुष्टि करें।',
    },
    'hi_exemption_confirm_temporaryEntryTraveller': {
      _en:
          'Based on what you selected, you may be exempt as a temporary entry traveller. MOPH can confirm your specific status.',
      _ar: 'قد تكون معفياً كمسافر دخول مؤقت — تحقق من MOPH.',
      _hi: 'अस्थायी प्रवेश यात्री के रूप में छूट संभव — MOPH से पुष्टि करें।',
    },
    'hi_exemption_confirm_transitPassenger': {
      _en:
          'Based on what you selected, you may be exempt as a transit passenger. MOPH can confirm your specific status.',
      _ar: 'قد تكون معفياً كمسافر ترانزيت — تحقق من MOPH.',
      _hi: 'ट्रांजिट यात्री के रूप में छूट संभव — MOPH से पुष्टि करें।',
    },
    'hi_exemption_confirm_diplomatSpouseOrChildUnder16': {
      _en:
          'Based on what you selected, you may be exempt as a diplomat, diplomat\'s spouse, or child under 16. MOPH can confirm your specific status.',
      _ar: 'قد تكون معفياً كدبلوماسي أو زوج/طفل دبلوماسي — تحقق من MOPH.',
      _hi: 'राजनयिक परिवार के सदस्य के रूप में छूट संभव — MOPH से पुष्टि करें।',
    },
    'hi_exemption_confirm_nonQatariWomanMarriedToQatari': {
      _en:
          'Based on what you selected, you may be exempt as a non-Qatari woman married to a Qatari national. MOPH can confirm your specific status.',
      _ar: 'قد تكون معفياً كزوجة غير قطرية لقطري — تحقق من MOPH.',
      _hi: 'कतरी से विवाहित गैर-कतरी महिला के रूप में छूट संभव।',
    },
    'hi_exemption_confirm_childOfQatariMotherNonQatariFather': {
      _en:
          'Based on what you selected, you may be exempt as a child of a Qatari mother married to a non-Qatari father. MOPH can confirm your specific status.',
      _ar: 'قد تكون معفياً كطفل لأم قطرية — تحقق من MOPH.',
      _hi: 'कतरी माँ की संतान के रूप में छूट संभव — MOPH से पुष्टि करें।',
    },
    'hi_exemption_confirm_widowOrDivorcedNonQatariWoman': {
      _en:
          'Based on what you selected, you may be exempt as a widowed or divorced non-Qatari woman (unless remarried to a non-Qatari national). MOPH can confirm your specific status.',
      _ar: 'قد تكون معفياً كأرملة أو مطلقة غير قطرية — تحقق من MOPH.',
      _hi: 'विधवा/तलाकशुदा गैर-कतरी महिला के रूप में छूट संभव।',
    },
    'hi_exemption_confirm_domesticWorkerInQatariHousehold': {
      _en:
          'Based on what you selected, you may be exempt as a domestic worker in a Qatari household (up to four per household). MOPH can confirm your specific status.',
      _ar: 'قد تكون معفياً كعامل منزلي في أسرة قطرية — تحقق من MOPH.',
      _hi: 'कतरी परिवार में घरेलू कर्मचारी के रूप में छूट संभव।',
    },
    'hi_exemption_confirm_detaineeOrPrisoner': {
      _en:
          'Based on what you selected, you may be exempt as a detainee or prisoner. MOPH can confirm your specific status.',
      _ar: 'قد تكون معفياً كمحتجز أو سجين — تحقق من MOPH.',
      _hi: 'हिरासत/कैदी के रूप में छूट संभव — MOPH से पुष्टि करें।',
    },
    'hi_exemption_confirm_orphanInCareHome': {
      _en:
          'Based on what you selected, you may be exempt as an orphan in a care home. MOPH can confirm your specific status.',
      _ar: 'قد تكون معفياً كيتيم في دار رعاية — تحقق من MOPH.',
      _hi: 'देखभाल गृह में अनाथ के रूप में छूट संभव।',
    },
    'hi_exemption_confirm_childWithUnknownFather': {
      _en:
          'Based on what you selected, you may be exempt as a child whose father is unknown. MOPH can confirm your specific status.',
      _ar: 'قد تكون معفياً كطفل مجهول الأب — تحقق من MOPH.',
      _hi: 'अज्ञात पिता वाले बच्चे के रूप में छूट संभव — MOPH से पुष्टि करें।',
    },
    'hi_results_overview_exempt': {
      _en:
          'You indicated a possible exemption category — no employer compliance violations were flagged for this session. MOPH can confirm your status.',
      _ar: 'أشرت إلى فئة إعفاء محتملة — لم تُرصد مخالفات امتثال.',
      _hi: 'संभावित छूट श्रेणी — इस सत्र में कोई उल्लंघन ध्वजित नहीं।',
    },
    'hi_results_title': {
      _en: 'Compliance Results',
      _ar: 'نتائج الامتثال',
      _hi: 'अनुपालन परिणाम',
    },
    'hi_results_summary_heading': {
      _en: 'Your compliance check',
      _ar: 'فحص الامتثال الخاص بك',
      _hi: 'आपकी अनुपालन जांच',
    },
    'hi_share_card': {
      _en: 'Share / Download',
      _ar: 'مشاركة / تنزيل',
      _hi: 'शेयर / डाउनलोड',
    },
    'hi_share_compliance_caption': {
      _en: 'My Qatar employer health insurance compliance check — RAABTA',
      _ar: 'فحص امتثال التأمين الصحي لصاحب العمل — RAABTA',
      _hi: 'My Qatar employer health insurance compliance check — RAABTA',
    },
    'hi_share_policy_caption': {
      _en: 'Summary of my uploaded health insurance policy — RAABTA',
      _ar: 'ملخص وثيقة التأمين الصحي التي رفعتها — RAABTA',
      _hi: 'Summary of my uploaded health insurance policy — RAABTA',
    },
    'hi_share_confirm_title': {
      _en: 'Share card with flagged issue?',
      _ar: 'مشاركة بطاقة تحتوي على مشكلة؟',
      _hi: 'Share card with flagged issue?',
    },
    'hi_share_confirm_body': {
      _en:
          'This card includes a flagged compliance issue (e.g. salary deduction or coverage gap). Are you sure you want to share it?',
      _ar:
          'تتضمن هذه البطاقة مشكلة امتثال (مثل خصم الراتب أو فجوة التغطية). هل أنت متأكد أنك تريد مشاركتها؟',
      _hi:
          'This card includes a flagged compliance issue. Are you sure you want to share it?',
    },
    'hi_share_confirm_cancel': {
      _en: 'Cancel',
      _ar: 'إلغاء',
      _hi: 'Cancel',
    },
    'hi_share_confirm_proceed': {
      _en: 'Share anyway',
      _ar: 'مشاركة على أي حال',
      _hi: 'Share anyway',
    },
    'hi_results_overview_pass': {
      _en: 'No clear-cut violations detected in your answers.',
      _ar: 'لم يُكتشف مخالفات واضحة في إجاباتك.',
      _hi: 'आपके उत्तरों में कोई स्पष्ट उल्लंघन नहीं मिला।',
    },
    'hi_results_overview_violations': {
      _en: '{count} potential violation(s) flagged — review details below.',
      _ar: 'تم رصد {count} مخالفة محتملة — راجع التفاصيل أدناه.',
      _hi: '{count} संभावित उल्लंघन — नीचे विवरण देखें।',
    },
    'hi_results_overview_review': {
      _en: 'Some items need verification — review amber items below.',
      _ar: 'بعض البنود تحتاج تحققاً — راجع العناصر البرتقالية.',
      _hi: 'कुछ बिंदुओं की पुष्टि चाहिए — नीचे पीले आइटम देखें।',
    },
    'hi_status_compliant': {_en: 'Compliant', _ar: 'ممتثل', _hi: 'अनुपालित'},
    'hi_status_violation': {_en: 'Violation', _ar: 'مخالفة', _hi: 'उल्लंघन'},
    'hi_status_needs_verification': {
      _en: 'Needs verification',
      _ar: 'يحتاج تحقق',
      _hi: 'पुष्टि आवश्यक',
    },
    'hi_status_informational': {
      _en: 'Informational',
      _ar: 'إرشادي',
      _hi: 'सूचनात्मक',
    },
    'hi_status_not_applicable': {
      _en: 'Not applicable',
      _ar: 'غير منطبق',
      _hi: 'लागू नहीं',
    },
    'hi_check_premium_title': {
      _en: 'Employer premium payment (Art. 13)',
      _ar: 'دفع القسط من صاحب العمل (المادة 13)',
      _hi: 'नियोक्ता प्रीमियम भुगतान (अनुच्छेद 13)',
    },
    'hi_check_premium_pass': {
      _en: 'You indicated the employer pays the full premium with no salary deduction.',
      _ar: 'أشرت إلى أن صاحب العمل يدفع القسط كاملاً دون خصم من الراتب.',
      _hi: 'आपने बताया नियोक्ता पूर्ण प्रीमियम देता है, वेतन से कोई कटौती नहीं।',
    },
    'hi_check_premium_violation': {
      _en:
          'Article 13 of Law No. 22 of 2021 prohibits salary deductions or employee cost-sharing for the mandatory health insurance premium — this is a separate fineable offence from simply not providing coverage.',
      _ar:
          'المادة 13 من القانون 22/2021 تحظر خصم الراتب أو مشاركة الموظف في قسط التأمين الإلزامي.',
      _hi:
          'कानून 22/2021 की धारा 13 अनिवार्य प्रीमियम के लिए वेतन कटौती या लागत-साझेदारी प्रतिबंधित करती है।',
    },
    'hi_check_premium_not_sure': {
      _en:
          'You are not sure whether any premium was deducted — no violation is flagged until confirmed. Check a recent payslip for any line item related to health or medical insurance.',
      _ar: 'غير متأكد — لا تُرصد مخالفة حتى التأكيد. راجع كشف الراتب.',
      _hi: 'पक्का नहीं — पुष्टि तक कोई उल्लंघन नहीं। हाल का payslip देखें।',
    },
    'hi_check_premium_action_not_sure': {
      _en:
          'Scan a recent payslip to Document Vault (tag: Health Insurance). If you find an insurance deduction, return and answer Yes to the premium question.',
      _ar: 'امسح كشف الراتب إلى خزنة المستندات. إذا وُجد خصم، عد وأجب بنعم.',
      _hi: 'Payslip Document Vault में स्कैन करें। कटौती मिले तो Yes चुनें।',
    },
    'hi_check_premium_unanswered': {
      _en: 'Answer whether any premium is deducted from your salary.',
      _ar: 'أجب عما إذا كان يُخصم أي قسط من راتبك.',
      _hi: 'बताएं क्या आपके वेतन से प्रीमियम काटा जाता है।',
    },
    'hi_check_premium_action_pass': {
      _en: 'Keep payslips showing no unauthorized insurance deductions.',
      _ar: 'احتفظ بكشوف الرواتب التي لا تظهر خصومات تأمين.',
      _hi: 'ऐसे payslip रखें जिनमें अनधिकृत कटौती न हो।',
    },
    'hi_check_premium_action_violation': {
      _en:
          'Keep payslips showing the deduction — scan to Document Vault tagged Health Insurance. Raise with HR; you may file with MOPH and Ministry of Labour (ADLSA).',
      _ar: 'احتفظ بكشوف الرواتب — امسحها إلى خزنة المستندات. تواصل مع الموارد البشرية أو MOPH أو ADLSA.',
      _hi: 'कटौती वाले payslip रखें — Document Vault में Health Insurance टैग से स्कैन करें। HR/MOPH/ADLSA से संपर्क करें।',
    },
    'hi_check_premium_action': {
      _en: 'Confirm your answer to complete this check.',
      _ar: 'أكد إجابتك لإكمال هذا الفحص.',
      _hi: 'इस जांच को पूरा करने के लिए उत्तर पुष्टि करें।',
    },
    'hi_check_card_title': {
      _en: 'Health insurance card issued (Art. 13)',
      _ar: 'إصدار بطاقة التأمين الصحي (المادة 13)',
      _hi: 'हेल्थ इंश्योरेंस कार्ड जारी (अनुच्छेद 13)',
    },
    'hi_check_card_pass': {
      _en: 'You have a physical or digital insurance card from your employer.',
      _ar: 'لديك بطاقة تأمين ورقية أو رقمية من صاحب العمل.',
      _hi: 'आपके पास नियोक्ता की भौतिक या डिजिटल बीमा कार्ड है।',
    },
    'hi_check_card_violation': {
      _en: 'Employers must issue a health insurance card and prove coverage.',
      _ar: 'يجب على أصحاب العمل إصدار بطاقة تأمين وإثبات التغطية.',
      _hi: 'नियोक्ताओं को बीमा कार्ड जारी करना और कवरेज साबित करना अनिवार्य है।',
    },
    'hi_check_card_unanswered': {
      _en: 'Confirm whether you received an insurance card.',
      _ar: 'أكد ما إذا استلمت بطاقة تأمين.',
      _hi: 'पुष्टि करें क्या आपको बीमा कार्ड मिली।',
    },
    'hi_check_card_action_pass': {
      _en: 'Store a scan in Document Vault tagged Health Insurance.',
      _ar: 'احفظ نسخة في خزنة المستندات بوسم التأمين الصحي.',
      _hi: 'Document Vault में Health Insurance टैग से स्कैन सहेजें।',
    },
    'hi_check_card_action_violation': {
      _en: 'Request your card from HR and keep proof for QID renewal.',
      _ar: 'اطلب البطاقة من الموارد البشرية واحتفظ بإثبات للتجديد.',
      _hi: 'HR से कार्ड मांगें और QID नवीनीकरण के लिए प्रमाण रखें।',
    },
    'hi_check_card_action': {
      _en: 'Answer whether you have an insurance card.',
      _ar: 'أجب عما إذا لديك بطاقة تأمين.',
      _hi: 'बताएं क्या आपके पास बीमा कार्ड है।',
    },
    'hi_check_insurer_title': {
      _en: 'MOPH-registered insurer (Art. 11)',
      _ar: 'شركة تأمين مسجلة لدى وزارة الصحة (المادة 11)',
      _hi: 'MOPH-पंजीकृत बीमाकर्ता (अनुच्छेद 11)',
    },
    'hi_check_insurer_pass': {
      _en: 'Your insurer appears on the bundled MOPH registered list (last verified date shown in Legal Sources).',
      _ar: 'شركة التأمين تظهر في قائمة وزارة الصحة المسجلة.',
      _hi: 'आपका बीमाकर्ता MOPH पंजीकृत सूची में है।',
    },
    'hi_check_insurer_not_found': {
      _en: 'Insurer not found on the current bundled list — verify directly with MOPH before concluding non-compliance.',
      _ar: 'لم تُعثر الشركة في القائمة الحالية — تحقق من وزارة الصحة مباشرة.',
      _hi: 'वर्तमान सूची में बीमाकर्ता नहीं मिला — MOPH से सीधे verify करें।',
    },
    'hi_check_insurer_stale_list': {
      _en: 'The MOPH insurer list has not been recently verified — this check needs manual confirmation.',
      _ar: 'لم تُحدَّث قائمة شركات التأمين مؤخراً — يلزم تحقق يدوي.',
      _hi: 'MOPH सूची हाल में verify नहीं हुई — मैन्युअल पुष्टि आवश्यक।',
    },
    'hi_check_insurer_unanswered': {
      _en: 'Enter your insurance company name.',
      _ar: 'أدخل اسم شركة التأمين.',
      _hi: 'बीमा कंपनी का नाम दर्ज करें।',
    },
    'hi_check_insurer_action_pass': {
      _en: 'Keep your policy documents for renewal proof.',
      _ar: 'احتفظ بوثائق الوثيقة لإثبات التجديد.',
      _hi: 'नवीनीकरण प्रमाण के लिए पॉलिसी दस्तावेज़ रखें।',
    },
    'hi_check_insurer_action_not_found': {
      _en: 'Ask HR for the insurer registration proof or check MOPH published registry.',
      _ar: 'اطلب من الموارد البشرية إثبات تسجيل الشركة أو راجع سجل وزارة الصحة.',
      _hi: 'HR से पंजीकरण प्रमाण मांगें या MOPH रजिस्टri देखें।',
    },
    'hi_check_insurer_action_stale': {
      _en: 'We cannot auto-confirm until the insurer list is refreshed.',
      _ar: 'لا يمكن التأكيد تلقائياً حتى تحديث القائمة.',
      _hi: 'सूची refresh होने तक auto-confirm नहीं हो सकता।',
    },
    'hi_check_insurer_action': {
      _en: 'Select or type your insurer name.',
      _ar: 'اختر أو اكتب اسم شركة التأمين.',
      _hi: 'बीमाकर्ता का नाम चुनें या लिखें।',
    },
    'hi_check_insurer_mapped_pass': {
      _en: 'Your card label was mapped to a MOPH-registered underlying insurer (see note below).',
      _ar: 'تم ربط اسم بطاقتك بشركة تأمين مسجلة لدى وزارة الصحة (انظر الملاحظة).',
      _hi: 'आपके कार्ड लेबल को MOPH-पंजीकृत अंतिम बीमाकर्ता से मैप किया गया (नीचे नोट देखें)।',
    },
    'hi_check_insurer_tpa_ambiguous': {
      _en: 'This is a Third-Party Administrator (TPA), not an insurer itself — ask HR for your underlying MOPH-registered insurer name.',
      _ar: 'هذا مسؤول طرف ثالث (TPA) وليس شركة تأمين — اطلب من الموارد البشرية اسم شركة التأمين الفعلية.',
      _hi: 'यह TPA है, स्वयं बीमाकर्ता नहीं — HR से अंतिम MOPH-पंजीकृत बीमाकर्ता का नाम पूछें।',
    },
    'hi_check_insurer_action_tpa': {
      _en: 'Check your policy certificate or ask HR for the legal insurer name behind the TPA.',
      _ar: 'راجع شهادة الوثيقة أو اسأل الموارد البشرية عن اسم شركة التأمين القانونية.',
      _hi: 'पॉलिसी प्रमाणपत्र देखें या HR से TPA के पीछे कानूनी बीमाकर्ता का नाम पूछें।',
    },
    'hi_check_insurer_manual_review': {
      _en: 'Your insurer/plan name is noted for manual catalogue review — MOPH registration could not be auto-verified.',
      _ar: 'تم تسجيل اسمك للمراجعة اليدوية — لم يمكن التحقق التلقائي من تسجيل وزارة الصحة.',
      _hi: 'आपका नाम मैन्युअल review के लिए नोट किया गया — MOPH पंजीकरण auto-verify नहीं हो सका।',
    },
    'hi_check_insurer_action_manual': {
      _en: 'Ask HR for MOPH registration proof while we update the insurer catalogue.',
      _ar: 'اطلب من الموارد البشرية إثبات تسجيل وزارة الصحة أثناء تحديث القائمة.',
      _hi: 'सूची update होने तक HR से MOPH पंजीकरण प्रमाण मांगें।',
    },
    'hi_insurer_search_hint': {
      _en: 'Type insurer, TPA, or plan name on your card',
      _ar: 'اكتب اسم شركة التأمين أو TPA أو الخطة على بطاقتك',
      _hi: 'कार्ड पर बीमाकर्ता, TPA, या plan नाम लिखें',
    },
    'hi_insurer_not_listed': {
      _en: "Don't see your insurer or plan name?",
      _ar: 'لا تجد شركة التأمين أو الخطة؟',
      _hi: 'अपना बीमाकर्ता या plan नहीं मिल रहा?',
    },
    'hi_insurer_manual_label': {
      _en: 'Enter name exactly as on your card',
      _ar: 'أدخل الاسم كما على بطاقتك',
      _hi: 'कार्ड पर जैसा है वैसा नाम दर्ज करें',
    },
    'hi_insurer_manual_hint': {
      _en: 'e.g. plan or TPA name from your insurance card',
      _ar: 'مثال: اسم الخطة أو TPA من بطاقتك',
      _hi: 'उदा. कार्ड पर plan या TPA नाम',
    },
    'hi_insurer_manual_note': {
      _en: 'This will be flagged for manual review — we cannot auto-verify MOPH registration until the catalogue is updated.',
      _ar: 'سيُ flagged للمراجعة اليدوية — لا يمكن التحقق التلقائي حتى تحديث القائمة.',
      _hi: 'Manual review के लिए flagged — catalogue update तक auto-verify नहीं।',
    },
    'hi_insurer_load_error': {
      _en: 'Insurer catalogue unavailable — enter your card label for manual review.',
      _ar: 'قائمة شركات التأمين غير متاحة — أدخل الاسم للمراجعة اليدوية.',
      _hi: 'बीमाकर्ता catalogue उपलब्ध नहीं — manual review के लिए नाम दर्ज करें।',
    },
    'hi_results_empty_title': {
      _en: 'No results yet',
      _ar: 'لا توجد نتائج بعد',
      _hi: 'अभी कोई परिणाम नहीं',
    },
    'hi_results_empty_desc': {
      _en: 'Run a check to see your compliance results here.',
      _ar: 'أجرِ فحصاً لعرض نتائج الامتثال هنا.',
      _hi: 'यहाँ परिणाम देखने के लिए जांच चलाएं।',
    },
    'hi_moph_list_freshness': {
      _en: 'MOPH insurer list last verified: {date}',
      _ar: 'آخر تحقق من قائمة وزارة الصحة: {date}',
      _hi: 'MOPH सूची last verified: {date}',
    },
    'hi_policy_upload_subtitle': {
      _en: 'Scan your policy via PDF Studio first — then Raabta can explain what it covers.',
      _ar: 'امسح وثيقتك عبر PDF Studio أولاً — ثم يمكن لرابطتة شرح التغطية.',
      _hi: 'पहले PDF Studio से पॉलिसी स्कैन करें — फिर Raabta कवरेज समझा सकता है।',
    },
    'hi_policy_after_upload_cta': {
      _en: 'Understand My Policy',
      _ar: 'افهم وثيقتي',
      _hi: 'मेरी पॉलिसी समझें',
    },
    'hi_check_qid_title': {
      _en: 'QID renewal proof (Art. 10 — informational)',
      _ar: 'إثبات التأمين عند تجديد الإقامة (المادة 10 — إرشادي)',
      _hi: 'QID नवीनीकरण प्रमाण (अनुच्छेद 10 — सूचनात्मक)',
    },
    'hi_check_qid_pass': {
      _en: 'Proof was required — suggests enforcement at renewal.',
      _ar: 'طُلب الإثبات — يدل على تطبيق عند التجديد.',
      _hi: 'प्रमाण मांगा गया — नवीनीकरण पर लागू होने का संकेत।',
    },
    'hi_check_qid_flag': {
      _en: 'If proof was not required, your employer may not be demonstrating compliance at renewal.',
      _ar: 'إذا لم يُطلب إثبات، قد لا يُظهر صاحب العمل الامتثال عند التجديد.',
      _hi: 'यदि प्रमाण नहीं मांगा गया, नियोक्ता नवीनीकरण पर अनुपालन न दिखा रहा हो।',
    },
    'hi_check_qid_unanswered': {
      _en: 'Optional — helps flag renewal enforcement gaps.',
      _ar: 'اختياري — يساعد في رصد فجوات التطبيق عند التجديد.',
      _hi: 'वैकल्पिक — नवीनीकरण enforcement gaps दिखाने में मदद।',
    },
    'hi_check_qid_action_pass': {
      _en: 'Keep renewal receipts with insurance proof.',
      _ar: 'احتفظ بإيصالات التجديد مع إثبات التأمين.',
      _hi: 'बीमा प्रमाण के साथ renewal receipts रखें।',
    },
    'hi_check_qid_action_flag': {
      _en: 'Confirm with Metrash/MOI whether insurance proof is on file.',
      _ar: 'تحقق عبر متras2/الداخلية من وجود إثبات التأمين.',
      _hi: 'Metrash/MOI से पुष्टि करें insurance proof file में है या नहीं।',
    },
    'hi_check_qid_action': {
      _en: 'Answer if you remember your last renewal experience.',
      _ar: 'أجب إن تذكرت تجربة آخر تجديد.',
      _hi: 'यदि याद हो तो पिछले renewal का अनुभव बताएं।',
    },
    'hi_check_gap_title': {
      _en: 'Insurer switch coverage gap (Art. 10/11)',
      _ar: 'فجوة التغطية عند تغيير شركة التأمين (10/11)',
      _hi: 'बीमाकर्ता बदलने पर कवरेज gap (10/11)',
    },
    'hi_check_gap_not_applicable': {
      _en: 'No insurer switch reported — annual re-tender alone is not a violation.',
      _ar: 'لم يُبلغ عن تغيير شركة — إعادة المناقصة السنوية ليست مخالفة.',
      _hi: 'बीमाकर्ता बदलने की सूचना नहीं — केवल व annual re-tender उल्लंघन नहीं।',
    },
    'hi_check_gap_pass': {
      _en: 'Coverage dates connect or overlap — no gap detected between policies.',
      _ar: 'تواريخ التغطية متصلة أو متداخلة — لا فجوة بين الوثائق.',
      _hi: 'कवरेज तिथियाँ जुड़ी या overlap — policies के बीच gap नहीं।',
    },
    'hi_check_gap_violation': {
      _en:
          'A gap exists between your old policy end and new policy start — you may have had no active coverage during that window. Raise with HR/insurance admin; claims in that period may be affected.',
      _ar:
          'توجد فجوة بين انتهاء الوثيقة السابقة وبدء الجديدة — ربما لم تكن مغطى خلالها. تواصل مع الموارد البشرية.',
      _hi:
          'पुरानी पॉलिसी समाप्ति और नई शुरुआत के बीच gap — उस अवधि में कवरेज नहीं हो सकती। HR से बात करें।',
    },
    'hi_check_gap_dates_missing': {
      _en: 'Enter both previous end date and new start date to check for a gap.',
      _ar: 'أدخل تاريخي الانتهاء والبدء للتحقق من الفجوة.',
      _hi: 'gap जांच के लिए दोनों तिथियाँ दर्ज करें।',
    },
    'hi_check_gap_action_na': {
      _en: 'If your insurer changes next renewal, compare coverage dates.',
      _ar: 'إذا تغيّرت الشركة في التجديد القادم، قارن تواريخ التغطية.',
      _hi: 'अगली renewal पर बीमाकर्ता बदले तो कवरेज तिथियाँ compare करें।',
    },
    'hi_check_gap_action_pass': {
      _en: 'Different insurer each year is normal when contracts are re-tendered.',
      _ar: 'تغيير الشركة سنوياً طبيعي عند إعادة المناقصة.',
      _hi: 'contract re-tender पर हर साल अलग insurer सामान्य है।',
    },
    'hi_check_gap_action_violation': {
      _en: 'Ask HR to confirm retroactive coverage or gap certificate.',
      _ar: 'اطلب من الموارد البشرية تأكيد التغطية بأثر رجعي أو شهادة الفجوة.',
      _hi: 'HR से retroactive coverage या gap certificate confirm करवाएं।',
    },
    'hi_check_gap_action_missing': {
      _en: 'Find dates on old and new insurance cards or HR letters.',
      _ar: 'ابحث عن التواريخ على البطاقات أو خطابات الموارد البشرية.',
      _hi: 'पुरानी/नई कार्ड या HR letters पर तिथियाँ देखें।',
    },
    'hi_policy_empty_title': {
      _en: 'No policy document yet',
      _ar: 'لا توجد وثيقة تأمين بعد',
      _hi: 'अभी कोई पॉलिसी दस्तावेज़ नहीं',
    },
    'hi_policy_empty_desc': {
      _en:
          'Upload your employer health insurance policy or card via PDF Studio. We will summarize only what your document states — no invented coverage numbers.',
      _ar: 'ارفع وثيقة أو بطاقة التأمين عبر استوديو PDF. نلخص فقط ما تنص عليه الوثيقة.',
      _hi: 'PDF Studio से पॉलिसी/कार्ड अपलोड करें। हम केवल दस्तावेज़ में लिखा सारांश देंगे।',
    },
    'hi_policy_explainer_title': {
      _en: 'Policy Explainer',
      _ar: 'شرح الوثيقة',
      _hi: 'पॉलिसी व्याख्या',
    },
    'hi_policy_section_coverage': {
      _en: 'Coverage categories',
      _ar: 'فئات التغطية',
      _hi: 'Coverage categories',
    },
    'hi_policy_section_exclusions': {
      _en: 'Exclusions stated',
      _ar: 'الاستثناءات المذكورة',
      _hi: 'Exclusions stated',
    },
    'hi_policy_section_network': {
      _en: 'Network / hospitals',
      _ar: 'الشبكة / المستشفيات',
      _hi: 'Network / hospitals',
    },
    'hi_policy_section_notes': {
      _en: 'Notes',
      _ar: 'ملاحظات',
      _hi: 'Notes',
    },
    'hi_policy_analyze': {
      _en: 'Generate plain-language summary',
      _ar: 'إنشاء ملخص بلغة بسيطة',
      _hi: 'सरल भाषा सारांश बनाएं',
    },
    'hi_upload_hint': {
      _en: 'Scan as Health Insurance Card in PDF Studio',
      _ar: 'امسح كبطاقة تأمين صحي في استوديو PDF',
      _hi: 'PDF Studio में Health Insurance Card के रूप में स्कैन करें',
    },
    'hi_legal_source_label': {
      _en: 'Law No. 22 of 2021 — Healthcare Services',
      _ar: 'القانون 22 لسنة 2021 — الخدمات الصحية',
      _hi: 'कानून 22/2021 — स्वास्थ्य सेवाएँ',
    },
    'hi_denial_title': {
      _en: 'Claim Denial Dispute Assistant',
      _ar: 'مساعد نزاع رفض المطالبة',
      _hi: 'दावा अस्वीकृति सहायक',
    },
    'hi_denial_subtitle': {
      _en:
          'Track denial milestones and documents — personal record only, not legal advice.',
      _ar: 'تتبع محطات الرفض والمستندات — سجل شخصي فقط.',
      _hi: 'अस्वीकृति milestones और दस्तावेज़ ट्रैक करें।',
    },
    'hi_denial_need_compliance': {
      _en: 'Run an employer compliance check first to link this dispute to your case.',
      _ar: 'أجرِ فحص امتثال صاحب العمل أولاً لربط هذا النزاع.',
      _hi: 'पहले employer compliance check चलाएँ।',
    },
    'hi_denial_steps_title': {
      _en: 'Dispute steps',
      _ar: 'خطوات النزاع',
      _hi: 'विवाद चरण',
    },
    'hi_denial_mark_done': {
      _en: 'Mark as done',
      _ar: 'تم',
      _hi: 'पूर्ण',
    },
    'hi_denial_dashboard_cta': {
      _en: 'My Claim Was Denied — What Now?',
      _ar: 'رُفضت مطالبتي — ماذا الآن؟',
      _hi: 'मेरा दावा अस्वीकृत — अब क्या?',
    },
    'hi_denial_step_denial': {
      _en: 'Denial received — note the date on the letter',
      _ar: 'استلام الرفض — سجّل تاريخ الخطاب',
      _hi: 'अस्वीकृति प्राप्त — पत्र की तारीख',
    },
    'hi_denial_step_complaint': {
      _en: 'Complaint filed with insurer or employer HR',
      _ar: 'تقديم شكوى للم insurer أو HR',
      _hi: 'बीमाकर्ता/HR के साथ शिकायत',
    },
    'hi_denial_step_regulator': {
      _en: 'Escalated to MOPH / regulator if needed',
      _ar: 'تصعيد إلى MOPH عند الحاجة',
      _hi: 'MOPH/regulator तक escalation',
    },
    'hi_denial_timeline_denial': {
      _en: 'Claim denial received',
      _ar: 'استلام رفض المطالبة',
      _hi: 'दावा अस्वीकृत',
    },
    'hi_denial_timeline_complaint': {
      _en: 'Complaint filed',
      _ar: 'تقديم شكوى',
      _hi: 'शिकायत दर्ज',
    },
    'hi_denial_timeline_regulator': {
      _en: 'Regulator escalation',
      _ar: 'تصعيد للجهة الرقابية',
      _hi: 'नियामक escalation',
    },
    'hi_denial_doc_letter': {
      _en: 'Written denial letter or email',
      _ar: 'خطاب أو بريد رفض مكتوب',
      _hi: 'लिखित अस्वीकृति पत्र',
    },
    'hi_denial_doc_letter_sub': {
      _en: 'Official insurer/employer denial with date and reason codes if shown',
      _ar: 'رفض رسمي مع التاريخ',
      _hi: 'आधिकारिक अस्वीकृति तिथि सहित',
    },
    'hi_denial_doc_policy': {
      _en: 'Health insurance card / policy schedule',
      _ar: 'بطاقة أو جدول الوثيقة',
      _hi: 'बीमा कार्ड/पॉलिसी',
    },
    'hi_denial_doc_policy_sub': {
      _en: 'Shows covered members and validity period',
      _ar: 'يظهر الم covered والصلاحية',
      _hi: 'सदस्य और वैधता',
    },
    'hi_denial_doc_premium': {
      _en: 'Premium payment proof',
      _ar: 'إثبات دفع القسط',
      _hi: 'प्रीमियम भुगतान प्रमाण',
    },
    'hi_denial_doc_premium_sub': {
      _en: 'Payroll deduction or employer payment confirmation',
      _ar: 'خصم راتب أو تأكيد دفع',
      _hi: 'वेतन कटौती/भुगतान',
    },
    'hi_denial_doc_medical': {
      _en: 'Medical reports for the claimed service',
      _ar: 'تقارير طبية للخدمة',
      _hi: 'चिकित्सा रिपोर्ट',
    },
    'hi_denial_doc_medical_sub': {
      _en: 'Hospital/clinic reports supporting the claim',
      _ar: 'تقارير المستشفى/العيادة',
      _hi: 'अस्पताल रिपोर्ट',
    },
    'hi_denial_doc_correspondence': {
      _en: 'Correspondence with insurer',
      _ar: 'مراسلات مع شركة التأمين',
      _hi: 'बीमाकर्ता पत्राचार',
    },
    'hi_denial_doc_correspondence_sub': {
      _en: 'Emails, portal messages, or call reference numbers you logged',
      _ar: 'بريد أو رسائل أو أرقام مرجعية',
      _hi: 'ईमेल/संदेश/संदर्भ',
    },
    'hi_denial_doc_complaint': {
      _en: 'Complaint filing proof',
      _ar: 'إثبات تقديم الشكوى',
      _hi: 'शिकायत प्रमाण',
    },
    'hi_denial_doc_complaint_sub': {
      _en: 'Reference number or dated letter to insurer/HR',
      _ar: 'رقم مرجعي أو خطاب مؤرخ',
      _hi: 'संदर्भ/दिनांकित पत्र',
    },
    'hi_denial_doc_regulator': {
      _en: 'MOPH / regulator escalation proof',
      _ar: 'إثبات تصعيد MOPH',
      _hi: 'MOPH escalation प्रमाण',
    },
    'hi_denial_doc_regulator_sub': {
      _en: 'Optional — if you escalated beyond the insurer',
      _ar: 'اختياري — عند التصعيد',
      _hi: 'वैकल्पिक',
    },
    'hi_denial_step1_title': {
      _en: 'Step 1 — Get the written denial letter',
      _ar: 'الخطوة 1 — احصل على خطاب الرفض كتابياً',
      _hi: 'चरण 1 — लिखित अस्वीकृति पत्र प्राप्त करें',
    },
    'hi_denial_step1_desc': {
      _en:
          'Request the denial in writing from your insurer, with the specific policy clause or exclusion cited. Verbal or SMS denials are not enough to escalate further.',
      _ar:
          'اطلب الرفض كتابياً من شركة التأمين مع ذكر بند أو استثناء الوثيقة. الرفض الشفهي أو عبر SMS لا يكفي للتصعيد.',
      _hi:
          'बीमाकर्ता से लिखित अस्वीकृति मांगें, जिसमें विशिष्ट पॉलिसी खंड/अपवाद उल्लिखित हो। मौखिक/SMS अस्वीकृति पर्याप्त नहीं।',
    },
    'hi_denial_step2_title': {
      _en: 'Step 2 — File with the insurer\'s Complaints Department',
      _ar: 'الخطوة 2 — تقديم شكوى لقسم الشكاوى لدى شركة التأمين',
      _hi: 'चरण 2 — बीमाकर्ता की शिकायत विभाग में दर्ज करें',
    },
    'hi_denial_step2_desc': {
      _en:
          'Every insurer operating in Qatar is required to have an internal complaints process. Attach your denial letter, policy schedule, and (for medical-necessity denials) any treatment notes or referral from your doctor.',
      _ar:
          'كل شركة تأمين في قطر ملزمة بإجراء شكاوى داخلي. أرفق خطاب الرفض وجدول الوثيقة، ولرفض الضرورة الطبية أي ملاحظات علاج أو إحالة.',
      _hi:
          'कतर में हर बीमाकर्ता के पास आंतरिक शिकायत प्रक्रिया होनी चाहिए। अस्वीकृति पत्र, पॉलिसी शेड्यूल, और (चिकित्सा-आवश्यकता के लिए) उपचार नोट्स/रेफरल संलग्न करें।',
    },
    'hi_denial_step2_medical_tip': {
      _en:
          'A letter from your treating physician confirming the clinical necessity and urgency of the treatment significantly strengthens this kind of complaint. This is optional but recommended.',
      _ar:
          'خطاب من طبيبك المعالج يؤكد الضرورة السريرية والإلحاح يقوّي هذا النوع من الشكاوى. اختياري لكن موصى به.',
      _hi:
          'आपके चिकित्सक का पत्र जो उपचार की नैदानिक आवश्यकता और तात्कालिकता की पुष्टि करे, इस प्रकार की शिकायत को मजबूत बनाता है। वैकल्पिक लेकिन अनुशंसित।',
    },
    'hi_denial_step3_qcb_title': {
      _en: 'Step 3 — Escalate to Qatar Central Bank (QCB)',
      _ar: 'الخطوة 3 — التصعيد إلى مصرف قطر المركزي',
      _hi: 'चरण 3 — QCB को एस्केलेट करें',
    },
    'hi_denial_step3_qcb_desc': {
      _en:
          'If your insurer\'s Complaints Department does not resolve the issue, you can escalate to the Qatar Central Bank\'s Customer Protection Department, which handles complaints against QCB-licensed financial institutions including insurers. QCB also has a formal Dispute Resolution Committee (established under Article 190 of QCB Law No. 13 of 2012) that can review unresolved cases.',
      _ar:
          'إذا لم يحل قسم الشكاوى المشكلة، يمكنك التصعيد إلى إدارة حماية العملاء في QCB. كما توجد لجنة تسوية المنازعات (بموجب المادة 190 من القانون 13/2012).',
      _hi:
          'यदि शिकायत विभाग समस्या हल नहीं करता, QCB Customer Protection Department को एस्केलेट करें। QCB Law 13/2012 Article 190 के तहत Dispute Resolution Committee भी है।',
    },
    'hi_denial_step3_qcb_cite': {
      _en: 'QCB Law No. 13 of 2012, Customer Protection Department, Article 190 Dispute Resolution Committee',
      _ar: 'قانون QCB 13/2012، إدارة حماية العملاء، المادة 190',
      _hi: 'QCB Law No. 13 of 2012, Customer Protection Department, Article 190',
    },
    'hi_denial_step3_qfcra_title': {
      _en: 'Step 3 — Escalate to QFCRA Customer Dispute Resolution Scheme (CDRS)',
      _ar: 'الخطوة 3 — التصعيد إلى CDRS لدى QFCRA',
      _hi: 'चरण 3 — QFCRA CDRS को एस्केलेट करें',
    },
    'hi_denial_step3_qfcra_desc': {
      _en:
          'Your insurer is registered with the Qatar Financial Centre, so complaints go to the QFC Regulatory Authority\'s Customer Dispute Resolution Scheme (CDRS) instead of QCB. The CDRS is free to use, you do not need a lawyer, and an independent adjudicator (separate from the regulator) reviews the case. If you accept the CDRS decision, it is binding on the insurer.',
      _ar:
          'شركة التأمين مسجلة في QFC، لذا تذهب الشكاوى إلى CDRS بدلاً من QCB. CDRS مجاني ولا تحتاج محامياً، ومحكّم مستقل يراجع القضية. قرار CDRS ملزم للشركة إذا قبلته.',
      _hi:
          'आपका बीमाकर्ता QFC में पंजीकृत है, इसलिए शिकायतें QCB के बजाय QFCRA CDRS को जाती हैं। CDRS मुफ्त है, वकील की जरूरत नहीं, स्वतंत्र adjudicator मामला देखता है।',
    },
    'hi_denial_step3_qfcra_cite': {
      _en: 'QFCRA Customer Dispute Resolution Scheme (CDRS), qfcra.com',
      _ar: 'QFCRA CDRS، qfcra.com',
      _hi: 'QFCRA CDRS, qfcra.com',
    },
    'hi_denial_step4_title': {
      _en: 'Step 4 — Mandatory employer-provided coverage (MOPH)',
      _ar: 'الخطوة 4 — التغطية الإلزامية من صاحب العمل (MOPH)',
      _hi: 'चरण 4 — नियोक्ता-प्रदत्त अनिवार्य कवरेज (MOPH)',
    },
    'hi_denial_step4_desc': {
      _en:
          'If this is your employer-provided mandatory health insurance (not a personal/supplementary policy) and you believe your employer or insurer isn\'t meeting the legal minimum obligations, this may also be a matter for the Ministry of Public Health, separate from the QCB/QFCRA complaint above. You can raise this alongside — not instead of — the regulator complaint in Step 3.',
      _ar:
          'إذا كان هذا تأميناً إلزامياً من صاحب العمل وتعتقد أن الحد الأدنى القانوني لا يُستوفى، قد يكون أيضاً من اختصاص MOPH — بالتوازي وليس بدلاً من شكوى Step 3.',
      _hi:
          'यदि यह नियोक्ता-प्रदत्त अनिवार्य बीमा है और न्यूनतम कानूनी दायित्व पूरे नहीं हो रहे, यह MOPH का भी मामला हो सकता है — Step 3 के साथ, उसके स्थान पर नहीं।',
    },
    'hi_denial_intake_title': {
      _en: 'Tell us about the denial',
      _ar: 'أخبرنا عن الرفض',
      _hi: 'अस्वीकृति के बारे में बताएं',
    },
    'hi_denial_intake_reason': {
      _en: 'Denial reason category',
      _ar: 'فئة سبب الرفض',
      _hi: 'अस्वीकृति कारण श्रेणी',
    },
    'hi_denial_reason_medicalNecessity': {
      _en: 'Medical necessity',
      _ar: 'الضرورة الطبية',
      _hi: 'चिकित्सा आवश्यकता',
    },
    'hi_denial_reason_policyExclusion': {
      _en: 'Policy exclusion',
      _ar: 'استثناء في الوثيقة',
      _hi: 'पॉलिसी अपवाद',
    },
    'hi_denial_reason_preAuthNotObtained': {
      _en: 'Pre-authorization not obtained',
      _ar: 'عدم الحصول على موافقة مسبقة',
      _hi: 'पूर्व-अनुमोदन नहीं मिला',
    },
    'hi_denial_reason_documentationIncomplete': {
      _en: 'Documentation incomplete',
      _ar: 'وثائق ناقصة',
      _hi: 'दस्तावेज़ अधूरे',
    },
    'hi_denial_reason_coverageLapsed': {
      _en: 'Coverage lapsed or not active',
      _ar: 'التغطية منتهية أو غير نشطة',
      _hi: 'कवरेज समाप्त/निष्क्रिय',
    },
    'hi_denial_reason_other': {
      _en: 'Other (your description)',
      _ar: 'أخرى (وصفك)',
      _hi: 'अन्य (आपका विवरण)',
    },
    'hi_denial_intake_other_label': {
      _en: 'Describe the denial reason',
      _ar: 'صف سبب الرفض',
      _hi: 'अस्वीकृति कारण बताएं',
    },
    'hi_denial_intake_other_hint': {
      _en: 'User-entered — not validated against any legal basis',
      _ar: 'مدخل من المستخدم — غير مُحقق قانونياً',
      _hi: 'उपयोगकर्ता-दर्ज — कानूनी आधार पर सत्यापित नहीं',
    },
    'hi_denial_intake_date': {
      _en: 'Date of denial (if known)',
      _ar: 'تاريخ الرفض (إن وُجد)',
      _hi: 'अस्वीकृति की तिथि (यदि ज्ञात)',
    },
    'hi_denial_intake_date_unknown': {
      _en: 'Not set',
      _ar: 'غير محدد',
      _hi: 'सेट नहीं',
    },
    'hi_denial_intake_written_letter': {
      _en: 'Have you received a written denial letter?',
      _ar: 'هل استلمت خطاب رفض كتابي؟',
      _hi: 'क्या लिखित अस्वीकृति पत्र मिला?',
    },
    'hi_denial_intake_employer': {
      _en: 'Is this employer-provided mandatory coverage?',
      _ar: 'هل هذا تأمين إلزامي من صاحب العمل؟',
      _hi: 'क्या यह नियोक्ता-प्रदत्त अनिवार्य कवरेज है?',
    },
    'hi_denial_intake_policy': {
      _en: 'Policy number (optional)',
      _ar: 'رقم الوثيقة (اختياري)',
      _hi: 'पॉलिसी नंबर (वैकल्पिक)',
    },
    'hi_denial_intake_amount': {
      _en: 'Claim amount (optional)',
      _ar: 'مبلغ المطالبة (اختياري)',
      _hi: 'दावा राशि (वैकल्पिक)',
    },
    'hi_denial_intake_submit': {
      _en: 'Start dispute tracker',
      _ar: 'بدء متتبع النزاع',
      _hi: 'विवाद ट्रैकर शुरू करें',
    },
    'hi_denial_intake_insurer': {
      _en: 'Insurer',
      _ar: 'شركة التأمين',
      _hi: 'बीमाकर्ता',
    },
    'hi_denial_intake_insurer_required': {
      _en: 'Please enter your insurer name',
      _ar: 'يرجى إدخال اسم شركة التأمين',
      _hi: 'बीमाकर्ता का नाम दर्ज करें',
    },
    'hi_denial_intake_letter_required': {
      _en: 'Please indicate whether you have a written denial letter',
      _ar: 'يرجى تحديد ما إذا كان لديك خطاب رفض كتابي',
      _hi: 'कृपया बताएं कि लिखित पत्र मिला या नहीं',
    },
    'hi_denial_checklist_title': {
      _en: 'Document checklist',
      _ar: 'قائمة المستندات',
      _hi: 'दस्तावेज़ चेकलिस्ट',
    },
    'hi_denial_scan_upload': {
      _en: 'Scan/Upload',
      _ar: 'مسح/رفع',
      _hi: 'स्कैन/अपलोड',
    },
    'hi_denial_doc_employer': {
      _en: 'Employer confirmation of coverage',
      _ar: 'تأكيد صاحب العمل للتغطية',
      _hi: 'कवरेज की नियोक्ता पुष्टि',
    },
    'hi_denial_doc_employer_sub': {
      _en: 'HR letter or proof of employer-provided policy',
      _ar: 'خطاب HR أو إثبات وثيقة صاحب العمل',
      _hi: 'HR पत्र या नियोक्ता-पॉलिसी प्रमाण',
    },
    'hi_denial_doc_preauth': {
      _en: 'Pre-authorization request and response',
      _ar: 'طلب الموافقة المسبقة ورد الشركة',
      _hi: 'पूर्व-अनुमोदन अनुरोध और प्रतिक्रिया',
    },
    'hi_denial_doc_preauth_sub': {
      _en: 'If a pre-auth was submitted before treatment',
      _ar: 'إذا قُدّم طلب موافقة مسبقة',
      _hi: 'यदि उपचार से पहले pre-auth दिया गया',
    },
    'hi_denial_ai_title': {
      _en: 'AI assistant',
      _ar: 'المساعد الذكي',
      _hi: 'AI सहायक',
    },
    'hi_denial_ai_disclaimer': {
      _en:
          'This is general information, not legal or medical advice. Escalation outcomes depend on your specific policy and circumstances.',
      _ar:
          'معلومات عامة وليست استشارة قانونية أو طبية. النتائج تعتمد على وثيقتك وظروفك.',
      _hi:
          'यह सामान्य जानकारी है, कानूनी/चिकित्सा सलाह नहीं। परिणाम आपकी पॉलिसी पर निर्भर।',
    },
    'hi_denial_privacy_note': {
      _en:
          'Documents are processed through Raabta\'s secure backend — the same as every other AI feature in this app.',
      _ar:
          'تُعالَج المستندات عبر خادم Raabta الآمن — كباقي ميزات AI في التطبيق.',
      _hi:
          'दस्तावेज़ Raabta के सुरक्षित backend से प्रोसेस होते हैं — जैसे अन्य AI फीचर।',
    },
    'hi_denial_clause_label': {
      _en: 'Policy clause / exclusion text (paste or from OCR)',
      _ar: 'نص البند/الاستثناء (لصق أو OCR)',
      _hi: 'पॉलिसी खंड/अपवाद (पेस्ट या OCR)',
    },
    'hi_denial_explain_clause': {
      _en: 'Explain this clause',
      _ar: 'شرح هذا البند',
      _hi: 'इस खंड की व्याख्या',
    },
    'hi_denial_explain_step': {
      _en: 'Explain this step',
      _ar: 'شرح هذه الخطوة',
      _hi: 'इस चरण की व्याख्या',
    },
    'hi_denial_draft_insurer': {
      _en: 'Draft my complaint letter (insurer)',
      _ar: 'صياغة خطاب شكوى (شركة التأمين)',
      _hi: 'शिकायत पत्र (बीमाकर्ता)',
    },
    'hi_denial_draft_regulator': {
      _en: 'Draft letter (regulator)',
      _ar: 'صياغة خطاب (الجهة الرقابية)',
      _hi: 'पत्र (नियामक)',
    },
    'hi_denial_draft_label': {
      _en: 'Editable letter draft',
      _ar: 'مسودة خطاب قابلة للتعديل',
      _hi: 'संपादन योग्य पत्र मसौदा',
    },
    'hi_denial_clause_empty': {
      _en: 'Paste clause text from your denial letter first.',
      _ar: 'الصق نص البند من خطاب الرفض أولاً.',
      _hi: 'पहले अस्वीकृति पत्र से खंड पेस्ट करें।',
    },
    'hi_denial_step_locked': {
      _en: 'Complete Step 1 first — get the written denial letter.',
      _ar: 'أكمل الخطوة 1 أولاً — احصل على خطاب الرفض كتابياً.',
      _hi: 'पहले चरण 1 पूरा करें — लिखित पत्र प्राप्त करें।',
    },
    'hi_denial_part_a_violation_link': {
      _en:
          'Your employer compliance check flagged potential violations — review those results for context.',
      _ar:
          'فحص امتثال صاحب العمل أشار إلى مخالفات محتملة — راجع تلك النتائج.',
      _hi:
          'नियोक्ता compliance check में संभावित उल्लंघन — संदर्भ के लिए वे परिणाम देखें।',
    },
    'hi_denial_export_pdf': {
      _en: 'Export PDF summary',
      _ar: 'تصدير ملخص PDF',
      _hi: 'PDF सारांश निर्यात',
    },
    'hi_denial_export_title': {
      _en: 'Claim Denial Dispute Record',
      _ar: 'سجل نزاع رفض المطالبة',
      _hi: 'दावा अस्वीकृति रिकॉर्ड',
    },
    'hi_denial_export_disclaimer': {
      _en:
          'Personal record only — Raabta does not file complaints on your behalf.',
      _ar: 'سجل شخصي فقط — Raabta لا يقدم شكاوى نيابة عنك.',
      _hi: 'केवल व्यक्तिगत रिकॉर्ड — Raabta आपकी ओर से शिकायत दाखिल नहीं करता।',
    },
    'hi_denial_export_share_caption': {
      _en: 'My health insurance claim denial dispute record — RAABTA',
      _ar: 'سجل نزاع رفض مطالبتي — RAABTA',
      _hi: 'My claim denial dispute record — RAABTA',
    },
    'hi_denial_start_over': {
      _en: 'Start a new dispute',
      _ar: 'بدء نزاع جديد',
      _hi: 'नया विवाद शुरू करें',
    },
    'hi_denial_entry_cta': {
      _en: 'Claim denied? Track your next steps',
      _ar: 'رُفضت مطالبتك؟ تتبع خطواتك',
      _hi: 'दावा अस्वीकृत? अगले कदम ट्रैक करें',
    },
    'hi_share_denial_caption': {
      _en: 'My health insurance claim denial dispute summary — RAABTA',
      _ar: 'ملخص نزاع رفض مطالبتي — RAABTA',
      _hi: 'My claim denial summary — RAABTA',
    },
    'hi_hub_explore': {_en: 'Explore', _ar: 'استكشف', _hi: 'Explore'},
    'hi_scenarios': {
      _en: 'What-if scenarios',
      _ar: 'سيناريوهات ماذا لو',
      _hi: 'What-if scenarios',
    },
    'hi_scenarios_desc': {
      _en:
          'Compare hypothetical Part A compliance outcomes. Not saved as real checks.',
      _ar: 'قارن نتائج الامتثال الافتراضية (الجزء أ). لا تُحفظ كفحوصات حقيقية.',
      _hi: 'Compare hypothetical compliance. Not saved.',
    },
    'hi_scenarios_empty_title': {
      _en: 'Complete compliance check first',
      _ar: 'أكمل فحص الامتثال أولاً',
      _hi: 'Complete compliance check first',
    },
    'hi_scenarios_empty_desc': {
      _en:
          'Run Part A compliance with standard (non-exempt) answers to explore scenarios.',
      _ar: 'أجرِ فحص الامتثال (غير المعفى) لاستكشاف السيناريوهات.',
      _hi: 'Run non-exempt compliance check first.',
    },
    'hi_scenario_base': {
      _en: 'Your current case',
      _ar: 'حالتك الحالية',
      _hi: 'Your current case',
    },
    'hi_scenario_hypothetical': {
      _en: 'Hypothetical only — not a saved compliance check',
      _ar: 'افتراضي فقط — ليس فحص امتثال محفوظ',
      _hi: 'Hypothetical only — not saved',
    },
    'hi_scenario_tap_expand': {
      _en: 'Tap to expand details',
      _ar: 'اضغط للتفاصيل',
      _hi: 'Tap to expand',
    },
    'hi_scenario_switch_insurer_title': {
      _en: 'If you switch insurer',
      _ar: 'إذا غيّرت شركة التأمين',
      _hi: 'If you switch insurer',
    },
    'hi_scenario_switch_insurer_desc': {
      _en: 'Hypothetical switch to another MOPH-registered insurer',
      _ar: 'تبديل افتراضي لشركة مسجلة لدى وزارة الصحة',
      _hi: 'Switch to another MOPH insurer',
    },
    'hi_scenario_switch_gap_title': {
      _en: 'If you switch with a coverage gap',
      _ar: 'إذا بدّلت مع فجوة تغطية',
      _hi: 'Switch with coverage gap',
    },
    'hi_scenario_switch_gap_desc': {
      _en: 'Prior policy ended 10 days ago; new policy started 2 days ago',
      _ar: 'انتهت الوثيقة قبل 10 أيام؛ بدأت الجديدة قبل يومين',
      _hi: '8-day gap between policies',
    },
    'hi_scenario_moph_stale_title': {
      _en: 'If MOPH insurer list is stale',
      _ar: 'إذا كانت قائمة وزارة الصحة قديمة',
      _hi: 'If MOPH list is stale',
    },
    'hi_scenario_moph_stale_desc': {
      _en: 'Insurer verification older than 180 days — educational impact',
      _ar: 'التحقق من الشركات أقدم من 180 يوماً — للتوعية',
      _hi: 'List verified >180 days ago',
    },
    'hi_scenario_diff_violation_added': {
      _en: 'Violation appears',
      _ar: 'تظهر مخالفة',
      _hi: 'Violation appears',
    },
    'hi_scenario_diff_violation_removed': {
      _en: 'Violation removed',
      _ar: 'تزول المخالفة',
      _hi: 'Violation removed',
    },
    'hi_scenario_diff_moph_stale': {
      _en: 'Stale MOPH list warning appears',
      _ar: 'يظهر تحذير قائمة قديمة',
      _hi: 'Stale list warning appears',
    },
    'hi_scenario_diff_coverage_gap': {
      _en: 'Coverage gap violation appears',
      _ar: 'تظهر مخالفة فجوة التغطية',
      _hi: 'Coverage gap violation',
    },
    'hi_scenario_diff_status_changed': {
      _en: 'Status changed vs current',
      _ar: 'تغيرت الحالة عن الحالية',
      _hi: 'Status changed',
    },
    'hi_history': {
      _en: 'Compliance history',
      _ar: 'سجل الامتثال',
      _hi: 'Compliance history',
    },
    'hi_empty_history': {
      _en: 'No past checks yet',
      _ar: 'لا فحوصات سابقة',
      _hi: 'No past checks',
    },
    'hi_empty_history_desc': {
      _en:
          'Checks are saved when your employer is linked from EOSB. Run Part A compliance to build history.',
      _ar: 'تُحفظ الفحوصات عند ربط صاحب العمل من EOSB. أجرِ فحص الامتثال لبناء السجل.',
      _hi: 'Checks save when employer is linked from EOSB.',
    },
    'hi_history_error': {
      _en: 'Could not load history',
      _ar: 'تعذر تحميل السجل',
      _hi: 'Could not load history',
    },
    'hi_history_summary_violation': {
      _en: 'Violation flagged',
      _ar: 'مخالفة',
      _hi: 'Violation flagged',
    },
    'hi_history_summary_compliant': {
      _en: 'Compliant',
      _ar: 'ممتثل',
      _hi: 'Compliant',
    },
    'hi_history_detail_title': {
      _en: 'Past compliance check',
      _ar: 'فحص امتثال سابق',
      _hi: 'Past check',
    },
    'hi_history_detail_note': {
      _en:
          'Saved summary only — item-level breakdown was not stored at check time.',
      _ar: 'ملخص محفوظ فقط — لم يُخزَّن تفصيل البنود وقت الفحص.',
      _hi: 'Saved summary only — full breakdown not stored.',
    },
    'hi_history_detail_employer': {
      _en: 'Employer',
      _ar: 'صاحب العمل',
      _hi: 'Employer',
    },
    'hi_history_detail_status': {
      _en: 'Status at check time',
      _ar: 'الحالة وقت الفحص',
      _hi: 'Status at check time',
    },
    'hi_nav_title': {
      _en: 'Healthcare Navigation',
      _ar: 'التنقل في الرعاية الصحية',
      _hi: 'Healthcare Navigation',
    },
    'hi_nav_subtitle': {
      _en: 'Qatar-specific guidance for expats — not medical advice.',
      _ar: 'إرشادات خاصة بقطر للمقيمين — ليست استشارة طبية.',
      _hi: 'Qatar-specific guidance for expats — not medical advice.',
    },
    'hi_nav_disclaimer': {
      _en:
          'Informational only — not authoritative. For emergencies call 999. Verify registration and coverage on official MOPH and HMC portals.',
      _ar:
          'إرشادي فقط — وليس مصدراً رسمياً. للطوارئ اتصل 999. تحقق من التسجيل والتغطية على بوابات MOPH و HMC الرسمية.',
      _hi:
          'Informational only — not authoritative. For emergencies call 999. Verify on official MOPH and HMC portals.',
    },
    'hi_nav_system_title': {
      _en: 'Public vs private care',
      _ar: 'الرعاية العامة مقابل الخاصة',
      _hi: 'Public vs private care',
    },
    'hi_nav_system_body': {
      _en:
          'Hamad Medical Corporation (HMC) runs Qatar\'s main public hospitals and emergency services. Private hospitals and clinics serve insured and self-pay patients — employer health insurance (Law No. 22 of 2021) typically covers private network care when your policy allows.',
      _ar:
          'تدير مؤسسة حمد الطبية (HMC) المستشفيات العامة الرئيسية وخدمات الطوارئ في قطر. تخدم المستشفيات والعيادات الخاصة المؤمن عليهم — التأمين الصحي لصاحب العمل (القانون 22/2021) يغطي عادة شبكة القطاع الخاص وفق وثيقتك.',
      _hi:
          'Hamad Medical Corporation (HMC) runs Qatar\'s main public hospitals and emergency services. Private hospitals serve insured patients — employer insurance (Law 22/2021) typically covers private network care per your policy.',
    },
    'hi_nav_healthcard_title': {
      _en: 'Health card registration',
      _ar: 'تسجيل البطاقة الصحية',
      _hi: 'Health card registration',
    },
    'hi_nav_healthcard_body': {
      _en:
          'Residents usually obtain a Qatar health card through MOPH/HMC registration for subsidised public care. Requirements and fees depend on residency and employment status — check the official MOPH e-services portal for current steps.',
      _ar:
          'يحصل المقيمون عادة على بطاقة صحية قطرية عبر تسجيل MOPH/HMC للرعاية العامة المدعومة. تختلف المتطلبات والرسوم حسب الإقامة — راجع بوابة MOPH الرسمية.',
      _hi:
          'Residents obtain a Qatar health card through MOPH/HMC registration for subsidised public care. Check the official MOPH e-services portal for current steps.',
    },
    'hi_nav_emergency_title': {
      _en: 'Emergencies',
      _ar: 'الطوارئ',
      _hi: 'Emergencies',
    },
    'hi_nav_emergency_body': {
      _en:
          'For life-threatening emergencies, call 999 (ambulance/police). Use MOI 109 for general Ministry of Interior inquiries. Go to the nearest emergency department — HMC emergency units handle acute public care.',
      _ar:
          'للطوارئ المهددة للحياة، اتصل 999. استخدم 109 لاستفسارات وزارة الداخلية. توجه لأقرب قسم طوارئ — وحدات HMC للرعاية الحادة.',
      _hi:
          'For life-threatening emergencies, call 999. Use MOI 109 for general inquiries. Nearest emergency department — HMC handles acute public care.',
    },
    'hi_crc_title': {
      _en: 'What Your Basic Coverage May Not Include',
      _ar: 'ما قد لا يشمله تأمينك الأساسي',
      _hi: 'आपका बेसिक कवरेज क्या शामिल नहीं हो सकता',
    },
    'hi_crc_subtitle': {
      _en:
          'Common patterns to check before you need care — not a review of your specific policy.',
      _ar:
          'أنماط شائعة للتحقق قبل الحاجة للرعاية — وليس مراجعة لوثيقتك المحددة.',
      _hi:
          'देखभाल से पहले जांचने के सामान्य पैटर्न — आपकी विशिष्ट पॉलिसी की समीक्षा नहीं।',
    },
    'hi_crc_dashboard_subtitle': {
      _en:
          'Pre-emptive checklist of typical gaps and limits in Qatar\'s mandatory basic scheme.',
      _ar:
          'قائمة استباقية للفجوات والحدود النموذجية في نظام التأمين الإلزامي الأساسي.',
      _hi:
          'Qatar की अनिवार्य बेसिक योजना में सामान्य अंतराल/सीमाओं की पूर्व-जांच सूची।',
    },
    'hi_dashboard_crc_cta': {
      _en: 'Check Coverage Gaps',
      _ar: 'تحقق من فجوات التغطية',
      _hi: 'कवरेज अंतराल जांचें',
    },
    'hi_crc_intro': {
      _en:
          'Raabta does not know what your insurer covers unless you have uploaded or entered policy details in the Policy Explainer. This guide lists statutory minimums (Known) and common exclusion patterns (Possible) you should verify with HR or your insurer now.',
      _ar:
          'Raabta لا تعرف ما يغطيه مؤمّنك ما لم ترفع أو تدخل تفاصيل الوثيقة في شرح الوثيقة. يسرد هذا الدليل الحد الأدنى القانوني (معروف) وأنماط الاستثناء الشائعة (محتمل) التي يجب التحقق منها مع HR أو المؤمّن الآن.',
      _hi:
          'जब तक आपने Policy Explainer में विवरण नहीं दिए, Raabta नहीं जानती कि आपका बीमाकर्ता क्या कवर करता है। यह गाइड कानूनी न्यूनतम (Known) और सामान्य अपवाद पैटर्न (Possible) सूचीबद्ध करती है — HR/बीमाकर्ता से अभी verify करें।',
    },
    'hi_crc_known_body': {
      _en:
          'Under Law No. 22 of 2021\'s minimum benefits mandate, employer-sponsored basic policies must include at minimum: outpatient and inpatient care; diagnostics and radiology; essential medicines; hospital stays; mandatory surgical procedures; basic maternity care; emergency care; and coverage for children up to 18.',
      _ar:
          'بموجب حزمة الحد الأدنى للمنافع في القانون 22/2021، يجب أن تشمل وثائق صاحب العمل الأساسية على الأقل: العيادات الخارجية والتنويم؛ التشخيص والأشعة؛ الأدوية الأساسية؛ الإقامة بالمستشفى؛ العمليات الجراحية الإلزامية؛ رعاية الأمومة الأساسية؛ الطوارئ؛ وتغطية الأطفال حتى 18.',
      _hi:
          'Law 22/2021 के न्यूनतम लाभों के तहत बेसिक नियोक्ता-पॉलिसियों में कम से कम शामिल होना चाहिए: outpatient/inpatient; diagnostics/radiology; essential medicines; hospital stays; mandatory surgery; basic maternity; emergency; और 18 तक बच्चों की कवरेज।',
    },
    'hi_crc_legal_known_note': {
      _en:
          'Source: Law No. 22 of 2021 minimum benefits package (verify on Al Meezan / moph.gov.qa).',
      _ar:
          'المصدر: حزمة الحد الأدنى للمنافع — القانون 22/2021 (تحقق على الميزان / moph.gov.qa).',
      _hi:
          'Source: Law 22/2021 minimum benefits (Al Meezan / moph.gov.qa पर verify करें).',
    },
    'hi_crc_possible_framing': {
      _en:
          'These are commonly excluded or limited across standard basic policies — check your specific policy; they are not universal facts about every insurer.',
      _ar:
          'غالباً ما تُستثنى أو تُحدّ في الوثائق الأساسية — تحقق من وثيقتك؛ ليست حقائق عامة عن كل مؤمّن.',
      _hi:
          'मानक बेसिक पॉलिसियों में अक्सर बाहर/सीमित — अपनी पॉलिसी जांचें; हर बीमाकर्ता पर सार्वभौमिक तथ्य नहीं।',
    },
    'hi_crc_possible_item_1': {
      _en: 'Cosmetic surgery',
      _ar: 'الجراحة التجميلية',
      _hi: 'Cosmetic surgery',
    },
    'hi_crc_possible_item_2': {
      _en: 'Fertility treatment beyond initial diagnostics',
      _ar: 'علاج الخصوبة بخلاف التشخيص الأولي',
      _hi: 'Fertility treatment beyond initial diagnostics',
    },
    'hi_crc_possible_item_3': {
      _en: 'Congenital conditions discovered after the policy started',
      _ar: 'حالات خلقية اكتُشفت بعد بدء الوثيقة',
      _hi: 'Congenital conditions discovered after policy start',
    },
    'hi_crc_possible_item_4': {
      _en: 'Dental care beyond emergency treatment',
      _ar: 'رعاية الأسنان بخلاف علاج الطوارئ',
      _hi: 'Dental care beyond emergency treatment',
    },
    'hi_crc_possible_item_5': {
      _en: 'Optical care beyond basic vision correction',
      _ar: 'رعاية البصر بخلاف تصحيح الرؤية الأساسي',
      _hi: 'Optical care beyond basic vision correction',
    },
    'hi_crc_possible_item_6': {
      _en: 'Alternative or complementary medicine',
      _ar: 'الطب البديل أو التكميلي',
      _hi: 'Alternative/complementary medicine',
    },
    'hi_crc_possible_item_7': {
      _en: 'Self-inflicted injuries',
      _ar: 'الإصابات الذاتية',
      _hi: 'Self-inflicted injuries',
    },
    'hi_crc_possible_item_8': {
      _en:
          'Maternity sub-limits (a cap on maternity-related costs even though basic maternity is mandated)',
      _ar:
          'حدود فرعية للأمومة (سقف لتكاليف الأمومة رغم إلزامية رعاية الأمومة الأساسية)',
      _hi:
          'Maternity sub-limits (cap on maternity costs despite basic maternity mandate)',
    },
    'hi_crc_legal_possible_note': {
      _en:
          'Informational common-pattern summary only — exclusions and sub-limits are policy- and insurer-specific, not uniformly mandated by law.',
      _ar:
          'ملخص إرشادي لأنماط شائعة فقط — الاستثناءات والحدود الفرعية خاصة بالوثيقة والمؤمّن، وليست موحدة قانونياً.',
      _hi:
          'Informational common-pattern only — exclusions/sub-limits are policy-specific, not uniformly mandated.',
    },
    'hi_crc_action_intro': {
      _en:
          'Practical checks to do with HR or your insurer now — before you need care:',
      _ar:
          'فحوصات عملية مع HR أو المؤمّن الآن — قبل الحاجة للرعاية:',
      _hi:
          'HR/बीमाकर्ता के साथ अभी practical checks — देखभाल से पहले:',
    },
    'hi_crc_action_item_1': {
      _en:
          'Ask whether Hamad Medical Corporation (HMC) is in-network and whether elective treatment there requires prior approval',
      _ar:
          'اسأل إن كان HMC ضمن الشبكة وهل العلاج الاختياري يتطلب موافقة مسبقة',
      _hi:
          'Ask if HMC is in-network and if elective treatment needs prior approval',
    },
    'hi_crc_action_item_2': {
      _en: 'Ask about the maternity benefit sub-limit if relevant to you',
      _ar: 'اسأل عن الحد الفرعي لمنافع الأمومة إن كان ذا صلة',
      _hi: 'Ask about maternity benefit sub-limit if relevant',
    },
    'hi_crc_action_item_3': {
      _en:
          'Ask about the co-insurance or co-payment percentage on inpatient and outpatient visits',
      _ar:
          'اسأل عن نسبة التحمل المشترك أو الدفع المشترك للعيادات والتنويم',
      _hi:
          'Ask co-insurance/co-payment % for inpatient and outpatient visits',
    },
    'hi_crc_action_item_4': {
      _en:
          'Confirm whether a pre-existing condition you have is excluded and for how long',
      _ar:
          'أكّد إن كانت حالة سابقة مستثناة ولمدة كم',
      _hi:
          'Confirm if your pre-existing condition is excluded and for how long',
    },
    'hi_crc_action_item_5': {
      _en:
          'Confirm dependents (spouse, up to 3 children under 18) are actually included on the policy, not just the primary worker',
      _ar:
          'أكّد إدراج المعالين (الزوج/الزوجة، حتى 3 أطفال دون 18) وليس العامل فقط',
      _hi:
          'Confirm dependents (spouse, up to 3 children under 18) are on the policy',
    },
    'hi_crc_upload_hint': {
      _en:
          'Optional: upload your policy schedule in Policy Explainer to see document-specific figures alongside these general checks.',
      _ar:
          'اختياري: ارفع جدول وثيقتك في شرح الوثيقة لرؤية أرقام محددة بجانب هذه الفحوصات العامة.',
      _hi:
          'Optional: upload policy in Policy Explainer for document-specific figures.',
    },
    'hi_crc_dependent_section_title': {
      _en: 'Dependent coverage — gaps families often miss',
      _ar: 'تغطية المعالين — فجوات تغفلها العائلات',
      _hi: 'Dependent coverage — gaps families often miss',
    },
    'hi_crc_dependent_intro': {
      _en:
          'Separate from the exclusion categories above: how employer plans typically treat spouses, children, and parents. General patterns only — not a statement about your specific policy.',
      _ar:
          'منفصل عن فئات الاستثناء أعلاه: كيف تتعامل وثائق صاحب العمل عادة مع الزوج/الزوجة والأطفال والوالدين. أنماط عامة فقط — وليس بياناً عن وثيقتك.',
      _hi:
          'Separate from exclusion categories above — how plans treat spouse, children, parents. General patterns only, not your specific policy.',
    },
    'hi_crc_dependent_known': {
      _en:
          'Known: Employer-paid family coverage under the implementing regulation covers the worker, spouse, and up to three children under 18. Parent coverage is not part of that employer-paid entitlement. If you sponsor a parent, confirm the applicable sponsor-paid mandatory coverage and any additional policy requirements.',
      _ar:
          'معروف: تغطية العائلة التي يدفعها صاحب العمل بموجب اللائحة التنفيذية تشمل العامل والزوج/الزوجة وحتى ثلاثة أطفال دون 18. تغطية الوالدين ليست جزءاً من هذا الاستحقاق. إذا كفلت والداً، تحقق من التغطية الإلزامية التي يدفعها الكفيل وأي متطلبات وثيقة إضافية.',
      _hi:
          'Known: Employer-paid family coverage covers worker, spouse, up to 3 children under 18. Parents not part of that employer-paid entitlement — if you sponsor a parent, confirm sponsor-paid mandatory coverage and any additional requirements.',
    },
    'hi_crc_dependent_possible_framing': {
      _en:
          'Possible: Common dependent-coverage patterns — verify your employer\'s dependent schedule; these are not universal facts about every plan.',
      _ar:
          'محتمل: أنماط شائعة لتغطية المعالين — تحقق من جدول المعالين لدى صاحب العمل؛ ليست حقائق عامة عن كل وثيقة.',
      _hi:
          'Possible: Common dependent patterns — verify employer\'s dependent schedule; not universal for every plan.',
    },
    'hi_crc_dependent_possible_item_1': {
      _en:
          'Dependent plans may be thinner than the employee\'s own — the law requires dependents be covered, not that the plan matches the employee\'s benefit level. "My family is covered" does not mean "my family has the same coverage I do."',
      _ar:
          'قد تكون وثيقة المعالين أضعف من وثيقة العامل — القانون يوجب التغطية لا مساواتها بالمنافع. "عائلتي مؤمنة" لا تعني "نفس تغطيتي".',
      _hi:
          'Dependent plan may be thinner than employee\'s — law requires coverage, not matching benefits. "Family covered" ≠ "same as mine."',
    },
    'hi_crc_dependent_possible_item_2': {
      _en:
          'Maternity waiting periods — many plans require 12 months of continuous coverage before maternity benefits activate. Check this separately from the maternity sub-limit (listed above).',
      _ar:
          'فترات انتظار الأمومة — كثير من الوثائق تشترط 12 شهراً تغطية متصلة قبل تفعيل منافع الأمومة. تحقق من هذا بشكل منفصل عن الحد الفرعي المذكور أعلاه.',
      _hi:
          'Maternity waiting periods — many plans need 12 months continuous coverage before maternity benefits. Check separately from sub-limit above.',
    },
    'hi_crc_dependent_action': {
      _en:
          'Action: Request the specific written benefit schedule or policy document for dependent coverage from HR. If it cannot be provided within a reasonable time (roughly a week), that is worth escalating — you have a right to know what your family is actually covered for. If pregnancy is a consideration, plan ahead given common waiting periods.',
      _ar:
          'إجراء: اطلب جدول المنافع المكتوب أو وثيقة تغطية المعالين من HR. إذا لم تُقدَّم خلال وقت معقول (حوالي أسبوع)، يستحق الأمر تصعيداً — لك الحق في معرفة ما تغطيه عائلتك فعلاً. إذا كان الحمل محل اهتمام، خطّط مسبقاً لفترات الانتظار الشائعة.',
      _hi:
          'Action: Request written dependent benefit schedule from HR. If not provided within ~a week, escalate — you have a right to know family coverage. Plan ahead if pregnancy is a consideration.',
    },
    'hi_crc_dependent_unknown': {
      _en:
          'Unknown: Whether your employer uses a reduced dependent plan, what maternity waiting periods apply, or what sponsor-paid mandatory coverage applies to a parent you sponsor — unless you have the dependent policy schedule, sponsor coverage details, or uploaded them in Policy Explainer.',
      _ar:
          'غير معروف: ما إذا كان صاحب العمل يستخدم وثيقة معالين مخفّضة، أو فترات انتظار الأمومة، أو ما التغطية الإلزامية التي يدفعها الكفيل لوالد مكفول — ما لم تكن لديك جدول المعالين أو تفاصيل تغطية الكفيل أو رفعتها في شرح الوثيقة.',
      _hi:
          'Unknown: Reduced dependent plan, maternity waiting periods, sponsor-paid parent coverage — unknown without schedule, sponsor details, or Policy Explainer upload.',
    },
  };
}
