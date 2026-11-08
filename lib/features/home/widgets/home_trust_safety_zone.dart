import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/features/home/widgets/home_icon_badge.dart';
import 'package:raabta/features/home/widgets/home_essential_tools_zone.dart';
import 'package:raabta/features/home/providers/home_personalization_providers.dart';
import 'package:raabta/features/home/providers/truth_home_priority_provider.dart';
import 'package:raabta/features/home/widgets/home_truth_priority_banner.dart';
import 'package:raabta/features/home/widgets/home_verification_links.dart';
import 'package:raabta/providers/visa_providers.dart';

/// Trust & safety block — Truth Engines and verification links.
/// ScamShield lives in [HomeGlanceRow] near the top of Home.
class HomeTrustSafetyZone extends ConsumerWidget {
  const HomeTrustSafetyZone({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final showVerification = ref.watch(homeShowVerificationLinksProvider);
    final locale = ref.watch(userLanguageProvider);
    final truthPriority = ref.watch(truthHomePriorityProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        HomeTruthPriorityBanner(priority: truthPriority, locale: locale),
        HomeEssentialToolsZone(
          routes: HomeEssentialToolsZone.truthEngineRoutes,
          overlineKey: 'home_truth_engines_overline',
          titleKey: 'home_truth_engines',
          subtitleKey: 'home_truth_engines_sub',
          accentColorOverride: AppColors.goldFamilyMain,
          surfaceGlowColorOverride: AppColors.goldFamilyMain,
          iconBadgeVariant: HomeIconBadgeVariant.goldBrand,
          truthEngineSection: true,
        ),
        if (showVerification) ...[
          const SizedBox(height: AppSpacing.sm),
          const HomeVerificationLinks(),
        ],
      ],
    );
  }
}
