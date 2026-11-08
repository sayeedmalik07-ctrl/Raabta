import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/glass/glass_card.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/core/widgets/glass_primary_button.dart';
import 'package:raabta/features/consumer_protection/presentation/screens/consumer_complaint_screen.dart';
import 'package:raabta/features/quick_actions/warranty_shield/data/qatar_warranty_retailers.dart';
import 'package:raabta/features/quick_actions/warranty_shield/l10n/warranty_strings.dart';
import 'package:raabta/features/quick_actions/warranty_shield/models/warranty_item.dart';

/// Contextual retailer contact card when [retailer] matches bundled catalog.
class RetailerContactCard extends StatelessWidget {
  const RetailerContactCard({
    super.key,
    required this.retailer,
    required this.item,
    required this.locale,
    required this.onFileClaim,
    this.showClaimCta = true,
  });

  final QatarWarrantyRetailer retailer;
  final WarrantyItem item;
  final String locale;
  final VoidCallback onFileClaim;
  final bool showClaimCta;

  Future<void> _launchTel(String phone) async {
    final uri = Uri.parse('tel:${phone.replaceAll(' ', '')}');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _launchWeb(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      glowColor: AppColors.cyanGlow,
      glowIntensity: 0.12,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.storefront_outlined, color: AppColors.cyanGlow, size: 22),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  WarrantyStrings.format(
                    'warr_retailer_card_title',
                    locale,
                    params: {'retailer': retailer.displayName},
                  ),
                  style: AppTypography.subtitle.copyWith(
                    color: AppColors.cyanGlow,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            WarrantyStrings.t(retailer.policySummaryKey, locale),
            style: AppTypography.bodySmall.copyWith(height: 1.45),
          ),
          if (retailer.phone != null) ...[
            const SizedBox(height: AppSpacing.sm),
            _FieldRow(
              label: WarrantyStrings.t('warr_retailer_phone', locale),
              value: retailer.phone!.value,
              verified: retailer.phone!.verified,
              locale: locale,
              onTap: () => _launchTel(retailer.phone!.value),
              trailing: Icons.phone_outlined,
            ),
          ],
          if (retailer.serviceCenterKey != null) ...[
            const SizedBox(height: AppSpacing.xs),
            _FieldRow(
              label: WarrantyStrings.t('warr_retailer_service', locale),
              value: WarrantyStrings.t(retailer.serviceCenterKey!, locale),
              verified: false,
              locale: locale,
            ),
          ],
          if (retailer.websiteUrl != null) ...[
            const SizedBox(height: AppSpacing.xs),
            _FieldRow(
              label: WarrantyStrings.t('warr_retailer_website', locale),
              value: retailer.websiteUrl!.value,
              verified: retailer.websiteUrl!.verified,
              locale: locale,
              onTap: () => _launchWeb(retailer.websiteUrl!.value),
              trailing: Icons.open_in_new,
            ),
          ],
          const SizedBox(height: AppSpacing.sm),
          Text(
            WarrantyStrings.t('warr_retailer_verify_note', locale),
            style: AppTypography.caption.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          if (showClaimCta) ...[
            const SizedBox(height: AppSpacing.md),
            GlassPrimaryButton(
              label: WarrantyStrings.t('warr_retailer_start_claim', locale),
              icon: Icons.support_agent_outlined,
              expand: true,
              accentColor: AppColors.cyanGlow,
              onPressed: onFileClaim,
            ),
          ],
          const SizedBox(height: AppSpacing.sm),
          TextButton(
            onPressed: () => context.push(ConsumerComplaintScreen.route),
            child: Text(
              WarrantyStrings.t('warr_retailer_moci_link', locale),
              style: AppTypography.link,
            ),
          ),
        ],
      ),
    );
  }
}

class _FieldRow extends StatelessWidget {
  const _FieldRow({
    required this.label,
    required this.value,
    required this.verified,
    required this.locale,
    this.onTap,
    this.trailing,
  });

  final String label;
  final String value;
  final bool verified;
  final String locale;
  final VoidCallback? onTap;
  final IconData? trailing;

  @override
  Widget build(BuildContext context) {
    final content = Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: Text(label, style: AppTypography.caption),
        ),
        Expanded(
          flex: 3,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value, style: AppTypography.bodySmall),
              if (!verified)
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Text(
                    WarrantyStrings.t('warr_retailer_unconfirmed', locale),
                    style: AppTypography.caption.copyWith(
                      color: AppColors.accentGold,
                      fontSize: 10,
                    ),
                  ),
                ),
            ],
          ),
        ),
        if (trailing != null && onTap != null)
          IconButton(
            icon: Icon(trailing, size: 18, color: AppColors.cyanGlow),
            onPressed: onTap,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
      ],
    );

    if (onTap == null) return content;
    return InkWell(onTap: onTap, borderRadius: BorderRadius.circular(8), child: content);
  }
}
