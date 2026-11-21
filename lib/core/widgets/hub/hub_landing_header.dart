import 'package:flutter/material.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/widgets/hub/hub_typography.dart';

/// Title block for hub landing tabs — back affordance + optional trailing action.
class HubLandingHeader extends StatelessWidget {
  const HubLandingHeader({
    super.key,
    required this.title,
    required this.subtitle,
    required this.onBack,
    this.trailing,
    this.compactBackTitleGap = false,
    this.showBack = true,
  });

  final String title;
  final String subtitle;
  final VoidCallback onBack;
  final Widget? trailing;

  /// Tighter icon padding + slight title pull-in (Jobs hub). Default keeps Housing layout.
  final bool compactBackTitleGap;

  /// Root hub tabs (e.g. Money) may hide the back affordance while keeping [onBack] for API parity.
  final bool showBack;

  static IconData _backIcon(BuildContext context) {
    return Directionality.of(context) == TextDirection.rtl
        ? Icons.arrow_forward
        : Icons.arrow_back;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (showBack)
          IconButton(
            onPressed: onBack,
            style: IconButton.styleFrom(
              padding: EdgeInsets.symmetric(
                horizontal: compactBackTitleGap ? AppSpacing.xs : AppSpacing.sm,
                vertical: AppSpacing.sm,
              ),
              minimumSize: const Size(48, 48),
              tapTargetSize: MaterialTapTargetSize.padded,
            ),
            icon: Icon(_backIcon(context), color: AppColors.textPrimary),
          )
        else
          const SizedBox(width: AppSpacing.xl),
        Expanded(
          child: Transform.translate(
            offset: Offset(
              compactBackTitleGap
                  ? (Directionality.of(context) == TextDirection.rtl
                      ? AppSpacing.xs
                      : -AppSpacing.xs)
                  : 0,
              0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: HubTypography.hubTitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  subtitle,
                  style: HubTypography.hubSubtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
        ?trailing,
      ],
    );
  }
}

/// Standard horizontal padding for summary strip rows.
class HubSummaryStripPadding extends StatelessWidget {
  const HubSummaryStripPadding({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(
        AppSpacing.xl,
        AppSpacing.md,
        AppSpacing.xl,
        0,
      ),
      child: child,
    );
  }
}
