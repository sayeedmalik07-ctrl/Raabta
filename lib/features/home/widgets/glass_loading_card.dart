import 'package:flutter/material.dart';

import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/glass/glass_container.dart';
import 'package:raabta/core/spacing/app_spacing.dart';

/// Unified glass loading placeholder for Home dashboard sections.
class GlassLoadingCard extends StatefulWidget {
  const GlassLoadingCard({
    super.key,
    this.height = 140,
    this.width = double.infinity,
  });

  final double height;
  final double width;

  @override
  State<GlassLoadingCard> createState() => _GlassLoadingCardState();
}

class _GlassLoadingCardState extends State<GlassLoadingCard> {
  int _cycle = 0;

  static const _stableReducedMotionOpacity = 0.6;

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    final forward = _cycle.isEven;

    return GlassContainer(
      width: widget.width,
      height: widget.height,
      padding: const EdgeInsets.all(AppSpacing.cardPadding),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final placeholder = _LoadingPlaceholderBars(
            maxHeight: constraints.maxHeight,
            maxWidth: constraints.maxWidth,
          );

          if (reduceMotion) {
            return ClipRect(
              child: Opacity(
                opacity: _stableReducedMotionOpacity,
                child: placeholder,
              ),
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
              if (mounted) {
                setState(() => _cycle++);
              }
            },
            builder: (context, opacity, _) {
              return ClipRect(
                child: Opacity(
                  opacity: opacity,
                  child: placeholder,
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _LoadingPlaceholderBars extends StatelessWidget {
  const _LoadingPlaceholderBars({
    required this.maxHeight,
    required this.maxWidth,
  });

  final double maxHeight;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    if (maxHeight <= 28) {
      return _PlaceholderBar(
        width: maxWidth,
        height: maxHeight.clamp(8, 28),
        borderRadius: AppSpacing.radiusXs,
      );
    }

    if (maxHeight <= 48) {
      final barHeight = (maxHeight * 0.4).clamp(6.0, 14.0);
      final gap = (maxHeight * 0.1).clamp(2.0, AppSpacing.xs);
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          _PlaceholderBar(
            width: maxWidth,
            height: barHeight,
            borderRadius: AppSpacing.radiusXs,
          ),
          SizedBox(height: gap),
          _PlaceholderBar(
            width: maxWidth * 0.65,
            height: (maxHeight - barHeight - gap).clamp(4.0, 12.0),
            borderRadius: AppSpacing.radiusXs,
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        _PlaceholderBar(
          width: maxWidth,
          height: 18,
          borderRadius: AppSpacing.radiusSm,
        ),
        const SizedBox(height: AppSpacing.sm),
        _PlaceholderBar(
          width: maxWidth.clamp(0, 220),
          height: 14,
          borderRadius: AppSpacing.radiusXs,
        ),
        const SizedBox(height: AppSpacing.sm),
        _PlaceholderBar(
          width: maxWidth.clamp(0, 140),
          height: 10,
          borderRadius: AppSpacing.radiusXs,
        ),
      ],
    );
  }
}

class _PlaceholderBar extends StatelessWidget {
  const _PlaceholderBar({
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
            : Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    );
  }
}
