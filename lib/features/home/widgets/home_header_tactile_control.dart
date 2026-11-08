import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/glass/glass_container.dart';

/// Press feedback for Home header icon controls (language pill, bell).
class HomeHeaderTactileControl extends StatefulWidget {
  const HomeHeaderTactileControl({
    super.key,
    required this.child,
    this.onTap,
    this.width,
    this.height = 44,
    this.borderRadius = 22,
    this.circular = false,
    this.semanticsLabel,
    this.controlKey,
  });

  final Widget child;
  final VoidCallback? onTap;
  final double? width;
  final double height;
  final double borderRadius;
  final bool circular;
  final String? semanticsLabel;
  final Key? controlKey;

  @override
  State<HomeHeaderTactileControl> createState() =>
      _HomeHeaderTactileControlState();
}

class _HomeHeaderTactileControlState extends State<HomeHeaderTactileControl>
    with SingleTickerProviderStateMixin {
  static const _pressInDuration = Duration(milliseconds: 80);
  static const _releaseDuration = Duration(milliseconds: 220);

  late final AnimationController _scaleController;
  late final Animation<double> _scale;
  bool _pressed = false;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      vsync: this,
      duration: _releaseDuration,
      value: 1,
    );
    _scale = Tween<double>(begin: 0.92, end: 1).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeOutBack),
    );
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  bool get _reduceMotion => MediaQuery.disableAnimationsOf(context);

  void _onTapDown(TapDownDetails _) {
    HapticFeedback.selectionClick();
    setState(() => _pressed = true);
    if (_reduceMotion) return;
    _scaleController.duration = _pressInDuration;
    _scaleController.animateTo(
      0,
      duration: _pressInDuration,
      curve: Curves.easeOutCubic,
    );
  }

  void _onTapUp(TapUpDetails _) {
    widget.onTap?.call();
    _release();
  }

  void _onTapCancel() => _release();

  void _release() {
    if (!mounted) return;
    setState(() => _pressed = false);
    if (_reduceMotion) {
      _scaleController.value = 1;
      return;
    }
    _scaleController.duration = _releaseDuration;
    _scaleController.forward();
  }

  @override
  Widget build(BuildContext context) {
    final radius = widget.circular ? widget.height / 2 : widget.borderRadius;
    final glow = _pressed ? 0.14 : 0.05;

    return Semantics(
      button: true,
      label: widget.semanticsLabel,
      child: SizedBox(
        width: widget.width,
        height: widget.height,
        child: ScaleTransition(
          scale: _reduceMotion
              ? AlwaysStoppedAnimation(_pressed ? 0.92 : 1.0)
              : _scale,
          child: GestureDetector(
            key: widget.controlKey,
            onTapDown: widget.onTap != null ? _onTapDown : null,
            onTapUp: widget.onTap != null ? _onTapUp : null,
            onTapCancel: widget.onTap != null ? _onTapCancel : null,
            behavior: HitTestBehavior.opaque,
            child: GlassContainer(
              width: widget.width,
              height: widget.height,
              borderRadius: radius,
              padding: EdgeInsets.zero,
              glowColor: AppColors.brandFamilyMain,
              glowIntensity: glow,
              backgroundColor: AppColors.isLight
                  ? Color.lerp(AppColors.surface, Colors.white, 0.35)
                  : null,
              child: widget.child,
            ),
          ),
        ),
      ),
    );
  }
}
