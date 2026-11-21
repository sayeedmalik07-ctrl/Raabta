import 'package:flutter/material.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/widgets/glass_progress_indicator.dart';
import 'package:raabta/features/quick_actions/bill_tracker/l10n/bill_tracker_strings.dart';

class BillTrackerLoadingState extends StatelessWidget {
  const BillTrackerLoadingState({super.key, required this.locale});

  final String locale;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          const GlassProgressIndicator(color: AppColors.sharePurple),
          const SizedBox(height: 16),
          Text(
            BillTrackerStrings.t('loading_bills', locale),
            style: TextStyle(
              color: AppColors.isLight
                  ? AppColors.textOnGlassMuted
                  : Colors.white38,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
