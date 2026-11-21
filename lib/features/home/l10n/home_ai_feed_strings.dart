import 'package:flutter/foundation.dart';
import 'package:raabta/core/l10n/app_locale.dart';
import 'package:raabta/core/l10n/locale_catalog_coverage.dart';
import 'package:raabta/core/l10n/locale_catalog_entry.dart';

/// Static templates for [AIFeedEngine] cards — data fields stay interpolated.
abstract final class HomeAiFeedStrings {
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
    'feed_job_title': l10nEntry(
      english: '💼 {count} jobs match your profile',
      arabic: '💼 {count} وظائف تناسب ملفك',
      hindi: '💼 {गिनती} नौकरियाँ आपकी प्रोफ़ाइल से मेल खाती हैं {count}',
      urdu: '💼 {count} آپ کے پروفائل سے مماثل ملازمتیں {count}',
      malayalam: '💼 {count} ജോലികൾ നിങ്ങളുടെ പ്രൊഫൈലുമായി പൊരുത്തപ്പെടുന്നു',
      nepali: '💼 {count} कार्यहरू तपाईंको प्रोफाइलसँग मेल खान्छ',
      bengali: '💼 {count}টি চাকরি আপনার প্রোফাইলের সাথে মেলে',
      tamil: '💼 {count} வேலைகள் உங்கள் சுயவிவரத்துடன் பொருந்துகின்றன',
      filipino: '💼 {count} mga trabaho ang tumutugma sa iyong profile',
    ),
    'feed_job_subtitle': l10nEntry(
      english: 'Best: {title} at {company} — {match}% match',
      arabic: 'الأفضل: {title} في {company} — تطابق {match}%',
      hindi:
          'सर्वोत्तम: {शीर्षक} {कंपनी} पर - {मिलान}% मिलान {title} {company} {match}',
      urdu:
          'بہترین: {title} {company} at - {match} % match {title} {company} {match}',
      malayalam: 'മികച്ചത്: {company}-ൽ {title} — {match}% പൊരുത്തം',
      nepali: 'उत्कृष्ट: {title} मा {company} — {match}% मिलान',
      bengali: 'সেরা: {title} এ {company} — {match}% মিল',
      tamil: 'சிறந்தது: {company} இல் {title} — {match}% பொருத்தம்',
      filipino: 'Pinakamahusay: {title} sa {company} — {match}% match',
    ),
    'feed_job_cta': l10nEntry(
      english: 'View Jobs',
      arabic: 'عرض الوظائف',
      hindi: 'नौकरियां देखें',
      urdu: 'نوکریاں دیکھیں',
      malayalam: 'ജോലികൾ കാണുക',
      nepali: 'कार्यहरू हेर्नुहोस्',
      bengali: 'চাকরি দেখুন',
      tamil: 'வேலைகளைப் பார்க்கவும்',
      filipino: 'Tingnan ang Mga Trabaho',
    ),
    'feed_job_fallback_title': l10nEntry(
      english: 'Recommended role',
      arabic: 'دور موصى به',
      hindi: 'अनुशंसित भूमिका',
      urdu: 'تجویز کردہ کردار',
      malayalam: 'ശുപാർശ ചെയ്യുന്ന റോൾ',
      nepali: 'सिफारिस गरिएको भूमिका',
      bengali: 'প্রস্তাবিত ভূমিকা',
      tamil: 'பரிந்துரைக்கப்பட்ட பாத்திரம்',
      filipino: 'Inirerekomendang tungkulin',
    ),
    'feed_job_fallback_company': l10nEntry(
      english: 'Qatar employer',
      arabic: 'صاحب عمل في قطر',
      hindi: 'कतर नियोक्ता',
      urdu: 'قطر آجر',
      malayalam: 'ഖത്തർ തൊഴിലുടമ',
      nepali: 'कतार रोजगारदाता',
      bengali: 'কাতার নিয়োগকর্তা',
      tamil: 'கத்தார் முதலாளி',
      filipino: 'Home AI feed card: Qatar employer',
    ),
    'feed_housing_title': l10nEntry(
      english: '🏠 {count} new rooms in {area}',
      arabic: '🏠 {count} غرف جديدة في {area}',
      hindi: '🏠 {क्षेत्र} में नए कमरे {गिनें} {count} {area}',
      urdu: '🏠 {count} نئے کمرے {area} {count} {area} میں',
      malayalam: '🏠 {count} പുതിയ മുറികൾ {ഏരിയയിൽ} {area}',
      nepali: '{क्षेत्र} मा 🏠 {count} नयाँ कोठाहरू {area}',
      bengali: '🏠 {count}টি {এরিয়া} এ নতুন রুম {area}',
      tamil: '🏠 {count} {area} இல் புதிய அறைகள்',
      filipino: '🏠 {count} bagong kwarto sa {area}',
    ),
    'feed_housing_subtitle': l10nEntry(
      english: 'Best match: {type} at {price} QR/month — {match}%',
      arabic: 'أفضل تطابق: {type} بـ {price} ر.ق/شهر — {match}%',
      hindi:
          'सर्वोत्तम मिलान: {प्रकार} पर {मूल्य} क्यूआर/माह - {मिलान}% {type} {price} {match}',
      urdu:
          'بہترین میچ: {price} پر {type} QR/ماہ - {match} % {type} {price} {match}',
      malayalam: 'മികച്ച പൊരുത്തം: {type} {price} QR/മാസം — {match}%',
      nepali: 'उत्कृष्ट मिलान: {type} मा {price} QR/महिना — {match}%',
      bengali: 'সেরা মিল: {type} এ {price} QR/মাস — {match}%',
      tamil: 'சிறந்த பொருத்தம்: {type}, {price} QR/மாதம் — {match}%',
      filipino: 'Pinakamahusay na tugma: {type} sa {price} QR/buwan — {match}%',
    ),
    'feed_housing_cta': l10nEntry(
      english: 'View Housing',
      arabic: 'عرض السكن',
      hindi: 'आवास देखें',
      urdu: 'رہائش دیکھیں',
      malayalam: 'ഭവനം കാണുക',
      nepali: 'आवास हेर्नुहोस्',
      bengali: 'হাউজিং দেখুন',
      tamil: 'வீட்டுவசதி பார்க்கவும்',
      filipino: 'Tingnan ang Pabahay',
    ),
    'feed_property_fallback': l10nEntry(
      english: 'Property',
      arabic: 'عقار',
      hindi: 'संपत्ति',
      urdu: 'جائیداد',
      malayalam: 'സ്വത്ത്',
      nepali: 'सम्पत्ति',
      bengali: 'সম্পত্তি',
      tamil: 'சொத்து',
      filipino: 'Ari-arian',
    ),
    'feed_exchange_title_up': l10nEntry(
      english: '💰 INR rate increased today',
      arabic: '💰 ارتفع سعر الروبية الهندية اليوم',
      hindi: '💰 INR दर में आज वृद्धि हुई',
      urdu: '💰 آج INR کی شرح میں اضافہ ہوا۔',
      malayalam: '💰 INR നിരക്ക് ഇന്ന് വർദ്ധിച്ചു',
      nepali: '💰 INR दर आज बढ्यो',
      bengali: '💰 আজ INR রেট বেড়েছে',
      tamil: '💰 INR விகிதம் இன்று அதிகரித்துள்ளது',
      filipino: '💰 Tumaas ang rate ng INR ngayon',
    ),
    'feed_exchange_title_down': l10nEntry(
      english: '💰 INR rate decreased today',
      arabic: '💰 انخفض سعر الروبية الهندية اليوم',
      hindi: '💰 INR दर में आज कमी आई',
      urdu: '💰 INR کی شرح آج کم ہو گئی۔',
      malayalam: '💰 INR നിരക്ക് ഇന്ന് കുറഞ്ഞു',
      nepali: '💰 INR दर आज घट्यो',
      bengali: '💰 আজ INR রেট কমেছে',
      tamil: '💰 INR விகிதம் இன்று குறைந்துள்ளது',
      filipino: '💰 Bumaba ang rate ng INR ngayon',
    ),
    'feed_exchange_subtitle': l10nEntry(
      english: '1 QR = {rate} INR {arrow}{change}',
      arabic: '1 ر.ق = {rate} INR {arrow}{change}',
      hindi: '1 QR = {दर} INR {तीर} {परिवर्तन} {rate} {arrow} {change}',
      urdu: '1 QR = {rate} INR {arrow} {change} {rate} {arrow} {change}',
      malayalam: 'ഹോം AI ഫീഡ് കാർഡ്: 1 QR = {rate} INR {arrow}{change}',
      nepali: '1 QR = {दर} INR {arrow}{change} {rate}',
      bengali: '1 QR = {রেট} INR {arrow}{change} {rate}',
      tamil: 'முகப்பு AI ஊட்ட அட்டை: 1 QR = {rate} INR {arrow}{change}',
      filipino: 'Home AI feed card: 1 QR = {rate} INR {arrow}{change}',
    ),
    'feed_exchange_cta': l10nEntry(
      english: 'Check Rates',
      arabic: 'تحقق من الأسعار',
      hindi: 'दरें चेक कीजिए',
      urdu: 'نرخوں کو چیک کریں۔',
      malayalam: 'നിരക്കുകൾ പരിശോധിക്കുക',
      nepali: 'दरहरू जाँच गर्नुहोस्',
      bengali: 'রেট চেক করুন',
      tamil: 'விகிதங்களை சரிபார்க்கவும்',
      filipino: 'Suriin ang mga Rate',
    ),
    'feed_visa_title': l10nEntry(
      english: '📋 New Qatar visa update',
      arabic: '📋 تحديث جديد لتأشيرة قطر',
      hindi: '📋नया कतर वीज़ा अपडेट',
      urdu: '📋قطر ویزا کی نئی اپڈیٹ',
      malayalam: '📋 പുതിയ ഖത്തർ വിസ അപ്ഡേറ്റ്',
      nepali: '📋 नयाँ कतार भिसा अपडेट',
      bengali: '📋 কাতারের নতুন ভিসা আপডেট',
      tamil: '📋 புதிய கத்தார் விசா புதுப்பிப்பு',
      filipino: '📋 Bagong Qatar visa update',
    ),
    'feed_visa_subtitle': l10nEntry(
      english: '{title} — {date}',
      arabic: '{العنوان} — {التاريخ} {title} {date}',
      hindi: '{शीर्षक} — {तारीख} {title} {date}',
      urdu: '{title} — {date} {title} {date}',
      malayalam: 'ഹോം AI ഫീഡ് കാർഡ്: {title} — {date}',
      nepali: 'Home AI फिड कार्ड: {title} — {date}',
      bengali: '{title} — {তারিখ} {date}',
      tamil: 'முகப்பு AI ஊட்ட அட்டை: {title} — {date}',
      filipino: 'Home AI feed card: {title} — {date}',
    ),
    'feed_visa_cta': l10nEntry(
      english: 'Read Update',
      arabic: 'قراءة التحديث',
      hindi: 'अद्यतन पढ़ें',
      urdu: 'اپ ڈیٹس پڑھیں',
      malayalam: 'അപ്‌ഡേറ്റ് വായിക്കുക',
      nepali: 'अपडेट पढ्नुहोस्',
      bengali: 'আপডেট পড়ুন',
      tamil: 'புதுப்பிப்பைப் படிக்கவும்',
      filipino: 'Basahin ang Update',
    ),
    'feed_visa_fallback': l10nEntry(
      english: 'Visa policy update',
      arabic: 'تحديث سياسة التأشيرة',
      hindi: 'वीज़ा नीति अद्यतन',
      urdu: 'ویزا پالیسی اپ ڈیٹ',
      malayalam: 'വിസ നയം അപ്ഡേറ്റ്',
      nepali: 'भिसा नीति अपडेट',
      bengali: 'ভিসা নীতি আপডেট',
      tamil: 'விசா கொள்கை புதுப்பிப்பு',
      filipino: 'Update sa patakaran ng visa',
    ),
    'feed_event_title': l10nEntry(
      english: '🎉 {name} this {day}',
      arabic: '🎉 {name} {day}',
      hindi: '🎉 {name} — {day}',
      urdu: '🎉 {name} — {day}',
      malayalam: '🎉 {name} — {day}',
      nepali: '🎉 {name} — {day}',
      bengali: '🎉 {name} — {day}',
      tamil: '🎉 {name} — {day}',
      filipino: '🎉 {name} ngayong {day}',
    ),
    'feed_event_subtitle': l10nEntry(
      english: '{location} · {community} Community · {price}',
      arabic: '{location} · مجتمع {community} · {price}',
      hindi:
          '{स्थान} · {समुदाय} समुदाय · {कीमत} {location} {community} {price}',
      urdu:
          '{location} {community} کمیونٹی · {price} {location} {community} {price}',
      malayalam: '{location} · {community} കമ്മ്യൂണിറ്റി · {price}',
      nepali:
          '{स्थान} · {समुदाय} समुदाय · {मूल्य} {location} {community} {price}',
      bengali:
          '{অবস্থান} · {সম্প্রদায়} সম্প্রদায় · {মূল্য} {location} {community} {price}',
      tamil: '{location} · {community} சமூகம் · {price}',
      filipino:
          'Home AI feed card: {location} · {community} Community · {price}',
    ),
    'feed_event_cta': l10nEntry(
      english: 'Join Event',
      arabic: 'انضم إلى الفعالية',
      hindi: 'इवेंट में शामिल हों',
      urdu: 'تقریب میں شامل ہوں',
      malayalam: 'ഇവൻ്റിൽ ചേരുക',
      nepali: 'कार्यक्रममा सामेल हुनुहोस्',
      bengali: 'ইভেন্টে যোগ দিন',
      tamil: 'நிகழ்வில் சேரவும்',
      filipino: 'Sumali sa Kaganapan',
    ),
    'feed_event_fallback_name': l10nEntry(
      english: 'Community event',
      arabic: 'فعالية مجتمعية',
      hindi: 'सामुदायिक आयोजन',
      urdu: 'کمیونٹی ایونٹ',
      malayalam: 'കമ്മ്യൂണിറ്റി ഇവൻ്റ്',
      nepali: 'सामुदायिक कार्यक्रम',
      bengali: 'কমিউনিটি ইভেন্ট',
      tamil: 'சமூக நிகழ்வு',
      filipino: 'Kaganapan sa komunidad',
    ),
    'feed_price_free': l10nEntry(
      english: 'Free',
      arabic: 'مجاني',
      hindi: 'मुक्त',
      urdu: 'مفت',
      malayalam: 'സൗജന്യം',
      nepali: 'नि:शुल्क',
      bengali: 'বিনামূল্যে',
      tamil: 'இலவசம்',
      filipino: 'Libre',
    ),
    'feed_day_today': l10nEntry(
      english: 'today',
      arabic: 'اليوم',
      hindi: 'आज',
      urdu: 'آج',
      malayalam: 'ഇന്ന്',
      nepali: 'आज',
      bengali: 'আজ',
      tamil: 'இன்று',
      filipino: 'ngayon',
    ),
    'feed_day_tomorrow': l10nEntry(
      english: 'tomorrow',
      arabic: 'غداً',
      hindi: 'कल',
      urdu: 'کل',
      malayalam: 'നാളെ',
      nepali: 'भोलि',
      bengali: 'আগামীকাল',
      tamil: 'நாளை',
      filipino: 'bukas',
    ),
    'feed_day_week': l10nEntry(
      english: 'week',
      arabic: 'هذا الأسبوع',
      hindi: 'सप्ताह',
      urdu: 'ہفتہ',
      malayalam: 'ആഴ്ച',
      nepali: 'हप्ता',
      bengali: 'সপ্তাহ',
      tamil: 'வாரம்',
      filipino: 'linggo',
    ),
    'feed_score_title': l10nEntry(
      english: '⭐ Improve your Expat Score by +{points} points',
      arabic: '⭐ حسّن درجة Expat Score بـ +{points} نقطة',
      hindi: '⭐ अपने प्रवासी स्कोर में +{अंक} अंकों से सुधार करें {points}',
      urdu: '⭐ اپنے غیر ملکی اسکور کو +{پوائنٹس} سے بہتر بنائیں {points}',
      malayalam:
          '⭐ നിങ്ങളുടെ എക്‌സ്‌പാറ്റ് സ്‌കോർ +{പോയിൻ്റ്} പോയിൻ്റുകൾ കൊണ്ട് മെച്ചപ്പെടുത്തുക {points}',
      nepali: '⭐ आफ्नो एक्स्प्याट स्कोर +{points} अंकले सुधार गर्नुहोस्',
      bengali:
          '⭐ আপনার প্রবাসী স্কোর +{পয়েন্ট} পয়েন্ট দ্বারা উন্নত করুন {points}',
      tamil:
          '⭐ உங்கள் எக்ஸ்பாட் ஸ்கோரை +{புள்ளிகள்} புள்ளிகளால் மேம்படுத்தவும் {points}',
      filipino: '⭐ Pahusayin ang iyong Expat Score ng +{points} na puntos',
    ),
    'feed_referral_title': l10nEntry(
      english: '👥 Invite friends, earn 50 points each',
      arabic: '👥 ادعُ الأصدقاء واكسب 50 نقطة لكل دعوة',
      hindi: '👥 मित्रों को आमंत्रित करें, प्रत्येक 50 अंक अर्जित करें',
      urdu: '👥 دوستوں کو مدعو کریں، ہر ایک کو 50 پوائنٹس حاصل کریں۔',
      malayalam: '👥 സുഹൃത്തുക്കളെ ക്ഷണിക്കൂ, 50 പോയിൻ്റുകൾ വീതം നേടൂ',
      nepali: '👥 साथीहरूलाई आमन्त्रित गर्नुहोस्, प्रत्येक 50 अंक कमाउनुहोस्',
      bengali: '👥 বন্ধুদের আমন্ত্রণ জানান, প্রত্যেকে 50 পয়েন্ট অর্জন করুন',
      tamil: '👥 நண்பர்களை அழையுங்கள், தலா 50 புள்ளிகளைப் பெறுங்கள்',
      filipino: '👥 Mag-imbita ng mga kaibigan, kumita ng 50 puntos bawat isa',
    ),
    'feed_referral_sub_premium': l10nEntry(
      english:
          'You\'ve invited {count} friends. {remaining} more to unlock Premium free!',
      arabic: 'دعوت {count} أصدقاء. {remaining} إضافيين لفتح Premium مجاناً!',
      hindi:
          'आपने {count} मित्रों को आमंत्रित किया। Premium मुफ्त अनलॉक करने के लिए {remaining} और चाहिए!',
      urdu:
          'آپ نے {count} دوستوں کو مدعو کیا۔ Premium مفت کے لیے {remaining} مزید درکار!',
      malayalam:
          'നിങ്ങൾ {count} സുഹൃത്തുക്കളെ ക്ഷണിച്ചു. Premium സൗജന്യമായി അൺലോക്ക് ചെയ്യാൻ {remaining} കൂടി!',
      nepali:
          'तपाईंले {count} साथीलाई आमन्त्रित गर्नुभयो। Premium निःशुल्क अनलक गर्न {remaining} थप!',
      bengali:
          'আপনি {count} বন্ধুকে আমন্ত্রণ জানিয়েছেন। Premium ফ্রি আনলক করতে আরও {remaining}!',
      tamil:
          'நீங்கள் {count} நண்பர்களை அழைத்தீர்கள். Premium இலவசமாக திறக்க இன்னும் {remaining}!',
      filipino:
          'Nag-imbita ka ng {count} kaibigan. {remaining} pa para i-unlock ang Premium nang libre!',
    ),
    'feed_referral_sub_boost': l10nEntry(
      english:
          'You\'ve invited {count} friends. When they complete EOSB, you both get +{extra} extra AI questions/day for {days} days.',
      arabic:
          'دعوت {count} أصدقاء. عند إكمال EOSB، تحصلان على +{extra} أسئلة AI إضافية/يوم لمدة {days} يوم.',
      hindi:
          'आपने मित्रों को आमंत्रित किया है। जब वे ईओएसबी पूरा कर लेते हैं, तो आप दोनों को दिनों के हिसाब से +अतिरिक्त एआई प्रश्न/दिन मिलते हैं। {count} {extra} {days}',
      urdu:
          'آپ نے دوستوں کو مدعو کیا ہے۔ جب وہ EOSB مکمل کرتے ہیں، تو آپ دونوں کو +اضافی AI سوالات/روزانہ ملتے ہیں۔ {count} {اضافی} {دن} {extra} {days}',
      malayalam:
          'നിങ്ങൾ {count} സുഹൃത്തുക്കളെ ക്ഷണിച്ചു. അവർ EOSB പൂർത്തിയാക്കുമ്പോൾ, നിങ്ങൾ രണ്ടുപേർക്കും {ദിവസം} ദിവസത്തേക്ക് +{എക്‌സ്‌ട്രാ} അധിക AI ചോദ്യങ്ങൾ/ദിവസം ലഭിക്കും. {extra} {days}',
      nepali:
          'तपाईंले {count} साथीहरूलाई आमन्त्रित गर्नुभएको छ। तिनीहरूले EOSB पूरा गर्दा, तपाईं दुवैले {दिन} दिनको लागि +{extra} अतिरिक्त AI प्रश्न/दिन प्राप्त गर्नुहुन्छ। {days}',
      bengali:
          'আপনি {count} জন বন্ধুকে আমন্ত্রণ জানিয়েছেন৷ যখন তারা EOSB সম্পূর্ণ করবে, তখন আপনি উভয়েই {দিন} দিনের জন্য +{অতিরিক্ত} অতিরিক্ত AI প্রশ্ন/দিন পাবেন। {extra} {days}',
      tamil:
          'நீங்கள் {count} நண்பர்களை அழைத்தீர்கள். அவர்கள் EOSBஐ முடித்ததும், நீங்கள் இருவரும் {days} நாட்களுக்கு +{extra} கூடுதல் AI கேள்விகள்/நாள் பெறுவீர்கள்.',
      filipino:
          'Nag-imbita ka ng {count} mga kaibigan. Kapag nakumpleto nila ang EOSB, pareho kayong makakakuha ng +{extra} karagdagang tanong sa AI/araw sa loob ng {days} na araw.',
    ),
    'feed_referral_cta': l10nEntry(
      english: 'Share Raabta',
      arabic: 'شارك Raabta',
      hindi: 'राब्ता शेयर करें',
      urdu: 'Raabta شیئر کریں۔',
      malayalam: 'Raabta പങ്കിടുക',
      nepali: 'Raabta सेयर गर्नुहोस्',
      bengali: 'রাবতা শেয়ার করুন',
      tamil: 'ராப்தாவைப் பகிரவும்',
      filipino: 'Ibahagi ang Raabta',
    ),
    'feed_welcome_title': l10nEntry(
      english: '👋 Welcome back to Raabta',
      arabic: '👋 مرحباً بعودتك إلى Raabta',
      hindi: '👋 राब्ता में आपका पुनः स्वागत है',
      urdu: '👋 Raabta میں دوبارہ خوش آمدید',
      malayalam: '👋 റാബ്തയിലേക്ക് തിരികെ സ്വാഗതം',
      nepali: '👋 Raabta मा फेरि स्वागत छ',
      bengali: '👋 রাবতাতে আবার স্বাগতম',
      tamil: '👋 ராப்தாவிற்கு மீண்டும் வரவேற்கிறோம்',
      filipino: '👋 Maligayang pagbabalik sa Raabta',
    ),
    'feed_welcome_subtitle': l10nEntry(
      english: 'Your personalized Qatar expat feed is ready',
      arabic: 'خلاصتك المخصصة للمغتربين في قطر جاهزة',
      hindi: 'आपका वैयक्तिकृत कतर प्रवासी फ़ीड तैयार है',
      urdu: 'آپ کی پرسنلائزڈ قطر ایکسپیٹ فیڈ تیار ہے۔',
      malayalam: 'നിങ്ങളുടെ വ്യക്തിപരമാക്കിയ ഖത്തർ പ്രവാസി ഫീഡ് തയ്യാറാണ്',
      nepali: 'तपाईको व्यक्तिगत कतार एक्सप्याट फिड तयार छ',
      bengali: 'আপনার ব্যক্তিগতকৃত কাতার প্রবাসী ফিড প্রস্তুত',
      tamil:
          'உங்களின் தனிப்பயனாக்கப்பட்ட கத்தார் வெளிநாட்டு ஊட்டம் தயாராக உள்ளது',
      filipino: 'Ang iyong personalized na Qatar expat feed ay handa na',
    ),
    'feed_welcome_cta': l10nEntry(
      english: 'Explore',
      arabic: 'استكشف',
      hindi: 'अन्वेषण करना',
      urdu: 'دریافت کرنا',
      malayalam: 'പര്യവേക്ഷണം ചെയ്യുക',
      nepali: 'अन्वेषण गर्नुहोस्',
      bengali: 'অন্বেষণ',
      tamil: 'ஆராயுங்கள்',
      filipino: 'Galugarin',
    ),
    'feed_business_fallback_title': l10nEntry(
      english: '🏪 Business offer near you',
      arabic: '🏪 عرض تجاري قريب منك',
      hindi: '🏪 आपके नजदीक बिजनेस ऑफर',
      urdu: '🏪 آپ کے قریب کاروباری پیشکش',
      malayalam: '🏪 നിങ്ങളുടെ അടുത്തുള്ള ബിസിനസ്സ് ഓഫർ',
      nepali: '🏪 तपाईंको नजिकैको व्यापार प्रस्ताव',
      bengali: '🏪 আপনার কাছাকাছি ব্যবসা অফার',
      tamil: '🏪 உங்களுக்கு அருகிலுள்ள வணிகச் சலுகை',
      filipino: '🏪 Alok ng negosyo na malapit sa iyo',
    ),
    'feed_business_cta': l10nEntry(
      english: 'View Offer',
      arabic: 'عرض العرض',
      hindi: 'ऑफर देखें',
      urdu: 'پیشکش دیکھیں',
      malayalam: 'ഓഫർ കാണുക',
      nepali: 'अफर हेर्नुहोस्',
      bengali: 'অফার দেখুন',
      tamil: 'சலுகையைப் பார்க்கவும்',
      filipino: 'Tingnan ang Alok',
    ),
    'feed_gov_fallback_title': l10nEntry(
      english: '🏛️ Government announcement',
      arabic: '🏛️ إعلان حكومي',
      hindi: '🏛️सरकारी घोषणा',
      urdu: '🏛️حکومتی اعلان',
      malayalam: '🏛️ സർക്കാർ പ്രഖ്യാപനം',
      nepali: '🏛️सरकारको घोषणा',
      bengali: '🏛️ সরকারী ঘোষণা',
      tamil: '🏛️ அரசு அறிவிப்பு',
      filipino: '🏛️ Anunsyo ng gobyerno',
    ),
    'feed_learn_more': l10nEntry(
      english: 'Learn More',
      arabic: 'اعرف المزيد',
      hindi: 'और अधिक जानें',
      urdu: 'مزید جانیں',
      malayalam: 'കൂടുതലറിയുക',
      nepali: 'थप जान्नुहोस्',
      bengali: 'আরও জানুন',
      tamil: 'மேலும் அறிக',
      filipino: 'Matuto pa',
    ),
    'feed_sponsored_fallback': l10nEntry(
      english: 'Sponsored',
      arabic: 'برعاية',
      hindi: 'प्रायोजित',
      urdu: 'سپانسر شدہ',
      malayalam: 'സ്പോൺസർ ചെയ്തത്',
      nepali: 'प्रायोजित',
      bengali: 'স্পন্সর',
      tamil: 'நிதியுதவி',
      filipino: 'Naka-sponsor',
    ),
    'feed_sponsor_label': l10nEntry(
      english: 'SPONSORED',
      arabic: 'برعاية',
      hindi: 'प्रायोजित',
      urdu: 'سپانسر شدہ',
      malayalam: 'സ്പോൺസർ ചെയ്തു',
      nepali: 'प्रायोजित',
      bengali: 'স্পন্সরড',
      tamil: 'நிதியுதவி',
      filipino: 'Home AI feed card: SPONSORED',
    ),
    'feed_cache_relative': l10nEntry(
      english: 'Last updated {time}',
      arabic: 'آخر تحديث {time}',
      hindi: 'अंतिम अद्यतन {time}',
      urdu: 'آخری اپڈیٹ {time}',
      malayalam: 'അവസാനം അപ്ഡേറ്റ് ചെയ്തത് {time}',
      nepali: 'पछिल्लो अद्यावधिक {time}',
      bengali: 'সর্বশেষ আপডেট {time}',
      tamil: 'கடைசி புதுப்பிப்பு {time}',
      filipino: 'Huling update {time}',
    ),
    'feed_offline_note': l10nEntry(
      english: 'Showing offline welcome feed',
      arabic: 'عرض خلاصة ترحيب دون اتصال',
      hindi: 'ऑफ़लाइन स्वागत फ़ीड दिखाया जा रहा है',
      urdu: 'آف لائن ویلکم فیڈ دکھا رہا ہے۔',
      malayalam: 'ഓഫ്‌ലൈൻ സ്വാഗത ഫീഡ് കാണിക്കുന്നു',
      nepali: 'अफलाइन स्वागत फिड देखाउँदै',
      bengali: 'অফলাইন ওয়েলকাম ফিড দেখানো হচ্ছে',
      tamil: 'ஆஃப்லைன் வரவேற்பு ஊட்டத்தைக் காட்டுகிறது',
      filipino: 'Ipinapakita ang offline na welcome feed',
    ),
    'feed_date_recently': l10nEntry(
      english: 'Recently',
      arabic: 'مؤخراً',
      hindi: 'हाल ही में',
      urdu: 'حال ہی میں',
      malayalam: 'അടുത്തിടെ',
      nepali: 'हालै',
      bengali: 'সম্প্রতি',
      tamil: 'சமீபத்தில்',
      filipino: 'Kamakailan lang',
    ),
    'feed_relative_minutes': l10nEntry(
      english: '{count}m ago',
      arabic: 'منذ {count} د',
      hindi: '{गिनती} मी पहले {count}',
      urdu: '{count} منٹ پہلے {count}',
      malayalam: '{count}m മുമ്പ്',
      nepali: '{count}मिनेट अघि',
      bengali: '{count}মি আগে',
      tamil: '{count}நி முன்பு',
      filipino: '{count}m ang nakalipas',
    ),
    'feed_relative_hours': l10nEntry(
      english: '{count}h ago',
      arabic: 'منذ {count} س',
      hindi: '{गिनती} घंटे पहले {count}',
      urdu: '{count} گھنٹے پہلے {count}',
      malayalam: '{count} മണിക്കൂർ മുമ്പ്',
      nepali: '{count} घण्टा अघि',
      bengali: '{count}ঘণ্টা আগে',
      tamil: '{count}h முன்பு',
      filipino: '{count}h ang nakalipas',
    ),
    'feed_relative_days': l10nEntry(
      english: '{count}d ago',
      arabic: 'منذ {count} ي',
      hindi: '{गिनती}दिन पहले {count}',
      urdu: '{count} دن پہلے {count}',
      malayalam: '{count}d മുമ്പ്',
      nepali: '{count} दिन अघि',
      bengali: '{count}দিন আগে',
      tamil: '{count}நா முன்பு',
      filipino: '{count}d ang nakalipas',
    ),
    'for_you_because_job_match': l10nEntry(
      english: 'Because your profile matches roles at {match}%',
      arabic: 'لأن ملفك يطابق وظائف بنسبة {match}%',
      hindi: 'क्योंकि आपकी प्रोफ़ाइल {match}% पर भूमिकाओं से मेल खाती है',
      urdu: 'کیونکہ آپ کا پروفائل کرداروں سے مماثل ہے {match}%',
      malayalam:
          'കാരണം നിങ്ങളുടെ പ്രൊഫൈൽ {match}%-ൽ റോളുകളുമായി പൊരുത്തപ്പെടുന്നു',
      nepali: 'किनभने तपाईंको प्रोफाइल {match}% मा भूमिकाहरूसँग मेल खान्छ',
      bengali: 'কারণ আপনার প্রোফাইল {match}% ভূমিকার সাথে মেলে',
      tamil:
          'ஏனெனில் உங்கள் சுயவிவரம் {match}% இல் உள்ள பாத்திரங்களுடன் பொருந்துகிறது',
      filipino:
          'Dahil ang iyong profile ay tumutugma sa mga tungkulin sa {match}%',
    ),
    'for_you_because_job_profession': l10nEntry(
      english: 'Because you work as {profession}',
      arabic: 'لأن مهنتك {profession}',
      hindi: 'क्योंकि आप {profession} के रूप में काम करते हैं',
      urdu: 'کیونکہ آپ {profession} کے طور پر کام کرتے ہیں',
      malayalam: 'കാരണം നിങ്ങൾ {profession} ആയി ജോലി ചെയ്യുന്നു',
      nepali: 'किनभने तपाईं {profession} को रूपमा काम गर्नुहुन्छ',
      bengali: 'কারণ আপনি {profession} হিসেবে কাজ করেন',
      tamil: 'ஏனெனில் நீங்கள் {profession} ஆக வேலை செய்கிறீர்கள்',
      filipino: 'Dahil nagtatrabaho ka bilang {profession}',
    ),
    'for_you_because_housing_area': l10nEntry(
      english: 'Because you set {area} as your area',
      arabic: 'لأنك اخترت {area} كمنطقتك',
      hindi:
          'क्योंकि आपने {क्षेत्र} को अपने क्षेत्र के रूप में निर्धारित किया है {area}',
      urdu:
          'کیونکہ آپ نے {علاقہ} کو اپنے علاقے {علاقہ} کے طور پر سیٹ کیا {area}',
      malayalam: 'കാരണം നിങ്ങൾ {area} നിങ്ങളുടെ ഏരിയയായി സജ്ജമാക്കി',
      nepali:
          'किनभने तपाईंले आफ्नो क्षेत्रको रूपमा {क्षेत्र} सेट गर्नुभयो {area}',
      bengali: 'কারণ আপনি {এরিয়া}কে আপনার এলাকা হিসেবে সেট করেছেন {area}',
      tamil: 'ஏனெனில் நீங்கள் {ஏரியா} உங்கள் ஏரியாவாக அமைத்தீர்கள் {area}',
      filipino: 'Dahil itinakda mo ang {area} bilang iyong lugar',
    ),
    'for_you_because_housing_match': l10nEntry(
      english: 'Because listings match your search at {match}%',
      arabic: 'لأن العروض تطابق بحثك بنسبة {match}%',
      hindi: 'क्योंकि सूचियाँ आपकी खोज से {match}% पर मेल खाती हैं',
      urdu: 'کیونکہ فہرستیں آپ کی تلاش سے {match}% پر ملتی ہیں',
      malayalam:
          'കാരണം ലിസ്റ്റിംഗുകൾ {match}% എന്നതിൽ നിങ്ങളുടെ തിരയലുമായി പൊരുത്തപ്പെടുന്നു',
      nepali: 'किनभने सूचीहरू तपाईंको खोजसँग मेल खान्छ {match}%',
      bengali: 'কারণ তালিকাগুলি আপনার অনুসন্ধানের সাথে {match}% এর সাথে মেলে',
      tamil: 'பட்டியல்கள் உங்கள் தேடலுக்கு {match}% இல் பொருந்துவதால்',
      filipino:
          'Dahil tumutugma ang mga listahan sa iyong paghahanap sa {match}%',
    ),
    'for_you_because_exchange_up': l10nEntry(
      english: 'Because INR moved up against QAR today',
      arabic: 'لأن الروبية الهندية ارتفعت مقابل الريال اليوم',
      hindi: 'क्योंकि INR आज QAR के मुकाबले बढ़ गया',
      urdu: 'کیونکہ آج INR QAR کے مقابلے میں بڑھ گیا ہے۔',
      malayalam: 'കാരണം INR ഇന്ന് QAR നെ അപേക്ഷിച്ച് ഉയർന്നു',
      nepali: 'किनकी INR आज QAR को बिरूद्ध सारियो',
      bengali: 'কারণ আজ INR QAR এর বিপরীতে বেড়েছে',
      tamil: 'ஏனெனில் இன்று QARக்கு எதிராக INR உயர்ந்தது',
      filipino: 'Dahil umakyat ang INR laban sa QAR ngayon',
    ),
    'for_you_because_exchange_down': l10nEntry(
      english: 'Because INR moved down against QAR today',
      arabic: 'لأن الروبية الهندية انخفضت مقابل الريال اليوم',
      hindi: 'क्योंकि INR आज QAR के मुकाबले नीचे चला गया',
      urdu: 'کیونکہ آج INR QAR کے مقابلے میں نیچے چلا گیا۔',
      malayalam: 'കാരണം INR ഇന്ന് QAR നെ അപേക്ഷിച്ച് താഴേക്ക് നീങ്ങി',
      nepali: 'किनकी INR आज QAR को बिरूद्ध घट्यो',
      bengali: 'কারণ INR আজ QAR এর বিপরীতে নেমে গেছে',
      tamil: 'ஏனெனில் இன்று QARக்கு எதிராக INR குறைந்துள்ளது',
      filipino: 'Dahil bumaba ang INR laban sa QAR ngayon',
    ),
    'for_you_because_exchange_rates': l10nEntry(
      english: 'Because QAR exchange rates updated',
      arabic: 'لأن أسعار صرف الريال تحدّثت',
      hindi: 'क्योंकि QAR विनिमय दरें अद्यतन की गईं',
      urdu: 'کیونکہ QAR کی شرح تبادلہ کو اپ ڈیٹ کر دیا گیا تھا۔',
      malayalam: 'കാരണം QAR വിനിമയ നിരക്കുകൾ അപ്ഡേറ്റ് ചെയ്തു',
      nepali: 'किनभने QAR विनिमय दरहरू अद्यावधिक गरियो',
      bengali: 'কারণ QAR বিনিময় হার আপডেট করা হয়েছে',
      tamil: 'ஏனெனில் QAR மாற்று விகிதங்கள் புதுப்பிக்கப்பட்டுள்ளன',
      filipino: 'Dahil na-update ang exchange rates ng QAR',
    ),
    'for_you_because_visa_update': l10nEntry(
      english: 'Because there is a recent visa update',
      arabic: 'لأن هناك تحديثاً حديثاً للتأشيرة',
      hindi: 'क्योंकि हाल ही में वीजा अपडेट हुआ है',
      urdu: 'کیونکہ ویزا حال ہی میں اپ ڈیٹ ہوا ہے۔',
      malayalam: 'കാരണം അടുത്തിടെ ഒരു വിസ അപ്ഡേറ്റ് ഉണ്ട്',
      nepali: 'किनभने भर्खरै भिसा अपडेट भएको छ',
      bengali: 'কারণ সাম্প্রতিক ভিসা আপডেট হয়েছে',
      tamil: 'ஏனெனில் சமீபத்திய விசா புதுப்பிப்பு உள்ளது',
      filipino: 'Kasi may recent visa update',
    ),
    'for_you_because_event_area': l10nEntry(
      english: 'Because events are listed near {area}',
      arabic: 'لأن هناك فعاليات قرب {area}',
      hindi: 'क्योंकि घटनाएँ {क्षेत्र} के पास सूचीबद्ध हैं {area}',
      urdu: 'کیونکہ واقعات {علاقہ} کے قریب درج ہیں {area}',
      malayalam:
          'കാരണം ഇവൻ്റുകൾ {ഏരിയയ്ക്ക് സമീപം ലിസ്റ്റ് ചെയ്തിരിക്കുന്നു {area}',
      nepali: 'किनभने घटनाहरू {क्षेत्र} नजिकै सूचीबद्ध छन् {area}',
      bengali:
          'কারণ ইভেন্টগুলি {এরিয়া} এর কাছাকাছি তালিকাভুক্ত করা হয়েছে {area}',
      tamil: 'ஏனெனில் நிகழ்வுகள் {ஏரியா} அருகில் பட்டியலிடப்பட்டுள்ளன {area}',
      filipino: 'Dahil nakalista ang mga kaganapan malapit sa {area}',
    ),
    'for_you_because_event_week': l10nEntry(
      english: 'Because community events are coming up this week',
      arabic: 'لأن فعاليات مجتمعية هذا الأسبوع',
      hindi: 'क्योंकि इस सप्ताह सामुदायिक कार्यक्रम आ रहे हैं',
      urdu: 'کیونکہ اس ہفتے کمیونٹی ایونٹس آرہے ہیں۔',
      malayalam: 'കാരണം കമ്മ്യൂണിറ്റി ഇവൻ്റുകൾ ഈ ആഴ്ച വരാനിരിക്കുന്നു',
      nepali: 'किनभने यस हप्ता सामुदायिक घटनाहरू आउँदैछन्',
      bengali: 'কারণ এই সপ্তাহে কমিউনিটি ইভেন্ট আসছে',
      tamil: 'ஏனெனில் இந்த வாரம் சமூக நிகழ்வுகள் வரவுள்ளன',
      filipino:
          'Dahil paparating na ang mga kaganapan sa komunidad ngayong linggo',
    ),
  };
}
