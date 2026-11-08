import 'package:flutter/material.dart';
import 'package:raabta/core/icons/raabta_icon.dart';
import 'package:raabta/features/global_search/presentation/widgets/global_search_presentation_tokens.dart';

/// Squircle icon chip for category-scoped search hits.
class GlobalSearchCategoryIconChip extends StatelessWidget {
  const GlobalSearchCategoryIconChip({
    super.key,
    required this.icon,
    required this.accent,
    this.size = GlobalSearchPresentationTokens.iconChipSize,
  });

  final IconData icon;
  final Color accent;
  final double size;

  @override
  Widget build(BuildContext context) {
    final radius = GlobalSearchPresentationTokens.iconChipRadius;
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        color: accent.withValues(alpha: 0.14),
        border: Border.all(color: accent.withValues(alpha: 0.28)),
      ),
      child: SizedBox(
        width: size,
        height: size,
        child: Center(
          child: RaabtaIcon(
            icon,
            size: 20,
            color: accent,
          ),
        ),
      ),
    );
  }
}
