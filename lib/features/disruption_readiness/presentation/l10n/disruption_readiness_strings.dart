import 'package:raabta/core/l10n/app_locale.dart';
import 'package:raabta/core/l10n/locale_catalog_entry.dart';

/// Disruption & crisis readiness copy — safety strings flagged for native review.
abstract final class DisruptionReadinessStrings {
  static const keysNeedingReview = {
    'dr_block_disclaimer_body',
    'dr_block_ews_channel_body',
    'dr_block_gco_pending_body',
    'dr_block_before_airport_body',
    'dr_block_keep_records_body',
    'dr_block_go_bag_body',
    'dr_block_evacuation_scams_body',
    'dr_block_embassy_body',
    'dr_block_emergency_body',
    'dr_block_rp_neutral_body',
    'dr_lq_card_body',
    'dr_trip_card_teaser',
    'kq_section_alerts_safety_body',
    'dr_understand_alert_title',
    'dr_understand_alert_intro',
    'dr_understand_alert_entry_title',
    'dr_understand_alert_entry_body',
    'dr_understand_alert_section_what',
    'dr_understand_alert_ews_explanation',
    'dr_understand_alert_section_example',
    'dr_understand_alert_example_label',
    'dr_understand_alert_example_caption',
    'dr_understand_alert_section_if_you_get_one',
    'dr_understand_alert_qna_follow',
    'dr_understand_alert_section_glossary',
    'dr_understand_alert_glossary_all_clear_heading',
    'dr_understand_alert_glossary_ar_label',
    'dr_understand_alert_glossary_ar_source',
    'dr_understand_alert_glossary_en_label',
    'dr_understand_alert_glossary_en_source',
    'dr_understand_alert_sources_title',
    'dr_understand_alert_sources_body',
    'kq_action_understand_alert',
  };

  static String t(String key, String locale) {
    final normalized = AppLocale.normalize(locale);
    final row = _catalog[key];
    if (row == null) return key;
    return row[normalized] ?? row['English'] ?? key;
  }

  static String format(
    String key,
    String locale,
    Map<String, String> params,
  ) {
    var text = t(key, locale);
    for (final entry in params.entries) {
      text = text.replaceAll('{${entry.key}}', entry.value);
    }
    return text;
  }

  static final _catalog = <String, Map<String, String>>{
    'dr_screen_title': l10nEntry(
      english: 'If things are disrupted',
      arabic: 'إذا حدثت اضطرابات',
      hindi: 'If things are disrupted',
      urdu: 'If things are disrupted',
    ),
    'dr_screen_subtitle': l10nEntry(
      english:
          'Calm, offline guidance and official links. Raabta does not show live airspace, airport, flight, or threat status.',
      arabic:
          'إرشادات هادئة دون اتصال وروابط رسمية. Raabta لا تعرض حالة المجال الجوي أو المطار أو الرحلات أو التهديدات.',
    ),
    'dr_needs_internet': l10nEntry(
      english: 'Needs internet',
      arabic: 'يتطلب اتصالاً',
    ),
    'dr_source_footer': l10nEntry(
      english: 'Source: {source} · Last verified {date}',
      arabic: 'المصدر: {source} · آخر تحقق {date}',
    ),
    'dr_source_unverified': l10nEntry(
      english: 'Official source not yet verified in Raabta',
      arabic: 'المصدر الرسمي لم يُتحقق منه بعد في Raabta',
    ),
    'dr_open_emergency_numbers': l10nEntry(
      english: 'Open emergency numbers',
      arabic: 'فتح أرقام الطوارئ',
    ),
    'dr_call_999': l10nEntry(
      english: 'Call 999',
      arabic: 'اتصل 999',
    ),
    'dr_airline_prompt_title': l10nEntry(
      english: 'Your airline',
      arabic: 'خطك الجوي',
    ),
    'dr_airline_prompt_hint': l10nEntry(
      english: 'Type airline name to open its website (not saved)',
      arabic: 'اكتب اسم الخط لفتح موقعه (لا يُحفظ)',
    ),
    'dr_airline_open_website': l10nEntry(
      english: 'Search airline website',
      arabic: 'البحث عن موقع الخط',
    ),
    'dr_document_vault': l10nEntry(
      english: 'Open Document Vault',
      arabic: 'فتح خزينة المستندات',
    ),
    'dr_block_disclaimer_title': l10nEntry(
      english: 'Official channels only',
      arabic: 'القنوات الرسمية فقط',
    ),
    'dr_block_disclaimer_body': l10nEntry(
      english:
          'Raabta does not state whether Qatar’s airspace, airports, or flights are open or closed, and does not assess security threats. Check your airline and official government sources before you travel.',
      arabic:
          'Raabta لا تعلن عن حالة المجال الجوي أو المطارات أو الرحلات ولا تقيّم التهديدات. تحقق من خطك الجوي والمصادر الرسمية قبل السفر.',
    ),
    'dr_block_ews_channel_title': l10nEntry(
      english: 'National Early Warning alerts',
      arabic: 'تنبيهات الإنذار المبكر الوطني',
    ),
    'dr_block_ews_channel_body': l10nEntry(
      english:
          'Emergency alerts on your phone come from Qatar’s authorities through the national Early Warning System. Follow instructions in the alert and monitor official channels. Raabta does not send its own threat alerts.',
      arabic:
          'تصل تنبيهات الطوارئ على هاتفك من الجهات القطرية عبر نظام الإنذار المبكر. اتبع تعليمات التنبيه وراقب القنوات الرسمية.',
    ),
    'dr_block_gco_pending_title': l10nEntry(
      english: 'Early Warning response guidance',
      arabic: 'إرشادات الاستجابة للإنذار المبكر',
    ),
    'dr_block_gco_pending_body': l10nEntry(
      english:
          'Raabta has not yet verified the Government Communications Office publication for step-by-step Early Warning response guidance. Until verification is complete, follow the alert text and official MOI channels only.',
      arabic:
          'لم يتحقق Raabta بعد من نشر مكتب الاتصال الحكومي للإرشادات التفصيلية. حتى اكتمال التحقق، اتبع نص التنبيه وقنوات وزارة الداخلية الرسمية فقط.',
    ),
    'dr_block_before_airport_title': l10nEntry(
      english: 'Before you go to the airport',
      arabic: 'قبل الذهاب إلى المطار',
    ),
    'dr_block_before_airport_body': l10nEntry(
      english:
          'Airport operations, airspace rules, published schedules, and your own flight are separate facts. Confirm with your airline before leaving for the airport. Do not assume Raabta or any link here means it is safe to travel.',
      arabic:
          'عمليات المطار وقواعد المجال الجوي والجداول ورحلتك أمور منفصلة. أكّد مع خطك الجوي قبل المغادرة. لا تفترض أن Raabta أو أي رابط هنا يعني أن السفر آمن.',
    ),
    'dr_block_keep_records_title': l10nEntry(
      english: 'Keep your records',
      arabic: 'احتفظ بسجلاتك',
    ),
    'dr_block_keep_records_body': l10nEntry(
      english:
          'Save screenshots or exports of cancelled or changed flights, booking references, messages from your airline or insurer, and any official notices you receive. Storing copies may help your own records; it does not guarantee any refund or claim.',
      arabic:
          'احفظ لقطات أو نسخاً عن تغييرات الرحلات ومراجع الحجز ورسائل الخط أو التأمين وأي إشعارات رسمية. التخزين يساعد سجلاتك الشخصية ولا يضمن أي استرداد.',
    ),
    'dr_block_go_bag_title': l10nEntry(
      english: 'Go-bag essentials',
      arabic: 'أساسيات حقيبة جاهزة',
    ),
    'dr_block_go_bag_body': l10nEntry(
      english:
          'Tick items you have ready on this device. This checklist stays on your phone and is not uploaded to Raabta servers.',
      arabic: 'حدّد ما هو جاهز على هذا الجهاز. القائمة تبقى على هاتفك ولا تُرفع إلى خوادم Raabta.',
    ),
    'dr_block_evacuation_scams_title': l10nEntry(
      english: 'Beware evacuation and seat scams',
      arabic: 'احذر احتيال الإجلاء والمقاعد',
    ),
    'dr_block_evacuation_scams_body': l10nEntry(
      english:
          'Official channels do not ask for QID photos or payments over WhatsApp or social media to reserve evacuation or relief seats. Use verified government and airline websites only. Report fraud through normal police and consumer channels.',
      arabic:
          'القنوات الرسمية لا تطلب صور QID أو مدفوعات عبر واتساب أو وسائل التواصل لحجز مقاعد إجلاء. استخدم المواقع الرسمية فقط.',
    ),
    'dr_block_embassy_title': l10nEntry(
      english: 'Contact your embassy',
      arabic: 'تواصل مع سفارتك',
    ),
    'dr_block_embassy_body': l10nEntry(
      english:
          'Register with your embassy or consulate through its official channel when one is available. Raabta lists verified portals only.',
      arabic: 'سجّل لدى سفارتك عبر قناة رسمية متاحة. Raabta تعرض بوابات مُتحقق منها فقط.',
    ),
    'dr_block_emergency_title': l10nEntry(
      english: 'Emergency number',
      arabic: 'رقم الطوارئ',
    ),
    'dr_block_emergency_body': l10nEntry(
      english:
          'For life-threatening emergencies in Qatar, call 999. For the full official hotline list already in Raabta, open Emergency Help without re-entering numbers here.',
      arabic: 'للطوارئ المهددة للحياة في قطر، اتصل 999. للقائمة الرسمية الكاملة في Raabta، افتح مساعدة الطوارئ.',
    ),
    'dr_block_rp_neutral_title': l10nEntry(
      english: 'Residence permit rules',
      arabic: 'قواعد الإقامة',
    ),
    'dr_block_rp_neutral_body': l10nEntry(
      english:
          'A disruption does not automatically change residence-permit or exit rules. Check the official portal for your situation — Raabta does not state grace periods, fines, or waivers.',
      arabic: 'الاضطراب لا يغيّر قواعد الإقامة تلقائياً. تحقق من البوابة الرسمية — Raabta لا تذكر فترات سماح أو غرامات.',
    ),
    'dr_source_moi': l10nEntry(english: 'MOI Qatar', arabic: 'وزارة الداخلية'),
    'dr_source_gco': l10nEntry(
      english: 'Government Communications Office',
      arabic: 'مكتب الاتصال الحكومي',
    ),
    'dr_source_qcaa': l10nEntry(
      english: 'Qatar Civil Aviation Authority',
      arabic: 'هيئة الطيران المدني',
    ),
    'dr_link_moi_ews': l10nEntry(
      english: 'MOI Early Warning System',
      arabic: 'نظام الإنذار المبكر',
    ),
    'dr_link_moi_portal': l10nEntry(
      english: 'MOI portal',
      arabic: 'بوابة وزارة الداخلية',
    ),
    'dr_link_hamad_airport': l10nEntry(
      english: 'Hamad International Airport',
      arabic: 'مطار حمد الدولي',
    ),
    'dr_link_qcaa': l10nEntry(
      english: 'QCAA website',
      arabic: 'موقع هيئة الطيران المدني',
    ),
    'dr_link_metrash': l10nEntry(
      english: 'Metrash portal',
      arabic: 'بوابة متراش',
    ),
    'dr_embassy_india_authority': l10nEntry(
      english: 'India MADAD (MEA consular services)',
      arabic: 'MADAD الهند',
    ),
    'dr_embassy_nepal_authority': l10nEntry(
      english: 'Nepal Department of Consular Services',
      arabic: 'الخدمات القنصلية النيبالية',
    ),
    'dr_embassy_ph_authority': l10nEntry(
      english: 'Philippines Department of Migrant Workers',
      arabic: 'إدارة العمالة الفلبينية',
    ),
    'dr_embassy_bd_not_confirmed': l10nEntry(
      english:
          'Not yet available in Raabta — check your embassy’s official website for registration.',
      arabic: 'غير متاح بعد — راجع موقع سفارتك الرسمي.',
    ),
    'dr_embassy_pk_not_confirmed': l10nEntry(
      english:
          'Not yet available in Raabta — check your embassy’s official website for registration.',
      arabic: 'غير متاح بعد — راجع موقع سفارتك الرسمي.',
    ),
    'dr_embassy_lk_not_confirmed': l10nEntry(
      english:
          'Not yet available in Raabta — check your embassy’s official website for registration.',
      arabic: 'غير متاح بعد — راجع موقع سفارتك الرسمي.',
    ),
    'dr_embassy_open_portal': l10nEntry(
      english: 'Open official portal',
      arabic: 'فتح البوابة الرسمية',
    ),
    'dr_go_bag_passport': l10nEntry(english: 'Passport', arabic: 'جواز السفر'),
    'dr_go_bag_qid': l10nEntry(english: 'QID', arabic: 'الهوية القطرية'),
    'dr_go_bag_contract': l10nEntry(english: 'Contract', arabic: 'العقد'),
    'dr_go_bag_salary_slips': l10nEntry(
      english: 'Recent salary slips',
      arabic: 'قسائم راتب حديثة',
    ),
    'dr_go_bag_medicines': l10nEntry(english: 'Medicines', arabic: 'الأدوية'),
    'dr_go_bag_charger_power_bank': l10nEntry(
      english: 'Phone charger / power bank',
      arabic: 'شاحن / بنك طاقة',
    ),
    'dr_go_bag_cash': l10nEntry(english: 'Some cash', arabic: 'نقد'),
    'dr_go_bag_vault_copies': l10nEntry(
      english: 'Copies saved in Document Vault',
      arabic: 'نسخ في خزينة المستندات',
    ),
    'dr_go_bag_contacts_written': l10nEntry(
      english: 'Emergency contacts written down',
      arabic: 'جهات طوارئ مكتوبة',
    ),
    'dr_lq_card_title': l10nEntry(
      english: 'Leaving during a disruption',
      arabic: 'المغادرة أثناء اضطراب',
    ),
    'dr_lq_card_body': l10nEntry(
      english:
          'Airport and airline checks, records, scams, and embassy links — without live status claims.',
      arabic: 'فحوصات المطار والخط والسجلات والاحتيال — دون ادعاءات حالة مباشرة.',
    ),
    'dr_lq_card_action': l10nEntry(
      english: 'Open disruption guide',
      arabic: 'فتح دليل الاضطراب',
    ),
    'dr_trip_card_title': l10nEntry(
      english: 'Check your flight before the airport',
      arabic: 'تحقق من رحلتك قبل المطار',
    ),
    'dr_trip_card_teaser': l10nEntry(
      english:
          'Confirm with your airline first. Raabta does not show live flight or airport status.',
      arabic: 'أكّد مع خطك الجوي. Raabta لا تعرض حالة الرحلة أو المطار.',
    ),
    'dr_trip_card_open': l10nEntry(
      english: 'Open guide',
      arabic: 'فتح الدليل',
    ),
    'dr_trip_checklist_unavailable': l10nEntry(
      english:
          'Open this guide from a saved trip so your go-bag checklist stays tied to that trip.',
      arabic:
          'افتح هذا الدليل من رحلة محفوظة لربط قائمة حقيبة الجاهزية بتلك الرحلة.',
    ),
    'dr_understand_alert_title': l10nEntry(
      english: 'Understand an alert',
      arabic: 'افهم التنبيه',
      hindi: 'Understand an alert',
      urdu: 'التنبيه سمجھیں',
    ),
    'dr_understand_alert_intro': l10nEntry(
      english:
          'Offline guide to Qatar’s official phone alerts. Raabta does not send threat alerts or show live warnings.',
      arabic:
          'دليل دون اتصال لتنبيهات الهاتف الرسمية. Raabta لا ترسل تنبيهات تهديد ولا تعرض تحذيرات مباشرة.',
      hindi: 'Offline guide — Raabta does not send threat alerts.',
      urdu: 'آف لائن گائیڈ — Raabta خطرے کے الرٹ نہیں بھیجتی۔',
    ),
    'dr_understand_alert_entry_title': l10nEntry(
      english: 'Understand an alert',
      arabic: 'افهم التنبيه',
    ),
    'dr_understand_alert_entry_body': l10nEntry(
      english:
          'What official Early Warning messages are, and verified all-clear wording — before an alert happens.',
      arabic: 'ما هي رسائل الإنذار المبكر الرسمية وصياغة زوال التهديد الموثقة.',
    ),
    'dr_understand_alert_section_what': l10nEntry(
      english: 'What these alerts are',
      arabic: 'ما هذه التنبيهات',
    ),
    'dr_understand_alert_ews_explanation': l10nEntry(
      english:
          'Qatar’s authorities use the mobile Early Warning System in exceptional urgent circumstances to help protect lives and property. Take an alert seriously and follow the instructions in that specific alert. Based on official reporting, messages may reach phones even when they are set to silent mode.',
      arabic:
          'تستخدم الجهات القطرية نظام الإنذار المبكر في ظروف استثنائية عاجلة لحماية الأرواح والممتلكات. خذ التنبيه بجدية واتبع تعليمات ذلك التنبيه. وفق تقارير رسمية، قد تصل الرسائل حتى عند وضع الصمت.',
    ),
    'dr_understand_alert_section_example': l10nEntry(
      english: 'What it may look like (example only)',
      arabic: 'شكل محتمل (مثال فقط)',
    ),
    'dr_understand_alert_example_label': l10nEntry(
      english: 'Example, not a real alert',
      arabic: 'مثال — ليس تنبيهاً حقيقياً',
    ),
    'dr_understand_alert_example_caption': l10nEntry(
      english:
          'Sample layout only. Real alerts are issued by the Ministry of Interior on your phone. This screen is not a notification.',
      arabic:
          'تخطيط توضيحي فقط. التنبيهات الحقيقية تصدرها وزارة الداخلية على هاتفك. هذه الشاشة ليست إشعاراً.',
    ),
    'dr_understand_alert_section_if_you_get_one': l10nEntry(
      english: 'If you get one',
      arabic: 'إذا وصلك تنبيه',
    ),
    'dr_understand_alert_qna_follow': l10nEntry(
      english:
          'Official reporting (QNA, 19 February 2026): take mobile Early-Warning alerts seriously, follow the instructions provided, and remember the system is for emergencies — not routine messages.',
      arabic:
          'تقارير رسمية (قنا، 19 فبراير 2026): خذ تنبيهات الإنذار المبكر بجدية واتبع التعليمات — النظام للطوارئ لا للرسائل الروتينية.',
    ),
    'dr_understand_alert_section_glossary': l10nEntry(
      english: 'Alert words in plain language',
      arabic: 'كلمات التنبيه بلغة واضحة',
    ),
    'dr_understand_alert_glossary_all_clear_heading': l10nEntry(
      english: 'All clear (verified official wording)',
      arabic: 'زوال التهديد (صياغة رسمية موثقة)',
    ),
    'dr_understand_alert_glossary_ar_label': l10nEntry(
      english: 'Arabic (QNA)',
      arabic: 'العربية (قنا)',
    ),
    'dr_understand_alert_glossary_ar_source': l10nEntry(
      english: 'Source: Qatar News Agency · {date}',
      arabic: 'المصدر: وكالة الأنباء القطرية · {date}',
    ),
    'dr_understand_alert_glossary_en_label': l10nEntry(
      english: 'English reporting (Gulf Times citing QNA)',
      arabic: 'إنجليزي (Gulf Times عن قنا)',
    ),
    'dr_understand_alert_glossary_en_source': l10nEntry(
      english: 'Source: Gulf Times reporting QNA · {date}',
      arabic: 'المصدر: Gulf Times عن قنا · {date}',
    ),
    'dr_understand_alert_sources_title': l10nEntry(
      english: 'Official sources',
      arabic: 'مصادر رسمية',
    ),
    'dr_understand_alert_sources_body': l10nEntry(
      english:
          'Early Warning reporting: QNA · {date}. Content last verified in Raabta · {verified}. Link below opens the MOI Early Warning portal (needs internet).',
      arabic:
          'تقارير الإنذار المبكر: قنا · {date}. آخر تحقق في Raabta · {verified}. الرابط يفتح بوابة MOI (يتطلب إنترنت).',
    ),
    'kq_action_understand_alert': l10nEntry(
      english: 'Understand an alert',
      arabic: 'افهم التنبيه',
    ),
  };

  static String goBagItemLabel(String itemId, String locale) {
    return t('dr_go_bag_$itemId', locale);
  }
}
