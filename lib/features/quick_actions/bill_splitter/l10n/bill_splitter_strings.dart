// Bill Splitter UI strings — receipt itemization, manual split, settlement.
//
// Scan pipeline button/progress copy is reused from [BillTrackerStrings]
// via [BillSplitterStrings.scanCamera] etc. (same translations as Bill Tracker).
//
// Keys in [keysNeedingReview] use English for Malayalam/Nepali/Tamil pending
// native review (TODO-TRANSLATE-REVIEW).
import 'package:flutter/foundation.dart';
import 'package:raabta/core/l10n/app_locale.dart';
import 'package:raabta/core/l10n/locale_catalog_coverage.dart';
import 'package:raabta/core/l10n/locale_catalog_entry.dart';
import 'package:raabta/features/quick_actions/bill_tracker/l10n/bill_tracker_strings.dart';

abstract final class BillSplitterStrings {
  static const supportedLocales = AppLocale.supportedLocales;

  /// Complex receipt/settlement copy — ML/NE/TA use English until native review.
  static const keysNeedingReview = {
    'receipt_prorate_charges',
    'receipt_equal_charges',
    'receipt_charge_mode_hint',
    'receipt_assign_instructions',
    'settlement_payer_hint',
    'scan_receipt_subtitle',
    'receipt_currency_confirm_body',
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

  // ── Reused Bill Tracker scan pipeline strings ─────────────────
  static String scanCamera(String locale) =>
      BillTrackerStrings.t('scan_camera', locale);

  static String scanGallery(String locale) =>
      BillTrackerStrings.t('scan_gallery', locale);

  static String scanReading(String locale) =>
      BillTrackerStrings.t('scan_reading', locale);

  static String scanExtracting(String locale) =>
      BillTrackerStrings.t('scan_extracting', locale);

  static String scanProcessing(String locale) =>
      BillTrackerStrings.t('scan_processing', locale);

  static String scanCameraMacos(String locale) =>
      BillTrackerStrings.t('scan_camera_macos', locale);

  static String scanNoText(String locale) =>
      BillTrackerStrings.t('scan_no_text', locale);

  static String scanProcessError(String locale) =>
      BillTrackerStrings.t('scan_process_error', locale);

  @visibleForTesting
  static Map<String, Set<String>> get localeCoverageReport =>
      buildLocaleCoverageReport(
        catalog: Map<String, Map<String, String>>.from(_strings),
        supportedLocales: supportedLocales,
      );

  @visibleForTesting
  static Iterable<String> get catalogKeys => _strings.keys;

  static final _strings = <String, Map<String, String>>{
    'screen_title': l10nEntry(
      english: 'Split Bills',
      arabic: 'تقسيم الفواتير',
      hindi: 'बिल बाँटें',
      urdu: 'بل تقسیم کریں',
      bengali: 'বিল ভাগ করুন',
      filipino: 'Split Bills',
      tamil: 'பில்களைப் பிரிக்கவும்',
      malayalam: 'ബില്ലുകൾ പങ്കിടുക',
      nepali: 'बिल बाँट्नुहोस्',
    ),
    'rates_loading': l10nEntry(
      english: 'Loading rates...',
      arabic: 'جاري تحميل الأسعار...',
      hindi: 'दरें लोड हो रही हैं...',
      urdu: 'ریٹ لوڈ ہو رہے ہیں...',
      bengali: 'রেট লোড হচ্ছে...',
      filipino: 'Loading rates...',
    ),
    'rates_live': l10nEntry(
      english: 'Live rates',
      arabic: 'أسعار مباشرة',
      hindi: 'लाइव दरें',
      urdu: 'لIVE ریٹ',
      bengali: 'লাইভ রেট',
      filipino: 'Live rates',
    ),
    'rates_offline': l10nEntry(
      english: 'Offline rates',
      arabic: 'أسعار دون اتصال',
      hindi: 'ऑफ़लाइन दरें',
      urdu: 'آف لائن ریٹ',
      bengali: 'অফলাইন রেট',
      filipino: 'Offline rates',
    ),
    'total_bill': l10nEntry(
      english: 'Total Bill',
      arabic: 'إجمالي الفاتورة',
      hindi: 'कुल बिल',
      urdu: 'کل بل',
      bengali: 'মোট বিল',
      filipino: 'Total Bill',
    ),
    'service_tax': l10nEntry(
      english: 'Service / Tax',
      arabic: 'خدمة / ضريبة',
      hindi: 'सेवा / कर',
      urdu: 'سروس / ٹیکس',
      bengali: 'সার্ভিস / ট্যাক্স',
      filipino: 'Service / Tax',
    ),
    'label_total': l10nEntry(
      english: 'Total',
      arabic: 'الإجمالي',
      hindi: 'कुल',
      urdu: 'کل',
      bengali: 'মোট',
      filipino: 'Total',
    ),
    'label_per_person': l10nEntry(
      english: 'Per Person',
      arabic: 'لكل شخص',
      hindi: 'प्रति व्यक्ति',
      urdu: 'فی شخص',
      bengali: 'প্রতি জন',
      filipino: 'Per Person',
    ),
    'add_people': l10nEntry(
      english: 'Add People',
      arabic: 'إضافة أشخاص',
      hindi: 'लोग जोड़ें',
      urdu: 'لوگ شامل کریں',
      bengali: 'মানুষ যোগ করুন',
      filipino: 'Add People',
    ),
    'people_count': l10nEntry(
      english: 'People ({count})',
      arabic: 'الأشخاص ({count})',
      hindi: 'लोग ({count})',
      urdu: 'لوگ ({count})',
      bengali: 'মানুষ ({count})',
      filipino: 'People ({count})',
    ),
    'add_person': l10nEntry(
      english: 'Add Person',
      arabic: 'إضافة شخص',
      hindi: 'व्यक्ति जोड़ें',
      urdu: 'شخص شامل کریں',
      bengali: 'ব্যক্তি যোগ করুন',
      filipino: 'Add Person',
    ),
    'empty_people_title': l10nEntry(
      english: 'No people added yet',
      arabic: 'لم تُضف أشخاص بعد',
      hindi: 'अभी कोई व्यक्ति नहीं जोड़ा',
      urdu: 'ابھی کوئی شخص شامل نہیں',
      bengali: 'এখনও কেউ যোগ হয়নি',
      filipino: 'No people added yet',
    ),
    'empty_people_description': l10nEntry(
      english: 'Tap "Add Person" to start splitting',
      arabic: 'اضغط "إضافة شخص" لبدء التقسيم',
      hindi: '"व्यक्ति जोड़ें" दबाकर विभाजन शुरू करें',
      urdu: '"شخص شامل کریں" دبائیں',
      bengali: '"ব্যক্তি যোগ করুন" ট্যাপ করুন',
      filipino: 'Tap "Add Person" to start splitting',
    ),
    'swipe_hint': l10nEntry(
      english: '← Swipe left on a person to remove',
      arabic: '← اسحب يساراً لإزالة شخص',
      hindi: '← हटाने के लिए बाएँ स्वाइप करें',
      urdu: '← ہٹانے کے لیے بائیں سوائپ',
      bengali: '← সরাতে বামে সোয়াইপ',
      filipino: '← Swipe left on a person to remove',
    ),
    'my_splits': l10nEntry(
      english: 'My Splits',
      arabic: 'تقسيماتي',
      hindi: 'मेरे विभाजन',
      urdu: 'میری تقسیمات',
      bengali: 'আমার ভাগ',
      filipino: 'My Splits',
    ),
    'save_recurring': l10nEntry(
      english: 'Save Recurring',
      arabic: 'حفظ متكرر',
      hindi: 'आवर्ती सहेजें',
      urdu: 'بار بار محفوظ',
      bengali: 'পুনরাবৃত্তি সংরক্ষণ',
      filipino: 'Save Recurring',
    ),
    'send_to_group': l10nEntry(
      english: 'Send to Group Chat',
      arabic: 'إرسال لمجموعة الدردشة',
      hindi: 'ग्रुप चैट में भेजें',
      urdu: 'گروپ چیٹ میں بھیجیں',
      bengali: 'গ্রুপ চ্যাটে পাঠান',
      filipino: 'Send to Group Chat',
    ),
    'add_person_title': l10nEntry(
      english: 'Add Person',
      arabic: 'إضافة شخص',
      hindi: 'व्यक्ति जोड़ें',
      urdu: 'شخص شامل کریں',
      bengali: 'ব্যক্তি যোগ করুন',
      filipino: 'Add Person',
    ),
    'name_hint': l10nEntry(
      english: 'Name (e.g. Raj, Marco, James)',
      arabic: 'الاسم (مثال: Raj, Marco, James)',
      hindi: 'नाम (जैसे Raj, Marco, James)',
      urdu: 'نام (مثال: Raj, Marco, James)',
      bengali: 'নাম (যেমন Raj, Marco, James)',
      filipino: 'Name (e.g. Raj, Marco, James)',
    ),
    'home_currency': l10nEntry(
      english: 'Home Currency',
      arabic: 'عملة البلد',
      hindi: 'घरेलू मुद्रा',
      urdu: 'گھر کی کرنسی',
      bengali: 'নিজ দেশের মুদ্রা',
      filipino: 'Home Currency',
    ),
    'add_to_bill': l10nEntry(
      english: 'Add to Bill',
      arabic: 'إضافة للفاتورة',
      hindi: 'बिल में जोड़ें',
      urdu: 'بل میں شامل',
      bengali: 'বিলে যোগ করুন',
      filipino: 'Add to Bill',
    ),
    'snack_need_bill_and_person': l10nEntry(
      english: 'Add a bill amount and at least one person.',
      arabic: 'أضف مبلغ الفاتورة وشخصاً واحداً على الأقل.',
      hindi: 'बिल राशि और कम से कम एक व्यक्ति जोड़ें।',
      urdu: 'بل کی رقم اور کم از کم ایک شخص شامل کریں۔',
      bengali: 'বিলের পরিমাণ ও কমপক্ষে একজন যোগ করুন।',
      filipino: 'Add a bill amount and at least one person.',
    ),
    'snack_recurring_saved': l10nEntry(
      english: '✅ Recurring split saved! View in My Splits.',
      arabic: '✅ تم حفظ التقسيم المتكرر! اعرضه في تقسيماتي.',
      hindi: '✅ आवर्ती विभाजन सहेजा! My Splits में देखें।',
      urdu: '✅ بار بار تقسیم محفوظ! My Splits میں دیکھیں۔',
      bengali: '✅ পুনরাবৃত্তি ভাগ সংরক্ষিত! My Splits-এ দেখুন।',
      filipino: '✅ Recurring split saved! View in My Splits.',
    ),
    'entry_mode_manual': l10nEntry(
      english: 'Enter manually',
      arabic: 'إدخال يدوي',
      hindi: 'मैन्युअल दर्ज करें',
      urdu: 'دستی درج',
      bengali: 'ম্যানুয়ালি লিখুন',
      filipino: 'Enter manually',
    ),
    'entry_mode_scan': l10nEntry(
      english: 'Scan receipt',
      arabic: 'مسح الإيصال',
      hindi: 'रसीद स्कैन',
      urdu: 'رسید scan',
      bengali: 'রসিদ scan',
      filipino: 'Scan receipt',
    ),
    'scan_receipt_title': l10nEntry(
      english: 'Scan a receipt',
      arabic: 'مسح إيصال',
      hindi: 'रसीद स्कैन करें',
      urdu: 'رسید scan کریں',
      bengali: 'রসিদ scan করুন',
      filipino: 'Scan a receipt',
    ),
    'scan_receipt_subtitle': l10nEntry(
      english:
          'Photograph a restaurant or shop receipt to itemize the bill.',
      arabic: 'صوّر إيصال مطعم أو متجر لتفصيل الفاتورة.',
      hindi:
          'Photograph a restaurant or shop receipt to itemize the bill.',
      urdu: 'Photograph a restaurant or shop receipt to itemize the bill.',
      malayalam:
          'Photograph a restaurant or shop receipt to itemize the bill.',
      nepali: 'Photograph a restaurant or shop receipt to itemize the bill.',
      tamil: 'Photograph a restaurant or shop receipt to itemize the bill.',
      bengali:
          'Photograph a restaurant or shop receipt to itemize the bill.',
      filipino:
          'Photograph a restaurant or shop receipt to itemize the bill.',
    ),
    'receipt_review_title': l10nEntry(
      english: 'Review receipt',
      arabic: 'مراجعة الإيصال',
      hindi: 'रसीद जाँचें',
      urdu: 'رسید دیکھیں',
      bengali: 'রসিদ পরীক্ষা',
      filipino: 'Review receipt',
    ),
    'receipt_low_confidence_note': l10nEntry(
      english:
          'Some amounts may be unclear — please double-check every line before continuing.',
      arabic:
          'قد تكون بعض المبالغ غير واضحة — راجع كل سطر قبل المتابعة.',
      hindi:
          'कुछ राशियाँ unclear हो सकती हैं — आगे बढ़ने से पहले हर पंक्ति जाँचें।',
      urdu:
          'کچھ رقوم unclear ہو سکتی ہیں — آگے بڑھنے سے پہلے ہر لائن چیک کریں۔',
      bengali:
          'কিছু amount unclear হতে পারে — এগোতে প্রতিটি লাইন যাচাই করুন।',
      filipino:
          'Some amounts may be unclear — please double-check every line before continuing.',
    ),
    'receipt_merchant': l10nEntry(
      english: 'Merchant',
      arabic: 'التاجر',
      hindi: 'दुकान/रेस्तरां',
      urdu: 'دکان',
      bengali: 'দোকান',
      filipino: 'Merchant',
    ),
    'receipt_bill_currency': l10nEntry(
      english: 'Bill currency',
      arabic: 'عملة الفاتورة',
      hindi: 'बिल मुद्रा',
      urdu: 'بل کی کرنسی',
      bengali: 'বিলের মুদ্রা',
      filipino: 'Bill currency',
    ),
    'receipt_line_items': l10nEntry(
      english: 'Line items',
      arabic: 'البنود',
      hindi: 'पंक्ति आइटम',
      urdu: 'لائن آئٹمز',
      bengali: 'লাইন আইটেম',
      filipino: 'Line items',
    ),
    'receipt_add_item': l10nEntry(
      english: 'Add line item',
      arabic: 'إضافة بند',
      hindi: 'आइटम जोड़ें',
      urdu: 'آئٹم شامل',
      bengali: 'আইটেম যোগ',
      filipino: 'Add line item',
    ),
    'receipt_item_name_hint': l10nEntry(
      english: 'Item name',
      arabic: 'اسم البند',
      hindi: 'आइटम का नाम',
      urdu: 'آئٹم کا نام',
      bengali: 'আইটেমের নাম',
      filipino: 'Item name',
    ),
    'receipt_item_price': l10nEntry(
      english: 'Price',
      arabic: 'السعر',
      hindi: 'कीमत',
      urdu: 'قیمت',
      bengali: 'দাম',
      filipino: 'Price',
    ),
    'receipt_item_qty': l10nEntry(
      english: 'Qty',
      arabic: 'الكمية',
      hindi: 'मात्रा',
      urdu: 'مقدار',
      bengali: 'পরিমাণ',
      filipino: 'Qty',
    ),
    'receipt_subtotal': l10nEntry(
      english: 'Subtotal',
      arabic: 'المجموع الفرعي',
      hindi: 'उप-योग',
      urdu: 'ذیلی کل',
      bengali: 'উপমোট',
      filipino: 'Subtotal',
    ),
    'receipt_tax': l10nEntry(
      english: 'Tax',
      arabic: 'الضريبة',
      hindi: 'कर',
      urdu: 'ٹیکس',
      bengali: 'ট্যাক্স',
      filipino: 'Tax',
    ),
    'receipt_service_charge': l10nEntry(
      english: 'Service charge',
      arabic: 'رسوم الخدمة',
      hindi: 'सेवा शुल्क',
      urdu: 'سروس چارج',
      bengali: 'সার্ভিস চার্জ',
      filipino: 'Service charge',
    ),
    'receipt_tip': l10nEntry(
      english: 'Tip',
      arabic: 'البقشيش',
      hindi: 'टिप',
      urdu: 'ٹِپ',
      bengali: 'টিপ',
      filipino: 'Tip',
    ),
    'receipt_continue': l10nEntry(
      english: 'Continue to assignment',
      arabic: 'متابعة للتخصيص',
      hindi: 'असाइनमेंट पर जाएँ',
      urdu: 'تفویض پر جائیں',
      bengali: 'অ্যাসাইনমেন্টে যান',
      filipino: 'Continue to assignment',
    ),
    'receipt_need_items': l10nEntry(
      english: 'Add at least one line item.',
      arabic: 'أضف بنداً واحداً على الأقل.',
      hindi: 'कम से कम एक आइटम जोड़ें।',
      urdu: 'کم از کم ایک آئٹم شامل کریں۔',
      bengali: 'কমপক্ষে একটি আইটেম যোগ করুন।',
      filipino: 'Add at least one line item.',
    ),
    'receipt_currency_confirm_title': l10nEntry(
      english: 'Confirm bill currency',
      arabic: 'تأكيد عملة الفاتورة',
      hindi: 'बिल मुद्रा की पुष्टि',
      urdu: 'بل کرنسی کی تصدیق',
      bengali: 'বিল মুদ্রা নিশ্চিত',
      filipino: 'Confirm bill currency',
    ),
    'receipt_currency_confirm_body': l10nEntry(
      english:
          'Detected {detected} on the receipt but you selected {selected}. Continue with {selected}?',
      arabic:
          'Detected {detected} on the receipt but you selected {selected}. Continue with {selected}?',
      hindi:
          'Detected {detected} on the receipt but you selected {selected}. Continue with {selected}?',
      urdu:
          'Detected {detected} on the receipt but you selected {selected}. Continue with {selected}?',
      malayalam:
          'Detected {detected} on the receipt but you selected {selected}. Continue with {selected}?',
      nepali:
          'Detected {detected} on the receipt but you selected {selected}. Continue with {selected}?',
      tamil:
          'Detected {detected} on the receipt but you selected {selected}. Continue with {selected}?',
      bengali:
          'Detected {detected} on the receipt but you selected {selected}. Continue with {selected}?',
      filipino:
          'Detected {detected} on the receipt but you selected {selected}. Continue with {selected}?',
    ),
    'receipt_currency_keep': l10nEntry(
      english: 'Continue',
      arabic: 'متابعة',
      hindi: 'जारी रखें',
      urdu: 'جاری رکھیں',
      bengali: 'চালিয়ে যান',
      filipino: 'Continue',
    ),
    'receipt_currency_change': l10nEntry(
      english: 'Go back',
      arabic: 'رجوع',
      hindi: 'वापस',
      urdu: 'واپس',
      bengali: 'ফিরে যান',
      filipino: 'Go back',
    ),
    'receipt_assign_title': l10nEntry(
      english: 'Assign items',
      arabic: 'تخصيص البنود',
      hindi: 'आइटम असाइन करें',
      urdu: 'آئٹمز تفویض',
      bengali: 'আইটেম বরাদ্দ',
      filipino: 'Assign items',
    ),
    'receipt_assign_instructions': l10nEntry(
      english:
          'Tap each person who shares an item. Shared items split equally among selected people.',
      arabic:
          'Tap each person who shares an item. Shared items split equally among selected people.',
      hindi:
          'Tap each person who shares an item. Shared items split equally among selected people.',
      urdu:
          'Tap each person who shares an item. Shared items split equally among selected people.',
      malayalam:
          'Tap each person who shares an item. Shared items split equally among selected people.',
      nepali:
          'Tap each person who shares an item. Shared items split equally among selected people.',
      tamil:
          'Tap each person who shares an item. Shared items split equally among selected people.',
      bengali:
          'Tap each person who shares an item. Shared items split equally among selected people.',
      filipino:
          'Tap each person who shares an item. Shared items split equally among selected people.',
    ),
    'receipt_prorate_charges': l10nEntry(
      english: 'Prorate tax & charges by item share',
      arabic: 'Prorate tax & charges by item share',
      hindi: 'Prorate tax & charges by item share',
      urdu: 'Prorate tax & charges by item share',
      malayalam: 'Prorate tax & charges by item share',
      nepali: 'Prorate tax & charges by item share',
      tamil: 'Prorate tax & charges by item share',
      bengali: 'Prorate tax & charges by item share',
      filipino: 'Prorate tax & charges by item share',
    ),
    'receipt_equal_charges': l10nEntry(
      english: 'Split tax & charges equally',
      arabic: 'Split tax & charges equally',
      hindi: 'Split tax & charges equally',
      urdu: 'Split tax & charges equally',
      malayalam: 'Split tax & charges equally',
      nepali: 'Split tax & charges equally',
      tamil: 'Split tax & charges equally',
      bengali: 'Split tax & charges equally',
      filipino: 'Split tax & charges equally',
    ),
    'receipt_charge_mode_hint': l10nEntry(
      english: 'Default: charges follow each person\'s food share.',
      arabic: 'Default: charges follow each person\'s food share.',
      hindi: 'Default: charges follow each person\'s food share.',
      urdu: 'Default: charges follow each person\'s food share.',
      malayalam: 'Default: charges follow each person\'s food share.',
      nepali: 'Default: charges follow each person\'s food share.',
      tamil: 'Default: charges follow each person\'s food share.',
      bengali: 'Default: charges follow each person\'s food share.',
      filipino: 'Default: charges follow each person\'s food share.',
    ),
    'receipt_settlement_title': l10nEntry(
      english: 'Each person pays',
      arabic: 'كل شخص يدفع',
      hindi: 'प्रत्येक व्यक्ति देता है',
      urdu: 'ہر شخص ادا کرے',
      bengali: 'প্রত্যেকে দেয়',
      filipino: 'Each person pays',
    ),
    'settlement_payments_count': l10nEntry(
      english: 'Settle up in {count} payments',
      arabic: 'تسوية في {count} دفعات',
      hindi: '{count} भुगतान में settle',
      urdu: '{count} ادائیگیوں میں settle',
      bengali: '{count} পেমেন্টে settle',
      filipino: 'Settle up in {count} payments',
    ),
    'settlement_payer_hint': l10nEntry(
      english: 'Tap who paid the bill — we\'ll minimize transfers.',
      arabic: 'Tap who paid the bill — we\'ll minimize transfers.',
      hindi: 'Tap who paid the bill — we\'ll minimize transfers.',
      urdu: 'Tap who paid the bill — we\'ll minimize transfers.',
      malayalam: 'Tap who paid the bill — we\'ll minimize transfers.',
      nepali: 'Tap who paid the bill — we\'ll minimize transfers.',
      tamil: 'Tap who paid the bill — we\'ll minimize transfers.',
      bengali: 'Tap who paid the bill — we\'ll minimize transfers.',
      filipino: 'Tap who paid the bill — we\'ll minimize transfers.',
    ),
    'settlement_payer_badge': l10nEntry(
      english: 'Paid',
      arabic: 'دفع',
      hindi: 'भुगतान किया',
      urdu: 'ادا کیا',
      bengali: 'পরিশোধ',
      filipino: 'Paid',
    ),
    'settlement_payment_line': l10nEntry(
      english: '{from} pays {to} {amount}',
      arabic: '{from} يدفع {to} {amount}',
      hindi: '{from} {to} को {amount} देता है',
      urdu: '{from} {to} کو {amount} دیتا ہے',
      bengali: '{from} {to}-কে {amount} দেয়',
      filipino: '{from} pays {to} {amount}',
    ),
    'settlement_share_heading': l10nEntry(
      english: 'Minimum payments:',
      arabic: 'الحد الأدنى للدفعات:',
      hindi: 'न्यूनतम भुगतान:',
      urdu: 'کم از کم ادائیگیاں:',
      bengali: 'সর্বনিম্ন পেমেন্ট:',
      filipino: 'Minimum payments:',
    ),
  };
}
