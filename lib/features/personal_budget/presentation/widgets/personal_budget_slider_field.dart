import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/glass/glass_card.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';

class PersonalBudgetSliderField extends StatefulWidget {
  const PersonalBudgetSliderField({
    super.key,
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
    this.hint,
    this.divisions = 100,
    this.accentColor = AppColors.emeraldGlow,
  });

  final String label;
  final String? hint;
  final double value;
  final double min;
  final double max;
  final ValueChanged<double> onChanged;
  final int divisions;
  final Color accentColor;

  @override
  State<PersonalBudgetSliderField> createState() =>
      _PersonalBudgetSliderFieldState();
}

class _PersonalBudgetSliderFieldState extends State<PersonalBudgetSliderField> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: _formatValue(widget.value));
  }

  @override
  void didUpdateWidget(covariant PersonalBudgetSliderField oldWidget) {
    super.didUpdateWidget(oldWidget);
    final formatted = _formatValue(widget.value);
    if (_controller.text != formatted &&
        double.tryParse(_controller.text) != widget.value) {
      _controller.text = formatted;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _formatValue(double v) {
    if (v == v.roundToDouble()) return v.toStringAsFixed(0);
    return v.toStringAsFixed(2);
  }

  void _applyValue(double v, {bool haptic = false}) {
    final clamped = v.clamp(widget.min, widget.max);
    if (haptic) HapticFeedback.selectionClick();
    widget.onChanged(clamped);
    _controller.text = _formatValue(clamped);
  }

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      borderRadius: AppSpacing.radiusLg,
      glowIntensity: 0.06,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.label,
                      style: AppTypography.subtitle,
                    ),
                    if (widget.hint != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        widget.hint!,
                        style: AppTypography.caption.copyWith(
                          color: AppColors.textOnGlassMuted,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              SizedBox(
                width: 120,
                child: TextField(
                  controller: _controller,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  textAlign: TextAlign.end,
                  style: AppTypography.tabular(
                    AppTypography.body.copyWith(
                      color: widget.accentColor,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  decoration: InputDecoration(
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: AppSpacing.xs,
                    ),
                    prefixText: 'QAR ',
                    filled: true,
                    fillColor: AppColors.surfaceElevated.withValues(alpha: 0.4),
                    border: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(AppSpacing.radiusSm),
                      borderSide:
                          BorderSide(color: AppColors.glassBorderBright),
                    ),
                  ),
                  onSubmitted: (text) {
                    _applyValue(double.tryParse(text.trim()) ?? widget.value);
                  },
                  onChanged: (text) {
                    final parsed = double.tryParse(text.trim());
                    if (parsed != null) {
                      widget.onChanged(parsed.clamp(widget.min, widget.max));
                    }
                  },
                ),
              ),
            ],
          ),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: widget.accentColor,
              inactiveTrackColor: AppColors.glassBorderBright,
              thumbColor: widget.accentColor,
              overlayColor: widget.accentColor.withValues(alpha: 0.15),
              trackHeight: 4,
            ),
            child: Slider(
              value: widget.value.clamp(widget.min, widget.max),
              min: widget.min,
              max: widget.max,
              divisions: widget.divisions,
              onChangeEnd: (_) => HapticFeedback.lightImpact(),
              onChanged: (v) => _applyValue(v),
            ),
          ),
        ],
      ),
    );
  }
}
