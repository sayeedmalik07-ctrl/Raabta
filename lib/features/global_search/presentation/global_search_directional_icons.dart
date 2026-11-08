import 'package:flutter/material.dart';

/// Direction-aware navigation affordances for Global Search (RTL-safe).
abstract final class GlobalSearchDirectionalIcons {
  static IconData chevronForward(BuildContext context) {
    return Directionality.of(context) == TextDirection.rtl
        ? Icons.chevron_left_rounded
        : Icons.chevron_right_rounded;
  }

  static IconData queryEnter(BuildContext context) {
    return Directionality.of(context) == TextDirection.rtl
        ? Icons.north_east_rounded
        : Icons.north_west_rounded;
  }

  static Widget playContinue(BuildContext context, {double size = 24}) {
    final icon = Icon(Icons.play_arrow_rounded, size: size);
    if (Directionality.of(context) == TextDirection.rtl) {
      return Transform(
        alignment: Alignment.center,
        transform: Matrix4.identity()..scaleByDouble(-1.0, 1.0, 1.0, 1.0),
        child: icon,
      );
    }
    return icon;
  }
}
