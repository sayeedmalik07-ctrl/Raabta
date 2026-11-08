import 'package:raabta/core/l10n/app_locale.dart';

/// Family Verification Kit — recipient-facing share locales use [shareLocales].
abstract final class FamilyVerificationKitStrings {
  static const shareLocales = AppLocale.supportedLocales;

  /// Locales using English/Hindi fallback text — fluent review before release.
  static const needsFluentReview = [
    'Urdu',
    'Malayalam',
    'Nepali',
    'Bengali',
    'Filipino',
    'Tamil',
  ];

  static String t(String key, [String locale = 'English']) {
    final map = _catalog[key];
    if (map == null) return key;
    return map[locale] ?? map['English'] ?? key;
  }

  /// Practice flow progress, e.g. "Step 2 of 4" — placeholders `{n}` and `{m}`.
  static String scenarioProgressLine(String locale, int step, int total) {
    final template = t('ss_fvk_scenario_progress_template', locale);
    return template
        .replaceAll('{n}', '$step')
        .replaceAll('{m}', '$total');
  }

  static final _catalog = <String, Map<String, String>>{
    'ss_fvk_hub_title': _f(
      en: 'Protect your family',
      ar: 'احمِ عائلتك',
      hi: 'अपने परिवार की रक्षा करें',
    ),
    'ss_fvk_hub_sub': _f(
      en: 'Secret word + call-back habit for urgent money scams',
      ar: 'كلمة سرية وعادة معاودة الاتصال',
      hi: 'गुप्त शब्द और कॉल-बैक की आदत',
    ),
    'ss_fvk_title': _f(
      en: 'Protect your family',
      ar: 'احمِ عائلتك',
      hi: 'अपने परिवार की रक्षा',
    ),
    /// Hub subscreen subtitle ([HubSubscreenScaffold]) — 9 locales.
    'ss_fvk_kit_subtitle': _f(
      en:
          'Secret word + call-back habits. Preferences save on this device only.',
      ar:
          'كلمة سرية وعادة معاودة الاتصال. تُحفظ التفضيلات على هذا الجهاز فقط.',
      hi:
          'गुप्त शब्द + कॉल-बैक आदतें। प्राथमिकताएँ केवल इस डिवाइस पर सहेजी जाती हैं।',
      ur:
          'خفیہ لفظ + واپس کال کی عادتیں۔ ترجیحات صرف اس ڈیوائس پر محفوظ ہوتی ہیں۔',
      ml:
          'രഹസ്യ വാക്ക് + കോൾബാക്ക് ശീലങ്ങൾ. മുൻഗണനകൾ ഈ ഡിവൈസിൽ മാത്രം സേവ് ചെയ്യുന്നു.',
      ne:
          'गोप्य शब्द + कलब्याक बानी। प्राथमिकताहरू यस डिभाइसमा मात्र बचत हुन्छ।',
      bn:
          'গোপন শব্দ + কল-ব্যাক অভ্যাস। পছন্দগুলো শুধু এই ডিভাইসে সংরক্ষিত হয়।',
      ta:
          'ரகசிய சொல் + கால்பேக் பழக்கங்கள். விருப்பங்கள் இந்த சாதனத்தில் மட்டும் சேமிக்கப்படும்.',
      fil:
          'Lihim na salita + call-back na gawi. Ang mga preperensya ay naka-save lang sa device na ito.',
    ),
    'ss_fvk_prefs_load_error_title': _f(
      en: 'Could not load settings',
      ar: 'تعذّر تحميل الإعدادات',
      hi: 'सेटिंग लोड नहीं हो सकीं',
      ur: 'ترتیبات لوڈ نہیں ہو سکیں',
      ml: 'ക്രമീകരണങ്ങൾ ലോഡ് ചെയ്യാനായില്ല',
      ne: 'सेटिङहरू लोड गर्न सकिएन',
      bn: 'সেটিংস লোড করা যায়নি',
      ta: 'அமைப்புகளை ஏற்ற முடியவில்லை',
      fil: 'Hindi ma-load ang mga setting',
    ),
    'ss_fvk_prefs_load_error_body': _f(
      en:
          'Check your connection and try again. Your saved hints and contacts on this device are not affected.',
      ar:
          'تحقق من الاتصال وحاول مجدداً. التلميحات والأرقام المحفوظة على هذا الجهاز لا تتأثر.',
      hi:
          'कनेक्शन जाँचें और पुनः कोशिश करें। इस डिवाइस पर सेव संकेत व संपर्क सुरक्षित हैं।',
      ur:
          'کنیکشن چیک کریں اور دوبارہ کوشش کریں۔ اس ڈیوائس پر محفوظ اشارے و رابطے محفوظ ہیں۔',
      ml:
          'കണക്ഷൻ പരിശോധിച്ച് വീണ്ടും ശ്രമിക്കുക. ഈ ഉപകരണത്തിലെ സൂചനകളും സമ്പർക്കങ്ങളും സുരക്ഷിതമാണ്.',
      ne:
          'जडान जाँच गरी फेरि प्रयास गर्नुहोस्। यस डिभाइसमा बचत संकेत र सम्पर्क सुरक्षित छन्।',
      bn:
          'সংযোগ পরীক্ষা করে আবার চেষ্টা করুন। এই ডিভাইসে সংরক্ষিত সূচক ও পরিচিতি অক্ষত।',
      ta:
          'இணைப்பைச் சரிபார்த்து மீண்டும் முயலவும். இந்த சாதனத்தில் சேமித்த குறிப்புகளும் தொடர்புகளும் பாதுகாப்பானவை.',
      fil:
          'Suriin ang koneksyon at subukan muli. Ang naka-save na hint at contacts sa device na ito ay ligtas.',
    ),
    'ss_fvk_prefs_retry': _f(
      en: 'Retry',
      ar: 'إعادة المحاولة',
      hi: 'पुनः प्रयास',
      ur: 'دوبارہ کوشش',
      ml: 'വീണ്ടും ശ്രമിക്കുക',
      ne: 'पुनः प्रयास',
      bn: 'আবার চেষ্টা',
      ta: 'மீண்டும் முயலவும்',
      fil: 'Subukan muli',
    ),
    'ss_fvk_disclaimer': _f(
      en:
          'This can lower risk — it does not guarantee safety. Raabta never stores your secret word.',
      ar: 'قد يقلل المخاطر — لا يضمن الأمان. رابطتا لا تحفظ كلمتك السرية.',
      hi: 'यह जोखिम कम कर सकता है — सुरक्षा की गारंटी नहीं। Raabta गुप्त शब्द नहीं रखता।',
    ),
    /// Hub section chrome — nine locales.
    'ss_fvk_kit_hero_badge': _f(
      en: 'Scam Shield',
      ar: 'درع الاحتيال',
      hi: 'स्कैम शील्ड',
      ur: 'اسکیم شیلڈ',
      ml: 'സ്കാം ഷീൽഡ്',
      ne: 'स्क्याम शिल्ड',
      bn: 'স্ক্যাম শিল্ড',
      ta: 'மோசடி கவசம்',
      fil: 'Kalasag sa scam',
    ),
    'ss_fvk_kit_section_steps': _f(
      en: 'Safety steps',
      ar: 'خطوات السلامة',
      hi: 'सुरक्षा कदम',
      ur: 'حفاظتی اقدامات',
      ml: 'സുരക്ഷാ ഘട്ടങ്ങൾ',
      ne: 'सुरक्षा चरणहरू',
      bn: 'নিরাপত্তার ধাপ',
      ta: 'பாதுகாப்பு கட்டங்கள்',
      fil: 'Mga hakbang sa kaligtasan',
    ),
    'ss_fvk_kit_section_device': _f(
      en: 'On this device',
      ar: 'على هذا الجهاز',
      hi: 'इस डिवाइस पर',
      ur: 'اس ڈیوائس پر',
      ml: 'ഈ ഡിവൈസിൽ',
      ne: 'यस डिभाइसमा',
      bn: 'এই ডিভাইসে',
      ta: 'இந்த சாதனத்தில்',
      fil: 'Sa device na ito',
    ),
    'ss_fvk_kit_section_family_actions': _f(
      en: 'Share & practice',
      ar: 'مشاركة وتمرين',
      hi: 'साझा करें और अभ्यास',
      ur: 'شیئر اور مشق',
      ml: 'പങ്കിടുകയും പരിശീലിക്കുകയും',
      ne: 'साझा र अभ्यास',
      bn: 'শেয়ার ও অনুশীলন',
      ta: 'பகிர்ந்து பயிற்சி',
      fil: 'I-share at magsanay',
    ),
    'ss_fvk_share_section_language': _f(
      en: 'Family message language',
      ar: 'لغة رسالة العائلة',
      hi: 'परिवार संदेश की भाषा',
      ur: 'خاندانی پیغام کی زبان',
      ml: 'കുടുംബ സന്ദേശ ഭാഷ',
      ne: 'परिवार सन्देश भाषा',
      bn: 'পরিবারের বার্তার ভাষা',
      ta: 'குடும்பச் செய்தி மொழி',
      fil: 'Wika ng mensahe sa pamilya',
    ),
    'ss_fvk_share_section_preview': _f(
      en: 'Message they will receive',
      ar: 'الرسالة التي سيستلمها',
      hi: 'वह संदेश जो उन्हें मिलेगा',
      ur: 'وہ پیغام جو انہیں ملے گا',
      ml: 'അവർക്ക് ലഭിക്കുന്ന സന്ദേശം',
      ne: 'उनीहरूले पाउने सन्देश',
      bn: 'তারা যা বার্তা পাবে',
      ta: 'அவர்கள் பெறும் செய்தி',
      fil: 'Mensaheng matatanggap nila',
    ),
    'ss_fvk_share_preview_rules_heading': _f(
      en: 'Three rules',
      ar: 'ثلاث قواعد',
      hi: 'तीन नियम',
      ur: 'تین اصول',
      ml: 'മൂന്ന് നിയമങ്ങൾ',
      ne: 'तीन नियमहरू',
      bn: 'তিনটি নিয়ম',
      ta: 'மூன்று விதிகள்',
      fil: 'Tatlong patakaran',
    ),
    'ss_fvk_scenario_section_situation': _f(
      en: 'Scenario',
      ar: 'السيناريو',
      hi: 'परिदृश्य',
      ur: 'منظرنامہ',
      ml: 'പരിധി',
      ne: 'परिदृश्य',
      bn: 'দৃশ্য',
      ta: 'காட்சி',
      fil: 'Senaryo',
    ),
    'ss_fvk_scenario_section_choices': _f(
      en: 'Choose a response',
      ar: 'اختر رداً',
      hi: 'जवाब चुनें',
      ur: 'ایک جواب منتخب کریں',
      ml: 'ഒരു പ്രതികരണം തിരഞ്ഞെടുക്കുക',
      ne: 'प्रतिक्रिया छान्नुहोस्',
      bn: 'একটি প্রতিক্রিয়া বেছে নিন',
      ta: 'ஒரு பதிலைத் தேர்ந்தெடுக்கவும்',
      fil: 'Pumili ng tugon',
    ),
    'ss_fvk_scenario_section_feedback': _f(
      en: 'Feedback',
      ar: 'ملاحظات',
      hi: 'प्रतिक्रिया',
      ur: 'رائے',
      ml: 'പ്രതികരണം',
      ne: 'प्रतिक्रिया',
      bn: 'প্রতিক্রিয়া',
      ta: 'கருத்து',
      fil: 'Puna',
    ),
    'ss_fvk_scenario_section_emergency': _f(
      en: 'If money is already gone',
      ar: 'إذا ذهب المال',
      hi: 'अगर पैसा जा चुका है',
      ur: 'اگر رقم جا چکی ہے',
      ml: 'പണം നഷ്ടമായെങ്കിൽ',
      ne: 'पैसा गइसकेमा',
      bn: 'টাকা চলে গেলে',
      ta: 'பணம் போய்விட்டால்',
      fil: 'Kung nawala na ang pera',
    ),
    'ss_fvk_scenario_progress_template': _f(
      en: 'Step {n} of {m}',
      ar: 'الخطوة {n} من {m}',
      hi: 'चरण {n} / {m}',
      ur: 'قدم {n} از {m}',
      ml: 'ഘട്ടം {n} / {m}',
      ne: 'चरण {n} / {m}',
      bn: 'ধাপ {n} / {m}',
      ta: 'படி {n} / {m}',
      fil: 'Hakbang {n} ng {m}',
    ),
    'ss_fvk_step1_title': _f(
      en: 'Agree a secret word in person',
      ar: 'اتفقوا على كلمة سرية حضورياً',
      hi: 'सामने मिलकर गुप्त शब्द तय करें',
    ),
    'ss_fvk_step1_body': _f(
      en:
          'Pick a word or question with each close relative on a live call or in person — never by text or chat. Choose something a stranger or cloned voice could not guess or find online. Change it if it was ever typed in a chat.',
      ar: 'اختاروا كلمة أو سؤالاً مع كل قريب مباشرة — لا عبر الدردشة. غيّروها إن كُتبت في محادثة.',
      hi: 'हर करीबी रिश्तेदार के साथ सीधे बात या मिलकर शब्द/सवाल तय करें — चैट में नहीं। अगर चैट में लिखा हो तो बदलें।',
    ),
    'ss_fvk_step2_title': _f(
      en: 'Three rules for urgent money calls',
      ar: 'ثلاث قواعد لمكالمات المال العاجلة',
      hi: 'जरूरी पैसे की कॉल के तीन नियम',
    ),
    'ss_fvk_step2_rule1': _f(
      en: 'Stop — do not rush.',
      ar: 'توقّف — لا تتسرع.',
      hi: 'रुकें — जल्दबाजी न करें।',
    ),
    'ss_fvk_step2_rule2': _f(
      en: 'Hang up and call back on the number you already saved.',
      ar: 'أنهِ المكالمة واتصل بالرقم المحفوظ.',
      hi: 'फोन काटें और सेव किए नंबर पर वापस कॉल करें।',
    ),
    'ss_fvk_step2_rule3': _f(
      en: 'Ask for the secret word. Never send money because of pressure or secrecy.',
      ar: 'اطلب الكلمة السرية. لا ترسل مالاً بسبب ضغط أو سرية.',
      hi: 'गुप्त शब्द पूछें। दबाव या गोपनीयता में पैसा न भेजें।',
    ),
    'ss_fvk_step3_title': _f(
      en: 'Tell them the scam exists',
      ar: 'أخبرهم أن هذا الاحتيال موجود',
      hi: 'उन्हें बताएं कि यह घोटाला होता है',
    ),
    'ss_fvk_step3_body': _f(
      en:
          'Voices can be copied from short clips online, and caller ID can be faked. A real relative will understand if you hang up and call back.',
      ar: 'يمكن تقليد الأصوات وتزوير الرقم. قريب حقيقي سيفهم إن أعدت الاتصال.',
      hi: 'आवाज़ छोटे क्लिप से नकली हो सकती है और नंबर भी। असली रिश्तेदार कॉल-बैक समझेंगे।',
    ),
    'ss_fvk_step4_title': _f(
      en: 'Rehearse once or twice a year',
      ar: 'تدرّبوا مرة أو مرتين سنوياً',
      hi: 'साल में एक-दो बार अभ्यास करें',
    ),
    'ss_fvk_step4_body': _f(
      en: 'Walk through the three rules together so everyone remembers under stress.',
      ar: 'راجعوا القواعد معاً حتى تتذكرها العائلة تحت الضغط.',
      hi: 'तीनों नियम साथ दोहराएं ताकि तनाव में याद रहे।',
    ),
    'ss_fvk_hint_label': _f(
      en: 'Optional memory hint (not the word)',
      ar: 'تلميح اختياري (ليس الكلمة)',
      hi: 'वैकल्पिक संकेत (शब्द नहीं)',
    ),
    'ss_fvk_hint_help': _f(
      en: 'Example: where you agreed it — never the word itself.',
      ar: 'مثال: أين اتفقتما — ليس الكلمة.',
      hi: 'उदाहरण: कहाँ तय किया — शब्द नहीं।',
    ),
    'ss_fvk_hint_save': _f(
      en: 'Save hint on this device only',
      ar: 'احفظ التلميح على هذا الجهاز فقط',
      hi: 'संकेत केवल इस फोन पर सहेजें',
    ),
    'ss_fvk_hint_cleared': _f(
      en: 'Hint removed from this device',
      ar: 'تم حذف التلميح',
      hi: 'संकेत हटाया गया',
    ),
    'ss_fvk_contacts_toggle': _f(
      en: 'Save known numbers on this device (optional)',
      ar: 'حفظ أرقام معروفة على الجهاز (اختياري)',
      hi: 'ज्ञात नंबर इस फोन पर (वैकल्पिक)',
    ),
    'ss_fvk_contacts_help': _f(
      en: 'For your eyes only — never shared or synced.',
      ar: 'لعينيك فقط — لا مشاركة ولا مزامنة.',
      hi: 'केवल आपके लिए — साझा/सिंक नहीं।',
    ),
    'ss_fvk_contact_name': _f(en: 'Name', ar: 'الاسم', hi: 'नाम'),
    'ss_fvk_contact_phone': _f(en: 'Phone number', ar: 'رقم الهاتف', hi: 'फ़ोन'),
    'ss_fvk_contact_add': _f(en: 'Add contact', ar: 'إضافة', hi: 'जोड़ें'),
    'ss_fvk_contacts_delete_all': _f(
      en: 'Delete all saved numbers',
      ar: 'حذف كل الأرقام',
      hi: 'सभी नंबर हटाएं',
    ),
    'ss_fvk_reminder_toggle': _f(
      en: 'Remind me every 6 months (local only)',
      ar: 'ذكّرني كل 6 أشهر (محلي فقط)',
      hi: 'हर 6 महीने याद दिलाएं (स्थानीय)',
    ),
    'ss_fvk_reminder_title': _f(
      en: 'Family verification check',
      ar: 'فحص التحقق العائلي',
      hi: 'परिवार सत्यापन',
    ),
    'ss_fvk_reminder_body': _f(
      en: 'Quick family check: do you still remember your secret word?',
      ar: 'تحقق عائلي: هل ما زلت تتذكر كلمتكم السرية؟',
      hi: 'परिवार जांच: क्या आपको गुप्त शब्द याद है?',
    ),
    'ss_fvk_share_entry': _f(
      en: 'Share explainer for family',
      ar: 'مشاركة شرح للعائلة',
      hi: 'परिवार के लिए जानकारी साझा करें',
    ),
    'ss_fvk_practice_entry': _f(
      en: 'Practice scenario',
      ar: 'سيناريو تدريبي',
      hi: 'अभ्यास परिदृश्य',
    ),
    'ss_fvk_share_screen_title': _f(
      en: 'Share with family',
      ar: 'شارك مع العائلة',
      hi: 'परिवार के साथ साझा करें',
      ur: 'خاندان کے ساتھ شیئر کریں',
      ml: 'കുടുംബത്തോട് പങ്കിടുക',
      ne: 'परिवारसँग साझा गर्नुहोस्',
      bn: 'পরিবারের সাথে শেয়ার করুন',
      ta: 'குடும்பத்துடன் பகிரவும்',
      fil: 'Ibahagi sa pamilya',
    ),
    'ss_fvk_share_subtitle': _f(
      en:
          'Preview the message — then share via your usual app (e.g. WhatsApp).',
      ar:
          'عرض الرسالة — ثم شارك عبر تطبيقك المعتاد (مثل واتساب).',
      hi:
          'संदेश का पूर्वावलोकन — फिर अपने सामान्य ऐप से साझा करें (जैसे WhatsApp)।',
      ur:
          'پەیام کا پیش منظر — پھر اپنے معمول کے ایپ سے شیئر کریں (مثلاً WhatsApp)۔',
      ml:
          'സന്ദേശം പ്രിവ്യൂ ചെയ്യുക — തുടർന്ന് നിങ്ങളുടെ പതിവ് ആപ്പ് വഴി പങ്കിടുക (ഉദാ. WhatsApp).',
      ne:
          'सन्देश पूर्वावलोकन — अनि आफ्नो सामान्य एपबाट साझा गर्नुहोस् (जस्तै WhatsApp)।',
      bn:
          'বার্তা প্রিভিউ করুন — তারপর আপনার নিয়মিত অ্যাপ দিয়ে শেয়ার করুন (যেমন WhatsApp)।',
      ta:
          'செய்தியை முன்னோட்டம் — பிறகு உங்கள் வழக்கமான பயன்பாட்டில் பகிரவும் (எ.கா. WhatsApp).',
      fil:
          'I-preview ang mensahe — pagkatapos i-share sa karaniwan mong app (hal. WhatsApp).',
    ),
    'ss_fvk_share_picker_label': _f(
      en: 'Language your family will read',
      ar: 'لغة قراءة العائلة',
      hi: 'परिवार किस भाषा में पढ़ेगा',
      ur: 'آپ کا خاندان کس زبان میں پڑھے گا',
      ml: 'നിങ്ങളുടെ കുടുംബം ഏത് ഭാഷയിൽ വായിക്കും',
      ne: 'तपाईंको परिवार कुन भाषामा पढ्छ',
      bn: 'আপনার পরিবার কোন ভাষায় পড়বে',
      ta: 'உங்கள் குடும்பம் எந்த மொழியில் வாசிக்கும்',
      fil: 'Anong wika babasahin ng iyong pamilya',
    ),
    'ss_fvk_share_cta': _f(
      en: 'Share via WhatsApp or messages',
      ar: 'شارك عبر واتساب أو رسائل',
      hi: 'WhatsApp/संदेश से साझा करें',
      ur: 'WhatsApp یا پیغامات سے شیئر کریں',
      ml: 'WhatsApp അല്ലെങ്കിൽ സന്ദേശങ്ങളിലൂടെ പങ്കിടുക',
      ne: 'WhatsApp वा सन्देशबाट साझा गर्नुहोस्',
      bn: 'WhatsApp বা বার্তা দিয়ে শেয়ার করুন',
      ta: 'WhatsApp அல்லது செய்திகள் வழி பகிரவும்',
      fil: 'I-share sa WhatsApp o mensahe',
    ),
    'ss_fvk_share_title': _f(
      en: 'If someone calls saying it is family and money is urgent',
      ar: 'إن اتصل أحد زاعياً أنه عائلة والمال عاجل',
      hi: 'अगर कोई कहे परिवार है और पैसा जरूरी है',
    ),
    'ss_fvk_share_intro': _f(
      en:
          'Scammers can copy voices and fake phone numbers. We agreed on a private word — use it before sending money.',
      ar: 'يمكن تقليد الصوت وتزوير الرقم. اتفقنا على كلمة خاصة — استخدموها قبل إرسال المال.',
      hi: 'आवाज़ और नंबर नकली हो सकते हैं। हमने निजी शब्द तय किया — पैसा भेजने से पहले पूछें।',
    ),
    'ss_fvk_share_rule1': _f(
      en: 'Stop and breathe — do not rush.',
      ar: 'توقّف — لا تتسرع.',
      hi: 'रुकें — जल्दबाजी न करें।',
    ),
    'ss_fvk_share_rule2': _f(
      en: 'Hang up and call our saved number.',
      ar: 'أنهِ واتصل برقمنا المحفوظ.',
      hi: 'काटें और सेव नंबर पर कॉल करें।',
    ),
    'ss_fvk_share_rule3': _f(
      en: 'Ask for our secret word before any transfer.',
      ar: 'اطلب كلمتنا السرية قبل أي تحويل.',
      hi: 'ट्रांसफर से पहले गुप्त शब्द पूछें।',
    ),
    'ss_fvk_share_footer': _f(
      en: 'Sent from Raabta Scam Shield — information only, not a guarantee.',
      ar: 'من Raabta — للمعلومات فقط.',
      hi: 'Raabta Scam Shield — केवल जानकारी।',
    ),
    'ss_fvk_scenario_title': _f(
      en: 'Practice: urgent call',
      ar: 'تدريب: مكالمة عاجلة',
      hi: 'अभ्यास: जरूरी कॉल',
      ur: 'مشق: فوری کال',
      ml: 'പരിശീലനം: അടിയന്തര കോൾ',
      ne: 'अभ्यास: जरुरी कल',
      bn: 'অনুশীলন: জরুরি কল',
      ta: 'பயிற்சி: அவசர அழைப்பு',
      fil: 'Pagsasanay: mabilis na tawag',
    ),
    'ss_fvk_scenario_subtitle': _f(
      en:
          'Tap choices — feedback is local only. No money moves through Raabta.',
      ar:
          'اضغط الخيارات — التلميح محلي فقط. لا يتحرك المال عبر Raabta.',
      hi:
          'विकल्प चुनें — प्रतिक्रिया केवल डिवाइस पर। Raabta से पैसा नहीं जाता।',
      ur:
          'اختیارات دبائیں — ردعمل صرف ڈیوائس پر۔ Raabta سے پیسہ نہیں جاتا۔',
      ml:
          'ഓപ്ഷനുകൾ ടാപ്പ് ചെയ്യുക — പ്രതികരണം ഡിവൈസിൽ മാത്രം. Raabta വഴി പണമില്ല.',
      ne:
          'विकल्प छान्नुहोस् — प्रतिक्रिया यसै डिभाइसमा। Raabta बाट पैसा जाँदैन।',
      bn:
          'বিকল্পে টোকা দিন — প্রতিক্রিয়া শুধু ডিভাইসে। Raabta দিয়ে টাকা যায় না।',
      ta:
          'விருப்பங்களை தட்டவும் — கருத்து இச்சாதனத்தில் மட்டும். Raabta வழி பணம் இல்லை.',
      fil:
          'Tapikin ang mga opsyon — puna lang sa device. Walang pera sa Raabta.',
    ),
    'ss_fvk_scenario_start': _f(
      en:
          'You get a call: "It is your brother — I had an accident, send money now, do not tell anyone."',
      ar: 'مكالمة: "أنا أخوك — حادث، أرسل مالاً الآن، لا تخبر أحداً."',
      hi: 'कॉल: "मैं तुम्हारा भाई — दुर्घटना, अभी पैसा भेजो, किसी को मत बताना।"',
    ),
    'ss_fvk_scenario_choice_send': _f(
      en: 'Send money immediately',
      ar: 'أرسل المال فوراً',
      hi: 'तुरंत पैसा भेजें',
    ),
    'ss_fvk_scenario_choice_stay': _f(
      en: 'Stay on the line and ask details',
      ar: 'ابق على الخط واسأل',
      hi: 'लाइन पर रहें और पूछें',
    ),
    'ss_fvk_scenario_choice_hangup': _f(
      en: 'Hang up',
      ar: 'أنهِ المكالمة',
      hi: 'फोन काटें',
    ),
    'ss_fvk_scenario_after_hangup': _f(
      en: 'Good pause. What next?',
      ar: 'توقف جيد. ماذا بعد؟',
      hi: 'अच्छा रुकाव। आगे?',
    ),
    'ss_fvk_scenario_choice_text': _f(
      en: 'Text back on the same thread',
      ar: 'رد على نفس المحادثة',
      hi: 'उसी चैट में जवाब दें',
    ),
    'ss_fvk_scenario_choice_call_known': _f(
      en: 'Call back on the number I already know',
      ar: 'اتصل بالرقم المعروف',
      hi: 'ज्ञात नंबर पर वापस कॉल',
    ),
    'ss_fvk_scenario_after_callback': _f(
      en: 'You reach your brother on the real number. He says he never called.',
      ar: 'تصل بأخيك على الرقم الحقيقي. يقول إنه لم يتصل.',
      hi: 'असली नंबर पर भाई से बात। उसने कॉल नहीं की।',
    ),
    'ss_fvk_scenario_choice_skip_word': _f(
      en: 'Skip the word — send anyway to be safe',
      ar: 'تخطّ الكلمة — أرسل',
      hi: 'शब्द छोड़ें — भेज दें',
    ),
    'ss_fvk_scenario_choice_ask_word': _f(
      en: 'Ask for our secret word next time before sending',
      ar: 'اطلب الكلمة السرية قبل الإرسال',
      hi: 'भेजने से पहले गुप्त शब्द पूछें',
    ),
    'ss_fvk_scenario_complete': _f(
      en:
          'That is the habit: hang up, call back on a known number, ask for the word. It lowers risk — it is not a guarantee.',
      ar: 'هذه العادة: أنهِ، اتصل بالرقم المعروف، اطلب الكلمة. يقلل المخاطر — ليس ضماناً.',
      hi: 'यही आदत: काटें, ज्ञात नंबर पर कॉल, शब्द पूछें। जोखिम कम — गारंटी नहीं।',
    ),
    'ss_fvk_scenario_restart': _f(
      en: 'Restart practice',
      ar: 'إعادة التمرين',
      hi: 'Restart practice',
    ),
    'ss_fvk_scenario_feedback_good': _f(
      en: 'Yes — that matches the plan.',
      ar: 'نعم — هذه هي الخطة.',
      hi: 'हाँ — यही योजना है।',
    ),
    'ss_fvk_scenario_feedback_send': _f(
      en: 'Pressure to send fast is a common scam sign. Hang up first.',
      ar: 'الضغط للإرسال سريعاً علامة احتيال. أنهِ أولاً.',
      hi: 'जल्दी भेजने का दबाव घोटाले का संकेत है। पहले काटें।',
    ),
    'ss_fvk_scenario_feedback_stay': _f(
      en: 'Cloned voices can keep you talking. Hang up and call back yourself.',
      ar: 'الصوت المقلد يبقيك على الخط. أنهِ واتصل بنفسك.',
      hi: 'नकली आवाज़ बात जारी रख सकती है। काटकर खुद कॉल करें।',
    ),
    'ss_fvk_scenario_feedback_text': _f(
      en: 'Use a number you already saved — not the one that just called.',
      ar: 'استخدم رقماً محفوظاً — ليس المتصل للتو.',
      hi: 'सेव किया नंबर उपयोग करें — अभी वाला नहीं।',
    ),
    'ss_fvk_scenario_feedback_skip': _f(
      en: 'The word is the check. Without it, pause any transfer.',
      ar: 'الكلمة هي التحقق. بدونها، أوقف التحويل.',
      hi: 'शब्द ही जांच है। बिना इसके ट्रांसफर रोकें।',
    ),
    'ss_fvk_scenario_feedback_generic': _f(
      en: 'Try the hang-up and call-back path.',
      ar: 'جرّب الإنهاء ومعاودة الاتصال.',
      hi: 'काटें और कॉल-बैक आज़माएं।',
    ),
    'ss_fvk_corridor_link': _f(
      en: 'Family emergency call? See the verification kit',
      ar: 'مكالمة طوارئ عائلية؟ راجع دليل التحقق',
      hi: 'परिवार की जरूरी कॉल? सत्यापन किट देखें',
    ),
    'ss_fvk_academy_link': _f(
      en: 'Practice: fake family emergency call',
      ar: 'تدريب: مكالمة طوارئ مزيفة',
      hi: 'अभ्यास: नकली परिवारी आपात कॉल',
    ),
  };
}

Map<String, String> _f({
  required String en,
  required String ar,
  required String hi,
  String? ur,
  String? ml,
  String? ne,
  String? bn,
  String? ta,
  String? fil,
}) {
  return {
    'English': en,
    'Arabic': ar,
    'Hindi': hi,
    'Urdu': ur ?? hi,
    'Malayalam': ml ?? en,
    'Nepali': ne ?? en,
    'Bengali': bn ?? hi,
    'Tamil': ta ?? en,
    'Filipino': fil ?? en,
  };
}
