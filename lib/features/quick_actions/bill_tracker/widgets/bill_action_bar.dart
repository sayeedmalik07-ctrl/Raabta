import 'package:flutter/material.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/glass/glass_container.dart';
import 'package:raabta/features/quick_actions/bill_tracker/l10n/bill_tracker_strings.dart';

class BillActionBar extends StatelessWidget {
  const BillActionBar({
    super.key,
    required this.locale,
    required this.isAnalyzing,
    required this.onAnalyze,
    required this.onShare,
  });

  final String locale;
  final bool isAnalyzing;
  final VoidCallback onAnalyze;
  final VoidCallback onShare;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: isAnalyzing ? null : onAnalyze,
            icon: isAnalyzing
                ? const SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : const Icon(
                    Icons.auto_awesome_rounded,
                    color: Colors.white,
                    size: 16,
                  ),
            label: Text(
              isAnalyzing
                  ? BillTrackerStrings.t('ai_analyzing', locale)
                  : BillTrackerStrings.t('ai_analysis', locale),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.sharePurple,
              disabledBackgroundColor:
                  AppColors.sharePurple.withValues(alpha: 0.4),
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: onShare,
            icon: const Icon(
              Icons.share_rounded,
              color: Color(0xFF25D366),
              size: 16,
            ),
            label: Text(
              BillTrackerStrings.t('share', locale),
              style: const TextStyle(
                color: Color(0xFF25D366),
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
            ),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
              side: const BorderSide(color: Color(0xFF25D366)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class BillAiAnalysisCard extends StatelessWidget {
  const BillAiAnalysisCard({super.key, required this.analysis});

  final String analysis;

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      padding: const EdgeInsets.all(14),
      borderRadius: 12,
      glowColor: AppColors.purpleGlow,
      glowIntensity: 0.1,
      backgroundColor: AppColors.purpleGlow.withValues(alpha: 0.08),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('🤖', style: TextStyle(fontSize: 16)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              analysis,
              style: TextStyle(
                color: AppColors.isLight
                    ? AppColors.textOnGlassSecondary
                    : Colors.white.withValues(alpha: 0.7),
                fontSize: 13,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
