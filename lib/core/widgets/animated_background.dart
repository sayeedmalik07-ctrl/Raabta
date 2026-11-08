import 'package:flutter/material.dart';
import 'package:raabta/core/background/animated_aurora_background.dart'
    as aurora;

/// Legacy import path for the canonical animated aurora background.
///
/// Preserves existing screen layouts by not applying an inner [SafeArea];
/// most callers already wrap content in their own [SafeArea].
class AnimatedAuroraBackground extends StatelessWidget {
  const AnimatedAuroraBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return aurora.AnimatedAuroraBackground(
      ignoreSafeArea: true,
      child: child,
    );
  }
}
