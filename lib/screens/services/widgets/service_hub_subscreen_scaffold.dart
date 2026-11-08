import 'package:flutter/material.dart';
import 'package:raabta/core/widgets/hub/hub_subscreen_scaffold.dart';

/// Services routes wrapper around shared [HubSubscreenScaffold].
class ServiceHubSubscreenScaffold extends StatelessWidget {
  const ServiceHubSubscreenScaffold({
    super.key,
    required this.title,
    required this.subtitle,
    required this.onBack,
    required this.body,
    this.bottomNavigationBar,
    this.headerTrailing,
    this.floatingActionButton,
  });

  final String title;
  final String subtitle;
  final VoidCallback onBack;
  final Widget body;
  final Widget? bottomNavigationBar;
  final Widget? headerTrailing;
  final Widget? floatingActionButton;

  static const headerKey = Key('services_hub_subscreen_header');

  @override
  Widget build(BuildContext context) {
    return HubSubscreenScaffold(
      headerKey: headerKey,
      title: title,
      subtitle: subtitle,
      onBack: onBack,
      body: body,
      bottomNavigationBar: bottomNavigationBar,
      headerTrailing: headerTrailing,
      floatingActionButton: floatingActionButton,
    );
  }
}
