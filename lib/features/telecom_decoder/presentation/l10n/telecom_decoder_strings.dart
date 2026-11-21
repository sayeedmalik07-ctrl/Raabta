import 'package:flutter/foundation.dart';
import 'package:raabta/core/l10n/app_locale.dart';
import 'package:raabta/core/l10n/locale_catalog_coverage.dart';
import 'package:raabta/core/l10n/locale_catalog_entry.dart';

abstract final class TelecomDecoderStrings {
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
    'td_screen_title': l10nEntry(
      english: 'Know Before You Sign or Cancel',
      arabic: 'اعرف قبل التوقيع أو الإلغاء',
      hindi: 'Sign या Cancel करने से पहले जानें',
      urdu: 'Sign یا Cancel کرنے سے پہلے جانیں',
    ),
    'td_screen_intro': l10nEntry(
      english:
          'Plain-language decoder for Ooredoo and Vodafone contract traps — minimum periods, early termination, and when you can escalate to CRA. Informational only; confirm your specific plan and balance directly with your provider.',
      arabic:
          'دليل مبسّط لعقود Ooredoo و Vodafone — فترات الحد الأدنى، الإنهاء المبكر، والتصعيد إلى CRA. للمعلومات فقط؛ أكّد خطتك ورصيدك مع مزودك.',
      hindi:
          'Ooredoo/Vodafone contract traps का plain-language decoder — minimum periods, early termination, CRA escalation। Informational only; अपनी plan provider से confirm करें।',
      urdu:
          'Ooredoo/Vodafone contract traps کا plain-language decoder — minimum periods, early termination, CRA escalation۔ Informational only; اپنی plan provider سے confirm کریں۔',
    ),
    'td_disclaimer': l10nEntry(
      english:
          'Raabta does not access your live account or tariff. Figures below come from published provider terms — your exact fees depend on your plan.',
      arabic:
          'Raabta لا تصل إلى حسابك المباشر. الأرقام من شروط المزود المنشورة — رسومك الفعلية تعتمد على خطتك.',
      hindi:
          'Raabta आपके live account/tariff तक नहीं पहुँचती। Figures published terms से — exact fees plan पर depend।',
      urdu:
          'Raabta آپ کے live account/tariff تک نہیں پہنچتی۔ Figures published terms سے — exact fees plan پر depend۔',
    ),
    'td_scope_note': l10nEntry(
      english:
          'Scope: this guide focuses on Fibre/broadband, bundled equipment, and GigaTV device terms where confirmed in research. Mobile-only SIM early-termination fees were not confirmed — do not assume the Vodafone QAR 798 example applies to a standalone mobile plan.',
      arabic:
          'النطاق: يركز هذا الدليل على Fibre/الإنترنت والمعدات المجمّعة وGigaTV. رسوم إنهاء SIM mobile-only لم تُؤكَّد — لا تفترض أن مثال 798 ر.ق ينطبق على خط mobile منفصل.',
      hindi:
          'Scope: Fibre/broadband, bundled equipment, GigaTV — mobile-only SIM early-termination fees confirmed नहीं; Vodafone QAR 798 example standalone mobile plan पर assume न करें।',
      urdu:
          'Scope: Fibre/broadband, bundled equipment, GigaTV — mobile-only SIM early-termination fees confirmed نہیں؛ Vodafone QAR 798 example standalone mobile plan پر assume نہ کریں۔',
    ),
    'td_traps_heading': l10nEntry(
      english: 'Things that catch people off guard',
      arabic: 'أمور تفاجئ الناس',
      hindi: 'Chizain jo log miss kar dete hain',
      urdu: 'Cheezen jo log miss kar dete hain',
    ),
    'td_trap_badge': l10nEntry(
      english: 'Easy to miss',
      arabic: 'سهل تفويته',
      hindi: 'Easy to miss',
      urdu: 'Easy to miss',
    ),
    'td_trap_ooredoo_provider': l10nEntry(
      english: 'Ooredoo',
      arabic: 'Ooredoo',
      hindi: 'Ooredoo',
      urdu: 'Ooredoo',
    ),
    'td_trap_ooredoo_title': l10nEntry(
      english: 'Price-rise cancellation rights have carve-outs',
      arabic: 'حق الإلغاء عند رفع السعر له استثناءات',
      hindi: 'Price-rise cancellation rights ke carve-outs hain',
      urdu: 'Price-rise cancellation rights ke carve-outs hain',
    ),
    'td_trap_ooredoo_body': l10nEntry(
      english:
          'A price increase normally gives you 15 days to cancel penalty-free — but increases from international roaming rates, government-imposed fees/taxes, or regulatory-framework changes do NOT count as "materially adverse" and do NOT trigger that cancellation right.',
      arabic:
          'رفع السعر عادة يمنحك 15 يوماً للإلغاء دون غرامة — لكن زيادات roaming الدولي أو الرسوم/الضرائب الحكومية أو تغييرات الإطار التنظيمي لا تُعد "ضارة مادياً" ولا تمنح حق الإلغاء.',
      hindi:
          'Price increase par normally 15 days penalty-free cancel — except roaming rate hikes, govt fees/taxes, regulatory changes — ye "materially adverse" nahi, cancellation right trigger nahi karte।',
      urdu:
          'Price increase par normally 15 days penalty-free cancel — except roaming rate hikes, govt fees/taxes, regulatory changes — ye "materially adverse" nahi, cancellation right trigger nahi karte۔',
    ),
    'td_trap_vodafone_provider': l10nEntry(
      english: 'Vodafone',
      arabic: 'Vodafone',
      hindi: 'Vodafone',
      urdu: 'Vodafone',
    ),
    'td_trap_vodafone_title': l10nEntry(
      english: 'Promotional offers stay at the old address',
      arabic: 'العروض الترويجية تبقى على العنوان القديم',
      hindi: 'Promotional offers purane address par rehte hain',
      urdu: 'Promotional offers purane address par rehte hain',
    ),
    'td_trap_vodafone_body': l10nEntry(
      english:
          'One-time promotional offers (e.g. "free months") are tied to a specific Kahramaa ID. Moving apartments, or reconnecting even under the same QID at a new address, does not carry the promotion over.',
      arabic:
          'العروض لمرة واحدة (مثل "أشهر مجانية") مرتبطة بـ Kahramaa ID محدد. الانتقال لشقة جديدة أو إعادة التوصيل بنفس QID في عنوان جديد لا ينقل العرض.',
      hindi:
          'One-time promos (jaise "free months") specific Kahramaa ID se tied hain — naye address par move/reconnect par promo carry over nahi hota, same QID ho to bhi।',
      urdu:
          'One-time promos (jaise "free months") specific Kahramaa ID se tied hain — naye address par move/reconnect par promo carry over nahi hota, same QID ho to bhi۔',
    ),
    'td_section_min_period_title': l10nEntry(
      english: 'Minimum service periods & early termination',
      arabic: 'فترات الحد الأدنى والإنهاء المبكر',
      hindi: 'Minimum service periods & early termination',
      urdu: 'Minimum service periods & early termination',
    ),
    'td_ooredoo_min_title': l10nEntry(
      english: 'Ooredoo — default 3-month minimum',
      arabic: 'Ooredoo — حد أدنى افتراضي 3 أشهر',
      hindi: 'Ooredoo — default 3-month minimum',
      urdu: 'Ooredoo — default 3-month minimum',
    ),
    'td_ooredoo_min_body': l10nEntry(
      english:
          'Default minimum service period is 3 months (varies by tariff). Early cancellation means owing charges for the remainder of that period. The exact amount depends on your specific plan — confirm the remaining balance with Ooredoo directly before cancelling.',
      arabic:
          'فترة الحد الأدنى الافتراضية 3 أشهر (تختلف حسب التعرفة). الإلغاء المبكر يعني دفع رسوم باقي الفترة. المبلغ الدقيق يعتمد على خطتك — أكّد الرصيد المتبقي مع Ooredoo قبل الإلغاء.',
      hindi:
          'Default minimum 3 months (tariff par vary)। Early cancel = bache period ke charges। Exact amount plan-specific — cancel se pehle Ooredoo se remaining balance confirm karein।',
      urdu:
          'Default minimum 3 months (tariff par vary)۔ Early cancel = bache period ke charges۔ Exact amount plan-specific — cancel se pehle Ooredoo se remaining balance confirm karein۔',
    ),
    'td_vodafone_min_title': l10nEntry(
      english: 'Vodafone Fibre — example early-termination fee',
      arabic: 'Vodafone Fibre — مثال رسوم إنهاء مبكر',
      hindi: 'Vodafone Fibre — example early-termination fee',
      urdu: 'Vodafone Fibre — example early-termination fee',
    ),
    'td_vodafone_min_body': l10nEntry(
      english:
          'Fibre/broadband example (not a universal mobile-plan fee): QAR 798 early termination fee if cancelled within the first 12 months, PLUS the remaining pro-rated cost of any bundled equipment (e.g. router/Mesh). Mobile-only SIM contract fees were not confirmed in research.',
      arabic:
          'مثال Fibre/الإنترنت (ليس رسوم mobile عامة): 798 ر.ق إنهاء مبكر خلال 12 شهراً الأولى، بالإضافة إلى التكلفة المتناسبة المتبقية للمعدات (router/Mesh). رسوم SIM mobile-only لم تُؤكَّد.',
      hindi:
          'Fibre/broadband example (universal mobile fee nahi): first 12 months mein cancel par QAR 798 + bundled equipment (router/Mesh) ka remaining pro-rated cost। Mobile-only SIM fees confirmed nahi।',
      urdu:
          'Fibre/broadband example (universal mobile fee nahi): first 12 months mein cancel par QAR 798 + bundled equipment (router/Mesh) ka remaining pro-rated cost۔ Mobile-only SIM fees confirmed nahi۔',
    ),
    'td_section_other_facts_title': l10nEntry(
      english: 'Other confirmed contract facts',
      arabic: 'حقائق تعاقدية أخرى مؤكدة',
      hindi: 'Other confirmed contract facts',
      urdu: 'Other confirmed contract facts',
    ),
    'td_other_quarantine': l10nEntry(
      english:
          'Cancelled phone numbers enter a 180-day quarantine before reuse (Ooredoo).',
      arabic: 'أرقام الهاتف الملغاة تدخل حجراً 180 يوماً قبل إعادة الاستخدام (Ooredoo).',
      hindi: 'Cancelled numbers 180-day quarantine mein jaate hain reuse se pehle (Ooredoo).',
      urdu: 'Cancelled numbers 180-day quarantine mein jaate hain reuse se pehle (Ooredoo).',
    ),
    'td_other_rp_trigger': l10nEntry(
      english:
          'RP/QID cancellation is an explicit contract-termination trigger from the provider\'s side.',
      arabic: 'إلغاء RP/QID محفّز صريح لإنهاء العقد من جانب المزود.',
      hindi: 'RP/QID cancellation provider ki taraf se explicit contract-termination trigger hai.',
      urdu: 'RP/QID cancellation provider ki taraf se explicit contract-termination trigger hai.',
    ),
    'td_other_gigatv': l10nEntry(
      english:
          'GigaTV Set Top Box (Vodafone) has a separate 24-month device lock-in with its own return/penalty terms — distinct from the Fibre contract itself.',
      arabic:
          'GigaTV Set Top Box (Vodafone) له lock-in منفصل 24 شهراً للجهاز مع شروط إرجاع/غرامة خاصة — منفصل عن عقد Fibre.',
      hindi:
          'GigaTV Set Top Box (Vodafone) ka alag 24-month device lock-in + return/penalty terms — Fibre contract se alag.',
      urdu:
          'GigaTV Set Top Box (Vodafone) ka alag 24-month device lock-in + return/penalty terms — Fibre contract se alag.',
    ),
    'td_section_cra_title': l10nEntry(
      english: 'CRA escalation — second tier, not first stop',
      arabic: 'تصعيد CRA — المستوى الثاني وليس الأول',
      hindi: 'CRA escalation — second tier, not first stop',
      urdu: 'CRA escalation — second tier, not first stop',
    ),
    'td_cra_intro': l10nEntry(
      english:
          'The Communications Regulatory Authority (CRA), established under Emiri Decree No. 42 of 2014, can take complaints after you have exhausted the provider process. You must complain to Ooredoo or Vodafone FIRST and keep the complaint reference number they give you, plus your QID.',
      arabic:
          'هيئة تنظيم الاتصالات (CRA) بموجب المرسوم الأمiri No. 42 لسنة 2014 — تصعيد بعد شكوى المزود. يجب الشكوى إلى Ooredoo أو Vodafone أولاً مع رقم المرجع وQID.',
      hindi:
          'CRA (Emiri Decree 42/2014) provider process ke baad escalate kar sakti hai। Pehle Ooredoo/Vodafone ko complain karein — reference number + QID rakhein।',
      urdu:
          'CRA (Emiri Decree 42/2014) provider process ke baad escalate kar sakti hai۔ Pehle Ooredoo/Vodafone ko complain karein — reference number + QID rakhein۔',
    ),
    'td_cra_eligible_heading': l10nEntry(
      english: 'When CRA can accept your complaint',
      arabic: 'متى تقبل CRA شكواك',
      hindi: 'When CRA can accept your complaint',
      urdu: 'When CRA can accept your complaint',
    ),
    'td_cra_eligible_1': l10nEntry(
      english: 'Mobile service issue unresolved 48 hours after your initial complaint to the provider',
      arabic: 'مشكلة mobile غير محلولة بعد 48 ساعة من الشكوى الأولى للمزود',
      hindi: 'Mobile issue provider ko initial complaint ke 48 hours baad unresolved',
      urdu: 'Mobile issue provider ko initial complaint ke 48 hours baad unresolved',
    ),
    'td_cra_eligible_2': l10nEntry(
      english: 'Fixed-line issue unresolved 72 hours after your initial complaint to the provider',
      arabic: 'مشكلة fixed-line غير محلولة بعد 72 ساعة من الشكوى الأولى',
      hindi: 'Fixed-line issue initial complaint ke 72 hours baad unresolved',
      urdu: 'Fixed-line issue initial complaint ke 72 hours baad unresolved',
    ),
    'td_cra_eligible_3': l10nEntry(
      english: 'Any non-connection complaint unresolved 30 calendar days after your initial complaint',
      arabic: 'أي شكوى غير اتصال غير محلولة بعد 30 يوماً تقويمياً',
      hindi: 'Non-connection complaint 30 calendar days baad unresolved',
      urdu: 'Non-connection complaint 30 calendar days baad unresolved',
    ),
    'td_cra_eligible_4': l10nEntry(
      english:
          'New fixed-line service not delivered within 10 working days, and a follow-up complaint about that delay remains unresolved 48 hours',
      arabic:
          'fixed-line جديد لم يُسلَّم خلال 10 أيام عمل، وشكوى متابعة عن التأخير غير محلولة بعد 48 ساعة',
      hindi:
          'New fixed-line 10 working days mein deliver nahi + follow-up complaint 48 hours baad unresolved',
      urdu:
          'New fixed-line 10 working days mein deliver nahi + follow-up complaint 48 hours baad unresolved',
    ),
    'td_cra_eligible_5': l10nEntry(
      english: 'A customer with a disability\'s complaint unresolved 48 hours after the initial complaint',
      arabic: 'شكوى عميل ذي إعاقة غير محلولة بعد 48 ساعة من الشكوى الأولى',
      hindi: 'Disability wale customer ki complaint 48 hours baad unresolved',
      urdu: 'Disability wale customer ki complaint 48 hours baad unresolved',
    ),
    'td_cra_eligible_6': l10nEntry(
      english: 'You are simply unsatisfied with a closed complaint\'s resolution',
      arabic: 'أنت غير راضٍ ببساطة عن حل شكوى مُغلقة',
      hindi: 'Closed complaint ke resolution se simply unsatisfied',
      urdu: 'Closed complaint ke resolution se simply unsatisfied',
    ),
    'td_cra_channels': l10nEntry(
      english:
          'Confirmed CRA channels: hotline 103 (within Qatar) or +974 4406 9938 (overseas), online complaint form at cra.gov.qa, the Arsel app, and @craqatar on social media.',
      arabic:
          'قنوات CRA: 103 (داخل قطر) أو +974 4406 9938 (خارج قطر)، نموذج cra.gov.qa، تطبيق Arsel، @craqatar.',
      hindi:
          'CRA channels: 103 / +974 4406 9938, cra.gov.qa form, Arsel app, @craqatar.',
      urdu:
          'CRA channels: 103 / +974 4406 9938, cra.gov.qa form, Arsel app, @craqatar.',
    ),
    'td_cra_open_form': l10nEntry(
      english: 'Open CRA complaint form',
      arabic: 'فتح نموذج شكوى CRA',
      hindi: 'Open CRA complaint form',
      urdu: 'Open CRA complaint form',
    ),
  };
}
