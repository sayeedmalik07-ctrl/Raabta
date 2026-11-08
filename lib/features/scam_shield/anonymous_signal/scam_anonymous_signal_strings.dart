/// Phase 20 consent copy (PDPPL / Law 13 of 2016 aligned — not legal advice).
abstract final class ScamAnonymousSignalStrings {
  static String t(String key, [String locale = 'English']) {
    final map = _catalog[key];
    if (map == null) return key;
    return map[locale] ?? map['English'] ?? key;
  }

  static final _catalog = <String, Map<String, String>>{
    'ss_signal_consent_title': {
      'English': 'Help improve Scam Shield (optional)',
      'Arabic': 'ساعد في تحسين درع الاحتيال (اختياري)',
    },
    'ss_signal_consent_purpose': {
      'English':
          'Purpose: spot scam trends early and tune Raabta’s pattern checks and advisories. '
          'This is separate from AI analysis of your message.',
      'Arabic':
          'الغرض: رصد اتجاهات الاحتيال مبكراً وتحسين فحوص الأنماط والتنبيهات. '
          'هذا منفصل عن تحليل الذكاء الاصطناعي لرسالتك.',
    },
    'ss_signal_consent_sent': {
      'English':
          'What is sent (once per day at most): category counters only — channel type, '
          'scam pattern IDs (up to 2), evidence kinds (up to 6), risk band, '
          'broad impersonation category (e.g. banking), app language, and optional feedback.',
      'Arabic':
          'ما يُرسل (مرة واحدة يومياً كحد أقصى): عدادات فئات فقط — نوع القناة، '
          'معرّفات أنماط (حتى 2)، أنواع أدلة (حتى 6)، مستوى الخطر، '
          'فئة انتحال عامة (مثل بنك)، لغة التطبيق، وملاحظات اختيارية.',
    },
    'ss_signal_consent_never': {
      'English':
          'Never sent: message text, phone numbers, URLs, domains, names, account numbers, '
          'exact entities, location, or anything from redaction fields.',
      'Arabic':
          'لا يُرسل أبداً: نص الرسالة، أرقام الهاتف، روابط، نطاقات، أسماء، أرقام حسابات، '
          'جهات محددة، الموقع، أو أي حقل تم إخفاؤه.',
    },
    'ss_signal_consent_retention': {
      'English':
          'Server: increments daily aggregate counters only — raw events are discarded. '
          'No user ID, device ID, or IP is stored. You can turn this off anytime in Scam Shield settings; '
          'withdrawal stops new sends immediately.',
      'Arabic':
          'الخادم: يزيد عدادات يومية مجمّعة فقط — لا يُحفظ الحدث الخام. '
          'لا يُخزَّن معرّف مستخدم أو جهاز أو IP. يمكنك الإيقاف من إعدادات درع الاحتيال؛ '
          'السحب يوقف الإرسال فوراً.',
    },
    'ss_signal_consent_no_ads': {
      'English':
          'Not used for ads or sold to third parties. Reports are for Raabta detector tuning and '
          'internal aggregate summaries only.',
      'Arabic':
          'لا يُستخدم للإعلانات ولا يُباع لأطراف ثالثة. للتحسين الداخلي والتقارير المجمّعة فقط.',
    },
    'ss_signal_consent_enable': {
      'English': 'I agree — share anonymous counters',
      'Arabic': 'أوافق — مشاركة عدادات مجهولة',
    },
    'ss_signal_consent_decline': {
      'English': 'Not now',
      'Arabic': 'ليس الآن',
    },
    'ss_signal_settings_title': {
      'English': 'Anonymous scam trend signal',
      'Arabic': 'إشارة اتجاه احتيال مجهولة',
    },
    'ss_signal_settings_sub': {
      'English': 'Opt-in counters only — default off',
      'Arabic': 'عدادات اختيارية — مغلق افتراضياً',
    },
    'ss_signal_legit_tap': {
      'English': 'This looks legitimate',
      'Arabic': 'يبدو شرعياً',
    },
    'ss_signal_legit_ack': {
      'English': 'Noted locally — helps tune false alarms if trend sharing is on',
      'Arabic': 'تم التسجيل محلياً — يساعد في ضبط الإنذارات إذا كان المشاركة مفعّلة',
    },
    'ss_signal_nudge_title': {
      'English': 'Optional: help spot scam trends',
      'Arabic': 'اختياري: المساعدة في رصد اتجاهات الاحتيال',
    },
    'ss_signal_nudge_body': {
      'English':
          'Share anonymous category counters only (never your message). Off by default.',
      'Arabic':
          'مشاركة عدادات فئات مجهولة فقط (وليس رسالتك). مغلق افتراضياً.',
    },
    'ss_signal_nudge_learn': {
      'English': 'Learn more',
      'Arabic': 'اعرف المزيد',
    },
  };
}
