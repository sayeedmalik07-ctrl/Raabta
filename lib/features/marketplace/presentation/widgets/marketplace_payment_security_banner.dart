import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/features/scam_shield/domain/payment_check_entry_points.dart';
import 'package:raabta/features/scam_shield/presentation/l10n/scam_shield_strings.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/features/marketplace/presentation/l10n/marketplace_strings.dart';

/// Part A — always visible in marketplace chat; dismiss once per screen session.
class MarketplacePaymentSecurityBanner extends StatelessWidget {
  const MarketplacePaymentSecurityBanner({
    super.key,
    required this.visible,
    required this.onDismiss,
    required this.locale,
  });

  final bool visible;
  final VoidCallback onDismiss;
  final String locale;

  @override
  Widget build(BuildContext context) {
    if (!visible) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.errorBright.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: AppColors.errorBright.withValues(alpha: 0.45)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.no_accounts_outlined,
              color: AppColors.errorBright, size: 22),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  MarketplaceStrings.t('mp_payment_security_banner_title', locale),
                  style: AppTypography.subtitle.copyWith(
                    color: AppColors.errorBright,
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  MarketplaceStrings.t('mp_payment_security_banner', locale),
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.errorBright,
                  ),
                ),
                if (PaymentCheckEntryPoints.marketplaceLinkVisible) ...[
                  const SizedBox(height: AppSpacing.xs),
                  TextButton(
                    onPressed: () =>
                        context.push('/scam-shield/payment-check'),
                    child: Text(
                      ScamShieldStrings.t('ss_payment_check_hub_link', locale),
                      style: AppTypography.caption.copyWith(
                        color: AppColors.errorBright,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, size: 18),
            color: AppColors.errorBright,
            onPressed: onDismiss,
            tooltip: MarketplaceStrings.t('mp_dismiss_session', locale),
          ),
        ],
      ),
    );
  }
}
