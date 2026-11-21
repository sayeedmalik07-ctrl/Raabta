import 'package:flutter/foundation.dart';
import 'package:raabta/core/l10n/app_locale.dart';
import 'package:raabta/core/l10n/locale_catalog_coverage.dart';
import 'package:raabta/core/l10n/locale_catalog_entry.dart';

abstract final class FreelanceVisaStrings {
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
    'fv_screen_title': l10nEntry(
      english: 'Freelance Visa in Qatar?',
      arabic: 'تأشيرة العمل الحر في قطر؟',
      hindi: 'Qatar mein Freelance Visa?',
      urdu: 'Qatar mein Freelance Visa?',
    ),
    'fv_screen_subtitle': l10nEntry(
      english: 'Signpost only — verify on official channels',
      arabic: 'إرشاد فقط — تحقق عبر القنوات الرسمية',
      hindi: 'Sirf signpost — official channels par verify karein',
      urdu: 'Sirf signpost — official channels par verify karein',
    ),
    'fv_lead_badge': l10nEntry(
      english: 'Know first',
      arabic: 'اعرف أولاً',
      hindi: 'Pehle jaanein',
      urdu: 'Pehle jaanein',
    ),
    'fv_lead_title': l10nEntry(
      english:
          'There is no Qatar visa officially named a "freelance visa."',
      arabic: 'لا توجد في قطر تأشيرة رسمية باسم "تأشيرة العمل الحر".',
      hindi:
          'Qatar mein koi aisi official visa nahi hai jiska naam "freelance visa" ho.',
      urdu:
          'Qatar mein koi aisi official visa nahi hai jiska naam "freelance visa" ho.',
    ),
    'fv_lead_body': l10nEntry(
      english:
          'Independent work is legal in Qatar, but only through specific recognized pathways — not through a single simple application that some websites describe online.',
      arabic:
          'العمل المستقل قانوني في قطر، لكن فقط عبر مسارات معترف بها — وليس عبر طلب واحد بسيط كما تصف بعض المواقع.',
      hindi:
          'Independent work Qatar mein legal hai, lekin sirf specific recognized pathways se — na ki koi ek simple online application jaisa kuch websites batati hain.',
      urdu:
          'Independent work Qatar mein legal hai, lekin sirf specific recognized pathways se — na ki koi ek simple online application jaisa kuch websites batati hain.',
    ),
    'fv_misinfo_title': l10nEntry(
      english: 'What you may see online',
      arabic: 'ما قد تراه على الإنترنت',
      hindi: 'Online jo aap dekh sakte hain',
      urdu: 'Online jo aap dekh sakte hain',
    ),
    'fv_misinfo_body': l10nEntry(
      english:
          'Many websites describe a "Qatar Freelance Visa" with specific steps and fees. This content is often inaccurate or describes something that does not exist in that form.',
      arabic:
          'مواقع كثيرة تصف "تأشيرة العمل الحر في قطر" بخطوات ورسوم محددة. هذا المحتوى غالباً غير دقيق أو يصف شيئاً غير موجود بهذا الشكل.',
      hindi:
          'Bahut si websites "Qatar Freelance Visa" ko specific steps aur fees ke saath describe karti hain. Ye content aksar inaccurate hota hai ya aisi cheez batata hai jo us form mein exist nahi karti.',
      urdu:
          'Bahut si websites "Qatar Freelance Visa" ko specific steps aur fees ke saath describe karti hain. Ye content aksar inaccurate hota hai ya aisi cheez batata hai jo us form mein exist nahi karti.',
    ),
    'fv_pathways_title': l10nEntry(
      english: 'Recognized official pathways',
      arabic: 'المسارات الرسمية المعترف بها',
      hindi: 'Recognized official pathways',
      urdu: 'Recognized official pathways',
    ),
    'fv_pathways_body': l10nEntry(
      english:
          'Real routes for independent professionals to work legally in Qatar exist through recognized government-affiliated channels — including company registration via the Ministry of Commerce and Industry (MOCI), the Qatar Financial Centre (QFC), or a Free Zone authority, and government-run residency and self-sponsorship programs. Program availability and eligibility change — check what is currently open directly with the administering body rather than relying on third-party guides.',
      arabic:
          'مسارات حقيقية للعمل المستقل قانونياً في قطر عبر قنوات حكومية معترف بها — تسجيل شركة عبر MOCI أو QFC أو منطقة حرة، وبرامج إقامة وتكفيل ذاتي حكومية. توفر البرامج والأهلية تتغير — تحقق مباشرة مع الجهة المختصة.',
      hindi:
          'Independent professionals ke liye legal work ke real routes recognized government channels se hain — MOCI, QFC, ya Free Zone se company registration, aur government-run residency/self-sponsorship programs. Program availability aur eligibility badalti rehti hai — third-party guides par bharosa na karke administering body se seedha current status check karein.',
      urdu:
          'Independent professionals ke liye legal work ke real routes recognized government channels se hain — MOCI, QFC, ya Free Zone se company registration, aur government-run residency/self-sponsorship programs. Program availability aur eligibility badalti rehti hai — third-party guides par bharosa na karke administering body se seedha current status check karein.',
    ),
    'fv_jusour_title': l10nEntry(
      english: 'Jusour (Qatar Manpower Solutions Company)',
      arabic: 'جسور (شركة قطر لحلول القوى العاملة)',
      hindi: 'Jusour (Qatar Manpower Solutions Company)',
      urdu: 'Jusour (Qatar Manpower Solutions Company)',
    ),
    'fv_jusour_body': l10nEntry(
      english:
          'Jusour is a government-owned body that administers manpower and residency programs. For current program availability, eligibility, and requirements, contact Jusour directly through their official channels — do not rely on unofficial websites or intermediaries.',
      arabic:
          'جسور جهة حكومية تدير برامج القوى العاملة والإقامة. للتوفر والأهلية والمتطلبات الحالية، تواصل مع جسور مباشرة عبر قنواتها الرسمية — لا تعتمد على مواقع أو وسطاء غير رسميين.',
      hindi:
          'Jusour ek government-owned body hai jo manpower aur residency programs chalati hai. Current availability, eligibility, aur requirements ke liye Jusour se official channels par seedha contact karein — unofficial websites ya intermediaries par bharosa na karein.',
      urdu:
          'Jusour ek government-owned body hai jo manpower aur residency programs chalati hai. Current availability, eligibility, aur requirements ke liye Jusour se official channels par seedha contact karein — unofficial websites ya intermediaries par bharosa na karein.',
    ),
    'fv_jusour_contact': l10nEntry(
      english: 'Email: info@jusour.qa · Phone: +974 44011044',
      arabic: 'البريد: info@jusour.qa · الهاتف: +974 44011044',
      hindi: 'Email: info@jusour.qa · Phone: +974 44011044',
      urdu: 'Email: info@jusour.qa · Phone: +974 44011044',
    ),
    'fv_open_official_site': l10nEntry(
      english: 'Open official website',
      arabic: 'افتح الموقع الرسمي',
      hindi: 'Official website kholen',
      urdu: 'Official website kholen',
    ),
    'fv_risk_title': l10nEntry(
      english: 'Informal arrangements carry real risk',
      arabic: 'الترتيبات غير الرسمية تحمل مخاطر حقيقية',
      hindi: 'Informal arrangements mein real risk hai',
      urdu: 'Informal arrangements mein real risk hai',
    ),
    'fv_risk_body': l10nEntry(
      english:
          'Some people work in Qatar through informal arrangements — for example, paying an individual or company for residency sponsorship without a genuine employment relationship. This is not the same as the official pathways above. It is not a recognized legal status, and people using such arrangements have faced fines, detention during routine checks, and visa cancellation.',
      arabic:
          'بعض الناس يعملون في قطر عبر ترتيبات غير رسمية — مثل دفع شخص أو شركة للكفالة دون علاقة عمل حقيقية. هذا ليس كالمسارات الرسمية أعلاه. ليس وضعاً قانونياً معترفاً به، ومن استخدموا هذه الترتيبات واجهوا غرامات واحتجازاً أثناء التفتيش الروتيني وإلغاء التأشيرة.',
      hindi:
          'Kuch log Qatar mein informal arrangements se kaam karte hain — jaise kisi individual ya company ko residency sponsorship ke liye pay karna bina genuine employment relationship ke. Ye upar wale official pathways jaisa nahi hai. Ye recognized legal status nahi hai, aur aise arrangements use karne walon ko fines, routine checks ke dauran detention, aur visa cancellation ka samna karna pada hai.',
      urdu:
          'Kuch log Qatar mein informal arrangements se kaam karte hain — jaise kisi individual ya company ko residency sponsorship ke liye pay karna bina genuine employment relationship ke. Ye upar wale official pathways jaisa nahi hai. Ye recognized legal status nahi hai, aur aise arrangements use karne walon ko fines, routine checks ke dauran detention, aur visa cancellation ka samna karna pada hai.',
    ),
    'fv_close_body': l10nEntry(
      english:
          'Before paying anyone or committing to any independent-work arrangement in Qatar, verify the pathway directly with the official administering body or a licensed legal or business-setup consultant — not with a website or informal intermediary claiming to offer a shortcut.',
      arabic:
          'قبل الدفع لأي شخص أو الالتزام بأي ترتيب عمل مستقل في قطر، تحقق من المسار مباشرة مع الجهة الرسمية أو مستشار قانوني/تأسيس مرخّص — وليس مع موقع أو وسيط غير رسمي يدّعي اختصاراً.',
      hindi:
          'Qatar mein kisi ko pay karne ya kisi independent-work arrangement par commit karne se pehle, pathway ko official administering body ya licensed legal/business-setup consultant se seedha verify karein — na ki kisi website ya informal intermediary se jo shortcut ka daawa kare.',
      urdu:
          'Qatar mein kisi ko pay karne ya kisi independent-work arrangement par commit karne se pehle, pathway ko official administering body ya licensed legal/business-setup consultant se seedha verify karein — na ki kisi website ya informal intermediary se jo shortcut ka daawa kare.',
    ),
    'fv_disclaimer': l10nEntry(
      english:
          'Raabta does not verify visa status, program eligibility, or any individual\'s right to work in Qatar. Confirm pathways, availability, and requirements directly with official government channels or a licensed consultant. Informational only — not legal advice.',
      arabic:
          'رابطة لا تتحقق من وضع التأشيرة أو أهلية البرامج أو حق أي شخص في العمل. أكّد المسارات والتوفر والمتطلبات مباشرة مع القنوات الحكومية أو مستشار مرخّص. للمعلومات فقط — ليست مشورة قانونية.',
      hindi:
          'Raabta visa status, program eligibility, ya kisi ka work right verify nahi karta. Pathways, availability, aur requirements official government channels ya licensed consultant se seedha confirm karein. Informational only — not legal advice.',
      urdu:
          'Raabta visa status, program eligibility, ya kisi ka work right verify nahi karta. Pathways, availability, aur requirements official government channels ya licensed consultant se seedha confirm karein. Informational only — not legal advice.',
    ),
  };
}
