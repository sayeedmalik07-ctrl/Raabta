import 'package:flutter/material.dart';

import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/glass/glass_card.dart';
import 'package:raabta/core/glass/glass_container.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/core/l10n/app_shell_strings.dart';
import 'package:raabta/core/widgets/glass_primary_button.dart';

import 'score_ring_painter.dart';

const _kRingDiameter = 140.0;
const _kRingStrokeWidth = 16.0;

/// Category breakdown item for the hero expat score card.
class ScoreCategory {
  const ScoreCategory({
    required this.title,
    required this.icon,
    required this.score,
    required this.color,
  });

  final String title;
  final IconData icon;
  final double score;
  final Color color;
}

/// Premium hero card summarizing the user's Expat Score — presentation only.
class HeroExpatScoreCard extends StatefulWidget {
  const HeroExpatScoreCard({
    super.key,
    required this.score,
    this.title = 'Your Expat Score',
    this.subtitle = 'Updated today',
    this.insight = "You're doing great. Keep building your profile.",
    this.categories,
    this.onTap,
    this.profileBuildingMode = false,
    this.isLoading = false,
    this.buildProfileLabel,
    this.onBuildProfile,
    this.levelLabel,
    this.statusLabel,
    this.onViewDetails,
    this.locale = 'English',
    this.viewDetailsLabel,
  });

  final double score;
  final String title;
  final String subtitle;
  final String insight;
  final List<ScoreCategory>? categories;
  final VoidCallback? onTap;
  /// When true, shows a friendly onboarding state instead of a low-score warning.
  final bool profileBuildingMode;
  final bool isLoading;
  final String? buildProfileLabel;
  final VoidCallback? onBuildProfile;
  final String? levelLabel;
  /// Live status under the ring (e.g. "Growing Strong ↗") — overrides score bands.
  final String? statusLabel;
  final VoidCallback? onViewDetails;
  final String locale;
  final String? viewDetailsLabel;

  @override
  State<HeroExpatScoreCard> createState() => _HeroExpatScoreCardState();
}

class _HeroExpatScoreCardState extends State<HeroExpatScoreCard>
    with TickerProviderStateMixin {
  late final AnimationController _scoreController;
  late final AnimationController _glowController;
  late final AnimationController _barsController;
  late Animation<double> _animatedScore;
  late Animation<double> _glowPulse;
  late Animation<double> _barsProgress;

  @override
  void initState() {
    super.initState();
    _scoreController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat(reverse: true);
    _glowPulse = Tween<double>(begin: 0.35, end: 1.0).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );
    _barsController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _barsProgress = CurvedAnimation(
      parent: _barsController,
      curve: Curves.easeOutCubic,
    );
    _setupScoreAnimation(begin: 0, end: widget.score.clamp(0, 100));
    _scoreController.forward();
    _barsController.forward();
  }

  void _setupScoreAnimation({required double begin, required double end}) {
    _animatedScore = Tween<double>(begin: begin, end: end).animate(
      CurvedAnimation(
        parent: _scoreController,
        curve: Curves.easeOutCubic,
      ),
    );
  }

  @override
  void didUpdateWidget(covariant HeroExpatScoreCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.score != widget.score) {
      final current = _animatedScore.value;
      _scoreController.reset();
      _setupScoreAnimation(
        begin: current,
        end: widget.score.clamp(0, 100),
      );
      _scoreController.forward();
    }
    if (oldWidget.categories != widget.categories) {
      _barsController.reset();
      _barsController.forward();
    }
  }

  @override
  void dispose() {
    _scoreController.dispose();
    _glowController.dispose();
    _barsController.dispose();
    super.dispose();
  }

  double get _clampedScore => widget.score.clamp(0, 100);

  List<ScoreCategory> get _displayCategories =>
      widget.categories ?? const [];

  _ScoreStatus _statusForScore(double score) {
    final locale = widget.locale;
    if (score >= 90) {
      return _ScoreStatus(
        label: AppShellStrings.t('score_band_outstanding', locale),
        color: AppColors.emeraldGlow,
        summary: AppShellStrings.t('home_score_summary_high', locale),
      );
    }
    if (score >= 75) {
      return _ScoreStatus(
        label: AppShellStrings.t('score_band_excellent', locale),
        color: AppColors.cyanGlow,
        summary: AppShellStrings.t('home_score_summary_high', locale),
      );
    }
    if (score >= 60) {
      return _ScoreStatus(
        label: AppShellStrings.t('score_band_good', locale),
        color: AppColors.blueGlow,
        summary: AppShellStrings.t('home_score_summary_mid', locale),
      );
    }
    if (score >= 40) {
      return _ScoreStatus(
        label: AppShellStrings.t('score_band_needs_attention', locale),
        color: AppColors.amberGlow,
        summary: AppShellStrings.t('home_score_summary_mid', locale),
      );
    }
    return _ScoreStatus(
      label: AppShellStrings.t('score_band_critical', locale),
      color: AppColors.roseGlow,
      summary: AppShellStrings.t('home_score_summary_low', locale),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ringStatus = widget.profileBuildingMode
        ? _ScoreStatus(
            label: widget.statusLabel ?? 'Get Started',
            color: AppColors.cyanGlow,
            summary:
                'Complete your profile to unlock your personalized Expat Score.',
          )
        : widget.statusLabel != null
            ? _ScoreStatus(
                label: widget.statusLabel!,
                color: _statusColorForScore(_clampedScore),
                summary: _summaryForLoadedScore(_clampedScore),
              )
            : _statusForScore(_clampedScore);

    return GlassCard(
      onTap: widget.onTap,
      padding: const EdgeInsets.all(AppSpacing.cardPadding),
      glowColor: ringStatus.color,
      glowIntensity: 0.1,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _Header(
            title: widget.title,
            subtitle: widget.isLoading
                ? AppShellStrings.t('home_calculating', widget.locale)
                : widget.subtitle,
            onViewDetails: widget.onViewDetails,
            viewDetailsLabel: widget.viewDetailsLabel ??
                AppShellStrings.t('home_view_details', widget.locale),
          ),
          const SizedBox(height: AppSpacing.lg),
          AnimatedBuilder(
            animation: Listenable.merge(
              [_animatedScore, _glowPulse, _barsProgress],
            ),
            builder: (context, _) {
              final animatedValue = _animatedScore.value;
              return Column(
                children: [
                  _ScoreRingSection(
                    animatedScore: animatedValue,
                    statusLabel: ringStatus.label,
                    statusColor: ringStatus.color,
                    glowPulse: _glowPulse.value,
                    showPlaceholder:
                        widget.profileBuildingMode && _clampedScore <= 0,
                  ),
                  if (_displayCategories.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.lg),
                    _CategoryBars(
                      categories: _displayCategories,
                      progress: _barsProgress.value,
                    ),
                  ],
                ],
              );
            },
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            widget.profileBuildingMode ? widget.insight : ringStatus.summary,
            style: AppTypography.body,
            textAlign: TextAlign.center,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          _InsightSection(
            insight: widget.profileBuildingMode
                ? AppShellStrings.t('home_score_building_hint', widget.locale)
                : widget.insight,
            actionLabel: widget.buildProfileLabel,
            onAction: widget.onBuildProfile,
          ),
        ],
      ),
    );
  }

  Color _statusColorForScore(double score) {
    if (score >= 75) return AppColors.cyanGlow;
    if (score >= 60) return AppColors.blueGlow;
    if (score >= 40) return AppColors.amberGlow;
    return AppColors.roseGlow;
  }

  String _summaryForLoadedScore(double score) {
    if (score >= 75) {
      return AppShellStrings.t('home_score_summary_high', widget.locale);
    }
    if (score >= 40) {
      return AppShellStrings.t('home_score_summary_mid', widget.locale);
    }
    return AppShellStrings.t('home_score_summary_low', widget.locale);
  }
}

class _ScoreStatus {
  const _ScoreStatus({
    required this.label,
    required this.color,
    required this.summary,
  });

  final String label;
  final Color color;
  final String summary;
}

class _Header extends StatelessWidget {
  const _Header({
    required this.title,
    required this.subtitle,
    this.onViewDetails,
    required this.viewDetailsLabel,
  });

  final String title;
  final String subtitle;
  final VoidCallback? onViewDetails;
  final String viewDetailsLabel;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: AppTypography.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (onViewDetails != null)
          GestureDetector(
            onTap: onViewDetails,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.xs,
                vertical: AppSpacing.xxs,
              ),
              child: Text(
                viewDetailsLabel,
                style: AppTypography.link.copyWith(
                  fontSize: 13,
                  color: AppColors.link,
                ),
              ),
            ),
          )
        else
          GlassContainer(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: AppSpacing.xs,
            ),
            borderRadius: AppSpacing.radiusFull,
            child: Text(
              subtitle,
              style: AppTypography.caption.copyWith(color: AppColors.cyanGlow),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
      ],
    );
  }
}

class _ScoreRingSection extends StatelessWidget {
  const _ScoreRingSection({
    required this.animatedScore,
    required this.statusLabel,
    required this.statusColor,
    required this.glowPulse,
    this.showPlaceholder = false,
  });

  final double animatedScore;
  final String statusLabel;
  final Color statusColor;
  final double glowPulse;
  final bool showPlaceholder;

  @override
  Widget build(BuildContext context) {
    final displayScore = animatedScore.round();
    final progress = animatedScore / 100;

    return Center(
      child: SizedBox(
        width: _kRingDiameter + 24,
        height: _kRingDiameter + 24,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Transform.scale(
              scale: 0.92 + glowPulse * 0.08,
              child: Container(
                width: _kRingDiameter,
                height: _kRingDiameter,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: statusColor.withValues(alpha: 0.12 + glowPulse * 0.28),
                      blurRadius: 18 + glowPulse * 22,
                      spreadRadius: 2 + glowPulse * 4,
                    ),
                  ],
                ),
              ),
            ),
            RepaintBoundary(
              child: CustomPaint(
                size: const Size(_kRingDiameter, _kRingDiameter),
                painter: ScoreRingPainter(
                  progress: progress,
                  strokeWidth: _kRingStrokeWidth,
                  ambientGlow: glowPulse,
                  glowColor: statusColor,
                ),
              ),
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (showPlaceholder)
                  Icon(
                    Icons.person_add_alt_1_rounded,
                    color: statusColor,
                    size: 40,
                  )
                else
                  Text(
                    '$displayScore',
                    style: AppTypography.display.copyWith(fontSize: 48),
                    textAlign: TextAlign.center,
                  ),
                if (!showPlaceholder)
                  Text(
                    '/100',
                    style: AppTypography.tabular(AppTypography.caption),
                    textAlign: TextAlign.center,
                  ),
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  statusLabel,
                  style: AppTypography.subtitle.copyWith(color: statusColor),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryBars extends StatelessWidget {
  const _CategoryBars({
    required this.categories,
    required this.progress,
  });

  final List<ScoreCategory> categories;
  final double progress;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (final category in categories) ...[
          _CategoryBarRow(category: category, progress: progress),
          const SizedBox(height: AppSpacing.sm),
        ],
      ],
    );
  }
}

class _CategoryBarRow extends StatelessWidget {
  const _CategoryBarRow({
    required this.category,
    required this.progress,
  });

  final ScoreCategory category;
  final double progress;

  @override
  Widget build(BuildContext context) {
    final pct = (category.score.clamp(0, 100) * progress).round();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(category.icon, size: 14, color: category.color),
            const SizedBox(width: AppSpacing.xs),
            Expanded(
              child: Text(
                category.title,
                style: AppTypography.caption.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Text(
              '$pct%',
              style: AppTypography.tabular(
                AppTypography.caption.copyWith(color: category.color),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xxs),
        ClipRRect(
          borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
          child: LinearProgressIndicator(
            value: pct / 100,
            minHeight: 6,
            backgroundColor: AppColors.glassBorder,
            valueColor: AlwaysStoppedAnimation<Color>(category.color),
          ),
        ),
      ],
    );
  }
}

class _InsightSection extends StatelessWidget {
  const _InsightSection({
    required this.insight,
    this.actionLabel,
    this.onAction,
  });

  final String insight;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.md),
      child: GlassContainer(
        padding: const EdgeInsets.all(AppSpacing.md),
        borderRadius: AppSpacing.radiusSm,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.auto_awesome_rounded,
                  color: AppColors.cyanGlow,
                  size: AppSpacing.iconMd,
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    insight,
                    style: AppTypography.bodySmall,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: AppSpacing.md),
              GlassPrimaryButton(
                label: actionLabel!,
                expand: true,
                icon: Icons.edit_rounded,
                accentColor: AppColors.cyanGlow,
                onPressed: onAction,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
