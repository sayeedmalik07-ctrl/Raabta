import 'package:flutter/material.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/glass/glass_card.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/features/know_qatar/data/models/know_qatar_persona.dart';
import 'package:raabta/features/know_qatar/domain/services/know_qatar_persona_service.dart';
import 'package:raabta/features/know_qatar/presentation/l10n/know_qatar_strings.dart';

class KnowQatarPersonaBanner extends StatelessWidget {
  const KnowQatarPersonaBanner({
    super.key,
    required this.persona,
    required this.locale,
  });

  final KnowQatarPersona persona;
  final String locale;

  Color get _accent {
    switch (persona) {
      case KnowQatarPersona.family:
        return AppColors.purpleGlow;
      case KnowQatarPersona.workingResident:
        return AppColors.cyanGlow;
      case KnowQatarPersona.newResident:
        return AppColors.info;
      case KnowQatarPersona.visitor:
        return AppColors.textSecondary;
    }
  }

  IconData get _icon {
    switch (persona) {
      case KnowQatarPersona.family:
        return Icons.family_restroom_outlined;
      case KnowQatarPersona.workingResident:
        return Icons.work_outline;
      case KnowQatarPersona.newResident:
        return Icons.flight_land_outlined;
      case KnowQatarPersona.visitor:
        return Icons.public_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bannerKey = KnowQatarPersonaService.bannerKeyFor(persona);
    return GlassCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      glowColor: _accent,
      glowIntensity: persona == KnowQatarPersona.visitor ? 0.08 : 0.14,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(_icon, color: _accent, size: 22),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              KnowQatarStrings.t(bannerKey, locale),
              style: AppTypography.bodySmall.copyWith(height: 1.45),
            ),
          ),
        ],
      ),
    );
  }
}
