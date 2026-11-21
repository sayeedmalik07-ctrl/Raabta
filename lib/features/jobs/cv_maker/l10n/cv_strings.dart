import 'package:flutter/foundation.dart';
import 'package:raabta/core/l10n/app_locale.dart';
import 'package:raabta/core/l10n/locale_catalog_coverage.dart';
import 'package:raabta/core/l10n/locale_catalog_entry.dart';

/// CV Maker UI and PDF export strings — 9 locales via [l10nEntry].
abstract final class CvStrings {
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
    // ── PDF export ──────────────────────────────────────────────────────────
    'cv_pdf_section_summary': l10nEntry(
      english: 'Professional Summary',
      arabic: 'الملخص المهني',
      hindi: 'Professional Summary',
    ),
    'cv_pdf_section_experience': l10nEntry(
      english: 'Work Experience',
      arabic: 'الخبرة العملية',
      hindi: 'Work Experience',
    ),
    'cv_pdf_section_projects': l10nEntry(
      english: 'Projects',
      arabic: 'المشاريع',
      hindi: 'Projects',
    ),
    'cv_pdf_section_education': l10nEntry(
      english: 'Education',
      arabic: 'التعليم',
      hindi: 'Education',
    ),
    'cv_pdf_section_certifications': l10nEntry(
      english: 'Certifications and Licenses',
      arabic: 'الشهادات والتراخيص',
      hindi: 'Certifications and Licenses',
    ),
    'cv_pdf_section_skills': l10nEntry(
      english: 'Skills',
      arabic: 'المهارات',
      hindi: 'Skills',
    ),
    'cv_pdf_section_languages': l10nEntry(
      english: 'Languages',
      arabic: 'اللغات',
      hindi: 'Languages',
    ),
    'cv_pdf_responsibilities': l10nEntry(
      english: 'Responsibilities',
      arabic: 'المسؤوليات',
      hindi: 'Responsibilities',
    ),
    'cv_pdf_achievements': l10nEntry(
      english: 'Achievements',
      arabic: 'الإنجازات',
      hindi: 'Achievements',
    ),
    'cv_pdf_phone': l10nEntry(
      english: 'Phone',
      arabic: 'الهاتف',
      hindi: 'Phone',
    ),
    'cv_pdf_email': l10nEntry(
      english: 'Email',
      arabic: 'البريد الإلكتروني',
      hindi: 'Email',
    ),
    'cv_pdf_location': l10nEntry(
      english: 'Location',
      arabic: 'الموقع',
      hindi: 'Location',
    ),
    'cv_pdf_linkedin': l10nEntry(
      english: 'LinkedIn',
      arabic: 'LinkedIn',
      hindi: 'LinkedIn',
    ),
    'cv_pdf_technical_skills': l10nEntry(
      english: 'Technical skills',
      arabic: 'المهارات التقنية',
      hindi: 'Technical skills',
    ),
    'cv_pdf_tools_software': l10nEntry(
      english: 'Tools and software',
      arabic: 'الأدوات والبرامج',
      hindi: 'Tools and software',
    ),
    'cv_pdf_soft_skills': l10nEntry(
      english: 'Soft skills',
      arabic: 'المهارات الشخصية',
      hindi: 'Soft skills',
    ),

    // ── Screen titles ─────────────────────────────────────────────────────────
    'cv_title_maker': l10nEntry(
      english: 'CV Maker',
      arabic: 'صانع السيرة الذاتية',
      hindi: 'CV Maker',
      urdu: 'سی وی بنانے والا',
    ),
    'cv_title_build': l10nEntry(
      english: 'Build My CV',
      arabic: 'إنشاء سيرتي الذاتية',
      hindi: 'मेरा CV बनाएं',
      urdu: 'میری CV بنائیں',
    ),
    'cv_title_my_cv': l10nEntry(
      english: 'My CV',
      arabic: 'سيرتي الذاتية',
      hindi: 'मेरा CV',
      urdu: 'میری CV',
    ),

    // ── Builder chrome ──────────────────────────────────────────────────────
    'cv_builder_complete_sections': l10nEntry(
      english: 'Complete every section',
      arabic: 'أكمل كل قسم',
      hindi: 'हर सेक्शन पूरा करें',
      urdu: 'ہر سیکشن مکمل کریں',
    ),
    'cv_template_picker_title': l10nEntry(
      english: 'Choose template',
      arabic: 'اختر القالب',
      hindi: 'टेम्पलेट चुनें',
      urdu: 'ٹیمپلیٹ منتخب کریں',
      malayalam: 'Choose template',
      nepali: 'Choose template',
      bengali: 'Choose template',
      filipino: 'Choose template',
      tamil: 'Choose template',
    ),
    'cv_builder_sections_helper': l10nEntry(
      english:
          'Contact, summary, experience, education, and skills are required for a strong CV. Optional sections appear when you add content.',
      arabic:
          'جهة الاتصال والملخص والخبرة والتعليم والمهارات مطلوبة لسيرة قوية. الأقسام الاختيارية تظهر عند إضافة محتوى.',
      hindi:
          'मजबूत CV के लिए संपर्क, सारांश, अनुभव, शिक्षा और कौशल जरूरी हैं। वैकल्पिक सेक्शन तब दिखते हैं जब आप सामग्री जोड़ते हैं।',
      urdu:
          'مضبوط CV کے لیے رابطہ، خلاصہ، تجربہ، تعلیم اور مہارتیں ضروری ہیں۔ اختیاری سیکشنز مواد شامل کرنے پر ظاہر ہوتے ہیں۔',
      malayalam:
          'Contact, summary, experience, education, and skills are required for a strong CV. Optional sections appear when you add content.',
      nepali:
          'Contact, summary, experience, education, and skills are required for a strong CV. Optional sections appear when you add content.',
      bengali:
          'Contact, summary, experience, education, and skills are required for a strong CV. Optional sections appear when you add content.',
      tamil:
          'Contact, summary, experience, education, and skills are required for a strong CV. Optional sections appear when you add content.',
      filipino:
          'Contact, summary, experience, education, and skills are required for a strong CV. Optional sections appear when you add content.',
    ),
    'cv_builder_load_failed': l10nEntry(
      english: 'Could not load CV data',
      arabic: 'تعذر تحميل بيانات السيرة',
      hindi: 'CV डेटा लोड नहीं हो सका',
      urdu: 'CV ڈیٹا لوڈ نہیں ہو سکا',
      malayalam: 'Could not load CV data',
      nepali: 'Could not load CV data',
      bengali: 'Could not load CV data',
      tamil: 'Could not load CV data',
      filipino: 'Could not load CV data',
    ),
    'cv_action_try_again': l10nEntry(
      english: 'Try again',
      arabic: 'حاول مرة أخرى',
      hindi: 'फिर से कोशिश करें',
      urdu: 'دوبارہ کوشش کریں',
    ),
    'cv_action_back_start': l10nEntry(
      english: 'Back to start options',
      arabic: 'العودة إلى خيارات البدء',
      hindi: 'शुरुआती विकल्पों पर वापस',
      urdu: 'شروع کے اختیارات پر واپس',
    ),
    'cv_action_preview_export': l10nEntry(
      english: 'Preview & Export',
      arabic: 'معاينة وتصدير',
      hindi: 'पूर्वावलोकन और निर्यात',
      urdu: 'پیش نظارہ اور برآمد',
    ),
    'cv_action_remove': l10nEntry(
      english: 'Remove',
      arabic: 'إزالة',
      hindi: 'हटाएं',
      urdu: 'ہٹائیں',
    ),

    // ── Contact & summary fields ────────────────────────────────────────────
    'cv_field_full_name': l10nEntry(
      english: 'Full name',
      arabic: 'الاسم الكامل',
      hindi: 'पूरा नाम',
      urdu: 'مکمل نام',
    ),
    'cv_field_phone': l10nEntry(
      english: 'Phone number',
      arabic: 'رقم الهاتف',
      hindi: 'फ़ोन नंबर',
      urdu: 'فون نمبر',
    ),
    'cv_field_email': l10nEntry(
      english: 'Professional email',
      arabic: 'البريد الإلكتروني المهني',
      hindi: 'पेशेवर ईमेल',
      urdu: 'پیشہ ورانہ ای میل',
    ),
    'cv_field_location': l10nEntry(
      english: 'Location (city, country)',
      arabic: 'الموقع (المدينة، الدولة)',
      hindi: 'स्थान (शहर, देश)',
      urdu: 'مقام (شہر، ملک)',
    ),
    'cv_field_linkedin': l10nEntry(
      english: 'LinkedIn URL (optional)',
      arabic: 'رابط LinkedIn (اختياري)',
      hindi: 'LinkedIn URL (वैकल्पिक)',
      urdu: 'LinkedIn URL (اختیاری)',
    ),
    'cv_format_paragraph': l10nEntry(
      english: 'Paragraph',
      arabic: 'فقرة',
      hindi: 'पैराग्राफ',
      urdu: 'پیراگراف',
    ),
    'cv_format_bullets': l10nEntry(
      english: 'Bullets',
      arabic: 'نقاط',
      hindi: 'बुलेट',
      urdu: 'بلٹ پوائنٹس',
    ),

    // ── Section add actions ─────────────────────────────────────────────────
    'cv_add_experience': l10nEntry(
      english: 'Add work experience',
      arabic: 'إضافة خبرة عمل',
      hindi: 'कार्य अनुभव जोड़ें',
      urdu: 'کام کا تجربہ شامل کریں',
    ),
    'cv_add_education': l10nEntry(
      english: 'Add education',
      arabic: 'إضافة تعليم',
      hindi: 'शिक्षा जोड़ें',
      urdu: 'تعلیم شامل کریں',
    ),
    'cv_add_certification': l10nEntry(
      english: 'Add certification',
      arabic: 'إضافة شهادة',
      hindi: 'प्रमाणपत्र जोड़ें',
      urdu: 'سرٹیفیکیشن شامل کریں',
    ),
    'cv_add_project': l10nEntry(
      english: 'Add project',
      arabic: 'إضافة مشروع',
      hindi: 'प्रोजेक्ट जोड़ें',
      urdu: 'پروجیکٹ شامل کریں',
    ),
    'cv_add_language': l10nEntry(
      english: 'Add language',
      arabic: 'إضافة لغة',
      hindi: 'भाषा जोड़ें',
      urdu: 'زبان شامل کریں',
    ),

    // ── Skills fields ───────────────────────────────────────────────────────
    'cv_field_hard_skills': l10nEntry(
      english: 'Hard / technical skills (comma-separated)',
      arabic: 'المهارات التقنية (مفصولة بفواصل)',
      hindi: 'तकनीकी कौशल (अल्पविराम से अलग)',
      urdu: 'تکنیکی مہارتیں (کoma سے الگ)',
    ),
    'cv_field_tools': l10nEntry(
      english: 'Tools & software (comma-separated)',
      arabic: 'الأدوات والبرامج (مفصولة بفواصل)',
      hindi: 'उपकरण और सॉफ़्टवेयर (अल्पविराम से अलग)',
      urdu: 'اوزار اور سافٹ ویئر (کoma سے الگ)',
    ),
    'cv_field_soft_skills': l10nEntry(
      english: 'Soft skills (optional, comma-separated)',
      arabic: 'المهارات الشخصية (اختياري، مفصولة بفواصل)',
      hindi: 'सॉफ्ट स्किल्स (वैकल्पिक, अल्पविराम से अलग)',
      urdu: 'نرم مہارتیں (اختیاری، کoma سے الگ)',
    ),

    // ── Photo ───────────────────────────────────────────────────────────────
    'cv_photo_optional': l10nEntry(
      english: 'Optional photo',
      arabic: 'صورة اختيارية',
      hindi: 'वैकल्पिक फ़ोटो',
      urdu: 'اختیاری تصویر',
    ),
    'cv_photo_take': l10nEntry(
      english: 'Take photo',
      arabic: 'التقاط صورة',
      hindi: 'फ़ोटो लें',
      urdu: 'تصویر لیں',
    ),
    'cv_photo_gallery': l10nEntry(
      english: 'Choose from gallery',
      arabic: 'اختر من المعرض',
      hindi: 'गैलरी से चुनें',
      urdu: 'گیلری سے منتخب کریں',
    ),
    'cv_photo_upload': l10nEntry(
      english: 'Upload photo',
      arabic: 'رفع صورة',
      hindi: 'फ़ोटो अपलोड करें',
      urdu: 'تصویر اپ لوڈ کریں',
    ),

    // ── Experience editor ───────────────────────────────────────────────────
    'cv_field_job_title': l10nEntry(
      english: 'Job title',
      arabic: 'المسمى الوظيفي',
      hindi: 'नौकरी का शीर्षक',
      urdu: 'ملازمت کا عنوان',
    ),
    'cv_field_company': l10nEntry(
      english: 'Company',
      arabic: 'الشركة',
      hindi: 'कंपनी',
      urdu: 'کمپنی',
    ),
    'cv_field_location_short': l10nEntry(
      english: 'Location',
      arabic: 'الموقع',
      hindi: 'स्थान',
      urdu: 'مقام',
    ),
    'cv_field_start_date': l10nEntry(
      english: 'Start date',
      arabic: 'تاريخ البدء',
      hindi: 'शुरुआत की तारीख',
      urdu: 'شروع کی تاریخ',
    ),
    'cv_field_end_date': l10nEntry(
      english: 'End date',
      arabic: 'تاريخ الانتهاء',
      hindi: 'समाप्ति की तारीख',
      urdu: 'اختتام کی تاریخ',
    ),
    'cv_field_currently_working': l10nEntry(
      english: 'Currently working here',
      arabic: 'أعمل هنا حالياً',
      hindi: 'वर्तमान में यहाँ काम कर रहा/रही हूँ',
      urdu: 'فی الحال یہاں کام کر رہا/رahi ہوں',
    ),
    'cv_field_responsibilities': l10nEntry(
      english: 'Responsibilities (one per line)',
      arabic: 'المسؤوليات (واحدة في كل سطر)',
      hindi: 'जिम्मेदारियाँ (प्रति पंक्ति एक)',
      urdu: 'ذمہ داریاں (ہر لائن میں ایک)',
    ),
    'cv_field_achievements': l10nEntry(
      english: 'Achievements (one per line)',
      arabic: 'الإنجازات (واحدة في كل سطر)',
      hindi: 'उपलब्धियाँ (प्रति पंक्ति एक)',
      urdu: 'کامیابیاں (ہر لائن میں ایک)',
    ),

    // ── Education editor ────────────────────────────────────────────────────
    'cv_field_degree': l10nEntry(
      english: 'Degree / qualification',
      arabic: 'الدرجة / المؤهل',
      hindi: 'डिग्री / योग्यता',
      urdu: 'ڈگری / قابلیت',
    ),
    'cv_field_school': l10nEntry(
      english: 'School / university',
      arabic: 'المدرسة / الجامعة',
      hindi: 'स्कूल / विश्वविद्यालय',
      urdu: 'اسکول / یونیورسٹی',
    ),
    'cv_field_school_location': l10nEntry(
      english: 'School location',
      arabic: 'موقع المدرسة',
      hindi: 'स्कूल का स्थान',
      urdu: 'اسکول کا مقام',
    ),
    'cv_field_graduation': l10nEntry(
      english: 'Graduation month & year',
      arabic: 'شهر وسنة التخرج',
      hindi: 'स्नातक माह और वर्ष',
      urdu: 'گریجuation کا مہینہ اور سال',
    ),
    'cv_field_show_grad_year': l10nEntry(
      english: 'Show graduation year on CV',
      arabic: 'إظهار سنة التخرج في السيرة',
      hindi: 'CV पर स्नातक वर्ष दिखाएं',
      urdu: 'CV پر گریجuation کا سال دکھائیں',
    ),

    // ── Certification editor ──────────────────────────────────────────────────
    'cv_field_cert_name': l10nEntry(
      english: 'Certification name',
      arabic: 'اسم الشهادة',
      hindi: 'प्रमाणपत्र का नाम',
      urdu: 'سرٹیفیکیشن کا نام',
    ),
    'cv_field_issuer': l10nEntry(
      english: 'Issuing body',
      arabic: 'الجهة المُصدِرة',
      hindi: 'जारी करने वाला संस्थान',
      urdu: 'جاری کرنے والا ادارہ',
    ),
    'cv_field_issue_date': l10nEntry(
      english: 'Issue month & year (optional)',
      arabic: 'شهر وسنة الإصدار (اختياري)',
      hindi: 'जारी करने का माह और वर्ष (वैकल्पिक)',
      urdu: 'جاری کرنے کا مہینہ اور سال (اختیاری)',
    ),

    // ── Project editor ──────────────────────────────────────────────────────
    'cv_field_project_title': l10nEntry(
      english: 'Project title',
      arabic: 'عنوان المشروع',
      hindi: 'प्रोजेक्ट शीर्षक',
      urdu: 'پروجیکٹ کا عنوان',
    ),
    'cv_field_description': l10nEntry(
      english: 'Description',
      arabic: 'الوصف',
      hindi: 'विवरण',
      urdu: 'تفصیل',
    ),
    'cv_field_url': l10nEntry(
      english: 'URL (optional)',
      arabic: 'الرابط (اختياري)',
      hindi: 'URL (वैकल्पिक)',
      urdu: 'URL (اختیاری)',
    ),

    // ── Language editor ─────────────────────────────────────────────────────
    'cv_field_language': l10nEntry(
      english: 'Language',
      arabic: 'اللغة',
      hindi: 'भाषा',
      urdu: 'زبان',
    ),
    'cv_field_proficiency': l10nEntry(
      english: 'Proficiency (optional)',
      arabic: 'الإتقان (اختياري)',
      hindi: 'प्रवीणता (वैकल्पिक)',
      urdu: 'مہارت (اختیاری)',
    ),

    // ── Start screen ────────────────────────────────────────────────────────
    'cv_upload_resume_pages': l10nEntry(
      english: 'Upload resume pages',
      arabic: 'رفع صفحات السيرة',
      hindi: 'रिज़्यूमे पृष्ठ अपलोड करें',
      urdu: 'ریزیومے صفحات اپ لوڈ کریں',
    ),
    'cv_upload_take_page': l10nEntry(
      english: 'Take photo of page',
      arabic: 'التقاط صورة للصفحة',
      hindi: 'पृष्ठ की फ़ोटो लें',
      urdu: 'صفحے کی تصویر لیں',
    ),
    'cv_upload_gallery': l10nEntry(
      english: 'Choose photos from gallery',
      arabic: 'اختر صوراً من المعرض',
      hindi: 'गैलरी से फ़ोटो चुनें',
      urdu: 'گیلری سے تصاویر منتخب کریں',
    ),
    'cv_upload_one_per_page': l10nEntry(
      english: 'Select one photo per page',
      arabic: 'اختر صورة واحدة لكل صفحة',
      hindi: 'प्रति पृष्ठ एक फ़ोटो चुनें',
      urdu: 'ہر صفحے کے لیے ایک تصویر منتخب کریں',
    ),
    'cv_import_dialog_title': l10nEntry(
      english: 'Review imported CV',
      arabic: 'مراجعة السيرة المستوردة',
      hindi: 'आयात किए CV की समीक्षा करें',
      urdu: 'درآمد شدہ CV کا جائزہ لیں',
    ),
    'cv_import_dialog_body': l10nEntry(
      english:
          'We extracted fields from your document. Please review and edit every section before saving — nothing is submitted automatically.',
      arabic:
          'استخرجنا حقولاً من مستندك. راجع وحرّر كل قسم قبل الحفظ — لا يُرسل شيء تلقائياً.',
      hindi:
          'हमने आपके दस्तावेज़ से फ़ील्ड निकाले। सहेजने से पहले हर सेक्शन की समीक्षा और संपादन करें — कुछ भी स्वचालित रूप से सबमिट नहीं होता।',
      urdu:
          'ہم نے آپ کے دستاویز سے فیلڈز نکالے۔ محفوظ کرنے سے پہلے ہر سیکشن کا جائزہ لیں — کچھ خودکار طور پر جمع نہیں ہوتا۔',
    ),
    'cv_action_continue_editing': l10nEntry(
      english: 'Continue editing',
      arabic: 'متابعة التحرير',
      hindi: 'संपादन जारी रखें',
      urdu: 'ترمیم جاری رکھیں',
    ),
    'cv_start_profile_title': l10nEntry(
      english: 'Use my Raabta profile data',
      arabic: 'استخدم بيانات ملفي في Raabta',
      hindi: 'मेरे Raabta प्रोफ़ाइल डेटा का उपयोग करें',
      urdu: 'میرے Raabta پروفائل ڈیٹا کا استعمال کریں',
    ),
    'cv_start_profile_subtitle': l10nEntry(
      english: 'Pre-fill contact, roles, and skills from EOSB & profile.',
      arabic: 'تعبئة مسبقة للاتصال والأدوار والمهارات من EOSB والملف.',
      hindi: 'EOSB और प्रोफ़ाइल से संपर्क, भूमिकाएँ और कौशल पूर्व-भरें।',
      urdu: 'EOSB اور پروفائل سے رابطہ، کردار اور مہارتیں پہلے سے بھریں۔',
    ),
    'cv_start_import_title': l10nEntry(
      english: 'Start from an existing resume',
      arabic: 'البدء من سيرة موجودة',
      hindi: 'मौजूदा रिज़्यूमे से शुरू करें',
      urdu: 'موجودہ ریزیومے سے شروع کریں',
    ),
    'cv_start_import_subtitle': l10nEntry(
      english: 'Photo or scan your CV — OCR + AI extracts editable fields.',
      arabic: 'صوّر أو امسح سيرتك — OCR + AI يستخرج حقولاً قابلة للتحرير.',
      hindi: 'अपने CV की फ़ोटो या स्कैन — OCR + AI संपादन योग्य फ़ील्ड निकालता है।',
      urdu: 'اپنے CV کی تصویر یا اسکین — OCR + AI قابل ترمیم فیلڈز نکالتا ہے۔',
    ),
    'cv_start_scratch_title': l10nEntry(
      english: 'Start from scratch',
      arabic: 'البدء من الصفر',
      hindi: 'शुरुआत से शुरू करें',
      urdu: 'شروع سے شروع کریں',
    ),
    'cv_start_scratch_subtitle': l10nEntry(
      english: 'Empty form — you fill every section manually.',
      arabic: 'نموذج فارغ — تملأ كل قسم يدوياً.',
      hindi: 'खाली फ़ॉर्म — आप हर सेक्शन मैन्युअल भरते हैं।',
      urdu: 'خالی فارم — آپ ہر سیکشن دستی بھرتے ہیں۔',
    ),
    'cv_start_continue_draft_title': l10nEntry(
      english: 'Continue editing saved draft',
      arabic: 'متابعة تحرير المسودة المحفوظة',
      hindi: 'सहेजा गया ड्राफ़्ट संपादित करना जारी रखें',
      urdu: 'محفوظ ڈرافٹ کی ترمیم جاری رکھیں',
    ),
    'cv_start_continue_draft_subtitle': l10nEntry(
      english: 'Resume your last in-progress CV.',
      arabic: 'استئناف آخر سيرة قيد التحرير.',
      hindi: 'अपना अंतिम प्रगति में CV फिर से शुरू करें।',
      urdu: 'اپنا آخری زیر التواء CV دوبارہ شروع کریں۔',
    ),
    'cv_start_vault_title': l10nEntry(
      english: 'View exported CV in Vault',
      arabic: 'عرض السيرة المُصدَّرة في الخزنة',
      hindi: 'वॉल्ट में निर्यात किया CV देखें',
      urdu: 'والٹ میں برآمد شدہ CV دیکھیں',
    ),
    'cv_start_vault_subtitle': l10nEntry(
      english: 'Open preview of your saved PDF CV.',
      arabic: 'افتح معاينة PDF المحفوظ.',
      hindi: 'अपने सहेजे PDF CV का पूर्वावलोकन खोलें।',
      urdu: 'اپنے محفوظ PDF CV کا پیش نظارہ کھولیں۔',
    ),
    'cv_start_headline': l10nEntry(
      english: 'How would you like to start?',
      arabic: 'كيف تريد أن تبدأ؟',
      hindi: 'आप कैसे शुरू करना चाहेंगे?',
      urdu: 'آپ کیسے شروع کرنا چاہیں گے؟',
      malayalam: 'How would you like to start?',
      nepali: 'How would you like to start?',
      bengali: 'How would you like to start?',
      tamil: 'How would you like to start?',
      filipino: 'How would you like to start?',
    ),
    'cv_start_intro': l10nEntry(
      english:
          'Build an ATS-friendly CV. All paths open the same editor — review before export.',
      arabic:
          'أنشئ سيرة متوافقة مع ATS. كل المسارات تفتح نفس المحرر — راجع قبل التصدير.',
      hindi:
          'ATS-अनुकूल CV बनाएं। सभी रास्ते एक ही संपादक खोलते हैं — निर्यात से पहले समीक्षा करें।',
      urdu:
          'ATS-دوست CV بنائیں۔ تمام راستے ایک ہی ایڈیٹر کھولتے ہیں — برآمد سے پہلے جائزہ لیں۔',
      malayalam:
          'Build an ATS-friendly CV. All paths open the same editor — review before export.',
      nepali:
          'Build an ATS-friendly CV. All paths open the same editor — review before export.',
      bengali:
          'Build an ATS-friendly CV. All paths open the same editor — review before export.',
      tamil:
          'Build an ATS-friendly CV. All paths open the same editor — review before export.',
      filipino:
          'Build an ATS-friendly CV. All paths open the same editor — review before export.',
    ),
    'cv_start_intro_premium': l10nEntry(
      english:
          'Build an ATS-friendly CV with optional premium styling. All paths open the same editor — review before export.',
      arabic:
          'أنشئ سيرة متوافقة مع ATS مع تنسيق مميز اختياري. كل المسارات تفتح نفس المحرر — راجع قبل التصدير.',
      hindi:
          'वैकल्पिक प्रीमियम स्टाइल के साथ ATS-अनुकूल CV बनाएं। सभी रास्ते एक ही संपादक खोलते हैं — निर्यात से पहले समीक्षा करें।',
      urdu:
          'اختیاری پریمیم اسٹائل کے ساتھ ATS-دوست CV بنائیں۔ تمام راستے ایک ہی ایڈیٹر کھولتے ہیں — برآمد سے پہلے جائزہ لیں۔',
      malayalam:
          'Build an ATS-friendly CV with optional premium styling. All paths open the same editor — review before export.',
      nepali:
          'Build an ATS-friendly CV with optional premium styling. All paths open the same editor — review before export.',
      bengali:
          'Build an ATS-friendly CV with optional premium styling. All paths open the same editor — review before export.',
      tamil:
          'Build an ATS-friendly CV with optional premium styling. All paths open the same editor — review before export.',
      filipino:
          'Build an ATS-friendly CV with optional premium styling. All paths open the same editor — review before export.',
    ),
    'cv_start_tip_pdf_pages': l10nEntry(
      english:
          'Tip: For PDF resumes, photograph each page clearly or scan via Document Scanner, then upload the images here.',
      arabic:
          'نصيحة: للسير بصيغة PDF، صوّر كل صفحة بوضوح أو امسحها عبر ماسح المستندات، ثم ارفع الصور هنا.',
      hindi:
          'सुझाव: PDF रिज़्यूमे के लिए, हर पृष्ठ की स्पष्ट फ़ोटो लें या Document Scanner से स्कैन करें, फिर यहाँ छवियाँ अपलोड करें।',
      urdu:
          'تجویز: PDF ریزیومے کے لیے ہر صفحے کی واضح تصویر لیں یا Document Scanner سے اسکین کریں، پھر یہاں تصاویر اپ لوڈ کریں۔',
      malayalam:
          'Tip: For PDF resumes, photograph each page clearly or scan via Document Scanner, then upload the images here.',
      nepali:
          'Tip: For PDF resumes, photograph each page clearly or scan via Document Scanner, then upload the images here.',
      bengali:
          'Tip: For PDF resumes, photograph each page clearly or scan via Document Scanner, then upload the images here.',
      tamil:
          'Tip: For PDF resumes, photograph each page clearly or scan via Document Scanner, then upload the images here.',
      filipino:
          'Tip: For PDF resumes, photograph each page clearly or scan via Document Scanner, then upload the images here.',
    ),
    'cv_busy_working': l10nEntry(
      english: 'Working…',
      arabic: 'جاري العمل…',
      hindi: 'काम जारी…',
      urdu: 'کام جاری…',
      malayalam: 'Working…',
      nepali: 'Working…',
      bengali: 'Working…',
      tamil: 'Working…',
      filipino: 'Working…',
    ),
    'cv_busy_loading_profile': l10nEntry(
      english: 'Loading profile & EOSB data…',
      arabic: 'جاري تحميل الملف وبيانات EOSB…',
      hindi: 'प्रोफ़ाइल और EOSB डेटा लोड हो रहा है…',
      urdu: 'پروفائل اور EOSB ڈیٹا لوڈ ہو رہا ہے…',
      malayalam: 'Loading profile & EOSB data…',
      nepali: 'Loading profile & EOSB data…',
      bengali: 'Loading profile & EOSB data…',
      tamil: 'Loading profile & EOSB data…',
      filipino: 'Loading profile & EOSB data…',
    ),
    'cv_busy_starting_blank': l10nEntry(
      english: 'Starting blank CV…',
      arabic: 'جاري بدء سيرة فارغة…',
      hindi: 'खाली CV शुरू हो रहा है…',
      urdu: 'خالی CV شروع ہو رہا ہے…',
      malayalam: 'Starting blank CV…',
      nepali: 'Starting blank CV…',
      bengali: 'Starting blank CV…',
      tamil: 'Starting blank CV…',
      filipino: 'Starting blank CV…',
    ),
    'cv_busy_loading_saved': l10nEntry(
      english: 'Loading saved CV…',
      arabic: 'جاري تحميل السيرة المحفوظة…',
      hindi: 'सहेजा CV लोड हो रहा है…',
      urdu: 'محفوظ CV لوڈ ہو رہا ہے…',
      malayalam: 'Loading saved CV…',
      nepali: 'Loading saved CV…',
      bengali: 'Loading saved CV…',
      tamil: 'Loading saved CV…',
      filipino: 'Loading saved CV…',
    ),
    'cv_busy_reading_document': l10nEntry(
      english: 'Reading document text…',
      arabic: 'جاري قراءة نص المستند…',
      hindi: 'दस्तावेज़ पाठ पढ़ा जा रहा है…',
      urdu: 'دستاویز کا متن پڑھا جا رہا ہے…',
      malayalam: 'Reading document text…',
      nepali: 'Reading document text…',
      bengali: 'Reading document text…',
      tamil: 'Reading document text…',
      filipino: 'Reading document text…',
    ),
    'cv_busy_extracting_ai': l10nEntry(
      english: 'Extracting CV fields with AI…',
      arabic: 'جاري استخراج حقول السيرة بالذكاء الاصطناعي…',
      hindi: 'AI से CV फ़ील्ड निकाले जा रहे हैं…',
      urdu: 'AI سے CV فیلڈز نکالی جا رہی ہیں…',
      malayalam: 'Extracting CV fields with AI…',
      nepali: 'Extracting CV fields with AI…',
      bengali: 'Extracting CV fields with AI…',
      tamil: 'Extracting CV fields with AI…',
      filipino: 'Extracting CV fields with AI…',
    ),
    'cv_busy_saving_draft': l10nEntry(
      english: 'Saving draft…',
      arabic: 'جاري حفظ المسودة…',
      hindi: 'ड्राफ़्ट सहेजा जा रहा है…',
      urdu: 'ڈرافٹ محفوظ ہو رہا ہے…',
      malayalam: 'Saving draft…',
      nepali: 'Saving draft…',
      bengali: 'Saving draft…',
      tamil: 'Saving draft…',
      filipino: 'Saving draft…',
    ),
    'cv_error_prefill_profile': l10nEntry(
      english: 'Could not pre-fill from profile.',
      arabic: 'تعذرت التعبئة المسبقة من الملف.',
      hindi: 'प्रोफ़ाइल से पूर्व-भरना संभव नहीं।',
      urdu: 'پروفائل سے پہلے سے بھرنا ممکن نہیں۔',
      malayalam: 'Could not pre-fill from profile.',
      nepali: 'Could not pre-fill from profile.',
      bengali: 'Could not pre-fill from profile.',
      tamil: 'Could not pre-fill from profile.',
      filipino: 'Could not pre-fill from profile.',
    ),
    'cv_error_create_from_profile': l10nEntry(
      english: 'Could not create CV from profile data.',
      arabic: 'تعذر إنشاء السيرة من بيانات الملف.',
      hindi: 'प्रोफ़ाइल डेटा से CV नहीं बन सका।',
      urdu: 'پروفائل ڈیٹا سے CV نہیں بن سکا۔',
      malayalam: 'Could not create CV from profile data.',
      nepali: 'Could not create CV from profile data.',
      bengali: 'Could not create CV from profile data.',
      tamil: 'Could not create CV from profile data.',
      filipino: 'Could not create CV from profile data.',
    ),
    'cv_error_start_new': l10nEntry(
      english: 'Could not start a new CV.',
      arabic: 'تعذر بدء سيرة جديدة.',
      hindi: 'नया CV शुरू नहीं हो सका।',
      urdu: 'نیا CV شروع نہیں ہو سکا۔',
      malayalam: 'Could not start a new CV.',
      nepali: 'Could not start a new CV.',
      bengali: 'Could not start a new CV.',
      tamil: 'Could not start a new CV.',
      filipino: 'Could not start a new CV.',
    ),
    'cv_error_no_draft': l10nEntry(
      english: 'No saved CV draft found.',
      arabic: 'لم تُعثر على مسودة محفوظة.',
      hindi: 'कोई सहेजा CV ड्राफ़्ट नहीं मिला।',
      urdu: 'کوئی محفوظ CV ڈرافٹ نہیں ملا۔',
      malayalam: 'No saved CV draft found.',
      nepali: 'No saved CV draft found.',
      bengali: 'No saved CV draft found.',
      tamil: 'No saved CV draft found.',
      filipino: 'No saved CV draft found.',
    ),
    'cv_error_import_save_failed': l10nEntry(
      english: 'Import saved failed.',
      arabic: 'فشل حفظ الاستيراد.',
      hindi: 'आयात सहेजना विफल।',
      urdu: 'درآمد محفوظ کرنا ناکام۔',
      malayalam: 'Import saved failed.',
      nepali: 'Import saved failed.',
      bengali: 'Import saved failed.',
      tamil: 'Import saved failed.',
      filipino: 'Import saved failed.',
    ),
    'cv_error_import_failed': l10nEntry(
      english: 'Import failed: {detail}',
      arabic: 'فشل الاستيراد: {detail}',
      hindi: 'आयात विफल: {detail}',
      urdu: 'درآمد ناکام: {detail}',
      malayalam: 'Import failed: {detail}',
      nepali: 'Import failed: {detail}',
      bengali: 'Import failed: {detail}',
      tamil: 'Import failed: {detail}',
      filipino: 'Import failed: {detail}',
    ),

    // ── Preview screen ──────────────────────────────────────────────────────
    'cv_export_failed': l10nEntry(
      english: 'Export failed. Try again.',
      arabic: 'فشل التصدير. حاول مرة أخرى.',
      hindi: 'निर्यात विफल। फिर से कोशिश करें।',
      urdu: 'برآمد ناکام۔ دوبارہ کوشش کریں۔',
    ),
    'cv_preview_modern_switch': l10nEntry(
      english: 'Preview same content in Modern template',
      arabic: 'معاينة نفس المحتوى بقالب Modern',
      hindi: 'Modern टेम्पलेट में वही सामग्री देखें',
      urdu: 'Modern ٹیمپلیٹ میں وہی مواد دیکھیں',
    ),
    'cv_action_share': l10nEntry(
      english: 'Share',
      arabic: 'مشاركة',
      hindi: 'साझा करें',
      urdu: 'شیئر کریں',
    ),
    'cv_qr_title': l10nEntry(
      english: 'Digital business card',
      arabic: 'بطاقة عمل رقمية',
      hindi: 'डिजिटल बिज़नेस कार्ड',
      urdu: 'ڈیجیٹل بزنس کارڈ',
    ),
    'cv_action_share_qr': l10nEntry(
      english: 'Share as QR',
      arabic: 'مشاركة كرمز QR',
      hindi: 'QR के रूप में साझा करें',
      urdu: 'QR کے طور پر شیئر کریں',
    ),
    'cv_action_edit': l10nEntry(
      english: 'Edit CV',
      arabic: 'تحرير السيرة',
      hindi: 'CV संपादित करें',
      urdu: 'CV میں ترمیم کریں',
    ),
    'cv_action_attach_return': l10nEntry(
      english: 'Attach & return to application',
      arabic: 'إرفاق والعودة إلى الطلب',
      hindi: 'संलग्न करें और आवेदन पर लौटें',
      urdu: 'منسلک کریں اور درخواست پر واپس جائیں',
    ),
    'cv_preview_empty_title': l10nEntry(
      english: 'No CV saved yet',
      arabic: 'لا توجد سيرة محفوظة بعد',
      hindi: 'अभी तक कोई CV सहेजा नहीं',
      urdu: 'ابھی تک کوئی CV محفوظ نہیں',
      malayalam: 'No CV saved yet',
      nepali: 'No CV saved yet',
      bengali: 'No CV saved yet',
      tamil: 'No CV saved yet',
      filipino: 'No CV saved yet',
    ),
    'cv_preview_empty_description': l10nEntry(
      english: 'Build your CV in the editor, then export a PDF to Document Vault.',
      arabic: 'أنشئ سيرتك في المحرر، ثم صدّر PDF إلى خزنة المستندات.',
      hindi: 'संपादक में अपना CV बनाएं, फिर Document Vault में PDF निर्यात करें।',
      urdu: 'ایڈیٹر میں اپنی CV بنائیں، پھر Document Vault میں PDF برآمد کریں۔',
      malayalam:
          'Build your CV in the editor, then export a PDF to Document Vault.',
      nepali:
          'Build your CV in the editor, then export a PDF to Document Vault.',
      bengali:
          'Build your CV in the editor, then export a PDF to Document Vault.',
      tamil:
          'Build your CV in the editor, then export a PDF to Document Vault.',
      filipino:
          'Build your CV in the editor, then export a PDF to Document Vault.',
    ),
    'cv_preview_disclaimer': l10nEntry(
      english:
          'In-app preview shows your chosen template. Exported PDF uses the same template styling in a single-column, selectable-text layout.',
      arabic:
          'المعاينة داخل التطبيق تعرض القالب المختار. PDF المُصدَّر يستخدم نفس التنسيق بعمود واحد ونص قابل للتحديد.',
      hindi:
          'इन-ऐप पूर्वावलोकन आपका चुना टेम्पलेट दिखाता है। निर्यात PDF एक कॉलम, चयन योग्य पाठ लेआउट में वही स्टाइल उपयोग करता है।',
      urdu:
          'ایپ میں پیش نظارہ آپ کا منتخب ٹیمپلیٹ دکھاتا ہے۔ برآمد شدہ PDF ایک کالم، قابل انتخاب متن لے آؤٹ میں وہی اسٹائل استعمال کرتا ہے۔',
      malayalam:
          'In-app preview shows your chosen template. Exported PDF uses the same template styling in a single-column, selectable-text layout.',
      nepali:
          'In-app preview shows your chosen template. Exported PDF uses the same template styling in a single-column, selectable-text layout.',
      bengali:
          'In-app preview shows your chosen template. Exported PDF uses the same template styling in a single-column, selectable-text layout.',
      tamil:
          'In-app preview shows your chosen template. Exported PDF uses the same template styling in a single-column, selectable-text layout.',
      filipino:
          'In-app preview shows your chosen template. Exported PDF uses the same template styling in a single-column, selectable-text layout.',
    ),
    'cv_export_saving': l10nEntry(
      english: 'Exporting…',
      arabic: 'جاري التصدير…',
      hindi: 'निर्यात हो रहा है…',
      urdu: 'برآمد ہو رہی ہے…',
      malayalam: 'Exporting…',
      nepali: 'Exporting…',
      bengali: 'Exporting…',
      tamil: 'Exporting…',
      filipino: 'Exporting…',
    ),
    'cv_export_save_pdf_vault': l10nEntry(
      english: 'Save PDF to Vault',
      arabic: 'حفظ PDF في الخزنة',
      hindi: 'PDF को Vault में सहेजें',
      urdu: 'PDF والٹ میں محفوظ کریں',
      malayalam: 'Save PDF to Vault',
      nepali: 'Save PDF to Vault',
      bengali: 'Save PDF to Vault',
      tamil: 'Save PDF to Vault',
      filipino: 'Save PDF to Vault',
    ),
    'cv_export_success_vault': l10nEntry(
      english: 'CV saved to Document Vault.',
      arabic: 'تم حفظ السيرة في خزنة المستندات.',
      hindi: 'CV Document Vault में सहेजा गया।',
      urdu: 'CV Document Vault میں محفوظ ہو گیا۔',
      malayalam: 'CV saved to Document Vault.',
      nepali: 'CV saved to Document Vault.',
      bengali: 'CV saved to Document Vault.',
      tamil: 'CV saved to Document Vault.',
      filipino: 'CV saved to Document Vault.',
    ),
    'cv_export_success_attach': l10nEntry(
      english: 'CV saved and ready to attach to your application.',
      arabic: 'تم حفظ السيرة وهي جاهزة للإرفاق بطلبك.',
      hindi: 'CV सहेजा गया और आपके आवेदन से जोड़ने के लिए तैयार है।',
      urdu: 'CV محفوظ ہو گیا اور آپ کی درخواست سے منسلک کرنے کے لیے تیار ہے۔',
      malayalam: 'CV saved and ready to attach to your application.',
      nepali: 'CV saved and ready to attach to your application.',
      bengali: 'CV saved and ready to attach to your application.',
      tamil: 'CV saved and ready to attach to your application.',
      filipino: 'CV saved and ready to attach to your application.',
    ),
    'cv_qr_caption_vcard': l10nEntry(
      english: 'Scan to save contact (vCard)',
      arabic: 'امسح لحفظ جهة الاتصال (vCard)',
      hindi: 'संपर्क सहेजने के लिए स्कैन करें (vCard)',
      urdu: 'رابطہ محفوظ کرنے کے لیے اسکین کریں (vCard)',
      malayalam: 'Scan to save contact (vCard)',
      nepali: 'Scan to save contact (vCard)',
      bengali: 'Scan to save contact (vCard)',
      tamil: 'Scan to save contact (vCard)',
      filipino: 'Scan to save contact (vCard)',
    ),
  };
}
