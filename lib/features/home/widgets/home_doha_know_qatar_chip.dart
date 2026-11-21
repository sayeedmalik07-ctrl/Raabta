import 'package:flutter/material.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/features/home/widgets/home_header_tactile_control.dart';
import 'package:raabta/features/know_qatar/presentation/l10n/know_qatar_strings.dart';

/// Skyline Know Qatar entry — tactile chip (not plain text).
class HomeDohaKnowQatarChip extends StatelessWidget {
  const HomeDohaKnowQatarChip({
    super.key,
    required this.locale,
    required this.onTap,
  });

  final String locale;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final label = KnowQatarStrings.t('kq_screen_title', locale);

    return HomeHeaderTactileControl(
      key: const Key('home_doha_know_qatar_chip'),
      overSkyline: true,
      height: 44,
      borderRadius: 22,
      semanticsLabel: label,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm + 2),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.explore_outlined,
              size: AppSpacing.iconSm + 2,
              color: Colors.white.withValues(alpha: 0.95),
            ),
            const SizedBox(width: AppSpacing.xs),
            Text(
              label,
              style: AppTypography.subtitle.copyWith(
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}