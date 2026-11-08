import 'package:flutter/material.dart';

import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/features/home/domain/home_chip_status.dart';
import '../glass/glass_card.dart';
import '../spacing/app_spacing.dart';
import '../typography/app_typography.dart';

/// Reusable horizontal shortcut chip for essentials and category shortcuts.
class GlassChip extends StatelessWidget {
  const GlassChip({
    super.key,
    required this.icon,
    required this.label,
    required this.accentColor,
    required this.onTap,
    this.compact = false,
    this.surfaceGlowColor,
    this.glowIntensity = 0.04,
    this.status = const HomeChipStatus.ready(line: ''),
  });

  final IconData icon;
  final String label;

  /// Icon and status-indicator accent — surface glow uses [surfaceGlowColor].
  final Color accentColor;
  final VoidCallback onTap;
  final bool compact;
  final Color? surfaceGlowColor;
  final double glowIntensity;
  final HomeChipStatus status;

  static const double compactWidth = 64;
  static const double compactHeight = 64;

  @override
  Widget build(BuildContext context) {
    final semanticsLabel = status.isLoading || status.line.isEmpty
        ? label
        : '$label, ${status.line}';

    return Semantics(
      button: true,
      label: semanticsLabel,
      child: GlassCard(
        onTap: onTap,
        width: compact ? compactWidth : null,
        height: compact ? compactHeight : 48,
        borderRadius: compact ? AppSpacing.radiusMd : AppSpacing.radiusFull,
        padding: EdgeInsets.symmetric(
          horizontal: compact ? AppSpacing.xs : AppSpacing.md,
          vertical: compact ? AppSpacing.xs : 0,
        ),
        glowColor: surfaceGlowColor ?? AppColors.cyanGlow,
        glowIntensity: glowIntensity,
        child: compact
            ? _CompactChipBody(
                icon: icon,
                label: label,
                accentColor: accentColor,
              )
            : _StandardChipBody(
                icon: icon,
                label: label,
                accentColor: accentColor,
              ),
      ),
    );
  }
}

class _StandardChipBody extends StatelessWidget {
  const _StandardChipBody({
    required this.icon,
    required this.label,
    required this.accentColor,
  });

  final IconData icon;
  final String label;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 3,
          height: 24,
          decoration: BoxDecoration(
            color: accentColor,
            borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
            boxShadow: [
              BoxShadow(
                color: accentColor.withValues(alpha: 0.08),
                blurRadius: AppSpacing.glassGlowBlur,
                spreadRadius: 0,
              ),
            ],
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Icon(icon, size: 18, color: accentColor),
        const SizedBox(width: AppSpacing.sm),
        Text(
          label,
          style: AppTypography.chipLabel.copyWith(
            color: AppColors.textOnGlassSecondary,
          ),
        ),
      ],
    );
  }
}

class _CompactChipBody extends StatelessWidget {
  const _CompactChipBody({
    required this.icon,
    required this.label,
    required this.accentColor,
  });

  final IconData icon;
  final String label;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: 22, color: accentColor),
        const SizedBox(height: AppSpacing.xxs),
        Text(
          label,
          style: AppTypography.chipLabel.copyWith(
            color: AppColors.textOnGlassSecondary,
            fontSize: 10,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
