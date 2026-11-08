import 'package:flutter/material.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/features/know_qatar/data/models/know_qatar_moment_models.dart';
import 'package:raabta/features/know_qatar/presentation/l10n/know_qatar_strings.dart';
import 'package:raabta/features/know_qatar/services/know_qatar_moments_analytics.dart';

class KnowQatarMomentsChipRow extends StatelessWidget {
  const KnowQatarMomentsChipRow({
    super.key,
    required this.locale,
    required this.selected,
    required this.chipOrder,
    required this.onSelected,
  });

  final String locale;
  final KnowQatarMomentId selected;
  final List<KnowQatarMomentId> chipOrder;
  final ValueChanged<KnowQatarMomentId> onSelected;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          KnowQatarStrings.t('kq_moments_chip_heading', locale),
          style: AppTypography.caption.copyWith(
            color: AppColors.textTertiary,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.3,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Material(
          color: Colors.transparent,
          child: SizedBox(
          height: 40,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: chipOrder.length,
            separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.xs),
            itemBuilder: (context, index) {
              final id = chipOrder[index];
              final selectedChip = id == selected;
              final labelKey = _titleKeyFor(id);
              return Semantics(
                button: true,
                selected: selectedChip,
                label: KnowQatarStrings.t(labelKey, locale),
                child: ChoiceChip(
                  label: Text(
                    KnowQatarStrings.t(labelKey, locale),
                    style: AppTypography.caption.copyWith(
                      fontWeight:
                          selectedChip ? FontWeight.w600 : FontWeight.w500,
                    ),
                  ),
                  selected: selectedChip,
                  showCheckmark: false,
                  visualDensity: VisualDensity.compact,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  selectedColor: AppColors.cyanGlow.withValues(alpha: 0.22),
                  backgroundColor:
                      AppColors.surfaceElevated.withValues(alpha: 0.55),
                  side: BorderSide(
                    color: selectedChip
                        ? AppColors.cyanGlow.withValues(alpha: 0.55)
                        : AppColors.textTertiary.withValues(alpha: 0.35),
                  ),
                  onSelected: (_) {
                    if (id != selected) {
                      KnowQatarMomentsAnalytics.momentsPickerUsed();
                      onSelected(id);
                    }
                  },
                ),
              );
            },
          ),
        ),
        ),
      ],
    );
  }

  static String _titleKeyFor(KnowQatarMomentId id) {
    switch (id) {
      case KnowQatarMomentId.justArrived:
        return 'kq_moment_just_arrived_title';
      case KnowQatarMomentId.startingChangingJob:
        return 'kq_moment_starting_job_title';
      case KnowQatarMomentId.bringingFamily:
        return 'kq_moment_bringing_family_title';
      case KnowQatarMomentId.hostingVisitors:
        return 'kq_moment_hosting_visitors_title';
      case KnowQatarMomentId.settingUpHome:
        return 'kq_moment_setting_up_home_title';
      case KnowQatarMomentId.visitingQatar:
        return 'kq_moment_visiting_title';
      case KnowQatarMomentId.goingHome:
        return 'kq_moment_going_home_title';
      case KnowQatarMomentId.whenSomethingGoesWrong:
        return 'kq_moment_something_wrong_title';
      case KnowQatarMomentId.allTopics:
        return 'kq_moment_all_topics_title';
    }
  }
}
