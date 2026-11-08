// Bill Tracker UI strings — utility bills, scan/import pipeline, anomaly hints.
//
// Keys in [keysNeedingReview] use English for ML/NE/TA/BN/FL pending native
// review of disclaimer and anomaly copy (TODO-TRANSLATE-REVIEW).
import 'package:flutter/foundation.dart';
import 'package:raabta/core/l10n/app_locale.dart';
import 'package:raabta/core/l10n/locale_catalog_coverage.dart';
import 'package:raabta/core/l10n/locale_catalog_entry.dart';

Map<String, String> _e(
  String english, {
  String? arabic,
  String? hindi,
  String? urdu,
}) =>
    l10nEntry(english: english, arabic: arabic, hindi: hindi, urdu: urdu);

abstract final class BillTrackerStrings {
  static const supportedLocales = AppLocale.supportedLocales;

  /// Scan/review, SMS import, and anomaly disclaimer copy — English fallback
  /// until native review for Malayalam/Nepali/Tamil/Bengali/Filipino.
  static const keysNeedingReview = {
    'payment_disclaimer',
    'mark_paid_tooltip',
    'scan_import_subtitle',
    'scan_pdf_no_text',
    'review_low_confidence',
    'review_field_confirm',
    'import_text_hint',
    'import_text_disclaimer',
    'import_text_no_parse',
    'anomaly_card_intro',
    'anomaly_card_disclaimer',
  };

  /// Part A/B/C upgrade keys — covered by dedicated l10n tests.
  static const upgradeCatalogKeys = {
    'scan_import_title',
    'scan_import_pdf',
    'scan_import_subtitle',
    'scan_pdf_no_text',
    'review_title',
    'review_save',
    'review_bill_type',
    'review_bill_type_hint',
    'review_currency',
    'review_billing_period',
    'review_period_start',
    'review_period_end',
    'review_low_confidence',
    'review_field_confirm',
    'import_text_divider',
    'import_text_title',
    'import_text_screen_title',
    'import_text_hint',
    'import_text_disclaimer',
    'import_text_button',
    'import_text_too_short',
    'import_text_no_parse',
    'anomaly_card_title',
    'anomaly_card_intro',
    'anomaly_card_row',
    'anomaly_card_disclaimer',
    'anomaly_bill_hint',
  };

  static String t(String key, [String locale = 'English']) {
    final map = _strings[key];
    if (map == null) return key;
    final normalized = AppLocale.normalize(locale);
    return map[normalized] ?? map['English'] ?? key;
  }

  static String format(
    String key,
    String locale,
    Map<String, String> params,
  ) {
    var value = t(key, locale);
    for (final entry in params.entries) {
      value = value.replaceAll('{${entry.key}}', entry.value);
    }
    return value;
  }

  static String dueLabel({
    required bool isPaid,
    required int daysUntilDue,
    required String locale,
  }) {
    if (isPaid) return t('due_paid', locale);
    if (daysUntilDue < 0) {
      return format('due_overdue', locale, {
        'days': '${daysUntilDue.abs()}',
      });
    }
    if (daysUntilDue == 0) return t('due_today', locale);
    if (daysUntilDue == 1) return t('due_tomorrow', locale);
    return format('due_in_days', locale, {'days': '$daysUntilDue'});
  }

  static String scanConfidenceLabel(double confidence, String locale) {
    if (confidence >= 0.65) return t('scan_confidence_high', locale);
    if (confidence >= 0.40) return t('scan_confidence_medium', locale);
    return t('scan_confidence_low', locale);
  }

  @visibleForTesting
  static Iterable<String> get catalogKeys => _strings.keys;

  @visibleForTesting
  static Map<String, Set<String>> get localeCoverageReport =>
      buildLocaleCoverageReport(
        catalog: Map<String, Map<String, String>>.from(_strings),
        supportedLocales: supportedLocales,
      );

  static final _strings = <String, Map<String, String>>{
    'screen_title': _e(
      'Bill Reminders',
      arabic: 'تذكيرات الفواتير',
      hindi: 'बिल अनुस्मारक',
      urdu: 'بل یاددہانیاں',
    ),
    'add_bill_tooltip': _e('Add Bill', arabic: 'إضافة فاتورة'),
    'add_loan_tooltip': _e('Add Loan', arabic: 'إضافة قرض'),
    'tab_utility_bills': _e('Utility Bills', arabic: 'فواتير الخدمات'),
    'tab_friends_family': _e('Friends & Family', arabic: 'الأصدقاء والعائلة'),
    'loading_bills': _e('Loading your bills...', arabic: 'جاري تحميل فواتيرك...'),
    'error_load_bills': _e(
      'Could not load bills.',
      arabic: 'تعذّر تحميل الفواتير.',
    ),
    'empty_title': _e('No bills tracked yet', arabic: 'لا توجد فواتير بعد'),
    'empty_description': _e(
      'Add your Qatar utility bills to track due dates, get AI insights, and never miss a payment.',
      arabic:
          'أضف فواتير قطر لتتبع مواعيد الاستحقاق والحصول على رؤى ذكية وعدم تفويت أي دفعة.',
    ),
    'empty_action': _e('Add First Bill', arabic: 'إضافة أول فاتورة'),
    'add_bill_title': _e('Add Bill', arabic: 'إضافة فاتورة'),
    'or_fill_manually': _e('or fill manually', arabic: 'أو أدخل يدوياً'),
    'label_provider': _e('Provider', arabic: 'مزود الخدمة'),
    'label_amount': _e('Amount (QAR)', arabic: 'المبلغ (ر.ق)'),
    'label_due_date': _e('Due Date', arabic: 'تاريخ الاستحقاق'),
    'hint_amount': _e('0.00'),
    'hint_account': _e(
      'Account / Contract number (optional)',
      arabic: 'رقم الحساب / العقد (اختياري)',
    ),
    'add_bill_button': _e('Add Bill', arabic: 'إضافة فاتورة'),
    'invalid_amount_snack': _e(
      'Please enter a valid amount',
      arabic: 'يرجى إدخال مبلغ صحيح',
    ),
    'could_not_add_bill': _e(
      'Could not add bill: {error}',
      arabic: 'تعذّرت إضافة الفاتورة: {error}',
    ),
    'section_overdue': _e('🔴  Overdue', arabic: '🔴  متأخرة'),
    'section_due_soon': _e('🟡  Due Soon', arabic: '🟡  قريبة الاستحقاق'),
    'section_upcoming': _e('📅  Upcoming', arabic: '📅  قادمة'),
    'section_paid': _e('✅  Paid', arabic: '✅  مدفوعة'),
    'stat_outstanding': _e('Outstanding', arabic: 'المستحق'),
    'stat_overdue': _e('Overdue', arabic: 'متأخرة'),
    'stat_due_soon': _e('Due Soon', arabic: 'قريبة'),
    'ai_analysis': _e('AI Analysis', arabic: 'تحليل ذكي'),
    'ai_analyzing': _e('Analyzing...', arabic: 'جاري التحليل...'),
    'share': _e('Share', arabic: 'مشاركة'),
    'pay_directly_header': _e(
      '🔗  Pay Directly with Provider',
      arabic: '🔗  ادفع مباشرة لدى المزود',
    ),
    'open_provider_site': _e(
      'Pay on Provider Website',
      arabic: 'الدفع على موقع المزود',
    ),
    'payment_disclaimer': _e(
      'RAABTA tracks your bills. Payment is made directly on the provider\'s website or app.',
      arabic:
          'RAABTA يتتبع فواتيرك. الدفع يتم مباشرة على موقع أو تطبيق المزود.',
    ),
    'mark_paid_label': _e('Mark as Paid', arabic: 'تعليم كمدفوعة'),
    'mark_paid_tooltip': _e(
      'Mark this bill as paid in your tracker. This does not process any payment.',
      arabic:
          'علّم هذه الفاتورة كمدفوعة في متتبعك. لا يتم معالجة أي دفعة فعلية.',
    ),
    'paid_badge': _e('✓ Paid', arabic: '✓ مدفوعة'),
    'due_paid': _e('Paid ✓', arabic: 'مدفوعة ✓'),
    'due_overdue': _e('{days}d overdue', arabic: 'متأخرة {days} يوم'),
    'due_today': _e('Due today!', arabic: 'مستحقة اليوم!'),
    'due_tomorrow': _e('Due tomorrow', arabic: 'مستحقة غداً'),
    'due_in_days': _e('Due in {days}d', arabic: 'مستحقة خلال {days} يوم'),
    'ai_error': _e(
      'Could not get AI analysis. Check your connection and try again.',
      arabic: 'تعذّر الحصول على التحليل. تحقق من الاتصال وحاول مجدداً.',
    ),
    'share_all_paid': _e('All bills paid! 🎉', arabic: 'جميع الفواتير مدفوعة! 🎉'),
    'share_header': _e('💳 My Qatar Bills — RAABTA'),
    'share_outstanding': _e('Outstanding: QAR {amount}'),
    'share_paid_count': _e('Paid: {count} bills', arabic: 'مدفوعة: {count} فاتورة'),
    'share_footer': _e('Track Qatar bills with RAABTA • {host}'),
    'legacy_provider_note': _e(
      'Updated from legacy provider to Kahramaa (electricity & water).',
      arabic: 'تم التحديث من مزود قديم إلى كهرماء (كهرباء وماء).',
    ),
    'scan_title': _e(
      'Scan Bill to Auto-Fill',
      arabic: 'مسح الفاتورة للملء التلقائي',
    ),
    'scan_import_title': _e(
      'Scan or Import Bill',
      arabic: 'مسح أو استيراد الفاتورة',
      hindi: 'बिल स्कैन या आयात करें',
      urdu: 'بل اسکین یا درآمد',
    ),
    'scan_import_pdf': _e(
      'Import PDF',
      arabic: 'استيراد PDF',
      hindi: 'PDF आयात',
      urdu: 'PDF درآمد',
    ),
    'scan_import_subtitle': _e(
      'Photo, gallery image, or Kahramaa/Ooredoo/Vodafone e-bill PDF',
      arabic: 'صورة أو PDF لفاتورة كهرماء/أوريدoo/فودافون',
      hindi: 'फ़ोटो, गैलरी, या Kahramaa/Ooredoo/Vodafone e-bill PDF',
      urdu: 'تصویر، گیلری، یا Kahramaa/Ooredoo/Vodafone e-bill PDF',
    ),
    'scan_pdf_no_text': _e(
      'Could not read text from this PDF. Try a photo of the bill instead.',
      arabic: 'تعذّر قراءة النص من PDF. جرّب تصوير الفاتورة.',
      hindi: 'PDF से टेक्स्ट नहीं पढ़ा जा सका। बिल की फ़ोटो आज़माएँ।',
      urdu: 'PDF سے متن نہیں پڑھا جا سکا۔ بل کی تصویر آزمائیں۔',
    ),
    'review_title': _e(
      'Review Bill',
      arabic: 'مراجعة الفاتورة',
      hindi: 'बिल की समीक्षा',
      urdu: 'بل کا جائزہ',
    ),
    'review_save': _e(
      'Save Bill',
      arabic: 'حفظ الفاتورة',
      hindi: 'बिल सहेजें',
      urdu: 'بل محفوظ کریں',
    ),
    'review_bill_type': _e(
      'Bill type',
      arabic: 'نوع الفاتورة',
      hindi: 'बिल प्रकार',
      urdu: 'بل کی قسم',
    ),
    'review_bill_type_hint': _e(
      'e.g. Electricity & Water, Mobile',
      arabic: 'مثلاً كهرباء وماء، جوال',
      hindi: 'जैसे बिजली और पानी, मोबाइल',
      urdu: 'مثلاً بجلی و پانی، موبائل',
    ),
    'review_currency': _e(
      'Currency',
      arabic: 'العملة',
      hindi: 'मुद्रा',
      urdu: 'کرنسی',
    ),
    'review_billing_period': _e(
      'Billing period (optional)',
      arabic: 'فترة الفوترة (اختياري)',
      hindi: 'बिलिंग अवधि (वैकल्पिक)',
      urdu: 'بلنگ مدت (اختیاری)',
    ),
    'review_period_start': _e(
      'Period start',
      arabic: 'بداية الفترة',
      hindi: 'अवधि प्रारंभ',
      urdu: 'مدت آغاز',
    ),
    'review_period_end': _e(
      'Period end',
      arabic: 'نهاية الفترة',
      hindi: 'अवधि समाप्त',
      urdu: 'مدت اختتام',
    ),
    'review_low_confidence': _e(
      'Some fields could not be read clearly — please confirm or fill in before saving.',
      arabic: 'تعذّر قراءة بعض الحقول بوضوح — أكّد أو أكمل قبل الحفظ.',
    ),
    'review_field_confirm': _e(
      'Please confirm: {field}',
      arabic: 'يرجى التأكيد: {field}',
    ),
    'import_text_divider': _e(
      'or paste bill SMS',
      arabic: 'أو الصق رسالة الفاتورة',
      hindi: 'या बिल SMS पेस्ट करें',
      urdu: 'یا بل SMS پیسٹ کریں',
    ),
    'import_text_title': _e(
      'Paste bill SMS or alert text',
      arabic: 'الصق رسالة الفاتورة أو التنبيه',
      hindi: 'बिल SMS या अलर्ट टेक्स्ट पेस्ट करें',
      urdu: 'بل SMS یا الرٹ متن پیسٹ کریں',
    ),
    'import_text_screen_title': _e(
      'Import Bill Text',
      arabic: 'استيراد نص الفاتورة',
      hindi: 'बिल टेक्स्ट आयात',
      urdu: 'بل متن درآمد',
    ),
    'import_text_hint': _e(
      'Copy the SMS from Kahramaa, Ooredoo, or Vodafone and paste here…',
      arabic: 'انسخ رسالة كهرماء أو أوريدoo أو فودافون والصقها هنا…',
      hindi: 'Kahramaa, Ooredoo या Vodafone का SMS कॉपी करके यहाँ पेस्ट करें…',
      urdu: 'Kahramaa، Ooredoo یا Vodafone کا SMS کاپی کر کے یہاں پیسٹ کریں…',
    ),
    'import_text_disclaimer': _e(
      'Raabta never reads SMS in the background — paste or use Share to Raabta only.',
      arabic: 'Raabta لا تقرأ SMS في الخلفية — الصق أو شارك إلى Raabta فقط.',
      hindi: 'Raabta पृष्ठभूमि में SMS नहीं पढ़ता — केवल पेस्ट या Share to Raabta।',
      urdu: 'Raabta پس منظر میں SMS نہیں پڑھتا — صرف پیسٹ یا Share to Raabta۔',
    ),
    'import_text_button': _e(
      'Extract bill details',
      arabic: 'استخراج تفاصيل الفاتورة',
      hindi: 'बिल विवरण निकालें',
      urdu: 'بل کی تفصیل نکالیں',
    ),
    'import_text_too_short': _e(
      'Paste the full bill SMS — text is too short to parse.',
      arabic: 'الصق رسالة الفاتورة كاملة — النص قصير جداً.',
      hindi: 'पूरा बिल SMS पेस्ट करें — टेक्स्ट बहुत छोटा है।',
      urdu: 'مکمل بل SMS پیسٹ کریں — متن بہت چھوٹا ہے۔',
    ),
    'import_text_no_parse': _e(
      'Could not parse bill details from this text. Check the paste and try again.',
      arabic: 'تعذّر استخراج تفاصيل الفاتورة. تحقق من النص وحاول مجدداً.',
      hindi: 'इस टेक्स्ट से बिल विवरण नहीं निकाले जा सके। पेस्ट जाँचें और पुनः प्रयास करें।',
      urdu: 'اس متن سے بل کی تفصیل نہیں نکالی جا سکی۔ پیسٹ چیک کریں اور دوبارہ کوشش کریں۔',
    ),
    'anomaly_card_title': _e(
      'Higher than your usual bills',
      arabic: 'أعلى من فواتيرك المعتادة',
      hindi: 'आपके सामान्य बिल से अधिक',
      urdu: 'آپ کے معمول کے بل سے زیادہ',
    ),
    'anomaly_card_intro': _e(
      'These amounts are noticeably above your recent average for the same provider. '
      'Possible reasons include seasonal use, tariff changes, estimated readings, or a one-off charge — worth checking your statement.',
      arabic:
          'هذه المبالغ أعلى بشكل ملحوظ من متوسطك الأخير لنفس المزود. '
          'قد يكون السبب موسمية الاستهلاك أو تغيّر التعرفة أو قراءة تقديرية أو رسوم لمرة واحدة — راجع كشف حسابك.',
      hindi:
          'ये राशियाँ उसी प्रदाता के आपके हाल के औसत से काफी ऊपर हैं। '
          'कारण मौसमी उपयोग, टैरिफ बदलाव, अनुमानित रीडिंग या एक बार का शुल्क हो सकता है — स्टेटमेंट जाँच लें।',
      urdu:
          'یہ رقوم اسی فراہم کنندہ کے آپ کے حالیہ اوسط سے نمایاں اوپر ہیں۔ '
          'وجہ موسمی استعمال، ٹیرف تبدیلی، تخمینی ریڈنگ یا یک بار چارج ہو سکتی ہے — اسٹیٹمنٹ دیکھ لیں۔',
    ),
    'anomaly_card_row': _e(
      '{provider}: {currency} {amount} (~{percent}% above avg {currency} {average})',
      arabic:
          '{provider}: {amount} {currency} (~{percent}% فوق المتوسط {average} {currency})',
      hindi:
          '{provider}: {currency} {amount} (~{percent}% औसत {currency} {average} से ऊपर)',
      urdu:
          '{provider}: {currency} {amount} (~{percent}% اوسط {currency} {average} سے اوپر)',
    ),
    'anomaly_card_disclaimer': _e(
      'This is a spending pattern hint, not a diagnosis of usage or billing errors.',
      arabic: 'هذا تلميح عن نمط الإنفاق وليس تشخيصاً للاستهلاك أو أخطاء الفوترة.',
      hindi: 'यह खर्च पैटर्न संकेत है, उपयोग या बिलिंग त्रुटि का निदान नहीं।',
      urdu: 'یہ خرچ کا اشارہ ہے، استعمال یا بلنگ کی غلطی کی تشخیص نہیں۔',
    ),
    'anomaly_bill_hint': _e(
      '~{percent}% above your recent avg ({currency} {average})',
      arabic: '~{percent}% فوق متوسطك الأخير ({average} {currency})',
      hindi: '~{percent}% हाल के औसत ({currency} {average}) से ऊपर',
      urdu: '~{percent}% حالیہ اوسط ({currency} {average}) سے اوپر',
    ),
    'scan_ai_powered': _e('AI-powered', arabic: 'مدعوم بالذكاء الاصطناعي'),
    'scan_camera': _e('Camera', arabic: 'الكاميرا'),
    'scan_gallery': _e('Gallery', arabic: 'المعرض'),
    'scan_open_scanner': _e(
      'Open RAABTA Scanner for multi-page bills',
      arabic: 'افتح ماسح RAABTA للفواتير متعددة الصفحات',
    ),
    'scan_subtitle': _e(
      'Provider, amount & due date auto-filled from bill photo',
      arabic: 'يُملأ المزود والمبلغ وتاريخ الاستحقاق تلقائياً من صورة الفاتورة',
    ),
    'scan_reading': _e('Reading bill text...', arabic: 'جاري قراءة نص الفاتورة...'),
    'scan_extracting': _e(
      'Extracting bill details with AI...',
      arabic: 'جاري استخراج تفاصيل الفاتورة بالذكاء الاصطناعي...',
    ),
    'scan_processing': _e('Processing...', arabic: 'جاري المعالجة...'),
    'scan_camera_macos': _e(
      'Camera scanning available on iPhone only. Use Upload Photo instead.',
      arabic: 'مسح الكاميرا متاح على iPhone فقط. استخدم رفع صورة بدلاً من ذلك.',
    ),
    'scan_no_text': _e(
      'Could not read text from this image. Try a clearer photo of your bill.',
      arabic: 'تعذّر قراءة النص من هذه الصورة. جرّب صورة أوضح للفاتورة.',
    ),
    'scan_process_error': _e(
      'Could not process bill photo. Try again.',
      arabic: 'تعذّرت معالجة صورة الفاتورة. حاول مجدداً.',
    ),
    'scan_confidence_high': _e(
      'High confidence — fields auto-filled',
      arabic: 'ثقة عالية — تم ملء الحقول تلقائياً',
    ),
    'scan_confidence_medium': _e(
      'Medium confidence — please verify all fields',
      arabic: 'ثقة متوسطة — يرجى التحقق من جميع الحقول',
    ),
    'loan_add_title': _e(
      'Add Loan',
      arabic: 'إضافة قرض',
      hindi: 'Add Loan',
      urdu: 'Add Loan',
    ),
    'loan_person_name': _e(
      'Person name',
      arabic: 'اسم الشخص',
      hindi: 'Person name',
      urdu: 'Person name',
    ),
    'loan_person_hint': _e(
      'e.g. Ahmed',
      arabic: 'مثلاً أحمد',
      hindi: 'e.g. Ahmed',
      urdu: 'e.g. Ahmed',
    ),
    'loan_direction_lent': _e(
      'I lent',
      arabic: 'أقرضت',
      hindi: 'I lent',
      urdu: 'I lent',
    ),
    'loan_direction_borrowed': _e(
      'I borrowed',
      arabic: 'اقترضت',
      hindi: 'I borrowed',
      urdu: 'I borrowed',
    ),
    'loan_date_label': _e(
      'Loan date',
      arabic: 'تاريخ القرض',
      hindi: 'Loan date',
      urdu: 'Loan date',
    ),
    'loan_due_date_label': _e(
      'Due date',
      arabic: 'تاريخ الاستحقاق',
      hindi: 'Due date',
      urdu: 'Due date',
    ),
    'loan_notes_optional': _e(
      'Notes (optional)',
      arabic: 'ملاحظات (اختياري)',
      hindi: 'Notes (optional)',
      urdu: 'Notes (optional)',
    ),
    'loan_notes_hint': _e(
      'e.g. for rent deposit',
      arabic: 'مثلاً لتأمين الإيجار',
      hindi: 'e.g. for rent deposit',
      urdu: 'e.g. for rent deposit',
    ),
    'loan_save_button': _e(
      'Save Loan',
      arabic: 'حفظ القرض',
      hindi: 'Save Loan',
      urdu: 'Save Loan',
    ),
    'loan_validation_person_amount': _e(
      'Enter a person name and valid amount',
      arabic: 'أدخل اسماً ومبلغاً صحيحاً',
      hindi: 'Enter a person name and valid amount',
      urdu: 'Enter a person name and valid amount',
    ),
    'loan_save_failed': _e(
      'Could not save loan: {error}',
      arabic: 'تعذّر حفظ القرض: {error}',
      hindi: 'Could not save loan: {error}',
      urdu: 'Could not save loan: {error}',
    ),
    'loan_load_error': _e(
      'Could not load loans. {error}',
      arabic: 'تعذّر تحميل القروض. {error}',
      hindi: 'Could not load loans. {error}',
      urdu: 'Could not load loans. {error}',
    ),
    'loan_archive_header': _e(
      'Settled loans archive',
      arabic: 'أرشيف القروض المسددة',
      hindi: 'Settled loans archive',
      urdu: 'Settled loans archive',
    ),
    'loan_active_header': _e(
      'People with active balances',
      arabic: 'أشخاص بأرصدة نشطة',
      hindi: 'People with active balances',
      urdu: 'People with active balances',
    ),
    'loan_tab_archive': _e(
      'Archive',
      arabic: 'الأرشيف',
      hindi: 'Archive',
      urdu: 'Archive',
    ),
    'loan_tab_active': _e(
      'Active',
      arabic: 'نشط',
      hindi: 'Active',
      urdu: 'Active',
    ),
    'loan_no_archive': _e(
      'No archived people yet',
      arabic: 'لا أشخاص في الأرشيف بعد',
      hindi: 'No archived people yet',
      urdu: 'No archived people yet',
    ),
    'loan_all_settled': _e(
      'All loans settled 🎉',
      arabic: 'كل القروض مسددة 🎉',
      hindi: 'All loans settled 🎉',
      urdu: 'All loans settled 🎉',
    ),
    'loan_empty_body': _e(
      'Track money lent to or borrowed from friends & family',
      arabic: 'تتبّع المال المُقرَض أو المُقترَض من الأصدقاء والعائلة',
      hindi: 'Track money lent to or borrowed from friends & family',
      urdu: 'Track money lent to or borrowed from friends & family',
    ),
    'loan_details_title': _e(
      'Loan details',
      arabic: 'تفاصيل القرض',
      hindi: 'Loan details',
      urdu: 'Loan details',
    ),
    'loan_person_not_found': _e(
      'Person not found',
      arabic: 'الشخص غير موجود',
      hindi: 'Person not found',
      urdu: 'Person not found',
    ),
    'loan_share_summary': _e(
      'Share summary',
      arabic: 'مشاركة الملخص',
      hindi: 'Share summary',
      urdu: 'Share summary',
    ),
    'loan_running_balance': _e(
      'Running balance',
      arabic: 'الرصيد الجاري',
      hindi: 'Running balance',
      urdu: 'Running balance',
    ),
    'loan_net_owed_to_you': _e(
      'Net owed to you',
      arabic: 'صافي المستحق لك',
      hindi: 'Net owed to you',
      urdu: 'Net owed to you',
    ),
    'loan_net_you_owe': _e(
      'Net you owe',
      arabic: 'صافي عليك',
      hindi: 'Net you owe',
      urdu: 'Net you owe',
    ),
    'loan_send_reminder': _e(
      'Send Reminder',
      arabic: 'إرسال تذكير',
      hindi: 'Send Reminder',
      urdu: 'Send Reminder',
    ),
    'loan_history': _e(
      'History',
      arabic: 'السجل',
      hindi: 'History',
      urdu: 'History',
    ),
    'loan_remove_all_records': _e(
      'Remove all records for this person',
      arabic: 'حذف كل سجلات هذا الشخص',
      hindi: 'Remove all records for this person',
      urdu: 'Remove all records for this person',
    ),
    'loan_record_repayment': _e(
      'Record repayment',
      arabic: 'تسجيل سداد',
      hindi: 'Record repayment',
      urdu: 'Record repayment',
    ),
    'loan_remaining_helper': _e(
      'Remaining: QAR {amount}',
      arabic: 'المتبقي: {amount} ر.ق',
      hindi: 'Remaining: QAR {amount}',
      urdu: 'Remaining: QAR {amount}',
    ),
    'loan_repayment_exceeds': _e(
      'Repayment cannot exceed remaining QAR {amount}',
      arabic: 'لا يمكن أن يتجاوز السداد {amount} ر.ق',
      hindi: 'Repayment cannot exceed remaining QAR {amount}',
      urdu: 'Repayment cannot exceed remaining QAR {amount}',
    ),
    'loan_save': _e(
      'Save',
      arabic: 'حفظ',
      hindi: 'Save',
      urdu: 'Save',
    ),
    'loan_cancel': _e(
      'Cancel',
      arabic: 'إلغاء',
      hindi: 'Cancel',
      urdu: 'Cancel',
    ),
    'loan_delete_active_title': _e(
      'Delete active loan records?',
      arabic: 'حذف سجلات القروض النشطة؟',
      hindi: 'Delete active loan records?',
      urdu: 'Delete active loan records?',
    ),
    'loan_delete_active_body': _e(
      'Outstanding balance: QAR {amount}. This will permanently remove all entries for this person.',
      arabic: 'الرصيد المستحق: {amount} ر.ق. سيُحذف كل سجل هذا الشخص نهائياً.',
      hindi: 'Outstanding balance: QAR {amount}. This will permanently remove all entries for this person.',
      urdu: 'Outstanding balance: QAR {amount}. This will permanently remove all entries for this person.',
    ),
    'loan_delete': _e(
      'Delete',
      arabic: 'حذف',
      hindi: 'Delete',
      urdu: 'Delete',
    ),
    'loan_send_reminder_title': _e(
      'Send reminder',
      arabic: 'إرسال تذكير',
      hindi: 'Send reminder',
      urdu: 'Send reminder',
    ),
    'loan_edit_message': _e(
      'Edit message before sending',
      arabic: 'عدّل الرسالة قبل الإرسال',
      hindi: 'Edit message before sending',
      urdu: 'Edit message before sending',
    ),
    'loan_share_via': _e(
      'Share via…',
      arabic: 'مشاركة عبر…',
      hindi: 'Share via…',
      urdu: 'Share via…',
    ),
    'loan_status_active': _e(
      'Active',
      arabic: 'نشط',
      hindi: 'Active',
      urdu: 'Active',
    ),
    'loan_status_overdue': _e(
      'Overdue',
      arabic: 'متأخر',
      hindi: 'Overdue',
      urdu: 'Overdue',
    ),
    'loan_status_settled': _e(
      'Settled',
      arabic: 'مسدّد',
      hindi: 'Settled',
      urdu: 'Settled',
    ),
    'loan_direction_they_owe': _e(
      'They owe you',
      arabic: 'عليهم لك',
      hindi: 'They owe you',
      urdu: 'They owe you',
    ),
    'loan_direction_you_owe': _e(
      'You owe them',
      arabic: 'عليك لهم',
      hindi: 'You owe them',
      urdu: 'You owe them',
    ),
    'loan_owes_you': _e(
      'owes you',
      arabic: 'يدين لك',
      hindi: 'owes you',
      urdu: 'owes you',
    ),
    'loan_you_owe': _e(
      'you owe',
      arabic: 'أنت تدين',
      hindi: 'you owe',
      urdu: 'you owe',
    ),
    'loan_active_count_one': _e(
      '{count} active loan',
      arabic: '{count} قرض نشط',
      hindi: '{count} active loan',
      urdu: '{count} active loan',
    ),
    'loan_active_count_many': _e(
      '{count} active loans',
      arabic: '{count} قروض نشطة',
      hindi: '{count} active loans',
      urdu: '{count} active loans',
    ),
    'loan_share_caption': _e(
      'Loan summary for {name} — tracked with RAABTA',
      arabic: 'ملخص قرض {name} — متتبع على RAABTA',
      hindi: 'Loan summary for {name} — tracked with RAABTA',
      urdu: 'Loan summary for {name} — tracked with RAABTA',
    ),
    'loan_entry_amount_line': _e(
      'QAR {amount} · Remaining QAR {remaining}',
      arabic: 'QAR {amount} · المتبقي QAR {remaining}',
      hindi: 'QAR {amount} · Remaining QAR {remaining}',
      urdu: 'QAR {amount} · Remaining QAR {remaining}',
    ),
    'loan_entry_dates_line': _e(
      'Loan {loanDate} · Due {dueDate}',
      arabic: 'قرض {loanDate} · استحقاق {dueDate}',
      hindi: 'Loan {loanDate} · Due {dueDate}',
      urdu: 'Loan {loanDate} · Due {dueDate}',
    ),
    'loan_repayments_count': _e(
      'Repayments: {count}',
      arabic: 'السدادات: {count}',
      hindi: 'Repayments: {count}',
      urdu: 'Repayments: {count}',
    ),
    'loan_record_repayment_btn': _e(
      'Record Repayment',
      arabic: 'تسجيل سداد',
      hindi: 'Record Repayment',
      urdu: 'Record Repayment',
    ),
    'loan_archive_btn': _e(
      'Archive',
      arabic: 'أرشفة',
      hindi: 'Archive',
      urdu: 'Archive',
    ),
    'loan_delete_body_named': _e(
      '{name} still has an outstanding balance of QAR {amount}. This will permanently remove all entries for this person.',
      arabic: '{name} لا يزال عليه QAR {amount}. سيُحذف كل سجل هذا الشخص.',
      hindi: '{name} still has outstanding QAR {amount}. All entries will be removed.',
      urdu: '{name} still has outstanding QAR {amount}. All entries will be removed.',
    ),
    'loan_reminder_share_lent': _e(
      'Hi {name}, friendly reminder that QAR {amount} is still outstanding (due {due}). Let me know if you need more time. — via RAABTA',
      arabic: 'مرحباً {name}، تذكير ودي بأن QAR {amount} لا يزال مستحقاً (استحقاق {due}). أخبرني إن احتجت وقتاً إضافياً. — عبر RAABTA',
      hindi: 'Hi {name}, friendly reminder that QAR {amount} is still outstanding (due {due}). Let me know if you need more time. — via RAABTA',
      urdu: 'Hi {name}, friendly reminder that QAR {amount} is still outstanding (due {due}). Let me know if you need more time. — via RAABTA',
    ),
    'loan_reminder_share_borrowed': _e(
      'Hi {name}, I wanted to confirm I still owe you QAR {amount} (was due {due}). I\'ll update you on repayment soon. — via RAABTA',
      arabic: 'مرحباً {name}، أود تأكيد أنني ما زلت أدين لك QAR {amount} (كان مستحقاً {due}). سأحدّثك قريباً عن السداد. — عبر RAABTA',
      hindi: 'Hi {name}, I wanted to confirm I still owe you QAR {amount} (was due {due}). I\'ll update you on repayment soon. — via RAABTA',
      urdu: 'Hi {name}, I wanted to confirm I still owe you QAR {amount} (was due {due}). I\'ll update you on repayment soon. — via RAABTA',
    ),
    'scan_confidence_low': _e(
      'Low confidence — please fill in manually',
      arabic: 'ثقة منخفضة — يرجى الإدخال يدوياً',
    ),
  };
}
