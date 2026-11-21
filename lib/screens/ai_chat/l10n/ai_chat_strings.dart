/// Raabta AI chat UI strings — aligned with [AppLocale.supportedLocales].
import 'package:flutter/foundation.dart';
import 'package:raabta/core/l10n/app_locale.dart';
import 'package:raabta/core/l10n/locale_catalog_coverage.dart';

abstract final class AiChatStrings {
  static const supportedLocales = AppLocale.supportedLocales;

  static String t(String key, [String locale = 'English']) {
    final normalized = AppLocale.normalize(locale);
    final map = _catalog[key];
    if (map == null) return key;
    return map[normalized] ?? map['English'] ?? key;
  }

  /// Exposed for catalog parity regression tests only.
  @visibleForTesting
  static Map<String, Set<String>> get localeCoverageReport =>
      buildLocaleCoverageReport(
        catalog: _catalog,
        supportedLocales: supportedLocales,
      );

  static const _en = 'English';
  static const _ar = 'Arabic';
  static const _hi = 'Hindi';
  static const _ur = 'Urdu';
  static const _ml = 'Malayalam';
  static const _ne = 'Nepali';
  static const _bn = 'Bengali';
  static const _fil = 'Filipino';

  static const _catalog = <String, Map<String, String>>{
    'ai_title': {
      _en: 'Raabta',
      _ar: 'Raabta',
      _hi: 'Raabta',
      _ur: 'Raabta',
      _ml: 'Raabta',
      _ne: 'Raabta',
      _bn: 'Raabta',
      _fil: 'Raabta',
    },
    'ai_subtitle': {
      _en: 'Qatar Labour Rights + General Help',
      _ar: 'حقوق العمل في قطر + مساعدة عامة',
      _hi: 'कतर श्रम अधिकार + सामान्य सहायता',
      _ur: 'قطر میں مزدوری کے حقوق + عمومی مدد',
      _ml: 'Qatar labour rights + general help',
      _ne: 'Qatar labour rights + general help',
      _bn: 'Qatar labour rights + general help',
      _fil: 'Qatar labour rights + general help',
    },
    'ai_input_hint': {
      _en: 'Ask about your rights in Qatar…',
      _ar: 'اسأل عن حقوقك في قطر…',
      _hi: 'कतर में अपने अधिकारों के बारे में पूछें…',
      _ur: 'قطر میں اپنے حقوق پوچھیں…',
      _ml: 'Ask about your rights in Qatar…',
      _ne: 'Ask about your rights in Qatar…',
      _bn: 'Ask about your rights in Qatar…',
      _fil: 'Ask about your rights in Qatar…',
    },
    'ai_greeting_morning': {
      _en: 'Good morning',
      _ar: 'صباح الخير',
      _hi: 'सुप्रभात',
    },
    'ai_greeting_afternoon': {
      _en: 'Good afternoon',
      _ar: 'مساء الخير',
      _hi: 'नमस्कार',
    },
    'ai_greeting_evening': {
      _en: 'Good evening',
      _ar: 'مساء الخير',
      _hi: 'शुभ संध्या',
    },
    'ai_welcome_title': {
      _en: 'How can I help you today?',
      _ar: 'كيف يمكنني مساعدتك اليوم؟',
      _hi: 'आज मैं आपकी कैसे मदद करूं?',
    },
    'ai_recent_sessions': {
      _en: 'Recent in this session',
      _ar: 'حديث في هذه الجلسة',
      _hi: 'इस सत्र में हाल ही में',
    },
    'ai_labour_quick_help': {
      _en: '⚖️ Qatar Labour Rights — Quick Help',
      _ar: '⚖️ حقوق العمل — مساعدة سريعة',
      _hi: '⚖️ कतर श्रम अधिकार — त्वरित सहायता',
    },
    'ai_listening': {
      _en: 'Listening… tap mic to stop',
      _ar: 'جاري الاستماع…',
      _hi: 'सुन रहा हूँ…',
    },
    'ai_stop_generating': {
      _en: 'Stop',
      _ar: 'إيقاف',
      _hi: 'रोकें',
      _ur: 'Stop',
      _ml: 'Stop',
      _ne: 'Stop',
      _bn: 'Stop',
      _fil: 'Stop',
    },
    'ai_copy': {_en: 'Copy', _ar: 'نسخ', _hi: 'कॉपी'},
    'ai_retry': {_en: 'Retry', _ar: 'إعادة', _hi: 'पुनः प्रयास'},
    'ai_error_title': {
      _en: 'No answer yet',
      _ar: 'لا إجابة بعد',
      _hi: 'अभी कोई जवाब नहीं',
      _ur: 'No answer yet',
      _ml: 'No answer yet',
      _ne: 'No answer yet',
      _bn: 'No answer yet',
      _fil: 'No answer yet',
    },
    'ai_error_body': {
      _en:
          'Raabta could not reach the service. Check your connection and try again.',
      _ar: 'تعذر على Raabta الوصول إلى الخدمة. تحقق من اتصالك وحاول مرة أخرى.',
      _hi:
          'Raabta सेवा तक नहीं पहुँच सका। अपना कनेक्शन जाँचें और फिर कोशिश करें।',
      _ur:
          'Raabta could not reach the service. Check your connection and try again.',
      _ml:
          'Raabta could not reach the service. Check your connection and try again.',
      _ne:
          'Raabta could not reach the service. Check your connection and try again.',
      _bn:
          'Raabta could not reach the service. Check your connection and try again.',
      _fil:
          'Raabta could not reach the service. Check your connection and try again.',
    },
    'ai_dismiss': {_en: 'Dismiss', _ar: 'تجاهل', _hi: 'बंद करें'},
    'ai_voice_unavailable': {
      _en: 'Voice input requires iOS or Android. Please type your question.',
      _ar: 'الإدخال الصوتي يتطلب iOS أو Android.',
      _hi: 'वॉइस इनपुट के लिए iOS/Android चाहिए।',
    },
    'ai_categories_header': {
      _en: 'Browse by topic',
      _ar: 'تصفح حسب الموضوع',
      _hi: 'विषय के अनुसार देखें',
    },
    'ai_suggested_header': {
      _en: 'Suggested prompts',
      _ar: 'اقتراحات',
      _hi: 'सुझाए गए प्रॉम्प्ट',
    },
    'eosb_explanation_title': {
      _en: 'Your EOSB Explanation',
      _ar: 'شرح مكافأة نهاية الخدمة',
      _hi: 'आपकी EOSB व्याख्या',
    },
    'eosb_follow_up_cta': {
      _en: 'Ask Raabta AI a follow-up',
      _ar: 'اسأل Raabta AI متابعة',
      _hi: 'Raabta AI से follow-up पूछें',
    },
    'eosb_follow_up_hint': {
      _en: 'e.g. Is my employer offer fair?',
      _ar: 'مثلاً: هل عرض صاحب العمل عادل؟',
      _hi: 'जैसे: क्या मेरे employer का offer fair है?',
    },
    'ai_threads_title': {_en: 'Conversations', _ar: 'المحادثات', _hi: 'बातचीत'},
    'ai_new_chat': {_en: 'New chat', _ar: 'محادثة جديدة', _hi: 'नई चैट'},
    'ai_rename_thread': {_en: 'Rename', _ar: 'إعادة تسمية', _hi: 'नाम बदलें'},
    'ai_delete_thread': {_en: 'Delete', _ar: 'حذف', _hi: 'हटाएं'},
    'ai_regenerate': {_en: 'Regenerate', _ar: 'إعادة', _hi: 'फिर से'},
    'ai_edit_message': {_en: 'Edit', _ar: 'تعديل', _hi: 'संपादित'},
    'ai_quota_remaining': {
      _en: '{n} messages left today',
      _ar: '{n} رسائل متبقية اليوم',
      _hi: 'आज {n} संदेश बचे',
    },
    'ai_quota_upgrade': {
      _en: 'Upgrade for unlimited AI',
      _ar: 'ترقية للحصول على AI غير محدود',
      _hi: 'असीमित AI के लिए अपग्रेड',
    },
    'ai_context_eosb': {_en: 'EOSB', _ar: 'EOSB', _hi: 'EOSB'},
    'ai_context_visa': {_en: 'Visa guide', _ar: 'دليل التأشيرة', _hi: 'Visa'},
    'ai_context_vault': {_en: 'Document', _ar: 'مستند', _hi: 'Document'},
    'ai_context_health': {
      _en: 'Health insurance',
      _ar: 'التأمين الصحي',
      _hi: 'Health insurance',
    },
    'ai_open_in_chat': {
      _en: 'Ask in Raabta AI',
      _ar: 'اسأل في Raabta AI',
      _hi: 'Raabta AI में पूछें',
    },
    'ai_attach_document': {
      _en: 'Attach photo',
      _ar: 'إرفاق صورة',
      _hi: 'Attach photo',
    },
    'ai_research_mode': {
      _en: 'Research mode',
      _ar: 'وضع البحث',
      _hi: 'Research mode',
    },
    'ai_research_premium': {
      _en: 'Premium — labour law research with citations',
      _ar: 'Premium — بحث قانون العمل',
      _hi: 'Premium research',
    },
    'ai_attachment_ready': {
      _en: 'Document attached',
      _ar: 'تم إرفاق المستند',
      _hi: 'Document attached',
    },
    'ai_hero_subtitle': {
      _en: 'Ask anything about life and work in Qatar',
      _ar: 'اسأل عن أي شيء يخص الحياة والعمل في قطر',
      _hi: 'कतर में जीवन और काम के बारे में कुछ भी पूछें',
    },
    'ai_browse_topics': {
      _en: 'Browse topics',
      _ar: 'تصفح المواضيع',
      _hi: 'विषय देखें',
    },
    'ai_chip_eosb': {_en: 'EOSB', _ar: 'EOSB', _hi: 'EOSB'},
    'ai_chip_visa': {_en: 'Visa', _ar: 'تأشيرة', _hi: 'Visa'},
    'ai_chip_document': {
      _en: 'My documents',
      _ar: 'مستنداتي',
      _hi: 'Documents',
    },
    'ai_chip_labour': {
      _en: 'Labour rights',
      _ar: 'حقوق العمل',
      _hi: 'Labour rights',
    },
    'ai_chip_eosb_prompt': {
      _en:
          'Explain my end-of-service benefits and whether my employer offer is fair.',
      _ar: 'اشرح مكافأة نهاية خدمتي وهل عرض صاحب العمل عادل.',
      _hi: 'Explain my EOSB and whether my employer offer is fair.',
    },
    'ai_chip_visa_prompt': {
      _en: 'Help me with my Qatar visa status, renewal, or family visa.',
      _ar: 'ساعدني في حالة تأشيرتي أو التجديد أو تأشيرة العائلة.',
      _hi: 'Help me with my Qatar visa or family visa.',
    },
    'ai_chip_document_prompt': {
      _en: 'Help me understand my QID, work permit, or employment contract.',
      _ar: 'ساعدني في فهم بطاقتي الشخصية أو تصريح العمل أو عقد العمل.',
      _hi: 'Help me understand my QID or employment contract.',
    },
    'ai_chip_labour_prompt': {
      _en:
          'What are my labour rights if my employer withholds salary or passport?',
      _ar: 'ما حقوقي إذا حجب صاحب العمل راتبي أو جواز سفري؟',
      _hi: 'What are my rights if employer withholds salary or passport?',
    },
    'ai_menu_voice_on': {
      _en: 'Voice responses on',
      _ar: 'الردود الصوتية مفعّلة',
      _hi: 'Voice on',
    },
    'ai_menu_voice_off': {
      _en: 'Voice responses off',
      _ar: 'الردود الصوتية متوقفة',
      _hi: 'Voice off',
    },
    'ai_menu_options': {
      _en: 'More options',
      _ar: 'المزيد',
      _hi: 'More options',
    },
    'ai_take_photo': {_en: 'Take photo', _ar: 'التقاط صورة', _hi: 'Take photo'},
    'ai_save': {_en: 'Save', _ar: 'حفظ', _hi: 'Save'},
    'ai_recent_empty': {
      _en: 'Your recent conversations will appear here.',
      _ar: 'ستظهر محادثاتك الأخيرة هنا.',
      _hi: 'Recent conversations appear here.',
    },
    'ai_cat_general_title': {_en: 'General', _ar: 'عام', _hi: 'General'},
    'ai_cat_general_desc': {
      _en: 'Everyday questions',
      _ar: 'أسئلة يومية',
      _hi: 'Everyday questions',
    },
    'ai_cat_general_prompt': {
      _en: 'Help me with a general question about life in Qatar.',
      _ar: 'ساعدني في سؤال عام عن الحياة في قطر.',
      _hi: 'Help with a general question about life in Qatar.',
    },
    'ai_cat_document_title': {
      _en: 'Documents',
      _ar: 'مستندات',
      _hi: 'Documents',
    },
    'ai_cat_document_desc': {
      _en: 'Forms and paperwork',
      _ar: 'نماذج وأوراق',
      _hi: 'Forms and paperwork',
    },
    'ai_cat_document_prompt': {
      _en: 'Help me understand this document: ',
      _ar: 'ساعدني في فهم هذا المستند: ',
      _hi: 'Help me understand this document: ',
    },
    'ai_cat_translation_title': {
      _en: 'Translation',
      _ar: 'ترجمة',
      _hi: 'Translation',
    },
    'ai_cat_translation_desc': {
      _en: 'Translate text',
      _ar: 'ترجمة النص',
      _hi: 'Translate text',
    },
    'ai_cat_translation_prompt': {
      _en: 'Translate this for me: ',
      _ar: 'ترجم هذا لي: ',
      _hi: 'Translate this for me: ',
    },
    'ai_cat_labour_title': {
      _en: 'Labour law',
      _ar: 'قانون العمل',
      _hi: 'Labour law',
    },
    'ai_cat_labour_desc': {
      _en: 'Worker rights',
      _ar: 'حقوق العامل',
      _hi: 'Worker rights',
    },
    'ai_cat_labour_prompt': {
      _en: 'Explain my labour rights regarding: ',
      _ar: 'اشرح حقوقي العمالية بخصوص: ',
      _hi: 'Explain my labour rights regarding: ',
    },
    'ai_cat_finance_title': {_en: 'Finance', _ar: 'مالية', _hi: 'Finance'},
    'ai_cat_finance_desc': {
      _en: 'Money and bills',
      _ar: 'المال والفواتير',
      _hi: 'Money and bills',
    },
    'ai_cat_finance_prompt': {
      _en: 'Help me with a finance question: ',
      _ar: 'ساعدني في سؤال مالي: ',
      _hi: 'Help me with a finance question: ',
    },
    'ai_cat_health_title': {_en: 'Healthcare', _ar: 'صحة', _hi: 'Healthcare'},
    'ai_cat_health_desc': {
      _en: 'Insurance and clinics',
      _ar: 'التأمين والعيادات',
      _hi: 'Insurance and clinics',
    },
    'ai_cat_health_prompt': {
      _en: 'Help me with a healthcare question: ',
      _ar: 'ساعدني في سؤال صحي: ',
      _hi: 'Help me with a healthcare question: ',
    },
    'ai_cat_housing_title': {_en: 'Housing', _ar: 'سكن', _hi: 'Housing'},
    'ai_cat_housing_desc': {
      _en: 'Rent and leases',
      _ar: 'الإيجار والعقود',
      _hi: 'Rent and leases',
    },
    'ai_cat_housing_prompt': {
      _en: 'Help me with a housing question: ',
      _ar: 'ساعدني في سؤال عن السكن: ',
      _hi: 'Help me with a housing question: ',
    },
    'ai_cat_visa_title': {_en: 'Visa', _ar: 'تأشيرة', _hi: 'Visa'},
    'ai_cat_visa_desc': {
      _en: 'Permits and status',
      _ar: 'التصاريح والحالة',
      _hi: 'Permits and status',
    },
    'ai_cat_visa_prompt': {
      _en: 'Help me with a visa or permit question: ',
      _ar: 'ساعدني في سؤال عن التأشيرة: ',
      _hi: 'Help me with a visa question: ',
    },
    'ai_cat_career_title': {_en: 'Career', _ar: 'مهنة', _hi: 'Career'},
    'ai_cat_career_desc': {
      _en: 'Jobs and CVs',
      _ar: 'الوظائف والسيرة',
      _hi: 'Jobs and CVs',
    },
    'ai_cat_career_prompt': {
      _en: 'Help me with my career: ',
      _ar: 'ساعدني في مسيرتي المهنية: ',
      _hi: 'Help me with my career: ',
    },
    'ai_labour_disclaimer': {
      _en:
          'General guidance only — not legal advice. For disputes: call ADLSA 16008 (24/7), Unified Complaints Portal (mol.gov.qa, NAS login), or SMS 5+QID to 92727.',
      _ar:
          'إرشادات عامة فقط — ليست استشارة قانونية. للنزاعات: اتصل بـ ADLSA 16008 (24/7)، بوابة الشكاوى الموحدة mol.gov.qa (تسجيل NAS)، أو SMS: 5 + رقم الهوية إلى 92727.',
      _hi:
          'General guidance only — not legal advice. Disputes: ADLSA 16008 (24/7), Unified Complaints Portal mol.gov.qa (NAS login), SMS 5+QID to 92727.',
      _ur:
          'General guidance only — not legal advice. Disputes: ADLSA 16008 (24/7), Unified Complaints Portal mol.gov.qa (NAS login), SMS 5+QID to 92727.',
      _ml:
          'General guidance only — not legal advice. Disputes: ADLSA 16008 (24/7), Unified Complaints Portal mol.gov.qa (NAS login), SMS 5+QID to 92727.',
      _ne:
          'General guidance only — not legal advice. Disputes: ADLSA 16008 (24/7), Unified Complaints Portal mol.gov.qa (NAS login), SMS 5+QID to 92727.',
      _bn:
          'General guidance only — not legal advice. Disputes: ADLSA 16008 (24/7), Unified Complaints Portal mol.gov.qa (NAS login), SMS 5+QID to 92727.',
      _fil:
          'General guidance only — not legal advice. Disputes: ADLSA 16008 (24/7), Unified Complaints Portal mol.gov.qa (NAS login), SMS 5+QID to 92727.',
    },
    'ai_copied': {
      _en: 'Copied to clipboard',
      _ar: 'تم النسخ',
      _hi: 'क्लिपबोर्ड पर कॉपी किया',
    },
    'ai_tier_haiku': {_en: 'Fast', _ar: 'سريع', _hi: 'Fast'},
    'ai_tier_sonnet': {_en: 'Advanced', _ar: 'متقدم', _hi: 'Advanced'},
    'ai_tier_research': {_en: 'Research', _ar: 'بحث', _hi: 'Research'},
    'ai_personalized_header': {
      _en: 'Suggested for you',
      _ar: 'مقترح لك',
      _hi: 'Suggested for you',
    },
    'ai_persona_starters_header': {
      _en: 'Start with your situation',
      _ar: 'ابدأ حسب وضعك',
      _hi: 'Start with your situation',
      _ur: 'Start with your situation',
      _ml: 'Start with your situation',
      _ne: 'Start with your situation',
      _bn: 'Start with your situation',
      _fil: 'Start with your situation',
    },
    'ai_quick_topics_header': {
      _en: 'Quick topics',
      _ar: 'مواضيع سريعة',
      _hi: 'Quick topics',
      _ur: 'Quick topics',
      _ml: 'Quick topics',
      _ne: 'Quick topics',
      _bn: 'Quick topics',
      _fil: 'Quick topics',
    },
    'ai_contextual_actions_header': {
      _en: 'Helpful next steps',
      _ar: 'خطوات مفيدة',
      _hi: 'Helpful next steps',
      _ur: 'Helpful next steps',
      _ml: 'Helpful next steps',
      _ne: 'Helpful next steps',
      _bn: 'Helpful next steps',
      _fil: 'Helpful next steps',
    },
    'ai_feed_teasers_header': {
      _en: 'From your feed',
      _ar: 'من خلاصتك',
      _hi: 'From your feed',
      _ur: 'From your feed',
      _ml: 'From your feed',
      _ne: 'From your feed',
      _bn: 'From your feed',
      _fil: 'From your feed',
    },
    'ai_personal_profession': {
      _en: 'What labour rights should I know as a {profession} in Qatar?',
      _ar: 'ما حقوق العمل التي يجب أن أعرفها كـ {profession} في قطر؟',
      _hi: 'What labour rights should I know as a {profession} in Qatar?',
    },
    'ai_personal_area': {
      _en: 'What should I know about living and working in {area}?',
      _ar: 'ماذا يجب أن أعرف عن العيش والعمل في {area}؟',
      _hi: 'What should I know about living in {area}?',
    },
    'ai_personal_nationality': {
      _en: 'Tips for {nationality} expats settling in Qatar?',
      _ar: 'نصائح للمغتربين من {nationality} في قطر؟',
      _hi: 'Tips for {nationality} expats in Qatar?',
    },
    'ai_personal_score_documentation': {
      _en: 'Help me improve my visa and document readiness in Qatar.',
      _ar: 'ساعدني في تحسين جاهزية تأشيرتي ومستنداتي.',
      _hi: 'Help me with visa and document readiness in Qatar.',
    },
    'ai_personal_score_career': {
      _en: 'How can I advance my career and job security in Qatar?',
      _ar: 'كيف أطور مسيرتي المهنية وأمان وظيفتي في قطر؟',
      _hi: 'How can I advance my career in Qatar?',
    },
    'ai_personal_score_housing': {
      _en: 'What should I check before signing a rental contract in Qatar?',
      _ar: 'ماذا يجب أن أتحقق قبل توقيع عقد إيجار في قطر؟',
      _hi: 'What to check before signing a rental contract in Qatar?',
    },
    'ai_personal_score_financial': {
      _en: 'Help me manage money and remittances better as an expat.',
      _ar: 'ساعدني في إدارة الأموال والحوالات كمغترب.',
      _hi: 'Help me manage money and remittances in Qatar.',
    },
    'ai_personal_score_health': {
      _en: 'Explain health insurance and clinic access for workers in Qatar.',
      _ar: 'اشرح التأمين الصحي والوصول للعيادات للعمال.',
      _hi: 'Explain health insurance for workers in Qatar.',
    },
    'ai_personal_score_community': {
      _en: 'How can I connect with my community and find trusted services?',
      _ar: 'كيف أتواصل مع مجتمعي وأجد خدمات موثوقة؟',
      _hi: 'How can I connect with my community in Qatar?',
    },
    'ai_reply': {_en: 'Reply', _ar: 'رد', _hi: 'Reply'},
    'ai_speak': {_en: 'Read aloud', _ar: 'قراءة بصوت', _hi: 'Read aloud'},
    'ai_reply_prefix': {
      _en: 'Regarding: "{quote}"\n\n',
      _ar: 'بخصوص: "{quote}"\n\n',
      _hi: 'Regarding: "{quote}"\n\n',
    },
  };
}
