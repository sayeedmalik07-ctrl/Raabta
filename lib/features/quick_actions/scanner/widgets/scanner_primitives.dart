import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/screens/money/widgets/money_hub_primitives.dart';

const scannerScreenPadding = EdgeInsets.fromLTRB(
  AppSpacing.xl,
  AppSpacing.lg,
  AppSpacing.xl,
  AppSpacing.xxxl,
);

/// Hub kit brand accent (replaces legacy purple hex).
Color get scannerAccent => AppColors.brandFamilyMain;

void scannerSelectionHaptic() => moneyHubSelectionHaptic();

void scannerLightHaptic() => moneyHubLightHaptic();

void scannerMediumHaptic() => HapticFeedback.mediumImpact();

/// Fade + slide entrance for scanner results and sections.
class ScannerEntranceReveal extends StatefulWidget {
  const ScannerEntranceReveal({
    super.key,
    required this.child,
    this.delay = Duration.zero,
  });

  final Widget child;
  final Duration delay;

  @override
  State<ScannerEntranceReveal> createState() => _ScannerEntranceRevealState();
}

class _ScannerEntranceRevealState extends State<ScannerEntranceReveal>
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
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));
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
      child: SlideTransition(
        position: _slide,
        child: widget.child,
      ),
    );
  }
}
