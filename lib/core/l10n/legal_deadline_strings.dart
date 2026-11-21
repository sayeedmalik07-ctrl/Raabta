/// Shared legal-deadline UI strings (Truth Engines).
abstract final class LegalDeadlineStrings {
  static String t(String key, [String locale = 'English']) {
    final map = _catalog[key];
    if (map == null) return key;
    return map[locale] ?? map['English'] ?? key;
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

  static final _catalog = <String, Map<String, String>>{
    'ld_title_info': _e(
      'Legal filing deadline: {date}',
      'موعد التقاضي القانوني: {date}',
      'कानूनी दाखिल समय सीमा: {date}',
    ),
    'ld_title_approaching': _e(
      'Filing deadline approaching: {date}',
      'اقتراب موعد التقاضي: {date}',
      'दाखिल समय सीमा नज़दीक: {date}',
    ),
    'ld_title_urgent': _e(
      'Urgent — filing deadline: {date}',
      'عاجل — موعد التقاضي: {date}',
      'अत्यावश्यक — दाखिल समय सीमा: {date}',
    ),
    'ld_title_expired': _e(
      'Standard filing window has closed ({date})',
      'انتهت مهلة التقاضي المعتادة ({date})',
      'मानक दाखिल समय सीमा समाप्त ({date})',
    ),
    'ld_days_remaining': _e(
      '{days} day(s) remaining',
      'متبقٍ {days} يوم',
      '{days} दिन शेष',
    ),
    'ld_days_overdue': _e(
      '{days} day(s) past the standard deadline',
      'تجاوز الموعد بـ {days} يوم',
      'मानक समय सीमा से {days} दिन बीत चुके',
    ),
    'ld_citation_prefix': _e('Per', 'وفق', 'अनुसार'),
    'ld_disclaimer': _e(
      'General information only — not legal advice. Mediation, pending cases, or other facts may change your actual deadline. Consult a qualified lawyer for your situation.',
      'معلومات عامة فقط — ليست استشارة قانونية. قد تغيّر الوساطة أو ظروف أخرى الموعد الفعلي. استشر محامياً.',
      'केवल सामान्य जानकारी — कानूनी सलाह नहीं। मध्यस्थता या अन्य परिस्थितियाँ वास्तविक समय सीमा बदल सकती हैं। वकील से सलाह लें।',
    ),
    'ld_eosb_urgent_body': _e(
      'After this date you may lose the standard one-year window to sue for EOSB and other labour entitlements under Art. 10.',
      'بعد هذا التاريخ قد تفقد مهلة السنة لرفع دعوى مستحقات نهاية الخدمة.',
      'इस तारीख के बाद Art. 10 के तहत EOSB व अन्य हक़ के लिए मानक एक-वर्ष की अवधि समाप्त हो सकती है।',
    ),
    'ld_eosb_expired_body': _e(
      'The standard one-year period from contract expiry may have passed. Exceptions can apply — speak with a lawyer about your options.',
      'قد تكون مهلة السنة من انتهاء العقد قد مرت. قد تنطبق استثناءات — تحدث مع محامٍ.',
      'अनुबंध समाप्ति से एक वर्ष की मानक अवधि बीत चुकी हो सकती है। अपवाद लागू हो सकते हैं — वकील से बात करें।',
    ),
    'ld_eosb_missing_date': _e(
      'Enter your last working day in Employee Info to calculate your Art. 10 filing deadline.',
      'أدخل آخر يوم عمل لحساب موعد Art. 10.',
      'Art. 10 समय सीमा के लिए अंतिम कार्य दिवस दर्ज करें।',
    ),
    'ld_eosb67_title_info': _e(
      'Employer final settlement due: {date}',
      'استحقاق تسوية نهاية الخدمة من صاحب العمل: {date}',
      'नियोक्ता की अंतिम निपटान तिथि: {date}',
    ),
    'ld_eosb67_title_approaching': _e(
      'Employer settlement payment approaching: {date}',
      'اقتراب موعد دفع صاحب العمل للتسوية: {date}',
      'नियोक्ता निपटान भुगतान नज़दीक: {date}',
    ),
    'ld_eosb67_title_urgent': _e(
      'Urgent — employer should pay final settlement by {date}',
      'عاجل — يجب على صاحب العمل الدفع قبل {date}',
      'अत्यावश्यक — नियोक्ता को {date} तक अंतिम निपटान चुकाना चाहिए',
    ),
    'ld_eosb67_title_expired': _e(
      'Employer payment deadline passed ({date})',
      'انتهى موعد دفع صاحب العمل ({date})',
      'नियोक्ता भुगतान समय सीमा समाप्त ({date})',
    ),
    'ld_eosb67_urgent_body': _e(
      'Your employer should pay your final wages and EOSB dues by this date. If payment is late, that may support a labour complaint — separate from your own one-year filing window under Art. 10.',
      'يجب على صاحب العمل دفع مستحقاتك قبل هذا التاريخ. التأخير قد يدعم شكوى — منفصلة عن مهلة السنة للتقاضي (المادة 10).',
      'नियोक्ता को इस तिथि तक अंतिम वेतन/EOSB देना चाहिए। देरी श्रम शिकायत का आधार हो सकती है — Art. 10 की एक-वर्षीय दाखिल अवधि से अलग।',
    ),
    'ld_eosb67_expired_body': _e(
      'The standard employer payment window under Art. 67 may have passed. Unpaid dues can still be pursued — check your Art. 10 filing deadline and speak with MoL or a lawyer.',
      'قد تكون مهلة الدفع بموجب المادة 67 قد مرت. لا يزال بإمكانك مطالبة المستحقات — راجع مهلة المادة 10.',
      'Art. 67 के तहत नियोक्ता भुगतान अवधि बीत चुकी हो सकती है। अवैतनिक राशि के लिए Art. 10 समय सीमा देखें और MoL/वकील से सलाह लें।',
    ),
    'ld_eosb67_missing_date': _e(
      'Enter your Article 49 notice status and the relevant termination or leaving date in Employee Info to calculate your Art. 67 employer payment deadline.',
      'أدخل حالة إشعار المادة 49 وتاريخ إنهاء العقد أو مغادرة العمل لحساب موعد الدفع بموجب المادة 67.',
      'Art. 67 नियोक्ता भुगतान समय सीमा के लिए Employee Info में Art. 49 स्थिति और प्रासंगिक तिथि दर्ज करें।',
    ),
    'ld_eosb67_standard_body': _e(
      'Due before the end of the working day on {date}.',
      'مستحق قبل نهاية يوم العمل في {date}.',
      '{date} को कार्य दिवस की समाप्ति से पहले देय।',
    ),
    'ld_eosb67_exception_body': _e(
      'Within seven calendar days of leaving work without Article 49 notice.',
      'خلال سبعة أيام تقويمية من مغادرة العمل دون إشعار المادة 49.',
      'Art. 49 नोटिस के बिना काम छोड़ने के सात कैलेंडर दिनों के भीतर।',
    ),
    'ld_eosb67_working_day_limitation': _e(
      'Working-day calculation uses Friday weekly rest only (V1). Public holidays and shift schedules are not included.',
      'حساب يوم العمل يستثني الجمعة فقط (V1). العطلات الرسمية وجداول الورديات غير مشمولة.',
      'Working-day गणना में केवल शुक्रवार विश्राम (V1) — सार्वजनिक अवकाश/शिफ्ट शामिल नहीं।',
    ),
    'ld_cta_eosb67': _e(
      'Review unpaid dues',
      'راجع المستحقات غير المدفوعة',
      'अवैतनिक dues की समीक्षा',
    ),
    'ld_tenancy_urgent_body': _e(
      'You may lose the 15-day window to appeal a Rental Dispute Committee decision (Art. 24).',
      'قد تفقد مهلة 15 يوماً للاستئناف (المادة 24).',
      'Art. 24 के तहत 15-दिवसीय अपील अवधि समाप्त हो सकती है।',
    ),
    'ld_tenancy_expired_body': _e(
      'The standard 15-day appeal window may have closed. A lawyer can advise whether any remedy remains.',
      'قد تكون مهلة الاستئناف 15 يوماً قد انتهت. استشر محامياً.',
      '15-दिवसीय अपील अवधि बंद हो सकती है। वकील से सलाह लें।',
    ),
    'ld_tenancy_missing_date': _e(
      'Enter the Committee decision date on your lease form to calculate the appeal deadline.',
      'أدخل تاريخ قرار اللجنة لحساب موعد الاستئناف.',
      'अपील समय सीमा के लिए Committee निर्णय तिथि दर्ज करें।',
    ),
    'ld_tenancy_deposit_title_info': _e(
      'Deposit return follow-up: {date}',
      'متابعة إرجاع الوديعة: {date}',
      'जमा वापसी अनुसरण: {date}',
    ),
    'ld_tenancy_deposit_title_approaching': _e(
      'Deposit return window approaching: {date}',
      'اقتراب موعد إرجاع الوديعة: {date}',
      'जमा वापसी अवधि नज़दीक: {date}',
    ),
    'ld_tenancy_deposit_title_urgent': _e(
      'Urgent — deposit return window: {date}',
      'عاجل — نافذة إرجاع الوديعة: {date}',
      'अत्यावश्यक — जमा वापसी अवधि: {date}',
    ),
    'ld_tenancy_deposit_title_expired': _e(
      'Deposit return window passed ({date})',
      'انتهت نافذة إرجاع الوديعة ({date})',
      'जमा वापसी अवधि बीत चुकी ({date})',
    ),
    'ld_tenancy_deposit_info_body': _e(
      'Landlords are generally expected to provide an itemized statement of any deposit deductions and return the remaining balance within 14 calendar days after the lease ends. This tracker helps you know when to follow up — it does not guarantee an outcome.',
      'يُتوقع عموماً أن يقدّم المالك بياناً مفصلاً بأي خصومات من الوديعة ويعيد المتبقي خلال 14 يوماً تقويمياً من انتهاء العقد. هذا متتبع للمتابعة — لا يضمن نتيجة.',
      'पट्टा समाप्ति के 14 कैलेंडर दिनों के भीतर कटौती विवरण और शेष जमा वापसी की अनुमानित अवधि — केवल अनुसरण सहायक, परिणाम की गारंटी नहीं।',
    ),
    'ld_tenancy_deposit_urgent_body': _e(
      'The 14-day deposit return window is closing. Consider requesting a written itemized statement and keeping your move-out condition evidence ready if you need to follow up.',
      'نافذة الـ14 يوماً لإرجاع الوديعة تقترب من الانتهاء. اطلب بياناً مكتوباً بالخصومات واحتفظ بأدلة حالة الخروج.',
      '14-दिवसीय जमा वापसी अवधि समाप्त हो रही है। लिखित कटौती विवरण माँगें और move-out condition evidence तैयार रखें।',
    ),
    'ld_tenancy_deposit_expired_body': _e(
      'The standard 14-day window from lease end may have passed. You can still follow up in writing and use your condition record if a dispute arises — this is not automatic escalation.',
      'قد تكون مهلة الـ14 يوماً من انتهاء العقد قد مرت. لا يزال بإمكانك المتابعة كتابياً — ليس تصعيداً تلقائياً.',
      '14-दिवसीय अवधि बीत चुकी हो सकती है। लिखित follow-up और condition record अभी भी उपयोगी — स्वचालित escalation नहीं।',
    ),
    'ld_tenancy_deposit_missing_date': _e(
      'Enter your lease end date on the lease form to track the 14-day deposit return follow-up window.',
      'أدخل تاريخ انتهاء العقد لتتبع نافذة متابعة إرجاع الوديعة (14 يوماً).',
      '14-दिवसीय जमा वापसी follow-up के लिए lease end date दर्ज करें।',
    ),
    'ld_cta_tenancy_deposit': _e(
      'Protect move-out evidence',
      'احمِ أدلة حالة الخروج',
      'Move-out evidence सुरक्षित करें',
    ),
    'ld_sponsorship_urgent_body': _e(
      'Employer-change steps via MOI may no longer be available after the 90-day post-expiry window.',
      'قد لا تتوفر خطوات تغيير الكفيل بعد مهلة 90 يوماً.',
      '90-दिवसीय अवधि के बाद MOI नियोक्ता-परिवर्तन कदम उपलब्ध नहीं रह सकते।',
    ),
    'ld_sponsorship_expired_body': _e(
      'The standard 90-day post-expiry window may have closed. Verify current MOI rules with official channels or a lawyer.',
      'قد تكون مهلة 90 يوماً قد انتهت. تحقق من MOI أو محامٍ.',
      '90-दिवसीय अवधि बंद हो सकती है। MOI या वकील से पुष्टि करें।',
    ),
    'ld_sponsorship_missing_date': _e(
      'Enter your residence permit expiry on the readiness form to calculate the 90-day window.',
      'أدخل انتهاء الإقامة لحساب مهلة 90 يوماً.',
      '90-दिवसीय अवधि के लिए permit expiry दर्ज करें।',
    ),
    'ld_cta_eosb': _e(
      'Prepare dispute documents',
      'جهّز مستندات النزاع',
      'विवाद दस्तावेज़ तैयार करें',
    ),
    'ld_cta_tenancy': _e(
      'Open dispute packet',
      'افتح حزمة النزاع',
      'विवाद पैकेट खोलें',
    ),
    'ld_cta_sponsorship': _e(
      'Open transfer documents',
      'افتح مستندات النقل',
      'स्थानांतरण दस्तावेज़',
    ),
    'ld_remind_toggle': _e(
      'Remind me at 90, 30, and 7 days before',
      'ذكّرني قبل 90 و30 و7 أيام',
      '90, 30, 7 दिन पहले याद दिलाएँ',
    ),
    'ld_timeline_marker': _e(
      'Legal deadline (system)',
      'موعد قانوني (نظام)',
      'कानूनी समय सीमा (सिस्टम)',
    ),
    'ld_basis_label': _e(
      'Based on: {basis} ({date})',
      'استناداً إلى: {basis} ({date})',
      'आधार: {basis} ({date})',
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
      'Tamil': en,
    };
