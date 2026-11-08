import 'package:flutter/foundation.dart';
import 'package:raabta/core/l10n/app_locale.dart';
import 'package:raabta/core/l10n/locale_catalog_coverage.dart';
import 'package:raabta/core/l10n/locale_catalog_entry.dart';
import 'package:raabta/features/buddy/domain/buddy_profile_validation.dart';

abstract final class BuddyStrings {
  static const supportedLocales = AppLocale.supportedLocales;

  static String t(String key, [String locale = 'English']) {
    final normalized = AppLocale.normalize(locale);
    final map = _catalog[key];
    if (map == null) return key;
    return map[normalized] ?? map['English'] ?? key;
  }

  @visibleForTesting
  static Map<String, Set<String>> get localeCoverageReport =>
      buildLocaleCoverageReport(
        catalog: _catalog,
        supportedLocales: supportedLocales,
      );

  static String validationMessage(BuddyValidationError error, String locale) {
    return t('buddy_err_${error.name}', locale);
  }

  static final _catalog = <String, Map<String, String>>{
    'buddy_entry_title': l10nEntry(
      english: 'Find a Buddy',
      arabic: 'ابحث عن رفيق',
      hindi: 'Find a Buddy',
      urdu: 'Find a Buddy',
      malayalam: 'Find a Buddy',
      nepali: 'Find a Buddy',
      bengali: 'Find a Buddy',
      tamil: 'Find a Buddy',
      filipino: 'Find a Buddy',
    ),
    'buddy_entry_body': l10nEntry(
      english:
          'Optional peer support from self-declared helpers in Qatar — same home country, in-app only.',
      arabic:
          'دعم اختياري من مقيمين يساعدون الوافدين — نفس بلدك، داخل التطبيق فقط. معلومات غير موثقة.',
      hindi:
          'Optional support from self-declared helpers — same country, in-app only. Not verified.',
      urdu:
          'Optional support from self-declared helpers — same country, in-app only. Not verified.',
    ),
    'buddy_entry_action': l10nEntry(
      english: 'Set up',
      arabic: 'إعداد',
      hindi: 'Set up',
      urdu: 'Set up',
    ),
    'buddy_entry_dismiss': l10nEntry(
      english: 'Not now',
      arabic: 'ليس الآن',
      hindi: 'Not now',
      urdu: 'Not now',
    ),
    'buddy_consent_title': l10nEntry(
      english: 'Buddy matching consent',
      arabic: 'موافقة نظام الرفيق',
      hindi: 'Buddy matching consent',
      urdu: 'Buddy matching consent',
    ),
    'buddy_consent_body': l10nEntry(
      english:
          'Buddy matching is optional. Details you share are self-declared — Raabta does not verify them. You must be 18+ (self-attestation, not verified). Other opted-in users may see: nickname, nationality, spoken languages, coarse area, years in Qatar (helpers), and interest tags. Pause or opt out removes you from future matching. Pick a supported nationality and coarse area to continue.',
      arabic:
          'المطابقة اختيارية. البيانات التي تدخلها ذاتية وغير موثقة. يجب أن تكون 18+ (إقرار ذاتي). يرى المستخدمون المشاركون: اللقب، الجنسية، اللغات، المنطقة التقريبية، مدة الإقامة (للمساعدين)، والاهتمامات. الإيقاف أو الإلغاء يزيلك من المطابقة.',
      hindi:
          'Buddy matching is optional. Self-declared info — not verified. 18+ self-attestation required. Others see nickname, nationality, languages, area, tenure (helpers), interests. Pause/opt out stops matching.',
      urdu:
          'Buddy matching is optional. Self-declared info — not verified. 18+ self-attestation required. Others see nickname, nationality, languages, area, tenure (helpers), interests. Pause/opt out stops matching.',
    ),
    'buddy_consent_adult_checkbox': l10nEntry(
      english: 'I am 18 or older (self-declaration)',
      arabic: 'عمري 18 سنة أو أكثر (إقرار ذاتي)',
      hindi: 'I am 18 or older (self-declaration)',
      urdu: 'I am 18 or older (self-declaration)',
    ),
    'buddy_consent_continue': l10nEntry(
      english: 'I understand — continue',
      arabic: 'أفهم — متابعة',
      hindi: 'I understand — continue',
      urdu: 'I understand — continue',
    ),
    'buddy_opt_in_title': l10nEntry(
      english: 'Your Buddy profile',
      arabic: 'ملف الرفيق',
      hindi: 'Your Buddy profile',
      urdu: 'Your Buddy profile',
    ),
    'buddy_role_newcomer': l10nEntry(
      english: 'I\'m new to Qatar',
      arabic: 'أنا جديد في قطر',
      hindi: 'I\'m new to Qatar',
      urdu: 'I\'m new to Qatar',
    ),
    'buddy_role_helper': l10nEntry(
      english: 'Happy to help newcomers',
      arabic: 'سعيد بمساعدة الوافدين',
      hindi: 'Happy to help newcomers',
      urdu: 'Happy to help newcomers',
    ),
    'buddy_paused': l10nEntry(
      english: 'Pause matching',
      arabic: 'إيقاف المطابقة',
      hindi: 'Pause matching',
      urdu: 'Pause matching',
    ),
    'buddy_country_label': l10nEntry(
      english: 'Home country (for matching)',
      arabic: 'بلدك (للمطابقة)',
      hindi: 'Home country (for matching)',
      urdu: 'Home country (for matching)',
    ),
    'buddy_spoken_languages_label': l10nEntry(
      english: 'Languages you speak (up to 5)',
      arabic: 'اللغات التي تتحدثها (حتى 5)',
      hindi: 'Languages you speak (up to 5)',
      urdu: 'Languages you speak (up to 5)',
    ),
    'buddy_area_label': l10nEntry(
      english: 'Coarse area in Qatar',
      arabic: 'منطقتك التقريبية في قطر',
      hindi: 'Coarse area in Qatar',
      urdu: 'Coarse area in Qatar',
    ),
    'buddy_years_label': l10nEntry(
      english: 'Time in Qatar',
      arabic: 'مدة إقامتك في قطر',
      hindi: 'Time in Qatar',
      urdu: 'Time in Qatar',
    ),
    'buddy_years_under_1': l10nEntry(
      english: 'Under 1 year',
      arabic: 'أقل من سنة',
      hindi: 'Under 1 year',
      urdu: 'Under 1 year',
    ),
    'buddy_years_1_3': l10nEntry(
      english: '1–3 years',
      arabic: '1–3 سنوات',
      hindi: '1–3 years',
      urdu: '1–3 years',
    ),
    'buddy_years_3_plus': l10nEntry(
      english: '3+ years',
      arabic: '3+ سنوات',
      hindi: '3+ years',
      urdu: '3+ years',
    ),
    'buddy_interests_label': l10nEntry(
      english: 'Interests (optional, up to 5)',
      arabic: 'الاهتمامات (اختياري، حتى 5)',
      hindi: 'Interests (optional, up to 5)',
      urdu: 'Interests (optional, up to 5)',
    ),
    'buddy_save': l10nEntry(
      english: 'Save Buddy profile',
      arabic: 'حفظ ملف الرفيق',
      hindi: 'Save Buddy profile',
      urdu: 'Save Buddy profile',
    ),
    'buddy_opt_out': l10nEntry(
      english: 'Leave Buddy matching',
      arabic: 'مغادرة نظام الرفيق',
      hindi: 'Leave Buddy matching',
      urdu: 'Leave Buddy matching',
    ),
    'buddy_opt_out_confirm': l10nEntry(
      english: 'Remove your Buddy profile? You can join again later.',
      arabic: 'إزالة ملف الرفيق؟ يمكنك الانضمام لاحقاً.',
      hindi: 'Remove your Buddy profile? You can join again later.',
      urdu: 'Remove your Buddy profile? You can join again later.',
    ),
    'buddy_saved': l10nEntry(
      english: 'Buddy profile saved',
      arabic: 'تم حفظ ملف الرفيق',
      hindi: 'Buddy profile saved',
      urdu: 'Buddy profile saved',
    ),
    'buddy_save_failed': l10nEntry(
      english: 'Could not save. Check connection and try again.',
      arabic: 'تعذر الحفظ. تحقق من الاتصال وحاول مجدداً.',
      hindi: 'Could not save. Try again.',
      urdu: 'Could not save. Try again.',
    ),
    'buddy_manage_hint': l10nEntry(
      english: 'Matching suggestions arrive in a future update. You can pause or leave anytime.',
      arabic: 'اقتراحات المطابقة قادمة لاحقاً. يمكنك الإيقاف أو المغادرة في أي وقت.',
      hindi: 'Matching suggestions coming later. Pause or leave anytime.',
      urdu: 'Matching suggestions coming later. Pause or leave anytime.',
    ),
    'buddy_interest_settling_in': l10nEntry(
      english: 'Settling in',
      arabic: 'الاستقرار',
      hindi: 'Settling in',
      urdu: 'Settling in',
    ),
    'buddy_interest_housing': l10nEntry(
      english: 'Housing',
      arabic: 'السكن',
      hindi: 'Housing',
      urdu: 'Housing',
    ),
    'buddy_interest_jobs': l10nEntry(
      english: 'Jobs',
      arabic: 'الوظائف',
      hindi: 'Jobs',
      urdu: 'Jobs',
    ),
    'buddy_interest_schools': l10nEntry(
      english: 'Schools',
      arabic: 'المدارس',
      hindi: 'Schools',
      urdu: 'Schools',
    ),
    'buddy_interest_transport': l10nEntry(
      english: 'Transport',
      arabic: 'المواصلات',
      hindi: 'Transport',
      urdu: 'Transport',
    ),
    'buddy_interest_healthcare': l10nEntry(
      english: 'Healthcare',
      arabic: 'الصحة',
      hindi: 'Healthcare',
      urdu: 'Healthcare',
    ),
    'buddy_interest_legal_admin': l10nEntry(
      english: 'Legal & admin',
      arabic: 'قانون وإجراءات',
      hindi: 'Legal & admin',
      urdu: 'Legal & admin',
    ),
    'buddy_interest_social': l10nEntry(
      english: 'Social life',
      arabic: 'حياة اجتماعية',
      hindi: 'Social life',
      urdu: 'Social life',
    ),
    'buddy_lang_en': l10nEntry(
      english: 'English',
      arabic: 'English',
      hindi: 'English',
      urdu: 'English',
    ),
    'buddy_lang_ar': l10nEntry(
      english: 'Arabic',
      arabic: 'العربية',
      hindi: 'Arabic',
      urdu: 'Arabic',
    ),
    'buddy_lang_hi': l10nEntry(
      english: 'Hindi',
      arabic: 'Hindi',
      hindi: 'हिंदी',
      urdu: 'Hindi',
    ),
    'buddy_lang_ur': l10nEntry(
      english: 'Urdu',
      arabic: 'Urdu',
      hindi: 'Urdu',
      urdu: 'اردو',
    ),
    'buddy_lang_ml': l10nEntry(
      english: 'Malayalam',
      arabic: 'Malayalam',
      hindi: 'Malayalam',
      urdu: 'Malayalam',
    ),
    'buddy_lang_ne': l10nEntry(
      english: 'Nepali',
      arabic: 'Nepali',
      hindi: 'Nepali',
      urdu: 'Nepali',
    ),
    'buddy_lang_bn': l10nEntry(
      english: 'Bengali',
      arabic: 'Bengali',
      hindi: 'Bengali',
      urdu: 'Bengali',
    ),
    'buddy_lang_ta': l10nEntry(
      english: 'Tamil',
      arabic: 'Tamil',
      hindi: 'Tamil',
      urdu: 'Tamil',
    ),
    'buddy_lang_fil': l10nEntry(
      english: 'Filipino',
      arabic: 'Filipino',
      hindi: 'Filipino',
      urdu: 'Filipino',
    ),
    'buddy_err_missingUid': l10nEntry(
      english: 'Sign in required',
      arabic: 'يلزم تسجيل الدخول',
      hindi: 'Sign in required',
      urdu: 'Sign in required',
    ),
    'buddy_err_nicknameEmpty': l10nEntry(
      english: 'Display name required',
      arabic: 'الاسم مطلوب',
      hindi: 'Display name required',
      urdu: 'Display name required',
    ),
    'buddy_err_invalidCountryId': l10nEntry(
      english: 'Choose a supported home country',
      arabic: 'اختر بلداً مدعوماً',
      hindi: 'Choose a supported home country',
      urdu: 'Choose a supported home country',
    ),
    'buddy_err_noSpokenLanguages': l10nEntry(
      english: 'Select at least one spoken language',
      arabic: 'اختر لغة واحدة على الأقل',
      hindi: 'Select at least one spoken language',
      urdu: 'Select at least one spoken language',
    ),
    'buddy_err_helperIneligibleTenure': l10nEntry(
      english: 'Helpers need 1+ years in Qatar',
      arabic: 'المساعدون يحتاجون سنة+ في قطر',
      hindi: 'Helpers need 1+ years in Qatar',
      urdu: 'Helpers need 1+ years in Qatar',
    ),
    'buddy_err_noActiveRole': l10nEntry(
      english: 'Enable newcomer or helper role',
      arabic: 'فعّل دور الوافد أو المساعد',
      hindi: 'Enable newcomer or helper role',
      urdu: 'Enable newcomer or helper role',
    ),
    'buddy_err_missingAdultAttestation': l10nEntry(
      english: '18+ self-attestation required',
      arabic: 'يلزم إقرار 18+',
      hindi: '18+ self-attestation required',
      urdu: '18+ self-attestation required',
    ),
    'buddy_hub_title': l10nEntry(
      english: 'Buddy matching',
      arabic: 'مطابقة الرفيق',
      hindi: 'Buddy matching',
      urdu: 'Buddy matching',
    ),
    'buddy_edit_profile': l10nEntry(
      english: 'Edit Buddy profile',
      arabic: 'تعديل ملف الرفيق',
      hindi: 'Edit Buddy profile',
      urdu: 'Edit Buddy profile',
    ),
    'buddy_setup_profile': l10nEntry(
      english: 'Set up your Buddy profile',
      arabic: 'إعداد ملف الرفيق',
      hindi: 'Set up your Buddy profile',
      urdu: 'Set up your Buddy profile',
    ),
    'buddy_suggestions_title': l10nEntry(
      english: 'Suggested helpers',
      arabic: 'مساعدون مقترحون',
      hindi: 'Suggested helpers',
      urdu: 'Suggested helpers',
    ),
    'buddy_suggestions_empty': l10nEntry(
      english: 'No helpers match yet. Try again later or adjust your profile.',
      arabic: 'لا يوجد مساعدون حالياً. حاول لاحقاً أو عدّل ملفك.',
      hindi: 'No helpers match yet.',
      urdu: 'No helpers match yet.',
    ),
    'buddy_send_request': l10nEntry(
      english: 'Send intro request',
      arabic: 'إرسال طلب تعارف',
      hindi: 'Send intro request',
      urdu: 'Send intro request',
    ),
    'buddy_intro_orient': l10nEntry(
      english: 'Hi, I\'m new here — could you help me get oriented?',
      arabic: 'مرحباً، أنا جديد هنا — هل يمكنك مساعدتي على التأقلم؟',
      hindi: 'Hi, I\'m new here — could you help me get oriented?',
      urdu: 'Hi, I\'m new here — could you help me get oriented?',
    ),
    'buddy_intro_housing': l10nEntry(
      english: 'Hi, I\'m looking for tips on housing and areas.',
      arabic: 'مرحباً، أبحث عن نصائح حول السكن والمناطق.',
      hindi: 'Hi, I\'m looking for housing tips.',
      urdu: 'Hi, I\'m looking for housing tips.',
    ),
    'buddy_intro_daily': l10nEntry(
      english: 'Hi, I\'d love tips on daily life in Qatar.',
      arabic: 'مرحباً، أود نصائح عن الحياة اليومية في قطر.',
      hindi: 'Hi, I\'d love daily life tips.',
      urdu: 'Hi, I\'d love daily life tips.',
    ),
    'buddy_optional_note': l10nEntry(
      english: 'Optional short note',
      arabic: 'ملاحظة قصيرة (اختياري)',
      hindi: 'Optional short note',
      urdu: 'Optional short note',
    ),
    'buddy_request_sent': l10nEntry(
      english: 'Intro request sent',
      arabic: 'تم إرسال الطلب',
      hindi: 'Intro request sent',
      urdu: 'Intro request sent',
    ),
    'buddy_request_failed': l10nEntry(
      english: 'Could not send request. Try again later.',
      arabic: 'تعذر إرسال الطلب. حاول لاحقاً.',
      hindi: 'Could not send request.',
      urdu: 'Could not send request.',
    ),
    'buddy_intro_moderation_blocked': l10nEntry(
      english: 'Your intro did not pass community safety checks.',
      arabic: 'Your intro did not pass community safety checks.',
      hindi: 'Your intro did not pass community safety checks.',
      urdu: 'Your intro did not pass community safety checks.',
    ),
    'buddy_threads_empty': l10nEntry(
      english: 'No active Buddy chats yet.',
      arabic: 'No active Buddy chats yet.',
      hindi: 'No active Buddy chats yet.',
      urdu: 'No active Buddy chats yet.',
    ),
    'buddy_request_blocked': l10nEntry(
      english: 'You cannot send a request to this user.',
      arabic: 'You cannot send a request to this user.',
      hindi: 'You cannot send a request to this user.',
      urdu: 'You cannot send a request to this user.',
    ),
    'buddy_threads_title': l10nEntry(
      english: 'Buddy chats',
      arabic: 'Buddy chats',
      hindi: 'Buddy chats',
      urdu: 'Buddy chats',
    ),
    'buddy_open_chat': l10nEntry(
      english: 'Open chat',
      arabic: 'Open chat',
      hindi: 'Open chat',
      urdu: 'Open chat',
    ),
    'buddy_chat_title': l10nEntry(
      english: 'Buddy chat',
      arabic: 'Buddy chat',
      hindi: 'Buddy chat',
      urdu: 'Buddy chat',
    ),
    'buddy_chat_hint': l10nEntry(
      english: 'Message your buddy…',
      arabic: 'Message your buddy…',
      hindi: 'Message your buddy…',
      urdu: 'Message your buddy…',
    ),
    'buddy_chat_unauthorized': l10nEntry(
      english: 'You cannot access this chat.',
      arabic: 'You cannot access this chat.',
      hindi: 'You cannot access this chat.',
      urdu: 'You cannot access this chat.',
    ),
    'buddy_chat_ended': l10nEntry(
      english: 'This Buddy chat is no longer active.',
      arabic: 'This Buddy chat is no longer active.',
      hindi: 'This Buddy chat is no longer active.',
      urdu: 'This Buddy chat is no longer active.',
    ),
    'buddy_incoming_title': l10nEntry(
      english: 'Intro requests for you',
      arabic: 'طلبات التعارف لك',
      hindi: 'Intro requests for you',
      urdu: 'Intro requests for you',
    ),
    'buddy_outgoing_title': l10nEntry(
      english: 'Your intro requests',
      arabic: 'طلباتك',
      hindi: 'Your intro requests',
      urdu: 'Your intro requests',
    ),
    'buddy_accept': l10nEntry(
      english: 'Accept',
      arabic: 'قبول',
      hindi: 'Accept',
      urdu: 'Accept',
    ),
    'buddy_safety_platform_title': l10nEntry(
      english: 'Stay in Raabta for now',
      arabic: 'Stay in Raabta for now',
      hindi: 'Stay in Raabta for now',
      urdu: 'Stay in Raabta for now',
    ),
    'buddy_safety_platform_body': l10nEntry(
      english:
          'This message looks like a request to move off-app. Raabta cannot verify people or payments outside the app. Be cautious sharing contact details or links.',
      arabic:
          'This message looks like a request to move off-app. Raabta cannot verify people or payments outside the app. Be cautious sharing contact details or links.',
      hindi:
          'This message looks like a request to move off-app. Raabta cannot verify people or payments outside the app. Be cautious sharing contact details or links.',
      urdu:
          'This message looks like a request to move off-app. Raabta cannot verify people or payments outside the app. Be cautious sharing contact details or links.',
    ),
    'buddy_safety_financial_title': l10nEntry(
      english: 'Money or fees mentioned',
      arabic: 'Money or fees mentioned',
      hindi: 'Money or fees mentioned',
      urdu: 'Money or fees mentioned',
    ),
    'buddy_safety_financial_body': l10nEntry(
      english:
          'Be careful with loans, advance fees, or urgent transfers. Buddy helpers are not verified by Raabta — never send money to someone you only met in-app.',
      arabic:
          'Be careful with loans, advance fees, or urgent transfers. Buddy helpers are not verified by Raabta — never send money to someone you only met in-app.',
      hindi:
          'Be careful with loans, advance fees, or urgent transfers. Buddy helpers are not verified by Raabta — never send money to someone you only met in-app.',
      urdu:
          'Be careful with loans, advance fees, or urgent transfers. Buddy helpers are not verified by Raabta — never send money to someone you only met in-app.',
    ),
    'buddy_decline': l10nEntry(
      english: 'Not now',
      arabic: 'ليس الآن',
      hindi: 'Not now',
      urdu: 'Not now',
    ),
    'buddy_cancel_request': l10nEntry(
      english: 'Cancel request',
      arabic: 'إلغاء الطلب',
      hindi: 'Cancel request',
      urdu: 'Cancel request',
    ),
    'buddy_self_declared_label': l10nEntry(
      english: 'Self-declared · not verified',
      arabic: 'ذاتي · غير موثق',
      hindi: 'Self-declared · not verified',
      urdu: 'Self-declared · not verified',
    ),
    'buddy_loading': l10nEntry(
      english: 'Loading…',
      arabic: 'جاري التحميل…',
      hindi: 'Loading…',
      urdu: 'Loading…',
    ),
    'buddy_error_generic': l10nEntry(
      english: 'Something went wrong. Pull to refresh.',
      arabic: 'حدث خطأ. اسحب للتحديث.',
      hindi: 'Something went wrong.',
      urdu: 'Something went wrong.',
    ),
  };
}
