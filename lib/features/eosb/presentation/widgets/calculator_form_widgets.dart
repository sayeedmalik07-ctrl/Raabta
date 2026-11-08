import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/glass/glass_card.dart';
import 'package:raabta/core/glass/glass_container.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/core/widgets/glass_primary_button.dart';
import 'package:raabta/features/eosb/presentation/l10n/eosb_strings.dart';

/// Section header for EOSB / overtime calculator flows.
class CalculatorSectionHeader extends StatelessWidget {
  const CalculatorSectionHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.icon,
    this.accentColor = AppColors.emeraldGlow,
  });

  final String title;
  final String? subtitle;
  final IconData? icon;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icon != null) ...[
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    accentColor.withValues(alpha: 0.28),
                    accentColor.withValues(alpha: 0.06),
                  ],
                ),
                borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                border: Border.all(color: accentColor.withValues(alpha: 0.35)),
              ),
              child: Icon(icon, size: 18, color: accentColor),
            ),
            const SizedBox(width: AppSpacing.sm),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.title.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle!,
                    style: AppTypography.caption.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Glass card wrapper for grouped form sections.
class CalculatorFormSection extends StatelessWidget {
  const CalculatorFormSection({
    super.key,
    required this.child,
    this.glowColor,
    this.glowIntensity = 0.12,
  });

  final Widget child;
  final Color? glowColor;
  final double glowIntensity;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      glowColor: glowColor ?? AppColors.cyanGlow,
      glowIntensity: glowIntensity,
      child: child,
    );
  }
}

/// Premium text field inside glass styling.
class CalculatorTextField extends StatelessWidget {
  const CalculatorTextField({
    super.key,
    required this.controller,
    this.label,
    this.hint,
    this.prefix,
    this.suffix,
    this.icon,
    this.keyboardType = TextInputType.text,
    this.inputFormatters,
    this.onChanged,
    this.large = false,
  });

  final TextEditingController controller;
  final String? label;
  final String? hint;
  final String? prefix;
  final Widget? suffix;
  final IconData? icon;
  final TextInputType keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final ValueChanged<String>? onChanged;
  final bool large;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Text(
            label!,
            style: AppTypography.caption.copyWith(
              color: AppColors.textTertiary,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
        ],
        GlassContainer(
          padding: EdgeInsets.zero,
          borderRadius: AppSpacing.radiusSm,
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            inputFormatters: inputFormatters,
            onChanged: onChanged,
            style: large
                ? AppTypography.headline2.copyWith(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                  )
                : AppTypography.body.copyWith(color: AppColors.textPrimary),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: AppTypography.body.copyWith(
                color: AppColors.textTertiary,
              ),
              prefixIcon: icon != null
                  ? Icon(icon, color: AppColors.textTertiary, size: 20)
                  : null,
              prefixText: prefix,
              prefixStyle: AppTypography.body.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
              suffix: suffix,
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                horizontal: icon != null ? AppSpacing.sm : AppSpacing.md,
                vertical: large ? AppSpacing.md : AppSpacing.md,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Side-by-side date picker chips.
class CalculatorDateRow extends StatelessWidget {
  const CalculatorDateRow({
    super.key,
    required this.startLabel,
    required this.endLabel,
    required this.startDate,
    required this.endDate,
    required this.onStartTap,
    required this.onEndTap,
    this.locale = 'English',
  });

  final String startLabel;
  final String endLabel;
  final DateTime? startDate;
  final DateTime? endDate;
  final VoidCallback onStartTap;
  final VoidCallback onEndTap;
  final String locale;

  String _format(DateTime? date) {
    if (date == null) return EosbStrings.t('eosb_select_date', locale);
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _DateTile(
            label: startLabel,
            value: _format(startDate),
            filled: startDate != null,
            onTap: onStartTap,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: _DateTile(
            label: endLabel,
            value: _format(endDate),
            filled: endDate != null,
            onTap: onEndTap,
          ),
        ),
      ],
    );
  }
}

class _DateTile extends StatelessWidget {
  const _DateTile({
    required this.label,
    required this.value,
    required this.filled,
    required this.onTap,
  });

  final String label;
  final String value;
  final bool filled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      onTap: onTap,
      borderRadius: AppSpacing.radiusSm,
      glowColor: filled ? AppColors.cyanGlow : null,
      glowIntensity: filled ? 0.08 : 0,
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.calendar_today_outlined,
                size: 14,
                color: filled ? AppColors.cyanGlow : AppColors.textTertiary,
              ),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: Text(
                  label,
                  style: AppTypography.caption.copyWith(
                    color: AppColors.textTertiary,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            value,
            style: AppTypography.body.copyWith(
              color: filled ? AppColors.textPrimary : AppColors.textTertiary,
              fontWeight: filled ? FontWeight.w700 : FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

/// Selectable card for enum / option choices (avoids dropdown overflow).
class CalculatorChoiceTile<T> extends StatelessWidget {
  const CalculatorChoiceTile({
    super.key,
    required this.title,
    required this.selected,
    required this.onTap,
    this.subtitle,
    this.icon,
    this.accentColor = AppColors.emeraldGlow,
  });

  final String title;
  final String? subtitle;
  final bool selected;
  final VoidCallback onTap;
  final IconData? icon;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    final borderColor = selected
        ? accentColor.withValues(alpha: 0.65)
        : AppColors.glassBorder.withValues(alpha: 0.35);
    final fill = selected
        ? accentColor.withValues(alpha: 0.12)
        : AppColors.surface.withValues(alpha: 0.35);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.selectionClick();
          onTap();
        },
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        child: Ink(
          decoration: BoxDecoration(
            color: fill,
            borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
            border: Border.all(color: borderColor, width: selected ? 1.5 : 1),
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (icon != null) ...[
                  Icon(
                    icon,
                    size: 20,
                    color: selected ? accentColor : AppColors.textTertiary,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                ],
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: AppTypography.body.copyWith(
                          fontWeight:
                              selected ? FontWeight.w700 : FontWeight.w600,
                          color: selected
                              ? AppColors.textPrimary
                              : AppColors.textSecondary,
                        ),
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          subtitle!,
                          style: AppTypography.caption.copyWith(
                            color: AppColors.textTertiary,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                Icon(
                  selected
                      ? Icons.check_circle_rounded
                      : Icons.radio_button_unchecked,
                  size: 20,
                  color: selected ? accentColor : AppColors.textTertiary,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Opens a bottom sheet list picker for long option sets.
Future<T?> showCalculatorPickerSheet<T>({
  required BuildContext context,
  required String title,
  required List<CalculatorPickerOption<T>> options,
  T? selected,
}) {
  return showModalBottomSheet<T>(
    context: context,
    backgroundColor: AppColors.surfaceElevated,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (ctx) {
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.md,
            AppSpacing.lg,
            AppSpacing.lg,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(title, style: AppTypography.headline2),
              const SizedBox(height: AppSpacing.md),
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: options.length,
                  separatorBuilder: (_, i) =>
                      const SizedBox(height: AppSpacing.sm),
                  itemBuilder: (_, i) {
                    final opt = options[i];
                    final isSelected = opt.value == selected;
                    return CalculatorChoiceTile<T>(
                      title: opt.label,
                      subtitle: opt.subtitle,
                      selected: isSelected,
                      accentColor: AppColors.cyanGlow,
                      onTap: () => Navigator.pop(ctx, opt.value),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

class CalculatorPickerOption<T> {
  const CalculatorPickerOption({
    required this.value,
    required this.label,
    this.subtitle,
  });

  final T value;
  final String label;
  final String? subtitle;
}

/// Tappable summary row that opens [showCalculatorPickerSheet].
class CalculatorPickerField<T> extends StatelessWidget {
  const CalculatorPickerField({
    super.key,
    required this.label,
    required this.valueLabel,
    required this.onTap,
    this.icon = Icons.expand_more_rounded,
  });

  final String label;
  final String valueLabel;
  final VoidCallback onTap;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      onTap: onTap,
      borderRadius: AppSpacing.radiusSm,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.md,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTypography.caption.copyWith(
                    color: AppColors.textTertiary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  valueLabel,
                  style: AppTypography.body.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Icon(icon, color: AppColors.textTertiary, size: 22),
        ],
      ),
    );
  }
}

/// Premium toggle row (replaces SwitchListTile).
class CalculatorToggleTile extends StatelessWidget {
  const CalculatorToggleTile({
    super.key,
    required this.title,
    required this.value,
    required this.onChanged,
    this.subtitle,
    this.icon,
  });

  final String title;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (icon != null) ...[
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.surface.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(AppSpacing.radiusXs),
              ),
              child: Icon(icon, size: 18, color: AppColors.textSecondary),
            ),
            const SizedBox(width: AppSpacing.sm),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.body.copyWith(fontWeight: FontWeight.w600),
                ),
                if (subtitle != null)
                  Text(
                    subtitle!,
                    style: AppTypography.caption.copyWith(
                      color: AppColors.textTertiary,
                    ),
                  ),
              ],
            ),
          ),
          Switch.adaptive(
            value: value,
            activeTrackColor: AppColors.emeraldGlow.withValues(alpha: 0.5),
            activeThumbColor: AppColors.emeraldGlow,
            onChanged: (v) {
              HapticFeedback.selectionClick();
              onChanged(v);
            },
          ),
        ],
      ),
    );
  }
}

/// Featured action card (e.g. contract scan).
class CalculatorFeatureAction extends StatelessWidget {
  const CalculatorFeatureAction({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
    this.accentColor = AppColors.purpleGlow,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      onTap: onTap,
      glowColor: accentColor,
      glowIntensity: 0.18,
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  accentColor.withValues(alpha: 0.35),
                  accentColor.withValues(alpha: 0.08),
                ],
              ),
              borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
            ),
            child: Icon(icon, color: accentColor, size: 26),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.title.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: AppTypography.caption.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right_rounded, color: accentColor),
        ],
      ),
    );
  }
}

/// Live preview hero for calculator inputs.
class CalculatorLiveHero extends StatelessWidget {
  const CalculatorLiveHero({
    super.key,
    required this.title,
    required this.primaryValue,
    this.secondaryLabel,
    this.secondaryValue,
    this.chips = const [],
    this.accentColor = AppColors.emeraldGlow,
  });

  final String title;
  final String primaryValue;
  final String? secondaryLabel;
  final String? secondaryValue;
  final List<Widget> chips;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      glowColor: accentColor,
      glowIntensity: 0.22,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTypography.caption.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.4,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            primaryValue,
            style: AppTypography.display.copyWith(
              color: accentColor,
              fontSize: 34,
              fontWeight: FontWeight.w800,
              letterSpacing: -1,
            ),
          ),
          if (secondaryLabel != null && secondaryValue != null) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(
              '$secondaryLabel · $secondaryValue',
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
          if (chips.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.xs,
              children: chips,
            ),
          ],
        ],
      ),
    );
  }
}

class CalculatorMetricChip extends StatelessWidget {
  const CalculatorMetricChip({
    super.key,
    required this.label,
    required this.color,
    this.icon,
  });

  final String label;
  final Color color;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xxs,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppSpacing.radiusXs),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: color),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: AppTypography.caption.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

/// Sticky bottom bar with primary CTA — use inside [CalculatorScreenLayout].
class CalculatorStickyBar extends StatelessWidget {
  const CalculatorStickyBar({
    super.key,
    required this.label,
    required this.onPressed,
    this.loading = false,
    this.icon = Icons.calculate_outlined,
    this.accentColor = AppColors.emeraldGlow,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool loading;
  final IconData icon;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.lg,
        AppSpacing.md + MediaQuery.paddingOf(context).bottom,
      ),
      borderRadius: 0,
      blurSigma: 28,
      child: GlassPrimaryButton(
        label: label,
        expand: true,
        accentColor: accentColor,
        icon: icon,
        onPressed: loading ? null : onPressed,
      ),
    );
  }
}

/// Reliable scroll + sticky footer layout (avoids macOS bottomNavigationBar body collapse).
class CalculatorScreenLayout extends StatelessWidget {
  const CalculatorScreenLayout({
    super.key,
    required this.body,
    required this.footer,
  });

  final Widget body;
  final Widget footer;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(child: body),
        footer,
      ],
    );
  }
}

/// Horizontal segmented control for 2–3 compact options.
class CalculatorSegmentRow<T> extends StatelessWidget {
  const CalculatorSegmentRow({
    super.key,
    required this.options,
    required this.selected,
    required this.onSelected,
    this.accentColor = AppColors.cyanGlow,
  });

  final List<CalculatorSegmentOption<T>> options;
  final T selected;
  final ValueChanged<T> onSelected;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var i = 0; i < options.length; i++) ...[
          if (i > 0) const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: _SegmentButton(
              label: options[i].label,
              selected: options[i].value == selected,
              accentColor: accentColor,
              onTap: () {
                HapticFeedback.selectionClick();
                onSelected(options[i].value);
              },
            ),
          ),
        ],
      ],
    );
  }
}

class CalculatorSegmentOption<T> {
  const CalculatorSegmentOption({required this.value, required this.label});

  final T value;
  final String label;
}

class _SegmentButton extends StatelessWidget {
  const _SegmentButton({
    required this.label,
    required this.selected,
    required this.onTap,
    required this.accentColor,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        child: Ink(
          decoration: BoxDecoration(
            color: selected
                ? accentColor.withValues(alpha: 0.18)
                : AppColors.surface.withValues(alpha: 0.35),
            borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
            border: Border.all(
              color: selected
                  ? accentColor.withValues(alpha: 0.6)
                  : AppColors.glassBorder.withValues(alpha: 0.3),
              width: selected ? 1.5 : 1,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              vertical: AppSpacing.md,
              horizontal: AppSpacing.sm,
            ),
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: AppTypography.chipLabel.copyWith(
                color: selected ? accentColor : AppColors.textSecondary,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ),
    );
  }
}
