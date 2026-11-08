import 'package:flutter/material.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/design/app_radius.dart';
import 'package:raabta/core/design/app_spacing.dart';
import 'package:raabta/core/glass/glass_container.dart';
import 'package:raabta/core/widgets/hub/hub_layout_tokens.dart';

/// Hub loading skeleton (not spinner).
enum HubLoadingSilhouette {
  /// Default hub feed / listing card.
  listing,

  /// Business hub text-led card (48dp logo + lines).
  businessCard,

  /// Services provider card (44dp avatar + lines).
  serviceCard,

  /// Services request card (title + meta, no avatar).
  serviceCardRequest,

  /// Form or tool screen — stacked lines, no photo media.
  formTool,

  /// Community [HubPostCard] — avatar + header lines + body block.
  postCard,
}

/// Hub list loading skeleton (not spinner) — listing-card silhouette.
class HubLoadingPlaceholder extends StatefulWidget {
  const HubLoadingPlaceholder({
    super.key,
    this.height = 120,
    this.width = 280,
    this.silhouette = HubLoadingSilhouette.listing,
  });

  final double height;
  final double width;
  final HubLoadingSilhouette silhouette;

  @override
  State<HubLoadingPlaceholder> createState() => _HubLoadingPlaceholderState();
}

class _HubLoadingPlaceholderState extends State<HubLoadingPlaceholder> {
  int _cycle = 0;

  static const _stableReducedMotionOpacity = 0.6;

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    final forward = _cycle.isEven;

    return Center(
      child: SizedBox(
        width: widget.width,
        height: widget.height,
        child: GlassContainer(
          padding: EdgeInsets.zero,
          borderRadius: AppRadius.xxl,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final skeleton = switch (widget.silhouette) {
                HubLoadingSilhouette.listing => _HubListingSkeleton(
                    maxWidth: constraints.maxWidth,
                    maxHeight: constraints.maxHeight,
                  ),
                HubLoadingSilhouette.businessCard => _HubBusinessCardSkeleton(
                    maxWidth: constraints.maxWidth,
                    maxHeight: constraints.maxHeight,
                  ),
                HubLoadingSilhouette.serviceCard => _HubServiceCardSkeleton(
                    maxWidth: constraints.maxWidth,
                    maxHeight: constraints.maxHeight,
                    withAvatar: true,
                  ),
                HubLoadingSilhouette.serviceCardRequest =>
                  _HubServiceCardSkeleton(
                    maxWidth: constraints.maxWidth,
                    maxHeight: constraints.maxHeight,
                    withAvatar: false,
                  ),
                HubLoadingSilhouette.formTool => _HubFormToolSkeleton(
                    maxWidth: constraints.maxWidth,
                    maxHeight: constraints.maxHeight,
                  ),
                HubLoadingSilhouette.postCard => _HubPostCardSkeleton(
                    maxWidth: constraints.maxWidth,
                    maxHeight: constraints.maxHeight,
                  ),
              };

              if (reduceMotion) {
                return Opacity(
                  opacity: _stableReducedMotionOpacity,
                  child: skeleton,
                );
              }

              return TweenAnimationBuilder<double>(
                key: ValueKey<int>(_cycle),
                tween: Tween<double>(
                  begin: forward ? 0.35 : 0.85,
                  end: forward ? 0.85 : 0.35,
                ),
                duration: const Duration(milliseconds: 1200),
                onEnd: () {
                  if (mounted) setState(() => _cycle++);
                },
                builder: (context, opacity, _) {
                  return Opacity(opacity: opacity, child: skeleton);
                },
              );
            },
          ),
        ),
      ),
    );
  }
}

/// Stacked lines for tool / form screens.
class _HubFormToolSkeleton extends StatelessWidget {
  const _HubFormToolSkeleton({
    required this.maxWidth,
    required this.maxHeight,
  });

  final double maxWidth;
  final double maxHeight;

  @override
  Widget build(BuildContext context) {
    final padding = AppSpacing.lg;
    final innerW = (maxWidth - padding * 2).clamp(0.0, double.infinity);
    final innerH = (maxHeight - padding * 2).clamp(0.0, double.infinity);

    const lineCount = 5;
    final gapCount = lineCount - 1;

    // Base sizes scale with the outer height; then scale down as one group so the
    // column never exceeds [innerH] (short placeholders e.g. 100dp must not overflow).
    var lineH = (maxHeight * 0.08).clamp(10.0, 16.0);
    var gap = (maxHeight * 0.05).clamp(8.0, 14.0);
    var naturalTotal = lineCount * lineH + gapCount * gap;
    if (innerH > 0 && naturalTotal > innerH) {
      final scale = innerH / naturalTotal;
      lineH = (lineH * scale).clamp(4.0, 16.0);
      gap = (gap * scale).clamp(2.0, 14.0);
      naturalTotal = lineCount * lineH + gapCount * gap;
      if (naturalTotal > innerH) {
        final f = innerH / naturalTotal;
        lineH *= f;
        gap *= f;
      }
    }

    final widths = [0.55, 0.92, 0.78, 0.88, 0.65];

    return Padding(
      padding: EdgeInsets.all(padding),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (var i = 0; i < widths.length; i++) ...[
            if (i > 0) SizedBox(height: gap),
            _SkeletonBar(
              width: innerW * widths[i],
              height: lineH,
              borderRadius: AppRadius.sm,
            ),
          ],
        ],
      ),
    );
  }
}

/// Shape-matched to [HubServiceCard] provider / request layouts.
class _HubServiceCardSkeleton extends StatelessWidget {
  const _HubServiceCardSkeleton({
    required this.maxWidth,
    required this.maxHeight,
    required this.withAvatar,
  });

  final double maxWidth;
  final double maxHeight;
  final bool withAvatar;

  @override
  Widget build(BuildContext context) {
    final padding = AppSpacing.lg;
    final avatar = HubLayoutTokens.serviceCardAvatarSize;
    final leading = withAvatar ? avatar + AppSpacing.md : 0.0;
    final innerW = maxWidth - padding * 2 - leading;
    final compact = maxHeight < 132;
    final lineGap = compact ? AppSpacing.xs : AppSpacing.sm;
    final line1 = compact ? 10.0 : 14.0;
    final line2 = compact ? 9.0 : 11.0;

    final lines = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SkeletonBar(
          width: innerW * 0.78,
          height: line1,
          borderRadius: AppRadius.sm,
        ),
        SizedBox(height: lineGap),
        _SkeletonBar(
          width: innerW * 0.52,
          height: line2,
          borderRadius: AppRadius.sm,
        ),
        if (!compact) ...[
          SizedBox(height: lineGap),
          _SkeletonBar(
            width: innerW * 0.38,
            height: line2,
            borderRadius: AppRadius.sm,
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              _SkeletonBar(
                width: (innerW * 0.26).clamp(48.0, 88.0),
                height: HubLayoutTokens.trustBadgeHeight,
                borderRadius: AppRadius.sm,
              ),
              const SizedBox(width: AppSpacing.xs),
              _SkeletonBar(
                width: (innerW * 0.22).clamp(40.0, 72.0),
                height: HubLayoutTokens.trustBadgeHeight,
                borderRadius: AppRadius.sm,
              ),
            ],
          ),
        ],
      ],
    );

    return Padding(
      padding: EdgeInsets.all(padding),
      child: withAvatar
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _SkeletonBar(
                  width: avatar,
                  height: avatar,
                  borderRadius: avatar / 2,
                ),
                SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: lines,
                  ),
                ),
              ],
            )
          : lines,
    );
  }
}

/// Shape-matched to [HubBusinessCard] (48dp logo, title lines, service chips).
class _HubBusinessCardSkeleton extends StatelessWidget {
  const _HubBusinessCardSkeleton({
    required this.maxWidth,
    required this.maxHeight,
  });

  final double maxWidth;
  final double maxHeight;

  @override
  Widget build(BuildContext context) {
    final padding = AppSpacing.lg;
    final logo = HubLayoutTokens.businessCardLogoSize;
    final innerW = maxWidth - padding * 2 - logo - AppSpacing.md;
    final compact = maxHeight < 100;
    final lineGap = compact ? AppSpacing.xs : AppSpacing.sm;
    final line1 = compact ? 11.0 : 14.0;
    final line2 = compact ? 9.0 : 11.0;
    final line3 = compact ? 8.0 : 10.0;

    return Padding(
      padding: EdgeInsets.all(padding),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _SkeletonBar(
            width: logo,
            height: logo,
            borderRadius: AppRadius.md,
          ),
          SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _SkeletonBar(
                  width: innerW * 0.72,
                  height: line1,
                  borderRadius: AppRadius.sm,
                ),
                SizedBox(height: lineGap),
                _SkeletonBar(
                  width: innerW * 0.55,
                  height: line2,
                  borderRadius: AppRadius.sm,
                ),
                if (!compact) ...[
                  SizedBox(height: lineGap),
                  _SkeletonBar(
                    width: innerW * 0.4,
                    height: line3,
                    borderRadius: AppRadius.sm,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Row(
                    children: [
                      _SkeletonBar(
                        width: (innerW * 0.22).clamp(40.0, 72.0),
                        height: 20,
                        borderRadius: AppRadius.md,
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      _SkeletonBar(
                        width: (innerW * 0.2).clamp(36.0, 64.0),
                        height: 20,
                        borderRadius: AppRadius.md,
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Shape-matched to hub ListingCard (16:10 media, body lines).
class _HubListingSkeleton extends StatelessWidget {
  const _HubListingSkeleton({
    required this.maxWidth,
    required this.maxHeight,
  });

  final double maxWidth;
  final double maxHeight;

  static const _mediaAspect = 10 / 16;

  @override
  Widget build(BuildContext context) {
    final compact = maxHeight < 160;
    final bodyPadding = compact ? AppSpacing.sm : AppSpacing.lg;
    final maxMedia = (maxHeight - bodyPadding * 2 - (compact ? 36 : 56))
        .clamp(24.0, maxHeight * 0.55);
    final mediaHeight =
        (maxWidth * _mediaAspect).clamp(compact ? 40.0 : 48.0, maxMedia);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ClipRRect(
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(AppRadius.xl),
          ),
          child: _SkeletonBar(
            width: maxWidth,
            height: mediaHeight,
            borderRadius: 0,
          ),
        ),
        Expanded(
          child: Padding(
            padding: EdgeInsets.all(bodyPadding),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final innerH = constraints.maxHeight;
                final lineH = (innerH * 0.22).clamp(8.0, compact ? 12.0 : 18.0);
                final gap = (innerH * 0.06).clamp(4.0, 8.0);
                final chipH = (innerH * 0.2).clamp(8.0, 12.0);

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _SkeletonBar(
                      width: maxWidth * 0.45,
                      height: lineH,
                      borderRadius: AppRadius.sm,
                    ),
                    SizedBox(height: gap),
                    _SkeletonBar(
                      width: maxWidth * 0.72,
                      height: lineH * 0.85,
                      borderRadius: AppRadius.sm,
                    ),
                    if (!compact && innerH > 52) ...[
                      SizedBox(height: gap),
                      _SkeletonBar(
                        width: maxWidth * 0.55,
                        height: lineH * 0.75,
                        borderRadius: AppRadius.sm,
                      ),
                    ],
                    const Spacer(),
                    Row(
                      children: [
                        _SkeletonBar(
                          width: (maxWidth * 0.18).clamp(28.0, 56.0),
                          height: chipH,
                          borderRadius: AppRadius.sm,
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        _SkeletonBar(
                          width: (maxWidth * 0.18).clamp(28.0, 56.0),
                          height: chipH,
                          borderRadius: AppRadius.sm,
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

/// Shape-matched to [HubPostCard].
class _HubPostCardSkeleton extends StatelessWidget {
  const _HubPostCardSkeleton({
    required this.maxWidth,
    required this.maxHeight,
  });

  final double maxWidth;
  final double maxHeight;

  @override
  Widget build(BuildContext context) {
    final padding = AppSpacing.lg;
    final avatar = HubLayoutTokens.jobCardLeadingSize;
    final innerW = (maxWidth - padding * 2).clamp(0.0, double.infinity);
    final lineGap = AppSpacing.sm;

    return Padding(
      padding: EdgeInsets.all(padding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _SkeletonBar(
                width: avatar,
                height: avatar,
                borderRadius: avatar / 2,
              ),
              SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _SkeletonBar(
                      width: innerW * 0.42,
                      height: 12,
                      borderRadius: AppRadius.sm,
                    ),
                    SizedBox(height: lineGap),
                    _SkeletonBar(
                      width: innerW * 0.28,
                      height: 10,
                      borderRadius: AppRadius.sm,
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.md),
          _SkeletonBar(
            width: innerW,
            height: 12,
            borderRadius: AppRadius.sm,
          ),
          SizedBox(height: lineGap),
          _SkeletonBar(
            width: innerW * 0.92,
            height: 12,
            borderRadius: AppRadius.sm,
          ),
          SizedBox(height: lineGap),
          _SkeletonBar(
            width: innerW * 0.55,
            height: 10,
            borderRadius: AppRadius.sm,
          ),
        ],
      ),
    );
  }
}

class _SkeletonBar extends StatelessWidget {
  const _SkeletonBar({
    required this.width,
    required this.height,
    required this.borderRadius,
  });

  final double width;
  final double height;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.isLight
            ? AppColors.glassSurface
            : AppColors.textPrimary.withValues(alpha: 0.12),
        borderRadius: borderRadius > 0
            ? BorderRadius.circular(borderRadius)
            : BorderRadius.zero,
      ),
    );
  }
}
