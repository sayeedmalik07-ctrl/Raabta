import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/glass/glass_container.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/core/widgets/animated_background.dart';
import 'package:raabta/core/widgets/glass_primary_button.dart';
import 'package:raabta/core/widgets/raabta_platform_notices_panel.dart';
import 'package:raabta/features/onboarding/l10n/onboarding_strings.dart';
import 'package:raabta/features/onboarding/providers/onboarding_providers.dart';
import 'package:raabta/features/onboarding/services/onboarding_analytics_service.dart';
import 'package:raabta/features/onboarding/widgets/onboarding_completion.dart';
import 'package:raabta/providers/visa_providers.dart';

class OnboardingWelcomeScreen extends ConsumerStatefulWidget {
  const OnboardingWelcomeScreen({super.key});

  @override
  ConsumerState<OnboardingWelcomeScreen> createState() =>
      _OnboardingWelcomeScreenState();
}

class _OnboardingWelcomeScreenState
    extends ConsumerState<OnboardingWelcomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(onboardingActiveProvider.notifier).state = true;
      OnboardingAnalyticsService.funnelStarted();
    });
  }

  @override
  Widget build(BuildContext context) {
    final locale = ref.watch(userLanguageProvider);

    return AnimatedAuroraBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Spacer(flex: 2),
                GlassContainer(
                  padding: const EdgeInsets.all(AppSpacing.xl),
                  borderRadius: AppSpacing.radiusXl,
                  glowColor: AppColors.cyanGlow,
                  glowIntensity: 0.1,
                  child: Column(
                    children: [
                      const Text('⚖️', style: TextStyle(fontSize: 48)),
                      const SizedBox(height: AppSpacing.lg),
                      Text(
                        OnboardingStrings.t('welcome_headline', locale),
                        style: AppTypography.headline1.copyWith(fontSize: 26),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        OnboardingStrings.t('welcome_subline', locale),
                        style: AppTypography.body.copyWith(height: 1.5),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                const Spacer(flex: 2),
                RaabtaPlatformNoticesPanel(locale: locale, dense: true),
                const Spacer(flex: 1),
                GlassPrimaryButton(
                  label: OnboardingStrings.t('welcome_cta', locale),
                  expand: true,
                  icon: Icons.arrow_forward_rounded,
                  onPressed: () => context.push('/onboarding/qualifier'),
                ),
                const SizedBox(height: AppSpacing.md),
                TextButton(
                  onPressed: () => completeOnboardingSkipped(context),
                  child: Text(
                    OnboardingStrings.t('welcome_skip', locale),
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
