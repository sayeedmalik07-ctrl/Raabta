import 'package:flutter/material.dart';

import '../glass/glass_card.dart';
import '../spacing/app_spacing.dart';
import '../typography/app_typography.dart';
import 'glass_secondary_button.dart';

/// Presentation-only AI recommendation card.
class AISuggestionCard extends StatelessWidget {
  const AISuggestionCard({
    super.key,
    required this.title,
    required this.description,
    required this.icon,
    required this.accentColor,
    required this.onTap,
    this.actionLabel,
  });

  final String title;
  final String description;
  final IconData icon;
  final Color accentColor;
  final VoidCallback onTap;
  final String? actionLabel;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      onTap: onTap,
      borderRadius: AppSpacing.radiusLg,
      padding: const EdgeInsets.all(AppSpacing.cardPadding),
      glowColor: accentColor,
      glowIntensity: 0.12,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: accentColor.withValues(alpha: 0.10),
            ),
            child: Icon(icon, color: accentColor, size: AppSpacing.iconMd),
          ),
          const SizedBox(width: AppSpacing.sm + AppSpacing.xxs),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(title, style: AppTypography.title),
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  description,
                  style: AppTypography.bodySmall,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          if (actionLabel != null) ...[
            const SizedBox(width: AppSpacing.sm),
            GlassSecondaryButton(
              label: actionLabel!,
              onPressed: onTap,
            ),
          ],
        ],
      ),
    );
  }
}
