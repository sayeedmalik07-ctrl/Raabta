import 'package:raabta/core/l10n/locale_catalog_entry.dart';

abstract final class ClassifiedsChatSafetyStrings {
  static String t(String key, [String locale = 'English']) {
    final map = _catalog[key];
    if (map == null) return key;
    return map[locale] ?? map['English'] ?? key;
  }

  static final _catalog = <String, Map<String, String>>{
    'menu_report': l10nEntry(
      english: 'Report conversation',
      arabic: 'الإبلاغ عن المحادثة',
      hindi: 'बातचीत की रिपोर्ट करें',
      urdu: 'گفتگو کی رپورٹ کریں',
      malayalam: 'സംഭാഷണം റിപ്പോർട്ട് ചെയ്യുക',
      nepali: 'कुराकानी रिपोर्ट गर्नुहोस्',
      bengali: 'কথোপকথন রিপোর্ট করুন',
      tamil: 'உரையாடலை புகார் செய்',
      filipino: 'I-report ang usapan',
    ),
    'menu_block_user': l10nEntry(
      english: 'Block user',
      arabic: 'حظر المستخدم',
      hindi: 'उपयोगकर्ता को ब्लॉक करें',
      urdu: 'صارف کو بلاک کریں',
      malayalam: 'ഉപയോക്താവിനെ ബ്ലോക്ക് ചെയ്യുക',
      nepali: 'प्रयोगकर्तालाई ब्लक गर्नुहोस्',
      bengali: 'ব্যবহারকারীকে ব্লক করুন',
      tamil: 'பயனரை தடு',
      filipino: 'I-block ang user',
    ),
    'block_confirm_title': l10nEntry(
      english: 'Block this user?',
      arabic: 'حظر هذا المستخدم؟',
      hindi: 'इस उपयोगकर्ता को ब्लॉक करें?',
      urdu: 'اس صارف کو بلاک کریں؟',
      malayalam: 'ഈ ഉപയോക്താവിനെ ബ്ലോക്ക് ചെയ്യണോ?',
      nepali: 'यो प्रयोगकर्तालाई ब्लक गर्ने?',
      bengali: 'এই ব্যবহারকারীকে ব্লক করবেন?',
      tamil: 'இந்த பயனரை தடுக்கவா?',
      filipino: 'I-block ang user na ito?',
    ),
    'block_confirm_body': l10nEntry(
      english:
          'They will not be able to message you in classifieds chats, and you will not see their messages.',
      arabic:
          'لن يتمكنوا من مراسلتك في محادثات الإعلانات، ولن ترى رسائلهم.',
      hindi:
          'वे क्लासिफ़ाइड्स चैट में आपको संदेश नहीं भेज पाएँगे, और आप उनके संदेश नहीं देखेंगे।',
      urdu:
          'وہ classifieds chats میں آپ کو پیغام نہیں بھیج سکیں گے، اور آپ ان کے پیغامات نہیں دیکھیں گے۔',
      malayalam:
          'classifieds chats-ൽ അവർക്ക് നിങ്ങൾക്ക് message അയയ്ക്കാൻ കഴിയില്ല; അവരുടെ messages നിങ്ങൾക്ക് കാണില്ല.',
      nepali:
          'उनीहरू classifieds chats मा तपाईंलाई message पठाउन सक्दैनन्, र तपाईंले उनीहरूका messages देख्नुहुने छैन।',
      bengali:
          'তারা classifieds chats-এ আপনাকে message পাঠাতে পারবে না, এবং আপনি তাদের messages দেখবেন না।',
      tamil:
          'classifieds chats-ல் அவர்கள் உங்களுக்கு message அனுப்ப முடியாது; அவர்கள் messages தெரியாது.',
      filipino:
          'Hindi ka nila mauusap sa classifieds chats, at hindi mo makikita ang kanilang messages.',
    ),
    'block_success': l10nEntry(
      english: 'User blocked',
      arabic: 'تم حظر المستخدم',
      hindi: 'उपयोगकर्ता ब्लॉक किया गया',
      urdu: 'صارف بلاک ہو گیا',
      malayalam: 'ഉപയോക്താവിനെ ബ്ലോക്ക് ചെയ്തു',
      nepali: 'प्रयोगकर्ता ब्लक गरियो',
      bengali: 'ব্যবহারকারী ব্লক করা হয়েছে',
      tamil: 'பயனர் தடுக்கப்பட்டார்',
      filipino: 'Na-block ang user',
    ),
    'report_success': l10nEntry(
      english: 'Report submitted. Thank you.',
      arabic: 'تم إرسال البلاغ. شكراً لك.',
      hindi: 'रिपोर्ट भेज दी गई। धन्यवाद।',
      urdu: 'رپورٹ جمع ہو گئی۔ شکریہ۔',
      malayalam: 'റിപ്പോർട്ട് സമർപ്പിച്ചു. നന്ദി.',
      nepali: 'रिपोर्ट पेश गरियो। धन्यवाद।',
      bengali: 'রিপোর্ট জমা হয়েছে। ধন্যবাদ।',
      tamil: 'புகார் அனுப்பப்பட்டது. நன்றி.',
      filipino: 'Na-submit ang report. Salamat.',
    ),
    'report_pick_message': l10nEntry(
      english: 'Which message are you reporting?',
      arabic: 'أي رسالة تبلّغ عنها؟',
      hindi: 'आप किस संदेश की रिपोर्ट कर रहे हैं?',
      urdu: 'آپ کس پیغام کی رپورٹ کر رہے ہیں؟',
      malayalam: 'ഏത് message റിപ്പോർട്ട് ചെയ്യുന്നു?',
      nepali: 'कुन message रिपोर्ट गर्दै हुनुहुन्छ?',
      bengali: 'কোন message রিপোর্ট করছেন?',
      tamil: 'எந்த message-ஐ புகார் செய்கிறீர்கள்?',
      filipino: 'Aling message ang irereport?',
    ),
    'send_failed_generic': l10nEntry(
      english: "Message couldn't be sent. Try again later.",
      arabic: 'تعذّر إرسال الرسالة. حاول لاحقاً.',
      hindi: 'संदेश नहीं भेजा जा सका। बाद में पुनः प्रयास करें।',
      urdu: 'پیغام نہیں بھیجا جا سکا۔ بعد میں دوبارہ کوشش کریں۔',
      malayalam: 'Message അയയ്ക്കാൻ കഴിഞ്ഞില്ല. പിന്നീട് ശ്രമിക്കുക.',
      nepali: 'Message पठाउन सकिएन। पछि फेरि प्रयास गर्नुहोस्।',
      bengali: 'Message পাঠানো যায়নি। পরে আবার চেষ্টা করুন।',
      tamil: 'Message அனுப்ப முடியவில்லை. பின்னர் முயற்சிக்கவும்.',
      filipino: 'Hindi naipadala ang message. Subukan muli mamaya.',
    ),
    'composer_disabled_hint': l10nEntry(
      english: "You can't send messages in this conversation right now.",
      arabic: 'لا يمكنك إرسال رسائل في هذه المحادثة حالياً.',
      hindi: 'अभी इस बातचीत में संदेश नहीं भेज सकते।',
      urdu: 'فی الحال اس گفتگو میں پیغام نہیں بھیج سکتے۔',
      malayalam: 'ഈ സംഭാഷണത്തിൽ ഇപ്പോൾ message അയയ്ക്കാൻ കഴിയില്ല.',
      nepali: 'अहिले यो कुराकानीमा message पठाउन मिल्दैन।',
      bengali: 'এখন এই কথোপকথনে message পাঠাতে পারবেন না।',
      tamil: 'இந்த உரையாடலில் இப்போது message அனுப்ப முடியாது.',
      filipino: 'Hindi ka makakapagpadala ng message sa usapang ito ngayon.',
    ),
    'blocked_users_title': l10nEntry(
      english: 'Blocked users',
      arabic: 'المستخدمون المحظورون',
      hindi: 'ब्लॉक किए उपयोगकर्ता',
      urdu: 'بلاک شدہ صارفین',
      malayalam: 'ബ്ലോക്ക് ചെയ്ത ഉപയോക്താക്കൾ',
      nepali: 'ब्लक गरिएका प्रयोगकर्ताहरू',
      bengali: 'ব্লক করা ব্যবহারকারী',
      tamil: 'தடுக்கப்பட்ட பயனர்கள்',
      filipino: 'Mga naka-block na user',
    ),
    'blocked_users_empty': l10nEntry(
      english: 'You have not blocked anyone.',
      arabic: 'لم تحظر أحداً.',
      hindi: 'आपने किसी को ब्लॉक नहीं किया है।',
      urdu: 'آپ نے کسی کو بلاک نہیں کیا۔',
      malayalam: 'നിങ്ങൾ ആരെയും ബ്ലോക്ക് ചെയ്തിട്ടില്ല.',
      nepali: 'तपाईंले कसैलाई ब्लक गर्नुभएको छैन।',
      bengali: 'আপনি কাউকে ব্লক করেননি।',
      tamil: 'நீங்கள் யாரையும் தடுக்கவில்லை.',
      filipino: 'Wala kang na-block na user.',
    ),
    'unblock_action': l10nEntry(
      english: 'Unblock',
      arabic: 'إلغاء الحظر',
      hindi: 'अनब्लॉक करें',
      urdu: 'بلاک ہٹائیں',
      malayalam: 'അൺബ്ലോക്ക്',
      nepali: 'अनब्लक',
      bengali: 'আনব্লক',
      tamil: 'தடை நீக்கு',
      filipino: 'I-unblock',
    ),
    'unblock_success': l10nEntry(
      english: 'User unblocked',
      arabic: 'تم إلغاء الحظر',
      hindi: 'उपयोगकर्ता अनब्लॉक किया गया',
      urdu: 'صارف کا بلاک ہٹا دیا گیا',
      malayalam: 'ഉപയോക്താവിനെ അൺബ്ലോക്ക് ചെയ്തു',
      nepali: 'प्रयोगकर्ता अनब्लक गरियो',
      bengali: 'ব্যবহারকারী আনব্লক করা হয়েছে',
      tamil: 'பயனர் தடை நீக்கப்பட்டது',
      filipino: 'Na-unblock ang user',
    ),
    'blocked_user_row_label': l10nEntry(
      english: 'User ID: {uid}',
      arabic: 'معرّف المستخدم: {uid}',
      hindi: 'उपयोगकर्ता ID: {uid}',
      urdu: 'صارف ID: {uid}',
      malayalam: 'User ID: {uid}',
      nepali: 'प्रयोगकर्ता ID: {uid}',
      bengali: 'User ID: {uid}',
      tamil: 'User ID: {uid}',
      filipino: 'User ID: {uid}',
    ),
    'safety_unavailable_no_peer': l10nEntry(
      english: 'Safety actions are unavailable until someone messages in this chat.',
      arabic: 'إجراءات الأمان غير متاحة حتى يرسل أحد رسالة في هذه المحادثة.',
      hindi: 'कोई संदेश आने तक सुरक्षा विकल्प उपलब्ध नहीं हैं।',
      urdu: 'کسی کے message بھیجنے تک safety actions دستیاب نہیں۔',
      malayalam: 'ആരെങ്കിലും message അയയ്ക്കുന്നത് വരെ safety actions ലഭ്യമല്ല.',
      nepali: 'कसैले message नपठाएसम्म safety actions उपलब्ध छैन।',
      bengali: 'কেউ message না পাঠানো পর্যন্ত safety actions unavailable।',
      tamil: 'யாராவது message அனுப்பும் வரை safety actions unavailable.',
      filipino: 'Hindi available ang safety actions hanggang may message sa chat.',
    ),
  };

  static String format(String key, String locale, {required Map<String, String> params}) {
    var out = t(key, locale);
    for (final e in params.entries) {
      out = out.replaceAll('{${e.key}}', e.value);
    }
    return out;
  }
}
