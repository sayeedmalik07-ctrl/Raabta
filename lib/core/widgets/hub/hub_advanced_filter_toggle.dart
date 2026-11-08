import 'package:flutter/material.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/widgets/hub/hub_layout_tokens.dart';

class HubAdvancedFilterToggle extends StatelessWidget {
  const HubAdvancedFilterToggle({
    super.key,
    required this.expanded,
    required this.onToggle,
    this.semanticsLabel = 'Advanced filters',
  });

  final bool expanded;
  final VoidCallback onToggle;
  final String semanticsLabel;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: semanticsLabel,
      child: SizedBox(
        width: HubLayoutTokens.filterControlSize,
        height: HubLayoutTokens.filterControlSize,
        child: Material(
          color: AppColors.brandFamilyMain.withValues(alpha: 0.16),
          shape: const CircleBorder(),
          child: InkWell(
            onTap: onToggle,
            customBorder: const CircleBorder(),
            child: Icon(
              expanded ? Icons.filter_alt : Icons.tune,
              color: AppColors.brandFamilyMain,
              size: AppSpacing.iconMd,
            ),
          ),
        ),
      ),
    );
  }
}
