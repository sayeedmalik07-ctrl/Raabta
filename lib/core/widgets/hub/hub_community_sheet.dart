import 'package:flutter/material.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/design/app_spacing.dart';
import 'package:raabta/core/design/app_text_styles.dart';
import 'package:raabta/core/widgets/hub/hub_picker_sheet.dart';

/// Community sub-screen kit sheet chrome (moderation, why am I seeing this, menus).
abstract final class HubCommunitySheet {
  HubCommunitySheet._();

  static Future<T?> show<T>({
    required BuildContext context,
    required String title,
    required Widget child,
    String? subtitle,
    Widget? footer,
    bool isScrollControlled = true,
  }) {
    return HubPickerSheet.show<T>(
      context: context,
      title: title,
      subtitle: subtitle,
      footer: footer,
      isScrollControlled: isScrollControlled,
      child: child,
    );
  }
}

/// Bullet row for deterministic visibility / moderation copy in community sheets.
class HubCommunitySheetBullet extends StatelessWidget {
  const HubCommunitySheetBullet({
    super.key,
    required this.text,
  });

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.check_circle_outline,
            size: 18,
            color: AppColors.brandFamilyMain,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              text,
              style: AppTextStyles.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}
