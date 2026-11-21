import 'package:flutter/material.dart';

import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/design/raabta_solid_surface_tokens.dart';
import 'package:raabta/core/glass/glass_card.dart';
import 'package:raabta/core/l10n/app_shell_strings.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/features/home/utils/home_expat_hero_presenter.dart';
import 'package:raabta/features/home/utils/home_today_focus_resolver.dart';
import 'package:raabta/features/home/widgets/home_brand_primary_button.dart';
import 'package:raabta/features/home/widgets/score_ring_painter.dart';

/// Design kit v2.1 Today hero — one adaptive card (radius 28, 64dp ring).
class HomeUnifiedTodayHero extends StatelessWidget {
  const HomeUnifiedTodayHero({
    super.key,
    required this.phase,
    required this.locale,
    required this.ringScore,
    required this.onOpenExpatScore,
    required this.onOpenBuildProfile,
    required this.focus,
    required this.onFocusPrimaryTap,
    this.onSignIn,
    this.statusLabel,
    this.setupSteps = const [],
    this.semanticsLabel,
  });

  static const heroRadius = 28.0;
  static const ringSize = 64.0;
  static const ringStroke = 5.0;

  final HomeExpatHeroPhase phase;
  final String locale;
  final double ringScore;
  final VoidCallback onOpenExpatScore;
  final VoidCallback onOpenBuildProfile;
  final TodayFocusContent focus;
  final VoidCallback onFocusPrimaryTap;
  final VoidCallback? onSignIn;
  final String? statusLabel;
  final List<TodayHeroSetupStep> setupSteps;
  final String? semanticsLabel;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      label: semanticsLabel,
      child: GlassCard(
        borderRadius: heroRadius,
        glowIntensity: 0,
        solidSurfaceFamily: RaabtaSolidSurfaceFamily.brand,
        padding: const EdgeInsets.all(AppSpacing.cardPadding),
        child: switch (phase) {
          HomeExpatHeroPhase.guest => _GuestBody(
              locale: locale,
              onSignIn: onSignIn ?? () {},
            ),
          HomeExpatHeroPhase.loading => _LoadingBody(locale: locale),
          HomeExpatHeroPhase.setup => _SetupBody(
              locale: locale,
              ringScore: ringScore,
              setupSteps: setupSteps,
              onFinishSetup: onOpenBuildProfile,
            ),
          HomeExpatHeroPhase.populated => _PopulatedBody(
              locale: locale,
              ringScore: ringScore,
              focus: focus,
              onPrimaryTap: onFocusPrimaryTap,
              onViewScore: onOpenExpatScore,
            ),
        },
      ),
    );
  }
}

class _TodayHeroHeader extends StatelessWidget {
  const _TodayHeroHeader({required this.locale, required this.estimatedTime});

  final String locale;
  final String estimatedTime;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _TodayTag(label: AppShellStrings.t('home_today', locale)),
        const Spacer(),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.schedule_rounded,
              size: AppSpacing.iconXs,
              color: AppColors.textOnGlassMuted,
            ),
            const SizedBox(width: AppSpacing.xxs),
            Text(
              estimatedTime,
              style: AppTypography.caption.copyWith(
                color: AppColors.textOnGlassMuted,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _TodayTag extends StatelessWidget {
  const _TodayTag({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xxs,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
        border: Border.all(
          color: AppColors.brandFamilyMain.withValues(alpha: 0.35),
        ),
        color: AppColors.brandFamilyMain.withValues(alpha: 0.1),
      ),
      child: Text(
        label,
        style: AppTypography.caption.copyWith(
          color: AppColors.brandFamilyText,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _TodayHeroRing extends StatelessWidget {
  const _TodayHeroRing({
    required this.value,
    required this.showPercentSuffix,
    this.isLoading = false,
  });

  final double value;
  final bool showPercentSuffix;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final clamped = value.clamp(0, 100);
    final progress = clamped / 100;
    final innerSize =
        HomeUnifiedTodayHero.ringSize - HomeUnifiedTodayHero.ringStroke * 2 - 4;

    return SizedBox(
      width: HomeUnifiedTodayHero.ringSize,
      height: HomeUnifiedTodayHero.ringSize,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: const Size(
              HomeUnifiedTodayHero.ringSize,
              HomeUnifiedTodayHero.ringSize,
            ),
            painter: ScoreRingPainter(
              progress: progress,
              strokeWidth: HomeUnifiedTodayHero.ringStroke,
              glowColor: AppColors.brandFamilyMain,
            ),
          ),
          Container(
            width: innerSize,
            height: innerSize,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.surface.withValues(alpha: 0.92),
            ),
            alignment: Alignment.center,
            child: isLoading
                ? SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.brandFamilyMain,
                    ),
                  )
                : Text(
                    showPercentSuffix
                        ? '${clamped.round()}%'
                        : '${clamped.round()}',
                    style: AppTypography.headline2.copyWith(
                      fontSize: showPercentSuffix ? 16 : 18,
                      height: 1,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _GuestBody extends StatelessWidget {
  const _GuestBody({
    required this.locale,
    required this.onSignIn,
  });

  final String locale;
  final VoidCallback onSignIn;

  static const _chipKeys = [
    'home_hero_guest_chip_deadlines',
    'home_hero_guest_chip_rights',
    'home_hero_guest_chip_picks',
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _TodayHeroHeader(locale: locale, estimatedTime: '1 min'),
        const SizedBox(height: AppSpacing.md),
        Text(
          AppShellStrings.t('home_hero_guest_title', locale),
          style: AppTypography.title.copyWith(fontSize: 17),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: AppSpacing.xxs),
        Text(
          AppShellStrings.t('home_hero_guest_body', locale),
          style: AppTypography.bodySmall.copyWith(
            color: AppColors.textOnGlassMuted,
          ),
          maxLines: 3,
          softWrap: true,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: AppSpacing.sm),
        Wrap(
          spacing: AppSpacing.xs,
          runSpacing: AppSpacing.xs,
          children: [
            for (final key in _chipKeys)
              _GuestBenefitChip(
                label: AppShellStrings.t(key, locale),
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        HomeBrandPrimaryButton(
          label: AppShellStrings.t('home_hero_guest_sign_in', locale),
          onPressed: onSignIn,
        ),
      ],
    );
  }
}

class _GuestBenefitChip extends StatelessWidget {
  const _GuestBenefitChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: AppColors.brandFamilyMain.withValues(
          alpha: AppColors.isLight ? 0.1 : 0.16,
        ),
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        border: Border.all(
          color: AppColors.brandFamilyMain.withValues(alpha: 0.22),
        ),
      ),
      child: Text(
        label,
        style: AppTypography.caption.copyWith(
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}

class _LoadingBody extends StatelessWidget {
  const _LoadingBody({required this.locale});

  final String locale;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _TodayHeroHeader(locale: locale, estimatedTime: '—'),
        const SizedBox(height: AppSpacing.md),
        Row(
          children: [
            const _TodayHeroRing(
              value: 0,
              showPercentSuffix: false,
              isLoading: true,
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Text(
                AppShellStrings.t('home_calculating', locale),
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.textOnGlassMuted,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _SetupBody extends StatelessWidget {
  const _SetupBody({
    required this.locale,
    required this.ringScore,
    required this.setupSteps,
    required this.onFinishSetup,
  });

  final String locale;
  final double ringScore;
  final List<TodayHeroSetupStep> setupSteps;
  final VoidCallback onFinishSetup;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _TodayHeroHeader(locale: locale, estimatedTime: '1 min'),
        const SizedBox(height: AppSpacing.md),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _TodayHeroRing(value: ringScore, showPercentSuffix: true),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    HomeExpatHeroPresenter.setupHeroTitle(locale),
                    style: AppTypography.title.copyWith(fontSize: 17),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: AppSpacing.xxs),
                  Text(
                    HomeExpatHeroPresenter.setupHeroSubtitle(locale),
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textOnGlassMuted,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
        if (setupSteps.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              for (final step in setupSteps.take(3))
                _SetupStepChip(
                  label: step.label,
                  complete: step.complete,
                ),
            ],
          ),
        ],
        const SizedBox(height: AppSpacing.md),
        HomeBrandPrimaryButton(
          label: AppShellStrings.t('home_complete_profile', locale),
          onPressed: onFinishSetup,
        ),
      ],
    );
  }
}

class _SetupStepChip extends StatelessWidget {
  const _SetupStepChip({required this.label, required this.complete});

  final String label;
  final bool complete;

  @override
  Widget build(BuildContext context) {
    final color = complete
        ? AppColors.brandFamilyMain.withValues(alpha: 0.55)
        : AppColors.brandFamilyMain;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color),
        color: complete
            ? AppColors.brandFamilyMain.withValues(alpha: 0.08)
            : Colors.transparent,
      ),
      child: Text(
        label,
        style: AppTypography.caption.copyWith(
          color: complete
              ? AppColors.textOnGlassMuted
              : AppColors.brandFamilyText,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

class _PopulatedBody extends StatelessWidget {
  const _PopulatedBody({
    required this.locale,
    required this.ringScore,
    required this.focus,
    required this.onPrimaryTap,
    required this.onViewScore,
  });

  final String locale;
  final double ringScore;
  final TodayFocusContent focus;
  final VoidCallback onPrimaryTap;
  final VoidCallback onViewScore;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _TodayHeroHeader(
          locale: locale,
          estimatedTime: focus.estimatedTime,
        ),
        const SizedBox(height: AppSpacing.md),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    focus.title,
                    style: AppTypography.title.copyWith(fontSize: 17),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: AppSpacing.xxs),
                  Text(
                    focus.description,
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textOnGlassMuted,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            _TodayHeroRing(value: ringScore, showPercentSuffix: false),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        Row(
          children: [
            Expanded(
              child: HomeBrandPrimaryButton(
                label: focus.actionLabel,
                onPressed: onPrimaryTap,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: _BrandGhostButton(
                label: AppShellStrings.t('home_view_score', locale),
                onPressed: onViewScore,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _BrandGhostButton extends StatelessWidget {
  const _BrandGhostButton({required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(0, 44),
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
        side: BorderSide(color: AppColors.brandFamilyMain.withValues(alpha: 0.5)),
        foregroundColor: AppColors.brandFamilyText,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
        ),
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: AppTypography.button.copyWith(
          fontSize: 13,
          color: AppColors.brandFamilyText,
        ),
      ),
    );
  }
}
