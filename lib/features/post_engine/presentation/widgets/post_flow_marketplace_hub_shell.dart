import 'package:flutter/material.dart';
import 'package:raabta/core/widgets/hub/hub_subscreen_scaffold.dart';
import 'package:raabta/features/post_engine/domain/models/post_vertical.dart';
import 'package:raabta/features/post_engine/l10n/post_engine_strings.dart';
import 'package:raabta/features/post_engine/presentation/post_flow_actions.dart';

/// Marketplace post flow chrome (hub kit) — wraps wizard steps.
class PostFlowMarketplaceHubShell extends StatelessWidget {
  const PostFlowMarketplaceHubShell({
    super.key,
    required this.locale,
    required this.child,
    this.subtitle,
    this.headerTrailing,
    this.onBack,
  });

  final String locale;
  final Widget child;
  final String? subtitle;
  final Widget? headerTrailing;
  final VoidCallback? onBack;

  static const headerKey = Key('post_flow_marketplace_hub_header');

  @override
  Widget build(BuildContext context) {
    return HubSubscreenScaffold(
      headerKey: headerKey,
      title: PostFlowActions.flowTitle(PostVertical.marketplace, locale),
      subtitle: subtitle ??
          PostEngineStrings.t('flow_subtitle_marketplace', locale),
      onBack: onBack ?? () => Navigator.of(context).pop(),
      headerTrailing: headerTrailing,
      body: child,
    );
  }
}
