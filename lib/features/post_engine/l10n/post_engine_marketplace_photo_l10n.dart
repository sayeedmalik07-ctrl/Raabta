import 'package:raabta/core/l10n/locale_catalog_entry.dart';

/// Marketplace photo-first posting flow strings.
final Map<String, Map<String, String>> postEngineMarketplacePhotoKeys = {
  'marketplace_photo_first_title': l10nEntry(
    english: 'Add photos of your item',
    arabic: 'أضف صوراً للمنتج',
  ),
  'marketplace_photo_first_body': l10nEntry(
    english:
        'Start with a clear photo. Raabta will suggest a category, title, and description — you can edit everything before publishing.',
    arabic:
        'ابدأ بصورة واضحة. Raabta ستقترح الفئة والعنوان والوصف — يمكنك تعديل كل شيء قبل النشر.',
  ),
  'marketplace_photo_hint_label': l10nEntry(
    english: 'Optional: what are you selling?',
    arabic: 'اختياري: ماذا تبيع؟',
  ),
  'marketplace_photo_hint_placeholder': l10nEntry(
    english: 'e.g. iPhone 13, dining table',
    arabic: 'مثال: آيفون 13، طاولة طعام',
  ),
  'marketplace_photo_add': l10nEntry(
    english: 'Add photos',
    arabic: 'إضافة صور',
  ),
  'marketplace_photo_continue': l10nEntry(
    english: 'Continue with AI suggestions',
    arabic: 'متابعة مع اقتراحات Raabta',
  ),
  'marketplace_photo_manual_category': l10nEntry(
    english: 'Choose category manually',
    arabic: 'اختر الفئة يدوياً',
  ),
  'marketplace_photo_manual_form': l10nEntry(
    english: 'Fill form without photos',
    arabic: 'املأ النموذج بدون صور',
  ),
  'marketplace_ai_analyzing': l10nEntry(
    english: 'Analyzing your item…',
    arabic: 'جارٍ تحليل المنتج…',
  ),
  'marketplace_ai_failed': l10nEntry(
    english: 'Could not analyze photos. Choose a category manually.',
    arabic: 'تعذّر تحليل الصور. اختر الفئة يدوياً.',
  ),
  'marketplace_category_detected': l10nEntry(
    english: 'Suggested category',
    arabic: 'الفئة المقترحة',
  ),
  'marketplace_category_confirm': l10nEntry(
    english: 'Use this category',
    arabic: 'استخدم هذه الفئة',
  ),
  'marketplace_category_change': l10nEntry(
    english: 'Pick a different category',
    arabic: 'اختر فئة مختلفة',
  ),
  'marketplace_price_grounded': l10nEntry(
    english:
        'Similar listings in Raabta: {min}–{max} QR (median {median} QR, {count} listings)',
    arabic:
        'إعلانات مشابهة في Raabta: {min}–{max} ر.ق (الوسيط {median} ر.ق، {count} إعلانات)',
  ),
  'marketplace_price_ungrounded': l10nEntry(
    english:
        'Not enough similar listings yet — use your own price. General estimate unavailable.',
    arabic:
        'لا توجد إعلانات مشابهة كافية بعد — حدّد سعرك. لا يتوفر تقدير عام.',
  ),
  'marketplace_reseller_nudge_frequency': l10nEntry(
    english:
        'You have posted several marketplace items recently. If you sell professionally, consider Raabta\'s Business listing type.',
    arabic:
        'نشرت عدة عناصر مؤخراً. إذا كنت تبيع بشكل احترافي، فكّر في نوع Business في Raabta.',
  ),
  'marketplace_reseller_nudge_similar': l10nEntry(
    english:
        'This looks similar to another listing you posted. Business listings may fit better if you sell multiple items.',
    arabic:
        'يبدو هذا مشابهاً لإعلان آخر نشرته. قد يناسبك Business إذا كنت تبيع عدة عناصر.',
  ),
  'marketplace_reseller_nudge_new_items': l10nEntry(
    english:
        'Many of your recent listings are marked as new. If you are a shop or reseller, check out Business listings.',
    arabic:
        'كثير من إعلاناتك الأخيرة marked as new. إذا كنت متجراً أو reseller، راجع Business.',
  ),
};
