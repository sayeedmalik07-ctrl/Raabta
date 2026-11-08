import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/glass/glass_container.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/features/home/widgets/home_card_tiers.dart';
import 'package:raabta/features/home/domain/home_chip_status.dart';
import 'package:raabta/features/home/widgets/home_chip_entrance.dart';
import 'package:raabta/features/home/widgets/home_chip_status_line.dart';
import 'package:raabta/features/home/widgets/home_icon_badge.dart';

/// Compact Core Service chip for the Home Explore rail.
class RaabtaCoreServiceChip extends StatefulWidget {
  const RaabtaCoreServiceChip({
    super.key,
    required this.icon,
    required this.label,
    required this.accentColor,
    required this.onTap,
    this.entranceIndex = 0,
    this.width = HomeCardTier.lifestyleChipWidth,
    this.height = HomeCardTier.lifestyleChipHeight,
    this.iconBadgeSize = HomeCardTier.lifestyleChipIconBadge,
    this.iconSize = HomeCardTier.lifestyleChipIconSize,
    this.labelFontSize = HomeCardTier.lifestyleChipLabelFontSize,
    this.glowIntensity = HomeCardTier.lifestyleChipGlowIntensity,
    this.backgroundTintAlpha = HomeCardTier.navigationSurfaceTintAlpha,
    this.surfaceGlowColor = AppColors.cyanGlow,
    this.enableEntranceAnimation = true,
    this.status = const HomeChipStatus.ready(line: ''),
    this.iconBadgeVariant = HomeIconBadgeVariant.standard,
    this.tileBorderRadius = HomeCardTier.homeCardRadius,
    this.labelColor,
    this.labelMaxLines = 1,
    this.labelMinLines,
    this.labelFontWeight = FontWeight.w600,
    this.topAlignedContent = false,
    this.centerLabelWhenTopAligned = false,
    this.contentPadding,
    this.iconLabelGap,
  });

  final IconData icon;
  final String label;

  /// Icon/badge accent — surface uses [surfaceGlowColor] for restrained glow.
  final Color accentColor;
  final VoidCallback onTap;
  final int entranceIndex;
  final double width;
  final double height;
  final double iconBadgeSize;
  final double iconSize;
  final double labelFontSize;
  final double glowIntensity;
  final double backgroundTintAlpha;
  final Color surfaceGlowColor;
  final bool enableEntranceAnimation;
  final HomeChipStatus status;
  final HomeIconBadgeVariant iconBadgeVariant;
  final double tileBorderRadius;
  final Color? labelColor;
  final int labelMaxLines;

  /// Reserves vertical space for multi-line labels (Explore grid).
  final int? labelMinLines;
  final FontWeight labelFontWeight;

  /// Kit rail layout: icon and labels top-aligned (Qatar Life).
  final bool topAlignedContent;

  /// When [topAlignedContent] is true, center icon + label block (Explore grid).
  final bool centerLabelWhenTopAligned;

  /// Optional tile inset (Explore grid kit padding).
  final EdgeInsetsGeometry? contentPadding;

  /// Gap between icon badge and label; defaults vary by layout mode.
  final double? iconLabelGap;

  /// Default lifestyle-rail height (Qatar Life and other non-Explore rails).
  static const chipHeight = HomeCardTier.lifestyleChipHeight;

  @override
  State<RaabtaCoreServiceChip> createState() => _RaabtaCoreServiceChipState();
}

double? _brandChipBorderRadius(HomeIconBadgeVariant variant) {
  return switch (variant) {
    HomeIconBadgeVariant.exploreBrand ||
    HomeIconBadgeVariant.goldBrand ||
    HomeIconBadgeVariant.tealBrand ||
    HomeIconBadgeVariant.greenBrand =>
      HomeCardTier.coreServiceIconChipRadius,
    HomeIconBadgeVariant.standard => null,
  };
}

class _RaabtaCoreServiceChipState extends State<RaabtaCoreServiceChip>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pressController;

  bool get _reduceMotion => MediaQuery.disableAnimationsOf(context);

  @override
  void initState() {
    super.initState();
    _pressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
      lowerBound: 0.96,
      upperBound: 1.0,
      value: 1.0,
    );
  }

  @override
  void dispose() {
    _pressController.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails _) {
    if (_reduceMotion) {
      HapticFeedback.selectionClick();
      return;
    }
    _pressController.reverse();
    HapticFeedback.lightImpact();
  }

  void _onTapUp(TapUpDetails _) {
    if (!_reduceMotion) {
      _pressController.forward();
    }
    widget.onTap();
  }

  void _onTapCancel() => _pressController.forward();

  double? get _reservedLabelHeight {
    final minLines = widget.labelMinLines;
    if (minLines == null || minLines < 1) return null;
    return widget.labelFontSize * 1.2 * minLines;
  }

  bool get _exploreGridTile => widget.contentPadding != null;

  Widget _buildLabelText(TextAlign textAlign) {
    final style = AppTypography.chipLabel.copyWith(
      color: widget.labelColor ?? AppColors.textOnGlassSecondary,
      fontSize: widget.labelFontSize,
      height: 1.2,
      fontWeight: widget.labelFontWeight,
    );
    final text = Text(
      widget.label,
      style: style,
      maxLines: widget.labelMaxLines,
      overflow: TextOverflow.ellipsis,
      textAlign: textAlign,
    );

    if (_exploreGridTile) {
      return Expanded(
        child: Align(
          alignment: textAlign == TextAlign.center
              ? Alignment.topCenter
              : AlignmentDirectional.topStart,
          child: ExcludeSemantics(child: text),
        ),
      );
    }

    final reservedHeight = _reservedLabelHeight;
    if (reservedHeight != null) {
      return SizedBox(
        height: reservedHeight,
        width: double.infinity,
        child: ExcludeSemantics(child: text),
      );
    }

    return Flexible(
      child: ExcludeSemantics(child: text),
    );
  }

  @override
  Widget build(BuildContext context) {
    final topCrossAxis = widget.topAlignedContent && widget.centerLabelWhenTopAligned
        ? CrossAxisAlignment.center
        : widget.topAlignedContent
            ? CrossAxisAlignment.start
            : CrossAxisAlignment.center;
    final labelTextAlign = widget.topAlignedContent && !widget.centerLabelWhenTopAligned
        ? TextAlign.start
        : widget.topAlignedContent && widget.centerLabelWhenTopAligned
            ? TextAlign.center
            : TextAlign.center;

    Widget chipBody = SizedBox(
      width: widget.width,
      height: widget.height,
      child: GestureDetector(
        onTapDown: _onTapDown,
        onTapUp: _onTapUp,
        onTapCancel: _onTapCancel,
        behavior: HitTestBehavior.opaque,
        child: ScaleTransition(
          scale: _reduceMotion
              ? const AlwaysStoppedAnimation(1.0)
              : _pressController,
          child: GlassContainer(
            padding: widget.contentPadding ??
                (widget.topAlignedContent
                    ? (widget.labelMinLines != null
                        ? const EdgeInsets.symmetric(
                            horizontal: AppSpacing.sm,
                            vertical: AppSpacing.sm,
                          )
                        : const EdgeInsets.all(12))
                    : const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: AppSpacing.sm,
                      )),
            borderRadius: widget.tileBorderRadius,
            glowColor: widget.surfaceGlowColor,
            glowIntensity: widget.glowIntensity,
            backgroundColor: widget.backgroundTintAlpha > 0
                ? widget.surfaceGlowColor.withValues(
                    alpha: widget.backgroundTintAlpha,
                  )
                : null,
            child: Column(
              crossAxisAlignment: topCrossAxis,
              mainAxisAlignment: widget.topAlignedContent
                  ? MainAxisAlignment.start
                  : MainAxisAlignment.center,
              mainAxisSize:
                  _exploreGridTile ? MainAxisSize.max : MainAxisSize.min,
              children: [
                ExcludeSemantics(
                  child: HomeIconBadge(
                    icon: widget.icon,
                    accentColor: widget.accentColor,
                    size: widget.iconBadgeSize,
                    iconSize: widget.iconSize,
                    variant: widget.iconBadgeVariant,
                    chipBorderRadius:
                        _brandChipBorderRadius(widget.iconBadgeVariant),
                  ),
                ),
                SizedBox(
                  height: widget.iconLabelGap ??
                      (widget.topAlignedContent
                          ? (widget.labelMinLines != null ? AppSpacing.xs : 10)
                          : AppSpacing.xs),
                ),
                _buildLabelText(labelTextAlign),
                widget.topAlignedContent && !widget.centerLabelWhenTopAligned
                    ? HomeChipStatusLine.build(widget.status)
                    : HomeChipStatusLine.buildCentered(widget.status),
              ],
            ),
          ),
        ),
      ),
    );

    chipBody = HomeChipEntrance(
      enabled: widget.enableEntranceAnimation,
      delayMs: 40 * widget.entranceIndex.clamp(0, 8),
      child: chipBody,
    );

    final semanticsLabel = widget.status.isLoading || widget.status.line.isEmpty
        ? widget.label
        : '${widget.label}, ${widget.status.line}';

    return Semantics(
      button: true,
      label: semanticsLabel,
      child: chipBody,
    );
  }
}
