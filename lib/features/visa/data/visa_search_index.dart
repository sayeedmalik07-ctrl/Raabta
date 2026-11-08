import 'package:raabta/features/global_search/domain/global_search_models.dart';
import 'package:raabta/features/global_search/domain/static_search_entry.dart';
import 'package:raabta/models/visa_models.dart';

/// Static searchable entries for Visa & Documents — co-located with visa content.
abstract final class VisaSearchIndex {
  static List<StaticSearchEntry> get all => [
        for (final cat in visaCategories)
          StaticSearchEntry(
            id: 'visa_${cat.id}',
            title: cat.title,
            subtitle: 'Visa guide · ${cat.estimatedTime}',
            keywords: [
              cat.title,
              cat.id.replaceAll('_', ' '),
              'visa',
              'iqama',
              'documents',
              'qatar',
              'metrash',
            ],
            routePath: '/visa/guide/${cat.id}',
            category: GlobalSearchCategory.visa,
          ),
        const StaticSearchEntry(
          id: 'visa_deadline_tracker',
          title: 'Deadline Tracker',
          subtitle: 'Visa & Documents · track renewals',
          keywords: [
            'deadline',
            'tracker',
            'renewal',
            'reminder',
            'iqama expiry',
            'visa expiry',
          ],
          routePath: '/visa',
          category: GlobalSearchCategory.visa,
        ),
        const StaticSearchEntry(
          id: 'visa_emergency',
          title: 'Emergency Help',
          subtitle: 'Visa & Documents · official hotlines',
          keywords: ['emergency', '999', 'moi', 'metrash', 'hotline', 'help'],
          routePath: '/visa',
          category: GlobalSearchCategory.visa,
        ),
      ];
}
