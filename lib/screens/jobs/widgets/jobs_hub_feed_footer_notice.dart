import 'package:flutter/material.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/widgets/hub/hub_layout_tokens.dart';
import 'package:raabta/core/widgets/hub/hub_typography.dart';
import 'package:raabta/screens/jobs/l10n/jobs_strings.dart';

/// Jobs feed footer — kit copy via [JobsStrings], same presentation as hub notice.
class JobsHubFeedFooterNotice extends StatelessWidget {
  const JobsHubFeedFooterNotice({
    super.key,
    required this.locale,
    this.dense = true,
  });

  final String locale;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    final message = JobsStrings.t('jobs_hub_feed_footer_notice', locale);
    return Padding(
      padding: EdgeInsetsDirectional.fromSTEB(
        AppSpacing.xl,
        AppSpacing.lg,
        AppSpacing.xl,
        dense ? 100 : AppSpacing.xxl,
      ),
      child: Semantics(
        container: true,
        label: message,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: AppColors.textPrimary.withValues(
              alpha: HubLayoutTokens.noticeBannerTintAlpha,
            ),
            borderRadius: BorderRadius.circular(
              HubLayoutTokens.noticeBannerRadius,
            ),
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: dense ? AppSpacing.sm : AppSpacing.md,
            ),
            child: ExcludeSemantics(
              child: Text(
                message,
                style: HubTypography.noticeBannerBody,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
