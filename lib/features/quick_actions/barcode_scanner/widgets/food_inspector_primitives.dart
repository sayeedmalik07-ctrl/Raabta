import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void foodInspectorLightHaptic() => HapticFeedback.selectionClick();

void foodInspectorMediumHaptic() => HapticFeedback.mediumImpact();

void foodInspectorHeavyHaptic() => HapticFeedback.heavyImpact();

void foodInspectorScanCompleteHaptic() => HapticFeedback.mediumImpact();

void foodInspectorAllergenHaptic() => HapticFeedback.heavyImpact();

void foodInspectorHalalWarningHaptic() => HapticFeedback.lightImpact();

/// Fade + slide entrance for scan result sections.
class FoodInspectorEntranceReveal extends StatefulWidget {
  const FoodInspectorEntranceReveal({
    super.key,
    required this.child,
    this.delay = Duration.zero,
  });

  final Widget child;
  final Duration delay;

  @override
  State<FoodInspectorEntranceReveal> createState() =>
      _FoodInspectorEntranceRevealState();
}

class _FoodInspectorEntranceRevealState extends State<FoodInspectorEntranceReveal>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacity;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
    );
    _opacity = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.04),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
    Future<void>.delayed(widget.delay, () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacity,
      child: SlideTransition(position: _slide, child: widget.child),
    );
  }
}
