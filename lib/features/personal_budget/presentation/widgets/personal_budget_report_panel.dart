import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/glass/glass_card.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/features/home/widgets/home_section_header.dart';
import 'package:raabta/features/personal_budget/presentation/l10n/personal_budget_strings.dart';
import 'package:raabta/features/personal_budget/services/personal_budget_report_service.dart';

class PersonalBudgetReportPanel extends StatelessWidget {
  const PersonalBudgetReportPanel({
    super.key,
    required this.report,
    required this.locale,
  });

  final PersonalBudgetReport report;
  final String locale;

  @override
  Widget build(BuildContext context) {
    final dateLabel = DateFormat.yMMMMd().format(report.generatedAt);

    return GlassCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      borderRadius: AppSpacing.radiusLg,
      glowColor: AppColors.emeraldGlow,
      glowIntensity: 0.12,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          HomeSectionHeader(
            overline: PersonalBudgetStrings.t('pb_report_overline', locale),
            title: report.title,
            subtitle: dateLabel,
            leadingIcon: Icons.description_outlined,
          ),
          const SizedBox(height: AppSpacing.lg),
          for (var i = 0; i < report.sections.length; i++) ...[
            if (i > 0) const SizedBox(height: AppSpacing.md),
            _ReportSection(section: report.sections[i]),
          ],
        ],
      ),
    );
  }
}

class _ReportSection extends StatelessWidget {
  const _ReportSection({required this.section});

  final PersonalBudgetReportSection section;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          section.heading,
          style: AppTypography.subtitle.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          section.body,
          style: AppTypography.bodySmall.copyWith(
            color: AppColors.textOnGlassMuted,
            height: 1.45,
          ),
        ),
        if (section.bullets.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.sm),
          for (final bullet in section.bullets)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '• ',
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.emeraldGlow,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      bullet,
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textOnGlassMuted,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ],
    );
  }
}
