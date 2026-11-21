import 'package:flutter/material.dart';
import 'package:raabta/core/background/animated_aurora_background.dart';

/// Unified premium shell — aurora on deep-link routes; tab uses parent aurora.
class AiChatShell extends StatelessWidget {
  const AiChatShell({
    super.key,
    required this.body,
    this.appBar,
    this.useAurora = true,
  });

  final Widget body;
  final PreferredSizeWidget? appBar;

  /// When embedded in Home tab, parent already renders [AnimatedAuroraBackground].
  final bool useAurora;

  @override
  Widget build(BuildContext context) {
    final scaffold = Scaffold(
      backgroundColor: Colors.transparent,
      appBar: appBar,
      body: body,
    );
    if (!useAurora) return scaffold;
    return AnimatedAuroraBackground(
      enableAnimation: true,
      ignoreSafeArea: true,
      child: scaffold,
    );
  }
}
