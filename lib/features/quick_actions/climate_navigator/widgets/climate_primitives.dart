import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/screens/money/widgets/money_hub_primitives.dart';

const climateScreenPadding = EdgeInsets.fromLTRB(
  AppSpacing.xl,
  AppSpacing.lg,
  AppSpacing.xl,
  AppSpacing.xxxl,
);

const climateAccent = AppColors.cyanGlow;

void climateSelectionHaptic() => moneyHubSelectionHaptic();

void climateLightHaptic() => moneyHubLightHaptic();

void climateMediumHaptic() => HapticFeedback.mediumImpact();

void climateHeavyHaptic() => HapticFeedback.heavyImpact();

void climateSuccessHaptic() => HapticFeedback.mediumImpact();

/// Fade + slide entrance for route results and alerts.
class ClimateEntranceReveal extends StatefulWidget {
  const ClimateEntranceReveal({
    super.key,
    required this.child,
    this.delay = Duration.zero,
  });

  final Widget child;
  final Duration delay;

  @override
  State<ClimateEntranceReveal> createState() => _ClimateEntranceRevealState();
}

class _ClimateEntranceRevealState extends State<ClimateEntranceReveal>
    with SingleTickerProviderStateMixin {
  AnimationController? _controller;
  Animation<double>? _opacity;
  Animation<Offset>? _slide;
  bool _started = false;

  bool get _reduceMotion => MediaQuery.disableAnimationsOf(context);

  void _startAnimationIfNeeded() {
    if (_reduceMotion || _started) return;
    _started = true;
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
    );
    _opacity = CurvedAnimation(
      parent: _controller!,
      curve: Curves.easeOutCubic,
    );
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.04),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller!,
      curve: Curves.easeOutCubic,
    ));
    Future<void>.delayed(widget.delay, () {
      if (mounted) _controller?.forward();
    });
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_reduceMotion) return widget.child;
    _startAnimationIfNeeded();
    if (_opacity == null || _slide == null) return widget.child;
    return FadeTransition(
      opacity: _opacity!,
      child: SlideTransition(
        position: _slide!,
        child: widget.child,
      ),
    );
  }
}

/// Fires a one-shot haptic when the widget first appears (e.g. work-stop alert).
class ClimateHapticOnReveal extends StatefulWidget {
  const ClimateHapticOnReveal({
    super.key,
    required this.child,
    this.onReveal = climateHeavyHaptic,
  });

  final Widget child;
  final VoidCallback onReveal;

  @override
  State<ClimateHapticOnReveal> createState() => _ClimateHapticOnRevealState();
}

class _ClimateHapticOnRevealState extends State<ClimateHapticOnReveal> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final reduceMotion = MediaQuery.disableAnimationsOf(context);
      if (reduceMotion) return;
      widget.onReveal();
    });
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
