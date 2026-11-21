import 'package:flutter/material.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/design/app_spacing.dart';
import 'package:raabta/core/design/app_text_styles.dart';
import 'package:raabta/core/widgets/hub/hub_layout_tokens.dart';
import 'package:raabta/core/widgets/hub/hub_notice_banner.dart';

/// Calm moderation inline notice (kit community states — specific wording + optional Edit).
class HubCommunityModerationNotice extends StatelessWidget {
  const HubCommunityModerationNotice({
    super.key,
    required this.message,
    this.actionLabel,
    this.onAction,
    this.padding,
  });

  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final showAction = actionLabel != null &&
        actionLabel!.trim().isNotEmpty &&
        onAction != null;

    if (!showAction) {
      return HubNoticeBanner(text: message, padding: padding);
    }

    final inset = padding ?? EdgeInsets.zero;
    return Padding(
      padding: inset,
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
          child: Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: AppSpacing.xs,
            children: [
              Text(
                message,
                style: AppTextStyles.bodyMedium.copyWith(fontSize: 11.5),
              ),
              TextButton(
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  foregroundColor: AppColors.brandFamilyText,
                ),
                onPressed: onAction,
                child: Text(
                  actionLabel!,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.brandFamilyText,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
