import 'package:flutter/material.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/glass/glass_card.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/features/eosb/domain/models/eosb_result.dart';
import 'package:raabta/features/eosb/presentation/l10n/eosb_strings.dart';

class EosbHeroCard extends StatefulWidget {
  const EosbHeroCard({
    super.key,
    required this.amount,
    required this.locale,
    this.confidenceScore,
    this.result,
    this.isReferenceEstimate = false,
  });

  final double amount;
  final String locale;
  final double? confidenceScore;
  final EosbResult? result;
  final bool isReferenceEstimate;

  @override
  State<EosbHeroCard> createState() => _EosbHeroCardState();
}

class _EosbHeroCardState extends State<EosbHeroCard>
    with SingleTickerProviderStateMixin {
  AnimationController? _controller;
  Animation<double>? _amountAnim;

  bool get _reduceMotion => MediaQuery.disableAnimationsOf(context);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_reduceMotion) {
      _controller?.dispose();
      _controller = null;
      _amountAnim = null;
      return;
    }
    if (_controller == null) {
      _initAnimation(from: 0, to: widget.amount);
      _controller!.forward();
    }
  }

  void _initAnimation({required double from, required double to}) {
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _amountAnim = Tween<double>(begin: from, end: to).animate(
      CurvedAnimation(parent: _controller!, curve: Curves.easeOutCubic),
    );
  }

  @override
  void didUpdateWidget(EosbHeroCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.amount != widget.amount && !_reduceMotion && _controller != null) {
      _amountAnim = Tween<double>(
        begin: _amountAnim!.value,
        end: widget.amount,
      ).animate(
        CurvedAnimation(parent: _controller!, curve: Curves.easeOutCubic),
      );
      _controller!
        ..reset()
        ..forward();
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  String get _statusKey {
    final comparison = widget.result?.comparison;
    if (comparison != null && comparison.isUnderpaid) {
      return 'eosb_status_underpayment';
    }
    if ((widget.confidenceScore ?? 1) < 0.6) {
      return 'eosb_status_low_confidence';
    }
    return 'eosb_status_ready';
  }

  String get _statusLabel => EosbStrings.t(_statusKey, widget.locale);

  Color get _statusColor {
    final comparison = widget.result?.comparison;
    if (comparison != null && comparison.isUnderpaid) {
      return AppColors.errorBright;
    }
    if ((widget.confidenceScore ?? 1) < 0.6) {
      return AppColors.accentGold;
    }
    return AppColors.successBright;
  }

  double get _displayAmount {
    if (_reduceMotion || _amountAnim == null) return widget.amount;
    return _amountAnim!.value;
  }

  @override
  Widget build(BuildContext context) {
    final confidence =
        widget.confidenceScore ?? widget.result?.explanation.confidenceScore;
    final heroColor = _statusColor;

    Widget cardContent(double animatedAmount) {
      final usd = eosbToUsd(animatedAmount);
      final inr = eosbToInr(animatedAmount);

      return GlassCard(
        padding: const EdgeInsets.all(AppSpacing.lg),
        glowColor: heroColor,
        glowIntensity: 0.2,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              EosbStrings.t(
                widget.isReferenceEstimate
                    ? 'eosb_reference_total'
                    : 'eosb_estimated_total',
                widget.locale,
              ),
              style: AppTypography.bodySmall,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              formatEosbCurrency(animatedAmount),
              style: AppTypography.display.copyWith(
                color: heroColor,
                fontSize: 36,
              ),
            ),
            if (confidence != null) ...[
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: [
                  _MetricChip(
                    label: EosbStrings.t('eosb_confidence', widget.locale),
                    value: '${(confidence * 100).round()}%',
                    color: AppColors.cyanGlow,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  _MetricChip(
                    label: EosbStrings.t('eosb_status', widget.locale),
                    value: _statusLabel,
                    color: _statusColor,
                  ),
                ],
              ),
            ],
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.xs,
              children: [
                _CurrencyChip(
                  label: '≈ USD ${usd.toStringAsFixed(0)}',
                  color: AppColors.info,
                ),
                _CurrencyChip(
                  label: '≈ INR ${inr.toStringAsFixed(0)}',
                  color: AppColors.purpleGlow,
                ),
              ],
            ),
          ],
        ),
      );
    }

    if (_reduceMotion || _amountAnim == null) {
      return cardContent(_displayAmount);
    }

    return AnimatedBuilder(
      animation: _amountAnim!,
      builder: (context, child) => cardContent(_displayAmount),
    );
  }
}

class _MetricChip extends StatelessWidget {
  const _MetricChip({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppTypography.caption.copyWith(fontSize: 9)),
          Text(
            value,
            style: AppTypography.chipLabel.copyWith(color: color, fontSize: 11),
          ),
        ],
      ),
    );
  }
}

class _CurrencyChip extends StatelessWidget {
  const _CurrencyChip({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xxs,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(AppSpacing.radiusXs),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(
        label,
        style: AppTypography.caption.copyWith(color: color),
      ),
    );
  }
}
