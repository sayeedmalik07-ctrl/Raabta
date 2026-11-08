import 'package:flutter/foundation.dart';
import 'package:raabta/core/l10n/app_locale.dart';
import 'package:raabta/core/l10n/locale_catalog_coverage.dart';
import 'package:raabta/core/l10n/locale_catalog_entry.dart';
import 'package:raabta/screens/profile/models/my_activity_item.dart';

abstract final class MyActivityStrings {
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
    var value = t(key, locale);
    params.forEach((placeholder, replacement) {
      value = value.replaceAll('{$placeholder}', replacement);
    });
    return value;
  }

  static String statusLabel(
    MyActivityVertical vertical,
    String statusKey,
    String locale,
  ) {
    final key = switch (vertical) {
      MyActivityVertical.marketplace => switch (statusKey) {
          'pending' => 'my_activity_mp_pending',
          'awaiting_buyer' => 'my_activity_mp_awaiting_buyer',
          _ => 'my_activity_mp_pending',
        },
      MyActivityVertical.housing => switch (statusKey) {
          'pending' => 'my_activity_hv_pending',
          'awaiting_viewer' => 'my_activity_hv_awaiting_viewer',
          _ => 'my_activity_hv_pending',
        },
      MyActivityVertical.services => switch (statusKey) {
          'quote_submitted' => 'my_activity_svc_quote_submitted',
          'quote_selected' => 'my_activity_svc_quote_selected',
          'quote_awaiting_customer' => 'my_activity_svc_quote_waiting',
          _ => 'my_activity_svc_quote_submitted',
        },
      MyActivityVertical.jobs => switch (statusKey) {
          'applied' => 'my_activity_job_applied',
          'under_review' => 'my_activity_job_under_review',
          'contacted' => 'my_activity_job_contacted',
          'closed' => 'my_activity_job_closed',
          _ => 'my_activity_job_applied',
        },
      MyActivityVertical.business => switch (statusKey) {
          'pending' => 'my_activity_biz_pending',
          'awaiting_requester' => 'my_activity_biz_awaiting_requester',
          'quoted' => 'my_activity_biz_quoted',
          _ => 'my_activity_biz_pending',
        },
    };
    return t(key, locale);
  }

  static String sectionTitle(MyActivityVertical vertical, String locale) {
    return t(switch (vertical) {
      MyActivityVertical.marketplace => 'my_activity_section_marketplace',
      MyActivityVertical.housing => 'my_activity_section_housing',
      MyActivityVertical.services => 'my_activity_section_services',
      MyActivityVertical.jobs => 'my_activity_section_jobs',
      MyActivityVertical.business => 'my_activity_section_business',
    }, locale);
  }

  @visibleForTesting
  static Map<String, Set<String>> get localeCoverageReport =>
      buildLocaleCoverageReport(
        catalog: _catalog,
        supportedLocales: supportedLocales,
      );

  static final _catalog = <String, Map<String, String>>{
    'settings_my_activity': l10nEntry(
      english: 'My Activity',
      arabic: 'نشاطي',
      hindi: 'Meri activity',
    ),
    'my_activity_title': l10nEntry(
      english: 'My Activity',
      arabic: 'نشاطي',
      hindi: 'Meri activity',
    ),
    'my_activity_empty': l10nEntry(
      english: 'Nothing needs your attention right now.',
      arabic: 'لا يوجد شيء يحتاج انتباهك الآن.',
      hindi: 'Abhi kuch bhi aapka dhyan maangta nahi hai.',
    ),
    'my_activity_incomplete': l10nEntry(
      english:
          'Some activity could not be loaded. The list below may be incomplete.',
      arabic: 'تعذّر تحميل بعض النشاط. قد تكون القائمة أدناه غير مكتملة.',
      hindi:
          'Kuch activity load nahi ho saki. Neeche ki list adhuri ho sakti hai.',
    ),
    'my_activity_load_failed': l10nEntry(
      english: 'Could not load your activity right now. Please try again.',
      arabic: 'تعذّر تحميل نشاطك الآن. يرجى المحاولة مرة أخرى.',
      hindi: 'Abhi aapki activity load nahi ho saki. Dobara koshish karein.',
    ),
    'my_activity_section_marketplace': l10nEntry(
      english: 'Marketplace Offers',
      arabic: 'عروض السوق',
      hindi: 'Marketplace offers',
    ),
    'my_activity_section_housing': l10nEntry(
      english: 'Housing Viewings',
      arabic: 'معاينات السكن',
      hindi: 'Housing viewings',
    ),
    'my_activity_section_services': l10nEntry(
      english: 'Service Quotes',
      arabic: 'عروض الخدمات',
      hindi: 'Service quotes',
    ),
    'my_activity_section_jobs': l10nEntry(
      english: 'Job Applications',
      arabic: 'طلبات التوظيف',
      hindi: 'Job applications',
    ),
    'my_activity_mp_pending': l10nEntry(
      english: 'New offer received',
      arabic: 'عرض جديد وارد',
      hindi: 'Naya offer aaya',
    ),
    'my_activity_mp_awaiting_buyer': l10nEntry(
      english: 'Counter offer awaiting your response',
      arabic: 'عرض مضاد بانتظار ردك',
      hindi: 'Counter offer aapke jawab ka intezaar',
    ),
    'my_activity_hv_pending': l10nEntry(
      english: 'Viewing request awaiting confirmation',
      arabic: 'طلب معاينة بانتظار التأكيد',
      hindi: 'Viewing request confirm hone ka intezaar',
    ),
    'my_activity_hv_awaiting_viewer': l10nEntry(
      english: 'Counter slot awaiting your response',
      arabic: 'موعد بديل بانتظار ردك',
      hindi: 'Counter slot aapke jawab ka intezaar',
    ),
    'my_activity_svc_quote_submitted': l10nEntry(
      english: 'New quote submitted',
      arabic: 'عرض سعر جديد',
      hindi: 'Naya quote submit hua',
    ),
    'my_activity_svc_quote_selected': l10nEntry(
      english: 'Your quote was selected',
      arabic: 'تم اختيار عرضك',
      hindi: 'Aapka quote select hua',
    ),
    'my_activity_svc_quote_waiting': l10nEntry(
      english: 'Quote submitted — awaiting customer',
      arabic: 'عرض مُرسَل — بانتظار العميل',
      hindi: 'Quote bheja — customer ka intezaar',
    ),
    'my_activity_job_applied': l10nEntry(
      english: 'New application',
      arabic: 'طلب جديد',
      hindi: 'Nayi application',
    ),
    'my_activity_job_under_review': l10nEntry(
      english: 'Under review',
      arabic: 'قيد المراجعة',
      hindi: 'Review mein hai',
    ),
    'my_activity_job_contacted': l10nEntry(
      english: 'Employer contacted you',
      arabic: 'تواصل معك صاحب العمل',
      hindi: 'Employer ne contact kiya',
    ),
    'my_activity_job_closed': l10nEntry(
      english: 'Closed',
      arabic: 'مغلق',
      hindi: 'Band ho gaya',
    ),
    'my_activity_section_business': l10nEntry(
      english: 'Business',
      arabic: 'أعمال',
      hindi: 'Business',
    ),
    'my_activity_biz_pending': l10nEntry(
      english: 'Appointment/quote pending',
      arabic: 'موعد/عرض سعر قيد الانتظار',
      hindi: 'Appointment/quote pending',
    ),
    'my_activity_biz_awaiting_requester': l10nEntry(
      english: 'Respond to suggested times',
      arabic: 'الرد على الأوقات المقترحة',
      hindi: 'Suggested times ka jawab dein',
    ),
    'my_activity_biz_quoted': l10nEntry(
      english: 'Quote received',
      arabic: 'تم استلام عرض السعر',
      hindi: 'Quote mila',
    ),
    'my_activity_section_life_intelligence': l10nEntry(
      english: 'Life Intelligence',
      arabic: 'Life Intelligence',
      hindi: 'Life Intelligence',
    ),
    'my_activity_li_transfer_title': l10nEntry(
      english: 'Sponsorship Transfer readiness + EOSB',
      arabic: 'جاهزية نقل الكفالة + EOSB',
      hindi: 'Sponsorship Transfer readiness + EOSB',
    ),
    'my_activity_li_transfer_body': l10nEntry(
      english:
          'You completed a Sponsorship Transfer readiness check and have EOSB history. Review your saved EOSB estimate.',
      arabic:
          'أكملت فحص جاهزية نقل الكفالة ولديك سجل EOSB. راجع تقدير EOSB المحفوظ.',
      hindi:
          'You completed a Sponsorship Transfer readiness check and have EOSB history. Review your saved EOSB estimate.',
    ),
    'my_activity_li_mismatch_title': l10nEntry(
      english: 'EOSB and Health Insurance employer mismatch',
      arabic: 'عدم تطابق صاحب العمل بين EOSB والتأمين الصحي',
      hindi: 'EOSB and Health Insurance employer mismatch',
    ),
    'my_activity_li_mismatch_body': l10nEntry(
      english:
          'Your newest EOSB employer key differs from your latest Health Insurance record. Compare details in Health Insurance.',
      arabic:
          'مفتاح صاحب العمل في أحدث EOSB يختلف عن أحدث سجل للتأمين الصحي. قارن التفاصيل في التأمين الصحي.',
      hindi:
          'Your newest EOSB employer key differs from your latest Health Insurance record. Compare details in Health Insurance.',
    ),
    'my_activity_li_dismiss': l10nEntry(
      english: 'Dismiss',
      arabic: 'تجاهل',
      hindi: 'Dismiss',
    ),
    'my_activity_li_advisory': l10nEntry(
      english: 'Advisory',
      arabic: 'إرشادي',
      hindi: 'Advisory',
    ),
    'my_activity_section_drafts': l10nEntry(
      english: 'Drafts',
      arabic: 'المسودات',
      hindi: 'Drafts',
      malayalam: 'Drafts',
      nepali: 'Drafts',
      bengali: 'Drafts',
      filipino: 'Drafts',
      tamil: 'Drafts',
      urdu: 'Drafts',
    ),
    'my_activity_draft_last_edited': l10nEntry(
      english: 'Last edited {time}',
      arabic: 'آخر تعديل {time}',
      hindi: 'Last edited {time}',
      malayalam: 'Last edited {time}',
      nepali: 'Last edited {time}',
      bengali: 'Last edited {time}',
      filipino: 'Last edited {time}',
      tamil: 'Last edited {time}',
      urdu: 'Last edited {time}',
    ),
    'my_activity_draft_resume': l10nEntry(
      english: 'Resume',
      arabic: 'متابعة',
      hindi: 'Resume',
      malayalam: 'Resume',
      nepali: 'Resume',
      bengali: 'Resume',
      filipino: 'Resume',
      tamil: 'Resume',
      urdu: 'Resume',
    ),
    'my_activity_draft_delete': l10nEntry(
      english: 'Delete',
      arabic: 'حذف',
      hindi: 'Delete',
      malayalam: 'Delete',
      nepali: 'Delete',
      bengali: 'Delete',
      filipino: 'Delete',
      tamil: 'Delete',
      urdu: 'Delete',
    ),
    'my_activity_draft_delete_title': l10nEntry(
      english: 'Delete draft?',
      arabic: 'حذف المسودة؟',
      hindi: 'Delete draft?',
      malayalam: 'Delete draft?',
      nepali: 'Delete draft?',
      bengali: 'Delete draft?',
      filipino: 'Delete draft?',
      tamil: 'Delete draft?',
      urdu: 'Delete draft?',
    ),
    'my_activity_draft_delete_body': l10nEntry(
      english: 'This cannot be undone. You will lose unsaved progress.',
      arabic: 'لا يمكن التراجع. ستفقد التقدم غير المحفوظ.',
      hindi: 'This cannot be undone. You will lose unsaved progress.',
      malayalam: 'This cannot be undone. You will lose unsaved progress.',
      nepali: 'This cannot be undone. You will lose unsaved progress.',
      bengali: 'This cannot be undone. You will lose unsaved progress.',
      filipino: 'This cannot be undone. You will lose unsaved progress.',
      tamil: 'This cannot be undone. You will lose unsaved progress.',
      urdu: 'This cannot be undone. You will lose unsaved progress.',
    ),
    'my_activity_draft_delete_cancel': l10nEntry(
      english: 'Cancel',
      arabic: 'إلغاء',
      hindi: 'Cancel',
      malayalam: 'Cancel',
      nepali: 'Cancel',
      bengali: 'Cancel',
      filipino: 'Cancel',
      tamil: 'Cancel',
      urdu: 'Cancel',
    ),
    'my_activity_draft_delete_confirm': l10nEntry(
      english: 'Delete',
      arabic: 'حذف',
      hindi: 'Delete',
      malayalam: 'Delete',
      nepali: 'Delete',
      bengali: 'Delete',
      filipino: 'Delete',
      tamil: 'Delete',
      urdu: 'Delete',
    ),
  };
}
