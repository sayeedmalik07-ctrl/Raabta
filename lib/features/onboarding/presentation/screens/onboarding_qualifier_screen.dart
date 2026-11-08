import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/glass/glass_container.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/core/widgets/animated_background.dart';
import 'package:raabta/core/glass/glass_card.dart';
import 'package:raabta/core/widgets/glass_primary_button.dart';
import 'package:raabta/core/widgets/glass_screen_scaffold.dart';
import 'package:raabta/features/eosb/domain/models/eosb_enums.dart';
import 'package:raabta/features/onboarding/l10n/onboarding_strings.dart';
import 'package:raabta/features/onboarding/providers/onboarding_providers.dart';
import 'package:raabta/features/onboarding/services/onboarding_analytics_service.dart';
import 'package:raabta/providers/visa_providers.dart';

class OnboardingQualifierScreen extends ConsumerWidget {
  const OnboardingQualifierScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(userLanguageProvider);
    final qualifier = ref.watch(onboardingQualifierProvider);

    return AnimatedAuroraBackground(
      child: GlassScreenScaffold(
        safeArea: true,
        title: OnboardingStrings.t('qualifier_title', locale),
        leading: GlassIconButton(
          icon: Icons.arrow_back_ios_rounded,
          tooltip: 'Back',
          onPressed: () => context.pop(),
        ),
        padding: const EdgeInsets.all(AppSpacing.lg),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              OnboardingStrings.t('qualifier_contract', locale),
              style: AppTypography.subtitle,
            ),
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: [
                _ChoiceChip(
                  label: OnboardingStrings.t('contract_unlimited', locale),
                  selected: qualifier.contractType == EosbContractType.unlimited,
                  onSelected: () {
                    ref.read(onboardingQualifierProvider.notifier).state =
                        qualifier.copyWith(
                      contractType: EosbContractType.unlimited,
                    );
                    OnboardingAnalyticsService.funnelQ1Answered('unlimited');
                  },
                ),
                _ChoiceChip(
                  label: OnboardingStrings.t('contract_limited', locale),
                  selected: qualifier.contractType == EosbContractType.limited,
                  onSelected: () {
                    ref.read(onboardingQualifierProvider.notifier).state =
                        qualifier.copyWith(
                      contractType: EosbContractType.limited,
                    );
                    OnboardingAnalyticsService.funnelQ1Answered('limited');
                  },
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xl),
            Text(
              OnboardingStrings.t('qualifier_years', locale),
              style: AppTypography.subtitle,
            ),
            const SizedBox(height: AppSpacing.sm),
            GlassContainer(
              padding: const EdgeInsets.all(AppSpacing.md),
              borderRadius: AppSpacing.radiusSm,
              child: Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: [
                  for (final band in OnboardingYearsBand.values)
                    _ChoiceChip(
                      label: band.label,
                      selected: qualifier.yearsBand == band,
                      onSelected: () {
                        ref.read(onboardingQualifierProvider.notifier).state =
                            qualifier.copyWith(yearsBand: band);
                        OnboardingAnalyticsService.funnelQ2Answered(band.name);
                      },
                    ),
                ],
              ),
            ),
            const Spacer(),
            GlassPrimaryButton(
              label: OnboardingStrings.t('qualifier_continue', locale),
              expand: true,
              onPressed: () {
                OnboardingAnalyticsService.funnelQ1Answered(
                  qualifier.contractType.name,
                );
                OnboardingAnalyticsService.funnelQ2Answered(
                  qualifier.yearsBand.name,
                );
                context.push('/eosb/employee-info?fromOnboarding=1');
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _ChoiceChip extends StatelessWidget {
  const _ChoiceChip({
    required this.label,
    required this.selected,
    required this.onSelected,
  });

  final String label;
  final bool selected;
  final VoidCallback onSelected;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      onTap: onSelected,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      borderRadius: AppSpacing.radiusFull,
      glowColor: selected ? AppColors.cyanGlow : null,
      glowIntensity: selected ? 0.18 : 0,
      child: Text(
        label,
        style: AppTypography.chipLabel.copyWith(
          color: selected ? AppColors.cyanGlow : AppColors.textSecondary,
          fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
        ),
      ),
    );
  }
}
