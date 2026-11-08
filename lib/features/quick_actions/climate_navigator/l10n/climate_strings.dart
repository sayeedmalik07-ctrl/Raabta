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
    'hydration_reminder_title': l10nEntry(
      english: 'Hydration break',
      arabic: 'استراحة للترطيب',
      hindi: 'हाइड्रेशन ब्रेक',
      urdu: 'ہائیڈریشن بریک',
      bengali: 'হাইড্রেশন বিরতি',
      tamil: 'நீர்ச்சத்து இடைவெளி',
      filipino: 'Hydration break',
    ),
    'hydration_reminder_body': l10nEntry(
      english: 'Take a rest and drink water in the shade.',
      arabic: 'استرح واشرب ماء في الظل.',
      hindi: 'छाया में आराम करें और पानी पिएँ।',
      urdu: 'سaye میں آرام کریں اور پانی پئیں۔',
      bengali: 'ছায়ায় বিশ্রাম নিন এবং পানি পান করুন।',
      tamil: 'நிழலில் ஓய்வெடுத்து தண்ணீர் குடியுங்கள்.',
      filipino: 'Magpahinga at uminom ng tubig sa lilim.',
    ),
    'hydration_reminder_toggle_label': l10nEntry(
      english: 'Rest & hydration reminders',
      arabic: 'تذكيرات الراحة والترطيب',
      hindi: 'आराम और हाइड्रेशन रिमाइंडर',
      urdu: 'آرام اور ہائیڈریشن یاددہانیاں',
      bengali: 'বিশ্রাম ও হাইড্রেশন রিমাইন্ডার',
      tamil: 'ஓய்வு & நீர்ச்சத்து நினைவூட்டல்கள்',
      filipino: 'Rest & hydration reminders',
    ),
    'hydration_reminder_toggle_subtitle': l10nEntry(
      english:
          'Opt-in: local alerts every 30 minutes for the next 4 hours while enabled.',
      arabic:
          'اختياري: تنبيهات محلية كل 30 دقيقة لـ 4 ساعات القادمة عند التفعيل.',
      hindi:
          'ऑप्ट-इन: सक्षम होने पर अगले 4 घंटे हर 30 मिनट स्थानीय अलर्ट।',
      urdu:
          'آپشن: فعال ہونے پر اگلے 4 گھنٹے ہر 30 منٹ مقامی الرٹ۔',
      bengali:
          'অপ্ট-ইন: চালু থাকলে পরের ৪ ঘণ্টা প্রতি ৩০ মিনিটে স্থানীয় সতর্কতা।',
      tamil:
          'தேர்வு: இயக்கப்பட்டால் அடுத்த 4 மணி நேரம் 30 நிமிடத்திற்கு ஒருமுறை உள்ளூர் எச்சரிக்கை.',
      filipino:
          'Opt-in: local alerts every 30 min for the next 4 hours when enabled.',
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
          'Qatar climate status. Air temperature {temp} degrees Celsius. Estimated WBGT {wbgt} degrees, {wbgtLabel}. Heat index {heatIndex} degrees, {heatLabel}. {advice}',
      arabic:
          'حالة مناخ قطر. درجة حرارة الهواء {temp} مئوية. WBGT التقديري {wbgt} درجة، {wbgtLabel}. مؤشر الحرارة {heatIndex} درجة، {heatLabel}. {advice}',
      hindi:
          'Qatar climate status. Air temperature {temp} degrees Celsius. Estimated WBGT {wbgt} degrees, {wbgtLabel}. Heat index {heatIndex} degrees, {heatLabel}. {advice}',
      urdu:
          'Qatar climate status. Air temperature {temp} degrees Celsius. Estimated WBGT {wbgt} degrees, {wbgtLabel}. Heat index {heatIndex} degrees, {heatLabel}. {advice}',
      bengali:
          'Qatar climate status. Air temperature {temp} degrees Celsius. Estimated WBGT {wbgt} degrees, {wbgtLabel}. Heat index {heatIndex} degrees, {heatLabel}. {advice}',
      tamil:
          'Qatar climate status. Air temperature {temp} degrees Celsius. Estimated WBGT {wbgt} degrees, {wbgtLabel}. Heat index {heatIndex} degrees, {heatLabel}. {advice}',
      filipino:
          'Qatar climate status. Air temperature {temp} degrees Celsius. Estimated WBGT {wbgt} degrees, {wbgtLabel}. Heat index {heatIndex} degrees, {heatLabel}. {advice}',
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
