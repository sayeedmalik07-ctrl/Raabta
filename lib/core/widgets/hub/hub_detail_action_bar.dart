import 'package:flutter/material.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/design/app_radius.dart';
import 'package:raabta/core/design/app_spacing.dart';
import 'package:raabta/core/spacing/app_spacing.dart' as hub_spacing;

/// Sticky listing detail actions (hub kit §4 DetailActionBar).
///
/// Flag-gated primaries are omitted by passing null [primaryLabel] / [onPrimary].
/// When both primary and secondary are absent, only save/share show (if provided).
class HubDetailActionBar extends StatelessWidget {
  const HubDetailActionBar({
    super.key,
    this.primaryLabel,
    this.onPrimary,
    this.secondaryLabel,
    this.onSecondary,
    required this.isSaved,
    required this.onSave,
    required this.onShare,
    this.saveTooltip = 'Save',
    this.shareTooltip = 'Share',
    this.backgroundColor,
  });

  final String? primaryLabel;
  final VoidCallback? onPrimary;
  final String? secondaryLabel;
  final VoidCallback? onSecondary;
  final bool isSaved;
  final VoidCallback onSave;
  final VoidCallback onShare;
  final String saveTooltip;
  final String shareTooltip;
  final Color? backgroundColor;

  bool get _showsPrimary =>
      primaryLabel != null &&
      primaryLabel!.trim().isNotEmpty &&
      onPrimary != null;

  bool get _showsSecondary =>
      secondaryLabel != null &&
      secondaryLabel!.trim().isNotEmpty &&
      onSecondary != null;

  @override
  Widget build(BuildContext context) {
    if (!_showsPrimary && !_showsSecondary) {
      return SafeArea(
        top: false,
        child: Material(
          color: backgroundColor ?? AppColors.surface,
          elevation: 8,
          child: Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(
              hub_spacing.AppSpacing.xl,
              AppSpacing.md,
              hub_spacing.AppSpacing.xl,
              AppSpacing.md,
            ),
            child: _IconActions(
              isSaved: isSaved,
              onSave: onSave,
              onShare: onShare,
              saveTooltip: saveTooltip,
              shareTooltip: shareTooltip,
            ),
          ),
        ),
      );
    }

    return SafeArea(
      top: false,
      child: Material(
        color: backgroundColor ?? AppColors.surface,
        elevation: 8,
        child: Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(
            hub_spacing.AppSpacing.xl,
            AppSpacing.md,
            hub_spacing.AppSpacing.xl,
            AppSpacing.md,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (_showsPrimary)
                Expanded(
                  flex: _showsSecondary ? 1 : 4,
                  child: FilledButton(
                    onPressed: onPrimary,
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.brandFamilyMain,
                      foregroundColor: Theme.of(context).colorScheme.onPrimary,
                      minimumSize: const Size(48, 48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadius.md),
                      ),
                    ),
                    child: Text(
                      primaryLabel!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              if (_showsPrimary && _showsSecondary)
                const SizedBox(width: AppSpacing.sm),
              if (_showsSecondary)
                Expanded(
                  flex: 1,
                  child: OutlinedButton(
                    onPressed: onSecondary,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.brandFamilyMain,
                      side: BorderSide(
                        color: AppColors.brandFamilyMain.withValues(alpha: 0.5),
                      ),
                      minimumSize: const Size(48, 48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadius.md),
                      ),
                    ),
                    child: Text(
                      secondaryLabel!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              const SizedBox(width: AppSpacing.sm),
              _IconActions(
                isSaved: isSaved,
                onSave: onSave,
                onShare: onShare,
                saveTooltip: saveTooltip,
                shareTooltip: shareTooltip,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _IconActions extends StatelessWidget {
  const _IconActions({
    required this.isSaved,
    required this.onSave,
    required this.onShare,
    required this.saveTooltip,
    required this.shareTooltip,
  });

  final bool isSaved;
  final VoidCallback onSave;
  final VoidCallback onShare;
  final String saveTooltip;
  final String shareTooltip;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _CircleIconButton(
          tooltip: saveTooltip,
          icon: isSaved ? Icons.favorite : Icons.favorite_border,
          onPressed: onSave,
          iconColor: isSaved
              ? AppColors.brandFamilyMain
              : AppColors.textSecondary,
        ),
        const SizedBox(width: AppSpacing.xs),
        _CircleIconButton(
          tooltip: shareTooltip,
          icon: Icons.ios_share_outlined,
          onPressed: onShare,
        ),
      ],
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  const _CircleIconButton({
    required this.tooltip,
    required this.icon,
    required this.onPressed,
    this.iconColor,
  });

  final String tooltip;
  final IconData icon;
  final VoidCallback onPressed;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: tooltip,
      onPressed: onPressed,
      style: IconButton.styleFrom(
        minimumSize: const Size(48, 48),
        tapTargetSize: MaterialTapTargetSize.padded,
        side: BorderSide(
          color: AppColors.textPrimary.withValues(alpha: 0.12),
        ),
        shape: const CircleBorder(),
      ),
      icon: Icon(icon, color: iconColor ?? AppColors.textPrimary),
    );
  }
}
