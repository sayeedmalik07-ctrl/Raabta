import 'package:flutter/material.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/glass/glass_card.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/features/financial_wellness/domain/ewa_awareness_constants.dart';
import 'package:raabta/features/home/widgets/home_icon_badge.dart';
import 'package:raabta/screens/money/widgets/money_hub_primitives.dart';
import 'package:url_launcher/url_launcher.dart';

/// Informational EWA awareness card for Money Hub — no in-app product, no data collection.
class EwaAwarenessCard extends StatelessWidget {
  const EwaAwarenessCard({super.key});

  Future<void> _openExternal(BuildContext context, String url) async {
    moneyHubSelectionHaptic();
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open link')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      glowColor: AppColors.emeraldGlow,
      glowIntensity: 0.1,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const HomeIconBadge(
                icon: Icons.payments_outlined,
                accentColor: AppColors.emeraldGlow,
                size: 40,
                iconSize: 20,
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      EwaAwarenessConstants.title,
                      style: AppTypography.title.copyWith(
                        color: AppColors.emeraldGlow,
                      ),
                    ),
                    Text(
                      EwaAwarenessConstants.subtitle,
                      style: AppTypography.caption.copyWith(
                        color: AppColors.textOnGlassMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            EwaAwarenessConstants.explanation,
            style: AppTypography.bodySmall,
          ),
          const SizedBox(height: AppSpacing.md),
          _EmployerGateCallout(),
          const SizedBox(height: AppSpacing.md),
          Text(
            EwaAwarenessConstants.providersIntro,
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textOnGlassMuted,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          ...EwaAwarenessConstants.providers.map(
            (provider) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: _ProviderBlock(
                provider: provider,
                onRefer: () => _openExternal(context, provider.referEmployerUrl),
                onLearnMore: () => _openExternal(context, provider.learnMoreUrl),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            EwaAwarenessConstants.disclaimer,
            style: AppTypography.caption.copyWith(
              color: AppColors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmployerGateCallout extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.warning.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: AppColors.warning.withValues(alpha: 0.35)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.business_center_outlined,
              color: AppColors.warning, size: 20),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  EwaAwarenessConstants.employerGateTitle,
                  style: AppTypography.subtitle.copyWith(
                    color: AppColors.warning,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  EwaAwarenessConstants.employerGateBody,
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.warning,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProviderBlock extends StatelessWidget {
  const _ProviderBlock({
    required this.provider,
    required this.onRefer,
    required this.onLearnMore,
  });

  final EwaProviderReference provider;
  final VoidCallback onRefer;
  final VoidCallback onLearnMore;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: AppColors.glassBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(provider.name, style: AppTypography.subtitle),
          const SizedBox(height: AppSpacing.xxs),
          Text(provider.summary, style: AppTypography.bodySmall),
          const SizedBox(height: AppSpacing.sm),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: onRefer,
              icon: const Icon(Icons.corporate_fare_outlined, size: 18),
              label: Text(provider.referEmployerLabel),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.emeraldGlow.withValues(alpha: 0.85),
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: onLearnMore,
              icon: const Icon(Icons.open_in_new, size: 16),
              label: Text(EwaAwarenessConstants.learnMoreLabel),
            ),
          ),
        ],
      ),
    );
  }
}
