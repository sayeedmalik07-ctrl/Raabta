import 'package:flutter/material.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/l10n/classifieds_compliance_strings.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';

/// Non-affiliation + information-only notices (Decision 25 Part G).
class RaabtaPlatformNoticesPanel extends StatelessWidget {
  const RaabtaPlatformNoticesPanel({
    super.key,
    required this.locale,
    this.dense = false,
  });

  final String locale;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    final style = (dense ? AppTypography.caption : AppTypography.bodySmall)
        .copyWith(color: AppColors.textSecondary, height: 1.45);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          ClassifiedsComplianceStrings.t('non_affiliation_notice', locale),
          style: style,
        ),
        SizedBox(height: dense ? AppSpacing.sm : AppSpacing.md),
        Text(
          ClassifiedsComplianceStrings.t('information_only_notice', locale),
          style: style,
        ),
      ],
    );
  }
}
