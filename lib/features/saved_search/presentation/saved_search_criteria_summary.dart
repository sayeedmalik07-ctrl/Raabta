import 'package:raabta/data/categories/business_categories.dart';
import 'package:raabta/data/models/category_filter.dart';
import 'package:raabta/features/saved_search/domain/saved_search.dart';
import 'package:raabta/features/saved_search/domain/saved_search_vertical.dart';
import 'package:raabta/features/saved_search/l10n/saved_search_strings.dart';

/// Human-readable criteria line for hub saved-search cards (sub-screen kit).
String savedSearchCriteriaSummary(SavedSearch search, String locale) {
  final vertical = SavedSearchStrings.verticalLabel(search.vertical, locale);
  final parts = <String>[vertical];

  switch (search.vertical) {
    case SavedSearchVertical.business:
      parts.addAll(_businessParts(search, locale));
    default:
      for (final entry in search.criteria.values.entries) {
        if (entry.value == null) continue;
        final text = entry.value.toString().trim();
        if (text.isEmpty) continue;
        parts.add('${entry.key}: $text');
      }
  }

  return parts.take(4).join(' · ');
}

List<String> _businessParts(SavedSearch search, String locale) {
  final map = search.criteria.values;
  final out = <String>[];

  final query = map['query']?.toString().trim();
  if (query != null && query.isNotEmpty) {
    out.add(query);
  }

  final categoryFilter = map['category']?.toString();
  if (categoryFilter != null && categoryFilter.isNotEmpty) {
    CategoryFilter? match;
    for (final cat in kBusinessCategories) {
      if (cat.filter == categoryFilter) {
        match = cat;
        break;
      }
    }
    out.add(match?.label ?? categoryFilter);
  } else if (map['businessTag']?.toString() == 'ramadan_iftar') {
    for (final cat in kBusinessCategories) {
      if (cat.filter == 'ramadan_iftar') {
        out.add(cat.label);
        break;
      }
    }
  }

  final area = map['area']?.toString().trim();
  if (area != null && area.isNotEmpty) out.add(area);

  return out;
}
