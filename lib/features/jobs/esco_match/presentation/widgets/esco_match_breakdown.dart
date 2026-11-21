import 'package:flutter/material.dart';
import 'package:raabta/core/design/app_colors.dart';
import 'package:raabta/core/design/app_spacing.dart';
import 'package:raabta/core/design/app_text_styles.dart';
import 'package:raabta/features/jobs/esco_match/domain/models/esco_job_match_models.dart';
import 'package:raabta/features/jobs/esco_match/presentation/l10n/esco_match_strings.dart';

/// Explainable matched / missing ESCO skill chips for Jobs Screen match cards.
class EscoMatchBreakdown extends StatelessWidget {
  const EscoMatchBreakdown({
    super.key,
    required this.matchedSkills,
    required this.missingSkills,
    required this.blockedQualifications,
    required this.overlapPercent,
    required this.locale,
    this.maxPerSection = 4,
  });

  final List<EscoSkillMatchItem> matchedSkills;
  final List<EscoSkillMatchItem> missingSkills;
  final List<String> blockedQualifications;
  final int overlapPercent;
  final String locale;
  final int maxPerSection;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          EscoMatchStrings.tf(
            'esco_match_skill_overlap',
            locale,
            {'percent': '$overlapPercent'},
          ),
          style: AppTextStyles.labelSmall.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        if (matchedSkills.isNotEmpty) ...[
          const SizedBox(height: 6),
          _sectionLabel(
            EscoMatchStrings.t('esco_match_matched_label', locale),
            AppColors.success,
          ),
          const SizedBox(height: 4),
          _skillWrap(
            matchedSkills.take(maxPerSection),
            AppColors.success,
            locale,
          ),
        ],
        if (missingSkills.isNotEmpty) ...[
          const SizedBox(height: 6),
          _sectionLabel(
            EscoMatchStrings.t('esco_match_missing_label', locale),
            AppColors.warning,
          ),
          const SizedBox(height: 4),
          _skillWrap(
            missingSkills.take(maxPerSection),
            AppColors.warning,
            locale,
          ),
        ],
        if (blockedQualifications.isNotEmpty) ...[
          const SizedBox(height: 6),
          _sectionLabel(
            EscoMatchStrings.t('esco_match_blocked_label', locale),
            AppColors.error,
          ),
          const SizedBox(height: 4),
          Wrap(
            spacing: 4,
            runSpacing: 4,
            children: blockedQualifications
                .map(
                  (q) => _chip(q, AppColors.error),
                )
                .toList(growable: false),
          ),
        ],
      ],
    );
  }

  Widget _sectionLabel(String text, Color color) {
    return Text(
      text,
      style: AppTextStyles.labelSmall.copyWith(
        color: color,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.3,
      ),
    );
  }

  Widget _skillWrap(
    Iterable<EscoSkillMatchItem> items,
    Color color,
    String locale,
  ) {
    return Wrap(
      spacing: 4,
      runSpacing: 4,
      children: items
          .map((item) => _chip(item.labelForLocale(locale), color))
          .toList(growable: false),
    );
  }

  Widget _chip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        border: Border.all(color: color.withValues(alpha: 0.35)),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 9,
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
