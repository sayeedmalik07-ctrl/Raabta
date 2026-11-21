import 'package:flutter/material.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/l10n/classifieds_compliance_strings.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/widgets/hub/hub_layout_tokens.dart';
import 'package:raabta/core/widgets/hub/hub_typography.dart';

/// Inline compliance notice (hub kit §4 NoticeBanner).
class HubNoticeBanner extends StatelessWidget {
  const HubNoticeBanner({
    super.key,
    required this.text,
    this.padding,
    this.semanticsLabel,
  });

  /// Localized host notice for the current locale.
  factory HubNoticeBanner.hostNotice({
    Key? key,
    required String locale,
    EdgeInsetsGeometry? padding,
  }) {
    final copy = ClassifiedsComplianceStrings.t('host_notice', locale);
    return HubNoticeBanner(
      key: key,
      text: copy,
      padding: padding,
      semanticsLabel: copy,
    );
  }

  final String text;
  final EdgeInsetsGeometry? padding;
  final String? semanticsLabel;

  @override
  Widget build(BuildContext context) {
    final banner = Semantics(
      container: true,
      label: semanticsLabel ?? text,
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
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          child: ExcludeSemantics(
            child: Text(
              text,
              style: HubTypography.noticeBannerBody,
            ),
          ),
        ),
      ),
    );

    if (padding == null) return banner;
    return Padding(padding: padding!, child: banner);
  }
}
