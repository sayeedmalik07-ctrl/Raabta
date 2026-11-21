import 'package:flutter/material.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/glass/glass_card.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/features/eosb/presentation/l10n/eosb_strings.dart';
import 'package:raabta/features/eosb/presentation/widgets/eosb_hub_tokens.dart';

/// Non-dismissible notice when local history JSON is corrupt but rows were salvaged.
class EosbHistoryCorruptBanner extends StatelessWidget {
  const EosbHistoryCorruptBanner({
    super.key,
    required this.locale,
    required this.messageKey,
  });

  final String locale;
  final String messageKey;

  @override
  Widget build(BuildContext context) {
    final gold = EosbHubTokens.gold;
    final textColor = AppColors.isLight
        ? AppColors.textPrimary
        : AppColors.textOnGlassMuted;

    return GlassCard(
      borderRadius: EosbHubTokens.cardRadius,
      padding: const EdgeInsets.all(AppSpacing.md),
      glowColor: gold,
      glowIntensity: 0.08,
      backgroundColor: gold.withValues(alpha: AppColors.isLight ? 0.1 : 0.08),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.warning_amber_rounded, color: gold, size: 20),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              EosbStrings.t(messageKey, locale),
              style: AppTypography.bodySmall.copyWith(
                color: textColor,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
