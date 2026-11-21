import 'package:flutter/material.dart';
import 'package:raabta/core/colors/app_colors.dart';

import '../l10n/food_inspector_strings.dart';

class AllergyWarningBanner extends StatelessWidget {
  final List<String> warnings;
  final String locale;

  const AllergyWarningBanner({
    super.key,
    required this.warnings,
    required this.locale,
  });

  @override
  Widget build(BuildContext context) {
    if (warnings.isEmpty) return const SizedBox.shrink();
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.errorBright.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.errorBright.withValues(alpha: 0.4),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.warning_rounded,
                color: AppColors.errorBright,
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                FoodInspectorStrings.t('allergen_warning_title', locale),
                style: const TextStyle(
                  color: AppColors.errorBright,
                  fontWeight: FontWeight.w900,
                  fontSize: 13,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...warnings.map(
            (w) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '• ',
                    style: TextStyle(
                      color: AppColors.errorBright,
                      fontSize: 13,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      w,
                      style: TextStyle(
                        color: AppColors.isLight
                            ? AppColors.textPrimary
                            : Colors.white.withValues(alpha: 0.85),
                        fontSize: 13,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
