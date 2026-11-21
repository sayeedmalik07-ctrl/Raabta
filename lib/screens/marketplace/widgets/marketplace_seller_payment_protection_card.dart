import 'package:flutter/material.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/glass/glass_card.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/features/marketplace/presentation/l10n/marketplace_strings.dart';
import 'package:raabta/screens/marketplace/data/marketplace_seller_payment_protection_catalog.dart';
import 'package:url_launcher/url_launcher.dart';

/// Seller-side guidance against fake payment-screenshot fraud — informational only.
class MarketplaceSellerPaymentProtectionCard extends StatelessWidget {
  const MarketplaceSellerPaymentProtectionCard({
    super.key,
    required this.locale,
    this.compact = false,
    this.visible = true,
    this.onDismiss,
  });

  final String locale;
  final bool compact;
  final bool visible;
  final VoidCallback? onDismiss;

  static const _bulletKeys = [
    'mp_seller_payment_rule',
    'mp_seller_payment_advanced_variant',
    'mp_seller_payment_high_value',
  ];

  Future<void> _openMoiPortal() async {
    final uri = Uri.parse(MarketplaceSellerPaymentProtectionCatalog.moiPortalUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!visible) return const SizedBox.shrink();

    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                MarketplaceStrings.t('mp_seller_payment_title', locale),
                style: AppTypography.subtitle.copyWith(color: AppColors.info),
              ),
            ),
            if (onDismiss != null)
              IconButton(
                icon: const Icon(Icons.close, size: 18),
                color: AppColors.textTertiary,
                onPressed: onDismiss,
                tooltip: MarketplaceStrings.t('mp_dismiss_session', locale),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          MarketplaceStrings.t('mp_seller_payment_pattern', locale),
          style: AppTypography.bodySmall,
        ),
        const SizedBox(height: AppSpacing.sm),
        for (final key in _bulletKeys)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.xs),
            child: Text(
              '• ${MarketplaceStrings.t(key, locale)}',
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          MarketplaceStrings.t('mp_seller_payment_moi_report', locale),
          style: AppTypography.caption.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: _openMoiPortal,
            icon: const Icon(Icons.open_in_new_rounded, size: 18),
            label: Text(
              MarketplaceStrings.t('mp_seller_payment_moi_button', locale),
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.info,
              side: BorderSide(color: AppColors.info.withValues(alpha: 0.5)),
            ),
          ),
        ),
        if (!compact) ...[
          const SizedBox(height: AppSpacing.sm),
          Text(
            MarketplaceStrings.t('mp_seller_payment_disclaimer', locale),
            style: AppTypography.caption.copyWith(
              color: AppColors.textTertiary,
            ),
          ),
        ],
      ],
    );

    if (compact) {
      return Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: AppSpacing.sm),
        padding: const EdgeInsets.all(AppSpacing.sm),
        decoration: BoxDecoration(
          color: AppColors.info.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          border: Border.all(color: AppColors.info.withValues(alpha: 0.35)),
        ),
        child: content,
      );
    }

    return GlassCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      glowColor: AppColors.info,
      glowIntensity: 0.1,
      child: content,
    );
  }
}
