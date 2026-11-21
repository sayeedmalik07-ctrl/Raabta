/// Personal Budget Calculator localized strings (8 languages).
abstract final class PersonalBudgetStrings {
  static const supportedLocales = [
    'English',
    'Arabic',
    'Hindi',
    'Urdu',
    'Malayalam',
    'Nepali',
    'Bengali',
    'Filipino',
  ];

  static String t(String key, [String locale = 'English']) {
    final map = _catalog[key];
    if (map == null) return key;
    return map[locale] ?? map['English'] ?? key;
  }

  static String format(
    String key,
    String locale, {
    Map<String, String> params = const {},
  }) {
    var text = t(key, locale);
    for (final entry in params.entries) {
      text = text.replaceAll('{${entry.key}}', entry.value);
    }
    return text;
  }

  static final _catalog = <String, Map<String, String>>{
    'pb_title': _e(
      'Personal Budget',
      'الميزانية الشخصية',
      'व्यक्तिगत बजट',
    ),
    'pb_subtitle': _e(
      'Enter your monthly figures — calculations update instantly. Not financial advice.',
      'أدخل أرقامك الشهرية — الحسابات فورية. ليست نصيحة مالية.',
      'मासिक राशि दर्ज करें — तुरंत अपडेट। वित्तीय सलाह नहीं।',
    ),
    'pb_disclaimer': _e(
      'Deterministic estimate only — verify figures with your employer and bank.',
      'تقدير حتمي فقط — تحقق من الأرقام مع صاحب العمل والبنك.',
      'केवल अनुमान — नियोक्ता और बैंक से सत्यापित करें।',
    ),
    'pb_link_from_col': _e(
      'Plan your personal budget',
      'خطط ميزانيتك الشخصية',
      'अपना व्यक्तिगत बजट बनाएं',
    ),
    'pb_link_from_col_sub': _e(
      'Salary vs expenses — savings rate & pressure band',
      'الراتب مقابل المصروفات — معدل الادخار وضغط الميزانية',
      'वेतन बनाम खर्च — बचत दर और दबाव',
    ),
    'pb_input_salary': _e(
      'Salary (net monthly take-home)',
      'الراتب (صافي شهري)',
      'वेतन (शुद्ध मासिक)',
    ),
    'pb_cat_rent': _e('Rent', 'الإيجار', 'किराया'),
    'pb_cat_food': _e('Food', 'الطعام', 'खाना'),
    'pb_cat_transport': _e('Transport', 'المواصلات', 'यातायात'),
    'pb_cat_utilities': _e('Utilities', 'المرافق', 'उपयोगिताएँ'),
    'pb_cat_family': _e('Family', 'الأسرة', 'परिवार'),
    'pb_cat_remittance': _e('Remittance', 'التحويلات', 'प्रेषण'),
    'pb_cat_other': _e('Other', 'أخرى', 'अन्य'),
    'pb_family_hint': _e(
      'School fees, dependents, local family costs',
      'رسوم المدارس، المعالون، تكاليف الأسرة',
      'स्कूल फीस, आश्रित, परिवार खर्च',
    ),
    'pb_results_heading': _e(
      'Your budget snapshot',
      'لمحة ميزانيتك',
      'बजट सारांश',
    ),
    'pb_monthly_cost': _e('Monthly cost', 'التكلفة الشهرية', 'मासिक लागत'),
    'pb_annual_cost': _e('Annual cost', 'التكلفة السنوية', 'वार्षिक लागत'),
    'pb_savings_rate': _e('Savings rate', 'معدل الادخار', 'बचत दर'),
    'pb_budget_pressure': _e('Budget pressure', 'ضغط الميزانية', 'बजट दबाव'),
    'pb_potential_savings': _e(
      'Potential savings',
      'الادخار المحتمل',
      'संभावित बचत',
    ),
    'pb_enter_salary': _e(
      'Enter your salary to calculate',
      'أدخل راتبك للحساب',
      'गणना के लिए वेतन दर्ज करें',
    ),
    'pb_savings_positive': _e(
      'You could save QAR {amount}/month',
      'يمكنك ادخار {amount} ر.ق/شهر',
      'आप QAR {amount}/माह बचा सकते हैं',
    ),
    'pb_savings_negative': _e(
      'You\'re spending QAR {amount} more than you earn per month',
      'تنفق {amount} ر.ق أكثر مما تكسب شهرياً',
      'आप QAR {amount}/माह अधिक खर्च कर रहे हैं',
    ),
    'pb_annual_savings_positive': _e(
      'Annual potential: QAR {amount}',
      'الإمكان السنوي: {amount} ر.ق',
      'वार्षिक संभावना: QAR {amount}',
    ),
    'pb_annual_savings_negative': _e(
      'Annual shortfall: QAR {amount}',
      'العجز السنوي: {amount} ر.ق',
      'वार्षिक घाटा: QAR {amount}',
    ),
    'pb_pressure_comfortable': _e('Comfortable', 'مريح', 'आरामदायक'),
    'pb_pressure_moderate': _e('Moderate', 'معتدل', 'मध्यम'),
    'pb_pressure_high': _e('High', 'مرتفع', 'उच्च'),
    'pb_pressure_critical': _e('Critical', 'حرج', 'गंभीर'),
    'pb_breakdown': _e('Expense breakdown', 'توزيع المصروفات', 'खर्च विभाजन'),
    'pb_breakdown_empty': _e(
      'Add expenses to see category breakdown',
      'أضف مصروفات لرؤية التوزيع',
      'विभाजन के लिए खर्च जोड़ें',
    ),
    'pb_inputs_heading': _e(
      'Monthly figures (QAR)',
      'أرقام شهرية (ر.ق)',
      'मासिक राशि (QAR)',
    ),
    'pb_attention_heading': _e(
      'What needs attention',
      'ما يحتاج انتباه',
      'ध्यान देने योग्य',
    ),
    'pb_attention_rent': _e(
      'Rent is {percent}% of your spending — the largest single category.',
      'الإيجار {percent}% من إنفاقك — أكبر فئة واحدة.',
      'किराया आपके खर्च का {percent}% है — सबसे बड़ी श्रेणी।',
    ),
    'pb_attention_food': _e(
      'Food is {percent}% of your spending — the largest single category.',
      'الطعام {percent}% من إنفاقك — أكبر فئة واحدة.',
      'खाना आपके खर्च का {percent}% है — सबसे बड़ी श्रेणी।',
    ),
    'pb_attention_transport': _e(
      'Transport is {percent}% of your spending — the largest single category.',
      'المواصلات {percent}% من إنفاقك — أكبر فئة واحدة.',
      'यातायात आपके खर्च का {percent}% है — सबसे बड़ी श्रेणी।',
    ),
    'pb_attention_utilities': _e(
      'Utilities are {percent}% of your spending — the largest single category.',
      'المرافق {percent}% من إنفاقك — أكبر فئة واحدة.',
      'उपयोगिताएँ आपके खर्च का {percent}% हैं — सबसे बड़ी श्रेणी।',
    ),
    'pb_attention_family': _e(
      'Family costs are {percent}% of your spending — the largest single category.',
      'تكاليف الأسرة {percent}% من إنفاقك — أكبر فئة واحدة.',
      'परिवार खर्च आपके खर्च का {percent}% है — सबसे बड़ी श्रेणी।',
    ),
    'pb_attention_remittance': _e(
      'Remittance is {percent}% of your spending — the largest single category.',
      'التحويلات {percent}% من إنفاقك — أكبر فئة واحدة.',
      'प्रेषण आपके खर्च का {percent}% है — सबसे बड़ी श्रेणी।',
    ),
    'pb_attention_other': _e(
      'Other expenses are {percent}% of your spending — the largest single category.',
      'مصروفات أخرى {percent}% من إنفاقك — أكبر فئة واحدة.',
      'अन्य खर्च आपके खर्च का {percent}% है — सबसे बड़ी श्रेणी।',
    ),
    'pb_export_heading': _e(
      'Export & share',
      'تصدير ومشاركة',
      'निर्यात और साझा करें',
    ),
    'pb_export_sub': _e(
      'Share a snapshot card, full PDF report, or save to Document Vault.',
      'شارك بطاقة أو تقرير PDF أو احفظ في الخزنة.',
      'कार्ड, PDF रिपोर्ट साझा करें या वॉल्ट में सहेजें।',
    ),
    'pb_share_card': _e('Share card', 'مشاركة بطاقة', 'कार्ड साझा'),
    'pb_share_pdf': _e('PDF report', 'تقرير PDF', 'PDF रिपोर्ट'),
    'pb_save_vault': _e('Save to Vault', 'حفظ في الخزنة', 'वॉल्ट में सहेजें'),
    'pb_vault_saved': _e(
      'Budget report saved to Document Vault',
      'تم حفظ التقرير في الخزنة',
      'रिपोर्ट वॉल्ट में सहेजी गई',
    ),
    'pb_vault_failed': _e(
      'Could not save to vault. Try again.',
      'تعذر الحفظ. حاول مرة أخرى.',
      'सहेजना विफल। पुनः प्रयास करें।',
    ),
    'pb_prefill_bills': _e(
      'Import from Bill Tracker',
      'استيراد من متتبع الفواتير',
      'बिल ट्रैकर से आयात',
    ),
    'pb_prefill_done': _e(
      'Utilities, rent & other filled from this month\'s bills',
      'تم ملء المرافق والإيجار من فواتير هذا الشهر',
      'इस महीने के बिल से भरा गया',
    ),
    'pb_report_overline': _e('Auto-generated', 'مُنشأ تلقائياً', 'स्वतः जनित'),
    'pb_report_title': _e(
      'Complete budget report',
      'تقرير الميزانية الكامل',
      'पूर्ण बजट रिपोर्ट',
    ),
    'pb_report_exec': _e('Executive summary', 'ملخص تنفيذي', 'कार्यकारी सारांश'),
    'pb_report_exec_body': _e(
      'You spend QAR {monthly}/month against a take-home salary of QAR {salary}. '
      'Savings rate: {savings_rate}%. Budget pressure: {pressure}.',
      'تنفق {monthly} ر.ق/شهر مقابل راتب {salary} ر.ق. '
      'معدل الادخار: {savings_rate}%. الضغط: {pressure}.',
      'आप QAR {salary} वेतन पर QAR {monthly}/माह खर्च करते हैं। '
      'बचत: {savings_rate}%. दबाव: {pressure}.',
    ),
    'pb_report_income': _e('Income & expenses', 'الدخل والمصروفات', 'आय और खर्च'),
    'pb_report_income_body': _e(
      'Net salary QAR {salary}/month · total expenses QAR {monthly}/month '
      '(QAR {annual}/year). Headroom vs salary: QAR {potential}/month.',
      'صافي الراتب {salary} ر.ق · المصروفات {monthly} ر.ق '
      '({annual} ر.ق/سنة). الفارق: {potential} ر.ق/شهر.',
      'शुद्ध वेतन QAR {salary} · खर्च QAR {monthly} (वार्षिक QAR {annual})। '
      'अंतर: QAR {potential}/माह।',
    ),
    'pb_report_pressure': _e('Pressure analysis', 'تحليل الضغط', 'दबाव विश्लेषण'),
    'pb_report_pressure_body': _e(
      'Expenses consume {percent}% of take-home pay — {band} pressure band.',
      'المصروفات {percent}% من الراتب — نطاق {band}.',
      'खर्च वेतन का {percent}% — {band} दबाव।',
    ),
    'pb_report_actions': _e('Recommendations', 'توصيات', 'सिफारिशें'),
    'pb_report_actions_body': _e(
      'Practical next steps based on your figures (not financial advice):',
      'خطوات عملية بناءً على أرقامك (ليست نصيحة مالية):',
      'Practical next steps based on your figures (not financial advice):',
    ),
    'pb_report_cpi': _e('Qatar CPI context', 'سياق CPI قطر', 'कतर CPI संदर्भ'),
    'pb_report_cpi_body': _e(
      'Official general CPI index: {cpi} (NPC release {date}). '
      'Use Cost of Living in RAABTA for national trend context.',
      'مؤشر CPI الرسمي: {cpi} (إصدار {date}). '
      'راجع تكلفة المعيشة في RAABTA للسياق الوطني.',
      'आधिकारिक CPI: {cpi} ({date})। RAABTA में राष्ट्रीय रुझान देखें।',
    ),
    'pb_report_disclaimer': _e('Disclaimer', 'إخلاء مسؤولية', 'अस्वीकरण'),
    'pb_rec_comfortable': _e(
      'Strong buffer — consider automating savings before discretionary spend.',
      'هامش جيد — فكّر في أتمتة الادخار.',
      'अच्छा बफर — बचत स्वचालित करें।',
    ),
    'pb_rec_moderate': _e(
      'Review remittance and subscription categories for easy wins.',
      'راجع التحويلات والاشتراكات.',
      'प्रेषण और सब्सक्रिप्शन की समीक्षा करें।',
    ),
    'pb_rec_high': _e(
      'Prioritise rent/food negotiation and defer non-essential purchases.',
      'ركز على الإيجار/الطعام وأجل المشتريات غير الضرورية.',
      'किराया/भोजन पर ध्यान दें, गैर-जरूरी खर्च टालें।',
    ),
    'pb_rec_critical': _e(
      'Expenses exceed or nearly exceed income — seek employer or community support options.',
      'المصروفات تقترب من الدخل — اطلب الدعم عند الحاجة.',
      'खर्च आय के करीब — सहायता लें।',
    ),
    'pb_rec_deficit': _e(
      'You are running a monthly deficit — adjust largest categories first.',
      'عجز شهري — عدّل أكبر فئات الإنفاق أولاً.',
      'मासिक घाटा — सबसे बड़ी श्रेणियाँ पहले समायोजित करें।',
    ),
    'pb_rec_track': _e(
      'Track bills in Bill Tracker and revisit monthly after salary day.',
      'تتبع الفواتير في RAABTA وراجع شهرياً.',
      'बिल ट्रैकर में ट्रैक करें, मासिक समीक्षा करें।',
    ),
    'pb_link_col': _e(
      'Compare with Qatar CPI',
      'قارن مع CPI قطر',
      'कतर CPI से तुलना',
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
