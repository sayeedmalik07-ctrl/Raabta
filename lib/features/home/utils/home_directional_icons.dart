import 'package:flutter/material.dart';

/// Direction-aware trailing indicators for Home widgets.
abstract final class HomeDirectionalIcons {
  HomeDirectionalIcons._();

  static IconData forwardChevron(BuildContext context) {
    return Directionality.of(context) == TextDirection.rtl
        ? Icons.chevron_left
        : Icons.chevron_right;
  }

  static IconData forwardChevronRounded(BuildContext context) {
    return Directionality.of(context) == TextDirection.rtl
        ? Icons.chevron_left_rounded
        : Icons.chevron_right_rounded;
  }

  static IconData forwardArrowIos(BuildContext context) {
    return Directionality.of(context) == TextDirection.rtl
        ? Icons.arrow_back_ios_rounded
        : Icons.arrow_forward_ios_rounded;
  }

  static IconData forwardArrowRounded(BuildContext context) {
    return Directionality.of(context) == TextDirection.rtl
        ? Icons.arrow_back_rounded
        : Icons.arrow_forward_rounded;
  }
}
