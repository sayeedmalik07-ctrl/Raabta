import 'package:flutter/material.dart';
import 'package:raabta/core/widgets/hub/hub_loading_placeholder.dart';

/// Post Engine schema/form loading — hub kit skeleton (not spinner).
class PostFlowHubLoading extends StatelessWidget {
  const PostFlowHubLoading({super.key});

  static const loadingKey = Key('post_flow_hub_loading');

  @override
  Widget build(BuildContext context) {
    return Center(
      key: loadingKey,
      child: const HubLoadingPlaceholder(
        width: 320,
        height: 280,
        silhouette: HubLoadingSilhouette.formTool,
      ),
    );
  }
}
