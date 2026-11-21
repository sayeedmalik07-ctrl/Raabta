import 'package:flutter/material.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/l10n/classifieds_compliance_strings.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';

/// Persistent Decision 25 host notice on classified listing / chat surfaces.
class ClassifiedsHostNotice extends StatelessWidget {
  const ClassifiedsHostNotice({super.key, required this.locale, this.dense = false});

  final String locale;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: dense ? AppSpacing.sm : AppSpacing.md),
      child: Text(
        ClassifiedsComplianceStrings.t('host_notice', locale),
        style: (dense ? AppTypography.caption : AppTypography.bodySmall).copyWith(
          color: AppColors.textSecondary,
          height: 1.45,
        ),
      ),
    );
  }
}
