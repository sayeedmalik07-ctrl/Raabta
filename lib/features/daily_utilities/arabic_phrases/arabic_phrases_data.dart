/// Pre-written Arabic phrasebook — bundled offline data (not AI-generated).
///
/// **Dialect:** Phrases use spoken Gulf/Qatari colloquial Arabic where practical
/// (e.g. *wayn*, *abgha*, *indi*) — not formal MSA-only. Confirm approach with
/// product before marketing; new entries ship with [ArabicPhrase.reviewed] until
/// native Gulf-dialect review is complete.
library;

import 'arabic_phrases_catalog.dart';

export 'arabic_phrases_catalog.dart' show arabicPhrases;

class PhraseCategory {
  const PhraseCategory({
    required this.id,
    required this.emoji,
    required this.labelKey,
  });

  final String id;
  final String emoji;
  final String labelKey;
}

const phraseCategories = [
  PhraseCategory(id: 'greetings', emoji: '👋', labelKey: 'cat_greetings'),
  PhraseCategory(id: 'workplace', emoji: '💼', labelKey: 'cat_workplace'),
  PhraseCategory(id: 'government', emoji: '🏛️', labelKey: 'cat_government'),
  PhraseCategory(id: 'housing', emoji: '🏠', labelKey: 'cat_housing'),
  PhraseCategory(id: 'healthcare', emoji: '🏥', labelKey: 'cat_healthcare'),
  PhraseCategory(id: 'shopping', emoji: '🛍️', labelKey: 'cat_shopping'),
  PhraseCategory(id: 'directions', emoji: '🚕', labelKey: 'cat_directions'),
  PhraseCategory(id: 'restaurant', emoji: '🍽️', labelKey: 'cat_restaurant'),
  PhraseCategory(id: 'emergency', emoji: '🆘', labelKey: 'cat_emergency'),
  PhraseCategory(id: 'numbers', emoji: '🔢', labelKey: 'cat_numbers'),
  PhraseCategory(id: 'small_talk', emoji: '💬', labelKey: 'cat_small_talk'),
  PhraseCategory(
    id: 'common_responses',
    emoji: '🔁',
    labelKey: 'cat_common_responses',
  ),
];

class ArabicPhrase {
  const ArabicPhrase({
    required this.id,
    required this.categoryId,
    required this.arabicScript,
    required this.transliteration,
    required this.translations,
    this.reviewed = false,
    this.contextNote,
  });

  final String id;
  final String categoryId;
  final String arabicScript;
  final String transliteration;

  /// English + app-language meanings (not the Arabic phrase itself).
  final Map<String, String> translations;

  /// `true` only after native/professional Gulf-dialect review.
  final bool reviewed;

  /// Optional usage note (especially for [common_responses] category).
  final String? contextNote;

  String meaningFor(String locale) =>
      translations[locale] ?? translations['English'] ?? '';
}

Map<String, String> phraseTranslations({
  required String en,
  String? ar,
  String? hi,
  String? ur,
  String? fil,
  String? bn,
}) =>
    {
      'English': en,
      if (ar != null) 'Arabic': ar,
      if (hi != null) 'Hindi': hi,
      if (ur != null) 'Urdu': ur,
      if (fil != null) 'Filipino': fil,
      if (bn != null) 'Bengali': bn,
    };

const phraseCategoryLabels = {
  'cat_greetings': {
    'English': 'Greetings & Courtesy',
    'Arabic': 'تحيات ومجاملة',
    'Hindi': 'अभिवादन और शिष्टाचार',
    'Urdu': 'سلام و آداب',
    'Filipino': 'Pagbati at Pagpapakita ng Respeto',
    'Bengali': 'অভিবাদন ও শিষ্টাচার',
  },
  'cat_workplace': {
    'English': 'Workplace & Office',
    'Arabic': 'العمل والمكتب',
    'Hindi': 'कार्यस्थल और ऑफिस',
    'Urdu': 'کام اور دفتر',
    'Filipino': 'Trabaho at Opisina',
    'Bengali': 'কর্মক্ষেত্র ও অফিস',
  },
  'cat_government': {
    'English': 'Government & Services',
    'Arabic': 'دوائر حكومية وخدمات',
    'Hindi': 'सरकारी कार्यालय और सेवाएँ',
    'Urdu': 'سرکاری دفاتر و خدمات',
    'Filipino': 'Gobyerno at Serbisyo',
    'Bengali': 'সরকারি অফিস ও সেবা',
  },
  'cat_housing': {
    'English': 'Housing & Landlord',
    'Arabic': 'السكن والمالك',
    'Hindi': 'आवास और मकान मालिक',
    'Urdu': 'رہائش اور مالک',
    'Filipino': 'Tirahan at May-ari',
    'Bengali': 'বাসস্থান ও বাড়িওয়ালা',
  },
  'cat_healthcare': {
    'English': 'Healthcare & Pharmacy',
    'Arabic': 'الصحة والصيدلية',
    'Hindi': 'स्वास्थ्य और फार्मेसी',
    'Urdu': 'صحت اور فارمیسی',
    'Filipino': 'Kalusugan at Parmasya',
    'Bengali': 'স্বাস্থ্যসেবা ও ফার্মেসি',
  },
  'cat_shopping': {
    'English': 'Shopping & Market',
    'Arabic': 'تسوق والسوق',
    'Hindi': 'खरीदारी और बाज़ार',
    'Urdu': 'خریداری اور بازار',
    'Filipino': 'Pamimili at Palengke',
    'Bengali': 'কেনাকাটা ও বাজার',
  },
  'cat_directions': {
    'English': 'Transport & Directions',
    'Arabic': 'مواصلات واتجاهات',
    'Hindi': 'परिवहन और दिशा',
    'Urdu': 'نقل و حرکت اور راستہ',
    'Filipino': 'Transportasyon at Direksyon',
    'Bengali': 'যাতায়াত ও দিকনির্দেশ',
  },
  'cat_restaurant': {
    'English': 'Dining & Food',
    'Arabic': 'مطعم وطعام',
    'Hindi': 'भोजन और रेस्तरां',
    'Urdu': 'کھانا اور ریستوران',
    'Filipino': 'Pagkain at Restaurant',
    'Bengali': 'খাবার ও রেস্তোরাঁ',
  },
  'cat_emergency': {
    'English': 'Emergency & Safety',
    'Arabic': 'طوارئ وأمان',
    'Hindi': 'आपातकाल और सुरक्षा',
    'Urdu': 'ایمرجنسی اور حفاظت',
    'Filipino': 'Emergency at Kaligtasan',
    'Bengali': 'জরুরি ও নিরাপত্তা',
  },
  'cat_numbers': {
    'English': 'Numbers, Time & Days',
    'Arabic': 'أرقام ووقت وأيام',
    'Hindi': 'संख्या, समय और दिन',
    'Urdu': 'نمبر، وقت اور دن',
    'Filipino': 'Numero, Oras at Araw',
    'Bengali': 'সংখ্যা, সময় ও দিন',
  },
  'cat_small_talk': {
    'English': 'Everyday Small Talk',
    'Arabic': 'حديث يومي',
    'Hindi': 'रोज़ की बातचीत',
    'Urdu': 'روزمرہ گفتگو',
    'Filipino': 'Pang-araw-araw na Usapan',
    'Bengali': 'দৈনন্দিন আড্ডা',
  },
  'cat_common_responses': {
    'English': 'Responses You\'ll Hear Back',
    'Arabic': 'ردود شائعة',
    'Hindi': 'आम जवाब जो आप सुनेंगे',
    'Urdu': 'عام جواب جو آپ سنیں گے',
    'Filipino': 'Mga Sagot na Maririnig Mo',
    'Bengali': 'যে উত্তরগুলো শুনবেন',
  },
};

String phraseCategoryLabel(String labelKey, String locale) {
  final map = phraseCategoryLabels[labelKey];
  if (map == null) return labelKey;
  return map[locale] ?? map['English'] ?? labelKey;
}

List<ArabicPhrase> phrasesForCategory(String categoryId) =>
    arabicPhrases.where((p) => p.categoryId == categoryId).toList();

ArabicPhrase? phraseById(String id) {
  for (final p in arabicPhrases) {
    if (p.id == id) return p;
  }
  return null;
}

int get reviewedPhraseCount =>
    arabicPhrases.where((p) => p.reviewed).length;

int get pendingReviewPhraseCount =>
    arabicPhrases.where((p) => !p.reviewed).length;
