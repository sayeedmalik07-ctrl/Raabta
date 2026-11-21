/// Book Your Flight Home — 8-language strings.
abstract final class FlightCheckerStrings {
  static const supportedLocales = [
    'English',
    'Arabic',
    'Hindi',
    'Urdu',
    'Malayalam',
    'Nepali',
    'Bengali',
    'Filipino',
  ];

  static String t(String key, [String locale = 'English']) {
    final map = _catalog[key];
    if (map == null) return key;
    return map[locale] ?? map['English'] ?? key;
  }

  static final _catalog = <String, Map<String, String>>{
    'fc_title': _e(
      'Book Your Flight Home',
      'احجز رحلتك إلى الوطن',
      'घर की उड़ान बुक करें',
    ),
    'fc_subtitle': _e(
      'Open Google Flights or Skyscanner with Doha (DOH) pre-filled — search happens outside Raabta.',
      'افتح Google Flights أو Skyscanner مع DOH — البحث خارج Raabta.',
      'DOH के साथ Google Flights या Skyscanner खोलें — खोज Raabta के बाहर।',
    ),
    'fc_disclaimer': _e(
      'Raabta does not show flight prices or sell tickets. External sites set fares and availability.',
      'Raabta لا تعرض أسعاراً ولا تبيع تذاكر. الأسعار على المواقع الخارجية.',
      'Raabta कीमत नहीं दिखाता और टिकट नहीं बेचता।',
    ),
    'fc_origin_label': _e(
      'From Doha (DOH)',
      'من الدوحة (DOH)',
      'दोहा (DOH) से',
    ),
    'fc_pick_destination': _e(
      'Choose destination',
      'اختر الوجهة',
      'गंतव्य चुनें',
    ),
    'fc_search_google': _e(
      'Search on Google Flights',
      'البحث على Google Flights',
      'Google Flights पर खोजें',
    ),
    'fc_search_skyscanner': _e(
      'Search on Skyscanner',
      'البحث على Skyscanner',
      'Skyscanner पर खोजें',
    ),
    'fc_tips_heading': _e(
      'General booking tips',
      'نصائح حجز عامة',
      'सामान्य बुकिंग सुझाव',
    ),
    'fc_tips_sub': _e(
      'Well-established guidance — not live prices or airline-specific advice.',
      'إرشادات عامة — لا أسعار حية ولا نصائح لشركة طيران.',
      'सामान्य मार्गदर्शन — live कीमत या एयरलाइन सलाह नहीं।',
    ),
    'fc_emergency': _e(
      'Need to fly home urgently?',
      'تحتاج السفر عاجلاً؟',
      'तुरंत घर जाना है?',
    ),
    'fc_emergency_sub': _e(
      'Jump to search for your nationality\'s main route',
      'انتقل للبحث حسب جنسيتك',
      'अपनी nationality के मुख्य रूट पर जाएँ',
    ),
    'fc_emergency_title': _e(
      'Urgent travel',
      'سفر عاجل',
      'अत्यावश्यक यात्रा',
    ),
    'fc_emergency_no_nationality': _e(
      'Add your nationality in Profile to use this shortcut.',
      'أضف جنسيتك في الملف الشخصي.',
      'Profile में nationality जोड़ें।',
    ),
    'fc_emergency_unsupported': _e(
      'Your nationality is not in our five corridor countries yet. Pick a destination below.',
      'جنسيتك ليست ضمن الممرات الخمس — اختر وجهة أدناه.',
      'आपकी nationality पाँच corridor देशों में नहीं — नीचे चुनें।',
    ),
    'fc_open_failed': _e(
      'Could not open link. Try again.',
      'تعذر فتح الرابط.',
      'लिंक नहीं खुला।',
    ),
    'fc_country_india': _e('India', 'الهند', 'भारत'),
    'fc_country_pakistan': _e('Pakistan', 'باكستان', 'पाकिस्तान'),
    'fc_country_bangladesh': _e('Bangladesh', 'بنغلاديش', 'बांग्लादेश'),
    'fc_country_nepal': _e('Nepal', 'نепال', 'नेपाल'),
    'fc_country_philippines': _e('Philippines', 'الفلبين', 'फिलीपींस'),
    'fc_city_delhi': _e('Delhi (DEL)', 'دلهي', 'दिल्ली'),
    'fc_city_mumbai': _e('Mumbai (BOM)', 'مumbai', 'मुंबई'),
    'fc_city_bengaluru': _e('Bengaluru (BLR)', 'بengaluru', 'बेंगलुरु'),
    'fc_city_chennai': _e('Chennai (MAA)', 'chennai', 'चेन्नई'),
    'fc_city_karachi': _e('Karachi (KHI)', 'كرachi', 'कराची'),
    'fc_city_lahore': _e('Lahore (LHE)', 'lahore', 'लाहौर'),
    'fc_city_islamabad': _e('Islamabad (ISB)', 'islamabad', 'इस्लामाबाद'),
    'fc_city_dhaka': _e('Dhaka (DAC)', 'dhaka', 'ढाका'),
    'fc_city_chittagong': _e('Chittagong (CGP)', 'chittagong', 'चटग्राम'),
    'fc_city_kathmandu': _e('Kathmandu (KTM)', 'kathmandu', 'काठमांडू'),
    'fc_city_manila': _e('Manila (MNL)', 'manila', 'मनीला'),
    'fc_city_cebu': _e('Cebu (CEB)', 'cebu', 'सेबू'),
    'fc_tip_booking_window': _e(
      'Many travellers find better availability when booking several weeks ahead — last-minute fares are often higher.',
      'الحجز قبل أسابيع قد يوفّر خيارات أكثر — الأسعار اللحظية غالباً أعلى.',
      'कई सप्ताह पहले बुक करने पर विकल्प बेहतर मिल सकते हैं।',
    ),
    'fc_tip_midweek': _e(
      'Midweek departures are often less crowded than peak weekend travel — compare a few dates if you can.',
      'المغادرة منتصف الأسبوع أقل ازدحاماً غالباً من عطلة نهاية الأسبوع.',
      'मध्य सप्ताह की उड़ानें अ част weekend से कम भीड़ वाली हो सकती हैं।',
    ),
    'fc_tip_direct_layover': _e(
      'Direct flights save time; one-stop routes sometimes cost less — weigh time vs total journey length.',
      'الرحلات المباشرة توفر الوقت؛ التوقف قد يقلل التكلفة أحياناً.',
      'सीधी उड़ान समय बचाती है; एक स्टॉप कभी-कभी सस्ती हो सकती है।',
    ),
    'fc_tip_compare_providers': _e(
      'Compare at least two search sites — fares and bundles can differ for the same route.',
      'قارن موقعين على الأقل — الأسعار قد تختلف.',
      'कम से कम दो साइटों पर तुलना करें।',
    ),
    'fc_tip_visa_passport': _e(
      'Confirm passport validity and visa rules before you pay — airline sites do not replace embassy guidance.',
      'تحقق من جواز السفر والتأشيرة قبل الدفع.',
      'भुगतान से पहले passport और visa नियम जाँचें।',
    ),
    'fc_tool_title': _e(
      'Book Flight Home',
      'احجز للوطن',
      'घर की उड़ान',
    ),
    'fc_tool_desc': _e(
      'DOH to India, Nepal, PH, BD, PK — external search',
      'DOH إلى الممرات الخمس — بحث خارجي',
      'DOH से 5 corridor — बाहरी खोज',
    ),
  };
}

Map<String, String> _e(String en, String ar, String hi) => {
      'English': en,
      'Arabic': ar,
      'Hindi': hi,
      'Urdu': ar,
      'Malayalam': en,
      'Nepali': en,
      'Bengali': en,
      'Filipino': en,
    };
