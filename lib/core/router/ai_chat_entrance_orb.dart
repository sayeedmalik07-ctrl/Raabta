import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';
import 'package:raabta/core/widgets/raabta_orb.dart';
import 'package:raabta/core/widgets/raabta_orb_kit_sizes.dart';
import 'package:raabta/core/widgets/raabta_orb_state.dart';

/// Serializable global rect for the Home sparkle orb at launch.
abstract final class AiChatEntranceOrbRectCodec {
  static Map<String, double>? encode(Rect? rect) {
    if (rect == null) return null;
    return {
      'l': rect.left,
      't': rect.top,
      'w': rect.width,
      'h': rect.height,
    };
  }

  static Rect? decode(Object? raw) {
    if (raw is! Map) return null;
    final l = raw['l'];
    final t = raw['t'];
    final w = raw['w'];
    final h = raw['h'];
    if (l is! num || t is! num || w is! num || h is! num) return null;
    return Rect.fromLTWH(l.toDouble(), t.toDouble(), w.toDouble(), h.toDouble());
  }
}

/// Rising orb during living entrance (kit PNG 02), before empty-state hero.
class AiChatFlyingEntranceOrb extends StatelessWidget {
  const AiChatFlyingEntranceOrb({
    super.key,
    required this.progress,
    required this.screenSize,
    this.sourceRect,
  });

  final double progress;
  final Size screenSize;
  final Rect? sourceRect;

  static Offset defaultSourceCenter(Size size) =>
      Offset(size.width * 0.82, size.height * 0.22);

  static Offset heroTargetCenter(Size size) =>
      Offset(size.width * 0.5, size.height * 0.34);

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    if (reduceMotion || progress <= 0) {
      return const SizedBox.shrink();
    }

    final from = sourceRect?.center ?? defaultSourceCenter(screenSize);
    final to = heroTargetCenter(screenSize);

    final flyPhase = (progress / 0.5).clamp(0.0, 1.0);
    final flyT = Curves.easeOutCubic.transform(flyPhase);
    final center = Offset.lerp(from, to, flyT)!;

    final pressSize = RaabtaOrbKitSizes.homeSparkle * 0.94;
    var diameter = lerpDouble(pressSize, RaabtaOrbKitSizes.entranceFly, flyT)!;
    if (progress > 0.45) {
      final growT = ((progress - 0.45) / 0.35).clamp(0.0, 1.0);
      diameter = lerpDouble(
        RaabtaOrbKitSizes.entranceFly,
        RaabtaOrbKitSizes.heroEmpty,
        Curves.easeOut.transform(growT),
      )!;
    }

    final fadeOut = progress > 0.72
        ? 1 - ((progress - 0.72) / 0.28).clamp(0.0, 1.0)
        : 1.0;

    final extent = diameter * 1.26;

    return Positioned(
      left: center.dx - extent / 2,
      top: center.dy - extent / 2,
      child: Opacity(
        opacity: fadeOut,
        child: RepaintBoundary(
          child: RaabtaOrb(
            state: RaabtaOrbState.idle,
            size: diameter,
            showDepthRings: progress > 0.35,
          ),
        ),
      ),
    );
  }
}
