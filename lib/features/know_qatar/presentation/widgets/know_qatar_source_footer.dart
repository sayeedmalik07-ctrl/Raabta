import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/features/know_qatar/data/models/know_qatar_models.dart';
import 'package:raabta/features/know_qatar/presentation/l10n/know_qatar_strings.dart';
import 'package:url_launcher/url_launcher.dart';

class KnowQatarSourceFooter extends StatelessWidget {
  const KnowQatarSourceFooter({
    super.key,
    required this.section,
    required this.locale,
  });

  final KnowQatarSection section;
  final String locale;

  Future<void> _openSource() async {
    final uri = Uri.tryParse(section.sourceUrl);
    if (uri == null) return;
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final reviewed = DateFormat.yMMM().format(section.lastReviewed);
    final source = KnowQatarStrings.t(section.sourceLabelKey, locale);
    final text = KnowQatarStrings.t('kq_source_footer', locale)
        .replaceAll('{source}', source)
        .replaceAll('{date}', reviewed);

    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.md),
      child: Material(
        color: AppColors.surfaceElevated.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: _openSource,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: AppSpacing.xs + 2,
            ),
            child: Row(
              children: [
                Icon(Icons.verified_outlined, size: 16, color: AppColors.cyanGlow),
                const SizedBox(width: AppSpacing.xs),
                Expanded(
                  child: Text(
                    text,
                    style: AppTypography.caption.copyWith(
                      color: AppColors.textSecondary,
                      height: 1.35,
                    ),
                  ),
                ),
                Icon(Icons.open_in_new, size: 14, color: AppColors.cyanGlow),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
