/// Spoken-language codes for Buddy — separate from app UI locale.
class BuddySpokenLanguageOption {
  const BuddySpokenLanguageOption({required this.code, required this.labelKey});

  final String code;
  final String labelKey;
}

abstract final class BuddySpokenLanguages {
  static const options = <BuddySpokenLanguageOption>[
    BuddySpokenLanguageOption(code: 'en', labelKey: 'buddy_lang_en'),
    BuddySpokenLanguageOption(code: 'ar', labelKey: 'buddy_lang_ar'),
    BuddySpokenLanguageOption(code: 'hi', labelKey: 'buddy_lang_hi'),
    BuddySpokenLanguageOption(code: 'ur', labelKey: 'buddy_lang_ur'),
    BuddySpokenLanguageOption(code: 'ml', labelKey: 'buddy_lang_ml'),
    BuddySpokenLanguageOption(code: 'ne', labelKey: 'buddy_lang_ne'),
    BuddySpokenLanguageOption(code: 'bn', labelKey: 'buddy_lang_bn'),
    BuddySpokenLanguageOption(code: 'ta', labelKey: 'buddy_lang_ta'),
    BuddySpokenLanguageOption(code: 'fil', labelKey: 'buddy_lang_fil'),
  ];

  static const allowedCodes = {
    'en',
    'ar',
    'hi',
    'ur',
    'ml',
    'ne',
    'bn',
    'ta',
    'fil',
  };
}
