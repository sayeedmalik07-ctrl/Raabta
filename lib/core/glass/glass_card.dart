import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:raabta/core/design/raabta_solid_surface_tokens.dart';

import 'glass_container.dart';
import '../spacing/app_spacing.dart';

/// Interactive glass surface with tap scale animation and haptic feedback.
class GlassCard extends StatefulWidget {
  const GlassCard({
    super.key,
    required this.child,
    this.width,
    this.height,
    this.padding,
    this.margin,
    this.borderRadius = AppSpacing.radiusLg,
    this.glowColor,
    this.glowIntensity = 0,
    this.blurSigma = AppSpacing.glassBlur,
    this.backgroundColor,
    this.onTap,
    this.solidSurfaceFamily,
  });

  final Widget child;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double borderRadius;
  final Color? glowColor;
  final double glowIntensity;
  final double blurSigma;
  final Color? backgroundColor;
  final VoidCallback? onTap;
  final RaabtaSolidSurfaceFamily? solidSurfaceFamily;

  @override
  State<GlassCard> createState() => _GlassCardState();
}

class _GlassCardState extends State<GlassCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;
  bool _reduceMotion = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
      lowerBound: 0.96,
      upperBound: 1.0,
      value: 1.0,
    );
    _scale = _controller;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _reduceMotion = MediaQuery.disableAnimationsOf(context);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails _) {
    if (!_reduceMotion) {
      _controller.reverse();
    }
    HapticFeedback.lightImpact();
  }

  void _onTapUp(TapUpDetails _) {
    if (!_reduceMotion) {
      _controller.forward();
    }
    widget.onTap?.call();
  }

  void _onTapCancel() {
    if (!_reduceMotion) {
      _controller.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasTap = widget.onTap != null;

    return GestureDetector(
      onTapDown: hasTap ? _onTapDown : null,
      onTapUp: hasTap ? _onTapUp : null,
      onTapCancel: hasTap ? _onTapCancel : null,
      behavior: HitTestBehavior.opaque,
      child: ScaleTransition(
        scale: _reduceMotion ? const AlwaysStoppedAnimation(1.0) : _scale,
        child: GlassContainer(
          width: widget.width,
          height: widget.height,
          padding: widget.padding,
          margin: widget.margin,
          borderRadius: widget.borderRadius,
          glowColor: widget.glowColor,
          glowIntensity: widget.glowIntensity,
          blurSigma: widget.blurSigma,
          backgroundColor: widget.backgroundColor,
          solidSurfaceFamily: widget.solidSurfaceFamily,
          child: widget.child,
        ),
      ),
    );
  }
}
