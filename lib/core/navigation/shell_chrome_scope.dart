import 'package:flutter/widgets.dart';

import '../widgets/hub/hub_post_fab.dart';

/// Set by [HomeScreen] (and profile shell) when the floating bottom nav is shown.
///
/// Hub landings use this to avoid a second Post FAB beside the shell center
/// action.
class ShellChromeScope extends InheritedWidget {
  const ShellChromeScope({
    super.key,
    required this.shellBottomNavVisible,
    required super.child,
  });

  final bool shellBottomNavVisible;

  static ShellChromeScope? maybeOf(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<ShellChromeScope>();
  }

  static bool suppressesHubPostFab(BuildContext context) {
    return maybeOf(context)?.shellBottomNavVisible ?? false;
  }

  @override
  bool updateShouldNotify(ShellChromeScope oldWidget) {
    return shellBottomNavVisible != oldWidget.shellBottomNavVisible;
  }
}

/// Hub Post FAB unless the shell bottom nav already exposes Post.
Widget? hubPostFabWhenAllowed(
  BuildContext context, {
  required VoidCallback onPressed,
  required String tooltip,
}) {
  if (ShellChromeScope.suppressesHubPostFab(context)) return null;
  return HubPostFab(onPressed: onPressed, tooltip: tooltip);
}
