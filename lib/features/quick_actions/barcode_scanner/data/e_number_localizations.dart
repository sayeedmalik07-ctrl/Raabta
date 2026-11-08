/// Localized plain names and reasons for high-frequency E-numbers.
///
/// Falls back to bundled English [ENumberEntry] text when a code or language
/// is not listed here.
abstract final class ENumberLocalizations {
  static String languageKey(String uiLanguage) => switch (uiLanguage) {
        'Arabic' => 'ar',
        'Urdu' => 'ur',
        'Hindi' => 'hi',
        'Bengali' => 'bn',
        'Tagalog' || 'Filipino' => 'tl',
        _ => 'en',
      };

  static _LocalizedText? forCode(String code, String uiLanguage) {
    final lang = languageKey(uiLanguage);
    if (lang == 'en') return null;
    return _byLanguage[lang]?[code.toUpperCase()];
  }

  static const _byLanguage = <String, Map<String, _LocalizedText>>{
    'ar': {
      'E102': _LocalizedText(
        plainName: 'تارترازين (لون)',
        reason: 'صبغ azo صناعية؛ قد تؤثر على بعض الأطفال الحساسين.',
      ),
      'E110': _LocalizedText(
        plainName: 'أصفر الغروب (لون)',
        reason: 'صبغ azo برتقالي؛ تحقق إن كنت تتجنب الألوان الاصطناعية.',
      ),
      'E120': _LocalizedText(
        plainName: 'كارمين (لون)',
        reason: 'لون أحمر من الحشرات؛ حساسية نادرة ممكنة.',
      ),
      'E150d': _LocalizedText(
        plainName: 'كراميل (لون)',
        reason: 'شائع في المشروبات الغازية؛ ضمن حدود آمنة منظم.',
      ),
      'E171': _LocalizedText(
        plainName: 'ثاني أكسيد التيتانيوم',
        reason: 'ممنوع كمضاف غذائي في الاتحاد الأوروبي من 2022.',
      ),
      'E211': _LocalizedText(
        plainName: 'بنzoate الصوديوم',
        reason: 'مادة حافظة شائعة؛ بعض الناس يفضلون تقليلها.',
      ),
      'E220': _LocalizedText(
        plainName: ' ثاني أكسيد الكبريت',
        reason: 'كبريتات؛ قد تسبب رد فعل لمن لديهم حساسية الكبريتات.',
      ),
      'E250': _LocalizedText(
        plainName: 'نitrite الصوديوم',
        reason: 'للحوم المصنعة؛ يُنصح بت moderating اللحوم المعالجة.',
      ),
      'E330': _LocalizedText(
        plainName: 'حمض الستريك',
        reason: 'حمض طبيعي شائع؛ منظم حموضة آمن.',
      ),
      'E407': _LocalizedText(
        plainName: 'كarrageenan',
        reason: 'مُكثّف من الطحالب؛ بعض الناس يبلغون عن حساسية هضمية.',
      ),
      'E415': _LocalizedText(
        plainName: 'صمغ الزanthan',
        reason: 'مُكثّف شائع في المنتجات خالية الغلuten.',
      ),
      'E471': _LocalizedText(
        plainName: 'مُستحلب أحادي/ثنائي الغlyceride',
        reason: 'مُستحلب شائع في الخبز والmargarine.',
      ),
      'E621': _LocalizedText(
        plainName: 'MSG (مُعزز نكهة)',
        reason: 'يُعزز النكهة؛ بعض الناس يفضلون تقليل MSG.',
      ),
      'E951': _LocalizedText(
        plainName: 'Aspartame (مُحلي)',
        reason: 'مُحلي اصطناعي؛ يجب تجنبه مع PKU.',
      ),
      'E955': _LocalizedText(
        plainName: 'Sucralose (مُحلي)',
        reason: 'مُحلي خالٍ من السعرات؛ معتمد ضمن حدود آمنة.',
      ),
      'E960': _LocalizedText(
        plainName: 'Stevia (مُحلي)',
        reason: 'مُحلي طبيعي من نبات stevia.',
      ),
    },
    'ur': {
      'E102': _LocalizedText(
        plainName: 'Tartrazine (رنگ)',
        reason: 'مصنوعی رنگ؛ حساس بچوں پر اثر ہو سکتا ہے۔',
      ),
      'E211': _LocalizedText(
        plainName: 'Sodium benzoate (preservative)',
        reason: 'عام preservative؛ بعض لوگ کم استعمال کرتے ہیں۔',
      ),
      'E330': _LocalizedText(
        plainName: 'Citric acid',
        reason: 'عام قدرتی acid؛ محفوظ acidity regulator۔',
      ),
      'E621': _LocalizedText(
        plainName: 'MSG (flavour enhancer)',
        reason: 'ذائقہ بڑھانے والا؛ بعض لوگ کم استعمال کرتے ہیں۔',
      ),
      'E951': _LocalizedText(
        plainName: 'Aspartame (sweetener)',
        reason: 'مصنوعی sweetener؛ PKU میں avoid کریں۔',
      ),
    },
    'hi': {
      'E102': _LocalizedText(
        plainName: 'Tartrazine (रंग)',
        reason: 'कृत्रिम रंग; कुछ संवेदनशील बच्चों पर प्रभाव हो सकता है।',
      ),
      'E211': _LocalizedText(
        plainName: 'Sodium benzoate',
        reason: 'आम preservative; कुछ लोग सीमित करते हैं।',
      ),
      'E330': _LocalizedText(
        plainName: 'Citric acid',
        reason: 'सामान्य प्राकृतिक अम्ल; सुरक्षित acidity regulator।',
      ),
      'E621': _LocalizedText(
        plainName: 'MSG (flavour enhancer)',
        reason: 'स्वाद बढ़ाने वाला; कुछ लोग सीमित करते हैं।',
      ),
      'E951': _LocalizedText(
        plainName: 'Aspartame',
        reason: 'कृत्रिम sweetener; PKU में avoid करें।',
      ),
    },
    'bn': {
      'E102': _LocalizedText(
        plainName: 'Tartrazine (রং)',
        reason: 'কৃত্রিম রং; সংবেদনশীল শিশুদের প্রভাব হতে পারে।',
      ),
      'E211': _LocalizedText(
        plainName: 'Sodium benzoate',
        reason: 'সাধারণ preservative; কেউ কম খান।',
      ),
      'E621': _LocalizedText(
        plainName: 'MSG',
        reason: 'স্বাদ বাড়ানো; কেউ সীমিত করেন।',
      ),
      'E951': _LocalizedText(
        plainName: 'Aspartame',
        reason: 'কৃত্রিম sweetener; PKU-তে এড়িয়ে চলুন।',
      ),
    },
    'tl': {
      'E102': _LocalizedText(
        plainName: 'Tartrazine (kulay)',
        reason: 'Artipisyal na dye; maaaring makaapekto sa sensitibong bata.',
      ),
      'E211': _LocalizedText(
        plainName: 'Sodium benzoate',
        reason: 'Karaniwang preservative; limitahan kung gusto mo.',
      ),
      'E621': _LocalizedText(
        plainName: 'MSG (pampalasa)',
        reason: 'Pampalasa ng umami; may limit ang ilan.',
      ),
      'E951': _LocalizedText(
        plainName: 'Aspartame',
        reason: 'Artipisyal na sweetener; iwasan kung may PKU.',
      ),
    },
  };
}

class _LocalizedText {
  const _LocalizedText({required this.plainName, required this.reason});

  final String plainName;
  final String reason;
}
