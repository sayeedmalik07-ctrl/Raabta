import 'package:flutter/foundation.dart';
import 'package:raabta/core/l10n/app_locale.dart';
import 'package:raabta/core/l10n/locale_catalog_coverage.dart';
import 'package:raabta/core/l10n/locale_catalog_entry.dart';

abstract final class LeavingQatarStrings {
  static const supportedLocales = AppLocale.supportedLocales;

  /// New close-out copy pending professional review (9 locales).
  static const keysNeedingReview = {
    'lq_closeout_section_title',
    'lq_closeout_section_teaser',
    'lq_closeout_offline_hint',
    'lq_closeout_needs_internet',
    'lq_closeout_verified_footer',
    'lq_closeout_secondary_source',
    'lq_closeout_group_vehicle',
    'lq_closeout_group_school',
    'lq_closeout_group_pets',
    'lq_closeout_group_pcc',
    'lq_closeout_group_certificates',
    'lq_closeout_group_home',
    'lq_closeout_group_airport',
    'lq_closeout_vehicle_transfer_title',
    'lq_closeout_vehicle_transfer_body',
    'lq_closeout_traffic_fines_title',
    'lq_closeout_traffic_fines_body',
    'lq_closeout_vehicle_export_title',
    'lq_closeout_vehicle_export_body',
    'lq_closeout_school_title',
    'lq_closeout_school_body',
    'lq_closeout_pets_title',
    'lq_closeout_pets_body',
    'lq_closeout_pcc_title',
    'lq_closeout_pcc_body',
    'lq_closeout_traffic_certs_title',
    'lq_closeout_traffic_certs_body',
    'lq_closeout_tenancy_title',
    'lq_closeout_tenancy_body',
    'lq_closeout_marketplace_title',
    'lq_closeout_marketplace_body',
    'lq_closeout_qdi_title',
    'lq_closeout_qdi_body',
    'lq_closeout_action_metrash',
    'lq_closeout_action_traffic_inquiry',
    'lq_closeout_action_traffic_certificates',
    'lq_closeout_action_qna_vehicle_exit',
    'lq_closeout_action_moehe_portal',
    'lq_closeout_action_municipality',
    'lq_closeout_action_pcc',
    'lq_closeout_action_tenancy',
    'lq_closeout_action_marketplace',
    'lq_closeout_action_moi_portal',
    'lq_closeout_source_moi',
    'lq_closeout_source_moi_traffic',
    'lq_closeout_source_qna',
    'lq_closeout_source_moehe',
    'lq_closeout_source_municipality',
    'lq_dp_section_title',
    'lq_dp_section_subtitle',
    'lq_dp_separate_state_note',
    'lq_dp_loading',
    'lq_dp_load_error',
    'lq_dp_save_failed',
    'lq_dp_progress',
    'lq_dp_date_heading',
    'lq_dp_date_not_set',
    'lq_dp_date_pick',
    'lq_dp_date_clear',
    'lq_dp_timing_suggested',
    'lq_dp_timing_official',
    'lq_dp_action_open',
    'lq_dp_action_official_portal',
    'lq_dp_action_view_on_page',
    'lq_dp_item_plan_employer_settlement',
    'lq_dp_item_plan_eosb_entitlement',
    'lq_dp_item_plan_bank_arrangements',
    'lq_dp_item_plan_kahramaa_closure',
    'lq_dp_item_plan_health_coverage_gap',
    'lq_dp_item_plan_vehicle_and_fines',
    'lq_dp_item_plan_school_records',
    'lq_dp_item_plan_pets',
    'lq_dp_item_plan_exit_permit',
    'lq_dp_item_plan_traffic_fines_recheck',
    'lq_dp_item_plan_travel_ban_inquiry',
    'lq_dp_item_plan_rp_cancellation',
    'lq_dp_item_plan_departure_rules_confirm',
    'lq_dp_item_plan_document_vault_copies',
    'lq_dp_item_plan_welcome_home_prep',
    'lq_dp_reminder_toggle_label',
    'lq_dp_reminder_toggle_sub',
    'lq_dp_reminder_need_date',
    'lq_dp_reminder_none_eligible',
    'lq_dp_reminder_permission_note',
    'lq_dp_reminder_load_error',
    'lq_dp_reminder_schedule_failed',
    'lq_dp_reminder_title',
    'lq_dp_reminder_body',
    'lq_dp_export_pdf',
    'lq_dp_export_failed',
    'lq_dp_pdf_title',
    'lq_dp_pdf_intro',
    'lq_dp_pdf_date_set',
    'lq_dp_pdf_date_not_set',
    'lq_dp_pdf_progress',
    'lq_dp_pdf_timing_suggested',
    'lq_dp_pdf_timing_official',
    'lq_dp_pdf_status_done',
    'lq_dp_pdf_status_pending',
    'lq_dp_pdf_ref_route',
    'lq_dp_pdf_ref_portal',
    'lq_dp_pdf_ref_timeline',
    'lq_dp_pdf_ref_closeout',
    'lq_dp_pdf_disclaimer',
    'lq_dp_pdf_branding',
  };

  static String departurePlanItemTitle(String itemId, [String locale = 'English']) {
    return t('lq_dp_item_$itemId', locale);
  }

  static String t(String key, [String locale = 'English']) {
    final normalized = AppLocale.normalize(locale);
    final map = _catalog[key];
    if (map == null) return key;
    return map[normalized] ?? map['English'] ?? key;
  }

  static String tf(
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

  @visibleForTesting
  static Map<String, Set<String>> get localeCoverageReport =>
      buildLocaleCoverageReport(
        catalog: _catalog,
        supportedLocales: supportedLocales,
      );

  static final _catalog = <String, Map<String, String>>{
    // ── Screen ──────────────────────────────────────────────────────────────
    'lq_screen_title': l10nEntry(
      english: 'Leaving Qatar',
      arabic: 'مغادرة قطر',
      hindi: 'क़तर छोड़ना',
      urdu: 'قطر چھوڑنا',
    ),
    'lq_screen_intro': l10nEntry(
      english:
          'Plan your departure with honest self-assessment, official MOI checks, and what you\'re owed — Raabta does not verify your live immigration status.',
      arabic:
          'خطط لمغادرتك بتقييم ذاتي واضح، وفحوصات وزارة الداخلية الرسمية، ومعرفة مستحقاتك — Raabta لا تتحقق من وضعك الهجري المباشر.',
      hindi:
          'स्पष्ट self-assessment, official MOI checks, और अपने बकाया अधिकारों के साथ प्रस्थान की योजना बनाएं — Raabta आपकी live immigration status verify नहीं करती।',
      urdu:
          'واضح self-assessment، سرکاری MOI checks، اور اپنے حقوق کے ساتھ روانگی کی منصوبہ بندی — Raabta آپ کی live immigration status verify نہیں کرتی۔',
    ),
    'lq_disclaimer': l10nEntry(
      english:
          'General guidance only — not legal advice or a status certificate. Always confirm via the official Metrash app or MOI portal.',
      arabic:
          'إرشادات عامة فقط — ليست استشارة قانونية ولا شهادة وضع. أكّد دائماً عبر تطبيق Metrash أو بوابة MOI.',
      hindi:
          'केवल सामान्य मार्गदर्शन — कानूनी सलाह या status certificate नहीं। हमेशा Metrash app या MOI portal से confirm करें।',
      urdu:
          'عام رہنمائی — قانونی مشورہ یا status certificate نہیں۔ ہمیشہ Metrash app یا MOI portal سے confirm کریں۔',
    ),

    // ── Self-assessment ─────────────────────────────────────────────────────
    'lq_assessment_heading': l10nEntry(
      english: 'Which category best describes your work?',
      arabic: 'أي فئة تصف عملك بشكل أفضل؟',
      hindi: 'आपके काम का सबसे उपयुक्त वर्ग कौन सा है?',
      urdu: 'آپ کے کام کی بہترین کیٹیگری کون سی ہے؟',
    ),
    'lq_assessment_note': l10nEntry(
      english:
          'This selects general guidance only — it does not determine your actual exit-permit or travel-ban status.',
      arabic:
          'يحدد هذا إرشادات عامة فقط — ولا يحدد وضع تصريح الخروج أو حظر السفر الفعلي.',
      hindi:
          'यह केवल general guidance चुनता है — यह आपकी actual exit-permit या travel-ban status determine नहीं करता।',
      urdu:
          'یہ صرف general guidance منتخب کرتا ہے — آپ کی actual exit-permit یا travel-ban status determine نہیں کرتا۔',
    ),
    'lq_category_standard': l10nEntry(
      english: 'Standard private-sector employee',
      arabic: 'موظف قطاع خاص عادي',
      hindi: 'मानक private-sector employee',
      urdu: 'معیاری private-sector employee',
    ),
    'lq_category_essential': l10nEntry(
      english: 'Employer-designated essential staff (≤5% of workforce)',
      arabic: 'موظف أساسي معيّن من صاحب العمل (≤5%)',
      hindi: 'Employer-designated essential staff (≤5%)',
      urdu: 'Employer-designated essential staff (≤5%)',
    ),
    'lq_category_domestic': l10nEntry(
      english: 'Domestic worker under personal sponsorship',
      arabic: 'عامل منزلي تحت كفالة شخصية',
      hindi: 'Domestic worker (personal sponsorship)',
      urdu: 'Domestic worker (personal sponsorship)',
    ),
    'lq_category_military': l10nEntry(
      english: 'Military / security personnel',
      arabic: 'عسكري / أمن',
      hindi: 'Military / security',
      urdu: 'Military / security',
    ),

    // ── Exit permit guidance (separate from travel ban) ─────────────────────
    'lq_exit_permit_heading': l10nEntry(
      english: 'Exit permit — permission requirement',
      arabic: 'تصريح الخروج — متطلب إذن',
      hindi: 'Exit permit — permission requirement',
      urdu: 'Exit permit — permission requirement',
    ),
    'lq_exit_permit_not_ban': l10nEntry(
      english:
          'Separate from travel ban: an exit permit is about employer permission to leave, not debts or court orders.',
      arabic:
          'منفصل عن حظر السفر: تصريح الخروج يتعلق بإذن صاحب العمل للمغادرة، وليس الديون أو الأوامر القضائية.',
      hindi:
          'Travel ban से अलग: exit permit employer permission से जुड़ा है, debts/court orders से नहीं।',
      urdu:
          'Travel ban سے الگ: exit permit employer permission سے متعلق ہے، debts/court orders سے نہیں۔',
    ),
    'lq_exit_guidance_standard': l10nEntry(
      english:
          'Workers in this category typically do not need an exit permit since labour reforms (most private-sector employees). Still run the travel ban check below before booking travel.',
      arabic:
          'عادةً لا يحتاج العامل في هذه الفئة إلى تصريح خروج بعد إصلاحات العمل (معظم موظفي القطاع الخاص). مع ذلك، نفّذ فحص حظر السفر أدناه قبل حجز السفر.',
      hindi:
          'इस category के workers को आमतौर पर exit permit नहीं चाहिए (labour reforms के बाद)। फिर भी travel book करने से पहले नीचे travel ban check करें।',
      urdu:
          'اس category کے workers کو عام طور پر exit permit نہیں چاہیے۔ پھر بھی travel book کرنے سے پہلے نیچے travel ban check کریں۔',
    ),
    'lq_exit_guidance_essential': l10nEntry(
      english:
          'Workers designated essential by their employer (up to 5% of workforce) typically need an exit permit before leaving. Apply via Metrash → Entry and Exit Permits → Leave Notification Application. Confirm the current fee and 72-hour validity window on the official portal when you apply.',
      arabic:
          'عادةً يحتاج الموظفون الأساسيون (حتى 5%) إلى تصريح خروج. قدّم عبر Metrash → تصاريح الدخول والخروج → طلب إشعار إجازة. أكّد الرسوم الحالية ونافذة 72 ساعة على البوابة الرسمية.',
      hindi:
          'Essential designated workers को आमतौर पर exit permit चाहिए। Metrash → Entry and Exit Permits → Leave Notification Application से apply करें। Fee और validity official portal पर confirm करें।',
      urdu:
          'Essential workers کو عام طور پر exit permit چاہیے۔ Metrash → Entry and Exit Permits → Leave Notification Application سے apply کریں۔',
    ),
    'lq_exit_guidance_domestic': l10nEntry(
      english:
          'Domestic workers under personal sponsorship typically do not need an exit permit, but must give their employer at least 72 hours\' notice before departure. Confirm current rules on the MOI portal.',
      arabic:
          'عادةً لا يحتاج العامل المنزلي إلى تصريح خروج، لكن يجب إخطار صاحب العمل قبل 72 ساعة على الأقل. أكّد القواعد الحالية على بوابة MOI.',
      hindi:
          'Domestic workers को आमतौर पर exit permit नहीं, लेकिन employer को कम से कम 72 घंटे पहले notice देना होता है। MOI portal पर rules confirm करें।',
      urdu:
          'Domestic workers کو عام طور پر exit permit نہیں، لیکن employer کو کم از کم 72 گھنٹے پہلے notice دیں۔',
    ),
    'lq_exit_guidance_military': l10nEntry(
      english:
          'Military and security personnel follow separate MOI rules — out of scope for this guide. Contact your unit command or official MOI channels directly.',
      arabic:
          'العسكريون وموظفو الأمن يخضعون لقواعد منفصلة — خارج نطاق هذا الدليل. تواصل مع قيادتك أو قنوات MOI الرسمية.',
      hindi:
          'Military/security के अलग MOI rules हैं — इस guide के बाहर। अपनी unit या official MOI channels से संपर्क करें।',
      urdu:
          'Military/security کے الگ MOI rules ہیں — اس guide سے باہر۔ اپنی unit یا official MOI channels سے رابطہ کریں۔',
    ),
    'lq_exit_permit_apply': l10nEntry(
      english: 'Open Metrash — exit permit services',
      arabic: 'فتح Metrash — خدمات تصريح الخروج',
      hindi: 'Metrash खोलें — exit permit',
      urdu: 'Metrash کھولیں — exit permit',
    ),

    // ── Travel ban (always shown, distinct) ───────────────────────────────
    'lq_travel_ban_heading': l10nEntry(
      english: 'Travel ban check — everyone should run this',
      arabic: 'فحص حظر السفر — يجب على الجميع',
      hindi: 'Travel ban check — सभी को करना चाहिए',
      urdu: 'Travel ban check — سب کو کرنا چاہیے',
    ),
    'lq_travel_ban_body': l10nEntry(
      english:
          'A travel ban is separate from exit-permit rules and can affect anyone — unpaid debts, legal cases, or immigration issues. Use MOI\'s Travel Ban Inquiry with your QID before you book a flight. Free, takes about 2 minutes.',
      arabic:
          'حظر السفر منفصل عن تصريح الخروج وقد يؤثر على أي شخص — ديون، قضايا، أو مخالفات. استخدم «استعلام حظر السفر» برقم QID قبل حجز الرحلة. مجاني، حوالي دقيقتين.',
      hindi:
          'Travel ban exit-permit से अलग है और किसी पर भी लग सकता है। Flight book करने से पहले QID से Travel Ban Inquiry करें — मुफ़्त, ~2 मिनट।',
      urdu:
          'Travel ban exit-permit سے الگ ہے۔ Flight book کرنے سے پہلے QID سے Travel Ban Inquiry کریں — مفت، ~2 منٹ۔',
    ),
    'lq_travel_ban_cta': l10nEntry(
      english: 'Check travel ban on MOI / Metrash',
      arabic: 'فحص حظر السفر عبر MOI / Metrash',
      hindi: 'MOI / Metrash पर travel ban check',
      urdu: 'MOI / Metrash پر travel ban check',
    ),
    'lq_travel_ban_fallback': l10nEntry(
      english:
          'If the Metrash app is not installed, use the MOI e-services portal in your browser with the same QID login.',
      arabic:
          'إذا لم يكن Metrash مثبتاً، استخدم بوابة MOI في المتصفح بنفس تسجيل QID.',
      hindi:
          'Metrash app न हो तो browser में MOI portal — same QID login।',
      urdu:
          'Metrash app نہ ہو تو browser میں MOI portal — same QID login۔',
    ),

    // ── EOSB card ─────────────────────────────────────────────────────────
    'lq_eosb_heading': l10nEntry(
      english: 'What you\'re owed before you go',
      arabic: 'ما تستحقه قبل المغادرة',
      hindi: 'जाने से पहले आपका हक',
      urdu: 'جانے سے پہلے آپ کا حق',
    ),
    'lq_eosb_body': l10nEntry(
      english:
          'Know your estimated end-of-service entitlement using Raabta\'s existing EOSB calculation — not a new estimate engine.',
      arabic:
          'اعرف مستحقات نهاية الخدمة التقديرية عبر حساب EOSB الموجود في Raabta.',
      hindi:
          'Raabta की existing EOSB calculation से अपनी estimated end-of-service entitlement जानें।',
      urdu:
          'Raabta کی existing EOSB calculation سے estimated end-of-service entitlement جانیں۔',
    ),
    'lq_eosb_has_calc': l10nEntry(
      english: 'Latest calculation: {amount} QAR estimated total',
      arabic: 'آخر حساب: {amount} ر.ق تقديري',
      hindi: 'Latest calculation: {amount} QAR estimated',
      urdu: 'Latest calculation: {amount} QAR estimated',
    ),
    'lq_eosb_view': l10nEntry(
      english: 'View full entitlement breakdown',
      arabic: 'عرض تفاصيل المستحقات',
      hindi: 'Full entitlement breakdown देखें',
      urdu: 'Full entitlement breakdown دیکھیں',
    ),
    'lq_eosb_run': l10nEntry(
      english: 'Run EOSB entitlement calculation',
      arabic: 'تشغيل حساب مستحقات نهاية الخدمة',
      hindi: 'EOSB entitlement calculation चलाएं',
      urdu: 'EOSB entitlement calculation چلائیں',
    ),
    'lq_eosb_none': l10nEntry(
      english: 'No saved calculation yet — run one before you negotiate your final settlement.',
      arabic: 'لا يوجد حساب محفوظ — أنشئ حساباً قبل التفاوض على التسوية النهائية.',
      hindi: 'No saved calculation — final settlement से पहले एक run करें।',
      urdu: 'No saved calculation — final settlement سے پہلے run کریں۔',
    ),

    // ── Checklist ─────────────────────────────────────────────────────────
    'lq_checklist_heading': l10nEntry(
      english: 'Departure checklist',
      arabic: 'قائمة مغادرة',
      hindi: 'Departure checklist',
      urdu: 'Departure checklist',
    ),
    'lq_checklist_note': l10nEntry(
      english: 'General guidance — confirm current rules and timelines on the official MOI portal.',
      arabic: 'إرشادات عامة — أكّد القواعد والمواعيد على بوابة MOI.',
      hindi: 'General guidance — MOI portal पर current rules confirm करें।',
      urdu: 'General guidance — MOI portal پر current rules confirm کریں۔',
    ),
    'lq_check_rp_title': l10nEntry(
      english: 'Cancel your Residence Permit (RP)',
      arabic: 'إلغاء تصريح الإقامة (RP)',
      hindi: 'Residence Permit (RP) cancel करें',
      urdu: 'Residence Permit (RP) cancel کریں',
    ),
    'lq_check_rp_body': l10nEntry(
      english:
          'RP cancellation is mandatory before final departure. Company-sponsored workers: your employer/sponsor initiates cancellation. Self-sponsored residents cancel their own. Any dependents\' RPs under your sponsorship must be cancelled in the same process.',
      arabic:
          'إلغاء RP إلزامي قبل المغادرة النهائية. الكفيل/صاحب العمل يبدأ الإلغاء للعمال. المقيمون ذوو الكفالة الذاتية يلغون بأنفسهم. يجب إلغاء RP للمعالين ضمن كفالتك.',
      hindi:
          'Final departure से पहले RP cancellation mandatory है। Company-sponsored: employer initiates। Self-sponsored: आप cancel करें। Dependents के RP भी same process में।',
      urdu:
          'Final departure سے پہلے RP cancellation لازمی۔ Company-sponsored: employer initiates۔ Dependents کے RP بھی same process میں۔',
    ),
    'lq_check_window_title': l10nEntry(
      english: 'Departure window after RP cancellation',
      arabic: 'نافذة المغادرة بعد إلغاء RP',
      hindi: 'RP cancellation के बाद departure window',
      urdu: 'RP cancellation کے بعد departure window',
    ),
    'lq_check_window_body': l10nEntry(
      english:
          'After RP cancellation is approved, a limited window applies to leave, change sponsorship, or secure a new visa before daily fines may begin. Confirm the current number of days and fine amount on the official MOI portal at the time of cancellation.',
      arabic:
          'بعد الموافقة على إلغاء RP، تنطبق نافذة محدودة للمغادرة أو تغيير الكفالة قبل possible غرامات يومية. أكّد عدد الأيام والغرامة على بوابة MOI وقت الإلغاء.',
      hindi:
          'RP cancellation approve होने के बाद limited window होती है — daily fines से पहले leave/sponsorship change करें। Exact days और fine MOI portal पर cancellation के समय confirm करें।',
      urdu:
          'RP cancellation approve کے بعد limited window — exact days اور fine MOI portal پر cancellation کے وقت confirm کریں۔',
    ),
    'lq_check_bank_title': l10nEntry(
      english: 'Close bank accounts with time to spare',
      arabic: 'أغلق الحسابات البنكية مع وقت كافٍ',
      hindi: 'Bank accounts समय से पहले बंद करें',
      urdu: 'Bank accounts وقت سے پہلے بند کریں',
    ),
    'lq_check_bank_body': l10nEntry(
      english:
          'Banks may freeze an expat account when they learn you are resigning or leaving — especially if you have an outstanding loan. Employers often send final settlement and end-of-service payments directly to your bank; if you owe the bank, it may deduct what is owed before releasing the rest. Policies vary bank to bank — start account-closure steps 30–45 days before your expected final payment, not on your last day.',
      arabic:
          'قد تجمّد البنوك حسابك عند علمها باستقالتك أو مغادرتك — خاصة مع قرض قائم. غالباً يُرسل صاحب العمل التسوية النهائية إلى بنكك؛ إن كان عليك دين، قد يُخصم قبل إطلاق الباقي. ابدأ إجراءات الإغلاق قبل 30–45 يوماً من الدفعة النهائية المتوقعة.',
      hindi:
          'Resign/leave पर bank account freeze हो सकता है — खासकर loan हो तो। Employer अक्सर final settlement सीधे bank में भेजता है; bank बकाया काट सकता है। 30–45 दिन पहले closure शुरू करें।',
      urdu:
          'Resign/leave پر bank account freeze ہو سکتا ہے — loan ہو تو خاص طور پر۔ Employer اکثر final settlement براہ راست bank میں بھیجتا ہے؛ bank واجب الادا رقم کاٹ سکتا ہے۔ 30–45 دن پہلے closure شروع کریں۔',
    ),
    'lq_check_bank_letters_title': l10nEntry(
      english: 'Liability letter → settle debt → clearance/NOC',
      arabic: 'خطاب مسؤولية → سداد → تخليص/NOC',
      hindi: 'Liability letter → debt settle → clearance/NOC',
      urdu: 'Liability letter → debt settle → clearance/NOC',
    ),
    'lq_check_bank_letters_body': l10nEntry(
      english:
          'Visit your bank branch in person: request a Liability Letter (confirms exact debt or debt-free status), settle any outstanding amount, then obtain a Clearance Letter/NOC (confirms no further liability). Both are often needed for smooth RP cancellation and gratuity release. If a freeze or deduction seems incorrect or excessive, contact the QCB Banking Customer Services Protection Department on 4445 6412 or 4445 6456.',
      arabic:
          'زر فرع البنك: اطلب خطاب مسؤولية، سدّد أي دين، ثم خطاب تخليص/NOC. غالباً مطلوب لإلغاء RP وصرف المكافأة. إن بدا التجميد أو الخصم غير صحيح، تواصل مع QCB Banking Customer Services Protection Department: 4445 6412 / 4445 6456.',
      hindi:
          'Bank branch जाएं: Liability Letter (exact debt), debt settle, Clearance/NOC। RP cancellation/gratuity के लिए अक्सर ज़रूरी। गलत freeze/deduction पर QCB Banking Customer Services Protection Department: 4445 6412 / 4445 6456.',
      urdu:
          'Bank branch جائیں: Liability Letter، debt settle، Clearance/NOC۔ RP cancellation/gratuity کے لیے اکثر ضروری۔ غلط freeze/deduction پر QCB Banking Customer Services Protection Department: 4445 6412 / 4445 6456.',
    ),
    'lq_check_health_title': l10nEntry(
      english: 'Plan for a health coverage gap',
      arabic: 'خطط لفجوة التغطية الصحية',
      hindi: 'Health coverage gap की योजना बनाएं',
      urdu: 'Health coverage gap کی منصوبہ بندی کریں',
    ),
    'lq_check_health_body': l10nEntry(
      english:
          'Employer-provided health insurance typically ends when employment ends — not on a date you choose — and there may be weeks before new coverage starts. Confirm exact gap dates with both outgoing and incoming employers. If you or dependents have a chronic condition or ongoing care needs, plan that gap carefully: look into short-term coverage options with your insurer or employer rather than assuming emergency-only cover will apply.',
      arabic:
          'التأمين الصحي من صاحب العمل ينتهي عادةً مع انتهاء العمل — وقد تمر أسابيع قبل تغطية جديدة. أكّد تواريخ الفجوة مع صاحب العمل الحالي والقادم. إن كان لديك أو لمعالين حالة مزمنة، خطط للفجوة وابحث عن تغطية قصيرة الأمد.',
      hindi:
          'Employer health insurance job end पर समाप्त होता है — नए cover से पहले हफ्तों का gap हो सकता है। दोनों employers से exact dates confirm करें। chronic/ongoing care हो तो short-term coverage options देखें।',
      urdu:
          'Employer health insurance job end پر ختم ہوتا ہے — نئے cover سے پہلے ہفتوں کا gap ہو سکتا ہے۔ دونوں employers سے exact dates confirm کریں۔ chronic/ongoing care ہو تو short-term coverage options دیکھیں۔',
    ),
    'lq_check_fines_title': l10nEntry(
      english: 'Settle traffic fines',
      arabic: 'تسوية مخالفات المرور',
      hindi: 'Traffic fines settle करें',
      urdu: 'Traffic fines settle کریں',
    ),
    'lq_check_fines_body': l10nEntry(
      english:
          'Clear outstanding traffic fines before departure — unpaid fines can block renewals, travel, and other MOI services.',
      arabic:
          'سدّد مخالفات المرور قبل المغادرة — المخالفات غير المسددة قد تمنع التجديد والسفر.',
      hindi:
          'Departure से पहले traffic fines clear करें — unpaid fines travel/renewals block कर सकते हैं।',
      urdu:
          'Departure سے پہلے traffic fines clear کریں — unpaid fines travel block کر سکتے ہیں۔',
    ),
    'lq_check_business_title': l10nEntry(
      english: 'Closing a business in Qatar?',
      arabic: 'إغلاق شركة في قطر؟',
      hindi: 'Qatar में business बंद?',
      urdu: 'Qatar میں business بند?',
    ),
    'lq_check_business_body': l10nEntry(
      english:
          'Business closure involves Ministry of Commerce and Industry notification and commercial registration cancellation — a separate, more complex path. Seek professional or legal advice; this app does not provide full business-closure guidance in v1.',
      arabic:
          'إغلاق الأعمال يتطلب إشعار وزارة التجارة وإلغاء السجل التجاري — مسار منفصل وأكثر تعقيداً. اطلب مشورة مهنية؛ التطبيق لا يقدم إرشاداً كاملاً في الإصدار الأول.',
      hindi:
          'Business closure अलग complex process है (MOCI, commercial registration) — professional advice लें; v1 में full guidance नहीं।',
      urdu:
          'Business closure الگ complex process ہے — professional advice لیں؛ v1 میں full guidance نہیں۔',
    ),

    // ── Kahramaa (hedged departure impact) ─────────────────────────────────
    'lq_kahramaa_heading': l10nEntry(
      english: 'Close your Kahramaa account with time to spare',
      arabic: 'أغلق حساب كهرماء مع وقت كافٍ',
      hindi: 'Kahramaa account समय से पहले बंद करें',
      urdu: 'Kahramaa account وقت سے پہلے بند کریں',
    ),
    'lq_kahramaa_body': l10nEntry(
      english:
          'Closing your Kahramaa (electricity/water) account requires an in-person visit with a technician-attended final meter reading — it cannot be completed same-day if left too late. Skipping final closure forfeits your QAR 2,000 security deposit. Even when closure is done correctly, deposit refunds can take weeks to months. Start this well before your final departure date, not on the last day.',
      arabic:
          'إغلاق حساب كهرماء يتطلب زيارة شخصية مع قراءة عداد نهائية بحضور فني — لا يمكن إنجازه في نفس اليوم إن تأخرت. التخطي يفقد وديعة 2000 ر.ق. حتى عند الإغلاق الصحيح، استرداد الوديعة قد يستغرق أسابيع إلى أشهر. ابدأ قبل موعد المغادرة النهائي.',
      hindi:
          'Kahramaa closure के लिए in-person visit + final meter reading (technician) ज़रूरी — last day पर same-day नहीं। Skip करने पर QAR 2,000 deposit forfeited। सही closure पर भी refund में हफ्ते-महीने। departure से पहले शुरू करें।',
      urdu:
          'Kahramaa closure کے لیے in-person visit + final meter reading (technician) — last day پر same-day نہیں۔ Skip پر QAR 2,000 deposit forfeited۔ صحیح closure پر بھی refund میں ہفتے-مہینے۔ departure سے پہلے شروع کریں۔',
    ),
    'lq_kahramaa_note': l10nEntry(
      english:
          'Note: Some people report that unresolved utility accounts can complicate or delay other close-out steps (such as final QID/residence permit cancellation). Confirm your own situation with Kahramaa and your sponsor — we have not independently verified a specific airport-level block from unpaid utility bills alone.',
      arabic:
          'ملاحظة: يُبلغ بعض الناس أن حسابات المرافق غير المغلقة قد تعقّد خطوات الإغلاق الأخرى (مثل إلغاء QID/RP). أكّد وضعك مع كهرماء والكفيل — لم نتحقق بشكل مستقل من حظر مطار محدد بسبب فواتير المرافق وحدها.',
      hindi:
          'Note: unresolved utility accounts से अन्य close-out steps delay हो सकते हैं (जैसे QID/RP cancellation) — Kahramaa/sponsor से confirm करें। unpaid utility bills से airport block — independently verified नहीं।',
      urdu:
          'Note: unresolved utility accounts سے دیگر close-out steps delay ہو سکتے ہیں (جیسے QID/RP cancellation) — Kahramaa/sponsor سے confirm کریں۔ unpaid utility bills سے airport block — independently verified نہیں۔',
    ),

    // ── Timeline restructure ───────────────────────────────────────────────
    'lq_timeline_heading': l10nEntry(
      english: 'Departure timeline',
      arabic: 'جدول المغادرة',
      hindi: 'Departure timeline',
      urdu: 'Departure timeline',
    ),
    'lq_timeline_all_done': l10nEntry(
      english: 'All checklist tasks marked done',
      arabic: 'جميع مهام القائمة مكتملة',
      hindi: 'All checklist tasks marked done',
      urdu: 'All checklist tasks marked done',
    ),
    'lq_timeline_remaining': l10nEntry(
      english: '{done} of {total} tasks done',
      arabic: '{done} من {total} مهام منجزة',
      hindi: '{done} of {total} tasks done',
      urdu: '{done} of {total} tasks done',
    ),
    'lq_timeline_stage_progress': l10nEntry(
      english: '{done}/{total} in this stage',
      arabic: '{done}/{total} في هذه المرحلة',
      hindi: '{done}/{total} in this stage',
      urdu: '{done}/{total} in this stage',
    ),
    'lq_timeline_early_short': l10nEntry(
      english: '60–90+ days',
      arabic: '60–90+ يوم',
      hindi: '60–90+ days',
      urdu: '60–90+ days',
    ),
    'lq_timeline_mid_short': l10nEntry(
      english: '30 days',
      arabic: '30 يوم',
      hindi: '30 days',
      urdu: '30 days',
    ),
    'lq_timeline_late_short': l10nEntry(
      english: '7 days',
      arabic: '7 أيام',
      hindi: '7 days',
      urdu: '7 days',
    ),
    'lq_timeline_departure_short': l10nEntry(
      english: 'Departure',
      arabic: 'يوم المغادرة',
      hindi: 'Departure',
      urdu: 'Departure',
    ),
    'lq_timeline_early_heading': l10nEntry(
      english: '60–90+ days before departure',
      arabic: '60–90+ يوماً قبل المغادرة',
      hindi: '60–90+ days before departure',
      urdu: '60–90+ days before departure',
    ),
    'lq_timeline_early_subtitle': l10nEntry(
      english:
          'Early planning: settlement discussion, home-country re-entry research, and coverage gaps.',
      arabic:
          'تخطيط مبكر: مناقشة التسوية، ومتطلبات العودة للوطن، وفجوات التغطية.',
      hindi:
          'Early planning: settlement discussion, home-country re-entry, coverage gaps.',
      urdu:
          'Early planning: settlement discussion, home-country re-entry, coverage gaps.',
    ),
    'lq_timeline_mid_heading': l10nEntry(
      english: '30 days before departure',
      arabic: '30 يوماً قبل المغادرة',
      hindi: '30 days before departure',
      urdu: '30 days before departure',
    ),
    'lq_timeline_mid_subtitle': l10nEntry(
      english:
          'Mid-stage close-out: utilities, banking, fines, and official exit-permit checks.',
      arabic:
          'إغلاق منتصف المدة: المرافق، البنوك، المخالفات، وفحوصات تصريح الخروج الرسمية.',
      hindi:
          'Mid-stage: utilities, banking, fines, official exit-permit checks.',
      urdu:
          'Mid-stage: utilities, banking, fines, official exit-permit checks.',
    ),
    'lq_timeline_late_heading': l10nEntry(
      english: '7 days before departure',
      arabic: '7 أيام قبل المغادرة',
      hindi: '7 days before departure',
      urdu: '7 days before departure',
    ),
    'lq_timeline_late_subtitle': l10nEntry(
      english:
          'Late-stage: RP cancellation steps and final settlement confirmation.',
      arabic:
          'مرحلة متأخرة: خطوات إلغاء RP وتأكيد التسوية النهائية.',
      hindi: 'Late-stage: RP cancellation and final settlement confirmation.',
      urdu: 'Late-stage: RP cancellation and final settlement confirmation.',
    ),
    'lq_timeline_departure_heading': l10nEntry(
      english: 'Departure day & final steps',
      arabic: 'يوم المغادرة والخطوات الأخيرة',
      hindi: 'Departure day & final steps',
      urdu: 'Departure day & final steps',
    ),
    'lq_timeline_departure_subtitle': l10nEntry(
      english:
          'Final MOI travel-ban check and export your departure document bundle.',
      arabic:
          'فحص حظر السفر النهائي عبر MOI وتصدير حزمة مستندات المغادرة.',
      hindi:
          'Final MOI travel-ban check and export departure document bundle.',
      urdu:
          'Final MOI travel-ban check and export departure document bundle.',
    ),
    'lq_checklist_sign_in': l10nEntry(
      english: 'Sign in to save checklist progress across devices.',
      arabic: 'سجّل الدخول لحفظ تقدم القائمة عبر الأجهزة.',
      hindi: 'Sign in to save checklist progress across devices.',
      urdu: 'Sign in to save checklist progress across devices.',
    ),

    // ── Cross-links (link-out only — Raabta never verifies status) ─────────
    'lq_link_moi_exit_title': l10nEntry(
      english: 'Check exit-permit rules on MOI / Metrash',
      arabic: 'تحقق من قواعد تصريح الخروج عبر MOI / Metrash',
      hindi: 'MOI / Metrash पर exit-permit rules check करें',
      urdu: 'MOI / Metrash پر exit-permit rules check کریں',
    ),
    'lq_link_moi_exit_body': l10nEntry(
      english:
          'Raabta does not verify your exit-permit status. Use the official MOI / Metrash portal to confirm current rules and any application status yourself.',
      arabic:
          'Raabta لا تتحقق من وضع تصريح الخروج. استخدم بوابة MOI / Metrash الرسمية للتأكيد بنفسك.',
      hindi:
          'Raabta exit-permit status verify नहीं करती। Official MOI / Metrash portal से खुद confirm करें।',
      urdu:
          'Raabta exit-permit status verify نہیں کرتی۔ Official MOI / Metrash portal سے خود confirm کریں۔',
    ),
    'lq_link_moi_exit_action': l10nEntry(
      english: 'Open MOI / Metrash portal',
      arabic: 'فتح بوابة MOI / Metrash',
      hindi: 'MOI / Metrash portal खोलें',
      urdu: 'MOI / Metrash portal کھولیں',
    ),
    'lq_link_moi_status_title': l10nEntry(
      english: 'Confirm RP / visa status on MOI portal',
      arabic: 'تأكيد وضع RP / التأشيرة على بوابة MOI',
      hindi: 'MOI portal पर RP / visa status confirm करें',
      urdu: 'MOI portal پر RP / visa status confirm کریں',
    ),
    'lq_link_moi_status_body': l10nEntry(
      english:
          'Raabta does not verify live immigration status. Confirm cancellation windows and fine amounts on the official MOI portal at the time you act.',
      arabic:
          'Raabta لا تتحقق من الوضع الهجري المباشر. أكّد نوافذ الإلغاء والغرامات على بوابة MOI الرسمية.',
      hindi:
          'Raabta live immigration status verify नहीं करती। Official MOI portal पर windows/fines confirm करें।',
      urdu:
          'Raabta live immigration status verify نہیں کرتی۔ Official MOI portal پر confirm کریں۔',
    ),
    'lq_link_moi_status_action': l10nEntry(
      english: 'Open official MOI portal',
      arabic: 'فتح بوابة MOI الرسمية',
      hindi: 'Official MOI portal खोलें',
      urdu: 'Official MOI portal کھولیں',
    ),
    'lq_link_eosb_mid_title': l10nEntry(
      english: 'EOSB final settlement check (30-day stage)',
      arabic: 'فحص تسوية EOSB النهائية (مرحلة 30 يوم)',
      hindi: 'EOSB final settlement check (30-day stage)',
      urdu: 'EOSB final settlement check (30-day stage)',
    ),
    'lq_link_eosb_mid_body': l10nEntry(
      english:
          'Review your saved EOSB entitlement before negotiating your final payout — uses Raabta\'s existing calculation, not a duplicate engine.',
      arabic:
          'راجع مستحقات EOSB المحفوظة قبل التفاوض على الدفعة النهائية — عبر حساب Raabta الحالي.',
      hindi:
          'Final payout negotiate करने से पहले saved EOSB entitlement review करें।',
      urdu:
          'Final payout negotiate کرنے سے پہلے saved EOSB entitlement review کریں۔',
    ),
    'lq_link_eosb_late_title': l10nEntry(
      english: 'EOSB final settlement check (7-day stage)',
      arabic: 'فحص تسوية EOSB النهائية (مرحلة 7 أيام)',
      hindi: 'EOSB final settlement check (7-day stage)',
      urdu: 'EOSB final settlement check (7-day stage)',
    ),
    'lq_link_eosb_late_body': l10nEntry(
      english:
          'One last review of your EOSB breakdown before departure — open your saved result or run a fresh calculation.',
      arabic:
          'مراجعة أخيرة لتفاصيل EOSB قبل المغادرة — افتح النتيجة المحفوظة أو أنشئ حساباً جديداً.',
      hindi:
          'Departure से पहले EOSB breakdown की last review — saved result खोलें।',
      urdu:
          'Departure سے پہلے EOSB breakdown کی last review — saved result کھولیں۔',
    ),

    // ── Departure document bundle ───────────────────────────────────────────
    'lq_bundle_export_title': l10nEntry(
      english: 'Export departure document bundle',
      arabic: 'تصدير حزمة مستندات المغادرة',
      hindi: 'Export departure document bundle',
      urdu: 'Export departure document bundle',
    ),
    'lq_bundle_export_subtitle': l10nEntry(
      english:
          'Combine passport, visa, QID, contract, payslips, and EOSB documents from your Vault into one PDF — review and choose what to include.',
      arabic:
          'اجمع جواز السفر والتأشيرة وQID والعقد وكشوف الرواتب ومستندات EOSB من خزنتك في PDF واحد — راجع واختر ما تريد.',
      hindi:
          'Vault से passport, visa, QID, contract, payslips, EOSB docs को एक PDF में — review करके choose करें।',
      urdu:
          'Vault سے passport, visa, QID, contract, payslips, EOSB docs ایک PDF میں — review کر کے choose کریں۔',
    ),
    'lq_bundle_open_sheet': l10nEntry(
      english: 'Export my departure bundle',
      arabic: 'تصدير حزمة مغادرتي',
      hindi: 'Export my departure bundle',
      urdu: 'Export my departure bundle',
    ),
    'lq_bundle_review_heading': l10nEntry(
      english: 'Review documents for your bundle',
      arabic: 'مراجعة مستندات حزمتك',
      hindi: 'Review documents for your bundle',
      urdu: 'Review documents for your bundle',
    ),
    'lq_bundle_review_hint': l10nEntry(
      english:
          'Toggle off anything you do not want in this export. Raabta merges selected scans using the same PDF engine as Document Scanner.',
      arabic:
          'أوقف أي مستند لا تريده في هذا التصدير. Raabta تدمج الملفات المختارة بنفس محرك PDF.',
      hindi:
          'जो export में नहीं चाहिए उसे toggle off करें। Same PDF engine as Document Scanner।',
      urdu:
          'جو export میں نہیں چاہیے toggle off کریں۔ Same PDF engine as Document Scanner۔',
    ),
    'lq_bundle_selected_count': l10nEntry(
      english: '{count} document(s) selected',
      arabic: '{count} مستند(ات) محددة',
      hindi: '{count} document(s) selected',
      urdu: '{count} document(s) selected',
    ),
    'lq_bundle_export_action': l10nEntry(
      english: 'Generate & share PDF',
      arabic: 'إنشاء PDF ومشاركته',
      hindi: 'Generate & share PDF',
      urdu: 'Generate & share PDF',
    ),
    'lq_bundle_cancel': l10nEntry(
      english: 'Cancel',
      arabic: 'إلغاء',
      hindi: 'Cancel',
      urdu: 'Cancel',
    ),
    'lq_bundle_empty': l10nEntry(
      english:
          'No departure-related documents found in your Vault yet. Scan key documents first.',
      arabic:
          'لم يُعثر على مستندات مغادرة في خزنتك بعد. امسح المستندات الأساسية أولاً.',
      hindi:
          'Vault में departure-related documents नहीं मिले। पहले key documents scan करें।',
      urdu:
          'Vault میں departure-related documents نہیں ملے۔ پہلے key documents scan کریں۔',
    ),
    'lq_bundle_missing_passport': l10nEntry(
      english:
          'No passport scan found in your Vault — consider scanning it before departure.',
      arabic:
          'لم يُعثر على مسح جواز سفر — فكّر في مسحه قبل المغادرة.',
      hindi:
          'Vault में passport scan नहीं — departure से पहले scan करें।',
      urdu:
          'Vault میں passport scan نہیں — departure سے پہلے scan کریں۔',
    ),
    'lq_bundle_missing_visa': l10nEntry(
      english:
          'No visa scan found in your Vault — consider scanning it before departure.',
      arabic:
          'لم يُعثر على مسح تأشيرة — فكّر في مسحها قبل المغادرة.',
      hindi:
          'Vault में visa scan नहीं — departure से पहले scan करें।',
      urdu:
          'Vault میں visa scan نہیں — departure سے پہلے scan کریں۔',
    ),
    'lq_bundle_missing_qid': l10nEntry(
      english:
          'No QID scan found in your Vault — consider scanning it (or a cancellation confirmation) before departure.',
      arabic:
          'لم يُعثر على مسح QID — فكّر في مسحه (أو تأكيد الإلغاء) قبل المغادرة.',
      hindi:
          'Vault में QID scan नहीं — departure से पहले scan करें (या cancellation confirmation)।',
      urdu:
          'Vault میں QID scan نہیں — departure سے پہلے scan کریں۔',
    ),
    'lq_bundle_missing_generic': l10nEntry(
      english: 'A commonly needed document category was not found in your Vault.',
      arabic: 'فئة مستند مطلوبة لم تُعثر في خزنتك.',
      hindi: 'Commonly needed document category Vault में नहीं मिली।',
      urdu: 'Commonly needed document category Vault میں نہیں ملی۔',
    ),
    'lq_bundle_cat_passport': l10nEntry(
      english: 'Passport',
      arabic: 'جواز سفر',
      hindi: 'Passport',
      urdu: 'Passport',
    ),
    'lq_bundle_cat_visa': l10nEntry(
      english: 'Visa',
      arabic: 'تأشيرة',
      hindi: 'Visa',
      urdu: 'Visa',
    ),
    'lq_bundle_cat_qid': l10nEntry(
      english: 'QID',
      arabic: 'QID',
      hindi: 'QID',
      urdu: 'QID',
    ),
    'lq_bundle_cat_contract': l10nEntry(
      english: 'Employment contract',
      arabic: 'عقد عمل',
      hindi: 'Employment contract',
      urdu: 'Employment contract',
    ),
    'lq_bundle_cat_payslip': l10nEntry(
      english: 'Payslip / salary proof',
      arabic: 'كشف راتب / إثبات',
      hindi: 'Payslip / salary proof',
      urdu: 'Payslip / salary proof',
    ),
    'lq_bundle_cat_eosb': l10nEntry(
      english: 'EOSB / settlement document',
      arabic: 'مستند EOSB / تسوية',
      hindi: 'EOSB / settlement document',
      urdu: 'EOSB / settlement document',
    ),
    'lq_bundle_cat_exit_permit': l10nEntry(
      english: 'Exit permit documentation',
      arabic: 'مستندات تصريح الخروج',
      hindi: 'Exit permit documentation',
      urdu: 'Exit permit documentation',
    ),
    'lq_bundle_exporting': l10nEntry(
      english: 'Building your departure PDF…',
      arabic: 'جاري إنشاء PDF المغادرة…',
      hindi: 'Building your departure PDF…',
      urdu: 'Building your departure PDF…',
    ),
    'lq_bundle_export_success': l10nEntry(
      english: 'Departure bundle ready — {count} page(s) merged.',
      arabic: 'حزمة المغادرة جاهزة — {count} صفحة/صفحات مدمجة.',
      hindi: 'Departure bundle ready — {count} page(s) merged.',
      urdu: 'Departure bundle ready — {count} page(s) merged.',
    ),
    'lq_bundle_export_failed': l10nEntry(
      english: 'Could not build the departure bundle. Try again.',
      arabic: 'تعذر إنشاء حزمة المغادرة. حاول مرة أخرى.',
      hindi: 'Could not build the departure bundle. Try again.',
      urdu: 'Could not build the departure bundle. Try again.',
    ),

    // ── Other close-out steps (Part A) ────────────────────────────────────
    'lq_closeout_section_title': l10nEntry(
      english: 'Other close-out steps',
      arabic: 'خطوات إغلاق إضافية',
      hindi: 'Other close-out steps',
      urdu: 'Other close-out steps',
    ),
    'lq_closeout_section_teaser': l10nEntry(
      english:
          'Vehicle, school, pets, certificates, home, and airport signposts — confirm details with official sources.',
      arabic:
          'إرشادات للمركبة والمدرسة والحيوانات والشهادات والسكن والمطار — أكّد التفاصيل من المصادر الرسمية.',
      hindi:
          'Vehicle, school, pets, certificates, home, and airport signposts — confirm details with official sources.',
      urdu:
          'Vehicle, school, pets, certificates, home, and airport signposts — confirm details with official sources.',
    ),
    'lq_closeout_offline_hint': l10nEntry(
      english: 'Guidance works offline; official links need internet.',
      arabic: 'الإرشادات تعمل دون اتصال؛ الروابط الرسمية تحتاج إنترنت.',
      hindi: 'Guidance works offline; official links need internet.',
      urdu: 'Guidance works offline; official links need internet.',
    ),
    'lq_closeout_needs_internet': l10nEntry(
      english: 'needs internet',
      arabic: 'يتطلب إنترنت',
      hindi: 'needs internet',
      urdu: 'needs internet',
    ),
    'lq_closeout_verified_footer': l10nEntry(
      english: 'Links last checked {date}. Source publication dates shown where applicable.',
      arabic: 'آخر مراجعة للروابط {date}. تواريخ النشر تظهر حيث ينطبق.',
      hindi: 'Links last checked {date}. Source publication dates shown where applicable.',
      urdu: 'Links last checked {date}. Source publication dates shown where applicable.',
    ),
    'lq_closeout_secondary_source': l10nEntry(
      english: 'Also see {name} reporting ({date}) — not a government page.',
      arabic: 'راجع أيضاً {name} ({date}) — ليس صفحة حكومية.',
      hindi: 'Also see {name} reporting ({date}) — not a government page.',
      urdu: 'Also see {name} reporting ({date}) — not a government page.',
    ),
    'lq_closeout_group_vehicle': l10nEntry(
      english: 'Vehicle & traffic',
      arabic: 'المركبة والمرور',
      hindi: 'Vehicle & traffic',
      urdu: 'Vehicle & traffic',
    ),
    'lq_closeout_group_school': l10nEntry(
      english: 'School records',
      arabic: 'سجلات المدرسة',
      hindi: 'School records',
      urdu: 'School records',
    ),
    'lq_closeout_group_pets': l10nEntry(
      english: 'Pets',
      arabic: 'الحيوانات الأليفة',
      hindi: 'Pets',
      urdu: 'Pets',
    ),
    'lq_closeout_group_pcc': l10nEntry(
      english: 'Police clearance',
      arabic: 'شهادة حسن السيرة',
      hindi: 'Police clearance',
      urdu: 'Police clearance',
    ),
    'lq_closeout_group_certificates': l10nEntry(
      english: 'Traffic certificates',
      arabic: 'شهادات المرور',
      hindi: 'Traffic certificates',
      urdu: 'Traffic certificates',
    ),
    'lq_closeout_group_home': l10nEntry(
      english: 'Home & belongings',
      arabic: 'السكن والمتعلقات',
      hindi: 'Home & belongings',
      urdu: 'Home & belongings',
    ),
    'lq_closeout_group_airport': l10nEntry(
      english: 'Airport & digital ID',
      arabic: 'المطار والهوية الرقمية',
      hindi: 'Airport & digital ID',
      urdu: 'Airport & digital ID',
    ),
    'lq_closeout_vehicle_transfer_title': l10nEntry(
      english: 'Transfer or sell your vehicle before you leave',
      arabic: 'انقل ملكية مركبتك أو بعها قبل المغادرة',
      hindi: 'Transfer or sell your vehicle before you leave',
      urdu: 'Transfer or sell your vehicle before you leave',
    ),
    'lq_closeout_vehicle_transfer_body': l10nEntry(
      english:
          'Ownership changes are handled through MOI/Metrash traffic services. Confirm with MOI/Metrash whether vehicle ownership or registration affects your specific cancellation case.',
      arabic:
          'تغيير الملكية عبر خدمات المرور في MOI/Metrash. أكّد مع MOI/Metrash ما إذا كانت ملكية المركبة أو تسجيلها تؤثر على حالة إلغاء إقامتك.',
      hindi:
          'Ownership changes are handled through MOI/Metrash traffic services. Confirm with MOI/Metrash whether vehicle ownership or registration affects your specific cancellation case.',
      urdu:
          'Ownership changes are handled through MOI/Metrash traffic services. Confirm with MOI/Metrash whether vehicle ownership or registration affects your specific cancellation case.',
    ),
    'lq_closeout_traffic_fines_title': l10nEntry(
      english: 'Clear outstanding traffic violations',
      arabic: 'تسوية المخالفات المرورية المعلقة',
      hindi: 'Clear outstanding traffic violations',
      urdu: 'Clear outstanding traffic violations',
    ),
    'lq_closeout_traffic_fines_body': l10nEntry(
      english:
          'Use MOI/Metrash traffic inquiries to check and pay fines. For planning, use the Traffic fines checklist item in the Mid-stage timeline above — Raabta does not verify violations.',
      arabic:
          'Use MOI/Metrash traffic inquiries to check and pay fines. For planning, use the Traffic fines checklist item in the Mid-stage timeline above — Raabta does not verify violations.',
      hindi:
          'Use MOI/Metrash traffic inquiries to check and pay fines. For planning, use the Traffic fines checklist item in the Mid-stage timeline above — Raabta does not verify violations.',
      urdu:
          'Use MOI/Metrash traffic inquiries to check and pay fines. For planning, use the Traffic fines checklist item in the Mid-stage timeline above — Raabta does not verify violations.',
    ),
    'lq_closeout_vehicle_export_title': l10nEntry(
      english: 'Export or exit-permit requirements for vehicles',
      arabic: 'متطلبات تصدير المركبة أو تصريح الخروج',
      hindi: 'Export or exit-permit requirements for vehicles',
      urdu: 'Export or exit-permit requirements for vehicles',
    ),
    'lq_closeout_vehicle_export_body': l10nEntry(
      english:
          'MOI traffic rules may require permits or certificates before a vehicle leaves Qatar. Use MOI Traffic Certificates enquiry for official services — Raabta does not list fees or processing times.',
      arabic:
          'MOI traffic rules may require permits or certificates before a vehicle leaves Qatar. Use MOI Traffic Certificates enquiry for official services — Raabta does not list fees or processing times.',
      hindi:
          'MOI traffic rules may require permits or certificates before a vehicle leaves Qatar. Use MOI Traffic Certificates enquiry for official services — Raabta does not list fees or processing times.',
      urdu:
          'MOI traffic rules may require permits or certificates before a vehicle leaves Qatar. Use MOI Traffic Certificates enquiry for official services — Raabta does not list fees or processing times.',
    ),
    'lq_closeout_school_title': l10nEntry(
      english: 'Arrange school records before departure',
      arabic: 'رتّب سجلات المدرسة قبل المغادرة',
      hindi: 'Arrange school records before departure',
      urdu: 'Arrange school records before departure',
    ),
    'lq_closeout_school_body': l10nEntry(
      english:
          'Notify the school early and request transcripts or statements through MOEHE e-services. Ask the school and your destination country what attestation or equivalency they require — Raabta does not certify documents.',
      arabic:
          'Notify the school early and request transcripts or statements through MOEHE e-services. Ask the school and your destination country what attestation or equivalency they require — Raabta does not certify documents.',
      hindi:
          'Notify the school early and request transcripts or statements through MOEHE e-services. Ask the school and your destination country what attestation or equivalency they require — Raabta does not certify documents.',
      urdu:
          'Notify the school early and request transcripts or statements through MOEHE e-services. Ask the school and your destination country what attestation or equivalency they require — Raabta does not certify documents.',
    ),
    'lq_closeout_pets_title': l10nEntry(
      english: 'Plan pet travel early',
      arabic: 'خطّط لسفر الحيوانات الأليفة مبكراً',
      hindi: 'Plan pet travel early',
      urdu: 'Plan pet travel early',
    ),
    'lq_closeout_pets_body': l10nEntry(
      english:
          'Export approvals, vaccinations, and certificate rules depend on the competent authority and your destination. Confirm requirements directly — Raabta does not provide veterinary or relocation advice.',
      arabic:
          'Export approvals, vaccinations, and certificate rules depend on the competent authority and your destination. Confirm requirements directly — Raabta does not provide veterinary or relocation advice.',
      hindi:
          'Export approvals, vaccinations, and certificate rules depend on the competent authority and your destination. Confirm requirements directly — Raabta does not provide veterinary or relocation advice.',
      urdu:
          'Export approvals, vaccinations, and certificate rules depend on the competent authority and your destination. Confirm requirements directly — Raabta does not provide veterinary or relocation advice.',
    ),
    'lq_closeout_pcc_title': l10nEntry(
      english: 'Police clearance (Certificate of Good Conduct)',
      arabic: 'شهادة حسن السيرة والسلوك',
      hindi: 'Police clearance (Certificate of Good Conduct)',
      urdu: 'Police clearance (Certificate of Good Conduct)',
    ),
    'lq_closeout_pcc_body': l10nEntry(
      english:
          'MOI describes how to apply while you are in Qatar and separate routes for applicants outside the country. Raabta does not guarantee eligibility or approval — confirm requirements on the official MOI pages.',
      arabic:
          'MOI describes how to apply while you are in Qatar and separate routes for applicants outside the country. Raabta does not guarantee eligibility or approval — confirm requirements on the official MOI pages.',
      hindi:
          'MOI describes how to apply while you are in Qatar and separate routes for applicants outside the country. Raabta does not guarantee eligibility or approval — confirm requirements on the official MOI pages.',
      urdu:
          'MOI describes how to apply while you are in Qatar and separate routes for applicants outside the country. Raabta does not guarantee eligibility or approval — confirm requirements on the official MOI pages.',
    ),
    'lq_closeout_traffic_certs_title': l10nEntry(
      english: 'MOI traffic certificates enquiry',
      arabic: 'الاستعلام عن شهادات المرور',
      hindi: 'MOI traffic certificates enquiry',
      urdu: 'MOI traffic certificates enquiry',
    ),
    'lq_closeout_traffic_certs_body': l10nEntry(
      english:
          'Use MOI/Metrash traffic certificate services for official documents. Raabta does not promise a specific certificate type (such as a driving-experience letter) unless MOI lists it on the service you open.',
      arabic:
          'Use MOI/Metrash traffic certificate services for official documents. Raabta does not promise a specific certificate type (such as a driving-experience letter) unless MOI lists it on the service you open.',
      hindi:
          'Use MOI/Metrash traffic certificate services for official documents. Raabta does not promise a specific certificate type (such as a driving-experience letter) unless MOI lists it on the service you open.',
      urdu:
          'Use MOI/Metrash traffic certificate services for official documents. Raabta does not promise a specific certificate type (such as a driving-experience letter) unless MOI lists it on the service you open.',
    ),
    'lq_closeout_tenancy_title': l10nEntry(
      english: 'Tenancy notice and termination',
      arabic: 'إشعار وإنهاء الإيجار',
      hindi: 'Tenancy notice and termination',
      urdu: 'Tenancy notice and termination',
    ),
    'lq_closeout_tenancy_body': l10nEntry(
      english:
          'Open the Tenancy Truth Engine for notice periods and termination steps — Raabta does not cancel a lease for you.',
      arabic:
          'Open the Tenancy Truth Engine for notice periods and termination steps — Raabta does not cancel a lease for you.',
      hindi:
          'Open the Tenancy Truth Engine for notice periods and termination steps — Raabta does not cancel a lease for you.',
      urdu:
          'Open the Tenancy Truth Engine for notice periods and termination steps — Raabta does not cancel a lease for you.',
    ),
    'lq_closeout_marketplace_title': l10nEntry(
      english: 'Sell or manage belongings',
      arabic: 'بيع أو إدارة المتعلقات',
      hindi: 'Sell or manage belongings',
      urdu: 'Sell or manage belongings',
    ),
    'lq_closeout_marketplace_body': l10nEntry(
      english:
          'Browse Marketplace to list items you will not take with you. A listing does not guarantee a sale.',
      arabic:
          'Browse Marketplace to list items you will not take with you. A listing does not guarantee a sale.',
      hindi:
          'Browse Marketplace to list items you will not take with you. A listing does not guarantee a sale.',
      urdu:
          'Browse Marketplace to list items you will not take with you. A listing does not guarantee a sale.',
    ),
    'lq_closeout_qdi_title': l10nEntry(
      english: 'Digital ID and airport e-gates',
      arabic: 'الهوية الرقمية وبوابات المطار',
      hindi: 'Digital ID and airport e-gates',
      urdu: 'Digital ID and airport e-gates',
    ),
    'lq_closeout_qdi_body': l10nEntry(
      english:
          'Qatar Digital Identity (QDI) and airport e-gate options may be available to eligible users per MOI guidance. Keep your physical passport and valid travel documents with you, confirm requirements with your airline and the relevant authorities, and do not assume QDI replaces a passport.',
      arabic:
          'Qatar Digital Identity (QDI) and airport e-gate options may be available to eligible users per MOI guidance. Keep your physical passport and valid travel documents with you, confirm requirements with your airline and the relevant authorities, and do not assume QDI replaces a passport.',
      hindi:
          'Qatar Digital Identity (QDI) and airport e-gate options may be available to eligible users per MOI guidance. Keep your physical passport and valid travel documents with you, confirm requirements with your airline and the relevant authorities, and do not assume QDI replaces a passport.',
      urdu:
          'Qatar Digital Identity (QDI) and airport e-gate options may be available to eligible users per MOI guidance. Keep your physical passport and valid travel documents with you, confirm requirements with your airline and the relevant authorities, and do not assume QDI replaces a passport.',
    ),
    'lq_closeout_action_metrash': l10nEntry(
      english: 'Open Metrash / MOI portal',
      arabic: 'فتح Metrash / MOI',
      hindi: 'Open Metrash / MOI portal',
      urdu: 'Open Metrash / MOI portal',
    ),
    'lq_closeout_action_traffic_inquiry': l10nEntry(
      english: 'MOI traffic inquiries',
      arabic: 'استعلامات المرور MOI',
      hindi: 'MOI traffic inquiries',
      urdu: 'MOI traffic inquiries',
    ),
    'lq_closeout_action_traffic_certificates': l10nEntry(
      english: 'MOI traffic certificates',
      arabic: 'شهادات المرور MOI',
      hindi: 'MOI traffic certificates',
      urdu: 'MOI traffic certificates',
    ),
    'lq_closeout_action_qna_vehicle_exit': l10nEntry(
      english: 'QNA report on vehicle exit rules',
      arabic: 'تقرير QNA عن قواعد خروج المركبات',
      hindi: 'QNA report on vehicle exit rules',
      urdu: 'QNA report on vehicle exit rules',
    ),
    'lq_closeout_action_moehe_portal': l10nEntry(
      english: 'MOEHE e-services portal',
      arabic: 'بوابة MOEHE',
      hindi: 'MOEHE e-services portal',
      urdu: 'MOEHE e-services portal',
    ),
    'lq_closeout_action_municipality': l10nEntry(
      english: 'Ministry of Municipality services',
      arabic: 'خدمات وزارة البلدية',
      hindi: 'Ministry of Municipality services',
      urdu: 'Ministry of Municipality services',
    ),
    'lq_closeout_action_pcc': l10nEntry(
      english: 'MOI conduct certificate information',
      arabic: 'معلومات شهادة حسن السيرة MOI',
      hindi: 'MOI conduct certificate information',
      urdu: 'MOI conduct certificate information',
    ),
    'lq_closeout_action_tenancy': l10nEntry(
      english: 'Open Tenancy Truth Engine',
      arabic: 'فتح Tenancy Truth Engine',
      hindi: 'Open Tenancy Truth Engine',
      urdu: 'Open Tenancy Truth Engine',
    ),
    'lq_closeout_action_marketplace': l10nEntry(
      english: 'Open Marketplace',
      arabic: 'فتح Marketplace',
      hindi: 'Open Marketplace',
      urdu: 'Open Marketplace',
    ),
    'lq_closeout_action_moi_portal': l10nEntry(
      english: 'MOI portal — digital ID services',
      arabic: 'بوابة MOI — الهوية الرقمية',
      hindi: 'MOI portal — digital ID services',
      urdu: 'MOI portal — digital ID services',
    ),
    'lq_closeout_source_moi': l10nEntry(
      english: 'Ministry of Interior (Qatar)',
      arabic: 'وزارة الداخلية (قطر)',
      hindi: 'Ministry of Interior (Qatar)',
      urdu: 'Ministry of Interior (Qatar)',
    ),
    'lq_closeout_source_moi_traffic': l10nEntry(
      english: 'MOI Traffic Services',
      arabic: 'خدمات المرور MOI',
      hindi: 'MOI Traffic Services',
      urdu: 'MOI Traffic Services',
    ),
    'lq_closeout_source_qna': l10nEntry(
      english: 'Qatar News Agency',
      arabic: 'وكالة الأنباء القطرية',
      hindi: 'Qatar News Agency',
      urdu: 'Qatar News Agency',
    ),
    'lq_closeout_source_moehe': l10nEntry(
      english: 'MOEHE',
      arabic: 'وزارة التربية والتعليم',
      hindi: 'MOEHE',
      urdu: 'MOEHE',
    ),
    'lq_closeout_source_municipality': l10nEntry(
      english: 'Ministry of Municipality',
      arabic: 'وزارة البلدية',
      hindi: 'Ministry of Municipality',
      urdu: 'Ministry of Municipality',
    ),
    // ── Departure Plan (local-only ticks) ───────────────────────────────────
    'lq_dp_section_title': l10nEntry(
      english: 'Plan your departure',
      arabic: 'خطّط لمغادرتك',
      hindi: 'अपनी departure प्लान करें',
      urdu: 'اپنی departure پلان کریں',
    ),
    'lq_dp_section_subtitle': l10nEntry(
      english:
          'Optional checklist stored only on this device — separate from the timeline below.',
      arabic:
          'قائمة اختيارية تُحفظ على هذا الجهاز فقط — منفصلة عن الجدول الزمني أدناه.',
      hindi:
          'Optional checklist stored only on this device — separate from the timeline below.',
      urdu:
          'Optional checklist stored only on this device — separate from the timeline below.',
    ),
    'lq_dp_separate_state_note': l10nEntry(
      english:
          'Ticks here do not sync to your account timeline checklist or other close-out steps.',
      arabic:
          'التأشيرات هنا لا تُزامَن مع قائمة الجدول الزمني أو خطوات الإغلاق الأخرى.',
      hindi:
          'Ticks here do not sync to your account timeline checklist or other close-out steps.',
      urdu:
          'Ticks here do not sync to your account timeline checklist or other close-out steps.',
    ),
    'lq_dp_loading': l10nEntry(
      english: 'Loading your departure plan…',
      arabic: 'جاري تحميل خطة المغادرة…',
      hindi: 'Loading your departure plan…',
      urdu: 'Loading your departure plan…',
    ),
    'lq_dp_load_error': l10nEntry(
      english: 'Could not load your departure plan. Try again later.',
      arabic: 'تعذّر تحميل خطة المغادرة. حاول لاحقاً.',
      hindi: 'Could not load your departure plan. Try again later.',
      urdu: 'Could not load your departure plan. Try again later.',
    ),
    'lq_dp_save_failed': l10nEntry(
      english: 'Could not save that change. Your previous state is restored.',
      arabic: 'تعذّر حفظ التغيير. تمت استعادة الحالة السابقة.',
      hindi: 'Could not save that change. Your previous state is restored.',
      urdu: 'Could not save that change. Your previous state is restored.',
    ),
    'lq_dp_progress': l10nEntry(
      english: '{done} of {total} plan steps marked done',
      arabic: '{done} من {total} خطوات الخطة مكتملة',
      hindi: '{done} of {total} plan steps marked done',
      urdu: '{done} of {total} plan steps marked done',
    ),
    'lq_dp_date_heading': l10nEntry(
      english: 'Planned departure date (optional)',
      arabic: 'تاريخ المغادرة المخطط (اختياري)',
      hindi: 'Planned departure date (optional)',
      urdu: 'Planned departure date (optional)',
    ),
    'lq_dp_date_not_set': l10nEntry(
      english: 'Not set yet',
      arabic: 'لم يُحدَّد بعد',
      hindi: 'Not set yet',
      urdu: 'Not set yet',
    ),
    'lq_dp_date_pick': l10nEntry(
      english: 'Choose date',
      arabic: 'اختر التاريخ',
      hindi: 'Choose date',
      urdu: 'Choose date',
    ),
    'lq_dp_date_clear': l10nEntry(
      english: 'Clear',
      arabic: 'مسح',
      hindi: 'Clear',
      urdu: 'Clear',
    ),
    'lq_dp_timing_suggested': l10nEntry(
      english: 'Suggested planning step — not a legal deadline',
      arabic: 'خطوة تخطيط مقترحة — ليست موعداً قانونياً',
      hindi: 'Suggested planning step — not a legal deadline',
      urdu: 'Suggested planning step — not a legal deadline',
    ),
    'lq_dp_timing_official': l10nEntry(
      english: 'Official rules apply — confirm current details on the portal',
      arabic: 'تسري قواعد رسمية — أكّد التفاصيل الحالية على البوابة',
      hindi: 'Official rules apply — confirm current details on the portal',
      urdu: 'Official rules apply — confirm current details on the portal',
    ),
    'lq_dp_action_open': l10nEntry(
      english: 'Open',
      arabic: 'فتح',
      hindi: 'Open',
      urdu: 'Open',
    ),
    'lq_dp_action_official_portal': l10nEntry(
      english: 'Official portal',
      arabic: 'البوابة الرسمية',
      hindi: 'Official portal',
      urdu: 'Official portal',
    ),
    'lq_dp_action_view_on_page': l10nEntry(
      english: 'View on this page',
      arabic: 'عرض في هذه الصفحة',
      hindi: 'View on this page',
      urdu: 'View on this page',
    ),
    'lq_dp_item_plan_employer_settlement': l10nEntry(
      english: 'Employer talk: final settlement & experience papers',
      arabic: 'التحدث مع جهة العمل: التسوية النهائية وشهادات الخبرة',
      hindi: 'Employer talk: final settlement & experience papers',
      urdu: 'Employer talk: final settlement & experience papers',
    ),
    'lq_dp_item_plan_eosb_entitlement': l10nEntry(
      english: 'Check end-of-service entitlement (EOSB)',
      arabic: 'تحقق من استحقاق نهاية الخدمة (EOSB)',
      hindi: 'Check end-of-service entitlement (EOSB)',
      urdu: 'Check end-of-service entitlement (EOSB)',
    ),
    'lq_dp_item_plan_bank_arrangements': l10nEntry(
      english: 'Start bank closure / clearance conversations early',
      arabic: 'ابدأ مبكراً محادثات إغلاق/مخالصة الحساب البنكي',
      hindi: 'Start bank closure / clearance conversations early',
      urdu: 'Start bank closure / clearance conversations early',
    ),
    'lq_dp_item_plan_kahramaa_closure': l10nEntry(
      english: 'Kahramaa final reading & account clearance',
      arabic: 'Kahramaa: القراءة النهائية وإغلاق الحساب',
      hindi: 'Kahramaa final reading & account clearance',
      urdu: 'Kahramaa final reading & account clearance',
    ),
    'lq_dp_item_plan_health_coverage_gap': l10nEntry(
      english: 'Plan health-coverage gap after employment ends',
      arabic: 'خطّط لفجوة التأمين الصحي بعد انتهاء العمل',
      hindi: 'Plan health-coverage gap after employment ends',
      urdu: 'Plan health-coverage gap after employment ends',
    ),
    'lq_dp_item_plan_vehicle_and_fines': l10nEntry(
      english: 'Vehicle transfer/sale and traffic fines cleared',
      arabic: 'نقل/بيع المركبة وتسوية مخالفات المرور',
      hindi: 'Vehicle transfer/sale and traffic fines cleared',
      urdu: 'Vehicle transfer/sale and traffic fines cleared',
    ),
    'lq_dp_item_plan_school_records': l10nEntry(
      english: 'School records & attestation',
      arabic: 'سجلات المدرسة والتصديق',
      hindi: 'School records & attestation',
      urdu: 'School records & attestation',
    ),
    'lq_dp_item_plan_pets': l10nEntry(
      english: 'Pet travel or rehoming plan',
      arabic: 'خطة سفر الحيوانات الأليفة أو إيجاد مأوى',
      hindi: 'Pet travel or rehoming plan',
      urdu: 'Pet travel or rehoming plan',
    ),
    'lq_dp_item_plan_exit_permit': l10nEntry(
      english: 'Exit permit rules (if they apply to you)',
      arabic: 'قواعد تصريح المغادرة (إن كانت تنطبق عليك)',
      hindi: 'Exit permit rules (if they apply to you)',
      urdu: 'Exit permit rules (if they apply to you)',
    ),
    'lq_dp_item_plan_traffic_fines_recheck': l10nEntry(
      english: 'Recheck traffic fines before travel',
      arabic: 'أعد التحقق من مخالفات المرور قبل السفر',
      hindi: 'Recheck traffic fines before travel',
      urdu: 'Recheck traffic fines before travel',
    ),
    'lq_dp_item_plan_travel_ban_inquiry': l10nEntry(
      english: 'MOI travel-ban inquiry before departure',
      arabic: 'استعلام MOI عن حظر السفر قبل المغادرة',
      hindi: 'MOI travel-ban inquiry before departure',
      urdu: 'MOI travel-ban inquiry before departure',
    ),
    'lq_dp_item_plan_rp_cancellation': l10nEntry(
      english: 'Residence permit cancellation steps',
      arabic: 'خطوات إلغاء تصريح الإقامة',
      hindi: 'Residence permit cancellation steps',
      urdu: 'Residence permit cancellation steps',
    ),
    'lq_dp_item_plan_departure_rules_confirm': l10nEntry(
      english: 'Confirm post-cancellation departure rules on MOI',
      arabic: 'أكّد قواعد المغادرة بعد الإلغاء على MOI',
      hindi: 'Confirm post-cancellation departure rules on MOI',
      urdu: 'Confirm post-cancellation departure rules on MOI',
    ),
    'lq_dp_item_plan_document_vault_copies': l10nEntry(
      english: 'Keep cancellation & settlement copies in Document Vault',
      arabic: 'احتفظ بنسخ الإلغاء والتسوية في Document Vault',
      hindi: 'Keep cancellation & settlement copies in Document Vault',
      urdu: 'Keep cancellation & settlement copies in Document Vault',
    ),
    'lq_dp_item_plan_welcome_home_prep': l10nEntry(
      english: 'Welcome Home prep for return support',
      arabic: 'تحضير Welcome Home لدعم العودة',
      hindi: 'Welcome Home prep for return support',
      urdu: 'Welcome Home prep for return support',
    ),
    'lq_dp_reminder_toggle_label': l10nEntry(
      english: 'Remind me (local notifications)',
      arabic: 'ذكّرني (إشعارات محلية)',
      hindi: 'Remind me (local notifications)',
      urdu: 'Remind me (local notifications)',
    ),
    'lq_dp_reminder_toggle_sub': l10nEntry(
      english:
          'Up to one gentle nudge per day for suggested plan steps — not legal deadlines.',
      arabic:
          'تذكير واحد لطيف يومياً كحد أقصى لخطوات الخطة المقترحة — وليس مواعيد قانونية.',
      hindi:
          'Up to one gentle nudge per day for suggested plan steps — not legal deadlines.',
      urdu:
          'Up to one gentle nudge per day for suggested plan steps — not legal deadlines.',
    ),
    'lq_dp_reminder_need_date': l10nEntry(
      english: 'Add a planned departure date to enable reminders.',
      arabic: 'أضف تاريخ مغادرة مخططاً لتفعيل التذكيرات.',
      hindi: 'Add a planned departure date to enable reminders.',
      urdu: 'Add a planned departure date to enable reminders.',
    ),
    'lq_dp_reminder_none_eligible': l10nEntry(
      english:
          'No upcoming suggested reminders — completed steps and official-only items are skipped.',
      arabic:
          'لا تذكيرات مقترحة قادمة — الخطوات المكتملة والخطوات الرسمية فقط مستثناة.',
      hindi:
          'No upcoming suggested reminders — completed steps and official-only items are skipped.',
      urdu:
          'No upcoming suggested reminders — completed steps and official-only items are skipped.',
    ),
    'lq_dp_reminder_permission_note': l10nEntry(
      english:
          'Reminders stay on this device. Your OS may ask for notification permission.',
      arabic:
          'التذكيرات تبقى على هذا الجهاز. قد يطلب نظامك إذن الإشعارات.',
      hindi:
          'Reminders stay on this device. Your OS may ask for notification permission.',
      urdu:
          'Reminders stay on this device. Your OS may ask for notification permission.',
    ),
    'lq_dp_reminder_load_error': l10nEntry(
      english: 'Reminder settings unavailable right now.',
      arabic: 'إعدادات التذكير غير متاحة الآن.',
      hindi: 'Reminder settings unavailable right now.',
      urdu: 'Reminder settings unavailable right now.',
    ),
    'lq_dp_reminder_schedule_failed': l10nEntry(
      english: 'Could not update reminders. Your plan data is unchanged.',
      arabic: 'تعذّر تحديث التذكيرات. بيانات خطتك لم تتغير.',
      hindi: 'Could not update reminders. Your plan data is unchanged.',
      urdu: 'Could not update reminders. Your plan data is unchanged.',
    ),
    'lq_dp_reminder_title': l10nEntry(
      english: 'Departure plan',
      arabic: 'خطة المغادرة',
      hindi: 'Departure plan',
      urdu: 'Departure plan',
    ),
    'lq_dp_reminder_body': l10nEntry(
      english:
          '{count} suggested departure plan step(s) to review today in Leaving Qatar.',
      arabic:
          '{count} خطوة/خطوات مقترحة في خطة المغادرة للمراجعة اليوم في مغادرة قطر.',
      hindi:
          '{count} suggested departure plan step(s) to review today in Leaving Qatar.',
      urdu:
          '{count} suggested departure plan step(s) to review today in Leaving Qatar.',
    ),
    'lq_dp_export_pdf': l10nEntry(
      english: 'Export PDF checklist',
      arabic: 'تصدير قائمة PDF',
      hindi: 'Export PDF checklist',
      urdu: 'Export PDF checklist',
    ),
    'lq_dp_export_failed': l10nEntry(
      english: 'Could not export the PDF. Your plan on this device is unchanged.',
      arabic: 'تعذّر تصدير PDF. خطتك على هذا الجهاز لم تتغير.',
      hindi: 'Could not export the PDF. Your plan on this device is unchanged.',
      urdu: 'Could not export the PDF. Your plan on this device is unchanged.',
    ),
    'lq_dp_pdf_title': l10nEntry(
      english: 'RAABTA - Departure Plan',
      arabic: 'RAABTA - خطة المغادرة',
      hindi: 'RAABTA - Departure Plan',
      urdu: 'RAABTA - Departure Plan',
    ),
    'lq_dp_pdf_intro': l10nEntry(
      english:
          'Personal planning aid stored on your device. This is not legal advice or an official record.',
      arabic:
          'مساعدة تخطيط شخصية على جهازك. هذا ليس مشورة قانونية أو سجلاً رسمياً.',
      hindi:
          'Personal planning aid stored on your device. This is not legal advice or an official record.',
      urdu:
          'Personal planning aid stored on your device. This is not legal advice or an official record.',
    ),
    'lq_dp_pdf_date_set': l10nEntry(
      english: 'Planned departure date: {date}',
      arabic: 'تاريخ المغادرة المخطط: {date}',
      hindi: 'Planned departure date: {date}',
      urdu: 'Planned departure date: {date}',
    ),
    'lq_dp_pdf_date_not_set': l10nEntry(
      english: 'Planned departure date: not set',
      arabic: 'تاريخ المغادرة المخطط: غير محدد',
      hindi: 'Planned departure date: not set',
      urdu: 'Planned departure date: not set',
    ),
    'lq_dp_pdf_progress': l10nEntry(
      english: 'Plan progress: {done} of {total} steps marked done',
      arabic: 'تقدم الخطة: {done} من {total} خطوات مكتملة',
      hindi: 'Plan progress: {done} of {total} steps marked done',
      urdu: 'Plan progress: {done} of {total} steps marked done',
    ),
    'lq_dp_pdf_timing_suggested': l10nEntry(
      english: 'Suggested planning step',
      arabic: 'خطوة تخطيط مقترحة',
      hindi: 'Suggested planning step',
      urdu: 'Suggested planning step',
    ),
    'lq_dp_pdf_timing_official': l10nEntry(
      english: 'Official source - confirm current rules on the portal',
      arabic: 'مصدر رسمي - أكّد القواعد الحالية على البوابة',
      hindi: 'Official source - confirm current rules on the portal',
      urdu: 'Official source - confirm current rules on the portal',
    ),
    'lq_dp_pdf_status_done': l10nEntry(
      english: 'Done',
      arabic: 'تم',
      hindi: 'Done',
      urdu: 'Done',
    ),
    'lq_dp_pdf_status_pending': l10nEntry(
      english: 'Pending',
      arabic: 'قيد الانتظار',
      hindi: 'Pending',
      urdu: 'Pending',
    ),
    'lq_dp_pdf_ref_route': l10nEntry(
      english: 'In-app: {route}',
      arabic: 'في التطبيق: {route}',
      hindi: 'In-app: {route}',
      urdu: 'In-app: {route}',
    ),
    'lq_dp_pdf_ref_portal': l10nEntry(
      english: 'Reference: official MOI / Metrash portal (confirm live rules there)',
      arabic: 'مرجع: بوابة MOI / Metrash الرسمية (أكّد القواعد الحية هناك)',
      hindi: 'Reference: official MOI / Metrash portal (confirm live rules there)',
      urdu: 'Reference: official MOI / Metrash portal (confirm live rules there)',
    ),
    'lq_dp_pdf_ref_timeline': l10nEntry(
      english: 'In-app: Leaving Qatar timeline section on /leaving-qatar',
      arabic: 'في التطبيق: قسم الجدول الزمني في مغادرة قطر',
      hindi: 'In-app: Leaving Qatar timeline section on /leaving-qatar',
      urdu: 'In-app: Leaving Qatar timeline section on /leaving-qatar',
    ),
    'lq_dp_pdf_ref_closeout': l10nEntry(
      english: 'In-app: Other close-out steps on /leaving-qatar',
      arabic: 'في التطبيق: خطوات الإغلاق الأخرى في /leaving-qatar',
      hindi: 'In-app: Other close-out steps on /leaving-qatar',
      urdu: 'In-app: Other close-out steps on /leaving-qatar',
    ),
    'lq_dp_pdf_disclaimer': l10nEntry(
      english:
          'Suggested steps are planning guidance only, not legal deadlines. Confirm official requirements with the relevant authorities. Generated by RAABTA for personal use.',
      arabic:
          'الخطوات المقترحة إرشاد تخطيط فقط وليست مواعيد قانونية. أكّد المتطلبات الرسمية لدى الجهات المختصة. أُنشئ بواسطة RAABTA للاستخدام الشخصي.',
      hindi:
          'Suggested steps are planning guidance only, not legal deadlines. Confirm official requirements with the relevant authorities. Generated by RAABTA for personal use.',
      urdu:
          'Suggested steps are planning guidance only, not legal deadlines. Confirm official requirements with the relevant authorities. Generated by RAABTA for personal use.',
    ),
    'lq_dp_pdf_branding': l10nEntry(
      english: 'RAABTA Leaving Qatar',
      arabic: 'RAABTA مغادرة قطر',
      hindi: 'RAABTA Leaving Qatar',
      urdu: 'RAABTA Leaving Qatar',
    ),
  };
}
