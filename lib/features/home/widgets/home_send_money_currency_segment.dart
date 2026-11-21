import 'package:flutter/material.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/core/widgets/horizontal_scroll_fade.dart';
import 'package:raabta/features/home/utils/home_send_money_rate_utils.dart';
import 'package:raabta/screens/money/widgets/money_hub_primitives.dart'
    show moneyHubSelectionHaptic;

/// Kit currency filter pills — all [targetCurrencyCodes] in a horizontal rail.
class HomeSendMoneyCurrencySegment extends StatelessWidget {
  const HomeSendMoneyCurrencySegment({
    super.key,
    required this.selectedCode,
    required this.onSelect,
    this.goldMain,
    this.goldText,
  });

  final String selectedCode;
  final ValueChanged<String> onSelect;
  final Color? goldMain;
  final Color? goldText;

  static const _rowHeight = 36.0;

  @override
  Widget build(BuildContext context) {
    final main = goldMain ?? AppColors.goldFamilyMain;
    final text = goldText ?? AppColors.goldFamilyText;

    return HorizontalScrollFade(
      height: _rowHeight,
      fadeWidth: 20,
      builder: (controller) {
        return ListView.separated(
          controller: controller,
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          itemCount: homeSendMoneyKitSegmentCodes.length,
          separatorBuilder: (_, _) => const SizedBox(width: 8),
          itemBuilder: (context, index) {
            final code = homeSendMoneyKitSegmentCodes[index];
            return _CurrencySegmentPill(
              code: code,
              selected: selectedCode == code,
              goldMain: main,
              goldText: text,
              onTap: () {
                moneyHubSelectionHaptic();
                onSelect(code);
              },
            );
          },
        );
      },
    );
  }
}

class _CurrencySegmentPill extends StatelessWidget {
  const _CurrencySegmentPill({
    required this.code,
    required this.selected,
    required this.goldMain,
    required this.goldText,
    required this.onTap,
  });

  final String code;
  final bool selected;
  final Color goldMain;
  final Color goldText;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 6),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            color: selected
                ? goldMain.withValues(alpha: 0.22)
                : Colors.transparent,
            border: Border.all(
              color: selected
                  ? goldMain.withValues(alpha: 0.55)
                  : AppColors.textPrimary.withValues(alpha: 0.16),
            ),
          ),
          child: Text(
            code,
            style: AppTypography.caption.copyWith(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: selected ? goldText : AppColors.textOnGlassMuted,
            ),
          ),
        ),
      ),
    );
  }
}
