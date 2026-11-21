// Community feature strings — 8-language pipeline via l10nEntry.
import 'package:flutter/foundation.dart';
import 'package:raabta/core/l10n/app_locale.dart';
import 'package:raabta/core/l10n/locale_catalog_entry.dart';
import 'package:raabta/core/l10n/locale_catalog_coverage.dart';

abstract final class CommunityStrings {
  static const supportedLocales = AppLocale.supportedLocales;

  static String t(String key, [String locale = 'English']) {
    final normalized = AppLocale.normalize(locale);
    final map = _catalog[key];
    if (map == null) return key;
    return map[normalized] ?? map['English'] ?? key;
  }

  static String format(
    String key,
    String locale, {
    required Map<String, String> params,
  }) {
    var text = t(key, locale);
    params.forEach((k, v) {
      text = text.replaceAll('{$k}', v);
    });
    return text;
  }

  @visibleForTesting
  static Map<String, Set<String>> get localeCoverageReport =>
      buildLocaleCoverageReport(
        catalog: _catalog,
        supportedLocales: supportedLocales,
      );

  static final _catalog = <String, Map<String, String>>{




    'community_nat_label_india': l10nEntry(
      english: 'Indian',
      arabic: 'هندي',
      hindi: 'भारतीय',
      urdu: 'بھارتی',
    ),
    'community_nat_label_pakistan': l10nEntry(
      english: 'Pakistani',
      arabic: 'باكستاني',
      urdu: 'پاکستانی',
    ),
    'community_nat_label_bangladesh': l10nEntry(
      english: 'Bangladeshi',
      arabic: 'بنغلاديشي',
      bengali: 'বাংলাদেশি',
    ),
    'community_nat_label_nepal': l10nEntry(
      english: 'Nepali',
      arabic: 'نيبالي',
      nepali: 'नेपाली',
    ),
    'community_nat_label_philippines': l10nEntry(
      english: 'Filipino',
      arabic: 'فلبيني',
      filipino: 'Filipino',
    ),
    'community_nat_label_kenya': l10nEntry(
      english: 'Kenyan',
      arabic: 'كيني',
    ),
    'community_nat_label_nigeria': l10nEntry(
      english: 'Nigerian',
      arabic: 'نيجيري',
    ),
    'community_nat_suggestion_join_title': l10nEntry(
      english: 'Connect with other {nationality} residents in Qatar',
      arabic: 'تواصل مع مقيمين {nationality} آخرين في قطر',
      hindi: 'क़तर में अन्य {nationality} निवासियों से जुड़ें',
      urdu: 'قطر میں دیگر {nationality} رہائشیوں سے جڑیں',
    ),
    'community_nat_suggestion_join_body': l10nEntry(
      english: 'Join {groupName} to meet people who share your background.',
      arabic: 'انضم إلى {groupName} للقاء أشخاص يشاركونك خلفيتك.',
      hindi: 'अपनी पृष्ठभूमि साझा करने वाले लोगों से मिलने के लिए {groupName} में शामिल हों।',
      urdu: 'اپنی پس منظر والے لوگوں سے ملنے کے لیے {groupName} میں شامل ہوں۔',
    ),
    'community_nat_suggestion_join_action': l10nEntry(
      english: 'Join group →',
      arabic: 'انضم للمجموعة ←',
      hindi: 'ग्रुप में शामिल हों →',
      urdu: 'گروپ میں شامل ہوں →',
    ),
    'community_nat_suggestion_no_group_title': l10nEntry(
      english: 'No {nationality} group yet',
      arabic: 'لا توجد مجموعة {nationality} بعد',
      hindi: 'अभी कोई {nationality} समूह नहीं',
      urdu: 'ابھی {nationality} گروپ نہیں',
    ),
    'community_nat_suggestion_no_group_body': l10nEntry(
      english:
          'Raabta\'s community groups are curated. Ask Qatar is the best place to connect while a dedicated group is being considered.',
      arabic:
          'مجموعات Raabta المجتمعية منسقة. Ask Qatar هو أفضل مكان للتواصل بينما يُنظر في مجموعة مخصصة.',
    ),
    'community_nat_suggestion_ask_action': l10nEntry(
      english: 'Ask in Ask Qatar →',
      arabic: 'اسأل في Ask Qatar ←',
      hindi: 'Ask Qatar में पूछें →',
      urdu: 'Ask Qatar میں پوچھیں →',
    ),
    'community_nat_suggestion_dismiss': l10nEntry(
      english: 'Not now',
      arabic: 'ليس الآن',
      hindi: 'अभी नहीं',
      urdu: 'ابھی نہیں',
    ),
    'community_tag_selector_heading': l10nEntry(
      english: 'Tag to groups (optional)',
      arabic: 'وسم المجموعات (اختياري)',
      hindi: 'Groups tag karein (optional)',
      urdu: 'Groups tag karein (optional)',
    ),
    'community_tag_selector_hint': l10nEntry(
      english: 'Leave untagged to share with general Community only.',
      arabic: 'اتركه بدون وسوم للمشاركة مع المجتمع العام فقط.',
      hindi: 'General Community ke liye untagged chhod dein.',
      urdu: 'General Community ke liye untagged chhor dein.',
    ),
    'community_tag_leaving_qatar': l10nEntry(
      english: 'Leaving Qatar',
      arabic: 'مغادرة قطر',
      hindi: 'Leaving Qatar',
      urdu: 'Leaving Qatar',
    ),
    'community_visibility_tagged_leaving_qatar': l10nEntry(
      english: 'Tagged Leaving Qatar',
      arabic: 'موسوم: مغادرة قطر',
      hindi: 'Tagged Leaving Qatar',
      urdu: 'Tagged Leaving Qatar',
    ),
    'community_leaving_qatar_tag_hint_title': l10nEntry(
      english: 'Selling before you leave?',
      arabic: 'تبيع قبل المغادرة؟',
      hindi: 'Jaane se pehle bech rahe hain?',
      urdu: 'Jaane se pehle bech rahe hain?',
    ),
    'community_leaving_qatar_tag_hint_body': l10nEntry(
      english:
          'When you post a Marketplace ad or Community listing, you can optionally tag it "Leaving Qatar" so buyers looking for departure sales can find it.',
      arabic:
          'عند نشر إعلان Marketplace أو منشور Community، يمكنك اختيارياً وسمه "مغادرة قطر" ليجده المشترون.',
      hindi:
          'Marketplace ad ya Community post karte waqt aap optionally "Leaving Qatar" tag laga sakte hain taaki departure-sale buyers dhoondh saken.',
      urdu:
          'Marketplace ad ya Community post karte waqt aap optionally "Leaving Qatar" tag laga sakte hain taaki departure-sale buyers dhoondh saken.',
    ),
    'community_marketplace_leaving_filter': l10nEntry(
      english: 'Leaving sale',
      arabic: 'بيع المغادرة',
      hindi: 'Leaving sale',
      urdu: 'Leaving sale',
    ),
    'community_mod_investment_warn_title': l10nEntry(
      english: 'Possible investment scam pattern',
      arabic: 'نمط محتمل لاحتيال استثماري',
      hindi: 'Possible investment scam pattern',
      urdu: 'Possible investment scam pattern',
    ),
    'community_mod_investment_warn_body': l10nEntry(
      english:
          'This looks similar to patterns commonly used in investment scams — unlicensed trading offers, guaranteed returns, or recruiting people into external investment groups. Are you sure you want to post this?',
      arabic:
          'يبدو مشابهاً لأنماط شائعة في احتيال الاستثمار — عروض تداول غير مرخّصة أو عوائد مضمونة أو استقطاب لمجموعات خارجية. هل أنت متأكد أنك تريد النشر؟',
      hindi:
          'Ye investment scams ke common patterns jaisa lagta hai — unlicensed trading, guaranteed returns, ya external investment groups. Kya aap post karna chahte hain?',
      urdu:
          'Ye investment scams ke common patterns jaisa lagta hai — unlicensed trading, guaranteed returns, ya external investment groups. Kya aap post karna chahte hain?',
    ),
    'community_mod_investment_scamshield_note': l10nEntry(
      english:
          'Want to check a specific message or offer in more depth? ScamShield can analyze text you have already received — without leaving this screen.',
      arabic:
          'تريد فحص رسالة أو عرض محدد بعمق؟ ScamShield يحلل النص الذي استلمته — دون مغادرة هذه الشاشة.',
      hindi:
          'Kisi specific message/offer ko depth mein check karna hai? ScamShield aapke paas maujood text analyze kar sakta hai.',
      urdu:
          'Kisi specific message/offer ko depth mein check karna hai? ScamShield aapke paas maujood text analyze kar sakta hai.',
    ),
    'community_mod_investment_scamshield_link': l10nEntry(
      english: 'Open ScamShield',
      arabic: 'افتح ScamShield',
      hindi: 'ScamShield kholen',
      urdu: 'ScamShield kholen',
    ),
    'community_mod_investment_cancel': l10nEntry(
      english: 'Edit post',
      arabic: 'عدّل المنشور',
      hindi: 'Post edit karein',
      urdu: 'Post edit karein',
    ),
    'community_mod_investment_proceed': l10nEntry(
      english: 'Post anyway',
      arabic: 'انشر على أي حال',
      hindi: 'Phir bhi post karein',
      urdu: 'Phir bhi post karein',
    ),
    // TODO-TRANSLATE-REVIEW: fundraising moderation interstitial (native review for all locales).
    'community_mod_fundraising_warn_title': l10nEntry(
      english: 'Check before collecting donations',
      arabic: 'تحقق قبل جمع التبرعات',
      hindi: 'Check before collecting donations',
      urdu: 'Check before collecting donations',
    ),
    'community_mod_fundraising_warn_body': l10nEntry(
      english:
          'Collecting money from the community through private accounts or informal group appeals can be risky in Qatar — including legal concerns and scams. Consider using officially recognised charities instead.',
      arabic:
          'جمع الأموال من المجتمع عبر حسابات خاصة أو حملات غير رسمية قد يكون محفوفاً بالمخاطر في قطر — بما في ذلك مخاطر قانونية واحتيال. فكّر في الجمعيات الخيرية المعترف بها رسمياً.',
      hindi:
          'Collecting money from the community through private accounts or informal group appeals can be risky in Qatar — including legal concerns and scams. Consider using officially recognised charities instead.',
      urdu:
          'Collecting money from the community through private accounts or informal group appeals can be risky in Qatar — including legal concerns and scams. Consider using officially recognised charities instead.',
    ),
    'community_mod_fundraising_verify_note': l10nEntry(
      english:
          'Verify organisations and report fraud through official channels in Scam Shield\'s directory — do not send money to unverified accounts.',
      arabic:
          'تحقق من الجهات وأبلغ عن الاحتيال عبر القنوات الرسمية في دليل Scam Shield — لا ترسل أموالاً إلى حسابات غير موثوقة.',
      hindi:
          'Verify organisations and report fraud through official channels in Scam Shield\'s directory — do not send money to unverified accounts.',
      urdu:
          'Verify organisations and report fraud through official channels in Scam Shield\'s directory — do not send money to unverified accounts.',
    ),
    'community_mod_fundraising_official_directory_link': l10nEntry(
      english: 'Browse official directory',
      arabic: 'تصفح الدليل الرسمي',
      hindi: 'Browse official directory',
      urdu: 'Browse official directory',
    ),
    'community_hub_title': l10nEntry(
      english: 'Community',
      arabic: 'المجتمع',
      hindi: 'Community',
      urdu: 'Community',
    ),
    'community_hub_subtitle': l10nEntry(
      english: 'Ask, share and help in Qatar',
      arabic: 'اسأل وشارك وساعد في قطر',
      hindi: 'Qatar mein poochein, share karein aur madad karein',
      urdu: 'Qatar mein poochein, share karein aur madad karein',
    ),
    // TODO-TRANSLATE-REVIEW — neighbourhood problem, not Raabta app support
    'community_civic_report_chip': l10nEntry(
      english: 'Report neighbourhood problem',
      arabic: 'بلاغ مشكلة في الحي',
      hindi: 'Report neighbourhood problem',
      urdu: 'محلے کا مسئلہ رپورٹ کریں',
    ),
    'community_tab_feed': l10nEntry(
      english: 'Feed',
      arabic: 'آخر المشاركات',
      hindi: 'Feed',
      urdu: 'Feed',
    ),
    'community_tab_groups': l10nEntry(
      english: 'Groups',
      arabic: 'المجموعات',
      hindi: 'Groups',
      urdu: 'Groups',
    ),
    'community_tab_ask_qatar': l10nEntry(
      english: 'Ask Qatar',
      arabic: 'Ask Qatar',
      hindi: 'Ask Qatar',
      urdu: 'Ask Qatar',
    ),
    'community_tab_news': l10nEntry(
      english: 'News',
      arabic: 'الأخبار',
      hindi: 'News',
      urdu: 'News',
    ),
    'community_tab_events': l10nEntry(
      english: 'Events',
      arabic: 'الفعاليات',
      hindi: 'Events',
      urdu: 'Events',
    ),
    'community_tab_lost_found': l10nEntry(
      english: 'Lost & Found',
      arabic: 'مفقودات',
      hindi: 'Lost & Found',
      urdu: 'Lost & Found',
    ),
    'community_search_hub_hint': l10nEntry(
      english: 'Search community…',
      arabic: 'ابحث في المجتمع…',
      hindi: 'Community search karein…',
      urdu: 'Community search karein…',
    ),
    'community_search_groups_hint': l10nEntry(
      english: 'Search groups…',
      arabic: 'ابحث في المجموعات…',
      hindi: 'Groups search karein…',
      urdu: 'Groups search karein…',
    ),
    'community_hub_groups_filter_semantics': l10nEntry(
      english: 'Focus search on groups',
      arabic: 'التركيز على مجموعات البحث',
      hindi: 'Groups par search focus',
      urdu: 'Groups par search focus',
    ),
    'community_post_fab_tooltip': l10nEntry(
      english: 'Post',
      arabic: 'نشر',
      hindi: 'Post',
      urdu: 'Post',
    ),
    'community_feed_empty_title': l10nEntry(
      english: 'No posts in your area yet',
      arabic: 'لا منشورات في منطقتك بعد',
      hindi: 'Abhi aapke area mein koi post nahi',
      urdu: 'Abhi aapke area mein koi post nahi',
    ),
    'community_feed_empty_cta': l10nEntry(
      english: 'Start a conversation',
      arabic: 'ابدأ محادثة',
      hindi: 'Conversation shuru karein',
      urdu: 'Conversation shuru karein',
    ),
    'community_trust_tier_community': l10nEntry(
      english: 'Community',
      arabic: 'المجتمع',
      hindi: 'Community',
      urdu: 'Community',
    ),
    'community_trust_tier_official': l10nEntry(
      english: 'Official',
      arabic: 'رسمي',
      hindi: 'Official',
      urdu: 'Official',
    ),
    'community_post_meta_reactions': l10nEntry(
      english: '{comments} replies · {likes} reactions',
      arabic: '{comments} ردود · {likes} تفاعلات',
      hindi: '{comments} replies · {likes} reactions',
      urdu: '{comments} replies · {likes} reactions',
    ),
    'community_why_seeing_link': l10nEntry(
      english: 'Why am I seeing this?',
      arabic: 'لماذا أرى هذا؟',
      hindi: 'Why am I seeing this?',
      urdu: 'Why am I seeing this?',
    ),
    'community_pulse_trending': l10nEntry(
      english: 'trending',
      arabic: 'رائج',
      hindi: 'trending',
      urdu: 'trending',
    ),
    'community_pulse_events_today': l10nEntry(
      english: 'events today',
      arabic: 'فعاليات اليوم',
      hindi: 'events today',
      urdu: 'events today',
    ),
    'community_pulse_open_questions': l10nEntry(
      english: 'open questions',
      arabic: 'أسئلة مفتوحة',
      hindi: 'open questions',
      urdu: 'open questions',
    ),
    'community_section_joined_overline': l10nEntry(
      english: 'Joined',
      arabic: 'منضم',
      hindi: 'Joined',
      urdu: 'Joined',
    ),
    'community_section_your_groups': l10nEntry(
      english: 'Your Groups',
      arabic: 'مجموعاتك',
      hindi: 'Aapke Groups',
      urdu: 'Aapke Groups',
    ),
    'community_section_discover_overline': l10nEntry(
      english: 'Discover',
      arabic: 'اكتشف',
      hindi: 'Discover',
      urdu: 'Discover',
    ),
    'community_section_all_communities': l10nEntry(
      english: 'All Communities',
      arabic: 'كل المجتمعات',
      hindi: 'Saari Communities',
      urdu: 'Saari Communities',
    ),
    'community_groups_count': l10nEntry(
      english: '{count} groups',
      arabic: '{count} مجموعات',
      hindi: '{count} groups',
      urdu: '{count} groups',
    ),
    'community_empty_no_groups': l10nEntry(
      english: 'No groups found',
      arabic: 'لم تُعثر على مجموعات',
      hindi: 'Koi group nahi mila',
      urdu: 'Koi group nahi mila',
    ),
    'community_empty_no_groups_hint': l10nEntry(
      english: 'Try a different search term.',
      arabic: 'جرّب كلمة بحث مختلفة.',
      hindi: 'Alag search term try karein.',
      urdu: 'Alag search term try karein.',
    ),
    'community_err_load_groups': l10nEntry(
      english: 'Could not load groups',
      arabic: 'تعذر تحميل المجموعات',
      hindi: 'Groups load nahi ho sake',
      urdu: 'Groups load nahi ho sake',
    ),
    'community_err_load_groups_hint': l10nEntry(
      english: 'Pull down to refresh.',
      arabic: 'اسحب للأسفل للتحديث.',
      hindi: 'Refresh ke liye neeche kheenchein.',
      urdu: 'Refresh ke liye neeche kheenchein.',
    ),
    'community_section_career_overline': l10nEntry(
      english: 'Career',
      arabic: 'مهنة',
      hindi: 'Career',
      urdu: 'Career',
    ),
    'community_section_professional': l10nEntry(
      english: 'Professional Communities',
      arabic: 'مجتمعات مهنية',
      hindi: 'Professional Communities',
      urdu: 'Professional Communities',
    ),
    'community_section_trending_overline': l10nEntry(
      english: 'Trending',
      arabic: 'رائج',
      hindi: 'Trending',
      urdu: 'Trending',
    ),
    'community_section_hot_discussions': l10nEntry(
      english: 'Hot Discussions',
      arabic: 'نقاشات ساخنة',
      hindi: 'Hot Discussions',
      urdu: 'Hot Discussions',
    ),
    'community_trending_unavailable': l10nEntry(
      english: 'Trending unavailable',
      arabic: 'الرائج غير متاح',
      hindi: 'Trending unavailable',
      urdu: 'Trending unavailable',
    ),
    'community_trending_unavailable_hint': l10nEntry(
      english: 'Pull down to refresh.',
      arabic: 'اسحب للأسفل للتحديث.',
      hindi: 'Refresh ke liye neeche kheenchein.',
      urdu: 'Refresh ke liye neeche kheenchein.',
    ),
    'community_trending_empty': l10nEntry(
      english: 'No trending posts yet',
      arabic: 'لا منشورات رائجة بعد',
      hindi: 'Abhi koi trending post nahi',
      urdu: 'Abhi koi trending post nahi',
    ),
    'community_trending_empty_hint': l10nEntry(
      english: 'Join a group and start the conversation.',
      arabic: 'انضم لمجموعة وابدأ المحادثة.',
      hindi: 'Group join karke conversation shuru karein.',
      urdu: 'Group join karke conversation shuru karein.',
    ),
    'community_stats_tagline': l10nEntry(
      english: 'Qatar\'s largest expat community',
      arabic: 'أكبر مجتمع مغتربين في قطر',
      hindi: 'Qatar ka sabse bada expat community',
      urdu: 'Qatar ka sabse bada expat community',
    ),
    'community_stat_members': l10nEntry(
      english: 'Members',
      arabic: 'أعضاء',
      hindi: 'Members',
      urdu: 'Members',
    ),
    'community_stat_feed_live': l10nEntry(
      english: 'Live',
      arabic: 'مباشر',
      hindi: 'Live',
      urdu: 'Live',
    ),
    'community_stat_feed': l10nEntry(
      english: 'Feed',
      arabic: 'الخلاصة',
      hindi: 'Feed',
      urdu: 'Feed',
    ),
    'community_stat_groups': l10nEntry(
      english: 'Groups',
      arabic: 'المجموعات',
      hindi: 'Groups',
      urdu: 'Groups',
    ),
    'community_new_posts': l10nEntry(
      english: '{count} new',
      arabic: '{count} جديد',
      hindi: '{count} new',
      urdu: '{count} new',
    ),
    'community_members_count': l10nEntry(
      english: '{count} members',
      arabic: '{count} أعضاء',
      hindi: '{count} members',
      urdu: '{count} members',
    ),
    'community_join': l10nEntry(
      english: 'Join',
      arabic: 'انضم',
      hindi: 'Join',
      urdu: 'Join',
    ),
    'community_joined': l10nEntry(
      english: 'Joined',
      arabic: 'منضم',
      hindi: 'Joined',
      urdu: 'Joined',
    ),
    'community_hot_badge': l10nEntry(
      english: 'HOT',
      arabic: 'ساخن',
      hindi: 'HOT',
      urdu: 'HOT',
    ),
    'community_fallback_group': l10nEntry(
      english: 'Community',
      arabic: 'المجتمع',
      hindi: 'Community',
      urdu: 'Community',
    ),
    'community_ask_qatar_title': l10nEntry(
      english: 'Ask Qatar 🤔',
      arabic: 'Ask Qatar 🤔',
      hindi: 'Ask Qatar 🤔',
      urdu: 'Ask Qatar 🤔',
    ),
    'community_ask_qatar_subtitle': l10nEntry(
      english: 'Get answers from the community',
      arabic: 'احصل على إجابات من المجتمع',
      hindi: 'Community se jawab paayein',
      urdu: 'Community se jawab paayein',
    ),
    'community_ask_search_hint': l10nEntry(
      english: 'Search questions...',
      arabic: 'ابحث في الأسئلة...',
      hindi: 'Questions search karein...',
      urdu: 'Questions search karein...',
    ),
    'community_ask_cta': l10nEntry(
      english: 'Ask a Question',
      arabic: 'اطرح سؤالاً',
      hindi: 'Sawal poochhein',
      urdu: 'Sawal poochhein',
    ),
    'community_ask_sheet_title': l10nEntry(
      english: 'Ask a Question',
      arabic: 'اطرح سؤالاً',
      hindi: 'Sawal poochhein',
      urdu: 'Sawal poochhein',
    ),
    'community_ask_title_hint': l10nEntry(
      english: 'What do you want to know?',
      arabic: 'ماذا تريد أن تعرف؟',
      hindi: 'Aap kya jaanna chahte hain?',
      urdu: 'Aap kya jaanna chahte hain?',
    ),
    'community_ask_body_hint': l10nEntry(
      english: 'Add details (optional)',
      arabic: 'أضف تفاصيل (اختياري)',
      hindi: 'Details add karein (optional)',
      urdu: 'Details add karein (optional)',
    ),
    'community_ask_submit': l10nEntry(
      english: 'Submit Question',
      arabic: 'إرسال السؤال',
      hindi: 'Sawal submit karein',
      urdu: 'Sawal submit karein',
    ),
    'community_ask_err_min_length': l10nEntry(
      english: 'Please enter a question of at least 8 characters.',
      arabic: 'يرجى إدخال سؤال من 8 أحرف على الأقل.',
      hindi: 'Kam se kam 8 characters ka sawal likhein.',
      urdu: 'Kam se kam 8 characters ka sawal likhein.',
    ),
    'community_ask_success': l10nEntry(
      english: 'Question posted! The community will help soon.',
      arabic: 'تم نشر السؤال! سيساعدك المجتمع قريباً.',
      hindi: 'Sawal post ho gaya! Community jald madad karegi.',
      urdu: 'Sawal post ho gaya! Community jald madad karegi.',
    ),
    'community_ask_err_post': l10nEntry(
      english: 'Could not post your question. Please try again.',
      arabic: 'تعذر نشر سؤالك. حاول مجدداً.',
      hindi: 'Sawal post nahi ho saka. Dubara try karein.',
      urdu: 'Sawal post nahi ho saka. Dubara try karein.',
    ),
    'community_sort_recent': l10nEntry(
      english: 'Recent',
      arabic: 'الأحدث',
      hindi: 'Recent',
      urdu: 'Recent',
    ),
    'community_sort_popular': l10nEntry(
      english: 'Popular',
      arabic: 'شائع',
      hindi: 'Popular',
      urdu: 'Popular',
    ),
    'community_sort_unanswered': l10nEntry(
      english: 'Unanswered',
      arabic: 'بدون إجابة',
      hindi: 'Unanswered',
      urdu: 'Unanswered',
    ),
    'community_filter_all': l10nEntry(
      english: 'All',
      arabic: 'الكل',
      hindi: 'All',
      urdu: 'All',
    ),
    'community_cat_general': l10nEntry(
      english: 'General',
      arabic: 'عام',
      hindi: 'General',
      urdu: 'General',
    ),
    'community_cat_visa': l10nEntry(
      english: 'Visa',
      arabic: 'تأشيرة',
      hindi: 'Visa',
      urdu: 'Visa',
    ),
    'community_cat_jobs': l10nEntry(
      english: 'Jobs',
      arabic: 'وظائف',
      hindi: 'Jobs',
      urdu: 'Jobs',
    ),
    'community_cat_transport': l10nEntry(
      english: 'Transport',
      arabic: 'مواصلات',
      hindi: 'Transport',
      urdu: 'Transport',
    ),
    'community_cat_education': l10nEntry(
      english: 'Education',
      arabic: 'تعليم',
      hindi: 'Education',
      urdu: 'Education',
    ),
    'community_cat_housing': l10nEntry(
      english: 'Housing',
      arabic: 'سكن',
      hindi: 'Housing',
      urdu: 'Housing',
    ),
    'community_ask_err_load': l10nEntry(
      english: 'Could not load questions',
      arabic: 'تعذر تحميل الأسئلة',
      hindi: 'Questions load nahi ho sake',
      urdu: 'Questions load nahi ho sake',
    ),
    'community_ask_err_load_hint': l10nEntry(
      english: 'Pull down to refresh and try again.',
      arabic: 'اسحب للأسفل للتحديث وحاول مجدداً.',
      hindi: 'Refresh karke dubara try karein.',
      urdu: 'Refresh karke dubara try karein.',
    ),
    'community_ask_empty': l10nEntry(
      english: 'No questions yet',
      arabic: 'لا أسئلة بعد',
      hindi: 'Abhi koi sawal nahi',
      urdu: 'Abhi koi sawal nahi',
    ),
    'community_ask_empty_filter': l10nEntry(
      english: 'Try a different search or category.',
      arabic: 'جرّب بحثاً أو فئة مختلفة.',
      hindi: 'Alag search ya category try karein.',
      urdu: 'Alag search ya category try karein.',
    ),
    'community_ask_empty_first': l10nEntry(
      english: 'Be the first to ask the community!',
      arabic: 'كن أول من يسأل المجتمع!',
      hindi: 'Community se pehle sawal poochhne wale banen!',
      urdu: 'Community se pehle sawal poochhne wale banen!',
    ),
    'community_ask_unanswered': l10nEntry(
      english: 'Unanswered',
      arabic: 'بدون إجابة',
      hindi: 'Unanswered',
      urdu: 'Unanswered',
    ),
    'community_ask_votes': l10nEntry(
      english: 'votes',
      arabic: 'أصوات',
      hindi: 'votes',
      urdu: 'votes',
    ),
    'community_ask_answer': l10nEntry(
      english: 'answer',
      arabic: 'إجابة',
      hindi: 'answer',
      urdu: 'answer',
    ),
    'community_ask_answers': l10nEntry(
      english: 'answers',
      arabic: 'إجابات',
      hindi: 'answers',
      urdu: 'answers',
    ),
    'community_ask_views': l10nEntry(
      english: 'views',
      arabic: 'مشاهدات',
      hindi: 'views',
      urdu: 'views',
    ),
    'community_content_blocked': l10nEntry(
      english: 'This content can\'t be posted. Please edit and try again.',
      arabic: 'لا يمكن نشر هذا المحتوى. عدّله وحاول مجدداً.',
      hindi: 'Ye content post nahi ho sakta. Edit karke dubara try karein.',
      urdu: 'Ye content post nahi ho sakta. Edit karke dubara try karein.',
    ),
    // TODO-TRANSLATE-REVIEW — Part A moderation block copy (English placeholders).
    'community_mod_block_empty': l10nEntry(
      english: 'Please write something before posting.',
      arabic: 'Please write something before posting.',
      hindi: 'Please write something before posting.',
      urdu: 'Please write something before posting.',
    ),
    'community_mod_block_too_long': l10nEntry(
      english: 'Your message is too long. Shorten it and try again.',
      arabic: 'Your message is too long. Shorten it and try again.',
      hindi: 'Your message is too long. Shorten it and try again.',
      urdu: 'Your message is too long. Shorten it and try again.',
    ),
    'community_mod_block_spam_pattern': l10nEntry(
      english: 'This looks like spam. Please write normally.',
      arabic: 'This looks like spam. Please write normally.',
      hindi: 'This looks like spam. Please write normally.',
      urdu: 'This looks like spam. Please write normally.',
    ),
    'community_mod_block_rate_limit': l10nEntry(
      english:
          'Too many posts are being reviewed right now. Please wait a few minutes.',
      arabic:
          'Too many posts are being reviewed right now. Please wait a few minutes.',
      hindi:
          'Too many posts are being reviewed right now. Please wait a few minutes.',
      urdu:
          'Too many posts are being reviewed right now. Please wait a few minutes.',
    ),
    'community_mod_block_msg_profanity': l10nEntry(
      english:
          'This looks like language we don\'t allow in the community. You can edit your message and try again.',
      arabic:
          'This looks like language we don\'t allow in the community. You can edit your message and try again.',
      hindi:
          'This looks like language we don\'t allow in the community. You can edit your message and try again.',
      urdu:
          'This looks like language we don\'t allow in the community. You can edit your message and try again.',
    ),
    'community_mod_block_msg_abusive': l10nEntry(
      english:
          'This looks like abusive or harassing language. You can edit your message and try again.',
      arabic:
          'This looks like abusive or harassing language. You can edit your message and try again.',
      hindi:
          'This looks like abusive or harassing language. You can edit your message and try again.',
      urdu:
          'This looks like abusive or harassing language. You can edit your message and try again.',
    ),
    'community_mod_block_msg_religion': l10nEntry(
      english:
          'This looks like content that insults a religion. Raabta is for respectful discussion.',
      arabic:
          'This looks like content that insults a religion. Raabta is for respectful discussion.',
      hindi:
          'This looks like content that insults a religion. Raabta is for respectful discussion.',
      urdu:
          'This looks like content that insults a religion. Raabta is for respectful discussion.',
    ),
    'community_mod_block_msg_nationality': l10nEntry(
      english:
          'This looks like content targeting a nationality or ethnicity. That isn\'t allowed here.',
      arabic:
          'This looks like content targeting a nationality or ethnicity. That isn\'t allowed here.',
      hindi:
          'This looks like content targeting a nationality or ethnicity. That isn\'t allowed here.',
      urdu:
          'This looks like content targeting a nationality or ethnicity. That isn\'t allowed here.',
    ),
    'community_mod_block_msg_state': l10nEntry(
      english:
          'This looks like content about Qatar\'s state or national symbols that we can\'t host.',
      arabic:
          'This looks like content about Qatar\'s state or national symbols that we can\'t host.',
      hindi:
          'This looks like content about Qatar\'s state or national symbols that we can\'t host.',
      urdu:
          'This looks like content about Qatar\'s state or national symbols that we can\'t host.',
    ),
    'community_mod_block_msg_sexual': l10nEntry(
      english:
          'This looks like explicit sexual content. Please edit your message.',
      arabic: 'This looks like explicit sexual content. Please edit your message.',
      hindi: 'This looks like explicit sexual content. Please edit your message.',
      urdu: 'This looks like explicit sexual content. Please edit your message.',
    ),
    'community_mod_block_msg_investment': l10nEntry(
      english:
          'This looks like investment or trading promotion. Edit your message or review the warning if shown.',
      arabic:
          'This looks like investment or trading promotion. Edit your message or review the warning if shown.',
      hindi:
          'This looks like investment or trading promotion. Edit your message or review the warning if shown.',
      urdu:
          'This looks like investment or trading promotion. Edit your message or review the warning if shown.',
    ),
    'community_mod_block_msg_fundraising': l10nEntry(
      english:
          'This looks like fundraising or solicitation. Edit your message or review the warning if shown.',
      arabic:
          'This looks like fundraising or solicitation. Edit your message or review the warning if shown.',
      hindi:
          'This looks like fundraising or solicitation. Edit your message or review the warning if shown.',
      urdu:
          'This looks like fundraising or solicitation. Edit your message or review the warning if shown.',
    ),
    'community_mod_block_guidelines_hint': l10nEntry(
      english:
          'Raabta is for helpful, respectful posts about life in Qatar. Be factual, avoid attacks, and keep discussions safe for everyone.',
      arabic:
          'Raabta is for helpful, respectful posts about life in Qatar. Be factual, avoid attacks, and keep discussions safe for everyone.',
      hindi:
          'Raabta is for helpful, respectful posts about life in Qatar. Be factual, avoid attacks, and keep discussions safe for everyone.',
      urdu:
          'Raabta is for helpful, respectful posts about life in Qatar. Be factual, avoid attacks, and keep discussions safe for everyone.',
    ),
    // TODO-TRANSLATE-REVIEW — Part B respectful rewrite (English placeholders).
    'community_mod_rephrase_hint': l10nEntry(
      english:
          'Optional: get a suggested rewrite in a more respectful tone. You can edit it before posting — nothing is sent automatically.',
      arabic:
          'Optional: get a suggested rewrite in a more respectful tone. You can edit it before posting — nothing is sent automatically.',
      hindi:
          'Optional: get a suggested rewrite in a more respectful tone. You can edit it before posting — nothing is sent automatically.',
      urdu:
          'Optional: get a suggested rewrite in a more respectful tone. You can edit it before posting — nothing is sent automatically.',
    ),
    'community_mod_rephrase_action': l10nEntry(
      english: 'Suggest a respectful rewrite',
      arabic: 'Suggest a respectful rewrite',
      hindi: 'Suggest a respectful rewrite',
      urdu: 'Suggest a respectful rewrite',
    ),
    'community_mod_rephrase_loading': l10nEntry(
      english: 'Preparing suggestion…',
      arabic: 'Preparing suggestion…',
      hindi: 'Preparing suggestion…',
      urdu: 'Preparing suggestion…',
    ),
    'community_mod_rephrase_failed': l10nEntry(
      english:
          'We couldn\'t prepare a suggestion right now. You can edit your message yourself.',
      arabic:
          'We couldn\'t prepare a suggestion right now. You can edit your message yourself.',
      hindi:
          'We couldn\'t prepare a suggestion right now. You can edit your message yourself.',
      urdu:
          'We couldn\'t prepare a suggestion right now. You can edit your message yourself.',
    ),
    'community_mod_rephrase_retry': l10nEntry(
      english: 'Try again',
      arabic: 'Try again',
      hindi: 'Try again',
      urdu: 'Try again',
    ),
    'community_mod_rephrase_daily_limit': l10nEntry(
      english:
          'Daily limit for rewrite suggestions reached. Try again tomorrow or edit your message.',
      arabic:
          'Daily limit for rewrite suggestions reached. Try again tomorrow or edit your message.',
      hindi:
          'Daily limit for rewrite suggestions reached. Try again tomorrow or edit your message.',
      urdu:
          'Daily limit for rewrite suggestions reached. Try again tomorrow or edit your message.',
    ),
    'community_mod_rephrase_auth_required': l10nEntry(
      english: 'Sign in to use rewrite suggestions.',
      arabic: 'Sign in to use rewrite suggestions.',
      hindi: 'Sign in to use rewrite suggestions.',
      urdu: 'Sign in to use rewrite suggestions.',
    ),
    'community_mod_rephrase_cannot': l10nEntry(
      english:
          'This message can\'t be rewritten safely. Please edit it yourself.',
      arabic:
          'This message can\'t be rewritten safely. Please edit it yourself.',
      hindi:
          'This message can\'t be rewritten safely. Please edit it yourself.',
      urdu:
          'This message can\'t be rewritten safely. Please edit it yourself.',
    ),
    'community_mod_rephrase_attempts_exhausted': l10nEntry(
      english:
          'You\'ve used the rewrite suggestions for this draft. Edit your message and try posting again.',
      arabic:
          'You\'ve used the rewrite suggestions for this draft. Edit your message and try posting again.',
      hindi:
          'You\'ve used the rewrite suggestions for this draft. Edit your message and try posting again.',
      urdu:
          'You\'ve used the rewrite suggestions for this draft. Edit your message and try posting again.',
    ),
    'community_mod_rephrase_review_hint': l10nEntry(
      english:
          'Review and edit the suggestion below, then tap Use this text. Your post still goes through moderation.',
      arabic:
          'Review and edit the suggestion below, then tap Use this text. Your post still goes through moderation.',
      hindi:
          'Review and edit the suggestion below, then tap Use this text. Your post still goes through moderation.',
      urdu:
          'Review and edit the suggestion below, then tap Use this text. Your post still goes through moderation.',
    ),
    'community_mod_rephrase_use_suggestion': l10nEntry(
      english: 'Use this text',
      arabic: 'Use this text',
      hindi: 'Use this text',
      urdu: 'Use this text',
    ),
    'community_mod_rephrase_edit_myself': l10nEntry(
      english: 'Edit myself',
      arabic: 'Edit myself',
      hindi: 'Edit myself',
      urdu: 'Edit myself',
    ),
    'community_question_err_load': l10nEntry(
      english: 'Could not load question',
      arabic: 'تعذر تحميل السؤال',
      hindi: 'Sawal load nahi ho saka',
      urdu: 'Sawal load nahi ho saka',
    ),
    'community_question_err_load_hint': l10nEntry(
      english: 'Pull down to try again.',
      arabic: 'اسحب للأسفل للمحاولة مجدداً.',
      hindi: 'Dubara try karne ke liye neeche kheenchein.',
      urdu: 'Dubara try karne ke liye neeche kheenchein.',
    ),
    'community_question_not_found': l10nEntry(
      english: 'Question not found',
      arabic: 'السؤال غير موجود',
      hindi: 'Sawal nahi mila',
      urdu: 'Sawal nahi mila',
    ),
    'community_question_removed': l10nEntry(
      english: 'It may have been removed.',
      arabic: 'ربما تمت إزالته.',
      hindi: 'Shayad hata diya gaya ho.',
      urdu: 'Shayad hata diya gaya ho.',
    ),
    'community_answers_count': l10nEntry(
      english: '{count} Answers',
      arabic: '{count} إجابات',
      hindi: '{count} Answers',
      urdu: '{count} Answers',
    ),
    'community_answers_err_load': l10nEntry(
      english: 'Could not load answers',
      arabic: 'تعذر تحميل الإجابات',
      hindi: 'Jawab load nahi ho sake',
      urdu: 'Jawab load nahi ho sake',
    ),
    'community_answers_err_load_hint': l10nEntry(
      english: 'Pull down to refresh.',
      arabic: 'اسحب للأسفل للتحديث.',
      hindi: 'Refresh ke liye neeche kheenchein.',
      urdu: 'Refresh ke liye neeche kheenchein.',
    ),
    'community_answers_empty': l10nEntry(
      english: 'No answers yet',
      arabic: 'لا إجابات بعد',
      hindi: 'Abhi koi jawab nahi',
      urdu: 'Abhi koi jawab nahi',
    ),
    'community_answers_empty_hint': l10nEntry(
      english: 'Be the first to help — share what you know.',
      arabic: 'كن أول من يساعد — شارك ما تعرفه.',
      hindi: 'Pehle madad karein — jo jaante hain share karein.',
      urdu: 'Pehle madad karein — jo jaante hain share karein.',
    ),
    'community_answer_accepted': l10nEntry(
      english: 'Accepted Answer',
      arabic: 'إجابة مقبولة',
      hindi: 'Accepted Answer',
      urdu: 'Accepted Answer',
    ),
    'community_answer_helpful': l10nEntry(
      english: 'Helpful · {count}',
      arabic: 'مفيد · {count}',
      hindi: 'Helpful · {count}',
      urdu: 'Helpful · {count}',
    ),
    'community_answer_mark_accepted': l10nEntry(
      english: 'Mark accepted',
      arabic: 'اعتمد الإجابة',
      hindi: 'Accepted mark karein',
      urdu: 'Accepted mark karein',
    ),
    'community_answer_accept_err': l10nEntry(
      english: 'Could not mark this answer as accepted. Please try again.',
      arabic: 'تعذر اعتماد هذه الإجابة. حاول مرة أخرى.',
      hindi: 'Could not mark this answer as accepted. Please try again.',
      urdu: 'Could not mark this answer as accepted. Please try again.',
    ),
    // TODO-TRANSLATE-REVIEW: Ask Qatar similar-question + solved UI strings.
    'community_ask_similar_title': l10nEntry(
      english: 'Similar questions already asked',
      arabic: 'أسئلة مشابهة سُئلت من قبل',
      hindi: 'Similar questions already asked',
      urdu: 'Similar questions already asked',
    ),
    'community_ask_similar_subtitle': l10nEntry(
      english:
          'These may already cover what you need. You can open one or ask anyway below.',
      arabic:
          'قد تغطي هذه ما تحتاجه. افتح أحدها أو اطرح سؤالك في الأسفل.',
      hindi:
          'These may already cover what you need. You can open one or ask anyway below.',
      urdu:
          'These may already cover what you need. You can open one or ask anyway below.',
    ),
    'community_ask_similar_dismiss': l10nEntry(
      english: 'Dismiss',
      arabic: 'إخفاء',
      hindi: 'Dismiss',
      urdu: 'Dismiss',
    ),
    'community_ask_similar_row_meta': l10nEntry(
      english: '{count} answers · {solved}',
      arabic: '{count} إجابات · {solved}',
      hindi: '{count} answers · {solved}',
      urdu: '{count} answers · {solved}',
    ),
    'community_ask_solved_chip': l10nEntry(
      english: 'Solved',
      arabic: 'تم الحل',
      hindi: 'Solved',
      urdu: 'Solved',
    ),
    'community_answer_hint': l10nEntry(
      english: 'Write your answer…',
      arabic: 'اكتب إجابتك…',
      hindi: 'Apna jawab likhein…',
      urdu: 'Apna jawab likhein…',
    ),
    'community_answer_err_post': l10nEntry(
      english: 'Could not post your answer. Please try again.',
      arabic: 'تعذر نشر إجابتك. حاول مجدداً.',
      hindi: 'Jawab post nahi ho saka. Dubara try karein.',
      urdu: 'Jawab post nahi ho saka. Dubara try karein.',
    ),
    'community_events_title': l10nEntry(
      english: '🎉 Events & Meetups',
      arabic: '🎉 Events & Meetups',
      hindi: '🎉 Events & Meetups',
      urdu: '🎉 Events & Meetups',
    ),
    'community_events_subtitle': l10nEntry(
      english: 'Connect with your community',
      arabic: 'تواصل مع مجتمعك',
      hindi: 'Apni community se judein',
      urdu: 'Apni community se judein',
    ),
    'community_events_post': l10nEntry(
      english: 'Post Event',
      arabic: 'نشر فعالية',
      hindi: 'Event post karein',
      urdu: 'Event post karein',
    ),
    'community_events_sheet_title': l10nEntry(
      english: 'Post Event',
      arabic: 'نشر فعالية',
      hindi: 'Event post karein',
      urdu: 'Event post karein',
    ),
    'community_events_label_title': l10nEntry(
      english: 'Event title',
      arabic: 'عنوان الفعالية',
      hindi: 'Event title',
      urdu: 'Event title',
    ),
    'community_events_label_description': l10nEntry(
      english: 'Description',
      arabic: 'الوصف',
      hindi: 'Description',
      urdu: 'Description',
    ),
    'community_events_label_location': l10nEntry(
      english: 'Location',
      arabic: 'الموقع',
      hindi: 'Location',
      urdu: 'Location',
    ),
    'community_events_date_time': l10nEntry(
      english: 'Date & time',
      arabic: 'التاريخ والوقت',
      hindi: 'Date & time',
      urdu: 'Date & time',
    ),
    'community_events_err_title_location': l10nEntry(
      english: 'Please add a title and location.',
      arabic: 'يرجى إضافة عنوان وموقع.',
      hindi: 'Title aur location add karein.',
      urdu: 'Title aur location add karein.',
    ),
    'community_events_submit_review': l10nEntry(
      english: 'Submit for Review',
      arabic: 'إرسال للمراجعة',
      hindi: 'Review ke liye submit karein',
      urdu: 'Review ke liye submit karein',
    ),
    'community_events_err_post': l10nEntry(
      english: 'Could not post event. Please try again.',
      arabic: 'تعذر نشر الفعالية. حاول مجدداً.',
      hindi: 'Event post nahi ho saka. Dubara try karein.',
      urdu: 'Event post nahi ho saka. Dubara try karein.',
    ),
    'community_events_approved': l10nEntry(
      english: 'Event approved and published!',
      arabic: 'تمت الموافقة على الفعالية ونشرها!',
      hindi: 'Event approve aur publish ho gayi!',
      urdu: 'Event approve aur publish ho gayi!',
    ),
    'community_events_rejected': l10nEntry(
      english: 'Event rejected: {reason}',
      arabic: 'تم رفض الفعالية: {reason}',
      hindi: 'Event reject: {reason}',
      urdu: 'Event reject: {reason}',
    ),
    'community_events_err_link': l10nEntry(
      english: 'Could not open event link.',
      arabic: 'تعذر فتح رابط الفعالية.',
      hindi: 'Event link nahi khul saka.',
      urdu: 'Event link nahi khul saka.',
    ),
    'community_filter_upcoming': l10nEntry(
      english: 'Upcoming',
      arabic: 'قادمة',
      hindi: 'Upcoming',
      urdu: 'Upcoming',
    ),
    'community_filter_this_week': l10nEntry(
      english: 'This Week',
      arabic: 'هذا الأسبوع',
      hindi: 'This Week',
      urdu: 'This Week',
    ),
    'community_filter_free': l10nEntry(
      english: 'Free',
      arabic: 'مجاني',
      hindi: 'Free',
      urdu: 'Free',
    ),
    'community_filter_sports': l10nEntry(
      english: 'Sports',
      arabic: 'رياضة',
      hindi: 'Sports',
      urdu: 'Sports',
    ),
    'community_filter_cultural': l10nEntry(
      english: 'Cultural',
      arabic: 'ثقافي',
      hindi: 'Cultural',
      urdu: 'Cultural',
    ),
    'community_events_live_unavailable': l10nEntry(
      english: 'Live events unavailable — pull to refresh.',
      arabic: 'الفعاليات المباشرة غير متاحة — اسحب للتحديث.',
      hindi: 'Live events unavailable — refresh karein.',
      urdu: 'Live events unavailable — refresh karein.',
    ),
    'community_events_happening': l10nEntry(
      english: 'Happening in Qatar',
      arabic: 'يحدث في قطر',
      hindi: 'Qatar mein ho raha hai',
      urdu: 'Qatar mein ho raha hai',
    ),
    'community_events_your_submissions': l10nEntry(
      english: 'Your submissions',
      arabic: 'طلباتك',
      hindi: 'Aapke submissions',
      urdu: 'Aapke submissions',
    ),
    'community_events_under_review': l10nEntry(
      english: 'Under review',
      arabic: 'قيد المراجعة',
      hindi: 'Review mein',
      urdu: 'Review mein',
    ),
    'community_events_rejected_status': l10nEntry(
      english: 'Rejected',
      arabic: 'مرفوض',
      hindi: 'Rejected',
      urdu: 'Rejected',
    ),
    'community_events_date_tbc': l10nEntry(
      english: 'Date TBC',
      arabic: 'التاريخ لاحقاً',
      hindi: 'Date TBC',
      urdu: 'Date TBC',
    ),
    'community_events_going': l10nEntry(
      english: 'Going',
      arabic: 'سأحضر',
      hindi: 'Going',
      urdu: 'Going',
    ),
    'community_events_going_check': l10nEntry(
      english: 'Going ✓',
      arabic: 'سأحضر ✓',
      hindi: 'Going ✓',
      urdu: 'Going ✓',
    ),
    'community_events_interested': l10nEntry(
      english: 'Interested',
      arabic: 'مهتم',
      hindi: 'Interested',
      urdu: 'Interested',
    ),
    'community_events_community_meetups': l10nEntry(
      english: 'Community Meetups',
      arabic: 'لقاءات المجتمع',
      hindi: 'Community Meetups',
      urdu: 'Community Meetups',
    ),
    'community_events_no_match': l10nEntry(
      english: 'No events match this filter',
      arabic: 'لا فعاليات تطابق هذا الفلتر',
      hindi: 'Is filter se koi event match nahi',
      urdu: 'Is filter se koi event match nahi',
    ),
    'community_events_no_match_hint': l10nEntry(
      english: 'Try a different category or post a community event.',
      arabic: 'جرّب فئة مختلفة أو انشر فعالية مجتمعية.',
      hindi: 'Alag category try karein ya community event post karein.',
      urdu: 'Alag category try karein ya community event post karein.',
    ),
    'community_events_empty': l10nEntry(
      english: 'No community events yet',
      arabic: 'لا فعاليات مجتمعية بعد',
      hindi: 'Abhi koi community event nahi',
      urdu: 'Abhi koi community event nahi',
    ),
    'community_events_empty_hint': l10nEntry(
      english: 'Post an event above, or browse Happening in Qatar.',
      arabic: 'انشر فعالية أعلاه، أو تصفح يحدث في قطر.',
      hindi: 'Upar event post karein, ya Happening in Qatar dekhein.',
      urdu: 'Upar event post karein, ya Happening in Qatar dekhein.',
    ),
    'community_events_schedule_online': l10nEntry(
      english: 'Schedule online',
      arabic: 'جدول عبر الإنترنت',
      hindi: 'Schedule online',
      urdu: 'Schedule online',
    ),
    'community_events_view_details': l10nEntry(
      english: 'View details →',
      arabic: 'عرض التفاصيل ←',
      hindi: 'View details →',
      urdu: 'View details →',
    ),
    'community_lf_title': l10nEntry(
      english: '🔍 Lost & Found',
      arabic: '🔍 Lost & Found',
      hindi: '🔍 Lost & Found',
      urdu: '🔍 Lost & Found',
    ),
    'community_lf_subtitle': l10nEntry(
      english: 'Help each other in Qatar',
      arabic: 'ساعد بعضكم في قطر',
      hindi: 'Qatar mein ek doosre ki madad karein',
      urdu: 'Qatar mein ek doosre ki madad karein',
    ),
    'community_lf_lost_items': l10nEntry(
      english: 'Lost Items',
      arabic: 'مفقودات',
      hindi: 'Lost Items',
      urdu: 'Lost Items',
    ),
    'community_lf_found_items': l10nEntry(
      english: 'Found Items',
      arabic: 'موجودات',
      hindi: 'Found Items',
      urdu: 'Found Items',
    ),
    'community_lf_report_lost': l10nEntry(
      english: 'Report Lost Item',
      arabic: 'بلّغ عن مفقود',
      hindi: 'Lost item report karein',
      urdu: 'Lost item report karein',
    ),
    'community_lf_report_found': l10nEntry(
      english: 'Report Found Item',
      arabic: 'بلّغ عن موجود',
      hindi: 'Found item report karein',
      urdu: 'Found item report karein',
    ),
    'community_lf_label_title': l10nEntry(
      english: 'Short title',
      arabic: 'عنوان قصير',
      hindi: 'Short title',
      urdu: 'Short title',
    ),
    'community_lf_label_description': l10nEntry(
      english: 'Description',
      arabic: 'الوصف',
      hindi: 'Description',
      urdu: 'Description',
    ),
    'community_lf_label_last_seen': l10nEntry(
      english: 'Last seen location',
      arabic: 'آخر موقع',
      hindi: 'Last seen location',
      urdu: 'Last seen location',
    ),
    'community_lf_label_found_at': l10nEntry(
      english: 'Found at',
      arabic: 'وُجد في',
      hindi: 'Found at',
      urdu: 'Found at',
    ),
    'community_lf_label_contact': l10nEntry(
      english: 'WhatsApp / phone contact',
      arabic: 'واتساب / هاتف',
      hindi: 'WhatsApp / phone contact',
      urdu: 'WhatsApp / phone contact',
    ),
    'community_lf_date_lost': l10nEntry(
      english: 'Date lost',
      arabic: 'تاريخ الفقد',
      hindi: 'Date lost',
      urdu: 'Date lost',
    ),
    'community_lf_date_found': l10nEntry(
      english: 'Date found',
      arabic: 'تاريخ العثور',
      hindi: 'Date found',
      urdu: 'Date found',
    ),
    'community_lf_err_title_location': l10nEntry(
      english: 'Please add a title and location.',
      arabic: 'يرجى إضافة عنوان وموقع.',
      hindi: 'Title aur location add karein.',
      urdu: 'Title aur location add karein.',
    ),
    'community_lf_post_listing': l10nEntry(
      english: 'Post Listing',
      arabic: 'نشر الإعلان',
      hindi: 'Listing post karein',
      urdu: 'Listing post karein',
    ),
    'community_lf_err_post': l10nEntry(
      english: 'Could not post listing. Please try again.',
      arabic: 'تعذر نشر الإعلان. حاول مجدداً.',
      hindi: 'Listing post nahi ho saki. Dubara try karein.',
      urdu: 'Listing post nahi ho saki. Dubara try karein.',
    ),
    'community_lf_err_contact': l10nEntry(
      english: 'Could not open contact method.',
      arabic: 'تعذر فتح طريقة التواصل.',
      hindi: 'Contact method nahi khul saka.',
      urdu: 'Contact method nahi khul saka.',
    ),
    'community_lf_badge_lost': l10nEntry(
      english: 'LOST',
      arabic: 'مفقود',
      hindi: 'LOST',
      urdu: 'LOST',
    ),
    'community_lf_badge_found': l10nEntry(
      english: 'FOUND',
      arabic: 'موجود',
      hindi: 'FOUND',
      urdu: 'FOUND',
    ),
    'community_lf_badge_resolved': l10nEntry(
      english: 'RESOLVED',
      arabic: 'تم الحل',
      hindi: 'RESOLVED',
      urdu: 'RESOLVED',
    ),
    'community_lf_contact_whatsapp': l10nEntry(
      english: 'Contact via WhatsApp',
      arabic: 'تواصل عبر واتساب',
      hindi: 'WhatsApp se contact karein',
      urdu: 'WhatsApp se contact karein',
    ),
    'community_lf_contact_claim': l10nEntry(
      english: 'Contact to Claim',
      arabic: 'تواصل للمطالبة',
      hindi: 'Claim ke liye contact karein',
      urdu: 'Claim ke liye contact karein',
    ),
    'community_lf_mark_resolved': l10nEntry(
      english: 'Mark as Resolved',
      arabic: 'اعتبره محلولاً',
      hindi: 'Resolved mark karein',
      urdu: 'Resolved mark karein',
    ),
    'community_lf_err_resolve': l10nEntry(
      english: 'Could not mark as resolved.',
      arabic: 'تعذر وضع علامة محلول.',
      hindi: 'Resolved mark nahi ho saka.',
      urdu: 'Resolved mark nahi ho saka.',
    ),
    'community_lf_err_load': l10nEntry(
      english: 'Could not load listings',
      arabic: 'تعذر تحميل الإعلانات',
      hindi: 'Listings load nahi ho sakin',
      urdu: 'Listings load nahi ho sakin',
    ),
    'community_lf_err_load_hint': l10nEntry(
      english: 'Pull down to refresh.',
      arabic: 'اسحب للأسفل للتحديث.',
      hindi: 'Refresh ke liye neeche kheenchein.',
      urdu: 'Refresh ke liye neeche kheenchein.',
    ),
    'community_lf_empty_lost': l10nEntry(
      english: 'No lost items reported',
      arabic: 'لا مفقودات مبلّغ عنها',
      hindi: 'Koi lost item report nahi',
      urdu: 'Koi lost item report nahi',
    ),
    'community_lf_empty_found': l10nEntry(
      english: 'No found items reported',
      arabic: 'لا موجودات مبلّغ عنها',
      hindi: 'Koi found item report nahi',
      urdu: 'Koi found item report nahi',
    ),
    'community_lf_empty_hint': l10nEntry(
      english: 'Be the first to post and help the community.',
      arabic: 'كن أول من ينشر ويساعد المجتمع.',
      hindi: 'Pehle post karke community ki madad karein.',
      urdu: 'Pehle post karke community ki madad karein.',
    ),
    'community_lf_resolved_count': l10nEntry(
      english: 'Resolved ({count})',
      arabic: 'محلول ({count})',
      hindi: 'Resolved ({count})',
      urdu: 'Resolved ({count})',
    ),
    'community_lf_tap_contact': l10nEntry(
      english: 'Tap for details & contact',
      arabic: 'اضغط للتفاصيل والتواصل',
      hindi: 'Details aur contact ke liye tap karein',
      urdu: 'Details aur contact ke liye tap karein',
    ),
    // TODO-TRANSLATE-REVIEW — Part A Lost & Found area + photo (English placeholders).
    'community_lf_label_area': l10nEntry(
      english: 'Area (optional)',
      arabic: 'Area (optional)',
      hindi: 'Area (optional)',
      urdu: 'Area (optional)',
    ),
    'community_lf_area_optional': l10nEntry(
      english: 'Select area (optional)',
      arabic: 'Select area (optional)',
      hindi: 'Select area (optional)',
      urdu: 'Select area (optional)',
    ),
    'community_lf_photo_optional': l10nEntry(
      english: 'Photo (optional)',
      arabic: 'Photo (optional)',
      hindi: 'Photo (optional)',
      urdu: 'Photo (optional)',
    ),
    'community_lf_photo_add': l10nEntry(
      english: 'Add a photo',
      arabic: 'Add a photo',
      hindi: 'Add a photo',
      urdu: 'Add a photo',
    ),
    'community_lf_photo_remove': l10nEntry(
      english: 'Remove photo',
      arabic: 'Remove photo',
      hindi: 'Remove photo',
      urdu: 'Remove photo',
    ),
    'community_lf_photo_uploading': l10nEntry(
      english: 'Uploading photo…',
      arabic: 'Uploading photo…',
      hindi: 'Uploading photo…',
      urdu: 'Uploading photo…',
    ),
    'community_lf_err_photo_upload': l10nEntry(
      english: 'Could not upload the photo. Your text is saved — try again.',
      arabic: 'Could not upload the photo. Your text is saved — try again.',
      hindi: 'Could not upload the photo. Your text is saved — try again.',
      urdu: 'Could not upload the photo. Your text is saved — try again.',
    ),
    'community_lf_err_photo_too_large': l10nEntry(
      english: 'Photo is too large after compression. Choose a smaller image.',
      arabic: 'Photo is too large after compression. Choose a smaller image.',
      hindi: 'Photo is too large after compression. Choose a smaller image.',
      urdu: 'Photo is too large after compression. Choose a smaller image.',
    ),
    // TODO-TRANSLATE-REVIEW — Stage 1 Lost & Found attributes & privacy.
    'community_lf_label_category': l10nEntry(
      english: 'Item category',
      arabic: 'Item category',
      hindi: 'Item category',
      urdu: 'Item category',
    ),
    'community_lf_category_optional': l10nEntry(
      english: 'Select category (optional)',
      arabic: 'Select category (optional)',
      hindi: 'Select category (optional)',
      urdu: 'Select category (optional)',
    ),
    'community_lf_documents_notice': l10nEntry(
      english:
          'For documents and cards: do not publish ID numbers, bank or card numbers, or full names. Describe only the document type and general place. Photos are disabled for this category.',
      arabic:
          'For documents and cards: do not publish ID numbers, bank or card numbers, or full names. Describe only the document type and general place. Photos are disabled for this category.',
      hindi:
          'For documents and cards: do not publish ID numbers, bank or card numbers, or full names. Describe only the document type and general place. Photos are disabled for this category.',
      urdu:
          'For documents and cards: do not publish ID numbers, bank or card numbers, or full names. Describe only the document type and general place. Photos are disabled for this category.',
    ),
    'community_lf_label_colors': l10nEntry(
      english: 'Colors (up to 3)',
      arabic: 'Colors (up to 3)',
      hindi: 'Colors (up to 3)',
      urdu: 'Colors (up to 3)',
    ),
    'community_lf_label_item_type': l10nEntry(
      english: 'Item type (optional)',
      arabic: 'Item type (optional)',
      hindi: 'Item type (optional)',
      urdu: 'Item type (optional)',
    ),
    'community_lf_label_brand': l10nEntry(
      english: 'Brand (optional)',
      arabic: 'Brand (optional)',
      hindi: 'Brand (optional)',
      urdu: 'Brand (optional)',
    ),
    'community_lf_label_marks': l10nEntry(
      english: 'Distinguishing marks (optional)',
      arabic: 'Distinguishing marks (optional)',
      hindi: 'Distinguishing marks (optional)',
      urdu: 'Distinguishing marks (optional)',
    ),
    'community_lf_err_category_before_photo': l10nEntry(
      english: 'Choose an item category before adding a photo.',
      arabic: 'Choose an item category before adding a photo.',
      hindi: 'Choose an item category before adding a photo.',
      urdu: 'Choose an item category before adding a photo.',
    ),
    'community_lf_err_sensitive_numbers': l10nEntry(
      english:
          'Please remove long number sequences (such as ID or card numbers) from your listing. Describe the item without sharing personal numbers.',
      arabic:
          'Please remove long number sequences (such as ID or card numbers) from your listing. Describe the item without sharing personal numbers.',
      hindi:
          'Please remove long number sequences (such as ID or card numbers) from your listing. Describe the item without sharing personal numbers.',
      urdu:
          'Please remove long number sequences (such as ID or card numbers) from your listing. Describe the item without sharing personal numbers.',
    ),
    'community_lf_label_hidden_detail': l10nEntry(
      english: 'Private verification detail (optional)',
      arabic: 'Private verification detail (optional)',
      hindi: 'Private verification detail (optional)',
      urdu: 'Private verification detail (optional)',
    ),
    'community_lf_hidden_detail_hint': l10nEntry(
      english:
          'Only you can see this. Use a non-sensitive detail to verify a claimant — not payments, rewards, or ID numbers.',
      arabic:
          'Only you can see this. Use a non-sensitive detail to verify a claimant — not payments, rewards, or ID numbers.',
      hindi:
          'Only you can see this. Use a non-sensitive detail to verify a claimant — not payments, rewards, or ID numbers.',
      urdu:
          'Only you can see this. Use a non-sensitive detail to verify a claimant — not payments, rewards, or ID numbers.',
    ),
    'community_lf_claimant_tip': l10nEntry(
      english:
          'The finder may ask for a distinguishing detail to confirm the item is yours.',
      arabic:
          'The finder may ask for a distinguishing detail to confirm the item is yours.',
      hindi:
          'The finder may ask for a distinguishing detail to confirm the item is yours.',
      urdu:
          'The finder may ask for a distinguishing detail to confirm the item is yours.',
    ),
    'community_lf_err_hidden_detail': l10nEntry(
      english:
          'Private verification detail cannot include payments, rewards, or number sequences. Use a simple physical detail instead.',
      arabic:
          'Private verification detail cannot include payments, rewards, or number sequences. Use a simple physical detail instead.',
      hindi:
          'Private verification detail cannot include payments, rewards, or number sequences. Use a simple physical detail instead.',
      urdu:
          'Private verification detail cannot include payments, rewards, or number sequences. Use a simple physical detail instead.',
    ),
    // TODO-TRANSLATE-REVIEW — Stage 2 Lost & Found matcher UI (English placeholders).
    'community_lf_matches_heading': l10nEntry(
      english: 'Possible matches',
      arabic: 'Possible matches',
      hindi: 'Possible matches',
      urdu: 'Possible matches',
    ),
    'community_lf_matches_hint': l10nEntry(
      english:
          'These are suggestions only. Contact the other listing to confirm — matching cannot verify identity.',
      arabic:
          'These are suggestions only. Contact the other listing to confirm — matching cannot verify identity.',
      hindi:
          'These are suggestions only. Contact the other listing to confirm — matching cannot verify identity.',
      urdu:
          'These are suggestions only. Contact the other listing to confirm — matching cannot verify identity.',
    ),
    'community_lf_match_not_mine': l10nEntry(
      english: 'Not mine',
      arabic: 'Not mine',
      hindi: 'Not mine',
      urdu: 'Not mine',
    ),
    'community_lf_match_dismiss_err': l10nEntry(
      english: 'Could not save dismissal. Try again.',
      arabic: 'Could not save dismissal. Try again.',
      hindi: 'Could not save dismissal. Try again.',
      urdu: 'Could not save dismissal. Try again.',
    ),
    'community_lf_cat_bag': l10nEntry(
      english: 'Bag',
      arabic: 'Bag',
      hindi: 'Bag',
      urdu: 'Bag',
    ),
    'community_lf_cat_wallet': l10nEntry(
      english: 'Wallet',
      arabic: 'Wallet',
      hindi: 'Wallet',
      urdu: 'Wallet',
    ),
    'community_lf_cat_phone_electronics': l10nEntry(
      english: 'Phone / electronics',
      arabic: 'Phone / electronics',
      hindi: 'Phone / electronics',
      urdu: 'Phone / electronics',
    ),
    'community_lf_cat_keys': l10nEntry(
      english: 'Keys',
      arabic: 'Keys',
      hindi: 'Keys',
      urdu: 'Keys',
    ),
    'community_lf_cat_jewellery': l10nEntry(
      english: 'Jewellery',
      arabic: 'Jewellery',
      hindi: 'Jewellery',
      urdu: 'Jewellery',
    ),
    'community_lf_cat_clothing': l10nEntry(
      english: 'Clothing',
      arabic: 'Clothing',
      hindi: 'Clothing',
      urdu: 'Clothing',
    ),
    'community_lf_cat_pet': l10nEntry(
      english: 'Pet',
      arabic: 'Pet',
      hindi: 'Pet',
      urdu: 'Pet',
    ),
    'community_lf_cat_vehicle_item': l10nEntry(
      english: 'Vehicle item',
      arabic: 'Vehicle item',
      hindi: 'Vehicle item',
      urdu: 'Vehicle item',
    ),
    'community_lf_cat_documents_cards': l10nEntry(
      english: 'Documents / cards',
      arabic: 'Documents / cards',
      hindi: 'Documents / cards',
      urdu: 'Documents / cards',
    ),
    'community_lf_cat_other': l10nEntry(
      english: 'Other',
      arabic: 'Other',
      hindi: 'Other',
      urdu: 'Other',
    ),
    'community_lf_color_black': l10nEntry(
      english: 'Black',
      arabic: 'Black',
      hindi: 'Black',
      urdu: 'Black',
    ),
    'community_lf_color_white': l10nEntry(
      english: 'White',
      arabic: 'White',
      hindi: 'White',
      urdu: 'White',
    ),
    'community_lf_color_brown': l10nEntry(
      english: 'Brown',
      arabic: 'Brown',
      hindi: 'Brown',
      urdu: 'Brown',
    ),
    'community_lf_color_blue': l10nEntry(
      english: 'Blue',
      arabic: 'Blue',
      hindi: 'Blue',
      urdu: 'Blue',
    ),
    'community_lf_color_red': l10nEntry(
      english: 'Red',
      arabic: 'Red',
      hindi: 'Red',
      urdu: 'Red',
    ),
    'community_lf_color_green': l10nEntry(
      english: 'Green',
      arabic: 'Green',
      hindi: 'Green',
      urdu: 'Green',
    ),
    'community_lf_color_yellow': l10nEntry(
      english: 'Yellow',
      arabic: 'Yellow',
      hindi: 'Yellow',
      urdu: 'Yellow',
    ),
    'community_lf_color_gray': l10nEntry(
      english: 'Gray',
      arabic: 'Gray',
      hindi: 'Gray',
      urdu: 'Gray',
    ),
    'community_lf_color_silver': l10nEntry(
      english: 'Silver',
      arabic: 'Silver',
      hindi: 'Silver',
      urdu: 'Silver',
    ),
    'community_lf_color_gold': l10nEntry(
      english: 'Gold',
      arabic: 'Gold',
      hindi: 'Gold',
      urdu: 'Gold',
    ),
    'community_lf_color_multicolor': l10nEntry(
      english: 'Multicolor',
      arabic: 'Multicolor',
      hindi: 'Multicolor',
      urdu: 'Multicolor',
    ),
    'community_news_title': l10nEntry(
      english: '📰 Qatar Today',
      arabic: '📰 Qatar Today',
      hindi: '📰 Qatar Today',
      urdu: '📰 Qatar Today',
    ),
    'community_news_subtitle': l10nEntry(
      english: 'News that matters to expats',
      arabic: 'أخبار تهم المغتربين',
      hindi: 'Expats ke liye zaroori khabrein',
      urdu: 'Expats ke liye zaroori khabrein',
    ),
    'community_news_err_link': l10nEntry(
      english: 'Could not open article link.',
      arabic: 'تعذر فتح رابط المقال.',
      hindi: 'Article link nahi khul saka.',
      urdu: 'Article link nahi khul saka.',
    ),
    'community_news_filter_traffic': l10nEntry(
      english: 'Traffic',
      arabic: 'مرور',
      hindi: 'Traffic',
      urdu: 'Traffic',
    ),
    'community_news_filter_government': l10nEntry(
      english: 'Government',
      arabic: 'حكومة',
      hindi: 'Government',
      urdu: 'Government',
    ),
    'community_news_unavailable': l10nEntry(
      english: 'News unavailable',
      arabic: 'الأخبار غير متاحة',
      hindi: 'News unavailable',
      urdu: 'News unavailable',
    ),
    'community_news_refresh': l10nEntry(
      english: 'Pull down to refresh.',
      arabic: 'اسحب للأسفل للتحديث.',
      hindi: 'Refresh ke liye neeche kheenchein.',
      urdu: 'Refresh ke liye neeche kheenchein.',
    ),
    'community_news_empty': l10nEntry(
      english: 'No news in this category',
      arabic: 'لا أخبار في هذه الفئة',
      hindi: 'Is category mein koi khabar nahi',
      urdu: 'Is category mein koi khabar nahi',
    ),
    'community_news_empty_hint': l10nEntry(
      english: 'Try selecting a different filter to see more stories.',
      arabic: 'جرّب فلتراً مختلفاً لرؤية المزيد.',
      hindi: 'Zyada stories ke liye alag filter choose karein.',
      urdu: 'Zyada stories ke liye alag filter choose karein.',
    ),
    'community_news_read_more': l10nEntry(
      english: 'Read more →',
      arabic: 'اقرأ المزيد ←',
      hindi: 'Read more →',
      urdu: 'Read more →',
    ),
    'community_group_members': l10nEntry(
      english: 'members',
      arabic: 'أعضاء',
      hindi: 'members',
      urdu: 'members',
    ),
    'community_group_joined_badge': l10nEntry(
      english: '✓ Joined',
      arabic: '✓ منضم',
      hindi: '✓ Joined',
      urdu: '✓ Joined',
    ),
    'community_group_err_feed': l10nEntry(
      english: 'Could not load feed',
      arabic: 'تعذر تحميل الخلاصة',
      hindi: 'Feed load nahi ho saki',
      urdu: 'Feed load nahi ho saki',
    ),
    'community_group_err_feed_hint': l10nEntry(
      english: 'Pull down to try again.',
      arabic: 'اسحب للأسفل للمحاولة مجدداً.',
      hindi: 'Dubara try karne ke liye neeche kheenchein.',
      urdu: 'Dubara try karne ke liye neeche kheenchein.',
    ),
    'community_group_empty': l10nEntry(
      english: 'No posts yet',
      arabic: 'لا منشورات بعد',
      hindi: 'Abhi koi post nahi',
      urdu: 'Abhi koi post nahi',
    ),
    'community_group_empty_joined': l10nEntry(
      english: 'Be the first to start a discussion in {groupName}.',
      arabic: 'كن أول من يبدأ نقاشاً في {groupName}.',
      hindi: '{groupName} mein pehli discussion shuru karein.',
      urdu: '{groupName} mein pehli discussion shuru karein.',
    ),
    'community_group_empty_not_joined': l10nEntry(
      english: 'Join this group to post and join the conversation.',
      arabic: 'انضم لهذه المجموعة للنشر والمحادثة.',
      hindi: 'Post aur conversation ke liye is group mein join karein.',
      urdu: 'Post aur conversation ke liye is group mein join karein.',
    ),
    'community_group_err_post': l10nEntry(
      english: 'Could not post right now. Please try again.',
      arabic: 'تعذر النشر الآن. حاول مجدداً.',
      hindi: 'Abhi post nahi ho saka. Dubara try karein.',
      urdu: 'Abhi post nahi ho saka. Dubara try karein.',
    ),
    'community_post_cancelled': l10nEntry(
      english: 'Post cancelled.',
      arabic: 'تم إلغاء النشر.',
      hindi: 'Post cancel ho gayi.',
      urdu: 'Post cancel ho gayi.',
    ),
    'community_comment_err_post': l10nEntry(
      english: 'Could not post comment. Please try again.',
      arabic: 'تعذر نشر التعليق. حاول مجدداً.',
      hindi: 'Comment post nahi ho saka. Dubara try karein.',
      urdu: 'Comment post nahi ho saka. Dubara try karein.',
    ),
    'community_post_pinned': l10nEntry(
      english: 'Pinned',
      arabic: 'مثبّت',
      hindi: 'Pinned',
      urdu: 'Pinned',
    ),
    'community_post_show_less': l10nEntry(
      english: 'Show less',
      arabic: 'عرض أقل',
      hindi: 'Kam dikhayein',
      urdu: 'Kam dikhayein',
    ),
    'community_post_read_more': l10nEntry(
      english: 'Read more',
      arabic: 'اقرأ المزيد',
      hindi: 'Aur padhein',
      urdu: 'Aur padhein',
    ),
    'community_post_share': l10nEntry(
      english: 'Share',
      arabic: 'مشاركة',
      hindi: 'Share',
      urdu: 'Share',
    ),
    'community_comments_err_load': l10nEntry(
      english: 'Could not load comments.',
      arabic: 'تعذر تحميل التعليقات.',
      hindi: 'Comments load nahi ho sake.',
      urdu: 'Comments load nahi ho sake.',
    ),
    'community_comments_empty': l10nEntry(
      english: 'No comments yet — start the conversation.',
      arabic: 'لا تعليقات بعد — ابدأ المحادثة.',
      hindi: 'Abhi koi comment nahi — conversation shuru karein.',
      urdu: 'Abhi koi comment nahi — conversation shuru karein.',
    ),
    'community_comment_hint': l10nEntry(
      english: 'Write a comment…',
      arabic: 'اكتب تعليقاً…',
      hindi: 'Comment likhein…',
      urdu: 'Comment likhein…',
    ),
    'community_time_just_now': l10nEntry(
      english: 'Just now',
      arabic: 'الآن',
      hindi: 'Abhi',
      urdu: 'Abhi',
    ),
    'community_time_minutes': l10nEntry(
      english: '{count}m ago',
      arabic: 'منذ {count} د',
      hindi: '{count}m pehle',
      urdu: '{count}m pehle',
    ),
    'community_time_hours': l10nEntry(
      english: '{count}h ago',
      arabic: 'منذ {count} س',
      hindi: '{count}h pehle',
      urdu: '{count}h pehle',
    ),
    'community_time_days': l10nEntry(
      english: '{count}d ago',
      arabic: 'منذ {count} ي',
      hindi: '{count}d pehle',
      urdu: '{count}d pehle',
    ),
    'community_err_join_first': l10nEntry(
      english: 'Join a community group first to post here.',
      arabic: 'انضم لمجموعة مجتمعية أولاً للنشر هنا.',
      hindi: 'Yahan post karne ke liye pehle community group join karein.',
      urdu: 'Yahan post karne ke liye pehle community group join karein.',
    ),
    'community_picker_title': l10nEntry(
      english: 'Select group',
      arabic: 'اختر مجموعة',
      hindi: 'Group select karein',
      urdu: 'Group select karein',
    ),
    'community_live': l10nEntry(
      english: 'Live',
      arabic: 'مباشر',
      hindi: 'Live',
      urdu: 'Live',
    ),
    'community_crosspost_title': l10nEntry(
      english: 'Share more widely?',
      arabic: 'مشاركة على نطاق أ wider?',
      hindi: 'Zyada logon tak share karein?',
      urdu: 'Zyada logon tak share karein?',
    ),
    'community_crosspost_body': l10nEntry(
      english:
          'You tagged this to {taggedName}. It may also be relevant to {destinationLabel} — share there too?',
      arabic:
          'وسمت هذا لـ {taggedName}. قد يكون ذا صلة أيضاً بـ {destinationLabel} — شاركه هناك أيضاً؟',
      hindi:
          'Aapne ise {taggedName} par tag kiya. Ye {destinationLabel} ke liye bhi relevant ho sakta hai — wahan bhi share karein?',
      urdu:
          'Aapne ise {taggedName} par tag kiya. Ye {destinationLabel} ke liye bhi relevant ho sakta hai — wahan bhi share karein?',
    ),
    'community_crosspost_no': l10nEntry(
      english: 'No thanks',
      arabic: 'لا شكراً',
      hindi: 'Nahi shukriya',
      urdu: 'Nahi shukriya',
    ),
    'community_crosspost_yes': l10nEntry(
      english: 'Yes, share',
      arabic: 'نعم، شارك',
      hindi: 'Haan, share karein',
      urdu: 'Haan, share karein',
    ),
    'community_crosspost_fallback_group': l10nEntry(
      english: 'your group',
      arabic: 'مجموعتك',
      hindi: 'aapka group',
      urdu: 'aapka group',
    ),
    'community_crosspost_another_group': l10nEntry(
      english: 'another group you joined',
      arabic: 'مجموعة أخرى انضممت إليها',
      hindi: 'aapka doosra joined group',
      urdu: 'aapka doosra joined group',
    ),
    'community_crosspost_qatar_community': l10nEntry(
      english: 'Qatar Community',
      arabic: 'مجتمع قطر',
      hindi: 'Qatar Community',
      urdu: 'Qatar Community',
    ),
    'community_composer_join_prompt': l10nEntry(
      english: 'Join this group to post and comment.',
      arabic: 'انضم لهذه المجموعة للنشر والتعليق.',
      hindi: 'Post aur comment ke liye is group mein join karein.',
      urdu: 'Post aur comment ke liye is group mein join karein.',
    ),
    'community_composer_hint_joined': l10nEntry(
      english: 'Write a post…',
      arabic: 'اكتب منشوراً…',
      hindi: 'Post likhein…',
      urdu: 'Post likhein…',
    ),
    'community_composer_hint_not_joined': l10nEntry(
      english: 'Join to write a post…',
      arabic: 'انضم لكتابة منشور…',
      hindi: 'Post likhne ke liye join karein…',
      urdu: 'Post likhne ke liye join karein…',
    ),
    'community_cat_rumour': l10nEntry(
      english: 'Rumour Check',
      arabic: 'Rumour Check',
      hindi: 'Rumour Check',
      urdu: 'Rumour Check',
    ),
    'community_rumour_cta': l10nEntry(
      english: 'Check a rumour',
      arabic: 'Check a rumour',
      hindi: 'Check a rumour',
      urdu: 'Check a rumour',
    ),
    'community_rumour_sheet_title': l10nEntry(
      english: 'Check a rumour',
      arabic: 'Check a rumour',
      hindi: 'Check a rumour',
      urdu: 'Check a rumour',
    ),
    'community_rumour_claim_hint': l10nEntry(
      english: 'Paste or describe the forwarded claim',
      arabic: 'Paste or describe the forwarded claim',
      hindi: 'Paste or describe the forwarded claim',
      urdu: 'Paste or describe the forwarded claim',
    ),
    'community_rumour_body_hint': l10nEntry(
      english: 'More context from the message (optional)',
      arabic: 'More context from the message (optional)',
      hindi: 'More context from the message (optional)',
      urdu: 'More context from the message (optional)',
    ),
    'community_rumour_category_label': l10nEntry(
      english: 'Topic',
      arabic: 'Topic',
      hindi: 'Topic',
      urdu: 'Topic',
    ),
    'community_rumour_presubmit_notice': l10nEntry(
      english:
          'Share only what you received. Do not name private people or companies, and do not post financial or personal details from the forward.',
      arabic:
          'Share only what you received. Do not name private people or companies, and do not post financial or personal details from the forward.',
      hindi:
          'Share only what you received. Do not name private people or companies, and do not post financial or personal details from the forward.',
      urdu:
          'Share only what you received. Do not name private people or companies, and do not post financial or personal details from the forward.',
    ),
    'community_rumour_disclaimer_ack': l10nEntry(
      english:
          'I understand this is community context, not legal advice, and Raabta does not verify whether the claim is true.',
      arabic:
          'I understand this is community context, not legal advice, and Raabta does not verify whether the claim is true.',
      hindi:
          'I understand this is community context, not legal advice, and Raabta does not verify whether the claim is true.',
      urdu:
          'I understand this is community context, not legal advice, and Raabta does not verify whether the claim is true.',
    ),
    'community_rumour_disclaimer': l10nEntry(
      english: 'Community context, not legal advice. Official sources linked in notes do not prove this forward is true.',
      arabic: 'Community context, not legal advice. Official sources linked in notes do not prove this forward is true.',
      hindi: 'Community context, not legal advice. Official sources linked in notes do not prove this forward is true.',
      urdu: 'Community context, not legal advice. Official sources linked in notes do not prove this forward is true.',
    ),
    'community_rumour_submit': l10nEntry(
      english: 'Submit rumour check',
      arabic: 'Submit rumour check',
      hindi: 'Submit rumour check',
      urdu: 'Submit rumour check',
    ),
    'community_rumour_success': l10nEntry(
      english: 'Rumour check posted. Community context may be added soon.',
      arabic: 'Rumour check posted. Community context may be added soon.',
      hindi: 'Rumour check posted. Community context may be added soon.',
      urdu: 'Rumour check posted. Community context may be added soon.',
    ),
    'community_rumour_type_chip': l10nEntry(
      english: 'Rumour Check',
      arabic: 'Rumour Check',
      hindi: 'Rumour Check',
      urdu: 'Rumour Check',
    ),
    'community_rumour_status_open': l10nEntry(
      english: 'Open: no verified context yet',
      arabic: 'Open: no verified context yet',
      hindi: 'Open: no verified context yet',
      urdu: 'Open: no verified context yet',
    ),
    'community_rumour_status_context': l10nEntry(
      english: 'Context added',
      arabic: 'Context added',
      hindi: 'Context added',
      urdu: 'Context added',
    ),
    'community_rumour_status_verified': l10nEntry(
      english: 'Community-verified context',
      arabic: 'Community-verified context',
      hindi: 'Community-verified context',
      urdu: 'Community-verified context',
    ),
    'community_rumour_truth_engine_link': l10nEntry(
      english: 'Open related Truth Engine',
      arabic: 'Open related Truth Engine',
      hindi: 'Open related Truth Engine',
      urdu: 'Open related Truth Engine',
    ),
    'community_rumour_cat_visa': l10nEntry(
      english: 'Visa',
      arabic: 'Visa',
      hindi: 'Visa',
      urdu: 'Visa',
    ),
    'community_rumour_cat_labour': l10nEntry(
      english: 'Labour',
      arabic: 'Labour',
      hindi: 'Labour',
      urdu: 'Labour',
    ),
    'community_rumour_cat_housing': l10nEntry(
      english: 'Housing',
      arabic: 'Housing',
      hindi: 'Housing',
      urdu: 'Housing',
    ),
    'community_rumour_cat_fees': l10nEntry(
      english: 'Fees',
      arabic: 'Fees',
      hindi: 'Fees',
      urdu: 'Fees',
    ),
    'community_rumour_cat_health': l10nEntry(
      english: 'Health',
      arabic: 'Health',
      hindi: 'Health',
      urdu: 'Health',
    ),
    'community_rumour_cat_other': l10nEntry(
      english: 'Other',
      arabic: 'Other',
      hindi: 'Other',
      urdu: 'Other',
    ),
    'community_rumour_context_note_hint': l10nEntry(
      english: 'Add community context (not a verdict)',
      arabic: 'Add community context (not a verdict)',
      hindi: 'Add community context (not a verdict)',
      urdu: 'Add community context (not a verdict)',
    ),
    'community_rumour_source_url_label': l10nEntry(
      english: 'Official source link (optional)',
      arabic: 'Official source link (optional)',
      hindi: 'Official source link (optional)',
      urdu: 'Official source link (optional)',
    ),
    'community_rumour_source_url_hint': l10nEntry(
      english: 'https://…',
      arabic: 'https://…',
      hindi: 'https://…',
      urdu: 'https://…',
    ),
    'community_rumour_context_note_composer_notice': l10nEntry(
      english:
          'Sources are checked for link safety only. A link does not mean the rumour is true.',
      arabic:
          'Sources are checked for link safety only. A link does not mean the rumour is true.',
      hindi:
          'Sources are checked for link safety only. A link does not mean the rumour is true.',
      urdu:
          'Sources are checked for link safety only. A link does not mean the rumour is true.',
    ),
    'community_rumour_note_official_source': l10nEntry(
      english: 'Official source (directory)',
      arabic: 'Official source (directory)',
      hindi: 'Official source (directory)',
      urdu: 'Official source (directory)',
    ),
    'community_rumour_note_source_not_verified': l10nEntry(
      english: 'Source not verified',
      arabic: 'Source not verified',
      hindi: 'Source not verified',
      urdu: 'Source not verified',
    ),
    'community_rumour_source_not_proof': l10nEntry(
      english: 'This does not verify the forwarded claim.',
      arabic: 'This does not verify the forwarded claim.',
      hindi: 'This does not verify the forwarded claim.',
      urdu: 'This does not verify the forwarded claim.',
    ),
    'community_rumour_read_official_source': l10nEntry(
      english: 'Open source link',
      arabic: 'Open source link',
      hindi: 'Open source link',
      urdu: 'Open source link',
    ),
    'community_rumour_source_invalid': l10nEntry(
      english: 'Enter a valid HTTPS source link or leave blank.',
      arabic: 'Enter a valid HTTPS source link or leave blank.',
      hindi: 'Enter a valid HTTPS source link or leave blank.',
      urdu: 'Enter a valid HTTPS source link or leave blank.',
    ),
    'community_rumour_source_deceptive': l10nEntry(
      english: 'This source link looks deceptive and cannot be added.',
      arabic: 'This source link looks deceptive and cannot be added.',
      hindi: 'This source link looks deceptive and cannot be added.',
      urdu: 'This source link looks deceptive and cannot be added.',
    ),
  };

  static String nationalityLabel(String countryId, String locale) {
    return t('community_nat_label_$countryId', locale);
  }

  static String rumourCategoryLabel(String categoryId, String locale) {
    return t('community_rumour_cat_$categoryId', locale);
  }
}
