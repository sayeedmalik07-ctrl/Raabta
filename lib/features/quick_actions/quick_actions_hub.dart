import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/glass/glass_card.dart';
import 'package:raabta/core/glass/glass_container.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/features/home/widgets/home_card_tiers.dart';
import 'package:raabta/features/home/widgets/home_icon_badge.dart';
import 'package:raabta/features/quick_actions/l10n/quick_actions_strings.dart';
import 'package:raabta/features/ramadan/ramadan_season.dart';
import 'package:raabta/providers/visa_providers.dart';
import 'package:raabta/services/home/quick_tool_usage_tracker.dart';

/// Sheet styling when opened from a Home section (scoped; default is neutral).
enum QuickActionsHubPresentation {
  standard,
  dailyEssentialsTeal,
}

class QuickActionsHub extends ConsumerWidget {
  const QuickActionsHub({
    super.key,
    this.presentation = QuickActionsHubPresentation.standard,
  });

  final QuickActionsHubPresentation presentation;

  static const QuickActionTool _ramadanTool = QuickActionTool(
    icon: Icons.nightlight_round,
    titleKey: 'tool_ramadan_title',
    shortLabelKey: 'tool_ramadan_short_label',
    descriptionKey: 'tool_ramadan_description',
    route: '/ramadan',
    accentColor: AppColors.purpleGlow,
  );

  /// Shared quick action definitions for the hub and Daily Essentials row.
  static const List<QuickActionTool> tools = [
    QuickActionTool(
      icon: Icons.handyman_outlined,
      titleKey: 'tool_services_title',
      shortLabelKey: 'tool_services_short_label',
      descriptionKey: 'tool_services_description',
      route: '/services',
      accentColor: AppColors.quickActionIndigo,
    ),
    QuickActionTool(
      icon: Icons.document_scanner_outlined,
      titleKey: 'tool_scanner_title',
      shortLabelKey: 'tool_scanner_short_label',
      descriptionKey: 'tool_scanner_description',
      route: '/scanner/capture',
      accentColor: AppColors.chipScanner,
    ),
    QuickActionTool(
      icon: Icons.folder_copy_outlined,
      titleKey: 'tool_vault_title',
      shortLabelKey: 'tool_vault_short_label',
      descriptionKey: 'tool_vault_description',
      route: '/document-vault',
      accentColor: AppColors.accentGold,
    ),
    QuickActionTool(
      icon: Icons.qr_code_scanner_rounded,
      titleKey: 'tool_barcode_title',
      shortLabelKey: 'tool_barcode_short_label',
      descriptionKey: 'tool_barcode_description',
      route: '/barcode-scanner',
      accentColor: AppColors.chipFood,
    ),
    QuickActionTool(
      icon: Icons.translate_rounded,
      titleKey: 'tool_arabic_companion_title',
      shortLabelKey: 'tool_arabic_companion_short_label',
      descriptionKey: 'tool_arabic_companion_description',
      route: '/arabic-companion',
      accentColor: AppColors.chipCommunity,
    ),
    QuickActionTool(
      icon: Icons.receipt_long_outlined,
      titleKey: 'tool_bill_splitter_title',
      shortLabelKey: 'tool_bill_splitter_short_label',
      descriptionKey: 'tool_bill_splitter_description',
      route: '/bill-splitter',
      accentColor: AppColors.chipLease,
    ),
    QuickActionTool(
      icon: Icons.verified_user_outlined,
      titleKey: 'tool_warranty_title',
      shortLabelKey: 'tool_warranty_short_label',
      descriptionKey: 'tool_warranty_description',
      route: '/warranty-shield',
      accentColor: AppColors.chipWage,
    ),
    QuickActionTool(
      icon: Icons.shield_outlined,
      titleKey: 'tool_scam_shield_title',
      shortLabelKey: 'tool_scam_shield_short_label',
      descriptionKey: 'tool_scam_shield_description',
      route: '/scam-shield',
      accentColor: AppColors.errorBright,
    ),
    QuickActionTool(
      icon: Icons.ac_unit_outlined,
      titleKey: 'tool_climate_title',
      shortLabelKey: 'tool_climate_short_label',
      descriptionKey: 'tool_climate_description',
      route: '/climate-navigator',
      accentColor: AppColors.chipClimate,
    ),
    QuickActionTool(
      icon: Icons.hourglass_top_outlined,
      titleKey: 'tool_queue_title',
      shortLabelKey: 'tool_queue_short_label',
      descriptionKey: 'tool_queue_description',
      route: '/queue-avoidance',
      accentColor: AppColors.chipQueue,
    ),
    QuickActionTool(
      icon: Icons.receipt_outlined,
      titleKey: 'tool_bill_tracker_title',
      shortLabelKey: 'tool_bill_tracker_short_label',
      descriptionKey: 'tool_bill_tracker_description',
      route: '/bill-tracker',
      accentColor: AppColors.chipCommunity,
    ),
    QuickActionTool(
      icon: Icons.public_outlined,
      titleKey: 'tool_know_qatar_title',
      shortLabelKey: 'tool_know_qatar_short_label',
      descriptionKey: 'tool_know_qatar_description',
      route: '/know-qatar',
      accentColor: AppColors.info,
    ),
    QuickActionTool(
      icon: Icons.sim_card_outlined,
      titleKey: 'tool_telecom_decoder_title',
      shortLabelKey: 'tool_telecom_decoder_short_label',
      descriptionKey: 'tool_telecom_decoder_description',
      route: '/telecom-contract-decoder',
      accentColor: AppColors.purpleGlow,
    ),
    QuickActionTool(
      icon: Icons.directions_car_outlined,
      titleKey: 'tool_buying_car_title',
      shortLabelKey: 'tool_buying_car_short_label',
      descriptionKey: 'tool_buying_car_description',
      route: '/buying-car-qatar',
      accentColor: AppColors.accentGold,
    ),
    QuickActionTool(
      icon: Icons.fact_check_outlined,
      titleKey: 'tool_freelance_visa_title',
      shortLabelKey: 'tool_freelance_visa_short_label',
      descriptionKey: 'tool_freelance_visa_description',
      route: '/freelance-visa-qatar',
      accentColor: AppColors.info,
    ),
    QuickActionTool(
      icon: Icons.flight_land_outlined,
      titleKey: 'tool_leaving_qatar_title',
      shortLabelKey: 'tool_leaving_qatar_short_label',
      descriptionKey: 'tool_leaving_qatar_description',
      route: '/leaving-qatar',
      accentColor: AppColors.warning,
    ),
    QuickActionTool(
      icon: Icons.flight_takeoff_rounded,
      titleKey: 'tool_trip_title',
      shortLabelKey: 'tool_trip_short_label',
      descriptionKey: 'tool_trip_description',
      route: '/trip-planner',
      accentColor: AppColors.chipTrip,
    ),
    QuickActionTool(
      icon: Icons.mosque_outlined,
      titleKey: 'tool_prayer_title',
      shortLabelKey: 'tool_prayer_short_label',
      descriptionKey: 'tool_prayer_description',
      route: '/prayer-mosque',
      accentColor: AppColors.chipPrayer,
    ),
    QuickActionTool(
      icon: Icons.balance_outlined,
      titleKey: 'tool_eosb_title',
      shortLabelKey: 'tool_eosb_short_label',
      descriptionKey: 'tool_eosb_description',
      route: '/eosb',
      accentColor: AppColors.chipEosb,
    ),
    QuickActionTool(
      icon: Icons.health_and_safety_outlined,
      titleKey: 'tool_health_insurance_title',
      shortLabelKey: 'tool_health_insurance_short_label',
      descriptionKey: 'tool_health_insurance_description',
      route: '/health-insurance',
      accentColor: AppColors.chipHealthInsurance,
    ),
    QuickActionTool(
      icon: Icons.home_work_outlined,
      titleKey: 'tool_tenancy_title',
      shortLabelKey: 'tool_tenancy_short_label',
      descriptionKey: 'tool_tenancy_description',
      route: '/tenancy',
      accentColor: AppColors.chipLease,
    ),
    QuickActionTool(
      icon: Icons.swap_horiz,
      titleKey: 'tool_sponsorship_transfer_title',
      shortLabelKey: 'tool_sponsorship_transfer_short_label',
      descriptionKey: 'tool_sponsorship_transfer_description',
      route: '/sponsorship-transfer',
      accentColor: AppColors.chipSponsorshipTransfer,
    ),
    QuickActionTool(
      icon: Icons.sim_card_outlined,
      titleKey: 'tool_ussd_title',
      shortLabelKey: 'tool_ussd_short_label',
      descriptionKey: 'tool_ussd_description',
      route: '/daily-ussd',
      accentColor: AppColors.sharePurple,
    ),
    QuickActionTool(
      icon: Icons.directions_car_outlined,
      titleKey: 'tool_driving_title',
      shortLabelKey: 'tool_driving_short_label',
      descriptionKey: 'tool_driving_description',
      route: '/driving',
      accentColor: AppColors.chipWage,
    ),
  ];

  /// Catalog-only routes — kept in [tools] for Home lookup, hidden from hub grid.
  static const hubExcludedRoutes = {
    '/prayer-mosque',
    '/eosb',
    '/sponsorship-transfer',
    '/tenancy',
    '/health-insurance',
    '/scam-shield',
    '/trip-planner',
    '/climate-navigator',
    '/queue-avoidance',
    '/arabic-companion',
    '/know-qatar',
    '/telecom-contract-decoder',
    '/buying-car-qatar',
    '/freelance-visa-qatar',
    '/daily-ussd',
    '/driving',
  };

  static const hubSections = <({String headerKey, List<String> routes})>[
    (
      headerKey: 'hub_section_documents',
      routes: ['/scanner/capture', '/document-vault', '/barcode-scanner'],
    ),
    (
      headerKey: 'hub_section_money_bills',
      routes: ['/bill-splitter', '/bill-tracker'],
    ),
    (
      headerKey: 'hub_section_protection',
      routes: ['/warranty-shield'],
    ),
    (
      headerKey: 'hub_section_utilities',
      routes: ['/leaving-qatar', '/services'],
    ),
  ];

  /// Hub grid tools. Includes seasonal Ramadan tile ~4 weeks before Ramadan.
  static List<QuickActionTool> visibleTools([DateTime? reference]) {
    final list = tools
        .where((tool) => !hubExcludedRoutes.contains(tool.route))
        .toList();
    if (RamadanSeason.isSeasonalPeriod(reference)) {
      list.insert(0, _ramadanTool);
    }
    return list;
  }

  static QuickActionTool? toolForRoute(String route) {
    for (final tool in tools) {
      if (tool.route == route) return tool;
    }
    if (route == _ramadanTool.route) return _ramadanTool;
    return null;
  }

  static List<({String headerKey, List<QuickActionTool> tools})> groupedVisibleTools([
    DateTime? reference,
  ]) {
    final visible = visibleTools(reference);
    final visibleRoutes = visible.map((t) => t.route).toSet();
    final grouped = <({String headerKey, List<QuickActionTool> tools})>[];

    for (final section in hubSections) {
      final sectionTools = section.routes
          .map(toolForRoute)
          .whereType<QuickActionTool>()
          .where((tool) => visibleRoutes.contains(tool.route))
          .toList();
      if (sectionTools.isNotEmpty) {
        grouped.add((headerKey: section.headerKey, tools: sectionTools));
      }
    }

    final assigned = grouped.expand((s) => s.tools).map((t) => t.route).toSet();
    final unassigned =
        visible.where((tool) => !assigned.contains(tool.route)).toList();
    if (unassigned.isNotEmpty) {
      grouped.add((headerKey: 'hub_section_other', tools: unassigned));
    }

    return grouped;
  }

  static void show(
    BuildContext context, {
    QuickActionsHubPresentation presentation =
        QuickActionsHubPresentation.standard,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => QuickActionsHub(presentation: presentation),
    );
  }

  /// Navigates to an existing GoRouter quick action route.
  static void navigateTo(
    BuildContext context,
    String route, {
    bool closeHub = false,
  }) {
    if (closeHub) {
      Navigator.pop(context);
    }
    QuickToolUsageTracker.recordTap(route);
    context.push(route);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(userLanguageProvider);
    final tealForward =
        presentation == QuickActionsHubPresentation.dailyEssentialsTeal;

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(
        top: Radius.circular(AppSpacing.radiusLg),
      ),
      child: GlassContainer(
        padding: EdgeInsets.zero,
        borderRadius: AppSpacing.radiusLg,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.sizeOf(context).height * 0.85,
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              AppSpacing.sm,
              AppSpacing.md,
              AppSpacing.xl,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.glassBorderBright,
                      borderRadius: BorderRadius.circular(AppSpacing.xxs),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            QuickActionsStrings.t('hub_title', locale),
                            style: AppTypography.headline2,
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            QuickActionsStrings.t('hub_subtitle', locale),
                            style: AppTypography.bodySmall.copyWith(
                              color: AppColors.textOnGlassMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                    GlassContainer(
                      onTap: () => Navigator.pop(context),
                      borderRadius: AppSpacing.radiusSm,
                      padding: const EdgeInsets.all(AppSpacing.sm),
                      child: Icon(
                        Icons.close_rounded,
                        size: AppSpacing.iconSm,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final crossAxisCount =
                        constraints.maxWidth >= 600 ? 3 : 2;
                    final sections = groupedVisibleTools();

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        for (final section in sections) ...[
                          Padding(
                            padding: const EdgeInsets.only(
                              bottom: AppSpacing.sm,
                              top: AppSpacing.sm,
                            ),
                            child: Text(
                              QuickActionsStrings.t(
                                section.headerKey,
                                locale,
                              ),
                              style: AppTypography.caption.copyWith(
                                color: tealForward
                                    ? AppColors.tealFamilyText
                                    : AppColors.cyanGlow,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.4,
                              ),
                            ),
                          ),
                          GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: crossAxisCount,
                              crossAxisSpacing: AppSpacing.md,
                              mainAxisSpacing: AppSpacing.md,
                              mainAxisExtent: tealForward
                                  ? HomeCardTier.homeCatalogTileExtent
                                  : null,
                              childAspectRatio: 1.0,
                            ),
                            itemCount: section.tools.length,
                            itemBuilder: (context, index) {
                              final tool = section.tools[index];
                              return _QuickActionToolCard(
                                tool: tool,
                                locale: locale,
                                presentation: presentation,
                                onTap: () => navigateTo(
                                  context,
                                  tool.route,
                                  closeHub: true,
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: AppSpacing.sm),
                        ],
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class QuickActionTool {
  const QuickActionTool({
    required this.icon,
    required this.titleKey,
    required this.shortLabelKey,
    required this.descriptionKey,
    required this.route,
    required this.accentColor,
  });

  final IconData icon;
  final String titleKey;
  final String shortLabelKey;
  final String descriptionKey;
  final String route;
  final Color accentColor;
}

class _QuickActionToolCard extends StatelessWidget {
  const _QuickActionToolCard({
    required this.tool,
    required this.locale,
    required this.presentation,
    required this.onTap,
  });

  final QuickActionTool tool;
  final String locale;
  final QuickActionsHubPresentation presentation;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final description = QuickActionsStrings.t(tool.descriptionKey, locale);
    final tealForward =
        presentation == QuickActionsHubPresentation.dailyEssentialsTeal;
    final familyAccent =
        tealForward ? AppColors.tealFamilyMain : tool.accentColor;

    final titleText = QuickActionsStrings.t(tool.titleKey, locale);
    final badgeSize =
        tealForward ? HomeCardTier.compactIconBadgeSize : 40.0;

    Widget cardBody = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        HomeIconBadge(
          icon: tool.icon,
          accentColor: familyAccent,
          size: badgeSize,
          iconSize: 22,
          variant: tealForward
              ? HomeIconBadgeVariant.tealBrand
              : HomeIconBadgeVariant.standard,
          chipBorderRadius: tealForward
              ? HomeCardTier.coreServiceIconChipRadius
              : null,
        ),
        const SizedBox(height: AppSpacing.sm),
        if (tealForward) ...[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Align(
                    alignment: AlignmentDirectional.topStart,
                    child: Text(
                      titleText,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.title.copyWith(
                        fontSize: HomeCardTier.toolTitleFontSize,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ),
                if (description.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.xxs),
                  Expanded(
                    child: Align(
                      alignment: AlignmentDirectional.topStart,
                      child: Text(
                        description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.bodySmall.copyWith(
                          fontSize: 11,
                          color: AppColors.textOnGlassMuted,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ] else ...[
          Text(
            titleText,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.title.copyWith(
              fontSize: 14,
              color: AppColors.textPrimary,
            ),
          ),
          if (description.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.xxs),
            Text(
              description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.bodySmall.copyWith(
                fontSize: 11,
                color: AppColors.textOnGlassMuted,
              ),
            ),
          ],
        ],
      ],
    );

    final card = GlassCard(
      onTap: onTap,
      borderRadius: AppSpacing.radiusMd,
      padding: const EdgeInsets.all(AppSpacing.md),
      height: tealForward ? HomeCardTier.homeCatalogTileExtent : null,
      glowColor: familyAccent,
      glowIntensity: tealForward
          ? HomeCardTier.lifestyleChipGlowIntensity
          : 0.12,
      backgroundColor: familyAccent.withValues(
        alpha: tealForward
            ? (AppColors.isLight ? 0.06 : 0.08)
            : 0.08,
      ),
      child: cardBody,
    );

    if (tealForward) {
      return SizedBox(
        height: HomeCardTier.homeCatalogTileExtent,
        child: card,
      );
    }
    return card;
  }
}
