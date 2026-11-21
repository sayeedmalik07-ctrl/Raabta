import 'package:flutter/material.dart';

/// Physical elevation shadows and tactile highlights (kit --ph, --tact).
abstract final class RaabtaPhysicalShadowTokens {
  RaabtaPhysicalShadowTokens._();

  /// Card / grouped list surface (replaces decorative glow shadow).
  static List<BoxShadow> card(Brightness brightness) {
    if (brightness == Brightness.light) {
      return const [
        BoxShadow(
          color: Color(0x0F0F172A),
          offset: Offset(0, 1),
          blurRadius: 2,
        ),
        BoxShadow(
          color: Color(0x120F172A),
          offset: Offset(0, 8),
          blurRadius: 18,
        ),
      ];
    }
    return const [
      BoxShadow(
        color: Color(0x59000000),
        offset: Offset(0, 6),
        blurRadius: 14,
      ),
    ];
  }

  /// Solid tactile controls (Post FAB, primary CTA, AI orb body).
  static List<BoxShadow> tactileButton(Brightness brightness) {
    if (brightness == Brightness.light) {
      return const [
        BoxShadow(
          color: Color(0x664A2A96),
          offset: Offset(0, 3),
          blurRadius: 7,
        ),
      ];
    }
    return const [
      BoxShadow(
        color: Color(0x66000000),
        offset: Offset(0, 4),
        blurRadius: 8,
      ),
    ];
  }

  /// Visual press sink distance (pair with [tactileButton]).
  static const double tactilePressedOffsetY = 1.0;

  static const double tactilePressedScale = 0.98;
}

/// Inner top-edge highlight and solid brand fill for tactile buttons (kit).
abstract final class RaabtaTactileHighlightTokens {
  RaabtaTactileHighlightTokens._();

  /// Simulated inset top highlight (apply as top border or inner gradient stop).
  static Color innerTopEdge(Brightness brightness) {
    if (brightness == Brightness.light) {
      return const Color(0x14FFFFFF);
    }
    return const Color(0x59FFFFFF);
  }

  /// Solid brand fill for tactile buttons (--solidb).
  static Color solidBrandFill(Brightness brightness) {
    return brightness == Brightness.dark
        ? const Color(0xFF7A55EE)
        : const Color(0xFF6C3FC5);
  }
}