abstract final class ContractScamPatternStrings {
  static String t(String key, String locale) {
    final map = _strings[key];
    if (map == null) return key;
    return map[locale] ?? map['English'] ?? map.values.first;
  }

  static String format(String key, String locale, Map<String, String> params) {
    var out = t(key, locale);
    for (final e in params.entries) {
      out = out.replaceAll('{${e.key}}', e.value);
    }
    return out;
  }

  static final _strings = {
    'cop_section_title': _e(
      'Scam-pattern checks',
      'فحوص أنماط الاحتيال',
      'Scam-pattern checks',
    ),
    'cop_section_sub': _e(
      'Pattern checks on text you provided — not a guarantee.',
      'فحوص أنماط على النص الذي قدمته — وليست ضماناً.',
      'Pattern checks on your text — not a guarantee.',
    ),
    'cop_no_patterns': _e(
      'No common warning patterns found in the text provided. This is not a guarantee.',
      'لم تُعثر على أنماط تحذير شائعة في النص المقدم. هذا ليس ضماناً.',
      'No common warning patterns found. This is not a guarantee.',
    ),
    'cop_source_pattern': _e('Pattern check', 'فحص نمط', 'Pattern check'),
    'cop_next_step': _e('Next step', 'الخطوة التالية', 'Next step'),
    'cop_cat_upfront_fee': _e('Upfront fee', 'رسوم مقدمة', 'Upfront fee'),
    'cop_cat_refundable_deposit': _e('Refundable deposit', 'عربون', 'Deposit'),
    'cop_cat_passport': _e('Passport handling', 'جواز السفر', 'Passport'),
    'cop_cat_guaranteed': _e('Guaranteed offer', 'عرض مضمون', 'Guaranteed'),
    'cop_cat_urgency': _e('Urgency pressure', 'ضغط عاجل', 'Urgency'),
    'cop_cat_contact': _e('Contact channel', 'قناة تواصل', 'Contact'),
    'cop_cat_personal_account': _e('Payment account', 'حساب الدفع', 'Payment'),
    'cop_cat_housing_deposit': _e('Housing deposit', 'عربون سكن', 'Deposit'),
    'cop_cat_landlord_abroad': _e('Remote landlord', 'مالك بعيد', 'Landlord'),
    'cop_cat_no_written': _e('Written terms', 'شروط مكتوبة', 'Written terms'),
    'cop_cat_mismatch': _e('Offer vs contract', 'عرض وعقد', 'Mismatch'),
    'cop_find_upfront_fee': _e(
      'This document asks for a payment from the worker before work starts, which is a common warning sign in job offers.',
      'يطلب هذا المستند دفعة من العامل قبل بدء العمل — علامة تحذير شائعة في عروض العمل.',
      'Payment from the worker before work starts — a common warning sign.',
    ),
    'cop_find_refundable_deposit': _e(
      'This text mentions a refundable deposit from you — confirm who keeps it and when it is returned.',
      'يذكر النص عربوناً مسترداً منك — تحقق من الجهة والموعد.',
      'Refundable deposit mentioned — confirm terms in writing.',
    ),
    'cop_find_passport': _e(
      'This text suggests your passport or ID may be held by someone else — a common warning sign.',
      'يشير النص إلى أن جوازك أو هويتك قد يحتفظ بها طرف آخر — علامة تحذير شائعة.',
      'Passport or ID retention mentioned — a common warning sign.',
    ),
    'cop_find_guaranteed': _e(
      'This text promises a guaranteed visa or job — verify through official channels.',
      'يعد النص بتأشيرة أو وظيفة مضمونة — تحقق عبر قنوات رسمية.',
      'Guaranteed visa or job language — verify officially.',
    ),
    'cop_find_urgency': _e(
      'This text pressures you to sign or pay quickly — slow down and verify.',
      'يضغط النص للتوقيع أو الدفع بسرعة — تمهل وتحقق.',
      'Pressure to sign quickly — slow down and verify.',
    ),
    'cop_find_off_platform': _e(
      'This text pushes contact only through informal apps or personal email.',
      'يدفع النص للتواصل عبر تطبيقات غير رسمية أو بريد شخصي.',
      'Informal contact channels only — verify independently.',
    ),
    'cop_find_personal_account': _e(
      'This text asks for payment to a personal account rather than a company account.',
      'يطلب النص الدفع لحساب شخصي لا حساب شركة.',
      'Payment to a personal account — a common warning sign.',
    ),
    'cop_find_housing_deposit': _e(
      'This text asks for rent or deposit before viewing or signing — a common rental warning sign.',
      'يطلب النص إيجاراً أو عربوناً قبل المعاينة أو التوقيع — علامة شائعة.',
      'Payment before viewing — a common rental warning sign.',
    ),
    'cop_find_landlord_abroad': _e(
      'This text describes a landlord abroad sending keys by courier — verify the listing.',
      'يصف النص مالكاً في الخارج يرسل المفاتيح — تحقق من الإعلان.',
      'Remote landlord and courier keys — verify the listing.',
    ),
    'cop_find_no_written': _e(
      'This text suggests there is no written tenancy agreement.',
      'يشير النص إلى عدم وجود عقد إيجار مكتوب.',
      'No written tenancy terms mentioned.',
    ),
    'cop_find_mismatch': _e(
      'Key figures in the offer message and contract text do not match; ask for the offer in writing.',
      'الأرقام الرئيسية في العرض والعقد لا تتطابق؛ اطلب العرض كتابياً.',
      'Offer and contract figures differ — ask for the offer in writing.',
    ),
    'cop_next_payment_check': _e('Check this payment', 'تحقق من الدفع', 'Check payment'),
    'cop_next_in_call': _e('In-call assistant', 'مساعد المكالمة', 'In-call help'),
    'cop_next_directory': _e('Official directory', 'الدليل الرسمي', 'Directory'),
    'cop_next_bys': _e('Before You Sign', 'قبل التوقيع', 'Before You Sign'),
    'cop_next_contract': _e('Contract analyzer', 'محلل العقد', 'Contract analyzer'),
    'cop_bys_paste_label': _e(
      'Paste offer or contract text (optional)',
      'الصق نص العرض أو العقد (اختياري)',
      'Paste offer text (optional)',
    ),
    'cop_bys_paste_hint': _e(
      'Pattern checks run locally on what you paste here.',
      'تُجرى الفحوص محلياً على ما تلصقه هنا.',
      'Local pattern checks on pasted text.',
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
