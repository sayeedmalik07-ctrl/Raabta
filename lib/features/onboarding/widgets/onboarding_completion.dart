import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/glass/glass_container.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/features/onboarding/l10n/onboarding_strings.dart';
import 'package:raabta/features/onboarding/services/onboarding_analytics_service.dart';
import 'package:raabta/features/onboarding/services/onboarding_service.dart';
import 'package:raabta/services/referral/referral_service.dart';

/// One-time sheet after onboarding EOSB result — then routes to home.
Future<void> showOnboardingCompleteSheet(
  BuildContext context, {
  required String locale,
}) async {
  await showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (ctx) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          0,
          AppSpacing.lg,
          AppSpacing.xl,
        ),
        child: GlassContainer(
          padding: const EdgeInsets.all(AppSpacing.lg),
          borderRadius: AppSpacing.radiusLg,
          glowColor: AppColors.cyanGlow,
          glowIntensity: 0.12,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                OnboardingStrings.t('complete_sheet_title', locale),
                style: AppTypography.headline2,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                OnboardingStrings.t('complete_sheet_body', locale),
                style: AppTypography.body,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.lg),
              FilledButton(
                onPressed: () {
                  Navigator.of(ctx).pop();
                  context.go('/home');
                },
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.cyanGlow,
                  foregroundColor: AppColors.background,
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                ),
                child: Text(
                  OnboardingStrings.t('complete_sheet_cta', locale),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

Future<void> completeOnboardingSkipped(BuildContext context) async {
  OnboardingAnalyticsService.funnelSkipped();
  await OnboardingService.instance.markCompleted();
  if (context.mounted) context.go('/home');
}

Future<void> completeOnboardingWithEstimate(
  BuildContext context, {
  required String locale,
}) async {
  OnboardingAnalyticsService.funnelCompletedWithEstimate();
  final uid = FirebaseAuth.instance.currentUser?.uid;
  if (uid != null) {
    await ReferralService.instance.tryGrantRewardsOnFirstEstimate(uid);
  }
  await OnboardingService.instance.markCompleted();
  if (!context.mounted) return;
  await showOnboardingCompleteSheet(context, locale: locale);
}
