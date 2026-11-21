abstract final class LinkSafetyStrings {
  static String t(String key, String locale) {
    final map = _strings[key];
    if (map == null) return key;
    return map[locale] ??
        map['English'] ??
        map.values.first;
  }

  static String format(
    String key,
    String locale, {
    required Map<String, String> params,
  }) {
    var out = t(key, locale);
    for (final e in params.entries) {
      out = out.replaceAll('{${e.key}}', e.value);
    }
    return out;
  }

  static final _strings = {
    'ls_label_lookalike': _e(
      'This link imitates {org}\'s website. It is not that organisation.',
      'هذا الرابط يقلّد موقع {org}. ليس المؤسسة الرسمية.',
      'This link imitates {org}. It is not that organisation.',
    ),
    'ls_label_shortener': _e(
      'Shortened link: the destination is hidden.',
      'رابط مختصر: الوجهة مخفية.',
      'Shortened link: destination hidden.',
    ),
    'ls_label_apk': _e(
      'This link downloads an app file (.apk).',
      'هذا الرابط يحمّل ملف تطبيق (.apk).',
      'This link downloads an app file (.apk).',
    ),
    'ls_label_payment_chat': _e(
      'This link is not on Raabta\'s usual payment allowlist.',
      'هذا الرابط ليس ضمن قائمة الدفع المعتادة في Raabta.',
      'Link not on usual payment allowlist.',
    ),
    'ls_why': _e('Why?', 'لماذا؟', 'Why?'),
    'ls_check_link': _e('Check this link', 'افحص هذا الرابط', 'Check this link'),
    'ls_why_title': _e('About this link note', 'عن ملاحظة الرابط', 'About this link note'),
    'ls_why_body_lookalike': _e(
      'Raabta compared the link\'s domain to its offline official directory. The domain looks similar to {org}, but is not the same official site. This describes the link only — not the person who shared it.',
      'قارن Raabta نطاق الرابط بدليله الرسمي دون اتصال. يشبه {org} لكنه ليس الموقع الرسمي. يصف الرابط فقط — لا الشخص.',
      'Offline directory comparison — link only, not the poster.',
    ),
    'ls_why_body_shortener': _e(
      'Short links hide the final address until you open them. You can run a full check in ScamShield before paying or signing in.',
      'الروابط المختصرة تخفى العنوان النهائي. يمكنك فحصاً كاملاً في ScamShield قبل الدفع.',
      'Short links hide the destination. Use ScamShield before paying.',
    ),
    'ls_why_body_apk': _e(
      'App files (.apk) installed outside official stores can carry extra risk. This note is about the link, not the sender.',
      'ملفات .apk خارج المتاجر الرسمية قد تحمل مخاطر. الملاحظة عن الرابط لا المرسل.',
      '.apk installs outside official stores — about the link only.',
    ),
    'ls_why_body_payment': _e(
      'Raabta uses the same local payment-link rules as marketplace chat warnings. It does not mean the sender committed fraud.',
      'Raabta تستخدم نفس قواعد روابط الدفع المحلية كتحذيرات محادثة السوق. لا تعني أن المرسل احتال.',
      'Same local rules as marketplace chat — not a claim about the sender.',
    ),
    'ls_why_learn': _e('Scam types library', 'مكتبة أنواع الاحتيال', 'Scam types library'),
    'ls_report_post': _e('Report this post', 'أبلغ عن هذا المنشور', 'Report this post'),
    'ls_friction_title': _e(
      'This link imitates {org}\'s website',
      'هذا الرابط يقلّد موقع {org}',
      'Link imitates {org}',
    ),
    'ls_friction_title_apk': _e(
      'This link downloads an app file',
      'هذا الرابط يحمّل ملف تطبيق',
      'App file download link',
    ),
    'ls_friction_title_payment': _e(
      'This payment link is unusual for Raabta chat',
      'رابط الدفع غير معتاد في محادثة Raabta',
      'Unusual payment link',
    ),
    'ls_author_note_apk': _e(
      'This link downloads an app file (.apk). Are you sure?',
      'هذا الرابط يحمّل ملف .apk. هل أنت متأكد؟',
      '.apk link — are you sure?',
    ),
    'ls_author_note_payment': _e(
      'This link is not on Raabta\'s usual payment allowlist. Are you sure?',
      'الرابط ليس ضمن قائمة الدفع المعتادة. هل أنت متأكد؟',
      'Unusual payment link — are you sure?',
    ),
    'ls_friction_body': _e(
      'Open anyway?',
      'هل تفتح على أي حال؟',
      'Open anyway?',
    ),
    'ls_friction_primary': _e('Don\'t open', 'لا تفتح', 'Don\'t open'),
    'ls_friction_open': _e('Open anyway', 'افتح على أي حال', 'Open anyway'),
    'ls_author_note': _e(
      'This link imitates {org}\'s website. Are you sure?',
      'هذا الرابط يقلّد موقع {org}. هل أنت متأكد؟',
      'Link imitates {org}. Are you sure?',
    ),
    'ls_author_remove': _e('Remove link', 'أزل الرابط', 'Remove link'),
    'ls_author_post_anyway': _e('Post anyway', 'انشر على أي حال', 'Post anyway'),
  };
}

Map<String, String> _e(String en, String ar, String hi) => {
      'English': en,
      'Arabic': ar,
      'Hindi': hi,
      'Urdu': hi,
      'Malayalam': en,
      'Nepali': en,
      'Bengali': hi,
      'Filipino': en,
    };
