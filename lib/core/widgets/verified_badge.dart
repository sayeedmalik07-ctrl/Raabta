import 'package:flutter/material.dart';
import 'package:raabta/core/design/app_colors.dart';
import 'package:raabta/core/design/app_text_styles.dart';

enum VerifiedBadgeVariant { gold, green, blue }

class VerifiedBadge extends StatelessWidget {
  const VerifiedBadge({
    super.key,
    this.variant = VerifiedBadgeVariant.gold,
  });

  final VerifiedBadgeVariant variant;

  ({Color color, IconData icon, String label}) get _config {
    switch (variant) {
      case VerifiedBadgeVariant.gold:
        return (
          color: AppColors.verifiedGold,
          icon: Icons.verified,
          label: 'RAABTA VERIFIED',
        );
      case VerifiedBadgeVariant.green:
        return (
          color: AppColors.verifiedGreen,
          icon: Icons.groups,
          label: 'COMMUNITY VERIFIED',
        );
      case VerifiedBadgeVariant.blue:
        return (
          color: AppColors.verifiedBlue,
          icon: Icons.check_circle,
          label: 'LISTED',
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final config = _config;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: config.color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: config.color.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(config.icon, size: 14, color: config.color),
          const SizedBox(width: 4),
          Text(
            config.label,
            style: AppTextStyles.labelSmall.copyWith(
              color: config.color,
              letterSpacing: 0.8,
            ),
          ),
        ],
      ),
    );
  }
}
