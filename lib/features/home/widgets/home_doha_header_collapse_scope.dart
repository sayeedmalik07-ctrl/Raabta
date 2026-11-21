import 'package:flutter/widgets.dart';

/// Collapse progress (0 expanded → 1 collapsed) for the Doha pinned header.
class HomeDohaHeaderCollapseScope extends InheritedWidget {
  const HomeDohaHeaderCollapseScope({
    super.key,
    required this.progress,
    required super.child,
  });

  final double progress;

  static double? maybeProgressOf(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<HomeDohaHeaderCollapseScope>()
        ?.progress;
  }

  @override
  bool updateShouldNotify(HomeDohaHeaderCollapseScope oldWidget) {
    return oldWidget.progress != progress;
  }
}