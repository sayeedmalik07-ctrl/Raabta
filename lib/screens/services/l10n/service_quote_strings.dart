import 'package:flutter/foundation.dart';
import 'package:raabta/core/l10n/app_locale.dart';
import 'package:raabta/core/l10n/locale_catalog_coverage.dart';
import 'package:raabta/core/l10n/locale_catalog_entry.dart';

abstract final class ServiceQuoteStrings {
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
    'svc_submit_quote': l10nEntry(
      english: 'Submit a Quote',
      arabic: 'قدّم عرض سعر',
      hindi: 'Quote submit karein',
    ),
    'svc_submit_quote_bar_hint': l10nEntry(
      english: 'Tap Submit a Quote in the bar below to send your price.',
      arabic: 'اضغط «تقديم عرض سعر» في الشريط أدناه لإرسال سعرك.',
      hindi: 'Apni price bhejne ke liye neeche wale bar mein Submit a Quote dabayein.',
    ),
    'svc_submit_quote_title': l10nEntry(
      english: 'Submit a quote',
      arabic: 'تقديم عرض سعر',
      hindi: 'Quote submit karein',
    ),
    'svc_submit_quote_subtitle': l10nEntry(
      english:
          'Enter one specific price for this job — not a range. This is the amount you are committing to for what you describe as included. If something could change the price later, say so separately below.',
      arabic:
          'أدخل سعرًا محددًا واحدًا لهذا العمل — وليس نطاقًا. هذا المبلغ الذي تلتزم به مقابل ما تصفه كمشمول. إذا كان هناك ما قد يغيّر السعر لاحقًا، اذكره بشكل منفصل أدناه.',
      hindi:
          'Is kaam ke liye ek specific price likhein — range nahi. Jo aap included batate hain uske liye yahi amount aap commit kar rahe hain. Agar baad mein price badal sakti hai to neeche alag likhein.',
    ),
    'svc_quote_price_label': l10nEntry(
      english: 'Your price (QAR)',
      arabic: 'سعرك (ريال قطري)',
      hindi: 'Aapki price (QAR)',
    ),
    'svc_quote_included_label': l10nEntry(
      english: 'What is included in this price',
      arabic: 'ما المشمول في هذا السعر',
      hindi: 'Is price mein kya shamil hai',
    ),
    'svc_quote_included_hint': l10nEntry(
      english: 'e.g. labour, basic parts, one visit',
      arabic: 'مثال: العمالة، قطع أساسية، زيارة واحدة',
      hindi: 'jaise: labour, basic parts, ek visit',
    ),
    'svc_quote_caveat_label': l10nEntry(
      english: 'Anything that could change the price (optional)',
      arabic: 'ما قد يغيّر السعر (اختياري)',
      hindi: 'Jo price badal sakta hai (optional)',
    ),
    'svc_quote_caveat_hint': l10nEntry(
      english: 'e.g. extra parts if needed on site',
      arabic: 'مثال: قطع إضافية إذا لزم الأمر في الموقع',
      hindi: 'jaise: site par extra parts agar zaroori hon',
    ),
    'svc_quote_invalid_price': l10nEntry(
      english: 'Enter a valid price greater than zero.',
      arabic: 'أدخل سعرًا صالحًا أكبر من صفر.',
      hindi: 'Zero se zyada valid price likhein.',
    ),
    'svc_quote_invalid_included': l10nEntry(
      english: 'Briefly describe what is included in your price.',
      arabic: 'صف باختصار ما المشمول في سعرك.',
      hindi: 'Apni price mein kya shamil hai, thoda likhein.',
    ),
    'svc_quotes_section_title': l10nEntry(
      english: 'Quotes received',
      arabic: 'عروض الأسعار المستلمة',
      hindi: 'Mile hue quotes',
    ),
    'svc_quotes_count': l10nEntry(
      english: '{count} quote(s)',
      arabic: '{count} عرض/عروض',
      hindi: '{count} quote',
    ),
    'svc_quote_price_line': l10nEntry(
      english: 'QAR {price}',
      arabic: '{price} ر.ق',
      hindi: 'QAR {price}',
    ),
    'svc_quote_included_line': l10nEntry(
      english: 'Includes: {text}',
      arabic: 'يشمل: {text}',
      hindi: 'Shamil: {text}',
    ),
    'svc_quote_caveat_line': l10nEntry(
      english: 'May change if: {text}',
      arabic: 'قد يتغير إذا: {text}',
      hindi: 'Badal sakta hai agar: {text}',
    ),
    'svc_quote_inflation_note': l10nEntry(
      english:
          'Each quote is the price that provider told you the job will cost for what they described as included. If the final price is different once work begins, discuss that with the provider directly before agreeing to any change.',
      arabic:
          'كل عرض هو السعر الذي أخبرك به مقدم الخدمة لتكلفة العمل مقابل ما وصفه كمشمول. إذا اختلف السعر النهائي عند بدء العمل، ناقش ذلك مع مقدم الخدمة مباشرة قبل الموافقة على أي تغيير.',
      hindi:
          'Har quote wahi price hai jo provider ne batayi hai us cheez ke liye jo unhone included likha hai. Agar kaam shuru hone par final price alag ho to kisi change par agree karne se pehle provider se seedha baat karein.',
    ),
    'svc_quote_select': l10nEntry(
      english: 'Proceed with this quote',
      arabic: 'المتابعة بهذا العرض',
      hindi: 'Is quote ke saath aage badhein',
    ),
    'svc_quote_selected': l10nEntry(
      english: 'You chose this quote',
      arabic: 'اخترت هذا العرض',
      hindi: 'Aapne yeh quote chuna',
    ),
    'svc_quote_closed': l10nEntry(
      english: 'This request is no longer accepting new quotes.',
      arabic: 'هذا الطلب لم يعد يقبل عروض أسعار جديدة.',
      hindi: 'Yeh request ab naye quotes nahi le rahi.',
    ),
    'svc_already_quoted': l10nEntry(
      english: 'You already submitted a quote for this request.',
      arabic: 'لقد قدّمت عرض سعر لهذا الطلب بالفعل.',
      hindi: 'Aap is request par pehle hi quote submit kar chuke hain.',
    ),
    'svc_open_chat': l10nEntry(
      english: 'Open chat',
      arabic: 'فتح المحادثة',
      hindi: 'Chat kholen',
    ),
    'svc_quote_chat_title': l10nEntry(
      english: 'Service chat',
      arabic: 'محادثة الخدمة',
      hindi: 'Service chat',
    ),
    'svc_quote_chat_hint': l10nEntry(
      english: 'Message about this job…',
      arabic: 'رسالة حول هذا العمل…',
      hindi: 'Is kaam ke baare mein likhein…',
    ),
    'svc_quote_chat_selected_system': l10nEntry(
      english:
          'You indicated you would like to proceed with {provider}\'s quote of QAR {price}. Use this chat to arrange details.',
      arabic:
          'أشرت إلى أنك تريد المتابعة مع عرض {provider} بقيمة {price} ر.ق. استخدم هذه المحادثة لترتيب التفاصيل.',
      hindi:
          'Aapne {provider} ka QAR {price} wala quote choose kiya hai. Details ke liye is chat ka use karein.',
    ),
    'svc_quote_notif_received_title': l10nEntry(
      english: 'New quote on your request',
      arabic: 'عرض سعر جديد على طلبك',
      hindi: 'Aapke request par naya quote',
    ),
    'svc_quote_notif_received_body': l10nEntry(
      english: '{provider} quoted QAR {price} for "{title}".',
      arabic: '{provider} قدّم {price} ر.ق لـ "{title}".',
      hindi: '{provider} ne "{title}" ke liye QAR {price} quote diya.',
    ),
    'svc_quote_notif_selected_title': l10nEntry(
      english: 'Customer chose your quote',
      arabic: 'العميل اختار عرضك',
      hindi: 'Customer ne aapka quote chuna',
    ),
    'svc_quote_notif_selected_body': l10nEntry(
      english: 'Your QAR {price} quote for "{title}" was selected.',
      arabic: 'تم اختيار عرضك {price} ر.ق لـ "{title}".',
      hindi: '"{title}" ke liye aapka QAR {price} quote select hua.',
    ),
  };
}
