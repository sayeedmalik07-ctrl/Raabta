import 'dart:ui';

import 'package:flutter/material.dart';

import '../colors/app_colors.dart';
import '../spacing/app_spacing.dart';

/// Reusable animated aurora background for premium screens.
class AnimatedAuroraBackground extends StatefulWidget {
  const AnimatedAuroraBackground({
    super.key,
    required this.child,
    this.enableAnimation = true,
    this.ignoreSafeArea = false,
  });

  final Widget child;
  final bool enableAnimation;
  final bool ignoreSafeArea;

  @override
  State<AnimatedAuroraBackground> createState() =>
      _AnimatedAuroraBackgroundState();
}

class _AnimatedAuroraBackgroundState extends State<AnimatedAuroraBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: AppSpacing.ambientAnimation,
    );
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);

    if (widget.enableAnimation) {
      _controller.repeat(reverse: true);
    } else {
      _controller.value = 0.5;
    }
  }

  @override
  void didUpdateWidget(covariant AnimatedAuroraBackground oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.enableAnimation && !_controller.isAnimating) {
      _controller.repeat(reverse: true);
    } else if (!widget.enableAnimation) {
      _controller.stop();
      _controller.value = 0.5;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLight = AppColors.isLight;
    final child = widget.ignoreSafeArea
        ? widget.child
        : SafeArea(child: widget.child);

    return ColoredBox(
      color: AppColors.background,
      child: Stack(
        fit: StackFit.expand,
        children: [
          RepaintBoundary(
            child: AnimatedBuilder(
              animation: _animation,
              builder: (context, _) => _AuroraLayer(
                progress: _animation.value,
                isLight: isLight,
              ),
            ),
          ),
          ColoredBox(
            color: AppColors.background.withValues(alpha: isLight ? 0.55 : 0.35),
          ),
          child,
        ],
      ),
    );
  }
}

class _AuroraLayer extends StatelessWidget {
  const _AuroraLayer({required this.progress, required this.isLight});

  final double progress;
  final bool isLight;

  @override
  Widget build(BuildContext context) {
    final cyanOpacity = isLight ? 0.08 : 0.18;
    final purpleOpacity = isLight ? 0.06 : 0.14;
    final blueOpacity = isLight ? 0.05 : 0.10;

    return Stack(
      fit: StackFit.expand,
      children: [
        _AuroraOrb(
          color: AppColors.cyanGlow,
          opacity: cyanOpacity,
          size: 420,
          top: -120 + (progress * 36),
          left: -100 + (progress * 24),
        ),
        _AuroraOrb(
          color: AppColors.purpleGlow,
          opacity: purpleOpacity,
          size: 460,
          bottom: -140 + (progress * -28),
          right: -110 + (progress * -18),
        ),
        _AuroraOrb(
          color: AppColors.blueGlow,
          opacity: blueOpacity,
          size: 320,
          top: 280 + (progress * -22),
          left: 80 + (progress * 30),
        ),
      ],
    );
  }
}

class _AuroraOrb extends StatelessWidget {
  const _AuroraOrb({
    required this.color,
    required this.opacity,
    required this.size,
    this.top,
    this.left,
    this.right,
    this.bottom,
  });

  final Color color;
  final double opacity;
  final double size;
  final double? top;
  final double? left;
  final double? right;
  final double? bottom;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: top,
      left: left,
      right: right,
      bottom: bottom,
      child: ImageFiltered(
        imageFilter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                color.withValues(alpha: opacity),
                color.withValues(alpha: 0),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
