import 'package:flutter/material.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/glass/glass_card.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/features/marketplace/presentation/l10n/marketplace_strings.dart';
import 'package:raabta/features/post_engine/data/post_schema_persistence.dart';
import 'package:raabta/models/marketplace_models.dart';
import 'package:url_launcher/url_launcher.dart';

/// Buyer guidance for vehicle listings — official checks only; no Raabta verification.
class MarketplaceVehicleListingTrustCard extends StatelessWidget {
  const MarketplaceVehicleListingTrustCard({
    super.key,
    required this.listing,
    required this.locale,
  });

  final MarketplaceListing listing;
  final String locale;

  /// MOI Traffic Services hub — durable entry for Traffic Reports / chassis inquiries.
  static const moiTrafficServicesUrl =
      'https://portal.moi.gov.qa/wps/portal/MOIInternet/services/inquiries/trafficservices';

  static bool isVehicleListing(MarketplaceListing listing) {
    final id = listing.categoryId;
    return id == 'cars_bikes' || PostSchemaPersistence.isVehicleCategory(id);
  }

  Future<void> _openMoiTrafficPortal() async {
    final uri = Uri.parse(moiTrafficServicesUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      borderRadius: AppSpacing.radiusLg,
      padding: const EdgeInsets.all(AppSpacing.lg),
      glowColor: AppColors.cyanGlow,
      glowIntensity: 0.08,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            MarketplaceStrings.t('mp_vehicle_trust_card_title', locale),
            style: AppTypography.subtitle,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            MarketplaceStrings.t('mp_vehicle_trust_card_disclaimer', locale),
            style: AppTypography.caption.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          _TrustRow(
            icon: Icons.history_edu_outlined,
            title: MarketplaceStrings.t(
              'mp_vehicle_trust_accident_title',
              locale,
            ),
            summary: MarketplaceStrings.t(
              'mp_vehicle_trust_accident_summary',
              locale,
            ),
            buttonLabel: MarketplaceStrings.t(
              'mp_vehicle_trust_accident_button',
              locale,
            ),
            onPressed: _openMoiTrafficPortal,
          ),
          const SizedBox(height: AppSpacing.md),
          _TrustRow(
            icon: Icons.account_balance_outlined,
            title: MarketplaceStrings.t('mp_vehicle_trust_loan_title', locale),
            summary: MarketplaceStrings.t(
              'mp_vehicle_trust_loan_summary',
              locale,
            ),
          ),
        ],
      ),
    );
  }
}

class _TrustRow extends StatelessWidget {
  const _TrustRow({
    required this.icon,
    required this.title,
    required this.summary,
    this.buttonLabel,
    this.onPressed,
  });

  final IconData icon;
  final String title;
  final String summary;
  final String? buttonLabel;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 20, color: AppColors.cyanGlow),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTypography.subtitle),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    summary,
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        if (buttonLabel != null && onPressed != null) ...[
          const SizedBox(height: AppSpacing.sm),
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: OutlinedButton(
              onPressed: onPressed,
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.cyanGlow,
                side: BorderSide(
                  color: AppColors.cyanGlow.withValues(alpha: 0.45),
                ),
              ),
              child: Text(buttonLabel!),
            ),
          ),
        ],
      ],
    );
  }
}
