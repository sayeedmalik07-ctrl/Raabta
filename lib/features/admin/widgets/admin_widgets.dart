import 'package:flutter/material.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';

class AdminModeChip extends StatelessWidget {
  const AdminModeChip({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFFF4444).withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0xFFFF6B35)),
      ),
      child: const Text(
        'ADMIN MODE',
        style: TextStyle(
          color: Color(0xFFFF6B35),
          fontSize: 10,
          fontWeight: FontWeight.w800,
          letterSpacing: 1,
        ),
      ),
    );
  }
}

class AdminAppBar extends StatelessWidget implements PreferredSizeWidget {
  const AdminAppBar({
    super.key,
    required this.title,
    this.actions,
  });

  final String title;
  final List<Widget>? actions;

  static const adminAccent = Color(0xFFFF6B35);

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: const Color(0xFF1A0A0A).withValues(alpha: 0.95),
      elevation: 0,
      iconTheme: IconThemeData(color: AppColors.textPrimary),
      title: Row(
        children: [
          Flexible(
            child: Text(
              title,
              style: AppTypography.title.copyWith(color: AppColors.textPrimary),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          const AdminModeChip(),
        ],
      ),
      actions: actions,
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(2),
        child: Container(
          height: 2,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFFF4444), Color(0xFFFFB627)],
            ),
          ),
        ),
      ),
    );
  }
}

class AdminStatCard extends StatelessWidget {
  const AdminStatCard({
    super.key,
    required this.label,
    required this.value,
    this.subtitle,
    this.icon,
    this.badgeCount,
    this.onTap,
  });

  final String label;
  final String value;
  final String? subtitle;
  final IconData? icon;
  final int? badgeCount;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.glassSurface,
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            border: Border.all(color: const Color(0xFFFF6B35).withValues(alpha: 0.25)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (icon != null)
                Badge(
                  isLabelVisible: badgeCount != null && badgeCount! > 0,
                  label: Text(
                    badgeCount! > 99 ? '99+' : '${badgeCount ?? 0}',
                    style: const TextStyle(fontSize: 10),
                  ),
                  child: Icon(icon, color: const Color(0xFFFFB627), size: 20),
                ),
              if (icon != null) const SizedBox(height: AppSpacing.sm),
              Text(
                value,
                style: AppTypography.headline1.copyWith(
                  color: AppColors.textPrimary,
                  fontSize: 24,
                ),
              ),
              const SizedBox(height: 4),
              Text(label, style: AppTypography.bodySmall),
              if (subtitle != null) ...[
                const SizedBox(height: 4),
                Text(
                  subtitle!,
                  style: AppTypography.caption.copyWith(
                    color: const Color(0xFFFFB627),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
