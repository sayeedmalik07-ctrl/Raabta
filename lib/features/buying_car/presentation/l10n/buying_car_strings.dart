import 'package:flutter/foundation.dart';
import 'package:raabta/core/l10n/app_locale.dart';
import 'package:raabta/core/l10n/locale_catalog_coverage.dart';
import 'package:raabta/core/l10n/locale_catalog_entry.dart';

abstract final class BuyingCarStrings {
  static const supportedLocales = AppLocale.supportedLocales;

  static String t(String key, [String locale = 'English']) {
    final normalized = AppLocale.normalize(locale);
    final map = _catalog[key];
    if (map == null) return key;
    return map[normalized] ?? map['English'] ?? key;
  }

  @visibleForTesting
  static Map<String, Set<String>> get localeCoverageReport =>
      buildLocaleCoverageReport(
        catalog: _catalog,
        supportedLocales: supportedLocales,
      );

  static final _catalog = <String, Map<String, String>>{
    'bc_screen_title': l10nEntry(
      english: 'Buying a Car in Qatar',
      arabic: 'شراء سيارة في قطر',
      hindi: 'Qatar mein car khareedna',
      urdu: 'Qatar mein car khareedna',
    ),
    'bc_screen_intro': l10nEntry(
      english:
          'Plain-language guide for private and dealer purchases — informational only. Raabta does not verify any dealer, vehicle, or price.',
      arabic:
          'دليل مبسّط للشراء الخاص والوكيل — للمعلومات فقط. Raabta لا تتحقق من أي dealer أو مركبة أو سعر.',
      hindi:
          'Private/dealer purchase guide — informational only. Raabta kisi dealer/vehicle/price ko verify nahi karti.',
      urdu:
          'Private/dealer purchase guide — informational only. Raabta kisi dealer/vehicle/price ko verify nahi karti.',
    ),
    'bc_lead_badge': l10nEntry(
      english: 'Read this first',
      arabic: 'اقرأ هذا أولاً',
      hindi: 'Pehle ye padhein',
      urdu: 'Pehle ye parhein',
    ),
    'bc_as_is_title': l10nEntry(
      english: 'Private sales are "as-is" — no legal recourse after purchase',
      arabic: 'البيع الخاص "كما هو" — لا recourse قانوني بعد الشراء',
      hindi: 'Private sales "as-is" hain — purchase ke baad legal recourse nahi',
      urdu: 'Private sales "as-is" hain — purchase ke baad legal recourse nahi',
    ),
    'bc_as_is_body': l10nEntry(
      english:
          'Private used-car sales in Qatar are typically sold "as-is". If something turns out to be wrong after you buy, you generally have no legal remedy against the seller. This is the single most important thing to understand before buying privately.',
      arabic:
          'بيع السيارات المستعملة بين الأفراد عادة "كما هو". إن ظهر عيب بعد الشراء، غالباً لا recourse قانوني ضد البائع — أهم fact قبل الشراء الخاص.',
      hindi:
          'Private used-car sales "as-is" hoti hain — kharidne ke baad kuch galat nikle to aksar seller ke khilaf legal remedy nahi. Private khareedne se pehle sabse important baat.',
      urdu:
          'Private used-car sales "as-is" hoti hain — kharidne ke baad kuch galat nikle to aksar seller ke khilaf legal remedy nahi. Private khareedne se pehle sabse important baat.',
    ),
    'bc_inspection_body': l10nEntry(
      english:
          'Your real protection before a private purchase is a professional pre-purchase inspection (mechanic-conducted) — not any legal fix after the fact.',
      arabic:
          'حمايتك الحقيقية قبل الشراء الخاص: فحص pre-purchase احترافي (ميكانيكي) — وليس remedy قانوني بعد الشراء.',
      hindi:
          'Private purchase se pehle asli protection: professional pre-purchase inspection (mechanic) — baad mein legal fix nahi.',
      urdu:
          'Private purchase se pehle asli protection: professional pre-purchase inspection (mechanic) — baad mein legal fix nahi.',
    ),
    'bc_dealer_title': l10nEntry(
      english: 'Dealer purchases — different risk profile',
      arabic: 'شراء من الوكيل — risk profile مختلف',
      hindi: 'Dealer purchases — alag risk profile',
      urdu: 'Dealer purchases — alag risk profile',
    ),
    'bc_dealer_body': l10nEntry(
      english:
          'Dealer sales typically come with warranty protection, and MOCI (Law No. 8 of 2008) has real enforcement power to back consumer rights. A published MOCI enforcement case on moci.gov.qa records MOCI compelling a car dealer to replace a defective vehicle with a new one after a consumer complaint — we cite only what that published case confirms, without adding detail. Vendor-issued warranties must be legally valid; MOCI\'s Consumer Protection Department verifies this as part of its role.',
      arabic:
          'مبيعات الوكيل عادة مع warranty، وMOCI (قانون 8/2008) لديه enforcement حقيقي. case منشور على moci.gov.qa: MOCI ألزم dealer باستبدال سيارة معيبة بجديدة بعد شكوى — vendor warranties يجب أن تكون legally valid.',
      hindi:
          'Dealer sales mein warranty hoti hai; MOCI (Law 8/2008) enforcement power rakhta hai. Published moci.gov.qa case: dealer ko defective car replace karne par majboor. Vendor warranties legally valid honi chahiye.',
      urdu:
          'Dealer sales mein warranty hoti hai; MOCI (Law 8/2008) enforcement power rakhta hai. Published moci.gov.qa case: dealer ko defective car replace karne par majboor. Vendor warranties legally valid honi chahiye.',
    ),
    'bc_before_title': l10nEntry(
      english: 'Before you buy — practical steps',
      arabic: 'قبل الشراء — خطوات عملية',
      hindi: 'Kharidne se pehle — practical steps',
      urdu: 'Kharidne se pehle — practical steps',
    ),
    'bc_before_metrash': l10nEntry(
      english:
          'Check vehicle history through the Metrash app before committing to a purchase.',
      arabic: 'تحقق من تاريخ المركبة عبر تطبيق Metrash قبل الشراء.',
      hindi: 'Purchase se pehle Metrash app se vehicle history check karein.',
      urdu: 'Purchase se pehle Metrash app se vehicle history check karein.',
    ),
    'bc_before_fines': l10nEntry(
      english:
          'Confirm any outstanding traffic fines on the vehicle — these are typically cleared by the seller before transfer or deducted from the agreed price.',
      arabic: 'أكّد أي مخالفات مرور outstanding — عادة يدفعها البائع قبل النقل أو تُخصم من السعر.',
      hindi: 'Vehicle par outstanding traffic fines confirm karein — aksar seller transfer se pehle clear karta hai ya price se deduct.',
      urdu: 'Vehicle par outstanding traffic fines confirm karein — aksar seller transfer se pehle clear karta hai ya price se deduct.',
    ),
    'bc_fines_link_label': l10nEntry(
      english: 'See Leaving Qatar traffic fines checklist',
      arabic: 'انظر checklist مخالفات المرور في Leaving Qatar',
      hindi: 'Leaving Qatar traffic fines checklist dekhein',
      urdu: 'Leaving Qatar traffic fines checklist dekhein',
    ),
    'bc_transfer_title': l10nEntry(
      english: 'Ownership transfer at Traffic Department (Muroor)',
      arabic: 'نقل الملكية في إدارة المرور (Muroor)',
      hindi: 'Traffic Department (Muroor) par ownership transfer',
      urdu: 'Traffic Department (Muroor) par ownership transfer',
    ),
    'bc_transfer_together': l10nEntry(
      english: 'Both buyer and seller must visit the Traffic Department together.',
      arabic: 'يجب على المشتري والبائع زيارة إدارة المرور معاً.',
      hindi: 'Buyer aur seller dono Traffic Department saath jayein.',
      urdu: 'Buyer aur seller dono Traffic Department saath jayein.',
    ),
    'bc_transfer_required': l10nEntry(
      english:
          'Required: both parties\' QIDs, the original Istimara (vehicle registration), valid insurance for the new owner, and a vehicle inspection certificate.',
      arabic:
          'المطلوب: QID الطرفين، Istimara الأصلي، تأمين صالح للمالك الجديد، شهادة فحص المركبة.',
      hindi:
          'Required: dono parties ke QID, original Istimara, new owner ka valid insurance, vehicle inspection certificate.',
      urdu:
          'Required: dono parties ke QID, original Istimara, new owner ka valid insurance, vehicle inspection certificate.',
    ),
    'bc_transfer_fee': l10nEntry(
      english:
          'Transfer fee is approximately QAR 50. The process is usually completed in one visit.',
      arabic: 'رسوم النقل تقريباً 50 ر.ق. عادة تُنجز في زيارة واحدة.',
      hindi: 'Transfer fee lagbhag QAR 50. Aksar ek visit mein complete.',
      urdu: 'Transfer fee lagbhag QAR 50. Aksar ek visit mein complete.',
    ),
    'bc_complaint_section_title': l10nEntry(
      english: 'General consumer complaints (not car-specific)',
      arabic: 'شكاوى استهلاكية عامة (ليست خاصة بالسيارات)',
      hindi: 'General consumer complaints (car-specific nahi)',
      urdu: 'General consumer complaints (car-specific nahi)',
    ),
    'bc_complaint_section_note': l10nEntry(
      english:
          'The reference below applies to any significant purchase dispute under MOCI — not only cars. It is a separate, reusable guide you can return to from other Raabta features.',
      arabic:
          'المرجع أدناه لأي نزاع purchase تحت MOCI — ليس للسيارات فقط. دليل منفصل قابل لإعادة الاستخدام.',
      hindi:
          'Neeche ka reference kisi bhi MOCI purchase dispute ke liye — sirf cars nahi. Alag reusable guide.',
      urdu:
          'Neeche ka reference kisi bhi MOCI purchase dispute ke liye — sirf cars nahi. Alag reusable guide.',
    ),
    'bc_open_complaint_full': l10nEntry(
      english: 'Open full consumer complaint guide',
      arabic: 'فتح دليل الشكوى الاستهلاكية الكامل',
      hindi: 'Full consumer complaint guide kholen',
      urdu: 'Full consumer complaint guide kholen',
    ),
  };
}
