import 'package:flutter/material.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/glass/glass_card.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/features/home/domain/truth_chip_status.dart';
import 'package:raabta/features/home/l10n/home_truth_chip_ui_strings.dart';
import 'package:raabta/features/home/widgets/home_card_tiers.dart';
import 'package:raabta/features/home/widgets/home_icon_badge.dart';

/// Truth Engine Home chip — kit anatomy (pill, progress, footer, invite Start).
class HomeTruthChipCard extends StatelessWidget {
  const HomeTruthChipCard({
    super.key,
    required this.icon,
    required this.title,
    required this.accentColor,
    required this.surfaceGlowColor,
    required this.onTap,
    required this.rowHeight,
    required this.status,
    required this.locale,
    required this.detailsRevealed,
    this.expand = false,
    this.cardWidth = 176,
    this.glowIntensity = HomeCardTier.toolGlowIntensity,
    this.titleFontSize = HomeCardTier.toolTitleFontSize,
    this.iconBadgeSize = HomeCardTier.compactIconBadgeSize,
    this.iconBadgeVariant = HomeIconBadgeVariant.goldBrand,
  });

  final IconData icon;
  final String title;
  final Color accentColor;
  final Color surfaceGlowColor;
  final VoidCallback onTap;
  final double rowHeight;
  final double cardWidth;
  final bool expand;
  final double glowIntensity;
  final double titleFontSize;
  final double iconBadgeSize;
  final HomeIconBadgeVariant iconBadgeVariant;
  final TruthChipStatus status;
  final String locale;
  final bool detailsRevealed;

  @visibleForTesting
  static String accessibilityLabel({
    required String title,
    required TruthChipStatus status,
    required bool detailsRevealed,
  }) {
    if (status.isLoading) return title;
    if (status.isUnavailable) {
      return '$title, ${status.statusText}';
    }
    final parts = <String>[title];
    if (status.showsPill && status.pillText != null) {
      parts.add(status.pillText!);
    }
    if (status.isInvite) {
      parts.add(status.statusText);
      return parts.join(', ');
    }
    final statusLine = _statusLineForSemantics(status, detailsRevealed);
    if (statusLine.isNotEmpty) parts.add(statusLine);
    if (status.showsProgressBar) {
      parts.add('${(status.progress!.clamp(0.0, 1.0) * 100).round()}%');
    }
    if (status.freshnessText.trim().isNotEmpty) {
      parts.add(status.freshnessText);
    }
    return parts.join(', ');
  }

  static String _statusLineForSemantics(
    TruthChipStatus status,
    bool detailsRevealed,
  ) {
    if (detailsRevealed &&
        status.hasRevealableDetail &&
        status.revealedText != null) {
      return status.revealedText!.trim();
    }
    return status.statusText.trim();
  }

  @override
  Widget build(BuildContext context) {
    final semanticsLabel = accessibilityLabel(
      title: title,
      status: status,
      detailsRevealed: detailsRevealed,
    );
    final reduceMotion = MediaQuery.disableAnimationsOf(context);

    final card = GlassCard(
      onTap: onTap,
      padding: const EdgeInsets.all(AppSpacing.md),
      borderRadius: HomeCardTier.homeCardRadius,
      glowColor: surfaceGlowColor,
      glowIntensity: glowIntensity,
      child: SizedBox.expand(
        child: status.isLoading
            ? _LoadingBody(
                icon: icon,
                title: title,
                accentColor: accentColor,
                titleFontSize: titleFontSize,
                iconBadgeSize: iconBadgeSize,
                iconBadgeVariant: iconBadgeVariant,
              )
            : _TruthChipBody(
                icon: icon,
                title: title,
                accentColor: accentColor,
                titleFontSize: titleFontSize,
                iconBadgeSize: iconBadgeSize,
                iconBadgeVariant: iconBadgeVariant,
                status: status,
                locale: locale,
                detailsRevealed: detailsRevealed,
                reduceMotion: reduceMotion,
              ),
      ),
    );

    final child = Semantics(
      button: true,
      label: semanticsLabel,
      child: expand
          ? SizedBox(height: rowHeight, child: card)
          : SizedBox(
              width: cardWidth,
              height: rowHeight,
              child: card,
            ),
    );

    return child;
  }
}

class _LoadingBody extends StatelessWidget {
  const _LoadingBody({
    required this.icon,
    required this.title,
    required this.accentColor,
    required this.titleFontSize,
    required this.iconBadgeSize,
    required this.iconBadgeVariant,
  });

  final IconData icon;
  final String title;
  final Color accentColor;
  final double titleFontSize;
  final double iconBadgeSize;
  final HomeIconBadgeVariant iconBadgeVariant;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        HomeIconBadge(
          icon: icon,
          accentColor: accentColor,
          size: iconBadgeSize,
          variant: iconBadgeVariant,
          chipBorderRadius: HomeCardTier.coreServiceIconChipRadius,
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          title,
          style: AppTypography.title.copyWith(
            fontSize: titleFontSize,
            color: AppColors.textPrimary,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const Spacer(),
        const SizedBox(height: 4),
      ],
    );
  }
}

class _TruthChipBody extends StatelessWidget {
  const _TruthChipBody({
    required this.icon,
    required this.title,
    required this.accentColor,
    required this.titleFontSize,
    required this.iconBadgeSize,
    required this.iconBadgeVariant,
    required this.status,
    required this.locale,
    required this.detailsRevealed,
    required this.reduceMotion,
  });

  final IconData icon;
  final String title;
  final Color accentColor;
  final double titleFontSize;
  final double iconBadgeSize;
  final HomeIconBadgeVariant iconBadgeVariant;
  final TruthChipStatus status;
  final String locale;
  final bool detailsRevealed;
  final bool reduceMotion;

  @override
  Widget build(BuildContext context) {
    final toneColor = _toneColor(status.tone);
    final showReveal = status.hasRevealableDetail;
    final revealed = detailsRevealed && showReveal;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            HomeIconBadge(
              icon: icon,
              accentColor: accentColor,
              size: iconBadgeSize,
              variant: iconBadgeVariant,
              chipBorderRadius: HomeCardTier.coreServiceIconChipRadius,
            ),
            const Spacer(),
            if (status.showsPill)
              Flexible(
                child: _StatusPill(
                  text: status.pillText!,
                  tone: status.tone,
                  pulse: !reduceMotion &&
                      (status.tone == TruthChipTone.amber ||
                          status.tone == TruthChipTone.red),
                ),
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          title,
          style: AppTypography.title.copyWith(
            fontSize: titleFontSize,
            color: AppColors.textPrimary,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 2),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (status.statusText.trim().isNotEmpty || status.hasRevealableDetail)
                Flexible(
                  child: _StatusLine(
                    status: status,
                    locale: locale,
                    revealed: revealed,
                    toneColor: toneColor,
                  ),
                ),
              const Spacer(),
              if (status.isInvite)
                Text(
                  HomeTruthChipUiStrings.t('truth_chip_start_cta', locale),
                  style: AppTypography.bodySmall.copyWith(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.goldFamilyText,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                )
              else ...[
                if (status.showsProgressBar)
                  _ProgressBar(
                    progress: status.progress!.clamp(0.0, 1.0),
                    tone: status.tone,
                  ),
                if (status.freshnessText.trim().isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    status.freshnessText,
                    style: AppTypography.caption.copyWith(
                      fontSize: 10.5,
                      height: 1.2,
                      color: AppColors.textOnGlassMuted,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ],
          ),
        ),
      ],
    );
  }

  static Color _toneColor(TruthChipTone tone) => switch (tone) {
        TruthChipTone.neutral => AppColors.textOnGlassMuted,
        TruthChipTone.ok => AppColors.success,
        TruthChipTone.amber => AppColors.warning,
        TruthChipTone.red => AppColors.error,
      };
}

class _StatusLine extends StatelessWidget {
  const _StatusLine({
    required this.status,
    required this.locale,
    required this.revealed,
    required this.toneColor,
  });

  final TruthChipStatus status;
  final String locale;
  final bool revealed;
  final Color toneColor;

  @override
  Widget build(BuildContext context) {
    final style = AppTypography.bodySmall.copyWith(
      fontSize: 12.5,
      fontWeight: FontWeight.w500,
      height: 1.3,
      color: toneColor,
    );

    if (revealed && status.revealedText != null) {
      return Text(
        status.revealedText!,
        style: style,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      );
    }

    final mask = HomeTruthChipUiStrings.t('truth_chip_masked_placeholder', locale);
    final showMask = status.hasRevealableDetail;
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(text: status.statusText),
          if (showMask)
            TextSpan(
              text: ' $mask',
              style: style.copyWith(letterSpacing: 1, color: toneColor.withValues(alpha: 0.7)),
            ),
        ],
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }
}

class _StatusPill extends StatefulWidget {
  const _StatusPill({
    required this.text,
    required this.tone,
    required this.pulse,
  });

  final String text;
  final TruthChipTone tone;
  final bool pulse;

  @override
  State<_StatusPill> createState() => _StatusPillState();
}

class _StatusPillState extends State<_StatusPill>
    with SingleTickerProviderStateMixin {
  AnimationController? _controller;

  @override
  void initState() {
    super.initState();
    if (widget.pulse) {
      _controller = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 1600),
      )..repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(covariant _StatusPill oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.pulse && _controller == null) {
      _controller = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 1600),
      )..repeat(reverse: true);
    } else if (!widget.pulse) {
      _controller?.dispose();
      _controller = null;
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Color get _color => switch (widget.tone) {
        TruthChipTone.neutral => AppColors.textOnGlassSecondary,
        TruthChipTone.ok => AppColors.success,
        TruthChipTone.amber => AppColors.warning,
        TruthChipTone.red => AppColors.error,
      };

  @override
  Widget build(BuildContext context) {
    final showDot = widget.tone == TruthChipTone.amber ||
        widget.tone == TruthChipTone.red;

    return Semantics(
      label: widget.text,
      child: Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: _color.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showDot)
            FadeTransition(
              opacity: _controller != null
                  ? Tween(begin: 1.0, end: 0.3).animate(_controller!)
                  : const AlwaysStoppedAnimation(1),
              child: Container(
                width: 6,
                height: 6,
                margin: const EdgeInsetsDirectional.only(end: 5),
                decoration: BoxDecoration(
                  color: _color,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          Flexible(
            child: Text(
              widget.text,
              style: AppTypography.caption.copyWith(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: _color,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
      ),
    );
  }
}

class _ProgressBar extends StatelessWidget {
  const _ProgressBar({
    required this.progress,
    required this.tone,
  });

  final double progress;
  final TruthChipTone tone;

  @override
  Widget build(BuildContext context) {
    final fill = switch (tone) {
      TruthChipTone.ok => AppColors.success,
      TruthChipTone.amber => AppColors.warning,
      TruthChipTone.red => AppColors.error,
      TruthChipTone.neutral => null,
    };

    final percent = (progress.clamp(0.0, 1.0) * 100).round();
    return Semantics(
      label: 'Progress',
      value: '$percent%',
      child: ExcludeSemantics(
        child: ClipRRect(
      borderRadius: BorderRadius.circular(2),
      child: SizedBox(
        height: 4,
        width: double.infinity,
        child: ColoredBox(
          color: AppColors.textOnGlassMuted.withValues(alpha: 0.15),
          child: Align(
            alignment: AlignmentDirectional.centerStart,
            child: FractionallySizedBox(
              widthFactor: progress,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(2),
                  gradient: fill == null
                      ? LinearGradient(
                          colors: [
                            AppColors.goldFamilyMain,
                            Color.lerp(
                              AppColors.goldFamilyMain,
                              AppColors.brandFamilyMain,
                              0.45,
                            )!,
                          ],
                        )
                      : null,
                  color: fill,
                ),
              ),
            ),
          ),
        ),
      ),
        ),
      ),
    );
  }
}
