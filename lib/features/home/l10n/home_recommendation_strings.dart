import 'package:flutter/foundation.dart';
import 'package:raabta/core/l10n/app_locale.dart';
import 'package:raabta/core/l10n/locale_catalog_coverage.dart';
import 'package:raabta/core/l10n/locale_catalog_entry.dart';

/// Static templates for Expat Score improvement actions and hero advice on Home.
abstract final class HomeRecommendationStrings {
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

  /// Strict nine-locale coverage inventory (J1 — no runtime behavior change).
  static Map<String, Map<String, String>> get catalogForStrictCoverage =>
      _catalog;

  @visibleForTesting
  static Map<String, Set<String>> get localeCoverageReport =>
      buildLocaleCoverageReport(
        catalog: _catalog,
        supportedLocales: supportedLocales,
      );

  @visibleForTesting
  static Map<String, Set<String>> get strictLocaleCoverageReport =>
      buildLocaleCoverageReport(
        catalog: catalogForStrictCoverage,
        supportedLocales: supportedLocales,
        fillMissingWithEnglish: false,
      );

  static final _catalog = <String, Map<String, String>>{
    'time_1_min': l10nEntry(
      english: '1 min',
      arabic: '1 د',
      hindi: '1 मिनट',
      urdu: '1 منٹ',
      malayalam: '1 മിനിറ്റ്',
      nepali: '१ मिनेट',
      bengali: '1 মিনিট',
      tamil: '1 நிமிடம்',
      filipino: 'Tip sa pagpapahusay ng home score: 1 min',
    ),
    'time_1_tap': l10nEntry(
      english: '1 tap',
      arabic: 'نقرة واحدة',
      hindi: '1 टैप',
      urdu: '1 تھپتھپائیں۔',
      malayalam: '1 ടാപ്പ്',
      nepali: '१ ट्याप गर्नुहोस्',
      bengali: '1 ট্যাপ',
      tamil: '1 தட்டு',
      filipino: '1 tapikin',
    ),
    'time_2_min': l10nEntry(
      english: '2 min',
      arabic: '2 د',
      hindi: '2 मिनट',
      urdu: '2 منٹ',
      malayalam: '2 മിനിറ്റ്',
      nepali: '२ मिनेट',
      bengali: '2 মিনিট',
      tamil: '2 நிமிடம்',
      filipino: 'Tip sa pagpapahusay ng home score: 2 min',
    ),
    'time_3_min': l10nEntry(
      english: '3 min',
      arabic: '3 د',
      hindi: '3 मिनट',
      urdu: '3 منٹ',
      malayalam: '3 മിനിറ്റ്',
      nepali: '३ मिनेट',
      bengali: '3 মিনিট',
      tamil: '3 நிமிடம்',
      filipino: 'Tip sa pagpapahusay ng marka sa bahay: 3 min',
    ),
    'time_5_min': l10nEntry(
      english: '5 min',
      arabic: '5 د',
      hindi: '5 मिनट',
      urdu: '5 منٹ',
      malayalam: '5 മിനിറ്റ്',
      nepali: '५ मिनेट',
      bengali: '5 মিনিট',
      tamil: '5 நிமிடம்',
      filipino: 'Tip sa pagpapabuti ng marka sa bahay: 5 min',
    ),
    'improve_iqama_title': l10nEntry(
      english: 'Set your Iqama expiry date',
      arabic: 'حدّد تاريخ انتهاء الإقامة',
      hindi: 'अपना इकामा समाप्ति तिथि निर्धारित करें',
      urdu: 'اپنا اقامہ ختم ہونے کی تاریخ طے کریں۔',
      malayalam: 'നിങ്ങളുടെ ഇഖാമയുടെ കാലഹരണ തീയതി സജ്ജമാക്കുക',
      nepali: 'आफ्नो Iqama समाप्ति मिति सेट गर्नुहोस्',
      bengali: 'আপনার ইকামার মেয়াদ শেষ হওয়ার তারিখ সেট করুন',
      tamil: 'உங்கள் இகாமா காலாவதி தேதியை அமைக்கவும்',
      filipino: 'Itakda ang iyong petsa ng pag-expire ng Iqama',
    ),
    'improve_iqama_desc': l10nEntry(
      english: 'Get reminders before your Iqama expires',
      arabic: 'احصل على تذكيرات قبل انتهاء الإقامة',
      hindi: 'आपका इकामा समाप्त होने से पहले अनुस्मारक प्राप्त करें',
      urdu: 'اپنا اقامہ ختم ہونے سے پہلے یاددہانی حاصل کریں۔',
      malayalam:
          'നിങ്ങളുടെ ഇഖാമ കാലഹരണപ്പെടുന്നതിന് മുമ്പ് ഓർമ്മപ്പെടുത്തലുകൾ നേടുക',
      nepali: 'आफ्नो Iqama समाप्त हुनु अघि रिमाइन्डर प्राप्त गर्नुहोस्',
      bengali: 'আপনার ইকামার মেয়াদ শেষ হওয়ার আগে অনুস্মারক পান',
      tamil: 'உங்கள் இகாமா காலாவதியாகும் முன் நினைவூட்டல்களைப் பெறுங்கள்',
      filipino: 'Kumuha ng mga paalala bago mag-expire ang iyong Iqama',
    ),
    'improve_join_group_title': l10nEntry(
      english: 'Join {groupName} group',
      arabic: 'انضم إلى مجموعة {groupName}',
      hindi: '{groupName} समूह में शामिल हों',
      urdu: 'گروپ {groupName} میں شامل ہوں',
      malayalam: '{groupName} ഗ്രൂപ്പിൽ ചേരുക',
      nepali: '{groupName} समूहमा सामेल हुनुहोस्',
      bengali: '{groupName} গ্রুপে যোগ দিন',
      tamil: '{groupName} குழுவில் சேரவும்',
      filipino: 'Sumali sa grupong {groupName}.',
    ),
    'improve_join_group_desc': l10nEntry(
      english: 'Connect with expats who share your background',
      arabic: 'تواصل مع مغتربين يشاركونك خلفيتك',
      hindi: 'उन प्रवासियों से जुड़ें जो आपकी पृष्ठभूमि साझा करते हैं',
      urdu: 'آپ کے پس منظر کا اشتراک کرنے والے غیر ملکیوں سے رابطہ کریں۔',
      malayalam: 'നിങ്ങളുടെ പശ്ചാത്തലം പങ്കിടുന്ന പ്രവാസികളുമായി ബന്ധപ്പെടുക',
      nepali: 'आफ्नो पृष्ठभूमि साझा गर्ने प्रवासीहरूसँग जडान गर्नुहोस्',
      bengali: 'আপনার ব্যাকগ্রাউন্ড শেয়ার করে এমন প্রবাসীদের সাথে সংযোগ করুন',
      tamil:
          'உங்கள் பின்னணியைப் பகிர்ந்து கொள்ளும் வெளிநாட்டவர்களுடன் இணையுங்கள்',
      filipino: 'Kumonekta sa mga expat na kapareho ng iyong background',
    ),
    'improve_skills_title': l10nEntry(
      english: 'Complete your skills profile',
      arabic: 'أكمل ملف مهاراتك',
      hindi: 'अपना कौशल प्रोफ़ाइल पूरा करें',
      urdu: 'اپنی مہارت کا پروفائل مکمل کریں۔',
      malayalam: 'നിങ്ങളുടെ വൈദഗ്ധ്യ പ്രൊഫൈൽ പൂർത്തിയാക്കുക',
      nepali: 'आफ्नो कौशल प्रोफाइल पूरा गर्नुहोस्',
      bengali: 'আপনার দক্ষতা প্রোফাইল সম্পূর্ণ করুন',
      tamil: 'உங்கள் திறன் சுயவிவரத்தை முடிக்கவும்',
      filipino: 'Kumpletuhin ang iyong profile ng mga kasanayan',
    ),
    'improve_skills_desc': l10nEntry(
      english: 'Add HSE, safety or other skills to improve job matches',
      arabic: 'أضف HSE أو السلامة أو مهارات أخرى لتحسين تطابق الوظائف',
      hindi: 'जॉब मैच को बेहतर बनाने के लिए एचएसई, सुरक्षा या अन्य कौशल जोड़ें',
      urdu:
          'ملازمت کی مماثلت کو بہتر بنانے کے لیے HSE، حفاظت یا دیگر مہارتیں شامل کریں۔',
      malayalam:
          'ജോലി പൊരുത്തങ്ങൾ മെച്ചപ്പെടുത്താൻ HSE, സുരക്ഷ അല്ലെങ്കിൽ മറ്റ് കഴിവുകൾ ചേർക്കുക',
      nepali: 'काम मिलान सुधार गर्न HSE, सुरक्षा वा अन्य सीपहरू थप्नुहोस्',
      bengali:
          'কাজের মিল উন্নত করতে HSE, নিরাপত্তা বা অন্যান্য দক্ষতা যোগ করুন',
      tamil:
          'வேலை பொருத்தங்களை மேம்படுத்த HSE, பாதுகாப்பு அல்லது பிற திறன்களைச் சேர்க்கவும்',
      filipino:
          'Magdagdag ng HSE, kaligtasan o iba pang mga kasanayan upang mapabuti ang mga tugma sa trabaho',
    ),
    'improve_profession_title': l10nEntry(
      english: 'Add your profession',
      arabic: 'أضف مهنتك',
      hindi: 'अपना पेशा जोड़ें',
      urdu: 'اپنا پیشہ شامل کریں۔',
      malayalam: 'നിങ്ങളുടെ തൊഴിൽ ചേർക്കുക',
      nepali: 'आफ्नो पेशा थप्नुहोस्',
      bengali: 'আপনার পেশা যোগ করুন',
      tamil: 'உங்கள் தொழிலைச் சேர்க்கவும்',
      filipino: 'Idagdag ang iyong propesyon',
    ),
    'improve_profession_desc': l10nEntry(
      english: 'Help Raabta AI personalize jobs and services for you',
      arabic: 'ساعد Raabta AI على تخصيص الوظائف والخدمات لك',
      hindi:
          'राब्ता एआई को आपके लिए नौकरियों और सेवाओं को वैयक्तिकृत करने में सहायता करें',
      urdu:
          'Raabta AI کو اپنے لیے ملازمتوں اور خدمات کو ذاتی نوعیت دینے میں مدد کریں۔',
      malayalam:
          'നിങ്ങൾക്കായി ജോലികളും സേവനങ്ങളും വ്യക്തിഗതമാക്കാൻ Raabta AI-യെ സഹായിക്കുക',
      nepali:
          'Raabta AI लाई तपाईंको लागि रोजगार र सेवाहरू निजीकृत गर्न मद्दत गर्नुहोस्',
      bengali:
          'Raabta AI কে আপনার জন্য চাকরি এবং পরিষেবাগুলি ব্যক্তিগতকৃত করতে সহায়তা করুন',
      tamil:
          'உங்களுக்கான வேலைகளையும் சேவைகளையும் தனிப்பயனாக்க Raabta AIக்கு உதவுங்கள்',
      filipino:
          'Tulungan ang Raabta AI na i-personalize ang mga trabaho at serbisyo para sa iyo',
    ),
    'improve_certs_title': l10nEntry(
      english: 'Add certifications',
      arabic: 'أضف الشهادات',
      hindi: 'प्रमाणपत्र जोड़ें',
      urdu: 'سرٹیفکیٹ شامل کریں',
      malayalam: 'സർട്ടിഫിക്കേഷനുകൾ ചേർക്കുക',
      nepali: 'प्रमाणपत्रहरू थप्नुहोस्',
      bengali: 'সার্টিফিকেশন যোগ করুন',
      tamil: 'சான்றிதழ்களைச் சேர்க்கவும்',
      filipino: 'Magdagdag ng mga sertipikasyon',
    ),
    'improve_certs_desc': l10nEntry(
      english: 'NEBOSH, IOSH and other certs boost career score',
      arabic: 'شهادات NEBOSH و IOSH وغيرها تعزز نقاط المسار المهني',
      hindi: 'NEBOSH, IOSH और अन्य प्रमाणपत्र कैरियर स्कोर को बढ़ावा देते हैं',
      urdu: 'NEBOSH، IOSH اور دیگر سرٹیفیکیشنز کیریئر کے اسکور کو بڑھاتے ہیں۔',
      malayalam:
          'NEBOSH, IOSH, മറ്റ് സർട്ടിഫിക്കറ്റുകൾ എന്നിവ കരിയർ സ്കോർ വർദ്ധിപ്പിക്കുന്നു',
      nepali: 'NEBOSH, IOSH र अन्य प्रमाणपत्रहरूले क्यारियर स्कोर बढाउँछ',
      bengali: 'NEBOSH, IOSH এবং অন্যান্য শংসাপত্র কর্মজীবনের স্কোর বাড়ায়',
      tamil:
          'NEBOSH, IOSH மற்றும் பிற சான்றிதழ்கள் தொழில் மதிப்பெண்ணை அதிகரிக்கின்றன',
      filipino:
          'Ang NEBOSH, IOSH at iba pang mga sertipikasyon ay nagpapalakas ng marka ng karera',
    ),
    'improve_explore_jobs_title': l10nEntry(
      english: 'Explore job listings',
      arabic: 'استكشف قوائم الوظائف',
      hindi: 'नौकरी लिस्टिंग का अन्वेषण करें',
      urdu: 'ملازمت کی فہرستیں دریافت کریں۔',
      malayalam: 'ജോലി ലിസ്റ്റിംഗുകൾ പര്യവേക്ഷണം ചെയ്യുക',
      nepali: 'कार्य सूचीहरू अन्वेषण गर्नुहोस्',
      bengali: 'চাকরির তালিকা অন্বেষণ করুন',
      tamil: 'வேலை பட்டியல்களை ஆராயுங்கள்',
      filipino: 'Galugarin ang mga listahan ng trabaho',
    ),
    'improve_explore_jobs_desc': l10nEntry(
      english: 'View 5+ jobs to activate your job search score',
      arabic: 'اعرض 5+ وظائف لتفعيل نقاط البحث عن عمل',
      hindi: 'अपना नौकरी खोज स्कोर सक्रिय करने के लिए 5+ नौकरियां देखें',
      urdu: 'اپنے جاب سرچ سکور کو چالو کرنے کے لیے 5+ نوکریاں دیکھیں',
      malayalam: 'നിങ്ങളുടെ തൊഴിൽ തിരയൽ സ്കോർ സജീവമാക്കാൻ 5+ ജോലികൾ കാണുക',
      nepali: 'आफ्नो जागिर खोज स्कोर सक्रिय गर्न 5+ कार्यहरू हेर्नुहोस्',
      bengali: 'আপনার কাজের অনুসন্ধান স্কোর সক্রিয় করতে 5+ চাকরি দেখুন',
      tamil: 'உங்கள் வேலை தேடல் ஸ்கோரை செயல்படுத்த 5+ வேலைகளைப் பார்க்கவும்',
      filipino:
          'Tingnan ang 5+ mga trabaho upang i-activate ang iyong marka sa paghahanap ng trabaho',
    ),
    'improve_save_job_title': l10nEntry(
      english: 'Save a job you like',
      arabic: 'احفظ وظيفة تعجبك',
      hindi: 'अपनी पसंद की नौकरी बचाएं',
      urdu: 'اپنی پسندیدہ نوکری محفوظ کریں۔',
      malayalam: 'നിങ്ങൾ ഇഷ്ടപ്പെടുന്ന ഒരു ജോലി സംരക്ഷിക്കുക',
      nepali: 'तपाईलाई मनपर्ने काम बचत गर्नुहोस्',
      bengali: 'আপনার পছন্দের একটি কাজ সংরক্ষণ করুন',
      tamil: 'நீங்கள் விரும்பும் வேலையைச் சேமிக்கவும்',
      filipino: 'Mag-save ng trabahong gusto mo',
    ),
    'improve_save_job_desc': l10nEntry(
      english: 'Saved jobs count toward your career engagement score',
      arabic: 'الوظائف المحفوظة تُحسب في نقاط تفاعلك المهني',
      hindi: 'सहेजी गई नौकरियाँ आपके कैरियर सहभागिता स्कोर में गिनी जाती हैं',
      urdu:
          'محفوظ کردہ ملازمتیں آپ کے کیریئر کی مصروفیت کے اسکور میں شمار ہوتی ہیں۔',
      malayalam:
          'സംരക്ഷിച്ച ജോലികൾ നിങ്ങളുടെ കരിയർ എൻഗേജ്‌മെൻ്റ് സ്‌കോറിൽ കണക്കാക്കുന്നു',
      nepali:
          'बचत गरिएका कार्यहरू तपाईंको क्यारियर संलग्नता स्कोरमा गणना हुन्छन्',
      bengali:
          'সংরক্ষিত কাজগুলি আপনার কর্মজীবনের ব্যস্ততার স্কোরের জন্য গণনা করে',
      tamil:
          'சேமித்த வேலைகள் உங்கள் தொழில் நிச்சயதார்த்த மதிப்பெண்ணில் கணக்கிடப்படும்',
      filipino:
          'Ang mga nai-save na trabaho ay binibilang sa iyong marka ng pakikipag-ugnayan sa karera',
    ),
    'improve_housing_title': l10nEntry(
      english: 'Confirm your current housing',
      arabic: 'أكد سكنك الحالي',
      hindi: 'अपने वर्तमान आवास की पुष्टि करें',
      urdu: 'اپنی موجودہ رہائش کی تصدیق کریں۔',
      malayalam: 'നിങ്ങളുടെ നിലവിലെ ഭവനം സ്ഥിരീകരിക്കുക',
      nepali: 'आफ्नो हालको आवास पुष्टि गर्नुहोस्',
      bengali: 'আপনার বর্তমান আবাসন নিশ্চিত করুন',
      tamil: 'உங்கள் தற்போதைய வீட்டை உறுதிப்படுத்தவும்',
      filipino: 'Kumpirmahin ang iyong kasalukuyang pabahay',
    ),
    'improve_housing_desc': l10nEntry(
      english: 'Unlock housing insights tailored to your area',
      arabic: 'افتح رؤى سكنية مخصصة لمنطقتك',
      hindi: 'अपने क्षेत्र के अनुरूप आवास अंतर्दृष्टि अनलॉक करें',
      urdu: 'اپنے علاقے کے مطابق ہاؤسنگ بصیرت کو غیر مقفل کریں۔',
      malayalam:
          'നിങ്ങളുടെ പ്രദേശത്തിന് അനുയോജ്യമായ ഭവന സ്ഥിതിവിവരക്കണക്കുകൾ അൺലോക്ക് ചെയ്യുക',
      nepali: 'तपाईंको क्षेत्र अनुरूप आवास अन्तर्दृष्टि अनलक गर्नुहोस्',
      bengali: 'আপনার এলাকার উপযোগী হাউজিং ইনসাইট আনলক করুন',
      tamil: 'உங்கள் பகுதிக்கு ஏற்றவாறு வீடமைப்பு நுண்ணறிவுகளைத் திறக்கவும்',
      filipino: 'I-unlock ang mga insight sa pabahay na iniakma sa iyong lugar',
    ),
    'improve_browse_housing_title': l10nEntry(
      english: 'Browse housing listings',
      arabic: 'تصفح قوائم السكن',
      hindi: 'आवास सूची ब्राउज़ करें',
      urdu: 'رہائش کی فہرست کو براؤز کریں۔',
      malayalam: 'ഭവന ലിസ്റ്റിംഗുകൾ ബ്രൗസ് ചെയ്യുക',
      nepali: 'आवास सूचीहरू ब्राउज गर्नुहोस्',
      bengali: 'হাউজিং তালিকা ব্রাউজ করুন',
      tamil: 'வீட்டு பட்டியல்களை உலாவவும்',
      filipino: 'Mag-browse ng mga listahan ng pabahay',
    ),
    'improve_browse_housing_desc': l10nEntry(
      english: 'Search and save listings to improve housing score',
      arabic: 'ابحث واحفظ القوائم لتحسين نقاط السكن',
      hindi: 'आवास स्कोर सुधारने के लिए सूचियाँ खोजें और सहेजें',
      urdu:
          'رہائش کے اسکور کو بہتر بنانے کے لیے فہرستیں تلاش کریں اور محفوظ کریں۔',
      malayalam:
          'ഭവന സ്‌കോർ മെച്ചപ്പെടുത്താൻ ലിസ്റ്റിംഗുകൾ തിരയുക, സംരക്ഷിക്കുക',
      nepali: 'आवास स्कोर सुधार गर्न सूचीहरू खोज्नुहोस् र बचत गर्नुहोस्',
      bengali: 'হাউজিং স্কোর উন্নত করতে তালিকা অনুসন্ধান করুন এবং সংরক্ষণ করুন',
      tamil: 'வீட்டு ஸ்கோரை மேம்படுத்த, பட்டியல்களைத் தேடிச் சேமிக்கவும்',
      filipino:
          'Maghanap at mag-save ng mga listahan upang mapabuti ang marka ng pabahay',
    ),
    'improve_budget_title': l10nEntry(
      english: 'Set your monthly budget',
      arabic: 'حدّد ميزانيتك الشهرية',
      hindi: 'अपना मासिक बजट निर्धारित करें',
      urdu: 'اپنا ماہانہ بجٹ سیٹ کریں۔',
      malayalam: 'നിങ്ങളുടെ പ്രതിമാസ ബജറ്റ് സജ്ജമാക്കുക',
      nepali: 'आफ्नो मासिक बजेट सेट गर्नुहोस्',
      bengali: 'আপনার মাসিক বাজেট সেট করুন',
      tamil: 'உங்கள் மாதாந்திர பட்ஜெட்டை அமைக்கவும்',
      filipino: 'Itakda ang iyong buwanang badyet',
    ),
    'improve_budget_desc': l10nEntry(
      english: 'Get better housing and salary recommendations',
      arabic: 'احصل على توصيات أفضل للسكن والراتب',
      hindi: 'बेहतर आवास और वेतन अनुशंसाएँ प्राप्त करें',
      urdu: 'بہتر رہائش اور تنخواہ کی سفارشات حاصل کریں۔',
      malayalam: 'മെച്ചപ്പെട്ട ഭവന, ശമ്പള ശുപാർശകൾ നേടുക',
      nepali: 'राम्रो आवास र तलब सिफारिसहरू प्राप्त गर्नुहोस्',
      bengali: 'ভাল আবাসন এবং বেতন সুপারিশ পান',
      tamil: 'சிறந்த வீட்டுவசதி மற்றும் சம்பள பரிந்துரைகளைப் பெறுங்கள்',
      filipino:
          'Kumuha ng mas magandang pabahay at mga rekomendasyon sa suweldo',
    ),
    'improve_transfer_title': l10nEntry(
      english: 'Set money transfer preference',
      arabic: 'حدّد تفضيل تحويل الأموال',
      hindi: 'धन हस्तांतरण प्राथमिकता निर्धारित करें',
      urdu: 'رقم کی منتقلی کی ترجیح مقرر کریں۔',
      malayalam: 'പണം ട്രാൻസ്ഫർ മുൻഗണന സജ്ജമാക്കുക',
      nepali: 'पैसा स्थानान्तरण प्राथमिकता सेट गर्नुहोस्',
      bengali: 'মানি ট্রান্সফার পছন্দ সেট করুন',
      tamil: 'பணப் பரிமாற்ற விருப்பத்தை அமைக்கவும்',
      filipino: 'Itakda ang kagustuhan sa paglipat ng pera',
    ),
    'improve_transfer_desc': l10nEntry(
      english: 'Track remittance options on the Money screen',
      arabic: 'تتبع خيارات التحويل في شاشة Money',
      hindi: 'मनी स्क्रीन पर प्रेषण विकल्पों को ट्रैक करें',
      urdu: 'منی اسکرین پر ترسیلات زر کے اختیارات کو ٹریک کریں۔',
      malayalam: 'പണം സ്‌ക്രീനിൽ പണമടയ്ക്കൽ ഓപ്ഷനുകൾ ട്രാക്ക് ചെയ്യുക',
      nepali: 'मनी स्क्रिनमा रेमिटेन्स विकल्पहरू ट्र्याक गर्नुहोस्',
      bengali: 'মানি স্ক্রিনে রেমিট্যান্স বিকল্পগুলি ট্র্যাক করুন৷',
      tamil: 'பணம் திரையில் பணம் அனுப்புதல் விருப்பங்களைக் கண்காணிக்கவும்',
      filipino: 'Subaybayan ang mga opsyon sa remittance sa screen ng Pera',
    ),
    'improve_exchange_title': l10nEntry(
      english: 'Enable exchange rate alerts',
      arabic: 'فعّل تنبيهات أسعار الصرف',
      hindi: 'विनिमय दर अलर्ट सक्षम करें',
      urdu: 'ایکسچینج ریٹ الرٹس کو فعال کریں۔',
      malayalam: 'വിനിമയ നിരക്ക് അലേർട്ടുകൾ പ്രവർത്തനക്ഷമമാക്കുക',
      nepali: 'विनिमय दर अलर्ट सक्षम गर्नुहोस्',
      bengali: 'বিনিময় হার সতর্কতা সক্ষম করুন',
      tamil: 'பரிமாற்ற வீத விழிப்பூட்டல்களை இயக்கவும்',
      filipino: 'Paganahin ang mga alerto sa exchange rate',
    ),
    'improve_exchange_desc': l10nEntry(
      english: 'Stay updated on QAR exchange rates',
      arabic: 'ابقَ على اطلاع بأسعار صرف QAR',
      hindi: 'QAR विनिमय दरों पर अद्यतन रहें',
      urdu: 'QAR کی شرح تبادلہ پر اپ ڈیٹ رہیں',
      malayalam: 'QAR വിനിമയ നിരക്കുകളെ കുറിച്ച് അപ്ഡേറ്റ് ആയി തുടരുക',
      nepali: 'QAR विनिमय दरहरूमा अद्यावधिक रहनुहोस्',
      bengali: 'QAR বিনিময় হার আপডেট থাকুন',
      tamil: 'QAR மாற்று விகிதங்கள் குறித்து புதுப்பித்த நிலையில் இருங்கள்',
      filipino: 'Manatiling updated sa QAR exchange rates',
    ),
    'improve_ask_qatar_title': l10nEntry(
      english: 'Answer a question on Ask Qatar',
      arabic: 'أجب على سؤال في Ask Qatar',
      hindi: 'आस्क कतर पर एक प्रश्न का उत्तर दें',
      urdu: 'Ask Qatar پر ایک سوال کا جواب دیں۔',
      malayalam: 'Ask Qatar എന്ന ചോദ്യത്തിന് ഉത്തരം നൽകുക',
      nepali: 'Ask Qatar मा एउटा प्रश्नको जवाफ दिनुहोस्',
      bengali: 'কাতারকে জিজ্ঞাসা করুন একটি প্রশ্নের উত্তর দিন',
      tamil: 'Ask Qatar பற்றிய கேள்விக்கு பதிலளிக்கவும்',
      filipino: 'Sagutin ang isang tanong sa Ask Qatar',
    ),
    'improve_ask_qatar_desc': l10nEntry(
      english: 'Help fellow expats and boost community score',
      arabic: 'ساعد المغتربين وعزّز نقاط المجتمع',
      hindi: 'साथी प्रवासियों की मदद करें और सामुदायिक स्कोर बढ़ाएं',
      urdu: 'ساتھی غیر ملکیوں کی مدد کریں اور کمیونٹی اسکور کو بڑھایں۔',
      malayalam:
          'സഹ പ്രവാസികളെ സഹായിക്കുകയും കമ്മ്യൂണിറ്റി സ്കോർ വർദ്ധിപ്പിക്കുകയും ചെയ്യുക',
      nepali: 'साथी प्रवासीहरूलाई मद्दत गर्नुहोस् र समुदायको स्कोर बढाउनुहोस्',
      bengali: 'সহকর্মী প্রবাসীদের সাহায্য করুন এবং সম্প্রদায়ের স্কোর বাড়ান',
      tamil:
          'சக வெளிநாட்டவர்களுக்கு உதவுங்கள் மற்றும் சமூக மதிப்பெண்ணை அதிகரிக்கவும்',
      filipino:
          'Tulungan ang mga kapwa expat at palakihin ang marka ng komunidad',
    ),
    'improve_doctor_title': l10nEntry(
      english: 'Set doctor language preference',
      arabic: 'حدّد تفضيل لغة الطبيب',
      hindi: 'डॉक्टर की भाषा प्राथमिकता निर्धारित करें',
      urdu: 'ڈاکٹر کی زبان کی ترجیحات طے کریں۔',
      malayalam: 'ഡോക്ടറുടെ ഭാഷാ മുൻഗണന സജ്ജമാക്കുക',
      nepali: 'डाक्टर भाषा प्राथमिकता सेट गर्नुहोस्',
      bengali: 'ডাক্তারের ভাষা পছন্দ সেট করুন',
      tamil: 'மருத்துவர் மொழி விருப்பத்தை அமைக்கவும்',
      filipino: 'Itakda ang kagustuhan sa wika ng doktor',
    ),
    'improve_doctor_desc': l10nEntry(
      english: 'Find doctors who speak your language',
      arabic: 'اعثر على أطباء يتحدثون لغتك',
      hindi: 'ऐसे डॉक्टर खोजें जो आपकी भाषा बोलते हों',
      urdu: 'آپ کی زبان بولنے والے ڈاکٹروں کو تلاش کریں۔',
      malayalam: 'നിങ്ങളുടെ ഭാഷ സംസാരിക്കുന്ന ഡോക്ടർമാരെ കണ്ടെത്തുക',
      nepali: 'तपाईंको भाषा बोल्ने डाक्टरहरू खोज्नुहोस्',
      bengali: 'আপনার ভাষায় কথা বলা ডাক্তারদের খুঁজুন',
      tamil: 'உங்கள் மொழியில் பேசும் மருத்துவர்களைக் கண்டறியவும்',
      filipino: 'Maghanap ng mga doktor na nagsasalita ng iyong wika',
    ),
    'improve_passport_title': l10nEntry(
      english: 'Add passport expiry date',
      arabic: 'أضف تاريخ انتهاء جواز السفر',
      hindi: 'पासपोर्ट की समाप्ति तिथि जोड़ें',
      urdu: 'پاسپورٹ کی میعاد ختم ہونے کی تاریخ شامل کریں۔',
      malayalam: 'പാസ്‌പോർട്ട് കാലഹരണ തീയതി ചേർക്കുക',
      nepali: 'राहदानी समाप्ति मिति थप्नुहोस्',
      bengali: 'পাসপোর্টের মেয়াদ শেষ হওয়ার তারিখ যোগ করুন',
      tamil: 'பாஸ்போர்ட் காலாவதி தேதியைச் சேர்க்கவும்',
      filipino: 'Magdagdag ng petsa ng pag-expire ng pasaporte',
    ),
    'improve_passport_desc': l10nEntry(
      english: 'Never miss a renewal deadline',
      arabic: 'لا تفوت موعد التجديد',
      hindi: 'नवीनीकरण की समय सीमा कभी न चूकें',
      urdu: 'کبھی بھی تجدید کی آخری تاریخ مت چھوڑیں۔',
      malayalam: 'പുതുക്കൽ സമയപരിധി ഒരിക്കലും നഷ്‌ടപ്പെടുത്തരുത്',
      nepali: 'नविकरण समय सीमा कहिल्यै नबिर्सनुहोस्',
      bengali: 'একটি পুনর্নবীকরণ সময়সীমা মিস করবেন না',
      tamil: 'புதுப்பித்தல் காலக்கெடுவை ஒருபோதும் தவறவிடாதீர்கள்',
      filipino: 'Huwag kailanman palampasin ang isang deadline ng pag-renew',
    ),
    'improve_refer_title': l10nEntry(
      english: 'Refer a friend to Raabta',
      arabic: 'أحِل صديقاً إلى Raabta',
      hindi: 'राब्ता के लिए किसी मित्र को रेफर करें',
      urdu: 'کسی دوست کو Raabta سے رجوع کریں۔',
      malayalam: 'ഒരു സുഹൃത്തിനെ റാബ്തയിലേക്ക് റഫർ ചെയ്യുക',
      nepali: 'Raabta को एक साथीलाई सन्दर्भ गर्नुहोस्',
      bengali: 'রাবতার কাছে একজন বন্ধুকে রেফার করুন',
      tamil: 'ராப்தாவுக்கு ஒரு நண்பரைப் பரிந்துரைக்கவும்',
      filipino: 'Sumangguni sa isang kaibigan sa Raabta',
    ),
    'improve_refer_desc': l10nEntry(
      english: 'Earn points — {remaining} more referrals to unlock Ambassador',
      arabic: 'اكسب نقاط — {remaining} إحالات إضافية لفتح Ambassador',
      hindi: 'अंक कमाएँ — Ambassador अनलॉक करने के लिए {remaining} और रेफरल',
      urdu: 'پوائنٹس کمائیں — Ambassador کے لیے {remaining} مزید ریفرلز',
      malayalam:
          'പോയിൻ്റുകൾ നേടൂ — Ambassador അൺലോക്ക് ചെയ്യാൻ {remaining} റഫറലുകൾ കൂടി',
      nepali: 'अंक कमाउनुहोस् — Ambassador अनलक गर्न {remaining} थप रेफरल',
      bengali:
          'পয়েন্ট অর্জন করুন — Ambassador আনলক করতে আরও {remaining} রেফারেল',
      tamil:
          'புள்ளிகள் பெறுங்கள் — Ambassador திறக்க இன்னும் {remaining} பரிந்துரைகள்',
      filipino:
          'Kumita ng puntos — {remaining} pang referral para i-unlock ang Ambassador',
    ),
    'advice_unlock_profile': l10nEntry(
      english:
          'Complete your profile and Raabta tools to unlock a personalized score.',
      arabic: 'أكمل ملفك وأدوات Raabta لفتح درجة مخصصة.',
      hindi:
          'वैयक्तिकृत स्कोर अनलॉक करने के लिए अपना प्रोफ़ाइल और राबता टूल पूरा करें।',
      urdu:
          'ذاتی اسکورز کو غیر مقفل کرنے کے لیے اپنا پروفائل اور Raabta ٹول مکمل کریں۔',
      malayalam:
          'വ്യക്തിഗതമാക്കിയ സ്കോർ അൺലോക്ക് ചെയ്യുന്നതിന് നിങ്ങളുടെ പ്രൊഫൈലും റാബ്ത ടൂളുകളും പൂർത്തിയാക്കുക.',
      nepali:
          'एक व्यक्तिगत स्कोर अनलक गर्न आफ्नो प्रोफाइल र Raabta उपकरणहरू पूरा गर्नुहोस्।',
      bengali:
          'একটি ব্যক্তিগতকৃত স্কোর আনলক করতে আপনার প্রোফাইল এবং Raabta সরঞ্জামগুলি সম্পূর্ণ করুন৷',
      tamil:
          'தனிப்பயனாக்கப்பட்ட ஸ்கோரைத் திறக்க உங்கள் சுயவிவரத்தையும் ராப்தா கருவிகளையும் பூர்த்தி செய்யவும்.',
      filipino:
          'Kumpletuhin ang iyong profile at mga tool sa Raabta para mag-unlock ng personalized na marka.',
    ),
    'advice_category_attention': l10nEntry(
      english: '{category} needs attention: {why}',
      arabic: '{category} يحتاج اهتماماً: {why}',
      hindi: '{श्रेणी} पर ध्यान देने की आवश्यकता है: {क्यों} {category} {why}',
      urdu: '{زمرہ} توجہ کی ضرورت ہے: {کیوں} {زمرہ} {کیوں} {category} {why}',
      malayalam: '{category}-ന് ശ്രദ്ധ ആവശ്യമാണ്: {എന്തുകൊണ്ട്} {why}',
      nepali: '{श्रेणी} लाई ध्यान चाहिन्छ: {किन} {category} {why}',
      bengali: '{category} মনোযোগ দিতে হবে: {কেন} {why}',
      tamil: '{category} கவனம் தேவை: {ஏன்} {why}',
      filipino: 'Kailangan ng {category} ng pansin: {why}',
    ),
    'advice_low_confidence': l10nEntry(
      english:
          '{category} confidence is reduced until you resolve a data mismatch between Raabta tools.',
      arabic: 'ثقة {category} منخفضة حتى تحل تناقض البيانات بين أدوات Raabta.',
      hindi:
          'जब तक आप राब्ता टूल के बीच डेटा बेमेल का समाधान नहीं कर लेते, तब तक {श्रेणी} का विश्वास कम हो जाता है। {category}',
      urdu:
          'جب تک آپ Rabta ٹولز کے درمیان ڈیٹا کی مماثلت کو حل نہیں کرتے، {category} کا اعتماد کم ہو جاتا ہے۔ {زمرہ}',
      malayalam:
          'Raabta ടൂളുകൾ തമ്മിലുള്ള ഡാറ്റ പൊരുത്തക്കേട് നിങ്ങൾ പരിഹരിക്കുന്നത് വരെ {category} ആത്മവിശ്വാസം കുറയും.',
      nepali:
          'तपाईंले Raabta उपकरणहरू बीचको डेटा बेमेल समाधान नगरेसम्म {श्रेणी} आत्मविश्वास कम हुन्छ। {category}',
      bengali:
          'আপনি Raabta টুলের মধ্যে ডেটার অমিল সমাধান না করা পর্যন্ত {category} আত্মবিশ্বাস কমে যাবে।',
      tamil:
          'Raabta கருவிகளுக்கு இடையே உள்ள தரவு பொருத்தமின்மையை நீங்கள் தீர்க்கும் வரை {category} நம்பிக்கை குறைக்கப்படும்.',
      filipino:
          'Nababawasan ang kumpiyansa ng {category} hanggang sa malutas mo ang hindi pagkakatugma ng data sa pagitan ng mga tool ng Raabta.',
    ),
    'advice_add_signals': l10nEntry(
      english:
          'Add {category} signals in Raabta — we need more data before scoring this category.',
      arabic:
          'أضف إشارات {category} في Raabta — نحتاج المزيد من البيانات قبل تقييم هذه الفئة.',
      hindi:
          'राब्ता में {श्रेणी} सिग्नल जोड़ें - इस श्रेणी को स्कोर करने से पहले हमें अधिक डेटा की आवश्यकता है। {category}',
      urdu:
          'Raabta میں {category} سگنل شامل کریں - ہمیں اس زمرے کو اسکور کرنے سے پہلے مزید ڈیٹا کی ضرورت ہے۔ {زمرہ}',
      malayalam:
          'Raabta-യിൽ {category} സിഗ്നലുകൾ ചേർക്കുക - ഈ വിഭാഗം സ്കോർ ചെയ്യുന്നതിന് മുമ്പ് ഞങ്ങൾക്ക് കൂടുതൽ ഡാറ്റ ആവശ്യമാണ്.',
      nepali:
          'Raabta मा {श्रेणी} संकेतहरू थप्नुहोस् — हामीलाई यो श्रेणी स्कोर गर्नु अघि थप डेटा चाहिन्छ। {category}',
      bengali:
          'রাবতাতে {বিভাগের} সংকেত যোগ করুন — এই বিভাগে স্কোর করার আগে আমাদের আরও ডেটা দরকার। {category}',
      tamil:
          'Raabta இல் {category} சிக்னல்களைச் சேர்க்கவும் — இந்த வகையைப் பெறுவதற்கு முன் எங்களுக்கு கூடுதல் தரவு தேவை.',
      filipino:
          'Magdagdag ng mga signal ng {category} sa Raabta — kailangan namin ng higit pang data bago i-iskor ang kategoryang ito.',
    ),
    'advice_category_low': l10nEntry(
      english: 'Your {category} score is {pct}%. {action} could help fastest.',
      arabic: 'درجة {category} هي {pct}%. {action} قد يساعدك أسرع.',
      hindi:
          'आपका {श्रेणी} स्कोर {पीसीटी}% है। {क्रिया} सबसे तेजी से मदद कर सकता है। {category} {pct} {action}',
      urdu:
          'آپ کا {category} اسکور {pct}% ہے۔ {فعل} تیزی سے مدد کر سکتا ہے۔ {زمرہ} {pct} {کارروائی} {action}',
      malayalam:
          'നിങ്ങളുടെ {category} സ്കോർ {pct}% ആണ്. {action} വേഗത്തിൽ സഹായിച്ചേക്കാം.',
      nepali:
          'तपाईको {category} स्कोर {pct}% हो। {action} ले सबैभन्दा छिटो मद्दत गर्न सक्छ।',
      bengali:
          'আপনার {category} স্কোর হল {pct}%। {action} দ্রুত সাহায্য করতে পারে।',
      tamil: 'உங்கள் {category} மதிப்பெண் {pct}%. {action} வேகமாக உதவக்கூடும்.',
      filipino:
          'Ang iyong {category} na marka ay {pct}%. Maaaring makatulong ang {action} nang pinakamabilis.',
    ),
    'advice_category_grow': l10nEntry(
      english:
          'Your {category} category has the most room to grow — start with {action}.',
      arabic: 'فئة {category} لديها أكبر مجال للنمو — ابدأ بـ {action}.',
      hindi:
          'आपकी {श्रेणी} श्रेणी में बढ़ने की सबसे अधिक गुंजाइश है - {कार्रवाई} से शुरू करें। {category} {action}',
      urdu:
          'اس {action} کے ساتھ شروع کریں جس میں آپ کے {category} زمرے میں بڑھنے کی سب سے زیادہ گنجائش ہے۔ {زمرہ} {کارروائی}',
      malayalam:
          'നിങ്ങളുടെ {category} വിഭാഗത്തിന് വളരാൻ ഏറ്റവും കൂടുതൽ ഇടമുണ്ട് — {action} ഉപയോഗിച്ച് ആരംഭിക്കുക.',
      nepali:
          'तपाईको {श्रेणी} कोटिमा बढ्नको लागि सबैभन्दा धेरै ठाउँ छ — {action} बाट सुरु गर्नुहोस्। {category}',
      bengali:
          'আপনার {category} বিভাগে বাড়তে সবচেয়ে বেশি জায়গা আছে — {action} দিয়ে শুরু করুন।',
      tamil:
          'உங்கள் {category} வகை வளர அதிக இடம் உள்ளது — {action} உடன் தொடங்கவும்.',
      filipino:
          'Ang iyong kategoryang {category} ay may pinakamaraming puwang na lalago — magsimula sa {action}.',
    ),
    'advice_weekly_up': l10nEntry(
      english:
          'Your score rose {delta} points this week — keep the momentum going.',
      arabic: 'ارتفعت درجتك {delta} نقطة هذا الأسبوع — حافظ على الزخم.',
      hindi: 'इस सप्ताह आपका स्कोर {डेल्टा} अंक बढ़ा - गति जारी रखें। {delta}',
      urdu:
          'اس ہفتے آپ کے سکور میں {delta} پوائنٹس کا اضافہ ہوا ہے - رفتار کو جاری رکھیں۔ {ڈیلٹا}',
      malayalam:
          'ഈ ആഴ്‌ച നിങ്ങളുടെ സ്‌കോർ {ഡെൽറ്റ} പോയിൻ്റ് ഉയർന്നു — ആക്കം തുടരുക. {delta}',
      nepali: 'यो हप्ता तपाईंको स्कोर {delta} अंक बढ्यो — गति जारी राख्नुहोस्।',
      bengali:
          'এই সপ্তাহে আপনার স্কোর {ডেল্টা} পয়েন্ট বেড়েছে — গতি বজায় রাখুন। {delta}',
      tamil:
          'இந்த வாரம் உங்கள் ஸ்கோர் {டெல்டா} புள்ளிகள் உயர்ந்துள்ளது — வேகத்தைத் தொடரவும். {delta}',
      filipino:
          'Tumaas ng {delta} puntos ang iyong iskor ngayong linggo — ipagpatuloy ang momentum.',
    ),
    'advice_on_track': l10nEntry(
      english:
          'You are on track. Small profile and tool updates still add points over time.',
      arabic:
          'أنت على المسار الصحيح. التحديثات الصغيرة للملف والأدوات تضيف نقاطاً مع الوقت.',
      hindi:
          'आप सही रास्ते पर हैं. छोटी प्रोफ़ाइल और टूल अपडेट अभी भी समय के साथ अंक जोड़ते हैं।',
      urdu:
          'آپ صحیح راستے پر ہیں۔ چھوٹے پروفائل اور ٹول اپ ڈیٹس اب بھی وقت کے ساتھ ساتھ پوائنٹس میں اضافہ کرتے ہیں۔',
      malayalam:
          'നിങ്ങൾ ട്രാക്കിലാണ്. ചെറിയ പ്രൊഫൈലും ടൂൾ അപ്‌ഡേറ്റുകളും കാലക്രമേണ പോയിൻ്റുകൾ ചേർക്കുന്നു.',
      nepali:
          'तपाईं ट्रयाकमा हुनुहुन्छ। सानो प्रोफाइल र उपकरण अद्यावधिकहरूले अझै पनि समयको साथ अंकहरू थप्छन्।',
      bengali:
          'আপনি ট্র্যাক আছে. ছোট প্রোফাইল এবং টুল আপডেট এখনও সময়ের সাথে পয়েন্ট যোগ করে।',
      tamil:
          'நீங்கள் பாதையில் இருக்கிறீர்கள். சிறிய சுயவிவரம் மற்றும் கருவி புதுப்பிப்புகள் காலப்போக்கில் புள்ளிகளைச் சேர்க்கின்றன.',
      filipino:
          'Ikaw ay nasa landas. Ang maliit na profile at mga update sa tool ay nagdaragdag pa rin ng mga puntos sa paglipas ng panahon.',
    ),
    'advice_default_empty': l10nEntry(
      english: 'Complete your profile to unlock personalized score advice.',
      arabic: 'أكمل ملفك لفتح نصائح درجة مخصصة.',
      hindi:
          'वैयक्तिकृत स्कोर सलाह अनलॉक करने के लिए अपना प्रोफ़ाइल पूरा करें।',
      urdu:
          'ذاتی اسکور کے مشورے کو غیر مقفل کرنے کے لیے اپنا پروفائل مکمل کریں۔',
      malayalam:
          'വ്യക്തിഗത സ്കോർ ഉപദേശം അൺലോക്ക് ചെയ്യാൻ നിങ്ങളുടെ പ്രൊഫൈൽ പൂർത്തിയാക്കുക.',
      nepali: 'व्यक्तिगत स्कोर सल्लाह अनलक गर्न आफ्नो प्रोफाइल पूरा गर्नुहोस्।',
      bengali:
          'ব্যক্তিগতকৃত স্কোর পরামর্শ আনলক করতে আপনার প্রোফাইল সম্পূর্ণ করুন।',
      tamil:
          'தனிப்பயனாக்கப்பட்ட மதிப்பெண் ஆலோசனையைத் திறக்க உங்கள் சுயவிவரத்தை முடிக்கவும்.',
      filipino:
          'Kumpletuhin ang iyong profile upang i-unlock ang personalized na payo sa marka.',
    ),
    'gap_housing_action': l10nEntry(
      english: 'Browse housing listings or set your preferred area',
      arabic: 'تصفح قوائم السكن أو حدّد منطقتك المفضلة',
      hindi: 'आवास सूची ब्राउज़ करें या अपना पसंदीदा क्षेत्र निर्धारित करें',
      urdu: 'رہائش کی فہرستیں براؤز کریں یا اپنی پسند کا علاقہ سیٹ کریں۔',
      malayalam:
          'ഭവന ലിസ്റ്റിംഗുകൾ ബ്രൗസ് ചെയ്യുക അല്ലെങ്കിൽ നിങ്ങൾക്ക് ഇഷ്ടപ്പെട്ട പ്രദേശം സജ്ജമാക്കുക',
      nepali:
          'आवास सूचीहरू ब्राउज गर्नुहोस् वा आफ्नो मनपर्ने क्षेत्र सेट गर्नुहोस्',
      bengali: 'হাউজিং তালিকা ব্রাউজ করুন বা আপনার পছন্দের এলাকা সেট করুন',
      tamil:
          'வீட்டுப் பட்டியலை உலாவவும் அல்லது உங்களுக்கு விருப்பமான பகுதியை அமைக்கவும்',
      filipino:
          'Mag-browse ng mga listahan ng pabahay o itakda ang iyong gustong lugar',
    ),
    'gap_community_action': l10nEntry(
      english: 'Join a community group or post in Community',
      arabic: 'انضم إلى مجموعة أو انشر في Community',
      hindi: 'किसी सामुदायिक समूह में शामिल हों या समुदाय में पोस्ट करें',
      urdu: 'کمیونٹی گروپ میں شامل ہوں یا کمیونٹی میں پوسٹ کریں۔',
      malayalam:
          'ഒരു കമ്മ്യൂണിറ്റി ഗ്രൂപ്പിൽ ചേരുക അല്ലെങ്കിൽ കമ്മ്യൂണിറ്റിയിൽ പോസ്റ്റ് ചെയ്യുക',
      nepali: 'सामुदायिक समूहमा सामेल हुनुहोस् वा समुदायमा पोस्ट गर्नुहोस्',
      bengali: 'কমিউনিটি গ্রুপে যোগ দিন বা কমিউনিটিতে পোস্ট করুন',
      tamil: 'சமூகக் குழுவில் சேரவும் அல்லது சமூகத்தில் இடுகையிடவும்',
      filipino: 'Sumali sa isang grupo ng komunidad o mag-post sa Komunidad',
    ),
    'gap_category_action': l10nEntry(
      english: 'Add more {category} data in Raabta',
      arabic: 'أضف المزيد من بيانات {category} في Raabta',
      hindi: 'राबता में और अधिक {श्रेणी} डेटा जोड़ें {category}',
      urdu: 'Raabta {category} میں مزید {category} ڈیٹا شامل کریں',
      malayalam: 'Raabta-യിൽ കൂടുതൽ {category} ഡാറ്റ ചേർക്കുക',
      nepali: 'Raabta मा थप {श्रेणी} डेटा थप्नुहोस् {category}',
      bengali: 'রাবতাতে আরও {শ্রেণীর} ডেটা যোগ করুন {category}',
      tamil: 'Raabta இல் மேலும் {category} தரவைச் சேர்க்கவும்',
      filipino: 'Magdagdag ng higit pang {category} data sa Raabta',
    ),
    'community_group_fallback': l10nEntry(
      english: 'your community',
      arabic: 'مجتمعك',
      hindi: 'आपका समुदाय',
      urdu: 'آپ کی کمیونٹی',
      malayalam: 'നിങ്ങളുടെ സമൂഹം',
      nepali: 'आफ्नो समुदाय',
      bengali: 'আপনার সম্প্রদায়',
      tamil: 'உங்கள் சமூகம்',
      filipino: 'iyong komunidad',
    ),
  };
}
