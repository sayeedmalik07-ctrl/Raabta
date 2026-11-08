import 'package:flutter/material.dart';
import 'package:raabta/core/colors/app_colors.dart';

import '../data/qatar_example_barcodes.dart';
import 'food_inspector_theme.dart';

class ExampleBarcodeTile extends StatelessWidget {
  const ExampleBarcodeTile({
    super.key,
    required this.example,
    required this.onTap,
  });

  final QatarExampleBarcode example;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: AppColors.isLight
            ? AppColors.glassSurface
            : Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: foodInspectorPurple.withValues(alpha: 0.2),
              ),
            ),
            child: Row(
              children: [
                Text(example.emoji, style: const TextStyle(fontSize: 22)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        example.label,
                        style: TextStyle(
                          color: AppColors.isLight
                              ? AppColors.textPrimary
                              : Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                      Text(
                        example.code,
                        style: TextStyle(
                          color: AppColors.isLight
                              ? AppColors.textOnGlassMuted
                              : Colors.white.withValues(alpha: 0.35),
                          fontSize: 10,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: foodInspectorGold.withValues(alpha: 0.6),
                  size: 14,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
