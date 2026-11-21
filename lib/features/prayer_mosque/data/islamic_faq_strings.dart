import 'package:flutter/foundation.dart';
import 'package:raabta/core/l10n/app_locale.dart';
import 'package:raabta/core/l10n/locale_catalog_coverage.dart';

/// Localized static FAQ answers for Islamic Q&A (8 app languages incl. Filipino).
abstract final class IslamicFaqStrings {
  static const supportedLocales = [
    'English',
    'Arabic',
    'Urdu',
    'Hindi',
    'Malayalam',
    'Nepali',
    'Bengali',
    'Filipino',
  ];

  static String t(String key, [String locale = 'English']) {
    final normalized = AppLocale.normalize(locale);
    final map = _catalog[key];
    if (map == null) return key;
    return map[normalized] ?? map['English'] ?? key;
  }

  /// Exposed for catalog parity regression tests only.
  @visibleForTesting
  static Map<String, Set<String>> get localeCoverageReport =>
      buildLocaleCoverageReport(
        catalog: _catalog,
        supportedLocales: supportedLocales,
      );

  static const _catalog = <String, Map<String, String>>{
    'faq_jumuah_timing': {
      'English':
          "Jumu'ah (Friday prayer) is performed in place of Dhuhr on Fridays for those it applies to. In Qatar, congregations commonly begin between late morning and early afternoon; exact times vary by mosque — check your nearest mosque listing or the Jumu'ah Reminder in this app.\n\nArrive early, listen to the khutbah, and pray the two rak'ah of Jumu'ah after the adhan/khutbah per your community's practice.",
      'Arabic':
          'الجمعة تُؤدّى بدل الظهر يوم الجمعة لمن تجب عليه. في قطر تبدأ غالباً من أواخر الصباح إلى أوائل الظهر حسب المسجد — راجع أقرب مسجد أو تذكير الجمعة في التطبيق.\n\nاحضر مبكراً واستمع للخطبة ثم صلّ ركعتين بعد الأذان/الخطبة حسب عادة مسجدك.',
      'Urdu':
          'جمعہ جمعہ کے دن ظہر کی جگہ ادا ہوتی ہے۔ قطر میں عام طور پر late صبح سے دوپہر سے پہلے شروع ہوتی ہے — قریبی مسجد یا ایپ میں Jumu\'ah Reminder دیکھیں۔\n\nجلدی پہنچیں، خطبہ سنیں، پھر جماعت کے مطابق دو رکعت جمعہ ادا کریں۔',
      'Hindi':
          'जुम्मा (शुक्रवार की नमाज़) उन पर जिन पर लागू हो, शुक्रवार को ज़ुहर की जगह अदा होती है। कतर में अक्सर late सुबह से early दोपहर तक होती है — नज़दीकी मस्जिद या ऐप में Jumu\'ah Reminder देखें।\n\nजल्दी पहुँचें, ख़ुत्बा सुनें, फिर दो रकअत जुम्मा अदा करें।',
      'Malayalam':
          "Jumu'ah (Friday prayer) is Dhuhr on Fridays for those obliged. In Qatar it often starts late morning to early afternoon — check your nearest mosque or Jumu'ah Reminder in this app.\n\nArrive early, listen to the khutbah, then pray two rak'ah.",
      'Nepali':
          "Jumu'ah (Friday prayer) replaces Dhuhr on Fridays. In Qatar congregations often start late morning to early afternoon — see nearest mosque or Jumu'ah Reminder in the app.\n\nArrive early, listen to the khutbah, then pray two rak'ah.",
      'Bengali':
          "জুমুআ শুক্রবারে যাদের উপর ওয়াজib, জোহরের পরিবর্তে আদায় হয়। কatar-এ সাধারণত late সকাল থেকে early দুপুর — নিকটস্থ মসjid বা অ্যাপের Jumu'ah Reminder দেখুন।\n\nআগে পৌঁছান, খুতবা শুনুন, তারপর দু'রakat জুমুআ আদায় করুন।",
      'Filipino':
          "Jumu'ah (வெள்ளிக்கிழமை தொழுகை) Friday-ஐ Dhuhr-க்கு பதிலாக. Qatar-ல் late காலை முதல் early மதியம் — அர 근 masjid அல்லது Jumu'ah Reminder பார்க்கவும்.\n\nசீக்கிரம் வந்து khutbah கேட்டு இரண்டு rak'ah தொழுங்கள்.",
    },
    'faq_jumuah_obligatory': {
      'English':
          "Jumu'ah is an obligation for adult Muslim men who are residents, able-bodied, and not excused (e.g. valid illness or necessary travel). It replaces the four-rak'ah Dhuhr on Friday with two rak'ah plus khutbah.\n\nWomen, children, and travellers have different rulings across schools of thought — many communities encourage women's attendance where facilities exist, but obligation details differ. For personal circumstances, consult a qualified local scholar.",
      'Arabic':
          'الجمعة واجبة على الرجل المسلم البالغ المقيم القادر غير المعذور. تُقام بدل ظهر يوم الجمعة بركعتين وخطبة.\n\nللنساء والأطفال والمسافر أحكام مختلفة — كثير من المجتمعات يشجع حضور النساء حيث توجد مرافق. للحالات الشخصية راجع عالماً مختصاً.',
      'Urdu':
          'جمعہ بالغ، مقیم، صحت مند مسلمان مرد پر فرض ہے (بیماری/ضروری سفر میں معذور除外). یہ جمعہ کے دن ظہر کی چار رکعت کی جگہ دو رکعت اور خطبہ ہے۔\n\nخواتین، بچوں اور مسافروں کے احکام مختلف ہیں — ذاتی صورت حال کے لیے مستند عالم سے رجوع کریں۔',
      'Hindi':
          'जुम्मा वयस्क, resident, सक्षम Muslim पुरुष पर farz है (बीमारी/ज़रूरी सफ़र में maaf)। शुक्रवार को चार rak\'ah ज़ुहर की जगह दो rak\'ah + khutbah।\n\nमहिलाओं, बच्चों, musafir के अलग अ hukum — व्यक्तिगत हालत के लिए qualified scholar से पूछें।',
      'Malayalam':
          "Jumu'ah is obligatory for resident adult Muslim men who are able and not excused. It replaces four-rak'ah Dhuhr on Friday with two rak'ah and khutbah.\n\nRulings differ for women, children, and travellers — consult a qualified scholar for personal cases.",
      'Nepali':
          "Jumu'ah is obligatory for resident adult Muslim men who are able and not excused. It replaces four-rak'ah Dhuhr on Friday.\n\nWomen, children, and travellers — consult a qualified scholar for personal cases.",
      'Bengali':
          'জুমুআ resident প্রাপ্তবয়স্ক সুস্থ Muslim পুরুষের উপর farz (অসুস্থ/প্রয়োজনীয় ভ্রমণে maaf)। শুক্রবারে চার rak\'ah জোহরের পরিবর্তে দু\' rak\'ah + khutbah।\n\nনারী, শিশু, musafir — ব্যক্তিগত ক্ষেত্রে qualified scholar-এর পরামর্শ নিন।',
      'Filipino':
          "Jumu'ah resident adult Muslim men-க்கு farz (நோய்/தேவையான travel-ல் maaf). Friday-ஐ four-rak'ah Dhuhr-க்கு பதிலாக two rak'ah + khutbah.\n\nWomen, children, travellers — personal cases-க்கு qualified scholar-ஐ அணுகவும்.",
    },
    'faq_jumuah_missed': {
      'English':
          "If you miss Jumu'ah, pray four rak'ah of Dhuhr (Zuhr) as the replacement prayer for those who were obliged but missed the congregation — this is the widely taught approach.\n\nIf you arrive after the khutbah or imam has started, many scholars say join what you can; if the rak'ah is missed entirely, pray Dhuhr. Details vary — ask your local imam if unsure.",
      'Arabic':
          'من فاتته الجمعة يصلّي ظهر أربع ركعات — هذا المشهور لمن كانت الجمعة واجبة عليه.\n\nمن حضر بعد الخطبة أو بعد الإمام، يراجع أهل العلم محلياً. إن فاتت الركعة بالكامل يُصلّى الظهر.',
      'Urdu':
          'جس کی جمعہ رہ جائے وہ چار رکعت ظہر ادا کرے — یہ مشہور قول ہے۔\n\nخطبہ/امام کے بعد آنے والے مختلف احکام — مقامی عالم سے پوچھیں۔ اگر جمعہ بالکل نہ ہو سکی تو ظہر پڑھیں۔',
      'Hindi':
          'जुम्मा miss होने पर चार rak\'ah ज़ुहर अदा करें — यह mashhur qaul है।\n\nख़ुत्बा/imam के बाद आने पर fiqh अलग हो सकती है — local imam से पूछें।',
      'Malayalam':
          "If Jumu'ah is missed, pray four rak'ah Dhuhr — widely taught for those obliged.\n\nIf you arrive late, rulings differ — consult your local imam.",
      'Nepali':
          "Miss Jumu'ah → pray four rak'ah Dhuhr. Late arrival rulings differ — ask local imam.",
      'Bengali':
          'জুমুআ miss হলে চার rak\'ah জোহর — mashhur qaul। দেরিতে এলে local imam-এর পরামর্শ নিন।',
      'Filipino':
          "Jumu'ah miss → four rak'ah Dhuhr. Late arrival — local imam-ஐ கேளுங்கள்.",
    },
    'faq_jumuah_women': {
      'English':
          "Scholars differ on whether Jumu'ah is obligatory for women. Many communities hold that women may pray Dhuhr at home or attend Jumu'ah where separate facilities and modest arrangements exist.\n\nAttendance is encouraged in many mosques in Qatar when space is provided. For your personal obligation, follow your madhhab or ask a trusted local scholar — this app gives general guidance only.",
      'Arabic':
          'اختلف العلماء في وجوب الجمعة على المرأة. كثير من المجتمعات يرى أنها تصلّي الظهر في البيت أو تحضر الجمعة حيث توجد مرافق.\n\nفي قطر يُشجع الحضور حيث توفر المساجد مكاناً للنساء. للوجوب الشخصي راجع مذهبك أو عالماً محلياً.',
      'Urdu':
          'خواتین پر جمعہ کے فرض ہونے میں اختلاف ہے۔ بہت سی جماعتوں میں گھر میں ظہر یا جہاں سہولت ہو وہاں جمعہ کی اجازت ہے۔\n\nقطر میں جہاں الگ انتظام ہو وہاں شرکت کی حوصلہ افزائی — ذاتی فرض کے لیے مستند عالم سے رجوع کریں۔',
      'Hindi':
          'महिलाओं पर जुम्मा farz पर scholars में ikhtilaf है। कई communities में घर पर ज़ुहर या सुविधा हो तो जुम्मा।\n\nQatar में अलग facility हो तो attendance — personal farz के लिए local scholar।',
      'Malayalam':
          "Scholars differ on women's Jumu'ah obligation. Many allow Dhuhr at home or attendance where facilities exist.\n\nConsult a local scholar for personal obligation.",
      'Nepali':
          "Women's Jumu'ah — scholars differ. Dhuhr at home or attend where facilities exist. Consult local scholar.",
      'Bengali':
          'নারীদের জুমুআ farz — scholars-এ ikhtilaf। বাড়িতে জোহর বা সুবিধা থাকলে জুমুআ। local scholar-এর পরামর্শ নিন।',
      'Filipino':
          "Women's Jumu'ah — scholars differ. Home Dhuhr or attend with facilities. Local scholar-ஐ அணுகவும்.",
    },
    'faq_fasting_invalidators': {
      'English':
          "Commonly agreed invalidators of fasting include intentional eating/drinking, intentional vomiting, and marital relations during fasting hours in Ramadan.\n\nUnintentional forgetfulness is generally forgiven once remembered. Injections, medical needs, and nuanced cases need scholar/medical guidance — this is general information, not a personal ruling.",
      'Arabic':
          'من المفطرات المشهورة: الأكل والشرب عمداً، القيء عمداً، والجماع في نهار رمضان.\n\nالنسيان يُعفى عند التذكر. الحقن والحالات الطبية تحتاج فتوى — إرشاد عام فقط.',
      'Urdu':
          'روزہ توڑنے والی مشہور چیزیں: جان بوجھ کر کھانا پینا، قے، رمضان کے دن جماع۔\n\nبھول جانے پر معاف۔ injection/طبی معاملات — عالم سے پوچھیں؛ یہ عام معلومات ہے۔',
      'Hindi':
          'रोज़ा तोड़ने वाली mashhur चीज़ें: जान-बूझकर खाना-पीना, क़ै, ramadan में marital relation।\n\nभूल पर maafi। medical cases — scholar; general info only।',
      'Malayalam':
          'Common invalidators: intentional eat/drink, intentional vomit, marital relations in Ramadan daytime. Forgetfulness forgiven. Medical cases — ask scholar.',
      'Nepali':
          'Common invalidators: intentional eat/drink, vomit, marital relations in Ramadan day. Forgetfulness forgiven. Medical — scholar.',
      'Bengali':
          'রোজা ভঙ্গ: ইচ্ছাকৃত খাওয়া-দাওয়া, বমি, ramadan-এ marital relation। ভুলে গেলে maaf। medical — scholar।',
      'Filipino':
          'Roza break: intentional eat/drink, vomit, marital relation in Ramadan day. Forgetfulness forgiven. Medical — scholar.',
    },
    'faq_fasting_exceptions': {
      'English':
          "Islam allows concessions for genuine hardship: illness where fasting harms health, necessary travel, and other valid excuses in many opinions. Pregnancy/nursing often has flexible rulings — some fast if safe, others make up later or give fidya depending on madhhab.\n\nThis is not medical advice. If fasting affects health, consult a doctor and a qualified scholar together.",
      'Arabic':
          'رُخص للمرض والسفر وغيرهما من المشقّة. الحمل والرضاعة لها أحكام مرنة — يُراجع الطبيب والعالم معاً.\n\nليس هذا استشارة طبية.',
      'Urdu':
          'بیماری، ضروری سفر وغیرہ میں رخصت ہے۔ حمل/دودھ pilane کے احکام لچکدار — طبی مشورہ اور عالم دونوں سے رجوع کریں۔\n\nیہ طبی مشورہ نہیں۔',
      'Hindi':
          'बीमारी, ज़रूरी सफ़र में rukhsat। गर्भ/av lactation — flexible ahkaam; doctor + scholar। medical advice नहीं।',
      'Malayalam':
          'Concessions for illness, travel, hardship. Pregnancy/nursing — flexible; doctor + scholar. Not medical advice.',
      'Nepali':
          'Illness, travel concessions. Pregnancy/nursing — doctor + scholar. Not medical advice.',
      'Bengali':
          'অসুস্থতা, ভ্রমণে rukhsat। গর্ভ/দুধ feeding — doctor + scholar। medical advice নয়।',
      'Filipino':
          'Illness, travel rukhsat. Pregnancy/nursing — doctor + scholar. Medical advice அல்ல.',
    },
    'faq_fasting_qada': {
      'English':
          "Missed Ramadan fasts (with valid excuse or without) should be made up (qada) by fasting an equal number of days later when able. Keep a simple record of missed days.\n\nThose permanently unable to fast may owe fidya (feeding the poor) per madhhab — confirm with a scholar. Intention (niyyah) before dawn is required for each make-up fast.",
      'Arabic':
          'يُقضى ما فات من رمضان بصيام عدد الأيام عند القدرة. يُسجّل ما فات.\n\nمن عجز permanently قد تجب fidya حسب المذهب — يُراجع العالم. النية قبل الفجر لكل يوم قضاء.',
      'Urdu':
          'چھوٹے روزوں کی قضاء بعد میں رکھیں جب طاقت ہو۔ ریکارڈ رکھیں۔\n\nدائمی عدم استطاعت پر fidya — مذهب کے مطابق عالم سے پوچھیں۔ ہر قضاء سے پہلے نیت ضروری۔',
      'Hindi':
          'छूटे rozon की qada बाद में जब ताक़त हो। record रखें। permanent inability पर fidya — madhhab + scholar। har qada se pehle niyyah।',
      'Malayalam':
          'Make up missed Ramadan fasts when able. Record missed days. Permanent inability — fidya per madhhab. Niyyah before dawn.',
      'Nepali':
          'Make up missed fasts when able. Record days. Permanent inability — fidya per madhhab. Niyyah before dawn.',
      'Bengali':
          'ছুটে যাওa rozar qada পরে। record রাখুন। permanent inability — fidya, scholar। niyyah প্রয়োজন।',
      'Filipino':
          'Missed fasts qada when able. Record. Permanent inability — fidya, scholar. Niyyah before dawn.',
    },
    'faq_travel_qasr': {
      'English':
          "Qasr (shortening) allows four-rak'ah prayers to two while travelling for many scholars once valid travel conditions are met. Commonly shortened: Dhuhr, Asr, and Isha. Maghrib stays three; Fajr stays two.\n\nUse the Travel Prayer Assistant in this app to find prayer rooms. Confirm your madhhab for edge cases.",
      'Arabic':
          'القصر: تقصير الرباعية إلى ركعتين للمسافر عند تحقق شروط السفر. يُقصّر الظهر والعصر والعشاء. المغرب ثلاث والفجر ركعتان.\n\nاستخدم مساعد صلاة السفر في التطبيق.',
      'Urdu':
          'قصر: مسافر چار رکعت کو دو میں — ظہر، عصر، عشاء۔ مغرب تین، فجر دو۔\n\nایپ میں Travel Prayer Assistant استعمال کریں۔',
      'Hindi':
          'Qasr: musafir चार rak\'ah → दो — ज़ुहर, अस्र, इशा। मग़रिब तीन, फज्र दो। Travel Prayer Assistant देखें।',
      'Malayalam':
          "Qasr: shorten four-rak'ah to two while travelling — Dhuhr, Asr, Isha. Maghrib three, Fajr two. Use Travel Prayer Assistant.",
      'Nepali':
          "Qasr while travelling — Dhuhr, Asr, Isha to two. Use Travel Prayer Assistant.",
      'Bengali':
          'Qasr: musafir চার rak\'ah → দু\' — জোহর, আসর, এশা। Travel Prayer Assistant দেখুন।',
      'Filipino':
          "Qasr: travel-ல் four-rak'ah → two — Dhuhr, Asr, Isha. Travel Prayer Assistant பயன்படுத்தவும்.",
    },
    'faq_travel_combine': {
      'English':
          "Combining prayers (jam') while travelling — joining Dhuhr with Asr, or Maghrib with Isha — is permitted in many schools when travelling, with specific conditions (often same journey, not at home mosque routinely).\n\nMethods differ (jam' taqdim vs ta'khir). If your question is nuanced, consult a scholar rather than assuming one method.",
      'Arabic':
          'جمع الصلاة في السفر — جمع الظهر مع العصر أو المغرب مع العشاء — جائز عند كثير من العلماء بشروط.\n\nتفاصيل الجمع (تقديم/تأخير) تختلف — راجع عالماً للحالات الدقيقة.',
      'Urdu':
          'سفر میں نماز جمع — ظہر+عصر یا مغرب+عشاء — بہت سے علماء کے نزدیک جائز بشرطik۔\n\nتفصیلی سوالات کے لیے عالم سے رجوع کریں۔',
      'Hindi':
          'Safar में jam\' — zuhr+asr ya maghrib+isha — kai ulama ke nazdeek jaiz with shart। nuanced sawal → scholar।',
      'Malayalam':
          "Combining prayers while travelling is allowed in many opinions with conditions. Nuanced cases — consult scholar.",
      'Nepali':
          'Combining prayers while travelling — many allow with conditions. Nuanced — scholar.',
      'Bengali':
          'ভ্রমণে jam\' — জোহর+আসর বা মাগরিব+এশা — অনেক opinion-এ jaiz। nuanced — scholar।',
      'Filipino':
          "Travel-ல் jam' — conditions apply. Nuanced — scholar.",
    },
    'faq_travel_distance': {
      'English':
          "Travel concessions (qasr/jam') typically apply once you are on a legitimate journey beyond your city and not merely commuting locally. A commonly cited minimum is ~80 km (48 miles) or ~1–4 days of travel — scholars differ on exact thresholds.\n\nShort trips within Qatar or daily commutes usually do not count. When unsure, ask a scholar rather than guessing.",
      'Arabic':
          'أحكام السفر (قصر/جمع) تُطبّق في سفر معتبر خارج نطاق العرف. يُذكر often نحو 80 كم أو أيام — يختلف العلماء.\n\nالتنقل اليومي داخل المدينة غالباً لا يُعد سفراً. عند الشك راجع عالماً.',
      'Urdu':
          'قصر/جمع عام طور پر city سے باہر معتبر سفر پر — اکثر 80 کلومیٹر یا چند دن کا حوالہ، علماء میں اختلاف۔\n\nروزمرہ commute عام طور پر سفر نہیں۔ شک میں عالم سے پوچھیں۔',
      'Hindi':
          'Qasr/jam\' valid safar par — often ~80 km ya kuch din, ulama mein ikhtilaf। daily commute safar nahi। doubt → scholar।',
      'Malayalam':
          'Travel concessions after valid journey — often ~80 km cited; scholars differ. Daily commute usually not travel.',
      'Nepali':
          'Valid journey for qasr — ~80 km often cited; scholars differ. Commute usually not travel.',
      'Bengali':
          'Qasr/jam\' valid safar-এ — ~80 km cite; scholars differ। commute safar নয়।',
      'Filipino':
          'Valid journey for qasr — ~80 km cited; scholars differ. Commute usually not travel.',
    },
    'faq_travel_status': {
      'English':
          'You are generally considered a traveller (musafir) when you leave your city/residence on a permitted journey intending stay under the scholarly limit (often up to ~15 days in many views, with differences).\n\nReturning home or staying long-term ends traveller status. Combining shortening with residence rules is nuanced — use Travel Prayer Assistant here and confirm with a scholar for long stays abroad.',
      'Arabic':
          'المسافر من خرج من بلده في سفر مباح ونوى الإقامة دون مدة طويلة (often حتى ~15 يوماً — اختلاف).\n\nالعودة للإقامة تنهي حكم السفر. للإقامة الطويلة راجع عالماً.',
      'Urdu':
          'مسافر وہ جو بلد/گھر سے halal safar پر نکلے اور قلیل قیام کا ارادہ — often ~15 دن تک (اختلاف)۔\n\nواپسی یا طویل قیام پر حكم بدلتا ہے — طویل بیرون ملک مقام پر عالم سے پوچھیں۔',
      'Hindi':
          'Musafir jab halal safar par sheher chhode, short qiyam — often ~15 din (ikhtilaf)। long stay → scholar।',
      'Malayalam':
          'Traveller when on valid journey with short stay intent — often ~15 days cited; differs. Long stay — scholar.',
      'Nepali':
          'Traveller on valid journey, short stay — often ~15 days; differs. Long stay — scholar.',
      'Bengali':
          'Musafir valid safar, short qiyam — often ~15 din; differs. Long stay — scholar.',
      'Filipino':
          'Musafir valid journey, short stay — often ~15 days; differs. Long stay — scholar.',
    },
    'faq_etiquette_mosque': {
      'English':
          'Mosque etiquette: enter with right foot, dress modestly, silence phone, avoid strong fragrance disputes, do not walk in front of someone praying, and keep voices low. Remove shoes where required.\n\nMake wudu if needed; women use designated areas when available. Respect local customs in Qatar’s diverse mosques.',
      'Arabic':
          'آداب المسجد: دخول باليمين، لباس محتشم، إسكات الجوال، تجنب إزعاج المصلين، خفض الصوت، إزالة الحذاء.\n\nالوضوء عند الحاجة؛ للنساء مكان مخصص. احترم عادات المساجد في قطر.',
      'Urdu':
          'مسجد کے آداب: دائیں پاؤں، پردہ، فون خاموش، خوشبو میں اعتدال، نمازی کے سامنے نہ چلیں، آواز کم۔ جوتے utarna۔\n\nوضو؛ خواتین کے لیے الگ جگہ۔ قطر کے مساجد کے رواج کا احترام۔',
      'Hindi':
          'Masjid aadaab: daayin paanv, modest dress, phone silent, namazi ke aage mat chalna, kam awaaz, joota utarna। wudu; ladies area। Qatar ke riwaaj।',
      'Malayalam':
          'Mosque etiquette: modest dress, silent phone, low voice, remove shoes, wudu, respect women\'s section.',
      'Nepali':
          'Mosque etiquette: modest dress, silent phone, low voice, shoes off, wudu, respect local custom.',
      'Bengali':
          'Masjid adab: modest dress, phone silent, namaziর সামনে নয়, জুতো uthan, wudu, ladies section respect.',
      'Filipino':
          'Masjid etiquette: modest dress, silent phone, low voice, shoes off, wudu, ladies section.',
    },
    'faq_etiquette_prayer_room': {
      'English':
          'Prayer rooms (musallas) in malls, airports, and hotels in Qatar are shared spaces — keep them clean, pray quietly, restore borrowed prayer mats, and avoid eating or loud conversation inside.\n\nUse Nearby Prayer Rooms / Travel Prayer Assistant in this app to locate facilities. Non-Muslim companions should wait respectfully outside when asked.',
      'Arabic':
          'المصليات في المولات والمطارات فضاء مشترك — نظافة، هدوء، إعادة السجاد، لا أكل ولا صوت عال.\n\nاستخدم التطبيق للعثور على مصلى. المرافقون ينتظرون باحترام خارجاً عند الطلب.',
      'Urdu':
          'مول/ائیرپورٹ مصلی مشترکہ جگہ — صفائی، خاموشی، janamaz وapas، کھana/شور نہیں۔\n\nایپ سے قریبی مصلی دیکھیں۔',
      'Hindi':
          'Mall/airport musalla — saaf, khamoshi, janamaz wapas, khana/shor nahi. App se nearby room.',
      'Malayalam':
          'Prayer rooms — keep clean, quiet, return mats. Use app to find nearby rooms.',
      'Nepali':
          'Prayer rooms — clean, quiet. Use app to find nearby.',
      'Bengali':
          'Prayer room — porishkar, chup, janamaz ফেরত। app-এ nearby room।',
      'Filipino':
          'Prayer room — clean, quiet. App-ல் nearby room.',
    },
    'faq_etiquette_dress': {
      'English':
          'For mosque/prayer: cover awrah modestly — men at least shoulders to knees; women cover body except face/hands per common practice, with headscarf in many mosques. Avoid tight or transparent clothing.\n\nAt work/travel prayer rooms, minimum modesty still applies. When visiting state mosques in Qatar, follow posted guidance.',
      'Arabic':
          'لباس الصلاة: ستر العورة — للرجل من المنكب إلى الركبة؛ للمرأة ستر الجسم مع حجاب في كثير من المساجد.\n\nتجنب الضيق والشفافية. في مساجد قطر اتبع التعليمات.',
      'Urdu':
          'نماز/مسjid لباس: عورت پردہ، مرد منکب سے گھٹنے؛ سخت/شفاف کپڑے نہ۔\n\nقطر کے مساجد کی ہدایت مانیں۔',
      'Hindi':
          'Namaz dress: modest awrah — men shoulders to knees; women hijab common. Tight/transparent avoid. Qatar mosque rules follow karein.',
      'Malayalam':
          'Modest dress for prayer — awrah covered; headscarf often for women. Follow mosque guidance in Qatar.',
      'Nepali':
          'Modest dress for prayer — awrah covered. Follow mosque guidance.',
      'Bengali':
          'Namaz dress — awrah cover, hijab common. Qatar mosque guidance follow.',
      'Filipino':
          'Prayer dress — awrah cover, hijab common. Follow mosque guidance.',
    },
    'faq_friday_sunnah': {
      'English':
          'Common Friday Sunnah practices many Muslims follow: ghusl, wearing clean clothes, applying light fragrance (men), reading Surah Al-Kahf, sending salawat on the Prophet ﷺ, arriving early for Jumu\'ah, and making dua on this blessed day.\n\nDetails vary by community — treat this as a gentle checklist, not an exhaustive obligation list.',
      'Arabic':
          'من السنة الشائعة يوم الجمعة: الغسل، اللباس النظيف، الطيب (للرجال)، قراءة سورة الكهف، الصلاة على النبي ﷺ، التبكير للجمعة، والدعاء.\n\nالتفاصيل تختلف — قائمة عامة وليست قائمة وجوب كاملة.',
      'Urdu':
          'جمعہ کی سنتیں: غسل، صاف کپڑے، خوشبو (مرد)، سورہ کہف، درود، جلدی مسجد، دعا۔\n\nتفصیلات مختلف — general checklist۔',
      'Hindi':
          'Jumma ki sunnat: ghusl, saaf kapde, itr (mard), Surah Kahf, durood, jaldi masjid, dua. General checklist.',
      'Malayalam':
          'Friday Sunnah: ghusl, clean clothes, Surah Kahf, salawat, arrive early for Jumu\'ah, dua. General checklist.',
      'Nepali':
          'Friday Sunnah: ghusl, clean clothes, Surah Kahf, salawat, early Jumu\'ah, dua.',
      'Bengali':
          'Friday Sunnah: ghusl, porishkar kapod, Surah Kahf, durood, early Jumu\'ah, dua.',
      'Filipino':
          'Friday Sunnah: ghusl, clean clothes, Surah Kahf, salawat, early Jumu\'ah, dua.',
    },
    'faq_nearest_mosque': {
      'English':
          'Open Nearby Mosques in this app to see masjids and prayer halls near your location in Qatar, with Jumu\'ah times and facilities where available.\n\nEnable location for best results, or browse the curated list from the dashboard.',
      'Arabic':
          'افتح «أقرب مسجد» في التطبيق لرؤية المساجد والمصليات في قطر مع أوقات الجمعة والمرافق.\n\nفعّل الموقع لأفضل نتيجة.',
      'Urdu':
          'ایپ میں Nearby Mosques کھولیں — قطر میں قریبی مساجد، جمعہ کے اوقات اور سہولیات۔\n\nلوکیشن آن کریں۔',
      'Hindi':
          'App mein Nearby Mosques kholen — Qatar mein paas ki masjid, Jumu\'ah time, facilities. Location on karein.',
      'Malayalam':
          'Open Nearby Mosques in the app for masjids in Qatar with Jumu\'ah times. Enable location.',
      'Nepali':
          'Open Nearby Mosques in app for Qatar masjids. Enable location.',
      'Bengali':
          'App-এ Nearby Mosques — Qatar-এ masjid, Jumu\'ah time. Location চালু করুন।',
      'Filipino':
          'App-ல் Nearby Mosques — Qatar masjids, Jumu\'ah time. Location enable.',
    },
    'faq_ramadan_companion': {
      'English':
          'For Ramadan suhoor/iftar times, fasting schedule, and seasonal reminders, open Ramadan Companion in this app — it uses local prayer times rather than generating new content each time.\n\nExact Ramadan start/end follow the official moon sighting announcements in Qatar.',
      'Arabic':
          'لمواعيد السحور والإفطار وجدول الصيام افتح «رفيق رمضان» — يعتمد على مواقيت الصلاة المحلية.\n\nبداية ونهاية رمضان حسب إعلانات رؤية الهلال في قطر.',
      'Urdu':
          'سحری/افطار اور روزے کا شیڈول — Ramadan Companion کھولیں؛ local prayer times استعمال ہوتے ہیں۔\n\nرمضان کی تاریخ قطر کی رویت کے اعلان پر۔',
      'Hindi':
          'Suhoor/iftar schedule — Ramadan Companion kholen; local prayer times use hote hain. Ramadan dates Qatar moon sighting par.',
      'Malayalam':
          'Suhoor/iftar — open Ramadan Companion using local prayer times. Dates follow Qatar moon sighting.',
      'Nepali':
          'Ramadan schedule — Ramadan Companion with local prayer times. Dates per Qatar sighting.',
      'Bengali':
          'Suhoor/iftar — Ramadan Companion, local prayer times. Dates Qatar moon sighting.',
      'Filipino':
          'Ramadan schedule — Ramadan Companion, local prayer times. Dates Qatar sighting.',
    },
    'faq_islamic_calendar': {
      'English':
          'Islamic Calendar in this app shows Hijri/Gregorian dates and upcoming events (Ramadan, Eid al-Fitr, Eid al-Adha, Ashura, and more) using offline calendar math — open it instead of asking for dates each time.\n\nOfficial holiday dates in Qatar may follow announced moon sighting.',
      'Arabic':
          'التقويم الإسلامي يعرض التاريخ الهجري والميلادي والمناسبات (رمضان، العيدين، عاشوراء…) offline — افتحه بدل السؤال كل مرة.\n\nالعطلات الرسمية حسب إعلانات رؤية الهلال.',
      'Urdu':
          'اسلامی کیلنڈر میں hijri/gregorian اور upcoming events offline — بار بار پوچھne ki bajaye کھولیں۔\n\nسرکاری تعطیلات رویت کے اعلان پر۔',
      'Hindi':
          'Islamic Calendar mein Hijri/Gregorian aur events offline — baar-baar poochne ki bajaye kholen. Official dates moon sighting par.',
      'Malayalam':
          'Islamic Calendar shows Hijri dates and events offline — open it for Ramadan/Eid dates.',
      'Nepali':
          'Islamic Calendar — Hijri dates and events offline. Open for Ramadan/Eid.',
      'Bengali':
          'Islamic Calendar — Hijri dates, events offline. Ramadan/Eid-এর জন্য খুলুন।',
      'Filipino':
          'Islamic Calendar — Hijri dates, events offline. Ramadan/Eid-ku open.',
    },
  };
}
