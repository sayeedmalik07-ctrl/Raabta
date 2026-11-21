import 'package:flutter/material.dart';
import 'package:raabta/core/background/animated_aurora_background.dart';
import 'package:raabta/core/widgets/hub/hub_landing_header.dart';

/// Hub kit sub-screen shell (T2/T3): aurora + [HubLandingHeader] + body.
class HubSubscreenScaffold extends StatelessWidget {
  const HubSubscreenScaffold({
    super.key,
    required this.title,
    required this.subtitle,
    required this.onBack,
    required this.body,
    this.bottomNavigationBar,
    this.headerTrailing,
    this.floatingActionButton,
    this.headerKey,
  });

  final String title;
  final String subtitle;
  final VoidCallback onBack;
  final Widget body;
  final Widget? bottomNavigationBar;
  final Widget? headerTrailing;
  final Widget? floatingActionButton;
  final Key? headerKey;

  @override
  Widget build(BuildContext context) {
    return AnimatedAuroraBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        bottomNavigationBar: bottomNavigationBar,
        floatingActionButton: floatingActionButton,
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              KeyedSubtree(
                key: headerKey,
                child: HubLandingHeader(
                  title: title,
                  subtitle: subtitle,
                  onBack: onBack,
                  trailing: headerTrailing,
                ),
              ),
              Expanded(child: body),
            ],
          ),
        ),
      ),
    );
  }
}
