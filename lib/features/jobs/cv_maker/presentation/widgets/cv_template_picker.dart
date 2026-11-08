import 'package:flutter/material.dart';
import 'package:raabta/config/monetization_state.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/features/jobs/cv_maker/domain/cv_template_catalog.dart';
import 'package:raabta/features/jobs/cv_maker/l10n/cv_strings.dart';
import 'package:raabta/features/jobs/cv_maker/domain/models/cv_document.dart';
import 'package:raabta/features/jobs/cv_maker/presentation/widgets/cv_ats_badge.dart';
import 'package:raabta/features/jobs/cv_maker/presentation/widgets/cv_preview_content.dart';

/// Live-data template picker with ATS badges (4-template library).
class CvTemplatePicker extends StatelessWidget {
  const CvTemplatePicker({
    super.key,
    required this.cv,
    required this.selected,
    required this.onSelected,
    required this.locale,
  });

  final CvDocument cv;
  final CvTemplateId selected;
  final ValueChanged<CvTemplateId> onSelected;
  final String locale;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          CvStrings.t('cv_template_picker_title', locale),
          style: AppTypography.subtitle,
        ),
        const SizedBox(height: AppSpacing.sm),
        SizedBox(
          height: 220,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: CvTemplateCatalog.ordered.length,
            separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.md),
            itemBuilder: (context, index) {
              final id = CvTemplateCatalog.ordered[index];
              final def = CvTemplateCatalog.definitionFor(id);
              final previewCv = cv.copyWith(templateId: id);
              final ats = def.atsFor(previewCv);
              final isSelected = selected == id;

              return GestureDetector(
                onTap: () => onSelected(id),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  width: 168,
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.brandFamilyMain
                          : AppColors.surfaceElevated,
                      width: isSelected ? 2 : 1,
                    ),
                    color: AppColors.surface.withValues(alpha: 0.4),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        id == CvTemplateId.premium &&
                                !MonetizationState.showPremiumTierUi
                            ? 'Visual'
                            : def.displayName,
                        style: AppTypography.subtitle.copyWith(
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 4),
                      CvAtsBadge(compatibility: ats, compact: true),
                      const SizedBox(height: AppSpacing.xs),
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: IgnorePointer(
                            child: FittedBox(
                              fit: BoxFit.cover,
                              alignment: Alignment.topCenter,
                              child: SizedBox(
                                width: 320,
                                child: CvPreviewContent(
                                  cv: previewCv,
                                  templateOverride: id,
                                  compact: true,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xxs),
                      Text(
                        def.pickerSubtitle,
                        style: AppTypography.caption.copyWith(
                          color: AppColors.textTertiary,
                          fontSize: 10,
                          height: 1.3,
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
