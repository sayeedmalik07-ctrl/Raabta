import 'package:flutter/material.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/widgets/hub/hub_layout_tokens.dart';

/// Gradient centre-post FAB used on Housing hub (shell post entry).
class HubPostFab extends StatelessWidget {
  const HubPostFab({
    super.key,
    required this.onPressed,
    required this.tooltip,
  });

  final VoidCallback onPressed;
  final String tooltip;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: HubLayoutTokens.postFabSize,
      height: HubLayoutTokens.postFabSize,
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            colors: [AppColors.brandFamilyMain, AppColors.brandFamilyDark],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.brandFamilyMain.withValues(alpha: 0.35),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: FloatingActionButton(
          onPressed: onPressed,
          tooltip: tooltip,
          backgroundColor: Colors.transparent,
          elevation: 0,
          shape: const CircleBorder(),
          child: Icon(
            Icons.add,
            color: Theme.of(context).colorScheme.onPrimary,
            size: 28,
          ),
        ),
      ),
    );
  }
}
