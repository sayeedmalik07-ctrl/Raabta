import 'package:flutter/material.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/glass/glass_card.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/features/eosb/presentation/l10n/eosb_strings.dart';

/// Informational transition-awareness notes shown near the EOSB entitlement
/// amount — does not alter calculation logic.
class EosbTransitionAwarenessSection extends StatelessWidget {
  const EosbTransitionAwarenessSection({super.key, required this.locale});

  final String locale;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _AwarenessCard(
          icon: Icons.account_balance_outlined,
          accent: AppColors.accentGold,
          titleKey: 'eosb_transition_bank_title',
          bodyKey: 'eosb_transition_bank_body',
          locale: locale,
        ),
        const SizedBox(height: AppSpacing.md),
        _AwarenessCard(
          icon: Icons.health_and_safety_outlined,
          accent: AppColors.info,
          titleKey: 'eosb_transition_health_title',
          bodyKey: 'eosb_transition_health_body',
          locale: locale,
        ),
      ],
    );
  }
}

class _AwarenessCard extends StatelessWidget {
  const _AwarenessCard({
    required this.icon,
    required this.accent,
    required this.titleKey,
    required this.bodyKey,
    required this.locale,
  });

  final IconData icon;
  final Color accent;
  final String titleKey;
  final String bodyKey;
  final String locale;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      glowColor: accent,
      glowIntensity: 0.14,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: accent, size: 20),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  EosbStrings.t(titleKey, locale),
                  style: AppTypography.subtitle.copyWith(
                    color: accent,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            EosbStrings.t(bodyKey, locale),
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textSecondary,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }
}
