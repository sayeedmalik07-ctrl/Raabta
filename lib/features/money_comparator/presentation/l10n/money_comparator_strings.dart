/// Remittance Corridor Comparator — compare screen, report form, and hub link.
import 'package:flutter/foundation.dart';
import 'package:raabta/core/l10n/app_locale.dart';
import 'package:raabta/core/l10n/locale_catalog_coverage.dart';
import 'package:raabta/core/l10n/locale_catalog_entry.dart';

abstract final class MoneyComparatorStrings {
  static const supportedLocales = AppLocale.supportedLocales;

  /// Tamil / Malayalam / Nepali remittance & finance terms pending native review.
  static const keysNeedingProfessionalReview = <String>{
    'mc_title',
    'mc_amount_label',
    'mc_amount_prefix',
    'mc_sort_best_value',
    'mc_community_transfer_data',
    'mc_cached_pull_refresh',
    'mc_not_enough_data_body',
    'mc_ranked_by_recipient',
    'mc_amount_sent',
    'mc_fee_paid',
    'mc_recipient_received',
    'mc_method_bank',
    'mc_method_mobile_wallet',
    'mc_method_cash_pickup',
    'mc_sanity_fee_high',
    'mc_sanity_invalid_total',
    'mc_sanity_amount_high',
    'mc_link_title',
    'mc_link_subtitle',
    'mc_compare_remittance',
    'mc_tool_subtitle',
    'mc_tool_indicative_line',
  };

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

  /// Exposed for catalog parity regression tests only.
  @visibleForTesting
  static Map<String, Set<String>> get localeCoverageReport =>
      buildLocaleCoverageReport(
        catalog: _catalog,
        supportedLocales: supportedLocales,
      );

  static final _catalog = <String, Map<String, String>>{
    // ── Compare screen ────────────────────────────────────────────────────────
    'mc_title': l10nEntry(
      english: 'Remittance Truth Engine',
      arabic: 'محرك شفافية التحويلات',
      hindi: 'Remittance Truth Engine',
      urdu: 'Remittance Truth Engine',
      bengali: 'Remittance Truth Engine',
      filipino: 'Remittance Truth Engine',
    ),
    'mc_tool_subtitle': l10nEntry(
      english: 'Compare mid-market and community-reported transfer costs.',
      arabic:
          'قارن تكلفة التحويل بين السوق الوسطي والتقارير المجتمعية.',
      hindi:
          'मिड-मार्केट और समुदाय-रिपोर्ट ट्रांसफ़र लागत की तुलना करें।',
      urdu:
          'مڈ مارکیٹ اور کمیونٹی-رپورٹ شدہ ٹرانسفر لاگت کا موازنہ کریں۔',
      bengali:
          'মিড-মার্কেট ও কমিউনিটি-রিপোর্ট করা ট্রান্সফার খরচ তুলুন।',
      filipino:
          'Ikumpara ang mid-market at community-reported na gastos sa transfer.',
    ),
    'mc_tool_indicative_line': l10nEntry(
      english:
          'Figures are indicative — verify fees and FX with your provider before sending.',
      arabic:
          'الأرقام تقريبية — تحقق من الرسوم وسعر الصرف مع مزودك قبل الإرسال.',
      hindi:
          'आंकड़े संकेतक हैं — भेजने से पहले अपने प्रदाता से शुल्क और FX सत्यापित करें।',
      urdu:
          'اعداد تعمیلی ہیں — بھیجنے سے پہلے اپنے فراہم کنندہ سے فیس اور FX تصدیق کریں۔',
      bengali:
          'সংখ্যাগুলো সূচক — পাঠানোর আগে আপনার প্রোভাইডারের কাছ থেকে ফি ও FX নিশ্চিত করুন।',
      filipino:
          'Ang mga halaga ay indikatibo — beripikahin ang mga bayarin at FX sa provider mo bago magpadala.',
    ),
    'mc_report_transfer_tooltip': l10nEntry(
      english: 'Report your transfer',
      arabic: 'أبلغ عن تحويلك',
      hindi: 'अपना ट्रांसफ़र रिपोर्ट करें',
      urdu: 'اپنا transfer رپورٹ کریں',
      bengali: 'আপনার ট্রান্সফার রিপোর্ট করুন',
      filipino: 'I-report ang transfer mo',
    ),
    'mc_send_to': l10nEntry(
      english: 'Send to',
      arabic: 'إرسال إلى',
      hindi: 'भेजें',
      urdu: 'بھیجیں',
      bengali: 'পাঠান',
      filipino: 'Ipadala sa',
    ),
    'mc_amount_label': l10nEntry(
      english: 'Amount to send (QAR)',
      arabic: 'المبلغ للإرسال (QAR)',
      hindi: 'भेजने की राशि (QAR)',
      urdu: 'بھیجنے کی رقم (QAR)',
      bengali: 'পাঠানোর পরিমাণ (QAR)',
      filipino: 'Halagang ipapadala (QAR)',
    ),
    'mc_amount_prefix': l10nEntry(
      english: 'QAR ',
      arabic: 'QAR ',
      hindi: 'QAR ',
      urdu: 'QAR ',
      bengali: 'QAR ',
      filipino: 'QAR ',
    ),
    'mc_amount_hint': l10nEntry(
      english: '1000',
      arabic: '1000',
      hindi: '1000',
      urdu: '1000',
      bengali: '1000',
      filipino: '1000',
    ),
    'mc_sort_best_value': l10nEntry(
      english: 'Best value',
      arabic: 'أفضل قيمة',
      hindi: 'सर्वोत्तम मूल्य',
      urdu: 'بہترین قیمت',
      bengali: 'সেরা মূল্য',
      filipino: 'Pinakamahusay na halaga',
    ),
    'mc_sort_fastest': l10nEntry(
      english: 'Fastest',
      arabic: 'الأسرع',
      hindi: 'सबसे तेज़',
      urdu: 'سب سے تیز',
      bengali: 'দ্রুততম',
      filipino: 'Pinakamabilis',
    ),
    'mc_community_transfer_data': l10nEntry(
      english: 'Community transfer data',
      arabic: 'بيانات تحويل المجتمع',
      hindi: 'समुदाय ट्रांसफ़र डेटा',
      urdu: 'کمیونٹی transfer ڈیٹا',
      bengali: 'কমিউনিটি ট্রান্সফার ডেটা',
      filipino: 'Community transfer data',
    ),
    'mc_cached_pull_refresh': l10nEntry(
      english: 'Cached data — pull to refresh when online',
      arabic: 'بيانات مخزّنة — اسحب للتحديث عند الاتصال',
      hindi: 'कैश्ड डेटा — ऑनलाइन होने पर रीफ़्रेश करें',
      urdu: 'محفوظ ڈیٹا — آن لائن ہونے پر ریفریش کریں',
      bengali: 'ক্যাশ করা ডেটা — অনলাইনে থাকলে রিফ্রেশ করুন',
      filipino: 'Naka-cache na data — hilahin para i-refresh kapag online',
    ),
    'mc_error_load_title': l10nEntry(
      english: 'Could not load comparisons',
      arabic: 'تعذّر تحميل المقارنات',
      hindi: 'तुलना लोड नहीं हो सकी',
      urdu: 'موازنہ لوڈ نہیں ہو سکا',
      bengali: 'তুলনা লোড করা যায়নি',
      filipino: 'Hindi ma-load ang mga comparison',
    ),
    'mc_retry': l10nEntry(
      english: 'Retry',
      arabic: 'إعادة المحاولة',
      hindi: 'पुनः प्रयास',
      urdu: 'دوبارہ کوشش',
      bengali: 'আবার চেষ্টা',
      filipino: 'Subukan muli',
    ),
    'mc_not_enough_data_title': l10nEntry(
      english: 'Not enough data yet',
      arabic: 'لا توجد بيانات كافية بعد',
      hindi: 'अभी पर्याप्त डेटा नहीं',
      urdu: 'ابھی کافی ڈیٹا نہیں',
      bengali: 'এখনও পর্যাপ্ত ডেটা নেই',
      filipino: 'Wala pang sapat na data',
    ),
    'mc_not_enough_data_body': l10nEntry(
      english:
          'We need at least {minReports} community reports per provider/method '
          'for {country}. Be the first to share what you got.',
      arabic:
          'نحتاج {minReports} تقارير مجتمعية على الأقل لكل مزود/طريقة '
          'لـ {country}. كن أول من يشارك ما حصلت عليه.',
      hindi:
          '{country} के लिए प्रति प्रदाता/विधि कम से कम {minReports} '
          'समुदाय रिपोर्ट चाहिए। पहले साझा करें।',
      urdu:
          '{country} کے لیے فی فراہم کنندہ/طریقہ کم از کم {minReports} '
          'کمیونٹی رپورٹ درکار۔ پہلے شیئر کریں۔',
      bengali:
          '{country}-এর জন্য প্রতি provider/method-এ কমপক্ষে {minReports} '
          'community report দরকার। প্রথমে শেয়ার করুন।',
      filipino:
          'Kailangan ng hindi bababa sa {minReports} community reports bawat '
          'provider/method para sa {country}. Mauna kang magbahagi.',
    ),
    'mc_submit_report': l10nEntry(
      english: 'Submit a report',
      arabic: 'إرسال تقرير',
      hindi: 'रिपोर्ट जमा करें',
      urdu: 'رپورٹ جمع کریں',
      bengali: 'রিপোর্ট জমা দিন',
      filipino: 'Mag-submit ng report',
    ),
    'mc_ranked_by_speed': l10nEntry(
      english: 'Ranked by speed',
      arabic: 'مرتّب حسب السرعة',
      hindi: 'गति के अनुसार क्रम',
      urdu: 'رفتار کے لحاظ سے درجہ',
      bengali: 'গতি অনুযায়ী সাজানো',
      filipino: 'Naka-rank ayon sa bilis',
    ),
    'mc_ranked_by_recipient': l10nEntry(
      english: 'Ranked by recipient gets',
      arabic: 'مرتّب حسب ما يحصل عليه المستلم',
      hindi: 'प्राप्तकर्ता को मिलने के अनुसार क्रम',
      urdu: 'وصول کنندہ کو ملنے کے لحاظ سے درجہ',
      bengali: 'প্রাপক যা পায় তার ভিত্তিতে সাজানো',
      filipino: 'Naka-rank ayon sa matatanggap ng recipient',
    ),
    /// Clarifies that [CorridorSortMode] applies only to community aggregate cards.
    'mc_community_sort_scope_hint': l10nEntry(
      english:
          'Sorting applies only to community-reported results below. Provider rankings above stay in recipient-gets order.',
      arabic:
          'ينطبق الترتيب على نتائج تقارير المجتمع أدناه فقط. ترتيب مزوّدي الخدمة أعلاه يبقى حسب ما يحصل عليه المستلم.',
      hindi:
          'क्रमण केवल नीचे समुदाय-रिपोर्ट परिणामों पर लागू है। ऊपर प्रदाता क्रम प्राप्तकर्ता को मिलने वाली राशि के अनुसार स्थिर रहता है।',
      urdu:
          'ترتیب صرف نیچے کمیونٹی رپورٹ نتائج پر لاگو ہے۔ اوپر فراہم کنندگان کا ترتیب وصول کنندہ کی رقم کے لحاظ سے قائم رہتا ہے۔',
      malayalam:
          'ക്രമീകരണം ചുവടെയുള്ള കമ്മ്യൂണിറ്റി റിപ്പോർട്ട് ഫലങ്ങൾക്ക് മാത്രമാണ്. മുകളിലെ പ്രൊവൈഡർ ക്രമം ഗ്രാഹകൻ ലഭിക്കുന്ന തുകയുടെ ക്രമത്തിൽ നിലനിൽക്കും.',
      nepali:
          'क्रमण मात्र तलका समुदाय-रिपोर्ट परिणामहरूमा लागू हुन्छ। माथिका प्रदायक क्रम प्राप्तकर्ताले पाउने रकम अनुसार स्थिर रहन्छ।',
      bengali:
          'সাজানো শুধু নিচের কমিউনিটি-রিপোর্ট ফলাফলে প্রযোজ্য। উপরের প্রোভাইডার ক্রম প্রাপক যা পায় তার ভিত্তিতে অপরিবর্তিত থাকে।',
      tamil:
          'வரிசைப்படுத்துதல் கீழே உள்ள சமூக அறிக்கை முடிவுகளுக்கு மட்டுமே. மேலுள்ள வழங்குநர் வரிசை பெறுநர் பெறும் தொகை வரிசையில் நிலையானது.',
      filipino:
          'Ang pag-uuri ay para lang sa community-reported na resulta sa ibaba. Ang provider rankings sa itaas ay nakaayon pa rin batay sa matatanggap ng recipient.',
    ),

    /// Community aggregate card — report line (`{count}`, `{updated}`).
    'mc_community_reports_meta': l10nEntry(
      english: 'Based on {count} recent reports · last updated {updated}',
      arabic: 'بناءً على {count} تقارير حديثة · آخر تحديث {updated}',
      hindi: '{count} हाल की रिपोर्टों के आधार पर · अंतिम अपडेट {updated}',
      urdu: '{count} حالیہ رپورٹس کی بنیاد پر · آخری اپ ڈیٹ {updated}',
      malayalam:
          'അടുത്തകാലത്തെ {count} റിപ്പോർട്ടുകളെ അടിസ്ഥാനമാക്കി · അവസാനം അപ്‌ഡേറ്റ് ചെയ്തത് {updated}',
      nepali: '{count} भर्खरका रिपोर्टहरूको आधारमा · अन्तिम अपडेट {updated}',
      bengali: 'সাম্প্রতিক {count}টি রিপোর্টের ভিত্তিতে · সর্বশেষ আপডেট {updated}',
      tamil:
          'சமீபத்திய {count} அறிக்கைகளின் அடிப்படையில் · கடைசியாக புதுப்பிக்கப்பட்டது {updated}',
      filipino:
          'Batay sa {count} kamakailang ulat · huling na-update: {updated}',
    ),
    /// When [CorridorAggregate.lastUpdated] is missing.
    'mc_community_updated_recently': l10nEntry(
      english: 'recently',
      arabic: 'مؤخراً',
      hindi: 'हाल ही में',
      urdu: 'حال ہی میں',
      malayalam: 'അടുത്തിടയിൽ',
      nepali: 'भर्खरै',
      bengali: 'সম্প্রতি',
      tamil: 'அண்மையில்',
      filipino: 'kamakailan',
    ),
    /// Per-100-QAR stats row (`{per100}`, `{code}`, `{fee}`, `{speed}`).
    'mc_community_stats_line': l10nEntry(
      english:
          '~{per100} {code} per 100 QAR sent · avg fee ~{fee} QAR · {speed}',
      arabic:
          '~{per100} {code} لكل 100 ر.ق مرسلة · متوسط الرسوم ~{fee} ر.ق · {speed}',
      hindi:
          'भेजे गए प्रति 100 QAR पर ~{per100} {code} · औसत शुल्क ~{fee} QAR · {speed}',
      urdu:
          'بھیجے گئے فی 100 QAR پر ~{per100} {code} · اوسط فیس ~{fee} QAR · {speed}',
      malayalam:
          'അയച്ച 100 QAR-ന് ~{per100} {code} · ശരാശരി ഫീസ് ~{fee} QAR · {speed}',
      nepali:
          'पठाइएको प्रति 100 QAR मा ~{per100} {code} · औसत शुल्क ~{fee} QAR · {speed}',
      bengali:
          'পাঠানো প্রতি 100 QAR-এ ~{per100} {code} · গড় ফি ~{fee} QAR · {speed}',
      tamil:
          'அனுப்பப்பட்ட ஒரு 100 QAR-க்கு ~{per100} {code} · சராசரி கட்டணம் ~{fee} QAR · {speed}',
      filipino:
          '~{per100} {code} bawat 100 QAR na ipinadala · avg na bayad ~{fee} QAR · {speed}',
    ),
    /// Delivery under 24h (`{hours}`).
    'mc_community_speed_hours': l10nEntry(
      english: '~{hours}h typical',
      arabic: '~{hours} ساعة تقريباً',
      hindi: '~{hours} घंटे औसतन',
      urdu: '~{hours} گھنٹے عموماً',
      malayalam: '~{hours} മണിക്കൂർ സാധാരണയായി',
      nepali: '~{hours} घण्टा प्रायः',
      bengali: '~{hours} ঘণ্টা সাধারণত',
      tamil: '~{hours} மணிநேரம் வழக்கமாக',
      filipino: '~{hours} oras karaniwan',
    ),
    /// Delivery 24h+ (`{days}` decimal string).
    'mc_community_speed_days': l10nEntry(
      english: '~{days} days typical',
      arabic: '~{days} يوماً تقريباً',
      hindi: '~{days} दिन औसतन',
      urdu: '~{days} دن عموماً',
      malayalam: '~{days} ദിവസം സാധാരണയായി',
      nepali: '~{days} दिन प्रायः',
      bengali: '~{days} দিন সাধারণত',
      tamil: '~{days} நாட்கள் வழக்கமாக',
      filipino: '~{days} araw karaniwan',
    ),

    // ── Submit report screen ────────────────────────────────────────────────────
    'mc_submit_title': l10nEntry(
      english: 'Report your transfer',
      arabic: 'أبلغ عن تحويلك',
      hindi: 'अपना ट्रांसफ़र रिपोर्ट करें',
      urdu: 'اپنا transfer رپورٹ کریں',
      bengali: 'আপনার ট্রান্সফার রিপোর্ট করুন',
      filipino: 'I-report ang transfer mo',
    ),
    /// Hub header subtitle — anonymous community transfer report (compare screen).
    'mc_submit_subtitle': l10nEntry(
      english:
          'Share what you sent — helps others compare corridors anonymously.',
      arabic:
          'شارك ما أرسلته — يساعد الآخرين على مقارنة الممرات دون كشف هوية.',
      hindi:
          'जो भेजा वो साझा करें — दूसरों को गलियारों की गुमनाम तुलना में मदद करता है।',
      urdu:
          'جو بھیجا ہے شیئر کریں — دوسروں کو بغیر شناخت راہوں کا موازنہ کرنے میں مدد۔',
      malayalam:
          'നിങ്ങൾ അയച്ചത് പങ്കിടുക — മറ്റുള്ളവർക്ക് മുറികൾ അജ്ഞാതമായി താരതമ്യം ചെയ്യാൻ സഹായിക്കുന്നു.',
      nepali:
          'पठाउनुभएको साझा गर्नुहोस् — अरूलाई गलियाराहरू गोप्य रूपमा तुलना गर्न मद्दत गर्छ।',
      bengali:
          'যা পাঠিয়েছেন তা শেয়ার করুন — অন্যদের করিডর নামহীনভাবে তুলতে সাহায্য করে।',
      tamil:
          'அனுப்பியதைப் பகிரவும் — பிறருக்கு முனைகளை அடையாளமில்லாமல் ஒப்பிட உதவும்.',
      filipino:
          'Ibahagi kung magkano ang ipinadala mo — tumutulong sa iba na ikumpara ang mga corridor nang walang pangalan.',
    ),
    /// Submit screen — gold hero line (under hero title).
    'mc_submit_hero_body': l10nEntry(
      english:
          'Anonymous numbers only. We use them to rank corridors — not to move money.',
      arabic:
          'أرقام فقط بدون هوية. نستخدمها لترتيب الممرات — لا لتحريك الأموال.',
      hindi:
          'केवल गुमनाम संख्याएँ। इन्हें मार्ग रैंक करने के लिए — पैसा भेजने के लिए नहीं।',
      urdu:
          'صرف گمنام اعداد۔ ان کا استعمال راہوں کی درجہ بندی — پیسہ منتقل کرنے کے لیے نہیں۔',
      malayalam:
          'അജ്ഞാത നമ്പറുകൾ മാത്രം. ഇത് മാർഗങ്ങൾ റാങ്ക് ചെയ്യാൻ — പണം നീക്കാൻ അല്ല.',
      nepali:
          'गोप्य संख्या मात्र। यसले करिडोर वर्गीकरण गर्छ — पैसा पठाउन होइन।',
      bengali:
          'শুধু অজ্ঞাতনামা সংখ্যা। করিডর র‍্যাঙ্ক করতে — টাকা পাঠাতে নয়।',
      tamil:
          'அடையாளமற்ற எண்கள் மட்டும். பாதைகளை வரிசைப்படுத்த — பணம் நகர்த்த அல்ல.',
      filipino:
          'Mga numerong anonymous lang. Ginagamit para i-rank ang mga corridor — hindi para magpadala ng pera.',
    ),
    'mc_submit_section_destination': l10nEntry(
      english: 'Where & who',
      arabic: 'إلى أين ولمَن',
      hindi: 'कहाँ और किसे',
      urdu: 'کہاں اور کس کو',
      malayalam: 'എവിടേക്കും ആര്ക്കും',
      nepali: 'कहाँ र कोसलाई',
      bengali: 'কোথায় ও কাকে',
      tamil: 'எங்கே மற்றும் யாருக்கு',
      filipino: 'Saan at kanino',
    ),
    'mc_submit_section_transfer_details': l10nEntry(
      english: 'Transfer amounts',
      arabic: 'مبالغ التحويل',
      hindi: 'ट्रांसफ़र राशियाँ',
      urdu: 'ٹرانسفر کی رقوم',
      malayalam: 'ട്രാൻസ്ഫർ തുകകൾ',
      nepali: 'ट्रान्सफर रकमहरू',
      bengali: 'ট্রান্সফারের অঙ্ক',
      tamil: 'பரிமாற்றத் தொகைகள்',
      filipino: 'Mga halaga ng transfer',
    ),
    'mc_submit_section_timing': l10nEntry(
      english: 'Delivery time',
      arabic: 'وقت التسليم',
      hindi: 'डिलीवरी समय',
      urdu: 'ترسیل کا وقت',
      malayalam: 'വിതരണ സമയം',
      nepali: 'डेलिभरी समय',
      bengali: 'ডেলিভারির সময়',
      tamil: 'வழங்கல் நேரம்',
      filipino: 'Oras ng delivery',
    ),
    'mc_submit_validation_hint': l10nEntry(
      english:
          'We may reject entries that look inconsistent. Fix fields and try again.',
      arabic:
          'قد نرفض القيَم غير المتسقة. صحّح الحقول وحاول مرة أخرى.',
      hindi:
          'असंगत प्रविष्टियाँ अस्वीकृत हो सकती हैं। फील्ड ठीक करें और फिर कोशिश करें।',
      urdu:
          'غیر متوازن اندراجات مسترد ہو سکتے ہیں۔ فیلڈز درست کریں اور دوبارہ کوشش کریں۔',
      malayalam:
          'പൊരുത്തമില്ലാത്ത എൻട്രികൾ നിരസിച്ചേക്കാം. ഫീൽഡുകൾ പരിഷ്കരിച്ച് വീണ്ടും ശ്രമിക്കുക.',
      nepali:
          'बेढुंगा प्रविष्टिहरू अस्वीकृत हुन सक्छन्। फिल्ड सच्याएर फेरि प्रयास गर्नुहोस्।',
      bengali:
          'অসামঞ্জস্য এন্ট্রি প্রত্যাখ্যান হতে পারে। ঠিক করে আবার চেষ্টা করুন।',
      tamil:
          'பொருந்தாத உள்ளீடுகள் நிராகரிக்கப்படலாம். புலங்களை சரிசெய்து மீண்டும் முயலவும்.',
      filipino:
          'Maaaring tanggapin ang mga entry na hindi tugma. Ayusin ang mga field at subukan muli.',
    ),
    /// Submit failed — user-safe (no raw exception).
    'mc_submit_error_generic': l10nEntry(
      english: 'Could not submit your report. Please try again shortly.',
      arabic: 'تعذّر إرسال تقريرك. يُرجى المحاولة بعد لحظات.',
      hindi: 'आपकी रिपोर्ट जमा नहीं हो सकी। कृपया कुछ देर बाद पुनः प्रयास करें।',
      urdu: 'آپ کی رپورٹ جمع نہیں ہو سکی۔ تھوڑی دیر بعد دوبارہ کوشش کریں۔',
      malayalam:
          'നിങ്ങളുടെ റിപ്പോർട്ട് സമർപ്പിക്കാനായില്ല. കുറച്ച് കഴിഞ്ഞ് വീണ്ടും ശ്രമിക്കുക.',
      nepali: 'तपाईंको रिपोर्ट पेस गर्न सकिएन। केही बेरपछि पुनः प्रयास गर्नुहोस्।',
      bengali: 'আপনার রিপোর্ট জমা দেওয়া যায়নি। কিছুক্ষণ পর আবার চেষ্টা করুন।',
      tamil:
          'உங்கள் அறிக்கையை சமர்ப்பிக்க முடியவில்லை. சிறிது நேரம் கழித்து மீண்டும் முயலவும்.',
      filipino:
          'Hindi ma-submit ang report mo. Pakisubukan muli maya-maya.',
    ),
    'mc_sign_in_required': l10nEntry(
      english: 'Sign in to submit a community report.',
      arabic: 'سجّل الدخول لإرسال تقرير مجتمعي.',
      hindi: 'समुदाय रिपोर्ट जमा करने के लिए साइन इन करें।',
      urdu: 'کمیونٹی رپورٹ جمع کرنے کے لیے سائن ان کریں۔',
      bengali: 'কমিউনিটি রিপোর্ট জমা দিতে সাইন ইন করুন।',
      filipino: 'Mag-sign in para mag-submit ng community report.',
    ),
    'mc_provider_required': l10nEntry(
      english: 'Enter the provider name.',
      arabic: 'أدخل اسم المزود.',
      hindi: 'प्रदाता का नाम दर्ज करें।',
      urdu: 'فراہم کنندہ کا نام درج کریں۔',
      bengali: 'প্রোভাইডারের নাম লিখুন।',
      filipino: 'Ilagay ang pangalan ng provider.',
    ),
    'mc_submit_thanks': l10nEntry(
      english:
          'Thanks — your report helps the community compare options.',
      arabic: 'شكراً — تقريرك يساعد المجتمع على مقارنة الخيارات.',
      hindi: 'धन्यवाद — आपकी रिपोर्ट समुदाय को विकल्प तुलना में मदद करती है।',
      urdu: 'شکریہ — آپ کی رپورٹ کمیونٹی کو موازنہ میں مدد دیتی ہے۔',
      bengali: 'ধন্যবাদ — আপনার রিপোর্ট কমিউনিটিকে তুলনায় সাহায্য করে।',
      filipino:
          'Salamat — ang report mo ay tumutulong sa community na mag-compare.',
    ),
    'mc_submit_error': l10nEntry(
      english: 'Could not submit: {error}',
      arabic: 'تعذّر الإرسال: {error}',
      hindi: 'जमा नहीं हो सका: {error}',
      urdu: 'جمع نہیں ہو سکا: {error}',
      bengali: 'জমা দেওয়া যায়নি: {error}',
      filipino: 'Hindi ma-submit: {error}',
    ),
    'mc_destination_country': l10nEntry(
      english: 'Destination country',
      arabic: 'بلد الوجهة',
      hindi: 'गंतव्य देश',
      urdu: 'منزل ملک',
      bengali: 'গন্তব্য দেশ',
      filipino: 'Bansang patutunguhan',
    ),
    'mc_method_used': l10nEntry(
      english: 'Method used',
      arabic: 'الطريقة المستخدمة',
      hindi: 'इस्तेमाल की विधि',
      urdu: 'استعمال شدہ طریقہ',
      bengali: 'ব্যবহৃত পদ্ধতি',
      filipino: 'Ginamit na paraan',
    ),
    'mc_provider_name': l10nEntry(
      english: 'Provider name',
      arabic: 'اسم المزود',
      hindi: 'प्रदाता का नाम',
      urdu: 'فراہم کنندہ کا نام',
      bengali: 'প্রোভাইডারের নাম',
      filipino: 'Pangalan ng provider',
    ),
    'mc_provider_hint': l10nEntry(
      english: 'e.g. Al Fardan, Western Union',
      arabic: 'مثال: Al Fardan، Western Union',
      hindi: 'जैसे Al Fardan, Western Union',
      urdu: 'مثال: Al Fardan، Western Union',
      bengali: 'যেমন Al Fardan, Western Union',
      filipino: 'hal. Al Fardan, Western Union',
    ),
    'mc_amount_sent': l10nEntry(
      english: 'Amount sent (QAR)',
      arabic: 'المبلغ المرسل (QAR)',
      hindi: 'भेजी गई राशि (QAR)',
      urdu: 'بھیجی گئی رقم (QAR)',
      bengali: 'পাঠানো পরিমাণ (QAR)',
      filipino: 'Halagang ipinadala (QAR)',
    ),
    'mc_fee_paid': l10nEntry(
      english: 'Fee paid (QAR)',
      arabic: 'الرسوم المدفوعة (QAR)',
      hindi: 'भुगतान किया शुल्क (QAR)',
      urdu: 'ادا شدہ فیس (QAR)',
      bengali: 'পরিশোধিত ফি (QAR)',
      filipino: 'Bayad na fee (QAR)',
    ),
    'mc_recipient_received': l10nEntry(
      english: 'Amount recipient received ({currency})',
      arabic: 'المبلغ الذي استلمه المستلم ({currency})',
      hindi: 'प्राप्तकर्ता को मिली राशि ({currency})',
      urdu: 'وصول کنندہ کو ملی رقم ({currency})',
      bengali: 'প্রাপক পেয়েছে ({currency})',
      filipino: 'Natanggap ng recipient ({currency})',
    ),
    'mc_delivery_hours': l10nEntry(
      english: 'Delivery time (hours)',
      arabic: 'وقت التسليم (ساعات)',
      hindi: 'डिलीवरी समय (घंटे)',
      urdu: 'ترسیل کا وقت (گھنٹے)',
      bengali: 'ডেলিভারি সময় (ঘণ্টা)',
      filipino: 'Oras ng delivery (oras)',
    ),
    'mc_submitting': l10nEntry(
      english: 'Submitting…',
      arabic: 'جاري الإرسال…',
      hindi: 'जमा हो रहा है…',
      urdu: 'جمع ہو رہا ہے…',
      bengali: 'জমা দেওয়া হচ্ছে…',
      filipino: 'Isinusubmit…',
    ),
    'mc_submit_button': l10nEntry(
      english: 'Submit report',
      arabic: 'إرسال التقرير',
      hindi: 'रिपोर्ट जमा करें',
      urdu: 'رپورٹ جمع کریں',
      bengali: 'রিপোর্ট জমা দিন',
      filipino: 'I-submit ang report',
    ),

    // ── Validation snackbars ──────────────────────────────────────────────────
    'mc_sanity_amount_sent': l10nEntry(
      english: 'Enter the amount you sent.',
      arabic: 'أدخل المبلغ الذي أرسلته.',
      hindi: 'भेजी गई राशि दर्ज करें।',
      urdu: 'بھیجی گئی رقم درج کریں۔',
      bengali: 'পাঠানো পরিমাণ লিখুন।',
      filipino: 'Ilagay ang halagang ipinadala mo.',
    ),
    'mc_sanity_recipient': l10nEntry(
      english: 'Enter what the recipient received.',
      arabic: 'أدخل ما استلمه المستلم.',
      hindi: 'प्राप्तकर्ता को क्या मिला दर्ज करें।',
      urdu: 'وصول کنندہ کو کیا ملا درج کریں۔',
      bengali: 'প্রাপক কী পেয়েছে লিখুন।',
      filipino: 'Ilagay kung ano ang natanggap ng recipient.',
    ),
    'mc_sanity_fee_negative': l10nEntry(
      english: 'Fee cannot be negative.',
      arabic: 'لا يمكن أن تكون الرسوم سالبة.',
      hindi: 'शुल्क ऋणात्मक नहीं हो सकता।',
      urdu: 'فیس منفی نہیں ہو سکتی۔',
      bengali: 'ফি ঋণাত্মক হতে পারে না।',
      filipino: 'Hindi maaaring negative ang fee.',
    ),
    'mc_sanity_fee_high': l10nEntry(
      english: 'Fee looks too high compared to amount sent.',
      arabic: 'الرسوم تبدو مرتفعة جداً مقارنة بالمبلغ المرسل.',
      hindi: 'भेजी गई राशि की तुलना में शुल्क बहुत अधिक लगता है।',
      urdu: 'بھیجی گئی رقم کے مقابلے میں فیس بہت زیادہ لگتی ہے۔',
      bengali: 'পাঠানো পরিমাণের তুলনায় ফি অনেক বেশি মনে হচ্ছে।',
      filipino: 'Mukhang masyadong mataas ang fee kumpara sa ipinadala.',
    ),
    'mc_sanity_invalid_total': l10nEntry(
      english: 'Check amounts — recipient total looks invalid.',
      arabic: 'تحقق من المبالغ — إجمالي المستلم يبدو غير صالح.',
      hindi: 'राशि जाँचें — प्राप्तकर्ता का कुल अमान्य लगता है।',
      urdu: 'رقوم چیک کریں — وصول کنندہ کا کل invalid لگتا ہے۔',
      bengali: 'পরিমাণ যাচাই করুন — প্রাপকের মোট invalid মনে হচ্ছে।',
      filipino: 'Suriin ang mga halaga — mukhang invalid ang total ng recipient.',
    ),
    'mc_sanity_amount_high': l10nEntry(
      english:
          'Recipient amount seems unusually high — please double-check.',
      arabic: 'مبلغ المستلم يبدو مرتفعاً بشكل غير عادي — يرجى المراجعة.',
      hindi: 'प्राप्तकर्ता की राशि असामान्य रूप से अधिक लगती है — जाँच करें।',
      urdu: 'وصول کنندہ کی رقم غیر معمولی زیادہ لگتی ہے — دوبارہ چیک کریں۔',
      bengali: 'প্রাপকের পরিমাণ অস্বাভাবিকভাবে বেশি — আবার যাচাই করুন।',
      filipino:
          'Mukhang hindi pangkaraniwang mataas ang halaga ng recipient — '
          'double-check.',
    ),
    'mc_sanity_delivery_hours': l10nEntry(
      english: 'Delivery time should be between 0 and 720 hours.',
      arabic: 'يجب أن يكون وقت التسليم بين 0 و 720 ساعة.',
      hindi: 'डिलीवरी समय 0 से 720 घंटे के बीच होना चाहिए।',
      urdu: 'ترسیل کا وقت 0 سے 720 گھنٹے کے درمیان ہونا چاہیے۔',
      bengali: 'ডেলিভারি সময় 0 থেকে 720 ঘণ্টার মধ্যে হতে হবে।',
      filipino: 'Dapat nasa pagitan ng 0 at 720 oras ang delivery time.',
    ),

    // ── Transfer methods ──────────────────────────────────────────────────────
    'mc_method_bank': l10nEntry(
      english: 'Bank transfer',
      arabic: 'تحويل بنكي',
      hindi: 'बैंक ट्रांसफ़र',
      urdu: 'بینک transfer',
      bengali: 'ব্যাংক ট্রান্সফার',
      filipino: 'Bank transfer',
    ),
    'mc_method_mobile_wallet': l10nEntry(
      english: 'Mobile wallet',
      arabic: 'محفظة جوال',
      hindi: 'मोबाइल वॉलेट',
      urdu: 'موبائل والٹ',
      bengali: 'মোবাইল ওয়ালেট',
      filipino: 'Mobile wallet',
    ),
    'mc_method_cash_pickup': l10nEntry(
      english: 'Cash pickup',
      arabic: 'استلام نقدي',
      hindi: 'नकद पिकअप',
      urdu: 'نقد وصول',
      bengali: 'নগদ পিকআপ',
      filipino: 'Cash pickup',
    ),

    // ── Hub link button ───────────────────────────────────────────────────────
    'mc_compare_remittance': l10nEntry(
      english: 'Compare remittance',
      arabic: 'قارن التحويلات',
      hindi: 'प्रेषण की तुलना करें',
      urdu: 'ترسیلات کا موازنہ',
      bengali: 'রেমিট্যান্স তুলনা',
      filipino: 'Ihambing ang remittance',
    ),
    'mc_link_title': l10nEntry(
      english: 'Remittance Corridor Comparator',
      arabic: 'مقارن ممرات التحويل',
      hindi: 'Remittance Corridor Comparator',
      urdu: 'Remittance Corridor Comparator',
      bengali: 'Remittance Corridor Comparator',
      filipino: 'Remittance Corridor Comparator',
    ),
    'mc_link_subtitle': l10nEntry(
      english: 'Live mid-market baseline vs hidden provider markups',
      arabic: 'سعر السوق المرجعي مقابل هامش مزودي الخدمة المخفي',
      hindi: 'Live mid-market baseline vs hidden provider markups',
      urdu: 'Live mid-market baseline vs hidden provider markups',
      bengali: 'Live mid-market baseline vs hidden provider markups',
      filipino: 'Live mid-market baseline vs hidden provider markups',
    ),

    // ── Remittance Truth Engine ───────────────────────────────────────────────
    'rte_mid_market': l10nEntry(
      english: 'Mid-market baseline',
      arabic: 'سعر السوق المرجعي',
      hindi: 'मिड-मार्केट बेसलाइन',
      urdu: 'درمیانی مارکیٹ بیس لائن',
      bengali: 'মিড-মার্কেট বেসলাইন',
      filipino: 'Mid-market baseline',
    ),
    'rte_source_frankfurter': l10nEntry(
      english: 'ECB via Frankfurter',
      arabic: 'ECB عبر Frankfurter',
      hindi: 'Frankfurter के माध्यम से ECB',
      urdu: 'Frankfurter کے ذریعے ECB',
      bengali: 'Frankfurter-এর মাধ্যমে ECB',
      filipino: 'ECB via Frankfurter',
    ),
    'rte_source_er_api': l10nEntry(
      english: 'open.er-api.com reference',
      arabic: 'مرجع open.er-api.com',
      hindi: 'open.er-api.com संदर्भ',
      urdu: 'open.er-api.com حوالہ',
      bengali: 'open.er-api.com রেফারেন্স',
      filipino: 'open.er-api.com reference',
    ),
    'rte_source_unknown': l10nEntry(
      english: 'Reference rate',
      arabic: 'سعر مرجعي',
      hindi: 'संदर्भ दर',
      urdu: 'حوالہ شرح',
      bengali: 'রেফারেন্স রেট',
      filipino: 'Reference rate',
    ),
    'rte_mid_market_rate_line': l10nEntry(
      english: '1 QAR = {rate} {code} (mid-market)',
      arabic: '1 QAR = {rate} {code} (سعر السوق)',
      hindi: '1 QAR = {rate} {code} (मिड-मार्केट)',
      urdu: '1 QAR = {rate} {code} (درمیانی مارکیٹ)',
      bengali: '1 QAR = {rate} {code} (মিড-মার্কেট)',
      filipino: '1 QAR = {rate} {code} (mid-market)',
    ),
    'rte_mid_market_as_of': l10nEntry(
      english: 'Mid-market rate as of {date}',
      arabic: 'سعر السوق المرجعي بتاريخ {date}',
      hindi: 'मिड-मार्केट दर {date} तक',
      urdu: 'درمیانی مارکیٹ شرح {date} تک',
      bengali: 'মিড-মার্কেট রেট {date} পর্যন্ত',
      filipino: 'Mid-market rate as of {date}',
    ),
    'rte_mid_market_disclaimer': l10nEntry(
      english:
          'Updated daily — not a live provider quote. INR/PHP via ECB (Frankfurter); NPR/BDT/PKR via open.er-api.com.',
      arabic:
          'يُحدَّث يومياً — ليس عرضاً مباشراً من المزود. INR/PHP عبر ECB؛ NPR/BDT/PKR عبر open.er-api.com.',
      hindi:
          'Updated daily — not a live provider quote. INR/PHP via ECB (Frankfurter); NPR/BDT/PKR via open.er-api.com.',
      urdu:
          'Updated daily — not a live provider quote. INR/PHP via ECB (Frankfurter); NPR/BDT/PKR via open.er-api.com.',
      bengali:
          'Updated daily — not a live provider quote. INR/PHP via ECB (Frankfurter); NPR/BDT/PKR via open.er-api.com.',
      filipino:
          'Updated daily — not a live provider quote. INR/PHP via ECB (Frankfurter); NPR/BDT/PKR via open.er-api.com.',
    ),
    'rte_headline_prefix': l10nEntry(
      english: '~',
      arabic: '~',
      hindi: '~',
      urdu: '~',
      bengali: '~',
      filipino: '~',
    ),
    'rte_headline_provider': l10nEntry(
      english: 'Hidden markup with {provider}',
      arabic: 'هامش مخفي مع {provider}',
      hindi: '{provider} के साथ छिपा हुआ मार्जिन',
      urdu: '{provider} کے ساتھ پوشیدہ مارجن',
      bengali: '{provider}-এ লুকানো মার্জিন',
      filipino: 'Hidden markup sa {provider}',
    ),
    'rte_headline_sub': l10nEntry(
      english:
          'Approx. hidden FX spread on your amount (+ {fee} QAR disclosed fee)',
      arabic:
          'تقريباً فرق سعر الصرف المخفي على مبلغك (+ {fee} QAR رسوم معلنة)',
      hindi:
          'Approx. hidden FX spread on your amount (+ {fee} QAR disclosed fee)',
      urdu:
          'Approx. hidden FX spread on your amount (+ {fee} QAR disclosed fee)',
      bengali:
          'Approx. hidden FX spread on your amount (+ {fee} QAR disclosed fee)',
      filipino:
          'Approx. hidden FX spread on your amount (+ {fee} QAR disclosed fee)',
    ),
    'rte_savings_vs_worst': l10nEntry(
      english:
          'Using {best} instead of {worst} could save ~{amount} QAR on this transfer',
      arabic:
          'استخدام {best} بدلاً من {worst} قد يوفر ~{amount} QAR على هذا التحويل',
      hindi:
          'Using {best} instead of {worst} could save ~{amount} QAR on this transfer',
      urdu:
          'Using {best} instead of {worst} could save ~{amount} QAR on this transfer',
      bengali:
          'Using {best} instead of {worst} could save ~{amount} QAR on this transfer',
      filipino:
          'Using {best} instead of {worst} could save ~{amount} QAR on this transfer',
    ),
    'rte_ranked_providers': l10nEntry(
      english: 'Ranked by recipient gets',
      arabic: 'مرتبة حسب ما يستلمه المستفيد',
      hindi: 'प्राप्त राशि के अनुसार क्रम',
      urdu: 'وصول کنندہ کی رقم کے لحاظ سے درجہ',
      bengali: 'প্রাপক পাবেন অনুযায়ী র‍্যাঙ্ক',
      filipino: 'Ranked by recipient gets',
    ),
    'rte_label_rpw': l10nEntry(
      english: 'World Bank RPW',
      arabic: 'البنك الدولي RPW',
      hindi: 'World Bank RPW',
      urdu: 'World Bank RPW',
      bengali: 'World Bank RPW',
      filipino: 'World Bank RPW',
    ),
    'rte_label_curated': l10nEntry(
      english: 'Raabta-curated',
      arabic: 'منسّق من Raabta',
      hindi: 'Raabta-curated',
      urdu: 'Raabta-curated',
      bengali: 'Raabta-curated',
      filipino: 'Raabta-curated',
    ),
    'rte_recipient_gets': l10nEntry(
      english: 'Recipient gets ~',
      arabic: 'المستفيد يستلم ~',
      hindi: 'प्राप्तकर्ता को ~',
      urdu: 'وصول کنندہ کو ~',
      bengali: 'প্রাপক পাবেন ~',
      filipino: 'Makakatanggap ng ~',
    ),
    'rte_provider_stats': l10nEntry(
      english:
          'Rate {effective} · Fee {fee} QAR · Hidden ~{markup} QAR · Total ~{total_pct}%',
      arabic:
          'سعر {effective} · رسوم {fee} QAR · مخفي ~{markup} QAR · إجمالي ~{total_pct}%',
      hindi:
          'Rate {effective} · Fee {fee} QAR · Hidden ~{markup} QAR · Total ~{total_pct}%',
      urdu:
          'Rate {effective} · Fee {fee} QAR · Hidden ~{markup} QAR · Total ~{total_pct}%',
      bengali:
          'Rate {effective} · Fee {fee} QAR · Hidden ~{markup} QAR · Total ~{total_pct}%',
      filipino:
          'Rate {effective} · Fee {fee} QAR · Hidden ~{markup} QAR · Total ~{total_pct}%',
    ),
    'rte_data_as_of': l10nEntry(
      english: 'Provider data as of {period}',
      arabic: 'بيانات المزود بتاريخ {period}',
      hindi: 'Provider data as of {period}',
      urdu: 'Provider data as of {period}',
      bengali: 'Provider data as of {period}',
      filipino: 'Provider data as of {period}',
    ),
    'rte_go_to_provider': l10nEntry(
      english: 'Go to {provider}',
      arabic: 'انتقل إلى {provider}',
      hindi: '{provider} पर जाएँ',
      urdu: '{provider} پر جائیں',
      bengali: '{provider}-এ যান',
      filipino: 'Pumunta sa {provider}',
    ),
    'rte_no_mid_market': l10nEntry(
      english: 'Mid-market baseline not available yet',
      arabic: 'سعر السوق المرجعي غير متاح بعد',
      hindi: 'Mid-market baseline not available yet',
      urdu: 'Mid-market baseline not available yet',
      bengali: 'Mid-market baseline not available yet',
      filipino: 'Mid-market baseline not available yet',
    ),
    'rte_no_providers': l10nEntry(
      english: 'No provider data for this corridor yet',
      arabic: 'لا توجد بيانات مزود لهذا الممر بعد',
      hindi: 'No provider data for this corridor yet',
      urdu: 'No provider data for this corridor yet',
      bengali: 'No provider data for this corridor yet',
      filipino: 'No provider data for this corridor yet',
    ),
    'rte_community_section': l10nEntry(
      english: 'Community transfer reports',
      arabic: 'تقارير تحويل المجتمع',
      hindi: 'Community transfer reports',
      urdu: 'Community transfer reports',
      bengali: 'Community transfer reports',
      filipino: 'Community transfer reports',
    ),
    'rte_disclaimer': l10nEntry(
      english:
          'Computed from mid-market baseline + World Bank RPW or Raabta-curated provider data. '
          'Raabta does not move money — confirm rates with the provider before sending.',
      arabic:
          'محسوب من سعر السوق المرجعي + بيانات RPW أو Raabta. Raabta لا تنقل الأموال — تأكد من المزود.',
      hindi:
          'Computed from mid-market baseline + World Bank RPW or Raabta-curated provider data. '
          'Raabta does not move money — confirm rates with the provider before sending.',
      urdu:
          'Computed from mid-market baseline + World Bank RPW or Raabta-curated provider data. '
          'Raabta does not move money — confirm rates with the provider before sending.',
      bengali:
          'Computed from mid-market baseline + World Bank RPW or Raabta-curated provider data. '
          'Raabta does not move money — confirm rates with the provider before sending.',
      filipino:
          'Computed from mid-market baseline + World Bank RPW or Raabta-curated provider data. '
          'Raabta does not move money — confirm rates with the provider before sending.',
    ),
  };
}
