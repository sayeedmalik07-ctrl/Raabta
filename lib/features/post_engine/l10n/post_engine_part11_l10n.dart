import 'package:raabta/core/l10n/locale_catalog_entry.dart';

/// Part 11 — AI request entry, trust flags, verification messaging.
final Map<String, Map<String, String>> postEnginePart11Keys = {
  'request_ai_title': l10nEntry(
    english: 'Describe what you need',
    arabic: 'صف ما تحتاجه',
  ),
  'request_ai_subtitle': l10nEntry(
    english:
        'Optional — type a short description and we will suggest a category and details for you to review.',
    arabic: 'اختياري — اكتب وصفاً قصيراً وسنقترح الفئة والتفاصيل للمراجعة.',
  ),
  'request_ai_hint': l10nEntry(
    english: 'e.g. My AC is leaking water and I need someone today',
    arabic: 'مثال: المكيف يسرب ماءً وأحتاج فنياً اليوم',
  ),
  'request_ai_analyze': l10nEntry(
    english: 'Analyze description',
    arabic: 'تحليل الوصف',
  ),
  'request_ai_manual': l10nEntry(
    english: 'Choose category manually',
    arabic: 'اختر الفئة يدوياً',
  ),
  'request_ai_analyzing': l10nEntry(
    english: 'Analyzing…',
    arabic: 'جاري التحليل…',
  ),
  'request_ai_failed': l10nEntry(
    english:
        'Could not analyze your description. Choose a category manually to continue.',
    arabic: 'تعذّر تحليل الوصف. اختر الفئة يدوياً للمتابعة.',
  ),
  'request_ai_confirm_title': l10nEntry(
    english: 'Review AI suggestions',
    arabic: 'راجع اقتراحات الذكاء الاصطناعي',
  ),
  'request_ai_confirm_subtitle': l10nEntry(
    english:
        'Edit anything below before continuing. Nothing is saved until you confirm.',
    arabic: 'عدّل أي حقل قبل المتابعة. لا يُحفظ شيء حتى تؤكد.',
  ),
  'request_ai_confirm_category': l10nEntry(
    english: 'Suggested category',
    arabic: 'الفئة المقترحة',
  ),
  'request_ai_confirm_fields': l10nEntry(
    english: 'Suggested details',
    arabic: 'التفاصيل المقترحة',
  ),
  'request_ai_confirm_apply': l10nEntry(
    english: 'Use these suggestions',
    arabic: 'استخدم هذه الاقتراحات',
  ),
  'request_ai_confirm_reject': l10nEntry(
    english: 'Pick category manually instead',
    arabic: 'اختر الفئة يدوياً بدلاً من ذلك',
  ),
  'trust_identity_required': l10nEntry(
    english:
        'Identity verification is required for this category. Verify your email or sign in with phone, then try again.',
    arabic:
        'التحقق من الهوية مطلوب لهذه الفئة. فعّل بريدك أو سجّل الدخول بالهاتف ثم حاول مجدداً.',
  ),
  'trust_business_required': l10nEntry(
    english:
        'Business verification is required for this category. Document review is not available in the app yet — check back in a future update.',
    arabic:
        'التحقق من النشاط التجاري مطلوب لهذه الفئة. مراجعة المستندات غير متاحة بعد في التطبيق.',
  ),
  'trust_license_required': l10nEntry(
    english:
        'License verification is required for this category. Document upload is not available in the app yet — check back in a future update.',
    arabic:
        'التحقق من الترخيص مطلوب لهذه الفئة. رفع المستندات غير متاح بعد في التطبيق.',
  ),
  'trust_banner_identity': l10nEntry(
    english: 'This category requires verified identity to publish.',
    arabic: 'تتطلب هذه الفئة هوية موثّقة للنشر.',
  ),
  'trust_banner_business': l10nEntry(
    english: 'Business verification required (coming soon — not enforced yet).',
    arabic: 'التحقق التجاري مطلوب (قريباً — غير مفعّل بعد).',
  ),
  'trust_banner_license': l10nEntry(
    english: 'License verification required (coming soon — not enforced yet).',
    arabic: 'التحقق من الترخيص مطلوب (قريباً — غير مفعّل بعد).',
  ),
};
