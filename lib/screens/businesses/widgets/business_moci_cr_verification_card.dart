import 'package:flutter/material.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/glass/glass_card.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/screens/businesses/data/moci_cr_verification_catalog.dart';
import 'package:raabta/screens/businesses/l10n/businesses_strings.dart';
import 'package:url_launcher/url_launcher.dart';

/// MOCI/QFC registration verification guidance — link-out only; no Raabta verification.
class BusinessMociCrVerificationCard extends StatelessWidget {
  const BusinessMociCrVerificationCard({super.key, required this.locale});

  final String locale;

  static const diligenceItemKeys = [
    'biz_trust_diligence_item_1',
    'biz_trust_diligence_item_2',
    'biz_trust_diligence_item_3',
  ];

  Future<void> _openUrl(String url) async {
    final uri = Uri.parse(url);
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
            BusinessesStrings.t('biz_trust_cr_card_title', locale),
            style: AppTypography.subtitle,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            BusinessesStrings.t('biz_trust_cr_disclaimer', locale),
            style: AppTypography.caption.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          _TrustRow(
            icon: Icons.apartment_outlined,
            title: BusinessesStrings.t('biz_trust_cr_verify_title', locale),
            summary: BusinessesStrings.t('biz_trust_cr_verify_summary', locale),
            actions: [
              _LinkButton(
                label: BusinessesStrings.t('biz_trust_cr_moci_button', locale),
                onPressed: () => _openUrl(MociCrVerificationCatalog.mociBusinessMapUrl),
              ),
              _LinkButton(
                label: BusinessesStrings.t('biz_trust_cr_qatarcid_button', locale),
                onPressed: () => _openUrl(MociCrVerificationCatalog.qatarCidUrl),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          _TrustRow(
            icon: Icons.account_balance_outlined,
            title: BusinessesStrings.t('biz_trust_qfc_title', locale),
            summary: BusinessesStrings.t('biz_trust_qfc_summary', locale),
            actions: [
              _LinkButton(
                label: BusinessesStrings.t('biz_trust_qfc_button', locale),
                onPressed: () =>
                    _openUrl(MociCrVerificationCatalog.qfcPublicRegisterUrl),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            BusinessesStrings.t('biz_trust_diligence_title', locale),
            style: AppTypography.subtitle,
          ),
          const SizedBox(height: AppSpacing.sm),
          for (final key in diligenceItemKeys)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.xs),
              child: Text(
                '• ${BusinessesStrings.t(key, locale)}',
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
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
    required this.actions,
  });

  final IconData icon;
  final String title;
  final String summary;
  final List<_LinkButton> actions;

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
        if (actions.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.xs,
            children: actions
                .map(
                  (action) => OutlinedButton(
                    onPressed: action.onPressed,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.cyanGlow,
                      side: BorderSide(
                        color: AppColors.cyanGlow.withValues(alpha: 0.45),
                      ),
                    ),
                    child: Text(action.label),
                  ),
                )
                .toList(),
          ),
        ],
      ],
    );
  }
}

class _LinkButton {
  const _LinkButton({required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;
}
