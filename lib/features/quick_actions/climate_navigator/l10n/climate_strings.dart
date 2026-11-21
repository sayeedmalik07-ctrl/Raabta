// Climate Navigator + heat-safety guidance strings.
//
// Malayalam and Nepali medical copy uses English pending native review
// (TODO-TRANSLATE-REVIEW in catalog entries below).
import 'package:flutter/foundation.dart';
import 'package:raabta/core/l10n/app_locale.dart';
import 'package:raabta/core/l10n/locale_catalog_coverage.dart';
import 'package:raabta/core/l10n/locale_catalog_entry.dart';

abstract final class ClimateStrings {
  static const supportedLocales = AppLocale.supportedLocales;

  static String t(String key, [String locale = 'English']) {
    final map = _strings[key];
    if (map == null) return key;
    final normalized = AppLocale.normalize(locale);
    return map[normalized] ?? map['English'] ?? key;
  }

  @visibleForTesting
  static Map<String, Set<String>> get localeCoverageReport =>
      buildLocaleCoverageReport(
        catalog: Map<String, Map<String, String>>.from(_strings),
        supportedLocales: supportedLocales,
      );

  static final _strings = <String, Map<String, String>>{
    'screen_title': {
      'English': 'Heat Safety',
      'Arabic': 'السلامة من الحر',
      'Hindi': 'गर्मी से सुरक्षा',
      'Urdu': 'گرمی سے تحفظ',
      'Bengali': 'তাপ সুরক্ষা',
      'Filipino': 'Heat Safety',
      'Malayalam': 'ചൂടിൽ സുരക്ഷ',
      'Nepali': 'ताप सुरक्षा',
      'Tamil': 'வெப்ப பாதுகாப்பு',
    },
    'wbgt_title': {
      'English': 'Estimated WBGT (heat stress)',
      'Arabic': 'WBGT التقديري (إجهاد حراري)',
      'Hindi': 'अनुमानित WBGT (गर्मी का तनाव)',
      'Urdu': 'تخمینی WBGT (گرمی کا دباؤ)',
      'Bengali': 'আনুমানিক WBGT (তাপ চাপ)',
      'Filipino': 'Tantyang WBGT (heat stress)',
      'Malayalam': 'Estimated WBGT (heat stress)',
      'Nepali': 'Estimated WBGT (heat stress)',
    },
    'wbgt_approx_note': {
      'English':
          'Approximation from weather data — not a certified ISO 7243 instrument reading.',
      'Arabic':
          'تقدير من بيانات الطقس — ليس قياساً بجهاز معتمد ISO 7243.',
      'Hindi':
          'मौसम डेटा से अनुमान — ISO 7243 प्रमाणित उपकरण reading नहीं।',
      'Urdu':
          'موسم کے ڈیٹا سے تخمینہ — ISO 7243 سرٹیفائیڈ آلہ نہیں۔',
      'Bengali':
          'আবহাওয়ার তথ্য থেকে অনুমান — ISO 7243 সনদপ্রাপ্ত যন্ত্র নয়।',
      'Filipino':
          'Tantya mula sa panahon — hindi ISO 7243 certified instrument.',
      'Malayalam':
          'Approximation from weather data — not a certified ISO 7243 instrument reading.',
      'Nepali':
          'Approximation from weather data — not a certified ISO 7243 instrument reading.',
    },
    'wbgt_risk_lower': {
      'English': 'Lower heat stress',
      'Arabic': 'إجهاد حراري أقل',
      'Hindi': 'कम गर्मी का तनाव',
      'Urdu': 'کم گرمی کا دباؤ',
      'Bengali': 'কম তাপ চাপ',
      'Filipino': 'Mas mababang heat stress',
      'Malayalam': 'Lower heat stress',
      'Nepali': 'Lower heat stress',
    },
    'wbgt_risk_moderate': {
      'English': 'Moderate heat stress',
      'Arabic': 'إجهاد حراري متوسط',
      'Hindi': 'मध्यम गर्मी का तनाव',
      'Urdu': 'درمیانی گرمی کا دباؤ',
      'Bengali': 'মাঝারি তাপ চাপ',
      'Filipino': 'Katamtamang heat stress',
      'Malayalam': 'Moderate heat stress',
      'Nepali': 'Moderate heat stress',
    },
    'wbgt_risk_high': {
      'English': 'High heat stress',
      'Arabic': 'إجهاد حراري مرتفع',
      'Hindi': 'उच्च गर्मी का तनाव',
      'Urdu': 'زیادہ گرمی کا دباؤ',
      'Bengali': 'উচ্চ তাপ চাপ',
      'Filipino': 'Mataas na heat stress',
      'Malayalam': 'High heat stress',
      'Nepali': 'High heat stress',
    },
    'wbgt_risk_extreme': {
      'English': 'Extreme heat stress',
      'Arabic': 'إجهاد حراري شديد',
      'Hindi': 'अत्यधिक गर्मी का तनाव',
      'Urdu': 'شدید گرمی کا دباؤ',
      'Bengali': 'চরম তাপ চাপ',
      'Filipino': 'Matinding heat stress',
      'Malayalam': 'Extreme heat stress',
      'Nepali': 'Extreme heat stress',
    },
    'wbgt_risk_work_stop': {
      'English': 'Work must stop (WBGT > 32.1 °C)',
      'Arabic': 'يجب إيقاف العمل (WBGT > 32.1 °C)',
      'Hindi': 'काम रोकना अनिवार्य (WBGT > 32.1 °C)',
      'Urdu': 'کام بند کرنا لازم (WBGT > 32.1 °C)',
      'Bengali': 'কাজ বন্ধ করতে হবে (WBGT > 32.1 °C)',
      'Filipino': 'Dapat tumigil ang trabaho (WBGT > 32.1 °C)',
      'Malayalam': 'Work must stop (WBGT > 32.1 °C)',
      'Nepali': 'Work must stop (WBGT > 32.1 °C)',
    },
    'work_stop_alert_title': {
      'English': 'Outdoor work must stop',
      'Arabic': 'يجب إيقاف العمل في الهواء الطلق',
      'Hindi': 'बाहरी काम रोकना अनिवार्य',
      'Urdu': 'بیرونی کام بند کریں',
      'Bengali': 'বাইরের কাজ বন্ধ করুন',
      'Filipino': 'Itigil ang outdoor work',
      'Malayalam': 'Outdoor work must stop',
      'Nepali': 'Outdoor work must stop',
    },
    'work_stop_alert_body': {
      'English':
          'Estimated WBGT exceeds 32.1 °C — the limit under Ministerial Decision No. 17 of 2021. Seek shade, hydrate, and follow your employer\'s heat plan.',
      'Arabic':
          'تجاوز WBGT التقديري 32.1 °C — الحد بموجب القرار الوزاري رقم 17 لسنة 2021. ابحث عن الظل وتناول السوائل.',
      'Hindi':
          'अनुमानित WBGT 32.1 °C से अधिक — मंत्रial Decision 17/2021 की सीमा। छाया में जाएँ, पानी पिएँ।',
      'Urdu':
          'تخمینی WBGT 32.1 °C سے زیادہ — وزاری فیصلہ 17/2021 کی حد۔ سایہ میں جائیں، پانی پئیں۔',
      'Bengali':
          'আনুমানিক WBGT 32.1 °C-এর বেশি — Ministerial Decision 17/2021 সীমা। ছায়ায় যান, পানি পান করুন।',
      'Filipino':
          'Lampas sa 32.1 °C ang tantyang WBGT — limit ng Ministerial Decision 17/2021. Humingi ng lilim at uminom ng tubig.',
      'Malayalam':
          'Estimated WBGT exceeds 32.1 °C — the limit under Ministerial Decision No. 17 of 2021.',
      'Nepali':
          'Estimated WBGT exceeds 32.1 °C — the limit under Ministerial Decision No. 17 of 2021.',
    },
    'summer_hours_alert_title': {
      'English': 'Summer restricted work hours (10:00–15:30)',
      'Arabic': 'ساعات عمل مقيدة صيفاً (10:00–15:30)',
      'Hindi': 'गर्मी में प्रतिबंधित समय (10:00–15:30)',
      'Urdu': 'گرمی میں محدود اوقات (10:00–15:30)',
      'Bengali': 'গ্রীষ্মে সীমিত সময় (10:00–15:30)',
      'Filipino': 'Restricted hours sa tag-init (10:00–15:30)',
      'Malayalam': 'Summer restricted work hours (10:00–15:30)',
      'Nepali': 'Summer restricted work hours (10:00–15:30)',
    },
    'summer_hours_alert_body': {
      'English':
          '1 June–15 September: outdoor work is restricted 10:00–15:30 (Qatar time) under Ministerial Decision No. 17 of 2021 — aligned with the MoL Heat Stress Prevention Campaign.',
      'Arabic':
          '1 يونيو–15 سبتمبر: يُقيّد العمل في الهواء الطلق 10:00–15:30 (توقيت قطر) بموجب القرار الوزاري 17/2021.',
      'Hindi':
          '1 जून–15 सितंबर: बाहरी काम 10:00–15:30 (कतर समय) तक प्रतिबंधित — MoL Heat Stress Prevention Campaign।',
      'Urdu':
          '1 جون–15 ستمبر: بیرونی کام 10:00–15:30 (قطر وقت) تک محدود — MoL Heat Stress Prevention Campaign۔',
      'Bengali':
          '১ জুন–১৫ সেপ্টেম্বর: বাইরের কাজ 10:00–15:30 (কatar সময়) সীমিত।',
      'Filipino':
          ' Hunyo 1–Set 15: restricted ang outdoor work 10:00–15:30 (Qatar time) — MoL Heat Stress campaign.',
      'Malayalam':
          '1 June–15 September: outdoor work restricted 10:00–15:30 Qatar time.',
      'Nepali':
          '1 June–15 September: outdoor work restricted 10:00–15:30 Qatar time.',
    },
    'heat_index_label': {
      'English': 'Heat index (unchanged estimate)',
      'Arabic': 'مؤشر الحرارة (تقدير سابق)',
      'Hindi': 'हीट इंडेक्स (पहले जैसा अनुमान)',
      'Urdu': 'Heat index (پہلے جیسا تخمینہ)',
      'Bengali': 'হিট ইনডেক্স (আগের অনুমান)',
      'Filipino': 'Heat index (dating tantya)',
      'Malayalam': 'Heat index (unchanged estimate)',
      'Nepali': 'Heat index (unchanged estimate)',
    },
    'weather_updated': {
      'English': 'Weather updated {time}',
      'Arabic': 'تحديث الطقس {time}',
      'Hindi': 'मौसम अपडेट {time}',
      'Urdu': 'موسم اپ ڈیٹ {time}',
      'Bengali': 'আবহাওয়া আপডেট {time}',
      'Filipino': 'Na-update ang panahon {time}',
      'Malayalam': 'Weather updated {time}',
      'Nepali': 'Weather updated {time}',
    },
    'weather_cached': {
      'English': 'Cached weather · last updated {time}',
      'Arabic': 'طقس مخزّن · آخر تحديث {time}',
      'Hindi': 'कैश मौसम · अंतिम अपडेट {time}',
      'Urdu': 'محفوظ موسم · آخری اپ ڈیٹ {time}',
      'Bengali': 'ক্যাশ আবহাওয়া · শেষ আপডেট {time}',
      'Filipino': 'Naka-cache na panahon · huling update {time}',
      'Malayalam': 'Cached weather · last updated {time}',
      'Nepali': 'Cached weather · last updated {time}',
    },
    'weather_estimated': {
      'English': 'Estimated weather — connect for fresh data',
      'Arabic': 'طقس تقديري — اتصل للحصول على بيانات حديثة',
      'Hindi': 'अनुमानित मौसम — ताज़ा डेटा के लिए कनेक्ट करें',
      'Urdu': 'تخمینی موسم — تازہ ڈیٹا کے لیے منسلک ہوں',
      'Bengali': 'আনুমানিক আবহাওয়া — সংযোগ দিন',
      'Filipino': 'Tantyang panahon — kumonekta para sa bagong data',
      'Malayalam': 'Estimated weather — connect for fresh data',
      'Nepali': 'Estimated weather — connect for fresh data',
    },
    'guide_title': {
      'English': 'Heat illness guide',
      'Arabic': 'دليل أمراض الحر',
      'Hindi': 'गर्मी से बीमारी गाइड',
      'Urdu': 'گرمی کی بیماری گائیڈ',
      'Bengali': 'তাপজনিত অসুস্থতা গাইড',
      'Filipino': 'Gabay sa heat illness',
      'Malayalam': 'Heat illness guide',
      'Nepali': 'Heat illness guide',
    },
    'guide_offline': {
      'English': 'Works offline',
      'Arabic': 'يعمل دون اتصال',
      'Hindi': 'ऑफ़लाइन काम करता है',
      'Urdu': 'آف لائن کام کرتا ہے',
      'Bengali': 'অফলাইনে কাজ করে',
      'Filipino': 'Gumagana offline',
      'Malayalam': 'Works offline',
      'Nepali': 'Works offline',
    },
    'guide_cramps_title': {
      'English': 'Heat cramps',
      'Arabic': 'تشنجات الحر',
      'Hindi': 'गर्मी की ऐंठन',
      'Urdu': 'گرمی کے درد',
      'Bengali': 'তাপ ঐঠন',
      'Filipino': 'Heat cramps',
      'Malayalam': 'Heat cramps',
      'Nepali': 'Heat cramps',
    },
    'guide_cramps_symptoms': {
      'English':
          'Painful muscle cramps or spasms, often during or after heavy work in heat.',
      'Arabic': 'تشنجات عضلية مؤلمة أثناء أو بعد العمل الشاق في الحر.',
      'Hindi': 'दर्दनाक मांसपेशी ऐंठन, अक्सर गर्मी में काम के दौरान/बाद।',
      'Urdu': 'پٹھوں میں دردناک کھچاؤ، اکثر گرمی میں کام کے دوران/بعد۔',
      'Bengali': 'পেশীতে ব্যথা — প্রায়ই গরমে কাজের সময়/পরে।',
      'Filipino': 'Masakit na muscle cramps habang o pagkatapos magtrabaho sa init.',
      'Malayalam':
          'Painful muscle cramps or spasms, often during or after heavy work in heat.',
      'Nepali':
          'Painful muscle cramps or spasms, often during or after heavy work in heat.',
    },
    'guide_cramps_aid': {
      'English':
          'Stop activity; rest in shade; drink water or electrolyte fluids; gently stretch the muscle; do not return to heavy work until cramps fully resolve.',
      'Arabic': 'أوقف النشاط؛ استرح في الظل؛ اشرب ماء أو سوائل م electrolytes؛ مدّد العضلة برفق.',
      'Hindi': 'काम रोकें; छाया में आराम; पानी/ORS पिएँ; हल्का स्टretch; भारी काम तब तक न करें जब तक ठीक न हों।',
      'Urdu': 'کام روکیں؛ سایہ میں آرام؛ پani/ORS؛ ہلکا stretch؛ مکمل ٹھیک ہونے تک بھاری کام نہ کریں۔',
      'Bengali': 'কাজ বন্ধ; ছায়ায় বিশ্রাম; পানি/ORS; হালকা stretch; ভাল না হলে ভারী কাজ নয়।',
      'Filipino': 'Itigil ang gawain; magpahinga sa lilim; uminom ng tubig/ORS; i-stretch ang muscle.',
      'Malayalam':
          'Stop activity; rest in shade; drink water or electrolyte fluids; gently stretch.',
      'Nepali':
          'Stop activity; rest in shade; drink water or electrolyte fluids; gently stretch.',
    },
    'guide_exhaustion_title': {
      'English': 'Heat exhaustion',
      'Arabic': 'إجهاد حراري',
      'Hindi': 'गर्मी की थकान',
      'Urdu': 'گرمی سے تھکاوٹ',
      'Bengali': 'তাপ ক্লান্তি',
      'Filipino': 'Heat exhaustion',
      'Malayalam': 'Heat exhaustion',
      'Nepali': 'Heat exhaustion',
    },
    'guide_exhaustion_symptoms': {
      'English':
          'Heavy sweating, pale or clammy skin, weakness, nausea, headache, fast weak pulse.',
      'Arabic': 'تعرق شديد، بشرة شاحبة، ضعف، غثيان، صداع، نبض سريع ضعيف.',
      'Hindi': 'पसीना, पीली/नम त्वचा, कमज़ोरी, मितली, सिरदर्द, तेज कमज़ोर नाड़ी।',
      'Urdu': 'پسینہ، پیلا/چپچپا جلد، کمزوری، متلی، سر درد، تیز کمزور نبض۔',
      'Bengali': 'ঘাম, ফ্যাকাশে/আর্দ্র ত্বক, দুর্বলতা, বমি বমি ভাব, মাথাব্যথা।',
      'Filipino': 'Sobrang pawis, maputla, hilo, pananakit ng ulo, mabilis na pulso.',
      'Malayalam':
          'Heavy sweating, pale or clammy skin, weakness, nausea, headache, fast weak pulse.',
      'Nepali':
          'Heavy sweating, pale or clammy skin, weakness, nausea, headache, fast weak pulse.',
    },
    'guide_exhaustion_aid': {
      'English':
          'Move to air-conditioning or shade; lie down with legs slightly raised; sip cool water; apply cool cloths; if no improvement within an hour or symptoms worsen, seek medical care.',
      'Arabic': 'انتقل لمكان مكيّف أو ظل؛ استلقِ وارفع الساقين؛ رشف ماء بارداً؛ اطلب رعاية طبية إن ساءت الأعراض.',
      'Hindi': 'AC/छाया में जाएँ; लेटें, पैर ऊपर; ठंडा पानी; 1 घंटे में सुधार न हो तो डॉक्टर।',
      'Urdu': 'AC/سایہ میں جائیں؛ لیٹیں؛ ٹھنڈا پani؛ 1 گھنٹے میں بہتر نہ ہو تو ڈاکٹر۔',
      'Bengali': 'AC/ছায়ায় যান; শুয়ে পান; ঠান্ডা পানি; ১ ঘণ্টায় না হলে চিকিৎসা।',
      'Filipino': 'Sa AC o lilim; humiga; uminom ng malamig na tubig; kung lumala, magpa-checkup.',
      'Malayalam':
          'Move to AC or shade; lie down; sip cool water; seek care if worsening.',
      'Nepali':
          'Move to AC or shade; lie down; sip cool water; seek care if worsening.',
    },
    'guide_stroke_title': {
      'English': 'Heat stroke — emergency',
      'Arabic': 'ضربة شمس — طوارئ',
      'Hindi': 'हीट स्ट्रोक — आपातकाल',
      'Urdu': 'ہیٹ سٹروک — ایمرجنسی',
      'Bengali': 'হিট স্ট্রোক — জরুরি',
      'Filipino': 'Heat stroke — emergency',
      'Malayalam': 'Heat stroke — emergency',
      'Nepali': 'Heat stroke — emergency',
    },
    'guide_stroke_symptoms': {
      'English':
          'High body temperature; hot dry skin or profuse sweating; confusion; slurred speech; seizures; loss of consciousness.',
      'Arabic': 'حرارة عالية؛ جلد ساخن؛ تشوش؛ تلعثم؛ تشنجات؛ فقدان وعي.',
      'Hindi': 'उच्च ताप; गर्म सूखी/पसीने वाली त्वचा; भ्रम; बेहोशी।',
      'Urdu': 'زیادہ درجہ حرارت؛ الجھن؛ بے ہوشی۔',
      'Bengali': 'উচ্চ তাপ; বিভ্রান্তি; খিঁচুনি; অজ্ঞান।',
      'Filipino': 'Mataas na lagnat; pagkalito; pagkawala ng malay.',
      'Malayalam':
          'High body temperature; confusion; seizures; loss of consciousness.',
      'Nepali':
          'High body temperature; confusion; seizures; loss of consciousness.',
    },
    'guide_stroke_aid': {
      'English':
          'Call 999 immediately. Move to shade or AC; cool with wet cloths on neck, armpits, and groin; do not give fluids if unconscious; stay until help arrives.',
      'Arabic': 'اتصل 999 فوراً. انقل للظل أو التكييف؛ ضمادات باردة؛ لا تعطِ سوائل إن كان فاقد الوعي.',
      'Hindi': 'तुरंत 999 पर कॉल करें। छाया/AC; गीले कपड़े; बेहोश हो तो पानी न दें।',
      'Urdu': 'فوراً 999 پر کال کریں۔ سایہ/AC؛ گila کپڑے؛ بے ہوش ہو تو پani نہ دیں۔',
      'Bengali': 'অবিলম্বে 999 কল করুন। ছায়া/AC; ভেজা কাপড়; অচেতন হলে তরল নয়।',
      'Filipino': 'Tawagan agad ang 999. Lilim/AC; basang basahan; huwag bigyan ng tubig kung walang malay.',
      'Malayalam': 'Call 999 immediately. Move to shade or AC; cool with wet cloths.',
      'Nepali': 'Call 999 immediately. Move to shade or AC; cool with wet cloths.',
    },
    'guide_emergency_call': {
      'English': 'Call 999 — Qatar emergency',
      'Arabic': 'اتصل 999 — طوارئ قطر',
      'Hindi': '999 कॉल करें — कतर आपातकाल',
      'Urdu': '999 کال — قطر ایمرجنسی',
      'Bengali': '999 কল — কাতার জরুরি',
      'Filipino': 'Tawagan ang 999 — Qatar emergency',
      'Malayalam': 'Call 999 — Qatar emergency',
      'Nepali': 'Call 999 — Qatar emergency',
    },
    'symptom_checker_title': {
      'English': 'Heat illness symptom checker',
      'Arabic': 'فحص أعراض أمراض الحر',
      'Hindi': 'गर्मी बीमारी लक्षण जाँच',
      'Urdu': 'گرمی کی بیماری چیکر',
      'Bengali': 'তাপ অসুস্থতা চেকার',
      'Filipino': 'Heat illness symptom checker',
      'Malayalam': 'Heat illness symptom checker',
      'Nepali': 'Heat illness symptom checker',
    },
    'open_guide': {
      'English': 'Open heat illness guide',
      'Arabic': 'افتح دليل أمراض الحر',
      'Hindi': 'गर्मी गाइड खोलें',
      'Urdu': 'گرمی گائیڈ کھولیں',
      'Bengali': 'গাইড খুলুন',
      'Filipino': 'Buksan ang heat guide',
      'Malayalam': 'Open heat illness guide',
      'Nepali': 'Open heat illness guide',
    },
    'cooling_title': {
      'English': 'Nearby cooling spots',
      'Arabic': 'أماكن التبريد القريبة',
      'Hindi': 'पास की ठंडी जगहें',
      'Urdu': 'قریبی ٹھنڈی جگہیں',
      'Bengali': 'কাছের শীতল স্থান',
      'Filipino': 'Malapit na cooling spots',
      'Malayalam': 'Nearby cooling spots',
      'Nepali': 'Nearby cooling spots',
    },
    'cooling_subtitle': {
      'English':
          'Verified malls, metro, mosques, hospitals & shaded parks to escape the heat.',
      'Arabic':
          'مراكز تسوق ومترو ومساجد ومستشفيات وحدائق مظللة موثقة للهروب من الحر.',
      'Hindi':
          'गर्मी से बचने के लिए verified malls, metro, mosques, hospitals और shaded parks।',
      'Urdu':
          'گرمی سے بچنے کے لیے verified malls، metro، مساجد، hospitals اور shaded parks۔',
      'Bengali':
          'গরম থেকে বাঁচতে verified malls, metro, mosques, hospitals ও shaded parks।',
      'Filipino':
          'Verified malls, metro, mosques, hospitals at shaded parks para umiwas sa init.',
      'Malayalam':
          'Verified malls, metro, mosques, hospitals & shaded parks to escape the heat.',
      'Nepali':
          'Verified malls, metro, mosques, hospitals & shaded parks to escape the heat.',
    },
    'cooling_location_near': {
      'English': 'Sorted by distance from {location}',
      'Arabic': 'مرتبة حسب المسافة من {location}',
      'Hindi': '{location} से दूरी के अनुसार',
      'Urdu': '{location} سے فاصلے کے مطابق',
      'Bengali': '{location} থেকে দূরত্ব অনুযায়ী',
      'Filipino': 'Ayos ayon sa distansya mula sa {location}',
      'Malayalam': 'Sorted by distance from {location}',
      'Nepali': 'Sorted by distance from {location}',
    },
    'cooling_location_doha': {
      'English': 'Doha (default)',
      'Arabic': 'الدوحة (افتراضي)',
      'Hindi': 'दोहा (डिफ़ॉल्ट)',
      'Urdu': 'دوحہ (ڈیفالٹ)',
      'Bengali': 'দোহা (ডিফল্ট)',
      'Filipino': 'Doha (default)',
      'Malayalam': 'Doha (default)',
      'Nepali': 'Doha (default)',
    },
    'cooling_location_fallback': {
      'English':
          'Location unavailable — showing Doha defaults. Enable location for nearest results.',
      'Arabic':
          'الموقع غير متاح — عرض افتراضيات الدوحة. فعّل الموقع للنتائج الأقرب.',
      'Hindi':
          'Location unavailable — Doha defaults दिखा रहे हैं। निकटतम परिणामों के लिए location चालू करें।',
      'Urdu':
          'Location unavailable — Doha defaults دکھا رہے ہیں۔ قریبی نتائج کے لیے location چalu کریں۔',
      'Bengali':
          'Location unavailable — Doha defaults দেখাচ্ছি। নিকটতম ফলাফলের জন্য location চalu করুন।',
      'Filipino':
          'Location unavailable — Doha defaults. I-enable ang location para sa pinakamalapit.',
      'Malayalam':
          'Location unavailable — showing Doha defaults. Enable location for nearest results.',
      'Nepali':
          'Location unavailable — showing Doha defaults. Enable location for nearest results.',
    },
    'cooling_filter_all': {
      'English': 'All',
      'Arabic': 'الكل',
      'Hindi': 'सभी',
      'Urdu': 'سب',
      'Bengali': 'সব',
      'Filipino': 'Lahat',
      'Malayalam': 'All',
      'Nepali': 'All',
    },
    'cooling_type_mall': {
      'English': 'Mall',
      'Arabic': 'مول',
      'Hindi': 'Mall',
      'Urdu': 'Mall',
      'Bengali': 'Mall',
      'Filipino': 'Mall',
      'Malayalam': 'Mall',
      'Nepali': 'Mall',
    },
    'cooling_type_metro': {
      'English': 'Metro',
      'Arabic': 'مترو',
      'Hindi': 'Metro',
      'Urdu': 'Metro',
      'Bengali': 'Metro',
      'Filipino': 'Metro',
      'Malayalam': 'Metro',
      'Nepali': 'Metro',
    },
    'cooling_type_mosque': {
      'English': 'Mosque',
      'Arabic': 'مسجد',
      'Hindi': 'Masjid',
      'Urdu': 'Masjid',
      'Bengali': 'Masjid',
      'Filipino': 'Mosque',
      'Malayalam': 'Mosque',
      'Nepali': 'Mosque',
    },
    'cooling_type_hospital': {
      'English': 'Hospital',
      'Arabic': 'مستشفى',
      'Hindi': 'Hospital',
      'Urdu': 'Hospital',
      'Bengali': 'Hospital',
      'Filipino': 'Hospital',
      'Malayalam': 'Hospital',
      'Nepali': 'Hospital',
    },
    'cooling_type_library': {
      'English': 'Library',
      'Arabic': 'مكتبة',
      'Hindi': 'Library',
      'Urdu': 'Library',
      'Bengali': 'Library',
      'Filipino': 'Library',
      'Malayalam': 'Library',
      'Nepali': 'Library',
    },
    'cooling_type_shaded': {
      'English': 'Shaded park',
      'Arabic': 'حديقة مظللة',
      'Hindi': 'Shaded park',
      'Urdu': 'Shaded park',
      'Bengali': 'Shaded park',
      'Filipino': 'Shaded park',
      'Malayalam': 'Shaded park',
      'Nepali': 'Shaded park',
    },
    'cooling_verified': {
      'English': 'Verified',
      'Arabic': 'موثّق',
      'Hindi': 'Verified',
      'Urdu': 'Verified',
      'Bengali': 'Verified',
      'Filipino': 'Verified',
      'Malayalam': 'Verified',
      'Nepali': 'Verified',
    },
    'cooling_unverified': {
      'English': 'Google · unverified',
      'Arabic': 'Google · غير موثّق',
      'Hindi': 'Google · unverified',
      'Urdu': 'Google · unverified',
      'Bengali': 'Google · unverified',
      'Filipino': 'Google · unverified',
      'Malayalam': 'Google · unverified',
      'Nepali': 'Google · unverified',
    },
    'cooling_live_banner': {
      'English':
          'Orange markers are unverified Google Places results — tap Verified filter to hide them.',
      'Arabic':
          'العلامات البرتقالية نتائج Google Places غير موثقة — استخدم فلتر Verified لإخفائها.',
      'Hindi':
          'Orange markers unverified Google Places results हैं — Verified filter से छुपाएँ।',
      'Urdu':
          'Orange markers unverified Google Places results ہیں — Verified filter سے چھپائیں۔',
      'Bengali':
          'Orange markers unverified Google Places results — Verified filter দিয়ে লুকান।',
      'Filipino':
          'Orange markers ay unverified Google Places — gamitin ang Verified filter.',
      'Malayalam':
          'Orange markers are unverified Google Places results — tap Verified filter to hide them.',
      'Nepali':
          'Orange markers are unverified Google Places results — tap Verified filter to hide them.',
    },
    'cooling_empty': {
      'English': 'No cooling spots in this area for the selected filter.',
      'Arabic': 'لا توجد أماكن تبريد في هذه المنطقة للفلتر المحدد.',
      'Hindi': 'Selected filter के लिए इस क्षेत्र में कोई cooling spot नहीं।',
      'Urdu': 'Selected filter کے لیے اس علاقے میں کوئی cooling spot نہیں۔',
      'Bengali': 'Selected filter-এর জন্য এই এলাকায় কোনো cooling spot নেই।',
      'Filipino': 'Walang cooling spots sa filter na ito.',
      'Malayalam': 'No cooling spots in this area for the selected filter.',
      'Nepali': 'No cooling spots in this area for the selected filter.',
    },
    'cooling_search_places': {
      'English': 'Find more on Google (unverified)',
      'Arabic': 'ابحث أكثر على Google (غير موثّق)',
      'Hindi': 'Google पर और खोजें (unverified)',
      'Urdu': 'Google پر مزید تلاش (unverified)',
      'Bengali': 'Google-এ আরও খুঁজুন (unverified)',
      'Filipino': 'Maghanap pa sa Google (unverified)',
      'Malayalam': 'Find more on Google (unverified)',
      'Nepali': 'Find more on Google (unverified)',
    },
    'cooling_places_no_key': {
      'English':
          'Google Places search is not configured. Verified spots are still available.',
      'Arabic':
          'بحث Google Places غير مُعد. الأماكن الموثقة لا تزال متاحة.',
      'Hindi':
          'Google Places search configure नहीं है। Verified spots अभी भी उपलब्ध हैं।',
      'Urdu':
          'Google Places search configure نہیں۔ Verified spots اب بھی دستیاب ہیں۔',
      'Bengali':
          'Google Places search configure নয়। Verified spots এখনও available।',
      'Filipino':
          'Google Places search hindi naka-configure. Verified spots available pa rin.',
      'Malayalam':
          'Google Places search is not configured. Verified spots are still available.',
      'Nepali':
          'Google Places search is not configured. Verified spots are still available.',
    },
    'section_conditions_overline': l10nEntry(
      english: 'Live conditions',
      arabic: 'الظروف الحية',
      hindi: 'लाइव स्थिति',
      urdu: 'لائیو حالات',
    ),
    'section_conditions_title': l10nEntry(
      english: 'Heat & weather',
      arabic: 'الحرارة والطقس',
      hindi: 'गर्मी और मौसम',
      urdu: 'گرمی اور موسم',
    ),
    'section_route_overline': l10nEntry(
      english: 'Plan a journey',
      arabic: 'خطّط رحلة',
      hindi: 'यात्रा की योजना',
      urdu: 'سفر کی منصوبہ بندی',
    ),
    'section_route_title': l10nEntry(
      english: 'Heat-safe routes',
      arabic: 'مسارات آمنة من الحر',
      hindi: 'गर्मी-सुरक्षित रास्ते',
      urdu: 'گرمی سے محفوظ راستے',
    ),
    'section_acclimat_overline': l10nEntry(
      english: 'Heat adaptation',
      arabic: 'التكيف مع الحر',
      hindi: 'गर्मी के अनुकूलन',
      urdu: 'گرمی کے ساتھ موافقت',
      bengali: 'তাপ অভিযোজন',
      tamil: 'வெப்பத் தகவமைப்பு',
      malayalam: 'ചൂട് അക്ലൈമാറ്റേഷൻ',
      nepali: 'ताप अनुकूलन',
      filipino: 'Pag-adjust sa init',
    ),
    'section_acclimat_title': l10nEntry(
      english: 'Acclimatization tracker',
      arabic: 'متتبع التكيف',
      hindi: 'अक्लाइमेटाइज़ेशन ट्रैकर',
      urdu: 'گرمی کے ساتھ ڈھلنے کا ٹریکر',
      bengali: 'অ্যাক্লাইম্যাটাইজেশন ট্র্যাকার',
      tamil: 'வெப்பத் தகவ ட്രாக்கர்',
      malayalam: 'അക്ലൈമറ്റൈസേഷൻ ട്രാക്കർ',
      nepali: 'अक्लाइमेटाइजेसन ट्र्याकर',
      filipino: 'Tracker ng pag-adjust sa init',
    ),
    'acclimat_storage_error': l10nEntry(
      english: 'Could not save acclimatization settings on this device.',
      arabic: 'تعذر حفظ إعدادات التكيف على هذا الجهاز.',
      hindi: 'इस डिवाइस पर अक्लाइमेटाइज़ेशन सेटिंग्स सहेजी नहीं जा सकीं।',
      urdu: 'اس ڈیوائس پر یکسانیت کی ترتیبات محفوظ نہیں ہو سکیں۔',
      bengali: 'এই ডিভাইসে অ্যাক্লাইম্যাটাইজেশন সেটিংস সংরক্ষণ হয়নি।',
      tamil: 'இந்த சாதனத்தில் அமைப்புகளைச் சேமிக்க முடியவில்லை.',
      malayalam: 'ഈ ഉപകരണത്തിൽ സജ്ജീകരണം സേവ് ചെയ്യാനായില്ല.',
      nepali: 'यो यन्त्रमा अक्लाइमेटाइजेसन सेटिङ बचत भएन।',
      filipino: 'Hindi ma-save ang acclimatization settings sa device na ito.',
    ),
    'acclimat_concierge_prefill_error': l10nEntry(
      english: 'Could not load Concierge arrival date. Try again later.',
      arabic: 'تعذر تحميل تاريخ الوصول من خدمة الـ90 يومًا. حاول لاحقًا.',
      hindi: 'कॉन्सिएर्ज आगमन तिथि लोड नहीं हो सकी। बाद में पुनः प्रयास करें।',
      urdu: 'کنسیئرج آمد کی تاریخ لوڈ نہیں ہو سکی۔ بعد میں کوشش کریں۔',
      bengali: 'কনসিয়ার্জ আগমনের তারিখ লোড হয়নি। পরে আবার চেষ্টা করুন।',
      tamil: 'கான்சியர்ஜ் வருகை தேதியை ஏற்ற முடியவில்லை. பிறகு முயற்சிக்கவும்.',
      malayalam: 'ക്യോൺസിയേഴ്ജ് തീയതി ലോഡ് ചെയ്യാനായില്ല. പിന്നീട് ശ്രമിക്കുക.',
      nepali: 'कन्सियर्ज आगमन मिति लोड हुन सकेन। पछि पुन: प्रयास गर्नुहोस्।',
      filipino:
          'Hindi ma-load ang Concierge arrival date. Subukan muli mamaya.',
    ),
    'acclimat_outdoor_question': l10nEntry(
      english: 'Do you work outdoors or in hot indoor places?',
      arabic: 'هل تعمل في الهواء الطلق أو في أماكن داخلية حارة؟',
      hindi: 'क्या आप बाहर या गर्म इनडोर जगहों पर काम करते हैं?',
      urdu: 'کیا آپ باہر یا گرم اندرونی جگہوں پر کام کرتے ہیں؟',
      bengali: 'আপনি কি বাইরে বা গরম ঘরের ভিতরে কাজ করেন?',
      tamil: 'நீங்கள் வெளியில் அல்லது சூடான உட்புறத்தில் வேலை செய்கிறீர்களா?',
      malayalam: 'നിങ്ങൾ പുറത്തോ ചൂടുള്ള ഇൻഡോറിലോ ജോലി ചെയ്യുന്നുണ്ടോ?',
      nepali: 'के तपाईं बाहिर वा तातो भित्री ठाउँमा काम गर्नुहुन्छ?',
      filipino: 'Nagtatrabaho ka ba sa labas o sa mainit na loob?',
    ),
    'acclimat_outdoor_yes': l10nEntry(
      english: 'Yes',
      arabic: 'نعم',
      hindi: 'हाँ',
      urdu: 'ہاں',
      bengali: 'হ্যাঁ',
      tamil: 'ஆம்',
      malayalam: 'അതെ',
      nepali: 'हो',
      filipino: 'Oo',
    ),
    'acclimat_outdoor_no': l10nEntry(
      english: 'No',
      arabic: 'لا',
      hindi: 'नहीं',
      urdu: 'نہیں',
      bengali: 'না',
      tamil: 'இல்லை',
      malayalam: 'ഇല്ല',
      nepali: 'होइन',
      filipino: 'Hindi',
    ),
    'acclimat_entry_prompt': l10nEntry(
      english:
          'Starting outdoor work in the heat, or back after time away?',
      arabic: 'تبدأ العمل في الحر بالخارج، أم عدت بعد غياب؟',
      hindi: 'गर्मी में बाहरी काम शुरू कर रहे हैं, या छुट्टी के बाद लौटे हैं?',
      urdu: 'گرمی میں بیرونی کام شروع کر رہے ہیں، یا واپسی کے بعد؟',
      bengali: 'গরমে বাইরে কাজ শুরু, নাকি ছুটির পর ফিরেছেন?',
      tamil: 'வெப்பத்தில் வெளி வேலையா, இல்லை விடுப்புக்குப் பிறகா?',
      malayalam: 'ചൂടിൽ പുറം ജോലിയിലേയോ, അവധിക്ക് ശേഷം തിരിച്ചുവന്നോ?',
      nepali: 'तातोमा बाहिर काम सुरु, वा बिरामी पछि फर्कनुभयो?',
      filipino:
          'Magsisimula sa init sa labas, o balik pagkatapos ng pahinga?',
    ),
    'acclimat_choice_new': l10nEntry(
      english: "I'm new to working in Qatar's heat",
      arabic: 'أنا جديد على العمل في حر قطر',
      hindi: 'मैं कतर की गर्मी में काम करने में नया/नई हूँ',
      urdu: 'میں قطر کی گرمی میں کام کرنے میں نیا ہوں',
      bengali: 'আমি কাতারের গরমে কাজে নতুন',
      tamil: 'கத்தாரின் வெப்ப வேலைக்கு நான் புதியவர்',
      malayalam: 'ഖത്തറിയുടെ ചൂടിൽ ജോലി ചെയ്യാൻ ഞാൻ പുതുതാണ്',
      nepali: 'कतारको तातोमा काम गर्न म नयाँ छु',
      filipino: 'Bago ako sa init sa Qatar',
    ),
    'acclimat_choice_returning': l10nEntry(
      english: "I'm back after a week or more away",
      arabic: 'عدت بعد أسبوع أو أكثر من الغياب',
      hindi: 'एक सप्ताह या उससे अधिक की छुट्टी के बाद लौटा/लौटी हूँ',
      urdu: 'ایک ہفتے یا اس سے زیادہ کی چھٹی کے بعد واپس',
      bengali: 'এক সপ্তাহ বা তার বেশি ছুটির পর ফিরেছি',
      tamil: 'ஒரு வாரம் அல்லது அதற்கு மேல் விடுப்பிற்குப் பிறகு திரும்பினேன்',
      malayalam: 'ഒരു ആഴ്ചയോ അതിൽ കൂടുതലോ കഴിഞ്ഞ് മടങ്ങി',
      nepali: 'एक हप्ता वा बढी बिदा पछि फर्किएँ',
      filipino: 'Bumalik ako pagkatapos ng isang linggo o higit pa',
    ),
    'acclimat_start_date_label': l10nEntry(
      english: 'Start date',
      arabic: 'تاريخ البدء',
      hindi: 'शुरुआत की तारीख',
      urdu: 'شروع کی تاریخ',
      bengali: 'শুরুর তারিখ',
      tamil: 'தொடக்க தேதி',
      malayalam: 'ആരംഭ തീയതി',
      nepali: 'सुरु मिति',
      filipino: 'Petsa ng simula',
    ),
    'acclimat_concierge_prefill': l10nEntry(
      english: 'Use arrival date from 90-day Concierge (optional)',
      arabic: 'استخدم تاريخ الوصول من خدمة الـ90 يومًا (اختياري)',
      hindi: '90-दिवसीय कॉन्सिएर्ज से आगमन तिथि लें (वैकल्पिक)',
      urdu: '90 دن کے کنسیئرج سے آمد کی تاریخ (اختیاری)',
      bengali: '৯০ দিনের কনসিয়ার্জ থেকে আগমনের তারিখ (ঐচ্ছিক)',
      tamil: '90 நாள் கான்சியர்ஜ் வருகை தேதி (விரும்பினால்)',
      malayalam: '90 ദിവസ ക്യോൺസിയേഴ്ജ് എത്തൽ തീയതി (ഓപ്ഷണൽ)',
      nepali: '90-दिन कन्सियर्ज आगमन मिति (वैकल्पिक)',
      filipino: 'Gamitin ang arrival date mula sa 90-day Concierge (opsyonal)',
    ),
    'acclimat_concierge_prefill_unavailable': l10nEntry(
      english: 'No Concierge arrival date is saved yet.',
      arabic: 'لم يُحفظ تاريخ وصول في خدمة الـ90 يومًا بعد.',
      hindi: 'कॉन्सिएर्ज में अभी कोई आगमन तिथि सहेजी नहीं गई।',
      urdu: 'کنسیئرج میں ابھی آمد کی تاریخ محفوظ نہیں۔',
      bengali: 'কনসিয়ার্জে এখনও আগমনের তারিখ নেই।',
      tamil: 'கான்சியர்ஜில் வருகை தேதி இன்னும் சேமிக்கப்படவில்லை.',
      malayalam: 'ക്യോൺസിയേഴ്ജിൽ എത്തൽ തീയതി ഇതുവരെ സേവ് ചെയ്തിട്ടില്ല.',
      nepali: 'कन्सियर्जमा अहिलेसम्म आगमन मिति सुरक्षित छैन।',
      filipino: 'Walang naka-save na Concierge arrival date pa.',
    ),
    'acclimat_save': l10nEntry(
      english: 'Save start date',
      arabic: 'احفظ تاريخ البدء',
      hindi: 'शुरुआत की तारीख सहेजें',
      urdu: 'شروع کی تاریخ محفوظ کریں',
      bengali: 'শুরুর তারিখ সংরক্ষণ',
      tamil: 'தொடக்க தேதியைச் சேமி',
      malayalam: 'ആരംഭ തീയതി സേവ് ചെയ്യുക',
      nepali: 'सुरु मिति बचत गर्नुहोस्',
      filipino: 'I-save ang petsa ng simula',
    ),
    'acclimat_edit': l10nEntry(
      english: 'Edit plan',
      arabic: 'تعديل الخطة',
      hindi: 'योजना संपादित करें',
      urdu: 'منصوبہ ترمیم',
      bengali: 'পরিকল্পনা সম্পাদনা',
      tamil: 'திட்டத்தைத் திருத்து',
      malayalam: 'പ്ലാൻ എഡിറ്റ് ചെയ്യുക',
      nepali: 'योजना सम्पादन',
      filipino: 'I-edit ang plano',
    ),
    'acclimat_clear': l10nEntry(
      english: 'Clear saved plan',
      arabic: 'مسح الخطة المحفوظة',
      hindi: 'सहेजी गई योजना मिटाएँ',
      urdu: 'محفوظ منصوبہ صاف کریں',
      bengali: 'সংরক্ষিত পরিকল্পনা মুছুন',
      tamil: 'சேமித்த திட்டத்தை அழி',
      malayalam: 'സേവ് ചെയ്ത പ്ലാൻ നീക്കം ചെയ്യുക',
      nepali: 'बचत गरिएको योजना हटाउनुहोस्',
      filipino: 'Burahin ang na-save na plano',
    ),
    'acclimat_active_summary': l10nEntry(
      english: 'Tracking: {type}. Start date: {date}.',
      arabic: 'التتبع: {type}. تاريخ البدء: {date}.',
      hindi: 'ट्रैकिंग: {type}. शुरुआत: {date}.',
      urdu: 'ٹریکنگ: {type}. شروع: {date}.',
      bengali: 'ট্র্যাকিং: {type}. শুরু: {date}.',
      tamil: 'கண்காணிப்பு: {type}. தொடக்கம்: {date}.',
      malayalam: 'ട്രാക്കിംഗ്: {type}. ആരംഭം: {date}.',
      nepali: 'ट्र्याकिङ: {type}. सुरु: {date}.',
      filipino: 'Tracking: {type}. Simula: {date}.',
    ),
    'acclimat_scaffold_note': l10nEntry(
      english:
          'Daily heat-exposure guidance will appear here after official sources are verified in a later update.',
      arabic: 'سيظهر هنا إرشاد التعرض اليومي للحر بعد التحقق من المصادر الرسمية في تحديث لاحق.',
      hindi: 'आधिकारिक स्रोतों के सत्यापन के बाद दैनिक गर्मी-जोखिम मार्गदर्शन यहाँ दिखेगा।',
      urdu: 'سرکاری ذرائع کی تصدیق کے بعد روزانہ گرمی کی ہدایت یہاں ظاہر ہوگی۔',
      bengali: 'সরকারি উৎস যাচাইয়ের পর দৈনিক তাপ নির্দেশনা এখানে দেখাবে।',
      tamil: 'அதிகார ஆதாரங்கள் சரிபார்க்கப்பட்ட பிறகு தினசரி வழிகாட்டுதல் இங்கே வரும்.',
      malayalam: 'ഔദ്യോഗിക സ്രോതസ്സുകൾ പരിശോധിച്ചതിന് ശേഷം ദൈനംദിന മാർഗ്ഗനിർദ്ദേശം ഇവിടെ കാണിക്കും.',
      nepali: 'आधिकारिक स्रोत प्रमाणित पछि दैनिक मार्गदर्शन यहाँ देखिनेछ।',
      filipino:
          'Lalabas dito ang gabay sa init pagkatapos ma-verify ang opisyal na sources.',
    ),
    'acclimat_schedule_disclaimer_occupational': l10nEntry(
      english:
          'Occupational guidance based on NIOSH/OSHA acclimatization references. Not Qatari law or medical clearance.',
      arabic:
          'إرشاد مهني مستمد من مراجع NIOSH/OSHA. ليس قانون قطر ولا تصريحاً طبياً.',
      hindi:
          'NIOSH/OSHA संदर्भ पर व्यावसायिक मार्गदर्शन। कतरी कानून या चिकित्सा मंजूरी नहीं।',
      urdu:
          'NIOSH/OSHA حوالہ پر پیشہ ورانہ رہنمائی۔ قطری قانون یا طبی کلیئرنس نہیں۔',
      bengali:
          'NIOSH/OSHA রেফারেন্স ভিত্তিক পেশাদার নির্দেশনা। কাতারি আইন বা চিকিৎসা ছাড়পত্র নয়।',
      tamil:
          'NIOSH/OSHA குறிப்பு அடிப்படையிலான தொழில்முறை வழிகாட்டல். கத்தார் சட்டம் அல்லது மருத்துவ அனுமதி அல்ல.',
      malayalam:
          'NIOSH/OSHA അടിസ്ഥാനത്തിലുള്ള തൊഴിൽ മാർഗ്ഗദർശനം. ഖത്തർ നിയമമോ medical clearance അല്ല.',
      nepali:
          'NIOSH/OSHA सन्दर्भमा व्यावसायिक मार्गदर्शन। कतारी कानून वा चिकित्सा क्लियरेन्स होइन।',
      filipino:
          'Gabay sa trabaho batay sa NIOSH/OSHA. Hindi batas ng Qatar o medical clearance.',
    ),
    'acclimat_schedule_disclaimer_not_proof': l10nEntry(
      english:
          'This tracker is not proof that you are acclimatized to heat.',
      arabic: 'هذا المتتبع ليس دليلاً على تكيّفك مع الحر.',
      hindi: 'यह ट्रैकर गर्मी के अनुकूलन का प्रमाण नहीं है।',
      urdu: 'یہ ٹریکر گرمی کے ساتھ موافقت کا ثبوت نہیں۔',
      bengali: 'এই ট্র্যাকার তাপের সাথে অভিযোজনের প্রমাণ নয়।',
      tamil: 'இந்த டிராக்கர் வெப்பத்துக்கு தகவமைந்ததற்கான சான்று அல்ல.',
      malayalam:
          'ഈ ട്രാക്കർ ചൂടോട് അക്ലൈമറ്റ് ആയതിന്റെ തെളിവല്ല.',
      nepali:
          'यो ट्र्याकर तापसँग अनुकूलन भएको प्रमाण होइन।',
      filipino:
          'Hindi patunay ng acclimatization ang tracker na ito.',
    ),
    'acclimat_schedule_disclaimer_risk': l10nEntry(
      english:
          'Acclimatization does not remove heat-illness risk. Employer controls, rest, hydration, task intensity and PPE still matter.',
      arabic:
          'التكيّف لا يزيل مخاطر أمراض الحر. ضوابط صاحب العمل والراحة والماء وشدة المهام ومعدات الوقاية ما زالت مهمة.',
      hindi:
          'अक्लाइमेटाइज़ेशन गर्मी-बीमारी का जोखिम समाप्त नहीं करता। नियोक्ता नियंत्रण, आराम, पानी, काम की तीव्रता और PPE अभी भी महत्वपूर्ण हैं।',
      urdu:
          'موافقت گرمی کی بیماری کا خطر ختم نہیں کرتی۔ آراام، پانی، کام کی شدت اور PPE اب بھی اہم ہیں۔',
      bengali:
          'অ্যাক্লাইমেটাইজেশন তাপজনিত ঝুঁকি দূর করে না। বিশ্রাম, পানি, কাজের তীব্রতা ও PPE এখনও গুরুত্বপূর্ণ।',
      tamil:
          'தகவமைப்பு வெப்ப நோய் அபாயத்தை நீக்காது. ஓய்வு, நீர், வேலை தீவிரம், PPE இன்னும் முக்கியம்.',
      malayalam:
          'അക്ലൈമറ്റേഷൻ ചൂട് അസുഖം അപകടം നീക്കുന്നില്ല. വിശ്രամം, ജലം, ജോലി തീവ്രത, PPE പ്രധാനമാണ്.',
      nepali:
          'अनुकूलनले तापबाट हुने जोखिम हटाउँदैन। आराम, पानी, कामको तीव्रता र PPE अझै महत्त्वपूर्ण छन्।',
      filipino:
          'Hindi inaalis ng acclimatization ang panganib sa heat illness. Mahalaga pa rin ang pahinga, tubig, bigat ng trabaho at PPE.',
    ),
    'acclimat_schedule_plan_day': l10nEntry(
      english: 'Plan day {day} (Qatar calendar)',
      arabic: 'يوم الخطة {day} (تقويم قطر)',
      hindi: 'योजना दिवस {day} (कतर कैलेंडर)',
      urdu: 'منصوبے کا دن {day} (قطر کیلنڈر)',
      bengali: 'পরিকল্পনা দিন {day} (কাতার ক্যালেন্ডার)',
      tamil: 'திட்ட நாள் {day} (கத்தார் நாட்காட்டி)',
      malayalam: 'പ്ലാൻ ദിവസം {day} (ഖത്തർ കലണ്ടർ)',
      nepali: 'योजना दिन {day} (कतार पात्रो)',
      filipino: 'Plan day {day} (Qatar calendar)',
    ),
    'acclimat_schedule_exposure_cap': l10nEntry(
      english:
          'Reference exposure cap: up to {percent}% of your employer\'s usual daily heat-exposure duration.',
      arabic:
          'حد مرجعي للتعرض: حتى {percent}% من مدة التعرض اليومية المعتادة لدى صاحب العمل.',
      hindi:
          'संदर्भ सीमा: नियोक्ता की सामान्य दैनिक गर्मी-अवधि का {percent}% तक।',
      urdu:
          'حوالہ حد: آجر کی عام روزانہ گرمی دورانیے کا {percent}% تک۔',
      bengali:
          'রেফারেন্স সীমা: নিয়োগকর্তার সাধারণ দৈনিক তাপ-সময়ের {percent}% পর্যন্ত।',
      tamil:
          'குறிப்பு வரம்பு: முதலாளியின் வழக்கமான தினசரி வெப்ப வேலை நேரத்தின் {percent}% வரை.',
      malayalam:
          'റഫറൻസ് പരമാവധി: തൊഴിലدارന്റെ സാധാരണ ദൈനംദിന ചൂട്-സമയത്തിന്റെ {percent}% വരെ.',
      nepali:
          'सन्दर्भ सीमा: रोजगारदाताको सामान्य दैनिक ताप-अवधिको {percent}% सम्म।',
      filipino:
          'Reference cap: hanggang {percent}% ng karaniwang heat exposure ng employer.',
    ),
    'acclimat_schedule_baseline_explainer': l10nEntry(
      english:
          'Your employer defines the usual daily duration spent working in hot conditions. Raabta does not count hours here.',
      arabic:
          'يحدد صاحب العمل مدة العمل اليومية المعتادة في البيئة الحارة. رابطة لا تحسب الساعات هنا.',
      hindi:
          'नियोक्ता गर्म परिस्थितियों में सामान्य दैनिक अवधि तय करता है। राब्ता यहाँ घंटे नहीं गिनती।',
      urdu:
          'آجر گرم حالات میں روزانہ معمول کا دورانیہ طے کرتا ہے۔ رابطہ یہاں گھنٹے شمار نہیں کرتی۔',
      bengali:
          'নিয়োগকর্তা গরম পরিবেশে সাধারণ দৈনিক সময় নির্ধারণ করে। রাবতা এখানে ঘণ্টা গণনা করে না।',
      tamil:
          'முதலாளி சூடான சூழலில் வழக்கமான தினசரி நேரத்தை வரையறுக்கிறார். ராப்தா இங்கே மணிநேரம் கணக்கிடாது.',
      malayalam:
          'തൊഴിലുടമ ചൂടുള്ള സാഹചര്യത്തെ സാധാരണ ദൈനംദിന സമയം നിശ്ചയിക്കുന്നു. റാബ്ത ഇവിടെ മണിക്കൂർ കണക്കാക്കുന്നില്ല.',
      nepali:
          'रोजगारदाताले तातो वातावरणको सामान्य दैनिक अवधि तोक्छ। राब्ताले यहाँ घण्टा गन्ने छैन।',
      filipino:
          'Tinutukoy ng employer ang karaniwang oras sa init. Hindi binibilang ng Raabta ang oras dito.',
    ),
    'acclimat_schedule_guidance_ramp': l10nEntry(
      english:
          'Increase time in the heat gradually per your employer\'s plan — today\'s reference cap is {percent}%. Take rest, water, and shade breaks.',
      arabic:
          'زِد وقت التعرض للحر تدريجياً وفق خطة صاحب العمل — حد اليوم المرجعي {percent}%. خذ راحة وماء وظلاً.',
      hindi:
          'नियोक्ता की योजना के अनुसार गर्मी में समय धीरे-धीरे बढ़ाएँ — आज की सीमा {percent}%। आराम, पानी और छाया लें।',
      urdu:
          'آجر کے منصوبے کے مطابق گرمی میں وقت بتدریج بڑھائیں — آج کی حد {percent}%۔ آرام، پانی اور سایہ لیں۔',
      bengali:
          'নিয়োগকর্তার পরিকল্পনা অনুযায়ী ধীরে ধীরে তাপ বাড়ান — আজকের সীমা {percent}%। বিশ্রাম, পানি ও ছায়া নিন।',
      tamil:
          'முதலாளி திட்டப்படி வெப்ப நேரத்தை படிப்படியாக அதிகரியுங்கள் — இன்று {percent}%. ஓய்வு, நீர், நிழல்.',
      malayalam:
          'തൊഴിലുടമയുടെ പ്ലാൻ അനുസരിച്ച് ചൂടിൽ സമയം ക്രമേണ വർദ്ധിപ്പിക്കുക — ഇന്ന് {percent}%. വിശ്രാമം, വെള്ളം, തണൽ.',
      nepali:
          'रोजगारदाताको योजनाअनुसार तातोमा समय बिस्तारै बढाउनुहोस् — आज {percent}%। आराम, पानी, छाया लिनुहोस्।',
      filipino:
          'Dahan-dahang dagdagan ang oras sa init — reference cap ngayon {percent}%. Magpahinga, uminom, lilim.',
    ),
    'acclimat_schedule_guidance_supervision': l10nEntry(
      english:
          'Exposure reference cap is 100% of the employer baseline. Continue close supervision through plan day 14 — you are not labelled fully acclimatized in this app.',
      arabic:
          'حد التعرض المرجعي 100%. أشرف عن كثب حتى يوم 14 — التطبيق لا يصنّفك متكيفاً بالكامل.',
      hindi:
          'संदर्भ सीमा 100%। दिन 14 तक करीबी निगरानी जारी रखें — ऐप आपको पूर्ण अक्लाइमेटाइज़्ड नहीं कहता।',
      urdu:
          'حوالہ حد 100%۔ دن 14 تک نگرانی جاری رکھیں — ایپ مکمل موافق نہیں لکھتی۔',
      bengali:
          'রেফারেন্স সীমা 100%। ১৪তম দিন পর্যন্ত তদারকি চালিয়ে যান — অ্যাপ সম্পূর্ণ অ্যাক্লাইমেটাইজড বলে না।',
      tamil:
          'குறிப்பு வரம்பு 100%. 14ம் நாள் வரை கண்காணிப்பு — பூரண தகவமைப்பு என்று சொல்லப்படுவதில்லை.',
      malayalam:
          'റഫറൻസ് 100%. 14ാം ദിവസം വരെ supervision — പൂർണ അക്ലൈമറ്റ് എന്ന് പറയില്ല.',
      nepali:
          'सन्दर्भ सीमा 100%। दिन 14 सम्म निगरानी — पूर्ण अनुकूलित भनिन्न।',
      filipino:
          '100% reference cap. Superbisyun hanggang day 14 — hindi fully acclimatized ang label.',
    ),
    'acclimat_schedule_guidance_after_supervision': l10nEntry(
      english:
          'Exposure reference cap remains 100% of the employer baseline. Follow your employer\'s supervision and heat-control programme until acclimatization is established. Heat-illness risk remains — this app does not label you fully acclimatized.',
      arabic:
          'حد التعرض المرجعي يبقى 100%. اتبع إشراف صاحب العمل وبرنامج التحكم بالحر حتى يتأسس التكيّف. يبقى خطر أمراض الحر — التطبيق لا يصنّفك متكيفاً بالكامل.',
      hindi:
          'संदर्भ सीमा 100% बनी रहती है। अक्लाइमेटाइज़ेशन स्थापित होने तक नियोक्ता की निगरानी और गर्मी-नियंत्रण योजना का पालन करें। गर्मी-जोखिम बना रहता है — ऐप पूर्ण अक्लाइमेटाइज़्ड नहीं लिखता।',
      urdu:
          'حوالہ حد 100% برقرار ہے۔ موافقت قائم ہونے تک آجر کی نگرانی اور حرارت-کنٹرول پروگرام پر عمل کریں۔ خطرہ باقی — ایپ مکمل موافق نہیں لکھتی۔',
      bengali:
          'রেফারেন্স সীমা 100% থাকে। অ্যাক্লাইমেটাইজেশন প্রতিষ্ঠিত না হওয়া পর্যন্ত নিয়োগকর্তার তদারকি ও তাপ-নিয়ন্ত্রণ কর্মসূচি মানুন। ঝুঁকি রয়ে যায় — অ্যাপ সম্পূর্ণ অ্যাক্লাইমেটাইজড বলে না।',
      tamil:
          'குறிப்பு வரம்பு 100% நிலையில். தகவமைப்பு நிறுவப்படும் வரை முதலாளியின் மேற்பார்வை மற்றும் வெப்பக் கட்டுப்பாட்டைப் பின்பற்றுங்கள். அபாயம் தொடரும் — பூரண தகவமைப்பு என்று சொல்லப்படுவதில்லை.',
      malayalam:
          'റഫറൻസ് 100% നിലനിൽക്കുന്നു. അക്ലൈമറ്റേഷൻ സ്ഥാപിതമാകുന്ന വരെ തൊഴിലുടമയുടെ supervision, heat-control പരിപാലിക്കുക. അപകടം തുടരുന്നു.',
      nepali:
          'सन्दर्भ सीमा 100% रहन्छ। अनुकूलन स्थापित नभएसम्म रोजगारदाताको निगरानी र ताप नियन्त्रण कार्यक्रम पालना गर्नुहोस्। जोखिम रहन्छ — पूर्ण अनुकूलित भनिँदैन।',
      filipino:
          '100% ang reference cap. Sundin ang supervision at heat-control ng employer hanggang ma-establish ang acclimatization. May panganib pa — hindi fully acclimatized ang label.',
    ),
    'acclimat_schedule_guidance_not_started': l10nEntry(
      english:
          'Your start date is in the future. Exposure guidance begins on plan day 1.',
      arabic: 'تاريخ البدء في المستقبل. يبدأ الإرشاد من يوم الخطة 1.',
      hindi: 'आरंभ तिथि भविष्य में है। मार्गदर्शन दिन 1 से शुरू।',
      urdu: 'شروع کی تاریخ مستقبل میں ہے۔ ہدایت دن 1 سے شروع ہوگی۔',
      bengali: 'শুরুর তারিখ ভবিষ্যতে। দিন ১ থেকে নির্দেশনা।',
      tamil: 'தொடக்க தேதி எதிர்காலத்தில். வழிகாட்டல் நாள் 1 இல் தொடங்கும்.',
      malayalam: 'ആരംഭ തീയതി ഭാവിയിലാണ്. ദിവസം 1 മുതൽ മാർഗ്ഗനിർദേശം.',
      nepali: 'सुरु मिति भविष्यमा छ। दिन 1 बाट मार्गदर्शन।',
      filipino: 'Sa hinaharap ang start date. Magsisimula sa plan day 1.',
    ),
    'acclimat_schedule_not_started': l10nEntry(
      english: 'Plan not started yet',
      arabic: 'الخطة لم تبدأ بعد',
      hindi: 'योजना अभी शुरू नहीं हुई',
      urdu: 'منصوبہ ابھی شروع نہیں ہوا',
      bengali: 'পরিকল্পনা এখনও শুরু হয়নি',
      tamil: 'திட்டம் இன்னும் தொடங்கவில்லை',
      malayalam: 'പ്ലാൻ ഇതുവരെ ആരംഭിച്ചിട്ടില്ല',
      nepali: 'योजना अहिले सुरु भएको छैन',
      filipino: 'Hindi pa nagsisimula ang plan',
    ),
    'acclimat_schedule_source': l10nEntry(
      english:
          'Schedule reference: NIOSH 20% rule (CDC) and OSHA heat acclimatization guidance — educational only.',
      arabic:
          'مرجع الجدول: قاعدة NIOSH 20% (CDC) وإرشادات OSHA — للتعلم فقط.',
      hindi:
          'अनुसूची: NIOSH 20% नियम (CDC) और OSHA — केवल शिक्षण हेतु।',
      urdu:
          'شیڈول: NIOSH 20% اصول (CDC) اور OSHA — صرف تعلیم۔',
      bengali:
          'NIOSH 20% নিয়ম (CDC) ও OSHA — শুধু শিক্ষামূলক।',
      tamil:
          'NIOSH 20% விதி (CDC), OSHA — கல்விக்காக மட்டும்.',
      malayalam:
          'NIOSH 20% rule (CDC), OSHA — educational only.',
      nepali:
          'NIOSH 20% नियम (CDC), OSHA — शैक्षिक मात्र।',
      filipino:
          'NIOSH 20% rule (CDC), OSHA — pang-edukasyon lang.',
    ),
    'acclimat_heat_guide_link': l10nEntry(
      english: 'Open heat illness first aid',
      arabic: 'افتح إسعافات أمراض الحر',
      hindi: 'गर्मी की बीमारी प्राथमिक उपचार खोलें',
      urdu: 'گرمی کی بیماری کی ابتدائی طبی مدد کھولیں',
      bengali: 'তাপজনিত অসুস্থতার প্রাথমিক চিকিৎসা',
      tamil: 'வெப்ப நோய் முதலுதவி திற',
      malayalam: 'ചൂട് രോഗ പ്രഥമ ശുശ്രൂഷ തുറക്കുക',
      nepali: 'तापबाट हुने बिरामीको प्राथमिक उपचार खोल्नुहोस्',
      filipino: 'Buksan ang first aid sa heat illness',
    ),
    'section_workload_overline': l10nEntry(
      english: 'Learn about workload',
      arabic: 'تعرّف على عبء العمل',
      hindi: 'कार्यभार के बारे में जानें',
      urdu: 'کام کے بوجھ کے بارے میں جانیں',
      bengali: 'কাজের চাপ সম্পর্কে জানুন',
      tamil: 'வேலை சுமை பற்றி அறியுங்கள்',
      malayalam: 'ജോലിഭാരം പരിചയം',
      nepali: 'कार्यभार बुझ्नुहोस्',
      filipino: 'Alamin ang workload',
    ),
    'section_workload_title': l10nEntry(
      english: 'Workload & heat reference',
      arabic: 'عبء العمل ومرجع الحر',
      hindi: 'कार्यभार और गर्मी संदर्भ',
      urdu: 'کام کا بوجھ اور حرارت کا حوالہ',
      bengali: 'কাজের চাপ ও তাপ রেফারেন্স',
      tamil: 'வேலைச்சுமை & வெப்ப குறிப்பு',
      malayalam: 'ജോലിഭാരവും ചൂട് റഫറൻസ്',
      nepali: 'कार्यभार र ताप सन्दर्भ',
      filipino: 'Workload at heat reference',
    ),
    'workload_disclaimer_not_law': l10nEntry(
      english: 'Guidance based on ACGIH reference values. Not Qatari law.',
      arabic: 'إرشاد مبني على قيم مرجعية من ACGIH. ليس قانون قطر.',
      hindi: 'ACGIH संदर्भ मूल्यों पर आधारित मार्गदर्शन। कतरी कानून नहीं।',
      urdu: 'ACGIH حوالہ اقدار پر مبنی رہنمائی۔ قطری قانون نہیں۔',
      bengali: 'ACGIH রেফারেন্স মানের ভিত্তিতে নির্দেশনা। কাতারি আইন নয়।',
      tamil: 'ACGIH குறிப்பு மதிப்புகளை அடிப்படையாகக் கொண்ட வழிகாட்டல். கத்தார் சட்டம் அல்ல.',
      malayalam:
          'ACGIH റഫറൻസ് മൂല്യങ്ങളെ അടിസ്ഥാനമാക്കിയുള്ള മാർഗ്ഗദർശനം. ഖത്തർ നിയമമല്ല.',
      nepali:
          'ACGIH सन्दर्भ मानहरूमा आधारित मार्गदर्शन। कतारी कानून होइन।',
      filipino:
          'Gabay batay sa ACGIH reference values. Hindi batas ng Qatar.',
    ),
    'workload_disclaimer_weather_estimate': l10nEntry(
      english:
          "This is an estimate from weather data. It doesn't include sun/shade, clothing or the real conditions at your workplace. If you feel unwell, stop and use the first-aid card.",
      arabic:
          'هذا تقدير من بيانات الطقس. لا يشمل الشمس/الظل أو الملابس أو ظروف مكان عملك الفعلية. إذا شعرت بتوعك، توقف واستخدم بطاقة الإسعافات الأولية.',
      hindi:
          'यह मौसम डेटा से अनुमान है। धूप/छाया, कपड़े या आपके कार्यस्थल की वास्तविक स्थिति शामिल नहीं। अस्वस्थ लगे तो रुकें और प्राथमिक उपचार कार्ड देखें।',
      urdu:
          'یہ موسم کے ڈیٹا سے تخمینہ ہے۔ دھوپ/سایہ، لباس یا آپ کے کام کی جگہ کی اصل صورتِ حال شامل نہیں۔ اگر بیمار لگیں تو رکیں اور فرسٹ ایڈ کارڈ استعمال کریں۔',
      bengali:
          'এটি আবহাওয়ার তথ্য থেকে অনুমান। রোদ/ছায়া, পোশাক বা কর্মক্ষেত্রের প্রকৃত অবস্থা অন্তর্ভুক্ত নয়। অসুস্থ বোধ করলে থামুন এবং প্রাথমিক চিকিৎসা কার্ড ব্যবহার করুন।',
      tamil:
          'இது வானிலை தரவிலிருந்து ஒரு மதிப்பீடு. சூர்/நிழல், உடை அல்லது உண்மையான பணியிட நிலைகள் சேர்க்கப்படவில்லை. உடல்நலம் சரியில்லாவிட்டால் நிறுத்தி முதலுதவி அட்டை பயன்படுத்துங்கள்.',
      malayalam:
          'ഇത് കാലാവസ്ഥാ ഡാറ്റയിൽ നിന്നുള്ള ഏകദേശ അളവാണ്. സൂര്യപ്രകാശം/നിഴൽ, വസ്ത്രം, നിങ്ങളുടെ ജോലിസ്ഥലത്തിലെ യഥാർത്ഥ സാഹചര്യങ്ങൾ ഉൾപ്പെടുന്നില്ല. അസ്വസ്ഥത അനുഭവപ്പെട്ടാൽ നിർത്തി പ്രഥമശുശ്രൂഷ കാർഡ് ഉപയോഗിക്കുക.',
      nepali:
          'यो मौसम डाटाबाट अनुमान हो। घाम/छाया, लुगा वा कार्यस्थलको वास्तविक अवस्था समावेश छैन। अस्वस्थ महसुस भए रोक्नुहोस् र प्राथमिक उपचार कार्ड प्रयोग गर्नुहोस्।',
      filipino:
          "Tantya ito mula sa weather data. Hindi kasama ang araw/shade, damit o totoong kondisyon sa trabaho. Kung masama ang pakiramdam, tumigil at gamitin ang first-aid card.",
    ),
    'workload_selector_prompt': l10nEntry(
      english: 'What is your typical work exertion? (local only — for reference)',
      arabic: 'ما مستوى مجهود عملك المعتاد؟ (محلي فقط — للمرجع)',
      hindi: 'आपका सामान्य कार्य प्रयास क्या है? (केवल स्थानीय — संदर्भ हेतु)',
      urdu: 'آپ کی عام محنت کی سطح کیا ہے؟ (صرف مقامی — حوالے کے لیے)',
      bengali: 'আপনার সাধারণ কাজের চাপ কী? (শুধু লোকাল — রেফারেন্সের জন্য)',
      tamil: 'உங்கள் வழக்கமான வேலை முயற்சி என்ன? (சாதனத்தில் மட்டும் — குறிப்பு)',
      malayalam:
          'നിങ്ങളുടെ സാധാരണ ജോലിയുടെ തീവ്രത എന്താണ്? (ഉപകരണത്തിൽ മാത്രം — റഫറൻസ്)',
      nepali: 'तपाईंको सामान्य कामको प्रयास के हो? (स्थानीय मात्र — सन्दर्भ)',
      filipino: 'Ano ang karaniwang workload mo? (lokal lang — sanggunian)',
    ),
    'workload_unset_hint': l10nEntry(
      english: 'Choose an option to see how ACGIH groups metabolic rate.',
      arabic: 'اختر خياراً لمعرفة كيف يصنّف ACGIH معدل الأيض.',
      hindi: 'चुनें कि ACGIH चयापचय दर कैसे वर्गीकृत करता है।',
      urdu: 'منتخب کریں کہ ACGIH میٹابولک شرح کیسے درجہ بندی کرتا ہے۔',
      bengali: 'ACGIH কীভাবে মেটাবলিক হার শ্রেণিবদ্ধ করে দেখতে একটি বিকল্প বেছে নিন।',
      tamil: 'ACGIH வளர்சிச்சை விகிதத்தை எவ்வாறு வகைப்படுத்துகிறது என்பதைக் காணத் தேர்வு செய்யுங்கள்.',
      malayalam:
          'ACGIH ചയാപചയ നിരക്ക് എങ്ങനെ വിഭാഗീകരിക്കുന്നു എന്ന് കാണാൻ ഒരു ഓപ്ഷൻ തിരഞ്ഞെടുക്കുക.',
      nepali: 'ACGIH ले मेटाबोलिक दर कसरी वर्गीकृत गर्छ हेर्न विकल्प छान्नुहोस्।',
      filipino: 'Pumili para makita kung paano ikinokategorya ng ACGIH ang metabolic rate.',
    ),
    'workload_option_light': l10nEntry(
      english: 'Light',
      arabic: 'خفيف',
      hindi: 'हल्का',
      urdu: 'ہلکا',
      bengali: 'হালকা',
      tamil: 'இலேசு',
      malayalam: 'ഭാരം കുറവ്',
      nepali: 'हल्का',
      filipino: 'Magaan',
    ),
    'workload_option_moderate': l10nEntry(
      english: 'Moderate',
      arabic: 'متوسط',
      hindi: 'मध्यम',
      urdu: 'درمیانی',
      bengali: 'মাঝারি',
      tamil: 'மிதமான',
      malayalam: 'മധ്യമം',
      nepali: 'मध्यम',
      filipino: 'Katamtaman',
    ),
    'workload_option_heavy': l10nEntry(
      english: 'Heavy',
      arabic: 'ثقيل',
      hindi: 'भारी',
      urdu: 'بھاری',
      bengali: 'ভারী',
      tamil: 'கனமான',
      malayalam: 'കനത്ത',
      nepali: 'गाह्रो',
      filipino: 'Mabigat',
    ),
    'workload_option_very_heavy': l10nEntry(
      english: 'Very heavy',
      arabic: 'ثقيل جداً',
      hindi: 'बहुत भारी',
      urdu: 'بہت بھاری',
      bengali: 'অতি ভারী',
      tamil: 'மிகக் கனமான',
      malayalam: 'വളരെ കനത്ത',
      nepali: 'धेरै गाह्रो',
      filipino: 'Napakabigat',
    ),
    'workload_example_light': l10nEntry(
      english: 'Example: office or light assembly, mostly sitting or standing.',
      arabic: 'مثال: مكتب أو تجميع خفيف، جلوس أو وقوف غالباً.',
      hindi: 'उदाहरण: कार्यालय या हल्का असेंबली, अधिकतर बैठना/खड़ा रहना।',
      urdu: 'مثال: دفتر یا ہلکی اسمبلی، زیادہ تر بیٹھنا یا کھڑے رہنا۔',
      bengali: 'উদাহরণ: অফিস বা হালকা অ্যাসেম্বলি, বেশিরভাগ বসা বা দাঁড়ানো।',
      tamil: 'எடுத்துக்காட்டு: அலுவலகம் அல்லது இலேசான அசெம்பிளி, பெரும்பாலும் உட்கார்ந்து/நின்று.',
      malayalam: 'ഉദാ: office, light assembly — കൂടുതൽ ഇരുന്നു/നിന്ന്.',
      nepali: 'उदाहरण: कार्यालय वा हल्का असेम्बली, धेरै बस्ने/उभिने।',
      filipino: 'Halimbawa: opisina o magaan na assembly, upo o nakatayo.',
    ),
    'workload_example_moderate': l10nEntry(
      english:
          'Example: steady walking, moderate lifting, or sustained light outdoor work.',
      arabic: 'مثال: مشي ثابت، رفع متوسط، أو عمل خفيف خارجي مستمر.',
      hindi: 'उदाहरण: स्थिर चलना, मध्यम उठाना, या लगातार हल्का बाहरी काम।',
      urdu: 'مثال: مسلسل چلنا، درمیانی اٹھانا، یا مسلسل ہلکا بیرونی کام۔',
      bengali: 'উদাহরণ: ধীরে হাঁটা, মাঝারি ওঠানো, বা টেকসই হালকা বাহিরের কাজ।',
      tamil: 'எடுத்துக்காட்டு: தொடர்ச்சியான நடை, மிதமான தூக்குதல், அல்லது நீண்ட இலேசான வெளிப்பணி.',
      malayalam: 'ഉദാ: നടത്തം, moderate lifting, sustained light outdoor work.',
      nepali: 'उदाहरण: निरन्तर हिँडाइ, मध्यम उठाउने, वा निरन्तर हल्का बाहिरी काम।',
      filipino:
          'Halimbawa: tuloy-tuloy na lakad, katamtamang buhat, o magaan na outdoor work.',
    ),
    'workload_example_heavy': l10nEntry(
      english:
          'Example: heavy digging, construction labour, or carrying loads for long periods.',
      arabic: 'مثال: حفر ثقيل، عمل بناء، أو حمل أوزان لفترات طويلة.',
      hindi: 'उदाहरण: भारी खुदाई, निर्माण मज़दूरी, या लंबे समय भार उठाना।',
      urdu: 'مثال: بھاری کھدائی، تعمیراتی مزدوری، یا لمبے عرصے بوجھ اٹھانا۔',
      bengali: 'উদাহরণ: ভারী খনন, নির্মাণ শ্রম, বা দীর্ঘ সময় বোঝা বহন।',
      tamil: 'எடுத்துக்காட்டு: கனமான அகழ்வு, கட்டுமானத் தொழிலாளர், அல்லது நீண்ட நேர சுமை.',
      malayalam: 'ഉദാ: heavy digging, construction, long carry.',
      nepali: 'उदाहरण: गाह्रो खन्ने, निर्माण काम, वा लामो समय बोकाइ।',
      filipino:
          'Halimbawa: mabigat na paghukay, konstruksyon, o matagal na pagbubuhat.',
    ),
    'workload_example_very_heavy': l10nEntry(
      english:
          'Example: intense shoveling, sprinting with load, or very hard manual labour.',
      arabic: 'مثال: حفر مكثف، جري بحمل، أو عمل يدوي شديد جداً.',
      hindi: 'उदाहरण: तीव्र खुदाई, भार के साथ दौड़ना, या बहुत कठिन शारीरिक श्रम।',
      urdu: 'مثال: شدید کھدائی، بوجھ کے ساتھ دوڑ، یا انتہائی سخت دستی محنت۔',
      bengali: 'উদাহরণ: তীব্র খনন, বোঝা নিয়ে দৌড়, বা খুব কঠিন ম্যানুয়াল শ্রম।',
      tamil: 'எடுத்துக்காட்டு: தீவிர தோண்டல், சுமையுடன் ஓடுதல், அல்லது மிகக் கடினமான கைத்தொழில்.',
      malayalam: 'ഉദാ: intense shoveling, sprint with load, very hard manual work.',
      nepali: 'उदाहरण: कडा खन्ने, बोकाइसँग दौड, वा धेरै कडा म्यानुअल श्रम।',
      filipino:
          'Halimbawa: matinding paghukay, takbo may pasan, o napakahirap na manual work.',
    ),
    'workload_acgih_heading': l10nEntry(
      english: 'ACGIH screening reference (continuous work)',
      arabic: 'مرجع فحص ACGIH (عمل مستمر)',
      hindi: 'ACGIH स्क्रीनिंग संदर्भ (निरंतर कार्य)',
      urdu: 'ACGIH اسکریننگ حوالہ (مسلسل کام)',
      bengali: 'ACGIH স্ক্রিনিং রেফারেন্স (অবিচ্ছিন্ন কাজ)',
      tamil: 'ACGIH திரை குறிப்பு (தொடர் வேலை)',
      malayalam: 'ACGIH സ്ക്രീനിംഗ് റഫറൻസ് (തുടർച്ചയായ ജോലി)',
      nepali: 'ACGIH स्क्रिनिङ सन्दर्भ (निरन्तर काम)',
      filipino: 'ACGIH screening reference (tuloy-tuloy na trabaho)',
    ),
    'workload_acgih_cite': l10nEntry(
      english:
          'Source: ACGIH Heat Stress and Strain, Table 2 (75–100% work allocation in the hour) and Table 3 (workload categories). Action Limit applies to unacclimatized workers; TLV applies to acclimatized workers — cited for education, not personal advice.',
      arabic:
          'المصدر: ACGIH للإجهاد الحراري، الجدول 2 (75–100% من الساعة) والجدول 3. حد الإجراء لغير المتكيفين؛ TLV للمتكيفين — للتعلم فقط.',
      hindi:
          'स्रोत: ACGIH Heat Stress and Strain, तालिका 2 (75–100% घंटे में) और तालिका 3। Action Limit अनअक्लाइमेटाइज़्ड; TLV अक्लाइमेटाइज़्ड — शिक्षा हेतु।',
      urdu:
          'ماخذ: ACGIH Heat Stress and Strain، ٹیبل 2 (75–100% گھنٹے میں) اور ٹیبل 3۔ ایکشن لمٹ غیر موافق؛ TLV موافق — صرف تعلیم۔',
      bengali:
          'সূত্র: ACGIH Heat Stress and Strain, টেবিল 2 (75–100%) এবং টেবিল 3। Action Limit অ-অ্যাক্লাইমেটাইজড; TLV অ্যাক্লাইমেটাইজড — শিক্ষামূলক।',
      tamil:
          'மூலம்: ACGIH Heat Stress and Strain, பட்டியல் 2 (75–100%) மற்றும் பட்டியல் 3. Action Limit அக்கில்மேட் அல்லாதவர்கள்; TLV அக்கில்மேட் — கல்வி மட்டும்.',
      malayalam:
          'ഉറവിടം: ACGIH Heat Stress and Strain, പട്ടിക 2 (മണിക്കൂറിൽ 75–100% ജോലി വിതരണം)യും പട്ടിക 3 (ജോലിഭാര വിഭാഗങ്ങളും). Action Limit അക്ലൈമറ്റ് അല്ലാത്തവർക്ക്; TLV അക്ലൈമറ്റ് ചെയ്തവർക്ക് — വിദ്യാഭ്യാസത്തിന് മാത്രം, വ്യക്തിഗത ഉപദേശമല്ല.',
      nepali:
          'स्रोत: ACGIH Heat Stress and Strain, तालिका 2 (75–100%) र तालिका 3। Action Limit अनअक्लाइमेटाइज्ड; TLV अक्लाइमेटाइज्ड — शैक्षिक मात्र।',
      filipino:
          'Source: ACGIH Heat Stress and Strain, Table 2 (75–100%) at Table 3. Para sa edukasyon lang.',
    ),
    'workload_acgih_assumptions': l10nEntry(
      english:
          'These screening values assume appropriate workplace WBGT measurement, a known workload category, and workers in conventional work clothing. Specialized PPE or unusual clothing require professional heat-stress assessment — not covered here.',
      arabic:
          'تفترض قيم الفحص قياس WBGT مناسب في مكان العمل، وفئة عبء عمل معروفة، وملابس عمل تقليدية. معدات الحماية أو الملابس غير الاعتيادية تحتاج تقييماً مهنياً.',
      hindi:
          'ये मान्यताएँ कार्यस्थल WBGT माप, ज्ञात कार्यभार, और पारंपरिक कपड़े मानती हैं। विशेष PPE या असामान्य कपड़े के लिए पेशेवर मूल्यांकन चाहिए।',
      urdu:
          'یہ اقدار مناسب WBGT پیمائش، معلوم workload اور روایتی لباس فرض کرتی ہیں۔ خاص PPE یا غیر معمولی لباس کے لیے پیشہ ورانہ تشخیص درکار ہے۔',
      bengali:
          'এই মানগুলো কর্মক্ষেত্রে WBGT পরিমাপ, পরিচিত workload ও সাধারণ পোশাক ধরে নেয়। বিশেষ PPE বা অস্বাভাবিক পোশাকে পেশাদার মূল্যায়ন দরকার।',
      tamil:
          'இந்த மதிப்புகள் பணியிட WBGT அளவீடு, அறியப்பட்ட வேலைச்சுமை, வழக்கமான உடை ஆகியவற்றைக் கருதுகின்றன. சிறப்பு PPE-க்கு தொழில்முறை மதிப்பீடு தேவை.',
      malayalam:
          'ഈ സ്ക്രീനിംഗ് മൂല്യങ്ങൾ ഉചിതമായ ജോലിസ്ഥല WBGT അളവ്, അറിയപ്പെട്ട ജോലിഭാരം, പരമ്പരാഗത ജോലിവസ്ത്രം എന്നിവ കരുതുന്നു. പ്രത്യേക PPE അല്ലെങ്കിൽ അസാധാരണ വസ്ത്രങ്ങൾക്ക് പ്രൊഫഷണൽ ചൂട്-സ്ട്രെസ് വിലയിരുത്തൽ ആവശ്യമാണ് — ഇവിടെ ഉൾപ്പെടുന്നില്ല.',
      nepali:
          'यी मानहरू कार्यस्थल WBGT माप, थाहा भएको कार्यभार र परम्परागत लुगा मान्छन्। विशेष PPE वा असामान्य लुगामा व्यावसायिक मूल्याङ्कन चाहिन्छ।',
      filipino:
          'Ipinapalagay ng values na tamang WBGT sa trabaho, kilalang workload, at karaniwang damit. Kailangan ng propesyonal na assessment para sa espesyal na PPE.',
    ),
    'workload_acgih_col_category': l10nEntry(
      english: 'Workload',
      arabic: 'عبء العمل',
      hindi: 'कार्यभार',
      urdu: 'کام کا بوجھ',
      bengali: 'কাজের চাপ',
      tamil: 'வேலைச்சுமை',
      malayalam: 'ജോലിഭാരം',
      nepali: 'कार्यभार',
      filipino: 'Workload',
    ),
    'workload_acgih_col_action_limit': l10nEntry(
      english: 'Action Limit',
      arabic: 'حد الإجراء',
      hindi: 'Action Limit',
      urdu: 'ایکشن لمٹ',
      bengali: 'Action Limit',
      tamil: 'Action Limit',
      malayalam: 'Action Limit',
      nepali: 'Action Limit',
      filipino: 'Action Limit',
    ),
    'workload_acgih_col_tlv': l10nEntry(
      english: 'TLV',
      arabic: 'TLV',
      hindi: 'TLV',
      urdu: 'TLV',
      bengali: 'TLV',
      tamil: 'TLV',
      malayalam: 'TLV',
      nepali: 'TLV',
      filipino: 'TLV',
    ),
    'workload_acgih_value_not_provided': l10nEntry(
      english: 'Not provided for continuous screening',
      arabic: 'غير متوفر للفحص المستمر',
      hindi: 'निरंतर स्क्रीनिंग के लिए उपलब्ध नहीं',
      urdu: 'مسلسل اسکریننگ کے لیے فراہم نہیں',
      bengali: 'অবিচ্ছিন্ন স্ক্রিনিংয়ের জন্য নেই',
      tamil: 'தொடர் திரைக்கு வழங்கப்படவில்லை',
      malayalam: 'തുടർച്ചയായ സ്ക്രീനിംഗിന് നൽകിയിട്ടില്ല',
      nepali: 'निरन्तर स्क्रिनिङका लागि छैन',
      filipino: 'Hindi ibinibigay para sa tuloy-tuloy na screening',
    ),
    'workload_acgih_no_continuous_screening': l10nEntry(
      english:
          'For heavy or very heavy work, ACGIH does not publish continuous-work screening WBGT values in Table 2. Seek professional assessment.',
      arabic:
          'للعمل الثقيل أو الشديد جداً، لا ينشر ACGIH قيم فحص مستمر في الجدول 2. اطلب تقييماً مهنياً.',
      hindi:
          'भारी या बहुत भारी कार्य के लिए ACGIH तालिका 2 में निरंतर स्क्रीनिंग मान प्रकाशित नहीं करता। पेशेवर मूल्यांकन लें।',
      urdu:
          'بھاری یا بہت بھاری کام کے لیے ACGIH ٹیبل 2 میں مسلسل اسکریننگ اقدار شائع نہیں کرتا۔ پیشہ ورانہ تشخیص کریں۔',
      bengali:
          'ভারী বা অতি ভারী কাজের জন্য ACGIH টেবিল 2-এ অবিচ্ছিন্ন স্ক্রিনিং মান দেয় না। পেশাদার মূল্যায়ন নিন।',
      tamil:
          'கனமான அல்லது மிகக் கனமான வேலைக்கு ACGIH தொடர் திரை மதிப்புகளை வெளியிடுவதில்லை. தொழில்முறை மதிப்பீடு செய்யுங்கள்.',
      malayalam:
          'കനത്ത അല്ലെങ്കിൽ വളരെ കനത്ത ജോലിക്ക് ACGIH പട്ടിക 2-ൽ തുടർച്ചയായ ജോലി സ്ക്രീനിംഗ് WBGT മൂല്യങ്ങൾ പ്രസിദ്ധീകരിക്കുന്നില്ല. പ്രൊഫഷണൽ വിലയിരുത്തൽ നേടുക.',
      nepali:
          'गाह्रो वा धेरै गाह्रो कामका लागि ACGIH ले तालिका 2 मा निरन्तर स्क्रिनिङ मान दिँदैन। व्यावसायिक मूल्याङ्कन गर्नुहोस्।',
      filipino:
          'Para sa mabigat o napakabigat na trabaho, walang continuous screening values ang ACGIH sa Table 2. Humingi ng propesyonal na assessment.',
    ),
    'workload_clear_choice': l10nEntry(
      english: 'Clear workload choice',
      arabic: 'مسح اختيار عبء العمل',
      hindi: 'कार्यभार विकल्प साफ़ करें',
      urdu: 'کام کے بوجھ کا انتخاب صاف کریں',
      bengali: 'কাজের চাপের পছন্দ মুছুন',
      tamil: 'வேலைச்சுமை தேர்வை அழி',
      malayalam: 'ജോലിഭാരം തിരഞ്ഞെടുപ്പ് നീക്കം ചെയ്യുക',
      nepali: 'कार्यभार छनोट हटाउनुहोस्',
      filipino: 'Burahin ang workload choice',
    ),
    'workload_open_first_aid': l10nEntry(
      english: 'Open heat illness first-aid card',
      arabic: 'افتح بطاقة إسعاف أمراض الحر',
      hindi: 'गर्मी रोग प्राथमिक उपचार कार्ड खोलें',
      urdu: 'گرمی کی بیماری کی فرسٹ ایڈ کارڈ کھولیں',
      bengali: 'তাপজনিত অসুস্থতার প্রাথমিক চিকিৎসা কার্ড',
      tamil: 'வெப்ப நோய் முதலுதவி அட்டை திற',
      malayalam: 'ചൂട് രോഗം first-aid card തുറക്കുക',
      nepali: 'तापबाट हुने बिरामीको प्राथमिक उपचार कार्ड खोल्नुहोस्',
      filipino: 'Buksan ang first-aid card sa heat illness',
    ),
    'section_emergency_overline': l10nEntry(
      english: 'Emergency tools',
      arabic: 'أدوات الطوارئ',
      hindi: 'आपातकालीन उपकरण',
      urdu: 'ایمرجنسی ٹولز',
    ),
    'section_emergency_title': l10nEntry(
      english: 'Symptom checker',
      arabic: 'فحص الأعراض',
      hindi: 'लक्षण जाँच',
      urdu: 'علامات چیکر',
    ),
    'route_new': l10nEntry(
      english: 'New route',
      arabic: 'مسار جديد',
      hindi: 'नया रास्ता',
      urdu: 'نیا راستہ',
    ),
    'route_from_label': l10nEntry(
      english: 'From',
      arabic: 'من',
      hindi: 'से',
      urdu: 'سے',
    ),
    'route_from_hint': l10nEntry(
      english: 'Your location (e.g. Al Khor, West Bay)...',
      arabic: 'موقعك (مثلاً الخور، West Bay)...',
      hindi: 'आपका स्थान (जैसे Al Khor, West Bay)...',
      urdu: 'آپ کا مقام (مثلاً Al Khor, West Bay)...',
    ),
    'route_to_label': l10nEntry(
      english: 'To',
      arabic: 'إلى',
      hindi: 'तक',
      urdu: 'تک',
    ),
    'route_to_hint': l10nEntry(
      english: 'Destination (e.g. City Center, Hamad Airport)...',
      arabic: 'الوجهة (مثلاً City Center، مطار حمد)...',
      hindi: 'गंतव्य (जैसे City Center, Hamad Airport)...',
      urdu: 'منزل (مثلاً City Center, Hamad Airport)...',
    ),
    'route_swap_locations': l10nEntry(
      english: 'Swap from and to locations',
      arabic: 'تبديل موقعي البداية والوجهة',
      hindi: 'Swap from and to locations',
      urdu: 'Swap from and to locations',
      bengali: 'Swap from and to locations',
      tamil: 'Swap from and to locations',
      filipino: 'Swap from and to locations',
    ),
    'route_error_missing': l10nEntry(
      english: 'Please select both your starting point and destination.',
      arabic: 'يرجى اختيار نقطة البداية والوجهة.',
      hindi: 'कृपया प्रारंभ बिंदु और गंतव्य दोनों चुनें।',
      urdu: 'براہ کرم شروع اور منزل دونوں منتخب کریں۔',
    ),
    'route_error_failed': l10nEntry(
      english: 'Could not get route advice. Check your connection and try again.',
      arabic: 'تعذّر الحصول على نصائح المسار. تحقق من الاتصال وحاول مجدداً.',
      hindi: 'रूट सलाह नहीं मिली। कनेक्शन जाँचें और पुनः प्रयास करें।',
      urdu: 'راستے کی مشورہ نہیں ملی۔ کنکشن چیک کریں اور دوبارہ کوشش کریں۔',
    ),
    'route_loading_weather': l10nEntry(
      english: 'Loading weather...',
      arabic: 'جاري تحميل الطقس...',
      hindi: 'मौसम लोड हो रहा है...',
      urdu: 'موسم لوڈ ہو رہا ہے...',
    ),
    'route_get_cta': l10nEntry(
      english: 'Get heat-safe route',
      arabic: 'احصل على مسار آمن من الحر',
      hindi: 'गर्मी-सुरक्षित रास्ता पाएँ',
      urdu: 'گرمی سے محفوظ راستہ حاصل کریں',
    ),
    'route_loading_title': l10nEntry(
      english: 'Calculating heat-safe routes...',
      arabic: 'جاري حساب مسارات آمنة من الحر...',
      hindi: 'गर्मी-सुरक्षित रास्ते गिने जा रहे हैं...',
      urdu: 'گرمی سے محفوظ راستے شمار ہو رہے ہیں...',
    ),
    'route_loading_subtitle': l10nEntry(
      english: 'Checking live weather + 3 route options',
      arabic: 'التحقق من الطقس المباشر + 3 خيارات مسار',
      hindi: 'लाइव मौसम + 3 रूट विकल्प जाँचे जा रहे हैं',
      urdu: 'لائیو موسم + 3 راستے کے اختیارات چیک ہو رہے ہیں',
    ),
    'route_options_title': l10nEntry(
      english: 'Route options',
      arabic: 'خيارات المسار',
      hindi: 'रूट विकल्प',
      urdu: 'راستے کے اختیارات',
    ),
    'route_tips_title': l10nEntry(
      english: 'Qatar heat tips',
      arabic: 'نصائح الحر في قطر',
      hindi: 'कतर गर्मी सुझाव',
      urdu: 'قطر گرمی کے مشورے',
    ),
    'route_best_time': l10nEntry(
      english: 'Best time: {time}',
      arabic: 'أفضل وقت: {time}',
      hindi: 'सबसे अच्छा समय: {time}',
      urdu: 'بہترین وقت: {time}',
    ),
    'route_open_maps': l10nEntry(
      english: 'Open in Google Maps',
      arabic: 'افتح في Google Maps',
      hindi: 'Google Maps में खोलें',
      urdu: 'Google Maps میں کھولیں',
    ),
    'route_heat_badge': l10nEntry(
      english: '{risk} HEAT',
      arabic: 'حرارة {risk}',
      hindi: '{risk} गर्मी',
      urdu: '{risk} گرمی',
    ),
    'route_risk_low': l10nEntry(
      english: 'LOW',
      arabic: 'منخفض',
      hindi: 'कम',
      urdu: 'کم',
    ),
    'route_risk_medium': l10nEntry(
      english: 'MEDIUM',
      arabic: 'متوسط',
      hindi: 'मध्यम',
      urdu: 'درمیانی',
    ),
    'route_risk_high': l10nEntry(
      english: 'HIGH',
      arabic: 'مرتفع',
      hindi: 'उच्च',
      urdu: 'زیادہ',
    ),
    'weather_fetching': l10nEntry(
      english: 'Fetching live Doha weather...',
      arabic: 'جاري جلب طقس الدوحة المباشر...',
      hindi: 'लाइव दोहा मौसम लाया जा रहा है...',
      urdu: 'لائیو دوحہ موسم لایا جا رہا ہے...',
    ),
    'weather_feels_line': l10nEntry(
      english: 'Feels {feels}°C • Humidity {humidity}% • Wind {wind} m/s',
      arabic: 'يشعر {feels}°م • رطوبة {humidity}% • رياح {wind} م/ث',
      hindi: 'महसूस {feels}°C • नमी {humidity}% • हवा {wind} m/s',
      urdu: 'محسوس {feels}°C • نمی {humidity}% • ہوا {wind} m/s',
    ),
    'weather_heat_index_line': l10nEntry(
      english: 'Heat index: {index}°C —',
      arabic: 'مؤشر الحرارة: {index}°م —',
      hindi: 'हीट इंडेक्स: {index}°C —',
      urdu: 'Heat index: {index}°C —',
    ),
    'heat_risk_extreme_danger': l10nEntry(
      english: 'EXTREME DANGER',
      arabic: 'خطر شديد',
      hindi: 'अत्यधिक खतरा',
      urdu: 'شدید خطرہ',
    ),
    'heat_risk_danger': l10nEntry(
      english: 'DANGER',
      arabic: 'خطر',
      hindi: 'खतरा',
      urdu: 'خطرہ',
    ),
    'heat_risk_extreme_caution': l10nEntry(
      english: 'EXTREME CAUTION',
      arabic: 'حذر شديد',
      hindi: 'अत्यधिक सावधानी',
      urdu: 'شدید احتیاط',
    ),
    'heat_risk_caution': l10nEntry(
      english: 'CAUTION',
      arabic: 'حذر',
      hindi: 'सावधानी',
      urdu: 'احتیاط',
    ),
    'heat_risk_safe': l10nEntry(
      english: 'SAFE',
      arabic: 'آمن',
      hindi: 'सुरक्षित',
      urdu: 'محفوظ',
    ),
    'outdoor_advice_extreme': l10nEntry(
      english: 'DO NOT go outdoors. Heatstroke risk within minutes.',
      arabic: 'لا تخرج. خطر ضربة شمس خلال دقائق.',
      hindi: 'बाहर न जाएँ। कुछ मिनटों में हीटस्ट्रोक का खतरा।',
      urdu: 'باہر نہ جائیں۔ چند منٹ میں ہیٹ اسٹروک کا خطرہ۔',
    ),
    'outdoor_advice_danger': l10nEntry(
      english: 'Avoid outdoors 10AM–5PM. Extreme heat — limit exposure to 10 min.',
      arabic: 'تجنّب الخروج 10–17. حر شديد — 10 دقائق كحد أقصى.',
      hindi: '10AM–5PM बाहर न जाएँ। अत्यधिक गर्मी — 10 मिनट से अधिक न रहें।',
      urdu: '10AM–5PM باہر نہ جائیں۔ شدید گرمی — 10 منٹ سے زیادہ نہ رہیں۔',
    ),
    'outdoor_advice_caution': l10nEntry(
      english: 'Avoid outdoors 11AM–4PM. Carry water. Seek shade constantly.',
      arabic: 'تجنّب 11–16. احمل ماء. ابقَ في الظل.',
      hindi: '11AM–4PM बाहर न जाएँ। पानी रखें। छाया में रहें।',
      urdu: '11AM–4PM باہر نہ جائیں۔ پانی رکھیں۔ سایہ میں رہیں۔',
    ),
    'outdoor_advice_mild': l10nEntry(
      english: 'Early morning or evening outdoor activity only. Stay hydrated.',
      arabic: 'نشاط خارجي صباحاً أو مساءً فقط. حافظ على الترطيب.',
      hindi: 'सुबह या शाम ही बाहरी गतिविधि। हाइड्रेटेड रहें।',
      urdu: 'صبح یا شام ہی بیرونی سرگرمی۔ پani پیتے رہیں۔',
    ),
    'outdoor_advice_safe': l10nEntry(
      english: 'Pleasant conditions. Normal outdoor activity is fine.',
      arabic: 'ظروف لطيفة. النشاط الخارجي العادي مناسب.',
      hindi: 'सुखद स्थिति। सामान्य बाहरी गतिविधि ठीक है।',
      urdu: 'اچھی حالت۔ عام بیرونی سرگرمی ٹھیک ہے۔',
    ),
    'uv_extreme': l10nEntry(
      english: 'Extreme',
      arabic: 'شديد',
      hindi: 'अत्यधिक',
      urdu: 'شدید',
    ),
    'uv_very_high': l10nEntry(
      english: 'Very High',
      arabic: 'مرتفع جداً',
      hindi: 'बहुत उच्च',
      urdu: 'بہت زیادہ',
    ),
    'uv_high': l10nEntry(
      english: 'High',
      arabic: 'مرتفع',
      hindi: 'उच्च',
      urdu: 'زیادہ',
    ),
    'uv_moderate': l10nEntry(
      english: 'Moderate',
      arabic: 'متوسط',
      hindi: 'मध्यम',
      urdu: 'درمیانی',
    ),
    'uv_low': l10nEntry(
      english: 'Low',
      arabic: 'منخفض',
      hindi: 'कम',
      urdu: 'کم',
    ),
    'weather_desc_hot': l10nEntry(
      english: 'Hot',
      arabic: 'حار',
      hindi: 'गर्म',
      urdu: 'گرم',
    ),
    'weather_desc_hot_no_connection': l10nEntry(
      english: 'Hot (no connection)',
      arabic: 'حار (لا اتصال)',
      hindi: 'गर्म (कोई कनेक्शन नहीं)',
      urdu: 'گرم (کوئی کنکشن نہیں)',
    ),
    'symptom_yes': l10nEntry(
      english: 'Yes',
      arabic: 'نعم',
      hindi: 'हाँ',
      urdu: 'ہاں',
    ),
    'symptom_no': l10nEntry(
      english: 'No',
      arabic: 'لا',
      hindi: 'नहीं',
      urdu: 'نہیں',
    ),
    'symptom_back': l10nEntry(
      english: 'Back',
      arabic: 'رجوع',
      hindi: 'वापस',
      urdu: 'واپس',
    ),
    'symptom_start_over': l10nEntry(
      english: 'Start over',
      arabic: 'ابدأ من جديد',
      hindi: 'फिर से शुरू',
      urdu: 'دوبارہ شروع',
    ),
    'symptom_find_doctor': l10nEntry(
      english: 'Find a doctor near you',
      arabic: 'ابحث عن طبيب قريب',
      hindi: 'पास का डॉक्टर खोजें',
      urdu: 'قریب ڈاکٹر تلاش کریں',
    ),
    'symptom_q_start': l10nEntry(
      english: 'Are you or someone near you feeling unwell in the heat right now?',
      arabic: 'هل تشعر أنت أو شخص قريب بتوعك في الحر الآن؟',
      hindi: 'क्या आप या कोई पास वाला अभी गर्मी में अस्वस्थ महसूस कर रहा है?',
      urdu: 'کیا آپ یا کوئی قریب والا ابھی گرمی میں بیمار محسوس کر رہا ہے؟',
    ),
    'symptom_q_q1': l10nEntry(
      english:
          'Are any of these present?\n\n• Not sweating despite extreme heat\n• Confusion, slurred speech, or seizures\n• Loss of consciousness or unresponsiveness\n• Body temperature above 40°C',
      arabic:
          'هل أي من هذه موجود؟\n\n• عدم التعرق رغم الحر الشديد\n• تشوش أو تلعثم أو تشنجات\n• فقدان الوعي\n• حرارة الجسم فوق 40°م',
      hindi:
          'क्या इनमें से कोई है?\n\n• अत्यधिक गर्मी में पसीना नहीं\n• भ्रम, बोलने में कठिनाई, या दौरे\n• बेहोशी\n• शरीर का ताप 40°C से ऊपर',
      urdu:
          'کیا ان میں سے کوئی ہے؟\n\n• شدید گرمی میں پسینہ نہیں\n• الجھن، بولنے میں مشکل، یا دورے\n• بے ہوشی\n• جسم کا درجہ 40°C سے زیادہ',
    ),
    'symptom_q_q2': l10nEntry(
      english:
          'Are any of these present?\n\n• Heavy sweating\n• Pale, moist skin\n• Weak, rapid pulse\n• Nausea or vomiting\n• Muscle cramps',
      arabic:
          'هل أي من هذه موجود؟\n\n• تعرق شديد\n• بشرة شاحبة رطبة\n• نبض ضعيف سريع\n• غثيان أو قيء\n• تشنجات عضلية',
      hindi:
          'क्या इनमें से कोई है?\n\n• भारी पसीना\n• पीली, नम त्वचा\n• कमज़ोर तेज नाड़ी\n• मितली या उल्टी\n• मांसपेशी ऐंठन',
      urdu:
          'کیا ان میں سے کوئی ہے؟\n\n• زیادہ پسینہ\n• پیلا، نم جلد\n• کمزور تیز نبض\n• متلی یا قے\n• پٹھوں میں درد',
    ),
    'symptom_q_q3': l10nEntry(
      english:
          'Are you experiencing?\n\n• Painful muscle cramps or spasms\n• Cramps during or after physical activity',
      arabic:
          'هل تعاني من؟\n\n• تشنجات عضلية مؤلمة\n• تشنجات أثناء أو بعد النشاط',
      hindi:
          'क्या आप अनुभव कर रहे हैं?\n\n• दर्दनाक मांसपेशी ऐंठन\n• गतिविधि के दौरान/बाद ऐंठन',
      urdu:
          'کیا آپ محسوس کر رہے ہیں؟\n\n• دردناک پٹھوں میں کھچاؤ\n• سرگرمی کے دوران/بعد کھچاؤ',
    ),
    'symptom_q_q4': l10nEntry(
      english:
          'Are you feeling?\n\n• Dizziness or light-headedness\n• Mild headache\n• Flushing or redness',
      arabic:
          'هل تشعر بـ؟\n\n• دوخة\n• صداع خفيف\n• احمرار',
      hindi:
          'क्या महसूस हो रहा है?\n\n• चक्कर\n• हल्का सिरदर्द\n• लालिमा',
      urdu:
          'کیا محسوس ہو رہا ہے؟\n\n• چکر\n• ہلکا سر درد\n• سرخی',
    ),
    'symptom_title_prevention': l10nEntry(
      english: 'Staying safe in Qatar heat',
      arabic: 'البقاء آمناً في حر قطر',
      hindi: 'कतर की गर्मी में सुरक्षित रहें',
      urdu: 'قطر کی گرمی میں محفوظ رہیں',
    ),
    'symptom_title_heatstroke': l10nEntry(
      english: 'Possible heatstroke — call 999 now',
      arabic: 'احتمال ضربة شمس — اتصل 999 فوراً',
      hindi: 'संभावित हीटस्ट्रोक — अभी 999 पर कॉल करें',
      urdu: 'ممکنہ ہیٹ اسٹروک — فوراً 999 پر کال کریں',
    ),
    'symptom_title_exhaustion': l10nEntry(
      english: 'Possible heat exhaustion',
      arabic: 'احتمال إجهاد حراري',
      hindi: 'संभावित गर्मी की थकान',
      urdu: 'ممکنہ گرمی سے تھکاوٹ',
    ),
    'symptom_title_cramps': l10nEntry(
      english: 'Heat cramps',
      arabic: 'تشنجات الحر',
      hindi: 'गर्मी की ऐंठन',
      urdu: 'گرمی کے درد',
    ),
    'symptom_title_syncope': l10nEntry(
      english: 'Heat dizziness',
      arabic: 'دوخة الحر',
      hindi: 'गर्मी से चक्कर',
      urdu: 'گرمی سے چکر',
    ),
    'symptom_title_mild': l10nEntry(
      english: 'Mild heat discomfort',
      arabic: 'انزعاج حراري خفيف',
      hindi: 'हल्की गर्मी की तकलीफ',
      urdu: 'ہلکی گرمی کی تکلیف',
    ),
    'symptom_warn_heatstroke': l10nEntry(
      english:
          'These are signs of heatstroke — a life-threatening emergency.\n\nWhile waiting for help:\n• Move the person to shade or AC immediately\n• Apply cold wet cloths to neck, armpits, groin\n• Fan them to increase cooling\n• Do NOT give water if unconscious\n• Stay with them until help arrives',
      arabic:
          'هذه علامات ضربة شمس — طوارئ مهددة للحياة.\n\nأثناء انتظار المساعدة:\n• انقل للظل أو التكييف\n• ضمادات باردة على الرقبة والإبطين\n• لا تعطِ ماء إن كان فاقد الوعي\n• ابقَ معه حتى تصل المساعدة',
      hindi:
          'ये हीटस्ट्रोक के संकेत हैं — जानलेवा आपातकाल।\n\nमदद के इंतज़ार में:\n• छाया/AC में ले जाएँ\n• गर्दन, बगल, जांघ पर ठंडे कपड़े\n• बेहोश हो तो पानी न दें\n• मदद आने तक साथ रहें',
      urdu:
          'یہ ہیٹ اسٹروک کی علامات ہیں — جان لیوا ایمرجنسی.\n\nمدد کے انتظار میں:\n• سایہ/AC میں لے جائیں\n• گردن، بغل، ران پر ٹھنڈے کپڑے\n• بے ہوش ہو تو پani نہ دیں\n• مدد آنے تک ساتھ رہیں',
    ),
    'symptom_tip_prevention_1': l10nEntry(
      english: 'Drink at least 3–4 litres of water daily — more if outdoors',
      arabic: 'اشرب 3–4 لتر ماء يومياً — أكثر إن كنت خارجاً',
    ),
    'symptom_tip_prevention_2': l10nEntry(
      english: 'Avoid outdoor activity between 11 AM and 4 PM during summer',
      arabic: 'تجنّب النشاط الخارجي 11–16 صيفاً',
    ),
    'symptom_tip_prevention_3': l10nEntry(
      english: 'Wear light, loose, light-coloured clothing',
      arabic: 'ارتدِ ملابس خفيفة فاتحة فضفاضة',
    ),
    'symptom_tip_prevention_4': l10nEntry(
      english: 'Use the metro and mall corridors as cooling routes',
      arabic: 'استخدم المترو والمولات كمسارات تبريد',
    ),
    'symptom_tip_prevention_5': l10nEntry(
      english: 'Never leave children or pets in a parked car',
      arabic: 'لا تترك أطفالاً أو حيوانات في سيارة متوقفة',
    ),
    'symptom_tip_prevention_6': l10nEntry(
      english: 'Check on elderly neighbours during peak heat',
      arabic: 'تحقق من الجيران كبار السن في ذروة الحر',
    ),
    'symptom_tip_exhaustion_1': l10nEntry(
      english: 'Move to a cool, air-conditioned space immediately',
      arabic: 'انتقل فوراً لمكان مكيّف',
    ),
    'symptom_tip_exhaustion_2': l10nEntry(
      english: 'Lie down and elevate legs slightly',
      arabic: 'استلقِ وارفع الساقين قليلاً',
    ),
    'symptom_tip_exhaustion_3': l10nEntry(
      english: 'Drink cool water slowly — sip, do not gulp',
      arabic: 'اشرب ماء بارداً ببطء — رشفات',
    ),
    'symptom_tip_exhaustion_4': l10nEntry(
      english: 'Apply cool, wet cloths to forehead, neck, wrists',
      arabic: 'ضعادات باردة على الجبهة والرقبة والمعصم',
    ),
    'symptom_tip_exhaustion_5': l10nEntry(
      english: 'Loosen or remove excess clothing',
      arabic: 'فكّ أو أزل الملابس الزائدة',
    ),
    'symptom_tip_exhaustion_6': l10nEntry(
      english: 'Rest for at least 30–60 minutes',
      arabic: 'استرح 30–60 دقيقة على الأقل',
    ),
    'symptom_tip_exhaustion_7': l10nEntry(
      english: 'If symptoms worsen or do not improve in 1 hour, seek medical attention',
      arabic: 'إن ساءت الأعراض أو لم تتحسن خلال ساعة، اطلب رعاية طبية',
    ),
    'symptom_tip_cramps_1': l10nEntry(
      english: 'Stop activity and rest in a cool place',
      arabic: 'أوقف النشاط واسترح في مكان بارد',
    ),
    'symptom_tip_cramps_2': l10nEntry(
      english: 'Drink water or a sports drink with electrolytes',
      arabic: 'اشرب ماء أو مشروب رياضي بالأ electrolytes',
    ),
    'symptom_tip_cramps_3': l10nEntry(
      english: 'Gently stretch and massage the cramping muscles',
      arabic: 'مدّد ودلّك العضلات المتشنجة برفق',
    ),
    'symptom_tip_cramps_4': l10nEntry(
      english: 'Wait for cramps to fully subside before resuming any physical activity',
      arabic: 'انتظر حتى تزول التشنجات قبل استئناف النشاط',
    ),
    'symptom_tip_cramps_5': l10nEntry(
      english: 'If cramps last more than 1 hour, see a doctor',
      arabic: 'إن استمرت التشنجات أكثر من ساعة، راجع طبيباً',
    ),
    'symptom_tip_syncope_1': l10nEntry(
      english: 'Sit or lie down in a cool, shaded area immediately',
      arabic: 'اجلس أو استلقِ في مكان بارد مظلل فوراً',
    ),
    'symptom_tip_syncope_2': l10nEntry(
      english: 'Drink cool water slowly',
      arabic: 'اشرب ماء بارداً ببطء',
    ),
    'symptom_tip_syncope_3': l10nEntry(
      english: 'Avoid sudden standing up',
      arabic: 'تجنّب الوقوف المفاجئ',
    ),
    'symptom_tip_syncope_4': l10nEntry(
      english: 'Wait until dizziness fully passes before moving',
      arabic: 'انتظر حتى تزول الدوخة قبل الحركة',
    ),
    'symptom_tip_syncope_5': l10nEntry(
      english: 'If you fainted or feel you might faint, seek medical attention',
      arabic: 'إن أغمي عليك أو تشعر بالإغماء، اطلب رعاية طبية',
    ),
    'symptom_tip_mild_1': l10nEntry(
      english: 'Move indoors or to shade',
      arabic: 'انتقل للداخل أو الظل',
    ),
    'symptom_tip_mild_2': l10nEntry(
      english: 'Drink water — even if not thirsty',
      arabic: 'اشرب ماء — حتى لو لم تشعر بالعطش',
    ),
    'symptom_tip_mild_3': l10nEntry(
      english: 'Rest for at least 20–30 minutes',
      arabic: 'استرح 20–30 دقيقة على الأقل',
    ),
    'symptom_tip_mild_4': l10nEntry(
      english: 'Avoid caffeine and alcohol which dehydrate',
      arabic: 'تجنّب الكافيين والكحول — يسببان الجفاف',
    ),
    'symptom_tip_mild_5': l10nEntry(
      english: 'A cool shower or damp cloth on the neck helps quickly',
      arabic: 'دش بارد أو قماش مبلل على الرقبة يساعد سريعاً',
    ),
    'cooling_set_destination': l10nEntry(
      english: 'Set as destination',
      arabic: 'تعيين كوجهة',
      hindi: 'गंतव्य के रूप में सेट करें',
      urdu: 'منزل کے طور پر سیٹ کریں',
    ),
    'cooling_directions': l10nEntry(
      english: 'Directions',
      arabic: 'الاتجاهات',
      hindi: 'दिशा-निर्देश',
      urdu: 'سمت',
    ),
    'cooling_destination_set': l10nEntry(
      english: 'Destination set — scroll to plan your route',
      arabic: 'تم تعيين الوجهة — خطّط مسارك',
      hindi: 'गंतव्य सेट — अपना रास्ता योजना बनाएँ',
      urdu: 'منزل سیٹ — اپنا راستہ منصوبہ بنائیں',
    ),
    'route_loading_inline': l10nEntry(
      english: 'Finding heat-safe routes…',
      arabic: 'جاري إيجاد مسارات آمنة من الحر…',
      hindi: 'गर्मी-सुरक्षित रास्ते खोजे जा रहे हैं…',
      urdu: 'گرمی سے محفوظ راستے تلاش ہو رہے ہیں…',
    ),
    'empty_cooling_title': l10nEntry(
      english: 'No cooling spots nearby',
      arabic: 'لا توجد أماكن تبريد قريبة',
      hindi: 'पास में कोई cooling spot नहीं',
      urdu: 'قریب کوئی ٹھنڈی جگہ نہیں',
    ),
    'empty_cooling_body': l10nEntry(
      english:
          'Try another filter or search Google Places for more options in this area.',
      arabic: 'جرّب فلتراً آخر أو ابحث في Google Places.',
      hindi: 'दूसरा filter आज़माएँ या Google Places खोजें।',
      urdu: 'دوسرا filter آزمائیں یا Google Places تلاش کریں۔',
    ),
    'empty_cooling_location_title': l10nEntry(
      english: 'Location access helps find nearest spots',
      arabic: 'الوصول للموقع يساعد في إيجاد الأقرب',
      hindi: 'Location चालू करने से निकटतम spots मिलते हैं',
      urdu: 'Location سے قریبی جگہیں ملتی ہیں',
    ),
    'empty_cooling_location_body': l10nEntry(
      english:
          'Enable location to sort cooling spots by distance. Doha defaults are shown until then.',
      arabic: 'فعّل الموقع لترتيب الأماكن حسب المسافة. تُعرض افتراضيات الدوحة حتى ذلك.',
      hindi: 'दूरी के अनुसार sorting के लिए location चालू करें। तब तक Doha defaults दिखेंगे।',
      urdu: 'فاصلے کے مطابق sorting کے لیے location چalu کریں۔ تب تک Doha defaults دکھائیں گے۔',
    ),
    'cooling_enable_location': l10nEntry(
      english: 'Enable location',
      arabic: 'تفعيل الموقع',
      hindi: 'Location चालू करें',
      urdu: 'Location چalu کریں',
    ),
    'cooling_tag_ac_rest': l10nEntry(
      english: 'AC rest',
      arabic: 'راحة مكيّف',
      hindi: 'AC rest',
      urdu: 'AC rest',
      bengali: 'AC rest',
      tamil: 'AC rest',
      filipino: 'AC rest',
      malayalam: 'AC rest',
      nepali: 'AC rest',
    ),
    'cooling_tag_respite': l10nEntry(
      english: 'Shade respite',
      arabic: 'راحة في الظل',
      hindi: 'Shade respite',
      urdu: 'Shade respite',
      bengali: 'Shade respite',
      tamil: 'Shade respite',
      filipino: 'Shade respite',
      malayalam: 'Shade respite',
      nepali: 'Shade respite',
    ),
    'cooling_cap_filter_all': l10nEntry(
      english: 'All types',
      arabic: 'كل الأنواع',
      hindi: 'All types',
      urdu: 'All types',
    ),
    'cooling_prov_catalog_mall': l10nEntry(
      english: 'Source: catalog section — Major malls (air-conditioned).',
      arabic: 'المصدر: قسم الكتالوج — Major malls (air-conditioned).',
    ),
    'cooling_prov_catalog_metro': l10nEntry(
      english:
          'Source: catalog section — Doha Metro stations (air-conditioned).',
      arabic:
          'المصدر: قسم الكتالوج — Doha Metro stations (air-conditioned).',
    ),
    'cooling_prov_catalog_hospital': l10nEntry(
      english: 'Source: catalog section — Hospitals (AC lobbies / waiting areas).',
      arabic:
          'المصدر: قسم الكتالوج — Hospitals (AC lobbies / waiting areas).',
    ),
    'cooling_prov_catalog_shaded': l10nEntry(
      english: 'Source: catalog section — Shaded outdoor parks.',
      arabic: 'المصدر: قسم الكتالوج — Shaded outdoor parks.',
    ),
    'cooling_prov_mosque_ac': l10nEntry(
      english: 'Source: MosqueFacilities.airConditioning in curated mosque data.',
      arabic: 'المصدر: MosqueFacilities.airConditioning في بيانات المساجد.',
    ),
    'cooling_nearest_stop_title': l10nEntry(
      english: 'Nearest documented public stop',
      arabic: 'أقرب محطة موثّقة للوصول العام',
      hindi: 'Nearest documented public stop',
      urdu: 'Nearest documented public stop',
    ),
    'cooling_nearest_walk_approx': l10nEntry(
      english: 'Approx. {minutes} min walk',
      arabic: 'حوالي {minutes} دقيقة مشياً',
      hindi: 'लगभग {minutes} मिनट पैदल',
      urdu: 'تقریباً {minutes} منٹ پیدل',
    ),
    'cooling_public_access_note': l10nEntry(
      english:
          'Public access is cited only from on-file description text — not from verification badges.',
      arabic:
          'الوصول العام مُستشهد به من نص الوصف المخزّن فقط — وليس من شارات التوثيق.',
    ),
    'cooling_detail_heading': l10nEntry(
      english: 'Classification detail',
      arabic: 'تفاصيل التصنيف',
      hindi: 'Classification detail',
      urdu: 'Classification detail',
    ),
    'uncertainty_approx_range': l10nEntry(
      english:
          'Approximate range {low}–{high}°C (±{margin}°C provisional margin around this estimate).',
      arabic:
          'نطاق تقريبي {low}–{high}°م (±{margin}°م هامش مؤقت حول هذا التقدير).',
      hindi:
          'अनुमानित सीमा {low}–{high}°C (±{margin}°C — अस्थायी UX मार्जिन).',
      urdu:
          'تقریبی حد {low}–{high}°C (±{margin}°C عارضی UX مارجن).',
      malayalam:
          'ഏകദേശ പരിധി {low}–{high}°C (±{margin}°C താൽക്കാലിക UX മാർജിൻ).',
      nepali:
          'अनुमानित दायरा {low}–{high}°C (±{margin}°C अस्थायी UX मार्जिन).',
      bengali:
          'আনুমানিক পরিসর {low}–{high}°C (±{margin}°C অস্থায়ী UX মার্জিন).',
      tamil:
          'தோராயமான வரம்பு {low}–{high}°C (±{margin}°C தற்காலிக UX விளிம்பு).',
      filipino:
          'Tinatayang saklaw {low}–{high}°C (±{margin}°C pansamantalang UX margin).',
    ),
    'uncertainty_site_variation_note': l10nEntry(
      english:
          'On-site WBGT can differ from a single weather point — microclimate and work zone matter.',
      arabic:
          'قد يختلف WBGT في الموقع عن نقطة طقس واحدة — المعالم المحلية ومنطقة العمل مهمة.',
      hindi:
          'साइट पर WBGT एक मौसम बिंदु से भिन्न हो सकता है — माइक्रोक्लाइमेट और कार्य क्षेत्र मायने रखते हैं।',
      urdu:
          'سائٹ پر WBGT واحد موسم مقام سے مختلف ہو سکتا ہے — مائیکروکلائمیٹ اور کام کا علاقہ اہم ہے۔',
      malayalam:
          'ഒറ്റ ഫോർകാസ്റ്റ് പോയിന്റിൽ നിന്ന് സൈറ്റ് WBGT വ്യത്യാസപ്പെടാം — മൈക്രോക്ലൈമറ്റ് പ്രാധാന്യം.',
      nepali:
          'साइट WBGT एउटै मौसम बिन्दुभन्दा फरक हुन सक्छ — माइक्रोक्लाइमेट महत्त्वपूर्ण।',
      bengali:
          'একক আবহাওয়া বিন্দুর থেকে সাইটে WBGT আলাদা হতে পারে — মাইক্রোক্লাইমেট গুরুত্বপূর্ণ।',
      tamil:
          'ஒரு வானிலைப் புள்ளியிலிருந்து தள WBGT மாறுபடலாம் — நுண்காலநிலை முக்கியம்.',
      filipino:
          'Maaaring magkaiba ang WBGT sa lugar kumpara sa isang weather point — mahalaga ang microclimate.',
    ),
    'uncertainty_close_to_title': l10nEntry(
      english: 'Close to {level} (upper margin only — not a legal reading).',
      arabic: 'قريب من {level} (الهامش العلوي فقط — ليس قراءة قانونية).',
      hindi: '{level} के निकट (ऊपरी मार्जिन — कानूनी रीडिंग नहीं).',
      urdu: '{level} کے قریب (اوپری مارجن — قانونی ریڈنگ نہیں).',
      malayalam:
          '{level} അടുത്ത് (ഉയർന്ന മാർജിൻ മാത്രം — നിയമപരമായ അല്ല).',
      nepali:
          '{level} नजिक (माथिल्लो मार्जिन मात्र — कानूनी पाठ होइन).',
      bengali:
          '{level}-এর কাছাকাছি (উপরের মার্জিন — আইনি রিডিং নয়).',
      tamil:
          '{level} அருகே (மேல் விளிம்பு மட்டும் — சட்டபூர்வ வாசிப்பு அல்ல).',
      filipino:
          'Malapit sa {level} (itaas na margin lamang — hindi legal na reading).',
    ),
    'uncertainty_provisional_margin_note': l10nEntry(
      english:
          '±2.0°C margin is a provisional UX band, not a validated confidence interval for this formula.',
      arabic:
          '±2.0°م هامش UX مؤقت وليس فترة ثقة مُعتمدة لهذه المعادلة.',
      hindi:
          '±2.0°C मार्जिन अस्थायी UX है, सूत्र के लिए प्रमाणित CI नहीं।',
      urdu:
          '±2.0°C مارجن عارضی UX ہے، فارمولا کے لیے تصدیق شدہ CI نہیں۔',
      malayalam:
          '±2.0°C മാർജിൻ താൽക്കാലിക UX ആണ്; സാധൂകരിച്ച CI അല്ല.',
      nepali:
          '±2.0°C मार्जिन अस्थायी UX हो, सूत्रको प्रमाणित CI होइन।',
      bengali:
          '±2.0°C মার্জিন অস্থায়ী UX; সূত্রের যাচাইকৃত CI নয়।',
      tamil:
          '±2.0°C விளிம்பு தற்காலிக UX; சூத்திரத்திற்கான சரிபார்க்கப்பட்ட CI அல்ல.',
      filipino:
          'Ang ±2.0°C ay pansamantalang UX margin, hindi validated confidence interval.',
    ),
    'meter_section_title': l10nEntry(
      english: 'Local WBGT meter log',
      arabic: 'سجل مقياس WBGT المحلي',
      hindi: 'स्थानीय WBGT मीटर लॉग',
      urdu: 'مقامی WBGT میٹر لاگ',
      malayalam: 'പ്രാദേശിക WBGT മീറ്റർ ലോഗ്',
      nepali: 'स्थानीय WBGT मिटर लग',
      bengali: 'স্থানীয় WBGT মিটার লগ',
      tamil: 'உள்ளூர் WBGT மீட்டர் பதிவு',
      filipino: 'Lokal na WBGT meter log',
    ),
    'meter_section_subtitle': l10nEntry(
      english:
          'Store readings on this device only (20–45°C). Snapshot matches today\'s estimate.',
      arabic:
          'احفظ القراءات على هذا الجهاز فقط (20–45°م). اللقطة تطابق تقدير اليوم.',
      hindi:
          'केवल इस डिवाइस पर सहेजें (20–45°C). स्नैपशॉट आज के अनुमान से मेल।',
      urdu:
          'صرف اس ڈیوائس پر محفوظ (20–45°C)۔ سنیپ شاٹ آج کے تخمینے سے ملے۔',
      malayalam:
          'ഈ ഉപകരണത്തിൽ മാത്രം സൂക്ഷിക്കുക (20–45°C).',
      nepali:
          'यो उपकरणमा मात्र (20–45°C)।',
      bengali:
          'শুধু এই ডিভাইসে (20–45°C) সংরক্ষণ।',
      tamil:
          'இந்த சாதனத்தில் மட்டும் (20–45°C) சேமிப்பு।',
      filipino:
          'Sa device na ito lang (20–45°C); snapshot ng tantya ngayon.',
    ),
    'meter_value_label': l10nEntry(
      english: 'Meter WBGT (°C)',
      arabic: 'WBGT من المقياس (°م)',
      hindi: 'मीटर WBGT (°C)',
      urdu: 'میٹر WBGT (°C)',
      malayalam: 'മീറ്റർ WBGT (°C)',
      nepali: 'मिटर WBGT (°C)',
      bengali: 'মিটার WBGT (°C)',
      tamil: 'மீட்டர் WBGT (°C)',
      filipino: 'Meter WBGT (°C)',
    ),
    'meter_value_hint': l10nEntry(
      english: 'Between {min} and {max}°C',
      arabic: 'بين {min} و {max}°م',
      hindi: '{min} से {max}°C के बीच',
      urdu: '{min} سے {max}°C',
      malayalam: '{min}–{max}°C',
      nepali: '{min}–{max}°C',
      bengali: '{min}–{max}°C',
      tamil: '{min}–{max}°C',
      filipino: 'Sa pagitan ng {min}–{max}°C',
    ),
    'meter_note_label': l10nEntry(
      english: 'Short note (optional)',
      arabic: 'ملاحظة قصيرة (اختياري)',
      hindi: 'संक्षिप्त नोट (वैकल्पिक)',
      urdu: 'مختصر نوٹ (اختیاری)',
      malayalam: 'ചെറിയ കുറിപ്പ് (ഓപ്ഷണൽ)',
      nepali: 'छोटो नोट (वैकल्पिक)',
      bengali: 'সংক্ষিপ্ত নোট (ঐচ্ছিক)',
      tamil: 'குறுகிய குறிப்பு (விருப்பம்)',
      filipino: 'Maikling tala (opsyonal)',
    ),
    'meter_note_hint': l10nEntry(
      english: 'e.g. warehouse aisle — no names or phone numbers',
      arabic: 'مثال: ممر المستودع — دون أسماء أو أرقام',
      hindi: 'जैसे गोदाम गलियारा — नाम/फ़ोन नहीं',
      urdu: 'مثلاً گودام — نام یا فون نمبر نہیں',
      malayalam: 'ഉദാ. വെയർഹൗസ് — പേര്/ഫോൺ വേണ്ട',
      nepali: 'जस्तै वेयरहाउस — नाम/फोन होइन',
      bengali: 'যেমন গুদাম — নাম/ফোন নয়',
      tamil: 'எ.கா கிடங்கு — பெயர்/தொலைபேசி வேண்டாம்',
      filipino: 'hal. warehouse — walang pangalan o telepono',
    ),
    'meter_save': l10nEntry(
      english: 'Save reading',
      arabic: 'حفظ القراءة',
      hindi: 'रीडिंग सहेजें',
      urdu: 'ریڈنگ محفوظ کریں',
      malayalam: 'റീഡിംഗ് സേവ്',
      nepali: 'रीडिंग बचत गर्नुहोस्',
      bengali: 'রিডিং সংরক্ষণ',
      tamil: 'வாசிப்பைச் சேமி',
      filipino: 'I-save ang reading',
    ),
    'meter_invalid_value': l10nEntry(
      english: 'Enter a number between 20 and 45°C.',
      arabic: 'أدخل رقماً بين 20 و 45°م.',
      hindi: '20–45°C के बीच संख्या दर्ज करें।',
      urdu: '20–45°C کے درمیان نمبر درج کریں۔',
      malayalam: '20–45°C ഇടയിൽ നമ്പർ നൽകുക.',
      nepali: '20–45°C बीचको नम्बर।',
      bengali: '20–45°C-এর মধ্যে সংখ্যা।',
      tamil: '20–45°C இடையே எண் உள்ளிடவும்.',
      filipino: 'Maglagay ng numero sa pagitan ng 20–45°C.',
    ),
    'meter_note_rejected': l10nEntry(
      english: 'Note cannot include phone numbers or personal names.',
      arabic: 'لا يمكن أن تتضمن الملاحظة أرقاماً أو أسماء شخصية.',
      hindi: 'नोट में फ़ोन या नाम नहीं हो सकते।',
      urdu: 'نوٹ میں فون یا نام نہیں ہو سکتے۔',
      malayalam: 'നോട്ടിൽ ഫോൺ/പേരുകൾ അനുവദനീയമല്ല.',
      nepali: 'नोटमा फोन/नाम नहोस्।',
      bengali: 'নোটে ফোন বা নাম নয়।',
      tamil: 'குறிப்பில் தொலைபேசி/பெயர் வேண்டாம்.',
      filipino: 'Walang telepono o pangalan sa tala.',
    ),
    'meter_not_legal_record': l10nEntry(
      english: 'Not an official or legal record.',
      arabic: 'ليس سجلاً رسمياً أو قانونياً.',
      hindi: 'आधिकारिक या कानूनी रिकॉर्ड नहीं।',
      urdu: 'سرکاری یا قانونی ریکارڈ نہیں۔',
      malayalam: 'ഔദ്യോഗിക/നിയമപരമായ രേഖയല്ല.',
      nepali: 'आधिकारिक/कानूनी रेकर्ड होइन।',
      bengali: 'সরকারি বা আইনি রেকর্ড নয়।',
      tamil: 'அதிகாரப்பூர்வ அல்லது சட்டபூர்வ பதிவு அல்ல.',
      filipino: 'Hindi opisyal o legal na rekord.',
    ),
    'meter_latest_heading': l10nEntry(
      english: 'Latest saved reading',
      arabic: 'أحدث قراءة محفوظة',
      hindi: 'नवीनतम सहेजी गई रीडिंग',
      urdu: 'تازہ ترین محفوظ ریڈنگ',
      malayalam: 'ഏറ്റവും പുതിയ റീഡിംഗ്',
      nepali: 'पछिल्लो बचत रीडिंग',
      bengali: 'সর্বশেষ সংরক্ষিত রিডিং',
      tamil: 'சமீபத்திய சேமிப்பு வாசிப்பு',
      filipino: 'Pinakabagong naka-save na reading',
    ),
    'meter_latest_value_line': l10nEntry(
      english: 'Meter: {value}°C',
      arabic: 'المقياس: {value}°م',
      hindi: 'मीटर: {value}°C',
      urdu: 'میٹر: {value}°C',
      malayalam: 'മീറ്റർ: {value}°C',
      nepali: 'मिटर: {value}°C',
      bengali: 'মিটার: {value}°C',
      tamil: 'மீட்டர்: {value}°C',
      filipino: 'Meter: {value}°C',
    ),
    'meter_latest_meta': l10nEntry(
      english:
          '{time} · estimate at save {estimate}°C ({band}) · difference {diff}°C',
      arabic:
          '{time} · التقدير عند الحفظ {estimate}°م ({band}) · الفرق {diff}°م',
      hindi:
          '{time} · सेव पर अनुमान {estimate}°C ({band}) · अंतर {diff}°C',
      urdu:
          '{time} · محفوظ پر تخمینہ {estimate}°C ({band}) · فرق {diff}°C',
      malayalam:
          '{time} · സേവ് സമയത്തെ ഏകദേശം {estimate}°C ({band}) · വ്യത്യാസം {diff}°C',
      nepali:
          '{time} · बचतमा अनुमान {estimate}°C ({band}) · भिन्नता {diff}°C',
      bengali:
          '{time} · সংরক্ষণে অনুমান {estimate}°C ({band}) · পার্থক্য {diff}°C',
      tamil:
          '{time} · சேமிப்பில் நேர மதிப்பீடு {estimate}°C ({band}) · வேறுபாடு {diff}°C',
      filipino:
          '{time} · tantya nang mag-save {estimate}°C ({band}) · diperensya {diff}°C',
    ),
    'meter_current_estimate_line': l10nEntry(
      english: 'Now: estimate {estimate}°C ({band}) — meter does not lower this band.',
      arabic:
          'الآن: التقدير {estimate}°م ({band}) — المقياس لا يخفّض هذا التصنيف.',
      hindi:
          'अब: अनुमान {estimate}°C ({band}) — मीटर यह बैंड कम नहीं करता।',
      urdu:
          'اب: تخمینہ {estimate}°C ({band}) — میٹر بینڈ کم نہیں کرتا۔',
      malayalam:
          'ഇപ്പോൾ: ഏകദേശം {estimate}°C ({band}) — മീറ്റർ ബാൻഡ് കുറയ്ക്കില്ല.',
      nepali:
          'अहिले: अनुमान {estimate}°C ({band}) — मिटरले ब्यान्ड घटाउँदैन।',
      bengali:
          'এখন: অনুমান {estimate}°C ({band}) — মিটার ব্যান্ড কমায় না।',
      tamil:
          'இப்போது: மதிப்பீடு {estimate}°C ({band}) — மீட்டர் பட்டையை குறைக்காது.',
      filipino:
          'Ngayon: tantya {estimate}°C ({band}) — hindi ibinababa ng meter ang band.',
    ),
    'meter_caution_higher_title': l10nEntry(
      english: 'Meter suggests higher caution',
      arabic: 'المقياس يشير إلى حذر أعلى',
      hindi: 'मीटर उच्च सावधानी दर्शाता है',
      urdu: 'میٹر زیادہ احتیاط کی نشاندہی',
      malayalam: 'മീറ്റർ ഉയർന്ന ജാഗ്രത സൂചിപ്പിക്കുന്നു',
      nepali: 'मिटरले उच्च सावधानी संकेत',
      bengali: 'মিটার উচ্চতর সতর্কতা নির্দেশ করে',
      tamil: 'மீட்டர் அதிக எச்சரிக்கையைக் குறிக்கிறது',
      filipino: 'Mas mataas na babala mula sa meter',
    ),
    'meter_share_latest': l10nEntry(
      english: 'Share latest reading',
      arabic: 'مشاركة أحدث قراءة',
      hindi: 'नवीनतम रीडिंग साझा करें',
      urdu: 'تازہ ریڈنگ شیئر کریں',
      malayalam: 'ഏറ്റവും പുതിയത് ഷെയർ ചെയ്യുക',
      nepali: 'पछिल्लो रीडिंग साझा',
      bengali: 'সর্বশেষ রিডিং শেয়ার',
      tamil: 'சமீப வாசிப்பைப் பகிர்',
      filipino: 'I-share ang pinakabagong reading',
    ),
    'meter_share_body': l10nEntry(
      english:
          'WBGT meter {meter}°C vs Raabta estimate {estimate}°C ({diff}°C) at {time}. {disclaimer}',
      arabic:
          'مقياس WBGT {meter}°م مقابل تقدير Raabta {estimate}°م ({diff}°م) {time}. {disclaimer}',
      hindi:
          'WBGT मीटर {meter}°C बनाम अनुमान {estimate}°C ({diff}°C) {time}. {disclaimer}',
      urdu:
          'WBGT میٹر {meter}°C بمقابلہ تخمینہ {estimate}°C ({diff}°C) {time}. {disclaimer}',
      malayalam:
          'WBGT {meter}°C vs {estimate}°C ({diff}°C) {time}. {disclaimer}',
      nepali:
          'WBGT {meter}°C बनाम {estimate}°C ({diff}°C) {time}. {disclaimer}',
      bengali:
          'WBGT {meter}°C বনাম {estimate}°C ({diff}°C) {time}. {disclaimer}',
      tamil:
          'WBGT {meter}°C எதிர் {estimate}°C ({diff}°C) {time}. {disclaimer}',
      filipino:
          'WBGT meter {meter}°C vs tantya {estimate}°C ({diff}°C) {time}. {disclaimer}',
    ),
    'empty_route_title': l10nEntry(
      english: 'Plan a heat-safe journey',
      arabic: 'خطّط رحلة آمنة من الحر',
      hindi: 'गर्मी-सुरक्षित यात्रा की योजना बनाएँ',
      urdu: 'گرمی سے محفوظ سفر کی منصوبہ بندی کریں',
    ),
    'empty_route_body': l10nEntry(
      english:
          'Enter where you are and where you\'re going. AI ranks 3 routes by heat exposure.',
      arabic: 'أدخل موقعك ووجهتك. يصنّف الذكاء الاصطناعي 3 مسارات حسب الحر.',
      hindi: 'आप कहाँ हैं और कहाँ जा रहे हैं — AI 3 रास्ते heat के अनुसार rank करेगा।',
      urdu: 'آپ کہاں ہیں اور کہاں جا رہے ہیں — AI 3 راستے گرمی کے مطابق rank کرے گا۔',
    ),
    'route_history_title': l10nEntry(
      english: 'Recent journeys',
      arabic: 'رحلات حديثة',
      hindi: 'हाल की यात्राएँ',
      urdu: 'حالیہ سفر',
    ),
    'route_map_preview': l10nEntry(
      english: 'Route preview',
      arabic: 'معاينة المسار',
      hindi: 'रूट preview',
      urdu: 'راستے کا preview',
    ),
    'compliance_restricted_question': l10nEntry(
      english: 'Is outdoor work currently restricted?',
      arabic: 'هل العمل في الهواء الطلق مقيد حالياً؟',
      hindi: 'क्या बाहरी काम अभी प्रतिबंधित है?',
      urdu: 'کیا بیرونی کام فی الحال محدود ہے؟',
      bengali: 'বাইরের কাজ কি এখন সীমাবদ্ধ?',
      tamil: 'வெளிப்புற வேலை தற்போது தடைசெய்யப்பட்டுள்ளதா?',
      filipino: 'Restricted ba ang outdoor work ngayon?',
    ),
    'compliance_yes': l10nEntry(
      english: 'YES — restricted',
      arabic: 'نعم — مقيد',
      hindi: 'हाँ — प्रतिबंधित',
      urdu: 'ہاں — محدود',
      bengali: 'হ্যাঁ — সীমাবদ্ধ',
      tamil: 'ஆம் — தடை',
      filipino: 'OO — restricted',
    ),
    'compliance_no': l10nEntry(
      english: 'NO — not restricted',
      arabic: 'لا — غير مقيد',
      hindi: 'नहीं — प्रतिबंधित नहीं',
      urdu: 'نہیں — محدود نہیں',
      bengali: 'না — সীমাবদ্ধ নয়',
      tamil: 'இல்லை — தடை இல்லை',
      filipino: 'HINDI — hindi restricted',
    ),
    'compliance_clock_ban_label': l10nEntry(
      english: 'Clock ban (seasonal window)',
      arabic: 'حظر الساعة (النافذة الموسمية)',
      hindi: 'घड़ी प्रतिबंध (मौसमी समय)',
      urdu: 'گھڑی پابندی (موسمی ونڈو)',
      bengali: 'ঘড়ি নিষেধ (মৌসুমি সময়)',
      tamil: 'நேர தடை (பருவகால சாளரம்)',
      filipino: 'Clock ban (seasonal window)',
    ),
    'compliance_wbgt_label': l10nEntry(
      english: 'WBGT stop (year-round)',
      arabic: 'إيقاف WBGT (على مدار السنة)',
      hindi: 'WBGT रोक (साल भर)',
      urdu: 'WBGT روک (سال بھر)',
      bengali: 'WBGT স্টপ (সারা বছর)',
      tamil: 'WBGT நிறுத்தம் (ஆண்டு முழுவதும்)',
      filipino: 'WBGT stop (year-round)',
    ),
    'compliance_clock_ban_off_season': l10nEntry(
      english:
          'Seasonal clock restriction not in effect (1 Jun–15 Sep). This does not mean conditions are safe.',
      arabic:
          'حظر الساعة الموسمي غير ساري (1 يونيو–15 سبتمبر). هذا لا يعني أن الظروف آمنة.',
      hindi:
          'मौसमी घड़ी प्रतिबंध लागू नहीं (1 जून–15 सितंबर)। इसका मतलब सुरक्षित नहीं।',
      urdu:
          'موسمی گھڑی پابندی نافذ نہیں (1 جون–15 ستمبر)۔ اس کا مطلب محفوظ نہیں۔',
      bengali:
          'মৌসুমি ঘড়ি নিষেধ কার্যকর নয় (১ জুন–১৫ সেপ)। এটি নিরাপদ বোঝায় না।',
      tamil:
          'பருவகால நேர தடை நடைமுறையில் இல்லை (1 ஜூன்–15 செப்). இது பாதுகாப்பானது என்று அர்த்தமல்ல.',
      filipino:
          'Hindi aktibo ang seasonal clock ban (Hun 1–Set 15). Hindi ibig sabihin na safe.',
    ),
    'compliance_off_season_note': l10nEntry(
      english:
          'Off-season for the clock ban: only the year-round WBGT limit applies right now.',
      arabic:
          'خارج موسم حظر الساعة: ينطبق حد WBGT السنوي فقط الآن.',
      hindi:
          'घड़ी प्रतिबंध का ऑफ-सीजन: अभी केवल WBGT सीमा लागू है।',
      urdu:
          'گھڑی پابندی کا آف سیزن: اب صرف WBGT حد لاگو ہے۔',
      bengali:
          'ঘড়ি নিষেধের অফ-সিজন: এখন শুধু WBGT সীমা প্রযোজ্য।',
      tamil:
          'நேர தடை ஆஃப்-சீசன்: இப்போது WBGT வரம்பு மட்டுமே பொருந்தும்.',
      filipino:
          'Off-season para sa clock ban: WBGT limit lang ang applicable ngayon.',
    ),
    'compliance_clock_ban_active': l10nEntry(
      english: 'Active now — outdoor work restricted {window} (Qatar time).',
      arabic: 'نشط الآن — العمل في الهواء الطلق مقيد {window} (توقيت قطر).',
      hindi: 'अभी सक्रिय — बाहरी काम {window} (कतर समय) तक प्रतिबंधित।',
      urdu: 'ابھی فعال — بیرونی کام {window} (قطر وقت) تک محدود۔',
      bengali: 'এখন সক্রিয় — বাইরের কাজ {window} (কাতার সময়) সীমিত।',
      tamil: 'இப்போது செயலில் — வெளிப்புற வேலை {window} (Qatar நேரம்) தடை.',
      filipino: 'Aktibo ngayon — restricted ang outdoor work {window} (Qatar time).',
    ),
    'compliance_clock_ban_inactive': l10nEntry(
      english:
          'Not in the daily restricted window ({window} Qatar time) — clock ban not active right now.',
      arabic:
          'خارج النافذة اليومية ({window} توقيت قطر) — حظر الساعة غير نشط الآن.',
      hindi:
          'दैनिक प्रतिबंधित समय ({window} कतर) में नहीं — घड़ी प्रतिबंध अभी नहीं।',
      urdu:
          'روزانہ محدود ونڈو ({window} قطر) میں نہیں — گھڑی پابندی ابھی نہیں۔',
      bengali:
          'দৈনিক সীমিত সময় ({window} কatar) এর বাইরে — ঘড়ি নিষেধ এখন নয়।',
      tamil:
          'தினசரி தடை சாளரம் ({window} Qatar நேரம்) இல்லை — நேர தடை இப்போது இல்லை.',
      filipino:
          'Wala sa daily window ({window} Qatar time) — hindi aktibo ang clock ban.',
    ),
    'compliance_wbgt_active': l10nEntry(
      english:
          'Estimated WBGT {wbgt}°C exceeds {threshold}°C — outdoor work must stop.',
      arabic:
          'WBGT التقديري {wbgt}°C يتجاوز {threshold}°C — يجب إيقاف العمل في الهواء الطلق.',
      hindi:
          'अनुमानित WBGT {wbgt}°C {threshold}°C से अधिक — बाहरी काम रोकें।',
      urdu:
          'تخمینی WBGT {wbgt}°C {threshold}°C سے زیادہ — بیرونی کام بند کریں۔',
      bengali:
          'আনুমানিক WBGT {wbgt}°C {threshold}°C-এর বেশি — বাইরের কাজ বন্ধ করুন।',
      tamil:
          'மதிப்பிடப்பட்ட WBGT {wbgt}°C {threshold}°C-ஐ மீறுகிறது — வெளிப்புற வேலை நிறுத்த வேண்டும்.',
      filipino:
          'Lampas ang tantyang WBGT {wbgt}°C sa {threshold}°C — dapat tumigil ang outdoor work.',
    ),
    'compliance_wbgt_inactive': l10nEntry(
      english:
          'Estimated WBGT {wbgt}°C is at or below {threshold}°C — WBGT stop not triggered.',
      arabic:
          'WBGT التقديري {wbgt}°C عند أو دون {threshold}°C — إيقاف WBGT غير مفعّل.',
      hindi:
          'अनुमानित WBGT {wbgt}°C {threshold}°C पर या नीचे — WBGT रोक सक्रिय नहीं।',
      urdu:
          'تخمینی WBGT {wbgt}°C {threshold}°C یا کم — WBGT روک فعال نہیں۔',
      bengali:
          'আনুমানিক WBGT {wbgt}°C {threshold}°C-এ বা নিচে — WBGT স্টপ ট্রিগার হয়নি।',
      tamil:
          'மதிப்பிடப்பட்ட WBGT {wbgt}°C {threshold}°C-க்கு சமமாகவோ குறைவாகவோ — WBGT நிறுத்தம் இல்லை.',
      filipino:
          'Ang tantyang WBGT {wbgt}°C ay sa o below {threshold}°C — hindi na-trigger ang WBGT stop.',
    ),
    'compliance_regulation_cite': l10nEntry(
      english:
          'Source: {decision}, {ministry}. Seasonal clock ban: {season}, {window} Qatar time. Year-round WBGT stop above {threshold}°C.',
      arabic:
          'المصدر: {decision}، {ministry}. حظر الساعة: {season}، {window} توقيت قطر. إيقاف WBGT فوق {threshold}°C على مدار السنة.',
      hindi:
          'स्रोत: {decision}, {ministry}. मौसमी प्रतिबंध: {season}, {window} कतर समय। WBGT रोक {threshold}°C से ऊपर।',
      urdu:
          'ماخذ: {decision}، {ministry}. موسمی پابندی: {season}، {window} قطر وقت۔ WBGT روک {threshold}°C سے اوپر۔',
      bengali:
          'উৎস: {decision}, {ministry}. মৌসুমি নিষেধ: {season}, {window} কatar সময়। WBGT স্টপ {threshold}°C-এর উপরে।',
      tamil:
          'மூலம்: {decision}, {ministry}. பருவகால தடை: {season}, {window} Qatar நேரம். WBGT நிறுத்தம் {threshold}°C-க்கு மேல்.',
      filipino:
          'Source: {decision}, {ministry}. Seasonal ban: {season}, {window} Qatar time. WBGT stop above {threshold}°C.',
    ),
    'compliance_shaded_exception_note': l10nEntry(
      english:
          'Shaded or ventilated workplaces may be exempt from the clock ban — Raabta cannot verify your site type.',
      arabic:
          'قد تُستثنى أماكن العمل المظللة أو الم ventilated من حظر الساعة — Raabta لا يمكنها التحقق من موقعك.',
      hindi:
          'छायादार/ventilated workplaces clock ban से छूट हो सकती हैं — Raabta आपकी site verify नहीं कर सकता।',
      urdu:
          'سaye یا ventilated workplaces clock ban سے مستثنیٰ ہو سکتی ہیں — Raabta site verify نہیں کر سکتا۔',
      bengali:
          'ছায়াযukt/ventilated কর্মস্থল clock ban থেকে exempt হতে পারে — Raabta site verify করতে পারে না।',
      tamil:
          'நிழல்/ventilated பணியிடங்கள் நேர தடையிலிருந்து விலக்கு — Raabta உங்கள் site-ஐ verify செய்ய முடியாது.',
      filipino:
          'Maaaring exempt ang shaded/ventilated workplaces sa clock ban — hindi ma-verify ng Raabta ang site mo.',
    ),
    'compliance_disclaimer': l10nEntry(
      english:
          'Informational only — not legal advice or an official Ministry of Labour determination. Confirm with your employer and official sources.',
      arabic:
          'للمعلومات فقط — ليس استشارة قانونية أو قراراً رسمياً من وزارة العمل. تأكد من جهة عملك والمصادر الرسمية.',
      hindi:
          'केवल जानकारी — कानूनी सलाह या MoL का आधिकारिक निर्धारण नहीं। नियोक्ता और आधिकारिक स्रोतों से पुष्टि करें।',
      urdu:
          'صرف معلومات — قانونی مشورہ یا MoL کا سرکاری فیصلہ نہیں۔ آجر اور سرکاری ذرائع سے تصدیق کریں۔',
      bengali:
          'শুধু তথ্য — আইনি পরামর্শ বা MoL-এর সরকারি সিদ্ধান্ত নয়। নিয়োগকর্তা ও সরকারি উৎসে নিশ্চিত করুন।',
      tamil:
          'தகவல் மட்டும் — சட்ட ஆலோசனை அல்லது MoL-ன் அதிகாரப்பூர்வ தீர்மானம் அல்ல. முதலாளி/அதிகாரப்பூர்வ ஆதாரங்களில் உறுதி செய்யுங்கள்.',
      filipino:
          'Impormasyon lang — hindi legal advice o opisyal na MoL determination. Kumpirmahin sa employer at opisyal na sources.',
    ),
    'section_worker_rights_overline': l10nEntry(
      english: 'Know your protections',
      arabic: 'اعرف حقوقك',
      hindi: 'अपने संरक्षण जानें',
      urdu: 'اپنے تحفظات جانیں',
      bengali: 'আপনার সুরক্ষা জানুন',
      tamil: 'உங்கள் பாதுகாப்புகளை அறியுங்கள்',
      malayalam: 'നിങ്ങളുടെ സംരക്ഷണം',
      nepali: 'आफ्नो सुरक्षा जान्नुहोस्',
      filipino: 'Alamin ang iyong proteksyon',
    ),
    'section_worker_rights_title': l10nEntry(
      english: 'Qatar heat worker rights (education)',
      arabic: 'حقوق العمال من الحر في قطر (تعليمي)',
      hindi: 'कतर गर्मी श्रमिक अधिकार (शिक्षा)',
      urdu: 'قطر گرمی مزدور حقوق (تعلیم)',
      bengali: 'কাতার তাপ শ্রমিক অধিকার (শিক্ষামূলক)',
      tamil: 'கத்தார் வெப்ப தொழிலாளர் உரிமைகள் (கல்வி)',
      malayalam: 'Qatar heat worker rights (education)',
      nepali: 'कतार ताप श्रमिक अधिकार (शैक्षिक)',
      filipino: 'Qatar heat worker rights (education)',
    ),
    'rights_applicability_art8_banner': l10nEntry(
      english:
          'Ministerial Decision No. 17 of 2021 may not apply to activities undertaken by companies working on oil and gas projects (Art. 8). Working for an oil or gas company does not by itself mean this decision does or does not apply to you. Raabta cannot infer applicability from your employer name, job title, profile or location — confirm with your employer and official sources.',
      arabic:
          'قد لا ينطبق القرار الوزاري 17/2021 على الأنشطة التي تنجزها شركات تعمل في مشروعات النفط والغاز (المادة 8). العمل لدى شركة نفط أو غاز لا يعني تلقائياً الانطباق أو عدمه. لا تستطيع Raabta استنتاج الانطباق من اسم جهة العمل أو المسمى أو الملف أو الموقع — تأكد من جهة عملك والمصادر الرسمية.',
      hindi:
          'मंत्रial Decision 17/2021 तेल-गैस परियोजना गतिविधियों पर लागू नहीं हो सकता (अनुच्छेद 8)। तेल/गैस कंपनी में होना स्वचालित रूप से लागू/अलाग नहीं करता। Raabta नियोक्ता, पद, प्रोफ़ाइल या स्थान से अनुमान नहीं लगाता।',
      urdu:
          'وزاری فیصلہ 17/2021 تیل و گیس منصوبوں کی سرگرمیوں پر لاگو نہ ہو (آرٹیکل 8)۔ تیل/گیس کمپنی میں کام خود بخود لاگو یا نہ ہو کا ثبوت نہیں۔ Raabta آجر، عنوان، پروفائل یا مقام سے اطلاق نہیں لگاتی۔',
      bengali:
          'মন্ত্রিসভা সিদ্ধান্ত 17/2021 তেল-গ্যাস প্রকল্পের কার্যক্রমে প্রযোজ্য নাও হতে পারে (অনুচ্ছেদ 8)। তেল/গ্যাস কোম্পানিতে কাজ মানে স্বয়ংক্রিয় বহির্ভূত নয়। Raabta নিয়োগকর্তা, পদ, প্রোফাইল বা অবস্থান থেকে অনুমান করে না।',
      tamil:
          'அமைச்சரவை முடிவு 17/2021 எண்ணெய்/எரிவாயு திட்டச் செயல்களுக்குப் பொருந்தாமல் போகலாம் (பிரிவு 8). எண்ணெய்/எரிவாயு நிறுவனத்தில் பணி தானாக விலக்கு அல்ல. Raabta பணியாளி/பதவி/சுயவிவர/இடத்திலிருந்து அனுமானிக்காது.',
      malayalam:
          'MD 17/2021 oil & gas project activities (Art. 8) il apply aakanilla ennullathu sambhavikkum. O&G company employment alone decisive alla. Raabta employer/job/profile/location ninnu infer cheyyilla.',
      nepali:
          'मन्त्रिपरिषद निर्णय 17/2021 तेल-ग्यास परियोजनाको गतिविधिमा लागू नहुन सक्छ (धारा 8)। तेल/ग्यास कम्पनीमा काम मात्रले लागू/नलागू थाहा हुँदैन। Raabta ले रोजगारदाता, पद, प्रोफाइल वा स्थानबाट अनुमान गर्दैन।',
      filipino:
          'MD 17/2021 maaaring hindi applicable sa oil and gas project activities (Art. 8). Hindi automatic ang exempt/in-scope kapag O&G employer. Hindi nag-iinfer ang Raabta mula sa employer, title, profile o lokasyon.',
    ),
    'rights_disclaimer_informational': l10nEntry(
      english:
          'Educational summary only — not legal advice or an official Ministry of Labour determination.',
      arabic: 'ملخص تعليمي فقط — ليس استشارة قانونية أو قراراً رسمياً من وزارة العمل.',
      hindi: 'केवल शैक्षिक सारांश — कानूनी सलाह या MoL निर्धारण नहीं।',
      urdu: 'صرف تعلیمی خلاصہ — قانونی مشورہ یا MoL کا سرکاری فیصلہ نہیں۔',
      bengali: 'শুধু শিক্ষামূলক সারাংশ — আইনি পরামর্শ বা MoL সিদ্ধান্ত নয়।',
      tamil: 'கல்வி சுருக்கம் மட்டும் — சட்ட ஆலோசனை அல்லது MoL தீர்மானம் அல்ல.',
      malayalam: 'Educational summary only — not legal advice or MoL determination.',
      nepali: 'शैक्षिक सारांश मात्र — कानूनी सलाह वा MoL निर्धारण होइन।',
      filipino: 'Educational summary lang — hindi legal advice o opisyal na MoL determination.',
    ),
    'rights_wbgt_workplace_vs_estimate': l10nEntry(
      english:
          'Articles 4(8) and 4(9) refer to workplace WBGT measured at the site with approved methods — not Raabta’s weather-based WBGT estimate shown elsewhere in this screen.',
      arabic:
          'المادتان 4(8) و4(9) تتعلق بقياس WBGT في مكان العمل — وليس تقدير Raabta من بيانات الطقس في هذه الشاشة.',
      hindi:
          'अनुच्छेद 4(8)(9) कार्यस्थल WBGT माप से — Raabta के मौसम अनुमान से नहीं।',
      urdu:
          'آرٹیکل 4(8)(9) کام کی جگہ کے WBGT پیمائش سے — اس اسکرین کے موسم کے تخمینے سے نہیں۔',
      bengali:
          'অনুচ্ছেদ 4(8)(9) কর্মক্ষেত্রে WBGT পরিমাপ — Raabta-র আবহাওয়া অনুমান নয়।',
      tamil:
          'பிரிவுகள் 4(8)(9) பணியிட WBGT அளவீடு — இந்த திரையின் வானிலை மதிப்பீடு அல்ல.',
      malayalam:
          'Art 4(8)(9) workplace WBGT measure — Raabta weather estimate alla.',
      nepali:
          'धारा 4(8)(9) कार्यस्थल WBGT माप — Raabta को मौसम अनुमान होइन।',
      filipino:
          'Art 4(8)(9) ay workplace WBGT measurement — hindi ang weather estimate ng Raabta sa screen na ito.',
    ),
    'rights_binding_law_heading': l10nEntry(
      english: 'Binding law — Ministerial Decision No. 17 of 2021',
      arabic: 'قانون ملزم — القرار الوزاري رقم 17 لسنة 2021',
      hindi: 'बाध्यकारी कानून — मंत्रial Decision 17/2021',
      urdu: 'لازمی قانون — وزاری فیصلہ 17/2021',
      bengali: 'বাধ্যতামূলক আইন — মন্ত্রিসভা সিদ্ধান্ত 17/2021',
      tamil: 'கட்டாயச் சட்டம் — அமைச்சரவை முடிவு 17/2021',
      malayalam: 'Binding law — Ministerial Decision No. 17 of 2021',
      nepali: 'बाध्यकारी कानून — मन्त्रिपरिषद निर्णय 17/2021',
      filipino: 'Binding law — Ministerial Decision No. 17 of 2021',
    ),
    'rights_guidance_nonbinding_note': l10nEntry(
      english:
          'The Ministry of Labour employer heat-stress guide explains practices; it is guidance, not a substitute for the ministerial decision.',
      arabic: 'دليل وزارة العمل لأصحاب العمل إرشادي وليس بديلاً عن القرار الوزاري.',
      hindi: 'MoL गाइड मार्गदर्शन है, मंत्रial निर्णय का विकल्प नहीं।',
      urdu: 'MoL گائیڈ رہنمائی ہے، وزاری فیصلے کا متبادل نہیں۔',
      bengali: 'MoL গাইড নির্দেশনা; মন্ত্রিসভা সিদ্ধান্তের বিকল্প নয়।',
      tamil: 'MoL வழிகாட்டுதல் — அமைச்சரவை முடிவின் மாற்று அல்ல.',
      malayalam: 'MoL employer heat guide — guidance only, not law substitute.',
      nepali: 'MoL मार्गदर्शन हो — मन्त्रिपरिषद निर्णयको विकल्प होइन।',
      filipino: 'MoL heat guide ay gabay lang — hindi kapalit ng ministerial decision.',
    ),
    'rights_bullet_art1_definitions': l10nEntry(
      english:
          '• Art. 1 — “Outdoor workplaces” expose workers to weather (sun, heat, humidity). “Shaded and ventilated workplaces” require sufficient ventilation, no solar radiation on workers, and no extra heat from operating machines (as defined in the decision).',
      arabic:
          '• المادة 1 — أماكن العمل في الهواء الطلق: تعرض للطقس. المظللة والمهواة: تهوية كافية، بلا إشعاع شمسي على العمال، بلا حرارة إضافية من الآلات (حسب التعريف).',
      hindi:
          '• अनुच्छेद 1 — बाहरी कार्यस्थल: मौसम का संपर्क। छायादार व ventilated: पर्याप्त वेंटिलेशन, सूर्य विकिरण नहीं, मशीनों से अतिरिक्त गर्मी नहीं।',
      urdu:
          '• آرٹیکل 1 — بیرونی workplaces: موسم کا سامنا۔ سایہ دار و ہوادار: مناسب ہوا، دھوپ کا اثر نہیں، مشینوں کی اضافی حرارت نہیں۔',
      bengali:
          '• অনুচ্ছেদ 1 — বাইরের কর্মক্ষেত্র: আবহাওয়ার সংস্পর্শ। ছায়াযুক্ত ও বাতাসযুক্ত: পর্যাপ্ত বায়ু, সূর্যের বিকিরণ নেই, যন্ত্রের অতিরিক্ত তাপ নেই।',
      tamil:
          '• பிரிவு 1 — வெளிப்பணியிடம்: வானிலை வெளிப்பாடு. நிழல்/ventilated: போதிய காற்றோட்டம், சூரிய கதிர்வீச்சு இல்லை, இயந்திர வெப்பம் இல்லை.',
      malayalam:
          '• Art. 1 — outdoor vs shaded/ventilated workplace definitions (decision text).',
      nepali:
          '• धारा 1 — बाहिरी कार्यस्थल: मौसमसँग सम्पर्क। छाया/भेन्टिलेट: पर्याप्त भेन्टिलेसन, घाम छैन, मेसिनको अतिरिक्त ताप छैन।',
      filipino:
          '• Art. 1 — outdoor workplaces at weather; shaded/ventilated: ventilation, no sun on workers, no machine heat (per decision).',
    ),
    'rights_bullet_art2_seasonal_restriction': l10nEntry(
      english:
          '• Art. 2 — From {season}, {window} Qatar time: prohibited to work in the sun, in outdoor workplaces, or in places that are not shaded and ventilated.',
      arabic:
          '• المادة 2 — من {season}، {window} بتوقيت قطر: يحظر العمل في الشمس أو في الهواء الطلق أو في غير المظلل والمهوى.',
      hindi:
          '• अनुच्छेद 2 — {season}, {window} कतर समय: धूप/बाहरी/गैर-छायादार व ventilated में काम निषिद्ध।',
      urdu:
          '• آرٹیکل 2 — {season}، {window} قطر وقت: دھوپ، بیرونی، یا غیر سایہ دار/ہوادار جگہوں میں کام ممنوع۔',
      bengali:
          '• অনুচ্ছেদ 2 — {season}, {window} কাতার সময়: রোদে, বাইরে বা ছায়াযুক্ত/বাতাসযুক্ত নয় এমন জায়গায় কাজ নিষিদ্ধ।',
      tamil:
          '• பிரிவு 2 — {season}, {window} கத்தார் நேரம்: சூரியனில், வெளிப்பணியிடத்தில் அல்லது நிழல்/ventilated அல்லாத இடங்களில் வேலை தடை.',
      malayalam:
          '• Art. 2 — {season}, {window} Qatar time: sun/outdoor/not shaded+ventilated work prohibited.',
      nepali:
          '• धारा 2 — {season}, {window} कतार समय: घाम, बाहिरी, वा छाया/भेन्टिलेट नभएको ठाउँमा काम निषेध।',
      filipino:
          '• Art. 2 — {season}, {window} Qatar time: bawal sa araw, outdoor, o hindi shaded/ventilated.',
    ),
    'rights_bullet_art1_shaded_ventilated_qualification': l10nEntry(
      english:
          '• Art. 1 (qualification) — The seasonal Art. 2 prohibition does not apply to workplaces that meet the Art. 1 “shaded and ventilated” definition. Meeting that definition does not by itself authorise work: employers must still comply with all other articles (including workplace WBGT duties in Arts. 4(8)–(9)).',
      arabic:
          '• المادة 1 (تأهيل) — لا ينطبق حظر المادة 2 الموسمي على أماكن العمل المطابقة لتعريف “المظلل والمهوى”. استيفاء التعريف لا يسمح بالعمل وحده: يبقى الالتزام بباقي المواد بما فيها WBGT (4(8)–(9)).',
      hindi:
          '• अनुच्छेद 1 (योग्यता) — Art. 1 छायादार/ventilated परिभाषा पूरी करने पर Art. 2 मौसमी प्रतिबंध नहीं। केवल परिभाषा से अनुमति नहीं — अन्य अनुच्छेद (4(8)–(9) सहित) लागू।',
      urdu:
          '• آرٹیکل 1 (قابلیت) — Art. 1 سایہ دار/ہوادار تعریف پر Art. 2 موسمی پابندی نہیں۔ صرف تعریف سے اجازت نہیں — دیگر دفعات بشمول 4(8)–(9)۔',
      bengali:
          '• অনুচ্ছেদ 1 (যোগ্যতা) — Art. 1 ছায়াযুক্ত/বাতাসযুক্ত সংজ্ঞা মেটালে Art. 2 মৌসুমি নিষেধ প্রযোজ্য নয়। সংজ্ঞা মাত্র কাজের অনুমতি নয় — অন্যান্য অনুচ্ছেদ (4(8)–(9) সহ) বাধ্য।',
      tamil:
          '• பிரிவு 1 (qualification) — Art. 1 வரையறை பூர்த்தியானால் Art. 2 பருவகால தடை இல்லை. வரையறை மட்டும் அனுமதி அல்ல — 4(8)–(9) உள்ளிட்ட மற்ற பிரிவுகள் பொருந்தும்.',
      malayalam:
          '• Art. 1 qualification — seasonal Art. 2 ban not for shaded+ventilated per Art. 1; definition alone is not work permission; Arts 4(8)-(9) still apply.',
      nepali:
          '• धारा 1 (योग्यता) — Art. 1 परिभाषा पूरा भए Art. 2 मौसमी प्रतिबन्ध लागू हुँदैन। परिभाषा मात्र अनुमति होइन — 4(8)–(9) सहित अन्य धाराहरू।',
      filipino:
          '• Art. 1 qualification — hindi seasonal Art. 2 kung shaded+ventilated per Art. 1; hindi permission lang; kailangan pa rin 4(8)–(9) at iba pa.',
    ),
    'rights_bullet_art4_3_water': l10nEntry(
      english:
          '• Art. 4(3) — Employers must provide free, suitably cool drinking water throughout working time.',
      arabic: '• المادة 4(3) — توفير مياه شرب باردة مجانية طوال وقت العمل.',
      hindi: '• अनुच्छेद 4(3) — नियोक्ता मुफ़्त ठंडा पानी पूरे काम के समय दें।',
      urdu: '• آرٹیکل 4(3) — آجر مفت ٹھنڈا پانی پورے کام کے دوران۔',
      bengali: '• অনুচ্ছেদ 4(3) — নিয়োগকর্তা বিনামূল্যে ঠান্ডা পানি পুরো কাজের সময়।',
      tamil: '• பிரிவு 4(3) — இலவச குளிர்ந்த குடிநீர் வேலை நேரம் முழுவதும்.',
      malayalam: '• Art. 4(3) — free cool drinking water throughout working time.',
      nepali: '• धारा 4(3) — रोजगारदाताले निःशुल्क चिसो पानी कामको समयभरि।',
      filipino: '• Art. 4(3) — libreng malamig na inumin sa buong oras ng trabaho.',
    ),
    'rights_bullet_art4_4_shade_rest': l10nEntry(
      english:
          '• Art. 4(4) — Employers must provide shaded rest areas that are easily accessible and effective during breaks.',
      arabic: '• المادة 4(4) — مناطق راحة مظللة سهلة الوصول وفعالة أثناء الاستراحة.',
      hindi: '• अनुच्छेद 4(4) — सुलभ, प्रभावी छायादार विश्राम क्षेत्र।',
      urdu: '• آرٹیکل 4(4) — قابل رسائی سایہ دار آرام کی جگہیں۔',
      bengali: '• অনুচ্ছেদ 4(4) — সহজপ্রাপ্য ছায়াযুক্ত বিশ্রাম এলাকা।',
      tamil: '• பிரிவு 4(4) — அணுகக்கூடிய நிழல் ஓய்வுப் பகுதிகள்.',
      malayalam: '• Art. 4(4) — accessible shaded rest areas.',
      nepali: '• धारा 4(4) — सजिलै पहुँचयोग्य छायादार विश्राम क्षेत्र।',
      filipino: '• Art. 4(4) — accessible na may lilim na pahingahan.',
    ),
    'rights_bullet_art4_8_wbgt_adoption': l10nEntry(
      english:
          '• Art. 4(8) — Employers must adopt the WBGT index to assess occupational heat stress at the workplace (including weather parameters).',
      arabic: '• المادة 4(8) — اعتماد مؤشر WBGT لتقييم الإجهاد الحراري في مكان العمل.',
      hindi: '• अनुच्छेद 4(8) — कार्यस्थल पर WBGT अपनाना और आकलन।',
      urdu: '• آرٹیکل 4(8) — کام کی جگہ WBGT اپنائیں اور تشخیص کریں۔',
      bengali: '• অনুচ্ছেদ 4(8) — কর্মক্ষেত্রে WBGT গ্রহণ ও মূল্যায়ন।',
      tamil: '• பிரிவு 4(8) — பணியிடத்தில் WBGT குறியீட்டை ஏற்று மதிப்பீடு.',
      malayalam: '• Art. 4(8) — adopt WBGT at workplace.',
      nepali: '• धारा 4(8) — कार्यस्थलमा WBGT अपनाउने र मूल्याङ्कन।',
      filipino: '• Art. 4(8) — gamitin ang WBGT sa workplace.',
    ),
    'rights_bullet_art4_9_wbgt_stop': l10nEntry(
      english:
          '• Art. 4(9) — Employers must monitor workplace conditions and stop work where workplace WBGT rises beyond {threshold}°C.',
      arabic: '• المادة 4(9) — إيقاف العمل عندما يتجاوز WBGT في مكان العمل {threshold}°م.',
      hindi: '• अनुच्छेद 4(9) — कार्यस्थल WBGT {threshold}°C से अधिक होने पर काम रोकें।',
      urdu: '• آرٹیکل 4(9) — کام کی جگہ WBGT {threshold}°C سے بڑھنے پر کام بند۔',
      bengali: '• অনুচ্ছেদ 4(9) — কর্মক্ষেত্রে WBGT {threshold}°C ছাড়িয়ে গেলে কাজ বন্ধ।',
      tamil: '• பிரிவு 4(9) — பணியிட WBGT {threshold}°C மீறும்போது வேலை நிறுத்தம்.',
      malayalam: '• Art. 4(9) — stop work when workplace WBGT beyond {threshold}°C.',
      nepali: '• धारा 4(9) — कार्यस्थल WBGT {threshold}°C भन्दा बढ्यो भने काम रोक्नुहोस्।',
      filipino: '• Art. 4(9) — itigil ang trabaho kapag workplace WBGT lampas {threshold}°C.',
    ),
    'rights_bullet_art6_stop_complaint_supervisor': l10nEntry(
      english:
          '• Art. 6 — Workers may stop working and submit a complaint to the Ministry when they have good reason to believe heat stress threatens their health or safety; they should inform their supervisor.',
      arabic: '• المادة 6 — للعمال التوقف وتقديم شكوى للوزارة عند اعتقاد معقول بتهديد الصحة أو السلامة؛ إبلاغ المشرف.',
      hindi: '• अनुच्छेद 6 — अच्छे कारण से रोक सकते हैं, मंत्रालय में शिकायत; पर्यवेक्षक को सूचित करें।',
      urdu: '• آرٹیکل 6 — معقول وجہ پر کام روکیں، وزارت کو شکایت؛ نگراں کو بتائیں۔',
      bengali: '• অনুচ্ছেদ 6 — যুক্তিযুক্ত কারণে থামুন, মন্ত্রণালয়ে অভিযোগ; সুপারভাইজারকে জানান।',
      tamil: '• பிரிவு 6 — நலன்/பாதுகாப்பு அச்சுறுத்தல் என நம்பினால் நிறுத்தி அமைச்சகத்தில் புகார்; மேற்பார்வையாளருக்கு தெரிவிக்கவும்.',
      malayalam: '• Art. 6 — stop, Ministry complaint with good reason; inform supervisor.',
      nepali: '• धारा 6 — राम्रो कारणमा रोक्नुहोस्, मन्त्रालयमा उजुरी; पर्यवेक्षकलाई भन्नुहोस्।',
      filipino: '• Art. 6 — huminto at magreklamo sa Ministry kung may good reason; ipaalam sa supervisor.',
    ),
    'rights_bullet_art6_protection': l10nEntry(
      english:
          '• Art. 6 — Workers must not be dismissed, discriminated against, or deprived of rights for exercising this stop/complaint right.',
      arabic: '• المادة 6 — لا يجوز الفصل أو التمييز أو حرمان الحقوق بسبب التوقف أو الشكوى.',
      hindi: '• अनुच्छेद 6 — इस अधिकार के लिए बर्खास्त/भेदभाव/अधिकार छीनना निषिद्ध।',
      urdu: '• آرٹیکل 6 — اس حق کے بدلے برطرفی/امتیاز/حقوق سے محرومی ممنوع۔',
      bengali: '• অনুচ্ছেদ 6 — এই অধিকারের জন্য বরখাস্ত/বৈষম্য/অধিকার কেড়ে নেওয়া নিষিদ্ধ।',
      tamil: '• பிரிவு 6 — இந்த உரிமைக்காக பணி நீக்கம்/பாகுபாடு/உரிமை மறுப்பு தடை.',
      malayalam: '• Art. 6 — no dismissal/discrimination/deprivation for stop/complaint.',
      nepali: '• धारा 6 — यो अधिकार प्रयोगमा बर्खास्त/भेदभाव/अधिकार छुट मनाही।',
      filipino: '• Art. 6 — bawal ang dismiss/discriminate/deprive rights dahil sa stop/complaint.',
    ),
    'rights_bullet_art7_penalties': l10nEntry(
      english:
          '• Art. 7 — The workplace may be shut down, in part or in whole, for violations.',
      arabic: '• المادة 7 — قد يُغلق موقع العمل جزئياً أو كلياً عند المخالفة.',
      hindi: '• अनुच्छेद 7 — उल्लंघन पर कार्यस्थल आंशिक/पूर्ण बंद।',
      urdu: '• آرٹیکل 7 — خلاف ورزی پر جگہ جزوی یا مکمل بند۔',
      bengali: '• অনুচ্ছেদ 7 — লঙ্ঘনে কর্মক্ষেত্র আংশিক/সম্পূর্ণ বন্ধ হতে পারে।',
      tamil: '• பிரிவு 7 — மீறல்களில் பணியிடம் முழுமையாக/பகுதியாக மூடலாம்.',
      malayalam: '• Art. 7 — workplace may be shut down for violations.',
      nepali: '• धारा 7 — उल्लङ्घनमा कार्यस्थल आंशिक वा पूर्ण बन्द।',
      filipino: '• Art. 7 — maaaring isara ang workplace kung may violation.',
    ),
    'rights_source_cite': l10nEntry(
      english:
          'Source: {decision}, {ministry}. Seasonal window: {season}, {window} Qatar time. Workplace WBGT stop: beyond {threshold}°C (Art. 4(9)).',
      arabic:
          'المصدر: {decision}، {ministry}. الموسم: {season}، {window} توقيت قطر. إيقاف WBGT: فوق {threshold}°م (المادة 4(9)).',
      hindi:
          'स्रोत: {decision}, {ministry}. {season}, {window}। WBGT रोक {threshold}°C से अधिक (4(9)).',
      urdu:
          'ماخذ: {decision}، {ministry}۔ {season}، {window}۔ WBGT روک {threshold}°C سے اوپر (4(9)).',
      bengali:
          'উৎস: {decision}, {ministry}. {season}, {window}. WBGT স্টপ {threshold}°C-এর উপরে (4(9)).',
      tamil:
          'மூலம்: {decision}, {ministry}. {season}, {window}. WBGT நிறுத்தம் {threshold}°C க்கு மேல் (4(9)).',
      malayalam:
          'Source: {decision}, {ministry}. {season}, {window}. WBGT stop beyond {threshold}°C (Art 4(9)).',
      nepali:
          'स्रोत: {decision}, {ministry}. {season}, {window}. WBGT stop {threshold}°C भन्दा माथि (4(9)).',
      filipino:
          'Source: {decision}, {ministry}. {season}, {window}. WBGT stop beyond {threshold}°C (Art. 4(9)).',
    ),
    'rights_al_meezan_verify_note': l10nEntry(
      english:
          'Verify the Arabic legal text on the official Qatari legal portal (Al Meezan) before relying on this summary.',
      arabic: 'تحقق من النص العربي الرسمي على بوابة الميزان القانونية قبل الاعتماد على هذا الملخص.',
      hindi: 'इस सारांश पर भरोसा करने से पहले Al Meezan पर अरबी पाठ सत्यापित करें।',
      urdu: 'اس خلاصے پر بھروسہ سے پہلے المیزان پر عربی متن کی تصدیق کریں۔',
      bengali: 'এই সারাংশের উপর নির্ভর করার আগে Al Meezan-এ আরবি পাঠ যাচাই করুন।',
      tamil: 'இந்த சுருக்கத்தை நம்புவதற்கு முன் Al Meezan-ல் அரபு உரையை சரிபார்க்கவும்.',
      malayalam: 'Verify Arabic legal text on Al Meezan before relying on this summary.',
      nepali: 'यो सारांशमा भर पर्नुअघि Al Meezan मा अरबी पाठ प्रमाणित गर्नुहोस्।',
      filipino: 'I-verify ang Arabic legal text sa Al Meezan bago umasa sa summary na ito.',
    ),
    'heat_reminder_title': l10nEntry(
      english: 'Heat is high',
      arabic: 'الحرارة مرتفعة',
      hindi: 'गर्मी अधिक है',
      urdu: 'گرمی زیادہ ہے',
      malayalam: 'ചൂട് അധികമാണ്',
      nepali: 'तातो धेरै छ',
      bengali: 'তাপ বেশি',
      tamil: 'வெப்பம் அதிகம்',
      filipino: 'Mataas ang init',
    ),
    'heat_reminder_body': l10nEntry(
      english: 'Take a water break in the shade.',
      arabic: 'خذ استراحة للماء في الظل.',
      hindi: 'छाया में पानी पीने का ब्रेक लें।',
      urdu: 'سائے میں پانی کا وقفہ لیں۔',
      malayalam: 'നിഴലിൽ വെള്ളം കുടിക്കാൻ ഇടവേള എടുക്കുക.',
      nepali: 'छहिरमा पानी पिउन विश्राम लिनुहोस्।',
      bengali: 'ছায়ায় পানি পানের বিরতি নিন।',
      tamil: 'நிழலில் தண்ணீர் குடிக்க இடைவெளி எடுங்கள்.',
      filipino: 'Magpahinga at uminom ng tubig sa lilim.',
    ),
    'heat_reminder_body_restricted': l10nEntry(
      english:
          'Heat is high during restricted outdoor hours — take a water break.',
      arabic:
          'الحرارة مرتفعة في ساعات العمل المقيدة — خذ استراحة للماء.',
      hindi:
          'प्रतिबंधित बाहरी घंटों में गर्मी अधिक — पानी का ब्रेक लें।',
      urdu:
          'محدود بیرونی اوقات میں گرمی زیادہ — پانی کا وقفہ لیں۔',
      malayalam:
          'നിയന്ത്രിത ഔട്ട്ഡോർ സമയത്ത് ചൂട് കൂടുതലാണ് — വെള്ളം കുടിക്കുക.',
      nepali:
          'प्रतिबन्धित बाहिरी समयमा तातो बढी छ — पानी पिउनुहोस्।',
      bengali:
          'সীমাবদ্ধ বাইরের সময়ে তাপ বেশি — পানি পানের বিরতি নিন।',
      tamil:
          'வரம்பிடப்பட்ட வெளிப்புற நேரத்தில் வெப்பம் அதிகம் — தண்ணீர் இடைவெளி எடுங்கள்.',
      filipino:
          'Mataas ang init sa mga oras ng limitadong outdoor — uminom ng tubig.',
    ),
    'heat_reminder_before_shift_title': l10nEntry(
      english: 'Before your shift',
      arabic: 'قبل نوبتك',
      hindi: 'शिफ्ट से पहले',
      urdu: 'شفٹ سے پہلے',
      malayalam: 'ഷിഫ്റ്റിന് മുമ്പ്',
      nepali: 'पालो सुरु हुनु अघि',
      bengali: 'শিফটের আগে',
      tamil: 'ஷிப்டுக்கு முன்',
      filipino: 'Bago ang iyong shift',
    ),
    'heat_reminder_before_shift_body': l10nEntry(
      english: 'Start tomorrow\'s shift with water.',
      arabic: 'ابدأ نوبة الغد بماء.',
      hindi: 'कल की शिफ्ट पानी के साथ शुरू करें।',
      urdu: 'کل کی شفٹ پانی سے شروع کریں۔',
      malayalam: 'നാളത്തെ ഷിഫ്റ്റ് വെള്ളത്തോടെ തുടങ്ങുക.',
      nepali: 'भोलिको पालो पानीसँग सुरु गर्नुहोस्।',
      bengali: 'আগামী শিফট পানি দিয়ে শুরু করুন।',
      tamil: 'நாளைய ஷிப்டை தண்ணீருடன் தொடங்குங்கள்.',
      filipino: 'Simulan ang shift bukas na may tubig.',
    ),
    'heat_reminder_forecast_basis': l10nEntry(
      english: 'Based on forecast as of {time}',
      arabic: 'استناداً إلى التوقعات اعتباراً من {time}',
      hindi: 'पूर्वानुमान के आधार पर {time} तक',
      urdu: 'پیش گوئی کی بنیاد پر {time} تک',
      malayalam: '{time} വരെയുള്ള പ്രവചനത്തിന്റെ അടിസ്ഥാനത്തിൽ',
      nepali: '{time} सम्मको पूर्वानुमानको आधारमा',
      bengali: 'পূর্বাভাস অনুযায়ী {time} পর্যন্ত',
      tamil: '{time} வரையிலான முன்னறிவிப்பின் அடிப்படையில்',
      filipino: 'Batay sa forecast noong {time}',
    ),
    'heat_reminder_active_start': l10nEntry(
      english: 'Active from',
      arabic: 'نشط من',
      hindi: 'सक्रिय समय शुरू',
      urdu: 'فعال وقفہ شروع',
      malayalam: 'സജീവം ആരംഭം',
      nepali: 'सक्रिय समय सुरु',
      bengali: 'সক্রিয় সময় শুরু',
      tamil: 'செயலில் இருந்து',
      filipino: 'Aktibo mula',
    ),
    'heat_reminder_active_end': l10nEntry(
      english: 'Active until',
      arabic: 'نشط حتى',
      hindi: 'सक्रिय समय समाप्त',
      urdu: 'فعال وقفہ ختم',
      malayalam: 'സജീവം വരെ',
      nepali: 'सक्रिय समय सम्म',
      bengali: 'সক্রিয় সময় শেষ',
      tamil: 'செயலில் வரை',
      filipino: 'Aktibo hanggang',
    ),
    'heat_reminder_quiet_start': l10nEntry(
      english: 'Quiet from',
      arabic: 'هدوء من',
      hindi: 'शांत अवधि शुरू',
      urdu: 'خاموش اوقات شروع',
      malayalam: 'മൗനം ആരംഭം',
      nepali: 'शान्त अवधि सुरु',
      bengali: 'নিঃশব্দ সময় শুরু',
      tamil: 'அமைதி நேரம் தொடக்கம்',
      filipino: 'Tahimik mula',
    ),
    'heat_reminder_quiet_end': l10nEntry(
      english: 'Quiet until',
      arabic: 'هدوء حتى',
      hindi: 'शांत अवधि समाप्त',
      urdu: 'خاموش اوقات ختم',
      malayalam: 'മൗനം വരെ',
      nepali: 'शान्त अवधि सम्म',
      bengali: 'নিঃশব্দ সময় শেষ',
      tamil: 'அமைதி நேரம் முடிவு',
      filipino: 'Tahimik hanggang',
    ),
    'heat_reminder_before_shift_label': l10nEntry(
      english: 'Remind me before my shift',
      arabic: 'ذكّرني قبل نوبتي',
      hindi: 'शिफ्ट से पहले याद दिलाएँ',
      urdu: 'شفٹ سے پہلے یاد دلائیں',
      malayalam: 'ഷിഫ്റ്റിന് മുമ്പ് ഓർമ്മിപ്പിക്കുക',
      nepali: 'पालो अघि सम्झाउनुहोस्',
      bengali: 'শিফটের আগে মনে করিয়ে দিন',
      tamil: 'ஷிப்டுக்கு முன் நினைவூட்டு',
      filipino: 'Paalalahanan ako bago ang shift',
    ),
    'heat_reminder_permission_denied': l10nEntry(
      english:
          'Notifications are off. Turn them on in system settings to use heat reminders.',
      arabic:
          'الإشعارات متوقفة. فعّلها في إعدادات النظام لاستخدام تذكيرات الحر.',
      hindi:
          'सूचनाएँ बंद हैं। हीट रिमाइंडर के लिए सिस्टम सेटिंग में चालू करें।',
      urdu:
          'اطلاعات بند ہیں۔ گرمی یاددہانیوں کے لیے سسٹم ترتیبات میں چالو کریں۔',
      malayalam:
          'അറിയിപ്പുകൾ ഓഫാണ്. ഹീറ്റ് റിമൈന്ററുകൾക്ക് സിസ്റ്റം ക്രമീകരണത്തിൽ ഓണാക്കുക.',
      nepali:
          'सूचनाहरू बन्द छन्। तातो सम्झना को लागि प्रणाली सेटिङमा अन गर्नुहोस्।',
      bengali:
          'নোটিফিকেশন বন্ধ। তাপ সতর্কতার জন্য সিস্টেম সেটিংসে চালু করুন।',
      tamil:
          'அறிவிப்புகள் அணைக்கப்பட்டுள்ளன. வெப்ப நினைவூட்டல்களுக்கு அமைப்புகளில் இயக்குங்கள்.',
      filipino:
          'Naka-off ang notifications. I-on sa system settings para sa heat reminders.',
    ),
    'heat_reminder_open_settings': l10nEntry(
      english: 'Open system settings',
      arabic: 'فتح إعدادات النظام',
      hindi: 'सिस्टम सेटिंग खोलें',
      urdu: 'سسٹم ترتیبات کھولیں',
      malayalam: 'സിസ്റ്റം ക്രമീകരണങ്ങൾ തുറക്കുക',
      nepali: 'प्रणाली सेटिङ खोल्नुहोस्',
      bengali: 'সিস্টেম সেটিংস খুলুন',
      tamil: 'கணினி அமைப்புகளைத் திற',
      filipino: 'Buksan ang mga setting ng system',
    ),
    'hydration_reminder_title': l10nEntry(
      english: 'Hydration break',
      arabic: 'استراحة للترطيب',
      hindi: 'हाइड्रेशन ब्रेक',
      urdu: 'ہائیڈریشن بریک',
      malayalam: 'ജലാംശ വിശ്രാമം',
      nepali: 'पानी पिउने विश्राम',
      bengali: 'হাইড্রেশন বিরতি',
      tamil: 'நீர்ச்சத்து இடைவெளி',
      filipino: 'Pahinga at hydration',
    ),
    'hydration_reminder_body': l10nEntry(
      english: 'Take a rest and drink water in the shade.',
      arabic: 'استرح واشرب ماء في الظل.',
      hindi: 'छाया में आराम करें और पानी पिएँ।',
      urdu: 'سaye میں آرام کریں اور پانی پئیں۔',
      malayalam: 'നിഴലിൽ വിശ്രമിച്ച് വെള്ളം കുടിക്കുക.',
      nepali: 'छहिरमा आराम गरी पानी पिउनुहोस्।',
      bengali: 'ছায়ায় বিশ্রাম নিন এবং পানি পান করুন।',
      tamil: 'நிழலில் ஓய்வெடுத்து தண்ணீர் குடியுங்கள்.',
      filipino: 'Magpahinga at uminom ng tubig sa lilim.',
    ),
    'hydration_reminder_toggle_label': l10nEntry(
      english: 'Heat hydration reminders',
      arabic: 'تذكيرات الماء عند ارتفاع الحرارة',
      hindi: 'गर्मी पर पानी की यादें',
      urdu: 'گرمی پر پانی کی یاددہانیاں',
      malayalam: 'ചൂടിലെ ജലാംശ ഓർമ്മപ്പെടുത്തലുകൾ',
      nepali: 'तातोमा पानी सम्झना',
      bengali: 'তাপে পানি পানের অনুস্মারক',
      tamil: 'வெப்ப நேர தண்ணீர் நினைவூட்டல்கள்',
      filipino: 'Mga paalala sa tubig kapag mainit',
    ),
    'hydration_reminder_toggle_subtitle': l10nEntry(
      english:
          'Opt-in local alerts from your heat level during your active hours. Default off.',
      arabic:
          'تنبيهات محلية اختيارية وفق مستوى الحرارة خلال ساعات نشاطك. متوقف افتراضياً.',
      hindi:
          'सक्रिय घंटों में गर्मी स्तर पर स्थानीय अलर्ट (ऑप्ट-इन). डिफ़ॉल्ट बंद।',
      urdu:
          'فعال اوقات میں گرمی کی سطح پر مقامی الرٹ (آپشن)۔ پہلے سے بند۔',
      malayalam:
          'സജീവ സമയത്ത് ചൂടിന്റെ അടിസ്ഥാനത്തിൽ പ്രാദേശിക അലേർട്ടുകൾ. സ്ഥിരസ്ഥിതി ഓഫ്.',
      nepali:
          'सक्रिय समयमा ताप स्तर अनुसार स्थानीय अलर्ट (वैकल्पिक)। पूर्वनिर्धारित बन्द।',
      bengali:
          'সক্রিয় সময়ে তাপমাত্রা অনুযায়ী স্থানীয় সতর্কতা (অপ্ট-ইন)। ডিফল্ট বন্ধ।',
      tamil:
          'செயலில் உள்ள நேரத்தில் வெப்ப அளவுக்கு ஏற்ப உள்ளூர் எச்சரிக்கை (தேர்வு). இயல்பாக அணை.',
      filipino:
          'Opt-in na lokal na alert batay sa init sa active hours mo. Naka-off bilang default.',
    ),
    'guide_source_citation': l10nEntry(
      english:
          'Symptom and first-aid guidance adapted from CDC (Heat Stress) and WHO (Health effects of hot weather) — informational only; call 999 for emergencies.',
      arabic:
          'إرشادات الأعراض والإسعافات الأولية م adapted من CDC (Heat Stress) وWHO — للمعلومات فقط؛ اتصل 999 للطوارئ.',
      hindi:
          'लक्षण/प्राथमिक चिकित्सा CDC (Heat Stress) और WHO से — केवल जानकारी; आपात में 999।',
      urdu:
          'علامات/فرسٹ ایڈ CDC (Heat Stress) اور WHO سے — صرف معلومات؛ ایمرجنسی میں 999۔',
      bengali:
          'লক্ষণ/প্রাথমিক চিকিৎসা CDC (Heat Stress) ও WHO থেকে — শুধু তথ্য; জরুরিতে 999।',
      tamil:
          'அறிகுறி/முதலுதவி CDC (Heat Stress) மற்றும் WHO-யிலிருந்து — தகவல் மட்டும்; அவசரத்தில் 999.',
      filipino:
          'Symptom/first-aid mula sa CDC (Heat Stress) at WHO — impormasyon lang; tumawag 999 sa emergency.',
    ),
    'banner_wbgt_primary_label': l10nEntry(
      english: 'Estimated WBGT',
      arabic: 'WBGT التقديري',
      hindi: 'अनुमानित WBGT',
      urdu: 'تخمینی WBGT',
      bengali: 'আনুমানিক WBGT',
      tamil: 'மதிப்பிடப்பட்ட WBGT',
      filipino: 'Tantyang WBGT',
    ),
    'banner_air_temp_line': l10nEntry(
      english:
          'Air {temp}°C · feels {feels}°C · {humidity}% RH · wind {wind} m/s',
      arabic:
          'الهواء {temp}°C · يشعر {feels}°C · {humidity}% · رياح {wind} m/s',
      hindi:
          'हवा {temp}°C · महसूस {feels}°C · {humidity}% · हवा {wind} m/s',
      urdu:
          'ہوا {temp}°C · محسوس {feels}°C · {humidity}% · ہوا {wind} m/s',
      bengali:
          'বাতাস {temp}°C · অনুভূত {feels}°C · {humidity}% · বাতাস {wind} m/s',
      tamil:
          'காற்று {temp}°C · உணர்வு {feels}°C · {humidity}% · காற்று {wind} m/s',
      filipino:
          'Air {temp}°C · feels {feels}°C · {humidity}% · hangin {wind} m/s',
    ),
    'banner_heat_index_line': l10nEntry(
      english: 'Heat index {index}°C ({label})',
      arabic: 'مؤشر الحرارة {index}°C ({label})',
      hindi: 'हीट इंडेक्स {index}°C ({label})',
      urdu: 'Heat index {index}°C ({label})',
      bengali: 'হিট ইনডেক্স {index}°C ({label})',
      tamil: 'வெப்பக் குறியீடு {index}°C ({label})',
      filipino: 'Heat index {index}°C ({label})',
    ),
    'uv_badge_label': l10nEntry(
      english: 'UV',
      arabic: 'UV',
      hindi: 'UV',
      urdu: 'UV',
      bengali: 'UV',
      tamil: 'UV',
      filipino: 'UV',
    ),
    'status_hero_semantics': l10nEntry(
      english:
          'Qatar climate status. Air {temp} degrees Celsius. Estimated WBGT {wbgt}, {wbgtLabel}. WBGT guidance: {wbgtAdvice}. Heat index {heatIndex}, {heatLabel}. Outdoor advice: {outdoorAdvice}.',
      arabic:
          'حالة قطر. الهواء {temp}°م. WBGT تقديري {wbgt}، {wbgtLabel}. إرشاد WBGT: {wbgtAdvice}. مؤشر الحرارة {heatIndex}، {heatLabel}. نصائح الهواء الطلق: {outdoorAdvice}.',
      hindi:
          'Qatar स्थिति। वायु {temp}°C। अनुमानित WBGT {wbgt}, {wbgtLabel}। WBGT मार्गदर्शन: {wbgtAdvice}। हीट इंडेक्स {heatIndex}, {heatLabel}। बाहरी सलाह: {outdoorAdvice}।',
      urdu:
          'قطر کی حالت۔ ہوا {temp}°C۔ تخمینی WBGT {wbgt}, {wbgtLabel}۔ WBGT رہنمائی: {wbgtAdvice}۔ ہیٹ انڈیکس {heatIndex}, {heatLabel}۔ بیرونی مشورہ: {outdoorAdvice}۔',
      bengali:
          'কাতার অবস্থা। বাতাস {temp}°C। আনুমানিক WBGT {wbgt}, {wbgtLabel}। WBGT নির্দেশনা: {wbgtAdvice}। হিট ইনডেক্স {heatIndex}, {heatLabel}। বাইরের পরামর্শ: {outdoorAdvice}।',
      tamil:
          'கத்தார் நிலை. காற்று {temp}°C. மதிப்பிடப்பட்ட WBGT {wbgt}, {wbgtLabel}. WBGT வழிகாட்டல்: {wbgtAdvice}. வெப்பக் குறியீடு {heatIndex}, {heatLabel}. வெளி அறிவுரை: {outdoorAdvice}.',
      malayalam:
          'Qatar status. Air {temp}°C. Estimated WBGT {wbgt}, {wbgtLabel}. WBGT: {wbgtAdvice}. Heat index {heatIndex}, {heatLabel}. Outdoor: {outdoorAdvice}.',
      nepali:
          'Qatar status. Air {temp}°C. Estimated WBGT {wbgt}, {wbgtLabel}. WBGT: {wbgtAdvice}. Heat index {heatIndex}, {heatLabel}. Outdoor: {outdoorAdvice}.',
      filipino:
          'Qatar status. Air {temp}°C. Tantyang WBGT {wbgt}, {wbgtLabel}. WBGT guidance: {wbgtAdvice}. Heat index {heatIndex}, {heatLabel}. Outdoor advice: {outdoorAdvice}.',
    ),
    'route_history_chip': l10nEntry(
      english: '{from} to {to}',
      arabic: '{from} إلى {to}',
      hindi: '{from} से {to}',
      urdu: '{from} سے {to}',
      bengali: '{from} থেকে {to}',
      tamil: '{from} to {to}',
      filipino: '{from} to {to}',
    ),
    'route_options_heading': l10nEntry(
      english: 'Route options',
      arabic: 'خيارات المسار',
      hindi: 'Route options',
      urdu: 'Route options',
      bengali: 'Route options',
      tamil: 'Route options',
      filipino: 'Route options',
    ),
    'route_tips_heading': l10nEntry(
      english: 'Heat safety tips',
      arabic: 'نصائح السلامة من الحر',
      hindi: 'Heat safety tips',
      urdu: 'Heat safety tips',
      bengali: 'Heat safety tips',
      tamil: 'Heat safety tips',
      filipino: 'Heat safety tips',
    ),
    'wbgt_band_short_lower': l10nEntry(
      english: 'Lower stress',
      arabic: 'إجهاد أقل',
      hindi: 'कम तनाव',
      urdu: 'کم دباؤ',
      bengali: 'কম চাপ',
      tamil: 'குறைந்த சுமை',
      malayalam: 'Lower stress',
      nepali: 'कम तनाव',
      filipino: 'Mas mababang stress',
    ),
    'wbgt_band_short_moderate': l10nEntry(
      english: 'Moderate stress',
      arabic: 'إجهاد معتدل',
      hindi: 'मध्यम तनाव',
      urdu: 'درمیانی دباؤ',
      bengali: 'মাঝারি চাপ',
      tamil: 'மிதமான சுமை',
      malayalam: 'Moderate stress',
      nepali: 'मध्यम तनाव',
      filipino: 'Katamtamang stress',
    ),
    'wbgt_band_short_high': l10nEntry(
      english: 'High stress',
      arabic: 'إجهاد مرتفع',
      hindi: 'उच्च तनाव',
      urdu: 'زیادہ دباؤ',
      bengali: 'উচ্চ চাপ',
      tamil: 'அதிக சுமை',
      malayalam: 'High stress',
      nepali: 'उच्च तनाव',
      filipino: 'Mataas na stress',
    ),
    'wbgt_band_short_extreme': l10nEntry(
      english: 'Extreme stress',
      arabic: 'إجهاد شديد',
      hindi: 'अत्यधिक तनाव',
      urdu: 'شدید دباؤ',
      bengali: 'চরম চাপ',
      tamil: 'கடுமையான சுமை',
      malayalam: 'Extreme stress',
      nepali: 'अत्यधिक तनाव',
      filipino: 'Matinding stress',
    ),
    'wbgt_band_short_work_stop': l10nEntry(
      english: 'Stop threshold',
      arabic: 'حد الإيقاف',
      hindi: 'रोक सीमा',
      urdu: 'روک کی حد',
      bengali: 'স্টপ সীমা',
      tamil: 'நிறுத்த வரம்பு',
      malayalam: 'Stop threshold',
      nepali: 'रोक सीमा',
      filipino: 'Stop threshold',
    ),
    'wbgt_band_guidance_lower': l10nEntry(
      english: 'Conditions look lower for heat stress — still hydrate and take normal breaks.',
      arabic: 'مستوى إجهاد حراري أقل — استمر بالترطيب وفترات الراحة المعتادة.',
      hindi: 'गर्मी का तनाव कम — पानी पिएँ और सामान्य विश्राम लें।',
      urdu: 'گرمی کا دباؤ کم — پانی پئیں اور عام وقفے لیں۔',
      bengali: 'তাপ চাপ কম — পানি পান করুন ও সাধারণ বিরতি নিন।',
      tamil: 'வெப்ப சுமை குறைவு — நீர் அருந்தி வழக்கமான இடைவெளி எடுங்கள்.',
      malayalam:
          'Heat stress lower — hydrate and take normal breaks.',
      nepali: 'ताप तनाव कम — पानी र सामान्य विश्राम।',
      filipino: 'Mas mababang heat stress — uminom at magpahinga.',
    ),
    'wbgt_band_guidance_moderate': l10nEntry(
      english: 'Moderate estimated stress — shorten outdoor spells and use shade when you can.',
      arabic: 'إجهاد تقديري معتدل — قلّل فترات الهواء الطلق واستخدم الظل.',
      hindi: 'मध्यम अनुमानित तनाव — बाहरी समय घटाएँ, छाया लें।',
      urdu: 'درمیانی تخمینی دباؤ — بیرونی وقت کم کریں، سایہ لیں۔',
      bengali: 'মাঝারি অনুমান — বাইরের সময় কমান, ছায়া নিন।',
      tamil: 'மிதமான மதிப்பீடு — வெளி நேரம் குறைத்து நிழல் தேடுங்கள்.',
      malayalam:
          'Moderate estimate — shorten outdoor time, use shade.',
      nepali: 'मध्यम अनुमान — बाहिरी समय घटाउनुहोस्, छाया लिनुहोस्।',
      filipino: 'Katamtamang estimate — paikliin ang outdoor, humanap ng lilim.',
    ),
    'wbgt_band_guidance_high': l10nEntry(
      english: 'High estimated stress — limit hard outdoor work and drink water often.',
      arabic: 'إجهاد تقديري مرتفع — قلّل العمل الشاق في الهواء واشرب الماء.',
      hindi: 'उच्च अनुमानित तनाव — कठिन बाहरी काम सीमित करें, पानी पिएँ।',
      urdu: 'زیادہ تخمینی دباؤ — سخت بیرونی کام کم کریں، پانی پئیں۔',
      bengali: 'উচ্চ অনুমান — কঠিন বাইরের কাজ সীমিত করুন, পানি পান করুন।',
      tamil: 'அதிக மதிப்பீடு — கடின வெளி வேலை குறைத்து தண்ணீர் அருந்துங்கள்.',
      malayalam: 'High estimate — limit hard outdoor work, hydrate.',
      nepali: 'उच्च अनुमान — कडा बाहिरी काम सीमित, पानी पिउनुहोस्।',
      filipino: 'Mataas na estimate — limitahan ang outdoor, uminom ng tubig.',
    ),
    'wbgt_band_guidance_extreme': l10nEntry(
      english: 'Extreme estimated stress — avoid unnecessary outdoor exertion and cool down.',
      arabic: 'إجهاد تقديري شديد — تجنب مجهوداً غير ضرورياً في الهواء وبرّد نفسك.',
      hindi: 'अत्यधिक अनुमान — अनावश्यक बाहरी मेहनत टालें, ठंडा रहें।',
      urdu: 'شدید تخمینہ — غیر ضروری بیرونی محنت سے بچیں، ٹھنڈا رہیں۔',
      bengali: 'চরম অনুমান — অপ্রয়োজনীয় বাইরের পরিশ্রম এড়ান, ঠান্ডা থাকুন।',
      tamil: 'கடுமையான மதிப்பீடு — தேவையற்ற வெளி உழைப்பைத் தவிர்த்து குளிர்வுங்கள்.',
      malayalam: 'Extreme estimate — avoid needless outdoor exertion.',
      nepali: 'अत्यधिक अनुमान — अनावश्यक बाहिरी श्रम नगर्नुहोस्।',
      filipino: 'Matinding estimate — iwasan ang outdoor kung hindi kailangan.',
    ),
    'wbgt_band_guidance_work_stop': l10nEntry(
      english:
          'Estimate above the 32.1°C reference — pause heavy outdoor exertion, hydrate, and follow your employer heat plan.',
      arabic:
          'التقدير فوق مرجع 32.1°C — أوقفوا مجهوداً شاقاً في الهواء ورطّبوا وأتبعوا خطة جهة العمل.',
      hindi:
          '32.1°C संदर्भ से ऊपर अनुमान — भारी बाहरी मेहनत रोकें, पानी पिएँ, नियोक्ता योजना मानें।',
      urdu:
          '32.1°C حوالے سے اوپر تخمینہ — سخت بیرونی محنت روکیں، پانی پئیں، آجر کا پلان فالو کریں۔',
      bengali:
          '32.1°C রেফারেন্সের উপরে অনুমান — কঠিন বাইরের কাজ থামান, পানি নিন, নিয়োগকর্তার পরিকল্পনা মানুন।',
      tamil:
          '32.1°C குறிப்புக்கு மேல் மதிப்பீடு — கடின வெளி உழைப்பு நிறுத்தி நீர் அருந்துங்கள், மேற்பார்வையாளர் திட்டம் பின்பற்றுங்கள்.',
      malayalam:
          'Estimate above 32.1°C reference — pause heavy outdoor work, hydrate.',
      nepali:
          '32.1°C सन्दर्भभन्दा माथि अनुमान — गाह्रो बाहिरी परिश्रम रोक्नुहोस्।',
      filipino:
          'Estimate above 32.1°C reference — huminto sa mabigat na outdoor, uminom.',
    ),
    'status_wbgt_guidance_label': l10nEntry(
      english: 'Estimated WBGT guidance (weather model — not a workplace WBGT reading)',
      arabic: 'إرشاد WBGT التقديري (نموذج طقس — ليس قياس WBGT في مكان العمل)',
      hindi: 'अनुमानित WBGT मार्गदर्शन (मौसम मॉडल — कार्यस्थल WBGT माप नहीं)',
      urdu: 'تخمینی WBGT رہنمائی (موسم ماڈل — کام کی جگہ WBGT پیمائش نہیں)',
      bengali: 'আনুমানিক WBGT নির্দেশনা (আবহাওয়া মডেল — কর্মক্ষেত্রের WBGT নয়)',
      tamil: 'மதிப்பிடப்பட்ட WBGT வழிகாட்டல் (வானிலை மாதிரி — பணியிட WBGT அளவீடு அல்ல)',
      malayalam:
          'Estimated WBGT guidance (weather model — not workplace WBGT)',
      nepali:
          'अनुमानित WBGT मार्गदर्शन (मौसम मोडेल — कार्यस्थल WBGT होइन)',
      filipino:
          'Tantyang WBGT guidance (weather model — hindi workplace WBGT)',
    ),
    'status_heat_index_outdoor_label': l10nEntry(
      english: 'Heat index — outdoor activity advice',
      arabic: 'مؤشر الحرارة — نصائح النشاط في الهواء الطلق',
      hindi: 'हीट इंडेक्स — बाहरी गतिविधि सलाह',
      urdu: 'ہیٹ انڈیکس — بیرونی سرگرمی مشورہ',
      bengali: 'হিট ইনডেক্স — বাইরের কার্যকলাপ পরামর্শ',
      tamil: 'வெப்பக் குறியீடு — வெளி நடவடிக்கை அறிவுரை',
      malayalam: 'Heat index — outdoor activity advice',
      nepali: 'Heat index — बाहिरी गतिविधि सलाह',
      filipino: 'Heat index — outdoor activity advice',
    ),
    'wbgt_narration_guidance_lower': l10nEntry(
      english: 'Hydrate; take normal breaks.',
      arabic: 'ارتوِ؛ خذ فترات راحة.',
      hindi: 'पानी पिएँ; सामान्य विश्राम।',
      urdu: 'پانی پئیں؛ عام وقفے۔',
      bengali: 'পানি নিন; সাধারণ বিরতি।',
      tamil: 'நீர் அருந்துங்கள்; இடைவெளி எடுங்கள்.',
      malayalam: 'Hydrate; normal breaks.',
      nepali: 'पानी; सामान्य विश्राम।',
      filipino: 'Uminom; magpahinga.',
    ),
    'wbgt_narration_guidance_moderate': l10nEntry(
      english: 'Shorten outdoor time; use shade.',
      arabic: 'قلّل الوقت في الهواء؛ استخدم الظل.',
      hindi: 'बाहरी समय घटाएँ; छाया लें।',
      urdu: 'بیرونی وقت کم؛ سایہ لیں۔',
      bengali: 'বাইরের সময় কমান; ছায়া নিন।',
      tamil: 'வெளி நேரம் குறையுங்கள்; நிழல் தேடுங்கள்.',
      malayalam: 'Shorten outdoor; use shade.',
      nepali: 'बाहिरी समय घटाउनुहोस्; छाया।',
      filipino: 'Paikliin ang outdoor; humanap ng lilim.',
    ),
    'wbgt_narration_guidance_high': l10nEntry(
      english: 'Limit hard outdoor work; drink often.',
      arabic: 'قلّل العمل الشاق في الهواء؛ اشرب كثيراً.',
      hindi: 'कठिन बाहरी काम सीमित करें; पानी पिएँ।',
      urdu: 'سخت بیرونی کام کم؛ پانی پئیں۔',
      bengali: 'কঠিন বাইরের কাজ কমান; পানি নিন।',
      tamil: 'கடின வெளி வேலை குறையுங்கள்; தண்ணீர் அருந்துங்கள்.',
      malayalam: 'Limit hard outdoor; hydrate often.',
      nepali: 'कडा बाहिरी काम सीमित; पानी पिउनुहोस्।',
      filipino: 'Limitahan ang outdoor; uminom.',
    ),
    'wbgt_narration_guidance_extreme': l10nEntry(
      english: 'Avoid needless outdoor exertion; cool down.',
      arabic: 'تجنّب مجهوداً غير ضروري؛ برّد نفسك.',
      hindi: 'अनावश्यक बाहरी मेहनत टालें; ठंडा रहें।',
      urdu: 'غیر ضروری محنت سے بچیں؛ ٹھنڈا رہیں۔',
      bengali: 'অপ্রয়োজনীয় পরিশ্রম এড়ান; ঠান্ডা থাকুন।',
      tamil: 'தேவையற்ற வெளி உழைப்பைத் தவிர்க்கவும்; குளிர்வுங்கள்.',
      malayalam: 'Avoid needless outdoor exertion.',
      nepali: 'अनावश्यक बाहिरी श्रम नगर्नुहोस्।',
      filipino: 'Iwasan ang outdoor kung hindi kailangan.',
    ),
    'wbgt_narration_guidance_work_stop': l10nEntry(
      english: 'Pause heavy outdoor work.',
      arabic: 'أوقف العمل الشاق.',
      hindi: 'भारी बाहरी काम रोकें।',
      urdu: 'سخت بیرونی کام روکیں۔',
      bengali: 'কঠিন বাইরের কাজ থামান।',
      tamil: 'கடின வெளி வேலை நிறுத்து.',
      malayalam: 'Pause heavy outdoor work.',
      nepali: 'गाह्रो बाहिरी काम रोक्नुहोस्।',
      filipino: 'Itigil ang mabigat na outdoor.',
    ),
    'status_actions_speak': l10nEntry(
      english: 'Listen to status',
      arabic: 'استمع للحالة',
      hindi: 'स्थिति सुनें',
      urdu: 'سٹیٹس سنیں',
      bengali: 'অবস্থা শুনুন',
      tamil: 'நிலையைக் கேளுங்கள்',
      malayalam: 'Listen to status',
      nepali: 'स्थिति सुन्नुहोस्',
      filipino: 'Pakinggan ang status',
    ),
    'status_actions_stop': l10nEntry(
      english: 'Stop audio',
      arabic: 'إيقاف الصوت',
      hindi: 'ऑडियो रोकें',
      urdu: 'آڈیو بند',
      bengali: 'অডিও বন্ধ',
      tamil: 'ஆடியோ நிறுத்து',
      malayalam: 'Stop audio',
      nepali: 'अडियो रोक्नुहोस्',
      filipino: 'Itigil ang audio',
    ),
    'status_actions_share': l10nEntry(
      english: 'Share status',
      arabic: 'مشاركة الحالة',
      hindi: 'स्थिति साझा करें',
      urdu: 'سٹیٹس شیئر',
      bengali: 'অবস্থা শেয়ার',
      tamil: 'நிலையைப் பகிர்',
      malayalam: 'Share status',
      nepali: 'स्थिति शेयर',
      filipino: 'Ibahagi ang status',
    ),
    'status_narration_intro': l10nEntry(
      english: 'WBGT {wbgt}. {band}.',
      arabic: 'WBGT {wbgt}. {band}.',
      hindi: 'WBGT {wbgt}. {band}.',
      urdu: 'WBGT {wbgt}. {band}.',
      bengali: 'WBGT {wbgt}. {band}.',
      tamil: 'WBGT {wbgt}. {band}.',
      malayalam: 'WBGT {wbgt}. {band}.',
      nepali: 'WBGT {wbgt}. {band}.',
      filipino: 'WBGT {wbgt}. {band}.',
    ),
    'status_audio_clock_ban_short': l10nEntry(
      english: 'Ban {window} Qatar.',
      arabic: 'حظر {window} قطر.',
      hindi: 'प्रतिबंध {window} कतर।',
      urdu: 'پابندی {window} قطر۔',
      bengali: 'নিষেধ {window} কাতার।',
      tamil: 'தடை {window} Qatar.',
      malayalam: 'Ban {window} Qatar.',
      nepali: 'प्रतिबन्ध {window} कतार।',
      filipino: 'Ban {window} Qatar.',
    ),
    'status_narration_snapshot_line': l10nEntry(
      english: 'Weather data: {basis}',
      arabic: 'بيانات الطقس: {basis}',
      hindi: 'मौसम डेटा: {basis}',
      urdu: 'موسم ڈیٹا: {basis}',
      bengali: 'আবহাওয়ার তথ্য: {basis}',
      tamil: 'வானிலை தரவு: {basis}',
      malayalam: 'Weather data: {basis}',
      nepali: 'मौसम डाटा: {basis}',
      filipino: 'Weather data: {basis}',
    ),
    'status_weather_snapshot_fresh': l10nEntry(
      english: 'Data {time}.',
      arabic: 'بيانات {time}.',
      hindi: 'डेटा {time}.',
      urdu: 'ڈیٹا {time}.',
      bengali: 'ডেটা {time}.',
      tamil: 'தரவு {time}.',
      malayalam: 'Data {time}.',
      nepali: 'डाटा {time}.',
      filipino: 'Data {time}.',
    ),
    'status_weather_snapshot_stale': l10nEntry(
      english: 'Stale {time}.',
      arabic: 'قديم {time}.',
      hindi: 'पुराना {time}.',
      urdu: 'پرانا {time}.',
      bengali: 'পুরোনো {time}.',
      tamil: 'பழைய {time}.',
      malayalam: 'Stale {time}.',
      nepali: 'पुरानो {time}.',
      filipino: 'Luma {time}.',
    ),
    'status_audio_clock_ban_active': l10nEntry(
      english:
          'Seasonal outdoor work restrictions may apply now, {window} Qatar time.',
      arabic:
          'قد تُطبَّق قيود العمل في الهواء الطلق الآن، {window} بتوقيت قطر.',
      hindi:
          'मौसमी बाहरी कार्य प्रतिबंध अब लागू हो सकते हैं, {window} कतर समय।',
      urdu:
          'موسمی بیرونی کام کی پابندیاں اب لاگو ہو سکتی ہیں، {window} قطر وقت۔',
      bengali:
          'মৌসুমি বাইরের কাজের সীমা এখন প্রযোজ্য হতে পারে, {window} কাতার সময়।',
      tamil:
          'பருவகால வெளி வேலைக் கட்டுப்பாடுகள் இப்போது பொருந்தலாம், {window} Qatar நேரம்.',
      malayalam:
          'Seasonal outdoor restrictions may apply, {window} Qatar time.',
      nepali:
          'मौसमी बाहिरी काम प्रतिबन्ध लागू हुन सक्छ, {window} कतार समय।',
      filipino:
          'Maaaring may seasonal outdoor restrictions ngayon, {window} Qatar time.',
    ),
    'status_share_header': l10nEntry(
      english: 'Raabta Heat Safety — Qatar (weather estimate)',
      arabic: 'Raabta السلامة من الحر — قطر (تقدير الطقس)',
      hindi: 'Raabta Heat Safety — Qatar (weather estimate)',
      urdu: 'Raabta Heat Safety — Qatar (weather estimate)',
      bengali: 'Raabta Heat Safety — Qatar (weather estimate)',
      tamil: 'Raabta Heat Safety — Qatar (weather estimate)',
      malayalam: 'Raabta Heat Safety — Qatar (weather estimate)',
      nepali: 'Raabta Heat Safety — Qatar (weather estimate)',
      filipino: 'Raabta Heat Safety — Qatar (weather estimate)',
    ),
    'status_share_band_line': l10nEntry(
      english: 'Estimated WBGT: {wbgt}°C — {band}',
      arabic: 'WBGT التقديري: {wbgt}°م — {band}',
      hindi: 'अनुमानित WBGT: {wbgt}°C — {band}',
      urdu: 'تخمینی WBGT: {wbgt}°C — {band}',
      bengali: 'আনুমানিক WBGT: {wbgt}°C — {band}',
      tamil: 'மதிப்பிடப்பட்ட WBGT: {wbgt}°C — {band}',
      malayalam: 'Estimated WBGT: {wbgt}°C — {band}',
      nepali: 'अनुमानित WBGT: {wbgt}°C — {band}',
      filipino: 'Tantyang WBGT: {wbgt}°C — {band}',
    ),
    'status_share_snapshot_line': l10nEntry(
      english: 'Weather snapshot: {basis}',
      arabic: 'لقطة الطقس: {basis}',
      hindi: 'मौसम स्नैपशॉट: {basis}',
      urdu: 'موسم سنپ شاٹ: {basis}',
      bengali: 'আবহাওয়ার স্ন্যাপশট: {basis}',
      tamil: 'வானிலை பதிவு: {basis}',
      malayalam: 'Weather snapshot: {basis}',
      nepali: 'मौसम स्न्यापशट: {basis}',
      filipino: 'Weather snapshot: {basis}',
    ),
    'status_share_wbgt_context_note': l10nEntry(
      english: 'WBGT band guidance below is from a weather estimate, not an on-site workplace instrument.',
      arabic: 'إرشاد النطاق أدناه من تقدير الطقس وليس جهازاً في موقع العمل.',
      hindi: 'नीचे WBGT मार्गदर्शन मौसम अनुमान से है, कार्यस्थल यंत्र नहीं।',
      urdu: 'نیچے WBGT رہنمائی موسم کے تخمینے سے ہے، جگہ کا آلہ نہیں۔',
      bengali: 'নিচের WBGT নির্দেশনা আবহাওয়ার অনুমান, কর্মক্ষেত্রের যন্ত্র নয়।',
      tamil: 'கீழே WBGT வழிகாட்டல் வானிலை மதிப்பீடு — பணியிட கருவி அல்ல.',
      malayalam:
          'WBGT guidance is a weather estimate, not on-site workplace instrument.',
      nepali:
          'WBGT guidance weather estimate ho, workplace instrument hoina.',
      filipino:
          'WBGT guidance from weather estimate, not on-site workplace instrument.',
    ),
    'status_share_heat_index_outdoor_heading': l10nEntry(
      english: 'Heat index outdoor advice',
      arabic: 'نصائح الهواء الطلق لمؤشر الحرارة',
      hindi: 'हीट इंडेक्स बाहरी सलाह',
      urdu: 'ہیٹ انڈیکس بیرونی مشورہ',
      bengali: 'হিট ইনডেক্স বাইরের পরামর্শ',
      tamil: 'வெப்பக் குறியீடு வெளி அறிவுரை',
      malayalam: 'Heat index outdoor advice',
      nepali: 'Heat index outdoor advice',
      filipino: 'Heat index outdoor advice',
    ),
    'status_share_stale_snapshot_note': l10nEntry(
      english: 'Weather snapshot may be cached, offline, or estimated.',
      arabic: 'قد تكون لقطة الطقس مخزنة أو غير متصلة أو تقديرية.',
      hindi: 'मौसम स्नैपशॉट कैश/ऑफ़लाइन/अनुमानित हो सकता है।',
      urdu: 'موسم سنپ شاٹ کیش/آف لائن/تخمینی ہو سکتا ہے۔',
      bengali: 'আবহাওয়ার স্ন্যাপশট ক্যাশ/অফলাইন/আনুমানিক হতে পারে।',
      tamil: 'வானிலை பதிவு கேச்/ஆஃப்லைன்/மதிப்பீடாக இருக்கலாம்.',
      malayalam: 'Weather snapshot may be cached, offline, or estimated.',
      nepali: 'मौसम स्न्यापशट क्यास/अफलाइन/अनुमानित हुन सक्छ।',
      filipino: 'Maaaring cached, offline, o estimate ang weather snapshot.',
    ),
    'status_share_forecast_line': l10nEntry(
      english: 'Weather snapshot: {basis}',
      arabic: 'لقطة الطقس: {basis}',
      hindi: 'मौसम स्नैपशॉट: {basis}',
      urdu: 'موسم سنپ شاٹ: {basis}',
      bengali: 'আবহাওয়ার স্ন্যাপশট: {basis}',
      tamil: 'வானிலை பதிவு: {basis}',
      malayalam: 'Weather snapshot: {basis}',
      nepali: 'मौसम स्न्यापशट: {basis}',
      filipino: 'Weather snapshot: {basis}',
    ),
    'status_share_stale_forecast_note': l10nEntry(
      english: 'Weather snapshot may be cached, offline, or estimated.',
      arabic: 'قد تكون لقطة الطقس مخزنة أو غير متصلة أو تقديرية.',
      hindi: 'मौसम स्नैपशॉट कैश/ऑफ़लाइन/अनुमानित हो सकता है।',
      urdu: 'موسم سنپ شاٹ کیش/آف لائن/تخمینی ہو سکتا ہے۔',
      bengali: 'আবহাওয়ার স্ন্যাপশট ক্যাশ/অফলাইন/আনুমানিক হতে পারে।',
      tamil: 'வானிலை பதிவு கேச்/ஆஃப்லைன்/மதிப்பீடாக இருக்கலாம்.',
      malayalam: 'Weather snapshot may be cached, offline, or estimated.',
      nepali: 'मौसम स्न्यापशट क्यास/अफलाइन/अनुमानित हुन सक्छ।',
      filipino: 'Maaaring cached, offline, o estimate ang weather snapshot.',
    ),
    'status_share_disclaimer': l10nEntry(
      english:
          'Educational summary from weather data only. This is not workplace WBGT measurement, legal advice, or an official Ministry of Labour determination.',
      arabic:
          'ملخص تعليمي من بيانات الطقس فقط — ليس قياس WBGT في مكان العمل ولا استشارة قانونية ولا قراراً رسمياً من وزارة العمل.',
      hindi:
          'केवल मौसम डेटा से शैक्षिक सारांश — कार्यस्थल WBGT माप, कानूनी सलाह या MoL निर्धारण नहीं।',
      urdu:
          'صرف موسم کے ڈیٹا سے تعلیمی خلاصہ — کام کی جگہ WBGT پیمائش، قانونی مشورہ یا MoL فیصلہ نہیں۔',
      bengali:
          'শুধু আবহাওয়ার ডেটা থেকে শিক্ষামূলক — কর্মক্ষেত্রে WBGT মাপ, আইনি পরামর্শ বা MoL সিদ্ধান্ত নয়।',
      tamil:
          'வானிலை தரவிலிருந்து கல்வி மட்டும் — பணியிட WBGT அளவீடு, சட்ட ஆலோசனை அல்லது MoL தீர்மானம் அல்ல.',
      malayalam:
          'Educational weather summary only — not workplace WBGT or MoL determination.',
      nepali:
          'मौसम डेटाबाट शैक्षिक मात्र — कार्यस्थल WBGT होइन, MoL निर्धारण होइन।',
      filipino:
          'Educational mula sa weather lang — hindi workplace WBGT o opisyal na MoL determination.',
    ),
  };

  static String format(String key, String locale, {required Map<String, String> params}) {
    var text = t(key, locale);
    for (final entry in params.entries) {
      text = text.replaceAll('{${entry.key}}', entry.value);
    }
    return text;
  }

  static String wbgtRiskLabel(String levelKey, String locale) {
    switch (levelKey) {
      case 'work_stop':
        return t('wbgt_risk_work_stop', locale);
      case 'extreme':
        return t('wbgt_risk_extreme', locale);
      case 'high':
        return t('wbgt_risk_high', locale);
      case 'moderate':
        return t('wbgt_risk_moderate', locale);
      default:
        return t('wbgt_risk_lower', locale);
    }
  }

  static String heatIndexRiskLabel(double heatIndexC, String locale) {
    if (heatIndexC >= 54) return t('heat_risk_extreme_danger', locale);
    if (heatIndexC >= 46) return t('heat_risk_danger', locale);
    if (heatIndexC >= 38) return t('heat_risk_extreme_caution', locale);
    if (heatIndexC >= 32) return t('heat_risk_caution', locale);
    return t('heat_risk_safe', locale);
  }

  static String outdoorAdviceFor(double heatIndexC, String locale) {
    if (heatIndexC >= 54) return t('outdoor_advice_extreme', locale);
    if (heatIndexC >= 46) return t('outdoor_advice_danger', locale);
    if (heatIndexC >= 38) return t('outdoor_advice_caution', locale);
    if (heatIndexC >= 32) return t('outdoor_advice_mild', locale);
    return t('outdoor_advice_safe', locale);
  }

  static String uvLabelFor(int uvIndex, String locale) {
    if (uvIndex >= 11) return t('uv_extreme', locale);
    if (uvIndex >= 8) return t('uv_very_high', locale);
    if (uvIndex >= 6) return t('uv_high', locale);
    if (uvIndex >= 3) return t('uv_moderate', locale);
    return t('uv_low', locale);
  }

  static String routeRiskLabel(String risk, String locale) {
    switch (risk.toLowerCase()) {
      case 'low':
        return t('route_risk_low', locale);
      case 'high':
        return t('route_risk_high', locale);
      default:
        return t('route_risk_medium', locale);
    }
  }

  static String routeHeatBadge(String risk, String locale) {
    return format(
      'route_heat_badge',
      locale,
      params: {'risk': routeRiskLabel(risk, locale)},
    );
  }

  static String localizedDescription(String description, String locale) {
    if (description == 'Hot (no connection)') {
      return t('weather_desc_hot_no_connection', locale);
    }
    if (description == 'Hot') return t('weather_desc_hot', locale);
    return description;
  }
}
