import 'package:flutter/material.dart';

import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/glass/glass_card.dart';
import 'package:raabta/core/l10n/app_shell_strings.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';

import 'package:raabta/features/home/widgets/home_card_tiers.dart';

import 'score_ring_painter.dart';

const _kCompactRingDiameter = 60.0;
const _kCompactStrokeWidth = 6.0;
const _kCompactScoreFontSize = 20.0;

/// Compact Home summary for Expat Score — detail lives on `/expat-score`.
class CompactExpatScoreCard extends StatelessWidget {
  const CompactExpatScoreCard({
    super.key,
    required this.score,
    required this.locale,
    required this.title,
    required this.subtitle,
    required this.insight,
    this.statusLabel,
    this.profileBuildingMode = false,
    this.isLoading = false,
    this.buildProfileLabel,
    this.onBuildProfile,
    this.onTap,
    this.onViewDetails,
    this.semanticsLabel,
  });

  final double score;
  final String locale;
  final String title;
  final String subtitle;
  final String insight;
  final String? statusLabel;
  final bool profileBuildingMode;
  final bool isLoading;
  final String? buildProfileLabel;
  final VoidCallback? onBuildProfile;
  final VoidCallback? onTap;
  final VoidCallback? onViewDetails;
  final String? semanticsLabel;

  double get _clampedScore => score.clamp(0, 100);

  Color _statusColorForScore(double value) {
    if (value >= 75) return AppColors.cyanGlow;
    if (value >= 60) return AppColors.blueGlow;
    if (value >= 40) return AppColors.amberGlow;
    return AppColors.roseGlow;
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = profileBuildingMode
        ? AppColors.cyanGlow
        : _statusColorForScore(_clampedScore);
    final showPlaceholder =
        isLoading || (profileBuildingMode && _clampedScore <= 0);
    final viewDetailsLabel =
        AppShellStrings.t('home_view_details', locale);
    final hasProfileCta =
        buildProfileLabel != null && onBuildProfile != null;
    final statusText = isLoading
        ? AppShellStrings.t('home_calculating', locale)
        : statusLabel ?? subtitle;

    final mainRow = Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        ExcludeSemantics(
          child: _CompactScoreRing(
            score: _clampedScore,
            statusColor: statusColor,
            showPlaceholder: showPlaceholder,
            isLoading: isLoading,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: ExcludeSemantics(
                      child: Text(
                        title,
                        style: AppTypography.title.copyWith(fontSize: 15),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  if (onViewDetails != null)
                    Flexible(
                      child: GestureDetector(
                        onTap: onViewDetails,
                        child: Padding(
                          padding: const EdgeInsetsDirectional.only(
                            start: AppSpacing.xs,
                          ),
                          child: Text(
                            viewDetailsLabel,
                            style: AppTypography.link.copyWith(
                              fontSize: 12,
                              color: AppColors.link,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.end,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: AppSpacing.xxs),
              ExcludeSemantics(
                child: Text(
                  statusText,
                  style: AppTypography.bodySmall.copyWith(
                    color: statusColor,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(height: AppSpacing.xxs),
              ExcludeSemantics(
                child: Text(
                  insight,
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textOnGlassMuted,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ],
    );

    final card = GlassCard(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      borderRadius: HomeCardTier.homeCardRadius,
      glowColor: statusColor,
      glowIntensity: HomeCardTier.expatScoreGlowIntensity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (hasProfileCta && semanticsLabel != null)
            Semantics(
              button: onTap != null,
              label: semanticsLabel,
              onTap: onTap,
              child: mainRow,
            )
          else
            mainRow,
          if (hasProfileCta) ...[
            const SizedBox(height: AppSpacing.xs),
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: TextButton(
                onPressed: onBuildProfile,
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: const Size(0, 48),
                  tapTargetSize: MaterialTapTargetSize.padded,
                ),
                child: Text(
                  buildProfileLabel!,
                  style: AppTypography.link.copyWith(color: AppColors.cyanGlow),
                ),
              ),
            ),
          ],
        ],
      ),
    );

    if (semanticsLabel == null) return card;

    if (hasProfileCta) {
      return Semantics(
        explicitChildNodes: true,
        child: card,
      );
    }

    return Semantics(
      button: onTap != null,
      label: semanticsLabel,
      child: card,
    );
  }
}

class _CompactScoreRing extends StatelessWidget {
  const _CompactScoreRing({
    required this.score,
    required this.statusColor,
    required this.showPlaceholder,
    required this.isLoading,
  });

  final double score;
  final Color statusColor;
  final bool showPlaceholder;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final displayScore = score.round();
    final progress = score / 100;

    return SizedBox(
      width: _kCompactRingDiameter,
      height: _kCompactRingDiameter,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: const Size(_kCompactRingDiameter, _kCompactRingDiameter),
            painter: ScoreRingPainter(
              progress: progress,
              strokeWidth: _kCompactStrokeWidth,
              glowColor: statusColor,
            ),
          ),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: showPlaceholder
                ? (isLoading
                    ? SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: statusColor,
                        ),
                      )
                    : Icon(
                        Icons.person_add_alt_1_rounded,
                        color: statusColor,
                        size: 22,
                      ))
                : Text(
                    '$displayScore',
                    style: AppTypography.headline2.copyWith(
                      fontSize: _kCompactScoreFontSize,
                      height: 1,
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
