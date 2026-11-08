import 'package:flutter/material.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/widgets/hub/hub_layout_tokens.dart';

/// Compact hub filter chip — matches Housing hub filter rows.
Widget buildHubFilterChip({
  required Widget label,
  required bool selected,
  required ValueChanged<bool> onSelected,
}) {
  return _AnimatedHubFilterChip(
    label: label,
    selected: selected,
    onSelected: onSelected,
    selectedColor: AppColors.brandFamilyMain.withValues(alpha: 0.18),
    unselectedBackground:
        AppColors.isLight ? AppColors.surface : AppColors.glassSurface,
  );
}

/// Hub choice chip (advanced filters) — same visual grammar as [buildHubFilterChip].
Widget buildHubChoiceChip({
  required Widget label,
  required bool selected,
  required ValueChanged<bool> onSelected,
}) {
  return _AnimatedHubFilterChip(
    label: label,
    selected: selected,
    onSelected: onSelected,
    selectedColor: AppColors.brandFamilyMain.withValues(alpha: 0.18),
    unselectedBackground:
        AppColors.isLight ? AppColors.background : AppColors.glassSurface,
    useChoiceChip: true,
  );
}

class _AnimatedHubFilterChip extends StatefulWidget {
  const _AnimatedHubFilterChip({
    required this.label,
    required this.selected,
    required this.onSelected,
    required this.selectedColor,
    required this.unselectedBackground,
    this.useChoiceChip = false,
  });

  final Widget label;
  final bool selected;
  final ValueChanged<bool> onSelected;
  final Color selectedColor;
  final Color unselectedBackground;
  final bool useChoiceChip;

  @override
  State<_AnimatedHubFilterChip> createState() => _AnimatedHubFilterChipState();
}

class _AnimatedHubFilterChipState extends State<_AnimatedHubFilterChip>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  bool get _reduceMotion => MediaQuery.disableAnimationsOf(context);

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: HubLayoutTokens.filterChipSelectionDuration,
      value: widget.selected ? 1.0 : 0.0,
    );
  }

  @override
  void didUpdateWidget(covariant _AnimatedHubFilterChip oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selected == oldWidget.selected) return;
    if (_reduceMotion) {
      _controller.value = widget.selected ? 1.0 : 0.0;
      return;
    }
    if (widget.selected) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final blend = _controller.value;
        final background = Color.lerp(
          widget.unselectedBackground,
          widget.selectedColor,
          blend,
        )!;
        final borderColor = Color.lerp(
          AppColors.glassBorder,
          AppColors.brandFamilyMain.withValues(alpha: 0.5),
          blend,
        )!;
        final labelColor = Color.lerp(
          AppColors.textSecondary,
          AppColors.brandFamilyText,
          blend,
        )!;

        final chip = widget.useChoiceChip
            ? ChoiceChip(
                label: widget.label,
                selected: widget.selected,
                onSelected: widget.onSelected,
                backgroundColor: background,
                selectedColor: background,
                labelStyle: TextStyle(
                  color: labelColor,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  height: 1.2,
                ),
                side: BorderSide(color: borderColor),
                padding: const EdgeInsets.symmetric(horizontal: 13),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                ),
                showCheckmark: false,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                visualDensity: VisualDensity.compact,
              )
            : FilterChip(
                label: widget.label,
                selected: widget.selected,
                onSelected: widget.onSelected,
                backgroundColor: background,
                selectedColor: background,
                labelStyle: TextStyle(
                  color: labelColor,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  height: 1.2,
                ),
                side: BorderSide(color: borderColor),
                padding: const EdgeInsets.symmetric(horizontal: 13),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                ),
                showCheckmark: false,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                visualDensity: VisualDensity.compact,
              );

        return SizedBox(
          height: HubLayoutTokens.filterChipHeight,
          child: Center(child: chip),
        );
      },
    );
  }
}
