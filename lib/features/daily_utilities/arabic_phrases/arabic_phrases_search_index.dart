import 'package:raabta/features/daily_utilities/arabic_phrases/arabic_phrases_data.dart';
import 'package:raabta/features/global_search/domain/global_search_models.dart';
import 'package:raabta/features/global_search/domain/static_search_entry.dart';

/// Arabic Companion phrasebook + live translation discoverability for Global Search.
abstract final class ArabicPhrasesSearchIndex {
  static List<StaticSearchEntry> get all => [
        const StaticSearchEntry(
          id: 'arabic_companion_hub',
          title: 'Arabic Companion',
          subtitle: 'Qatar phrasebook + live translation',
          keywords: [
            'arabic',
            'phrases',
            'phrasebook',
            'learn arabic',
            'speak arabic',
            'qatar arabic',
            'gulf arabic',
            'translator',
            'landmark',
            'taxi',
            'directions',
          ],
          routePath: '/arabic-companion',
          category: GlobalSearchCategory.tools,
        ),
        ...phraseCategories.map(
          (cat) => StaticSearchEntry(
            id: 'arabic_cat_${cat.id}',
            title: phraseCategoryLabel(cat.labelKey, 'English'),
            subtitle: 'Arabic Companion · ${cat.emoji}',
            keywords: [
              cat.id,
              phraseCategoryLabel(cat.labelKey, 'English'),
              'arabic phrases',
            ],
            routePath: '/arabic-companion?category=${cat.id}',
            category: GlobalSearchCategory.tools,
          ),
        ),
        ...arabicPhrases.map(
          (p) => StaticSearchEntry(
            id: 'arabic_phrase_${p.id}',
            title: p.translations['English'] ?? p.id,
            subtitle: 'Arabic Companion · ${p.transliteration}',
            keywords: [
              p.transliteration,
              p.arabicScript,
              p.translations['English'] ?? '',
              p.categoryId,
              'arabic',
            ],
            routePath: '/arabic-companion?phrase=${p.id}',
            category: GlobalSearchCategory.tools,
          ),
        ),
      ];
}
