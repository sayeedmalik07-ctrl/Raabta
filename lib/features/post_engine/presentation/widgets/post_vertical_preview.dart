import 'package:flutter/material.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/glass/glass_card.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/features/post_engine/domain/models/post_vertical.dart';
import 'package:raabta/features/post_engine/l10n/post_engine_strings.dart';
import 'package:raabta/models/marketplace_models.dart';
import 'package:raabta/screens/marketplace/widgets/marketplace_listing_card.dart';

/// Vertical-specific preview rendering (Phase 8) — not a generic card.
class PostVerticalPreview extends StatelessWidget {
  const PostVerticalPreview({
    super.key,
    required this.vertical,
    required this.categoryPath,
    required this.values,
    required this.locale,
  });

  final PostVertical vertical;
  final String categoryPath;
  final Map<String, dynamic> values;
  final String locale;

  @override
  Widget build(BuildContext context) {
    return switch (vertical) {
      PostVertical.marketplace => _MarketplacePreview(
        values: values,
        categoryPath: categoryPath,
        locale: locale,
      ),
      PostVertical.housing => _HousingPreview(values: values, locale: locale),
      PostVertical.jobs => _JobPreview(values: values, locale: locale),
      PostVertical.business => _BusinessPreview(values: values, locale: locale),
      PostVertical.services => _ServicePreview(values: values, locale: locale),
    };
  }
}

class _MarketplacePreview extends StatelessWidget {
  const _MarketplacePreview({
    required this.values,
    required this.categoryPath,
    required this.locale,
  });

  final Map<String, dynamic> values;
  final String categoryPath;
  final String locale;

  @override
  Widget build(BuildContext context) {
    final leafId = categoryPath.split('.').last;
    final category = marketplaceCategoryById(leafId);
    final price = int.tryParse(values['price']?.toString() ?? '') ?? 0;
    final listing = MarketplaceListing(
      id: 'preview',
      categoryId: leafId,
      emoji: category.emoji,
      title: _title(values),
      price: price > 0 ? '$price QR' : '—',
      area: values['location']?.toString() ?? '',
      posted: 'Preview',
      condition: _conditionLabel(values['condition']),
      sellerFlag: '🌍',
      views: 0,
      distanceKm: 0,
    );

    return MarketplaceListingCard(
      listing: listing,
      locale: locale,
      showTrustBadges: false,
      isSaved: false,
      onSave: () {},
      onTap: () {},
    );
  }

  String _title(Map<String, dynamic> v) {
    for (final key in ['title', 'brand', 'model']) {
      final val = v[key]?.toString().trim();
      if (val != null && val.isNotEmpty) return val;
    }
    return 'Marketplace item';
  }

  String _conditionLabel(dynamic raw) {
    return switch (raw?.toString()) {
      'condition_new' => 'New',
      'condition_used' => 'Used',
      'condition_refurbished' => 'Refurbished',
      _ => raw?.toString() ?? '',
    };
  }
}

class _HousingPreview extends StatelessWidget {
  const _HousingPreview({required this.values, required this.locale});

  final Map<String, dynamic> values;
  final String locale;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('🏠', style: const TextStyle(fontSize: 40)),
          const SizedBox(height: AppSpacing.sm),
          Text(
            values['title']?.toString() ??
                PostEngineStrings.t('preview_untitled', locale),
            style: AppTypography.title,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            '${values['price'] ?? '—'} QAR / month',
            style: AppTypography.body.copyWith(color: AppColors.cyanGlow),
          ),
          if (values['location'] != null) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(values['location'].toString(), style: AppTypography.caption),
          ],
          if (values['description']?.toString().isNotEmpty == true) ...[
            const SizedBox(height: AppSpacing.md),
            Text(values['description'].toString(), style: AppTypography.body),
          ],
        ],
      ),
    );
  }
}

class _JobPreview extends StatelessWidget {
  const _JobPreview({required this.values, required this.locale});

  final Map<String, dynamic> values;
  final String locale;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('💼', style: const TextStyle(fontSize: 40)),
          const SizedBox(height: AppSpacing.sm),
          Text(
            values['title']?.toString() ??
                PostEngineStrings.t('preview_untitled', locale),
            style: AppTypography.title,
          ),
          Text(
            values['company']?.toString() ?? '',
            style: AppTypography.body.copyWith(color: AppColors.textSecondary),
          ),
          if (values['linkedBusinessName']?.toString().isNotEmpty == true) ...[
            const SizedBox(height: 4),
            Text(
              'Linked business: ${values['linkedBusinessName']}',
              style: AppTypography.caption.copyWith(color: AppColors.cyanGlow),
            ),
          ],
          const SizedBox(height: AppSpacing.sm),
          if (values['salary'] != null)
            Text('💰 ${values['salary']}', style: AppTypography.body),
          if (values['location'] != null)
            Text('📍 ${values['location']}', style: AppTypography.caption),
          if (values['description']?.toString().isNotEmpty == true) ...[
            const SizedBox(height: AppSpacing.md),
            Text(values['description'].toString(), style: AppTypography.body),
          ],
        ],
      ),
    );
  }
}

class _BusinessPreview extends StatelessWidget {
  const _BusinessPreview({required this.values, required this.locale});

  final Map<String, dynamic> values;
  final String locale;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('🏪', style: const TextStyle(fontSize: 40)),
          const SizedBox(height: AppSpacing.sm),
          Text(
            values['name']?.toString() ??
                PostEngineStrings.t('preview_untitled', locale),
            style: AppTypography.title,
          ),
          if (values['location'] != null)
            Text('📍 ${values['location']}', style: AppTypography.caption),
          if (values['phone'] != null)
            Text('📞 ${values['phone']}', style: AppTypography.caption),
          if (values['description']?.toString().isNotEmpty == true) ...[
            const SizedBox(height: AppSpacing.md),
            Text(values['description'].toString(), style: AppTypography.body),
          ],
        ],
      ),
    );
  }
}

class _ServicePreview extends StatelessWidget {
  const _ServicePreview({required this.values, required this.locale});

  final Map<String, dynamic> values;
  final String locale;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('🔧', style: const TextStyle(fontSize: 40)),
          const SizedBox(height: AppSpacing.sm),
          Text(
            values['title']?.toString() ??
                values['serviceName']?.toString() ??
                PostEngineStrings.t('preview_untitled', locale),
            style: AppTypography.title,
          ),
          if (values['providerName'] != null)
            Text(
              values['providerName'].toString(),
              style: AppTypography.caption,
            ),
          if (values['location'] != null)
            Text('📍 ${values['location']}', style: AppTypography.caption),
          if (values['description']?.toString().isNotEmpty == true) ...[
            const SizedBox(height: AppSpacing.md),
            Text(values['description'].toString(), style: AppTypography.body),
          ],
        ],
      ),
    );
  }
}
