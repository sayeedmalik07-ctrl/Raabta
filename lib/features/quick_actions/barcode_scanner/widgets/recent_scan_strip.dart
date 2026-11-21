import 'package:flutter/material.dart';
import 'package:raabta/core/colors/app_colors.dart';

import '../services/food_scan_history_repository.dart';

class RecentScanStrip extends StatelessWidget {
  const RecentScanStrip({
    super.key,
    required this.scans,
    required this.onScanTap,
  });

  final List<FoodScanHistoryEntry> scans;
  final ValueChanged<String> onScanTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 72,
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.isLight
            ? AppColors.glassSurface
            : Colors.white.withValues(alpha: 0.03),
        border: Border(
          top: BorderSide(
            color: AppColors.isLight
                ? AppColors.glassBorder
                : Colors.white.withValues(alpha: 0.07),
          ),
        ),
      ),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: scans.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (_, i) => RecentScanChip(
          scan: scans[i],
          onTap: () => onScanTap(scans[i].barcode),
        ),
      ),
    );
  }
}

class RecentScanChip extends StatelessWidget {
  const RecentScanChip({
    super.key,
    required this.scan,
    required this.onTap,
  });

  final FoodScanHistoryEntry scan;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 120,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: scan.scoreColor.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: scan.scoreColor.withValues(alpha: 0.25)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              scan.productName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: AppColors.isLight
                    ? AppColors.textPrimary
                    : Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 11,
              ),
            ),
            const SizedBox(height: 2),
            Row(
              children: [
                Text(
                  '${scan.healthScore}',
                  style: TextStyle(
                    color: scan.scoreColor,
                    fontWeight: FontWeight.w900,
                    fontSize: 13,
                  ),
                ),
                Text(
                  '/100',
                  style: TextStyle(
                    color: AppColors.isLight
                        ? AppColors.textOnGlassMuted
                        : Colors.white.withValues(alpha: 0.3),
                    fontSize: 9,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
