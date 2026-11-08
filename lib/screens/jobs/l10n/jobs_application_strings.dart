import 'package:flutter/foundation.dart';
import 'package:raabta/core/l10n/app_locale.dart';
import 'package:raabta/core/l10n/locale_catalog_coverage.dart';
import 'package:raabta/core/l10n/locale_catalog_entry.dart';

abstract final class JobsApplicationStrings {
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

  @visibleForTesting
  static Map<String, Set<String>> get localeCoverageReport =>
      buildLocaleCoverageReport(
        catalog: _catalog,
        supportedLocales: supportedLocales,
      );

  static final _catalog = <String, Map<String, String>>{
    'jobs_my_applications_title': l10nEntry(
      english: 'My Applications',
      arabic: 'طلباتي',
      hindi: 'Meri applications',
    ),
    'jobs_my_applications_empty': l10nEntry(
      english: 'You have not applied to any Raabta job listings yet.',
      arabic: 'لم تتقدّم بعد إلى أي وظائف على Raabta.',
      hindi: 'Aapne abhi tak kisi Raabta job par apply nahi kiya.',
    ),
    'jobs_my_applications_empty_title': l10nEntry(
      english: 'No applications yet',
      arabic: 'لا توجد طلبات بعد',
      hindi: 'Abhi koi application nahi',
    ),
    'jobs_my_applications_load_error': l10nEntry(
      english:
          'Could not load your applications. Check your connection and try again.',
      arabic: 'تعذّر تحميل طلباتك. تحقق من الاتصال وحاول مرة أخرى.',
      hindi:
          'Applications load nahi ho paye. Connection check karke dubara koshish karein.',
    ),
    'jobs_my_applications_retry': l10nEntry(
      english: 'Retry',
      arabic: 'إعادة المحاولة',
      hindi: 'Dubara koshish karein',
    ),
    'jobs_app_status_applied': l10nEntry(
      english: 'Applied',
      arabic: 'تم التقديم',
      hindi: 'Apply ho chuka hai',
    ),
    'jobs_app_status_under_review': l10nEntry(
      english: 'Under Review',
      arabic: 'قيد المراجعة',
      hindi: 'Review mein hai',
    ),
    'jobs_app_status_contacted': l10nEntry(
      english: 'Contacted',
      arabic: 'تم التواصل',
      hindi: 'Contact kiya gaya',
    ),
    'jobs_app_status_closed': l10nEntry(
      english: 'Closed',
      arabic: 'مغلق',
      hindi: 'Band ho gaya',
    ),
    'jobs_app_closed_hint': l10nEntry(
      english: 'This application is closed — the role may be filled or the process has ended for you.',
      arabic: 'هذا الطلب مغلق — قد تكون الوظيفة مُشغّلة أو انتهت العملية بالنسبة لك.',
      hindi: 'Yeh application band hai — role bhar chuki ho ya process aapke liye khatam ho chuka ho.',
    ),
    'jobs_app_chat_status_updated': l10nEntry(
      english: 'Your application status was updated to {status}.',
      arabic: 'تم تحديث حالة طلبك إلى {status}.',
      hindi: 'Aapki application ki status {status} par update hui.',
    ),
    'jobs_app_notif_title': l10nEntry(
      english: 'Application status updated',
      arabic: 'تم تحديث حالة الطلب',
      hindi: 'Application status update hui',
    ),
    'jobs_app_notif_body': l10nEntry(
      english: '{title}: {status}',
      arabic: '{title}: {status}',
      hindi: '{title}: {status}',
    ),
    'jobs_app_already_applied': l10nEntry(
      english: 'Applied',
      arabic: 'تم التقديم',
      hindi: 'Apply ho chuka hai',
    ),
    'jobs_app_manage_candidates': l10nEntry(
      english: 'Candidates',
      arabic: 'المرشّحون',
      hindi: 'Candidates',
    ),
    'jobs_app_manage_empty': l10nEntry(
      english: 'No applications yet for this listing.',
      arabic: 'لا توجد طلبات لهذا الإعلان بعد.',
      hindi: 'Is listing par abhi koi application nahi.',
    ),
    'jobs_app_update_status': l10nEntry(
      english: 'Update status',
      arabic: 'تحديث الحالة',
      hindi: 'Status update karein',
    ),
    'jobs_app_view_applications': l10nEntry(
      english: 'My Applications',
      arabic: 'طلباتي',
      hindi: 'Meri applications',
    ),
    'jobs_app_view_thread': l10nEntry(
      english: 'View updates',
      arabic: 'عرض التحديثات',
      hindi: 'Updates dekhein',
    ),
    'jobs_app_chat_title': l10nEntry(
      english: 'Application updates',
      arabic: 'تحديثات الطلب',
      hindi: 'Application updates',
    ),
    'jobs_app_set_under_review': l10nEntry(
      english: 'Mark under review',
      arabic: 'وضع قيد المراجعة',
      hindi: 'Review mein rakhein',
    ),
    'jobs_app_set_contacted': l10nEntry(
      english: 'Mark contacted',
      arabic: 'وضع تم التواصل',
      hindi: 'Contacted mark karein',
    ),
    'jobs_app_set_closed': l10nEntry(
      english: 'Mark closed',
      arabic: 'وضع مغلق',
      hindi: 'Closed mark karein',
    ),
    'jobs_hub_summary_applications_label': l10nEntry(
      english: 'Applications',
      arabic: 'الطلبات',
      hindi: 'Applications',
      urdu: 'Applications',
    ),
    'jobs_hub_summary_under_review_value': l10nEntry(
      english: '{count} under review',
      arabic: '{count} قيد المراجعة',
      hindi: '{count} under review',
      urdu: '{count} under review',
    ),
  };
}
