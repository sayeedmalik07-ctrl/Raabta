/// Case Timeline shared UI strings (8 languages).
abstract final class CaseTimelineStrings {
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
    'ct_title': _e('Case Timeline', 'الجدول الزمني للقضية', 'केस टाइमलाइन'),
    'ct_subtitle': _e(
      'Build a dated record of events and linked documents for your case.',
      'سجل مؤرخ للأحداث والمستندات المرتبطة.',
      'अपने केस की दिनांकित घटनाओं का रिकॉर्ड।',
    ),
    'ct_disclaimer': _e(
      'Personal record only — not legal advice or a filed complaint.',
      'سجل شخصي فقط — ليس استشارة قانونية.',
      'व्यक्तिगत रिकॉर्ड — कानूनी सलाह नहीं।',
    ),
    'ct_add_entry': _e('Add entry', 'إضافة', 'प्रविष्टि जोड़ें'),
    'ct_empty_title': _e('No entries yet', 'لا توجد إدخالات', 'अभी कोई प्रविष्टि नहीं'),
    'ct_empty_body': _e(
      'Add the date something happened — a letter, call note, or document.',
      'أضف تاريخ حدث — رسالة أو ملاحظة أو مستند.',
      'घटना की तारीख जोड़ें।',
    ),
    'ct_entry_date': _e('Event date', 'تاريخ الحدث', 'घटना की तारीख'),
    'ct_entry_type': _e('Entry type', 'نوع الإدخال', 'प्रविष्टि प्रकार'),
    'ct_entry_title': _e('Title', 'العنوان', 'शीर्षक'),
    'ct_entry_title_hint': _e(
      'Short label, e.g. "Salary not paid — March"',
      'مثال: "لم يُدفع الراتب — مارس"',
      'उदा. "मार्च वेतन नहीं मिला"',
    ),
    'ct_entry_description': _e('Notes (optional)', 'ملاحظات', 'नोट'),
    'ct_checklist_link': _e(
      'Related document (optional)',
      'مستند ذو صلة',
      'संबंधित दस्तावेज़',
    ),
    'ct_attach_document': _e('Attach document', 'إرفاق مستند', 'दस्तावेज़ जोड़ें'),
    'ct_pick_vault': _e('From Document Vault', 'من الخزنة', 'वॉल्ट से'),
    'ct_scan_new': _e('Scan new', 'مسح جديد', 'नया स्कैन'),
    'ct_save': _e('Save entry', 'حفظ', 'सहेजें'),
    'ct_cancel': _e('Cancel', 'إلغاء', 'रद्द'),
    'ct_gap_heading': _e(
      'Documents that might strengthen your case',
      'مستندات قد تقوي قضيتك',
      'जो दस्तावेज़ केस मजबूत कर सकते हैं',
    ),
    'ct_gap_covered': _e('Added to timeline', 'مُضاف للجدول', 'टाइमलाइन में'),
    'ct_gap_missing': _e('Not yet added', 'لم يُضاف بعد', 'अभी नहीं जोड़ा'),
    'ct_summarize': _e('Summarize my timeline', 'تلخيص الجدول', 'टाइमलाइन सारांश'),
    'ct_summarize_loading': _e('Summarizing…', 'جاري التلخيص…', 'सारांश…'),
    'ct_summarize_disclaimer': _e(
      'Review this summary before sharing — it is factual only, not legal assessment.',
      'راجع قبل المشاركة — وصف factual فقط.',
      'साझा करने से पहले जांचें — तथ्यात्मक सारांश।',
    ),
    'ct_open_timeline': _e('Case Timeline', 'الجدول الزمني', 'केस टाइमलाइन'),
    'ct_packet_appendix_heading': _e(
      'Case timeline appendix',
      'ملحق الجدول الزمني',
      'टाइमलाइन परिशिष्ट',
    ),
    'ct_entry_type_document': _e('Document', 'مستند', 'दस्तावेज़'),
    'ct_entry_type_correspondence': _e('Correspondence', 'مراسلات', 'पत्राचार'),
    'ct_entry_type_note': _e('Note', 'ملاحظة', 'नोट'),
    'ct_entry_type_photo': _e('Photo / video', 'صورة / فيديو', 'फोटो/वीडियो'),
    'ct_entry_type_milestone': _e('Milestone', 'محطة', 'माइलस्टोन'),
    'ct_eosb_doc_contract_sub': _e(
      'Signed contract and any amendments',
      'عقد موقع وأي تعديلات',
      'हस्ताक्षरित अनुबंध',
    ),
    'ct_eosb_doc_payslip_sub': _e(
      'Recent payslips and WPS transfer records',
      'كشوف رواتب وسجلات WPS',
      'पेस्लिप और WPS',
    ),
    'ct_eosb_doc_settlement_sub': _e(
      'Employer settlement letter or offer',
      'خطاب تسوية من صاحب العمل',
      'निपटान पत्र',
    ),
    'ct_eosb_doc_qid': _e('QID / passport copies', 'نسخ QID / جواز', 'QID/पासपोर्ट'),
    'ct_eosb_doc_qid_sub': _e(
      'Identity documents for filing',
      'وثائق الهوية للتقديم',
      'दाखिले के लिए पहचान',
    ),
    'ct_eosb_doc_correspondence': _e(
      'Written correspondence with employer/HR',
      'مراسلات مكتوبة مع HR',
      'नियोक्ता/HR पत्राचार',
    ),
    'ct_eosb_doc_correspondence_sub': _e(
      'Emails, letters, WhatsApp exports where available',
      'بريد ورسائل موثقة',
      'ईमेल/लेटर/चैट',
    ),
    'ct_eosb_doc_photos': _e('Photos or videos', 'صور أو فيديو', 'फोटो/वीडियो'),
    'ct_eosb_doc_photos_sub': _e(
      'Workplace, payment, or condition evidence',
      'أدلة بصرية من مكان العمل',
      'कार्यस्थल साक्ष्य',
    ),
    'ct_eosb_doc_witness': _e('Witness contact details', 'بيانات شهود', 'गवाह संपर्क'),
    'ct_eosb_doc_witness_sub': _e(
      'Names and numbers — you control who is contacted',
      'أسماء وأرقام — أنت تتحكم',
      'नाम और नंबर',
    ),
    'st_milestone_app_submitted': _e(
      'Application submitted (Metrash / MoL)',
      'تم تقديم الطلب',
      'आवेदन जमा',
    ),
    'st_milestone_employer_sms': _e(
      'SMS to current employer received',
      'رسالة SMS لصاحب العمل',
      'नियोक्ता SMS',
    ),
    'st_milestone_notice_begins': _e(
      'Notice period begins',
      'بدء فترة الإشعار',
      'नोटिस अवधि शुरू',
    ),
    'st_milestone_both_parties_sms': _e(
      'SMS to both parties received',
      'SMS للطرفين',
      'दोनों पक्षों को SMS',
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
