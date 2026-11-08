import 'package:flutter/material.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/glass/glass_card.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/features/eosb/presentation/widgets/home_country_support_section.dart';
import 'package:raabta/features/know_qatar/data/models/know_qatar_models.dart';
import 'package:raabta/features/know_qatar/presentation/l10n/know_qatar_strings.dart';
import 'package:raabta/features/know_qatar/presentation/widgets/know_qatar_action_cards.dart';
import 'package:raabta/features/know_qatar/presentation/widgets/know_qatar_history_timeline.dart';
import 'package:raabta/features/know_qatar/presentation/widgets/know_qatar_legal_callout.dart';
import 'package:raabta/features/know_qatar/presentation/widgets/know_qatar_progress_chart.dart';
import 'package:raabta/features/know_qatar/presentation/widgets/know_qatar_source_footer.dart';

/// Visual-only icon map for Know Qatar section headers.
const _sectionIcons = <String, IconData>{
  'qatar_at_glance': Icons.landscape_outlined,
  'history': Icons.history_edu_outlined,
  'leadership_government': Icons.account_balance_outlined,
  'economy': Icons.trending_up_outlined,
  'cities_regions': Icons.location_city_outlined,
  'culture_society': Icons.groups_outlined,
  'work_in_qatar': Icons.work_outline,
  'living_in_qatar': Icons.home_outlined,
  'money_cost_of_living': Icons.payments_outlined,
  'residency_documents': Icons.badge_outlined,
  'communities': Icons.diversity_3_outlined,
  'buying_car': Icons.directions_car_outlined,
  'freelance_visa': Icons.card_travel_outlined,
  'telecom_contracts': Icons.phone_android_outlined,
  'sim_ussd': Icons.sim_card_outlined,
  'driving_traffic': Icons.traffic_outlined,
};

Color _tileSurface({required bool expanded}) {
  return AppColors.surfaceElevated.withValues(alpha: expanded ? 0.72 : 0.58);
}

class KnowQatarSectionCard extends StatelessWidget {
  const KnowQatarSectionCard({
    super.key,
    required this.section,
    required this.locale,
    required this.expanded,
    required this.onExpansionChanged,
  });

  final KnowQatarSection section;
  final String locale;
  final bool expanded;
  final ValueChanged<bool> onExpansionChanged;

  @override
  Widget build(BuildContext context) {
    final icon = _sectionIcons[section.sectionKey] ?? Icons.menu_book_outlined;
    final tileSurface = _tileSurface(expanded: expanded);

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: GlassCard(
        padding: EdgeInsets.zero,
        glowColor: expanded ? AppColors.cyanGlow : null,
        glowIntensity: expanded ? 0.1 : 0,
        child: Material(
          color: tileSurface,
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          clipBehavior: Clip.antiAlias,
          child: Theme(
            data: Theme.of(context).copyWith(
              dividerColor: Colors.transparent,
              splashColor: AppColors.cyanGlow.withValues(alpha: 0.14),
              highlightColor: AppColors.cyanGlow.withValues(alpha: 0.07),
              listTileTheme: ListTileThemeData(
                tileColor: tileSurface,
                selectedTileColor: tileSurface,
                iconColor: AppColors.cyanGlow,
                textColor: AppColors.textPrimary,
                contentPadding: EdgeInsets.zero,
              ),
            ),
            child: ExpansionTile(
              initiallyExpanded: expanded,
              onExpansionChanged: onExpansionChanged,
              backgroundColor: AppColors.surfaceElevated.withValues(alpha: 0.42),
              collapsedBackgroundColor: tileSurface,
              iconColor: AppColors.cyanGlow,
              collapsedIconColor: AppColors.textSecondary,
              shape: const RoundedRectangleBorder(side: BorderSide.none),
              collapsedShape: const RoundedRectangleBorder(side: BorderSide.none),
              tilePadding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.xs,
              ),
              childrenPadding: const EdgeInsets.fromLTRB(
                AppSpacing.md,
                0,
                AppSpacing.md,
                AppSpacing.md,
              ),
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.cyanGlow.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.cyanGlow.withValues(alpha: 0.35),
                  ),
                ),
                child: Icon(icon, color: AppColors.cyanGlow, size: 20),
              ),
              title: Text(
                KnowQatarStrings.t(section.titleKey, locale),
                style: AppTypography.title.copyWith(
                  color: expanded ? AppColors.textPrimary : null,
                ),
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: AppSpacing.xxs),
                child: Text(
                  KnowQatarStrings.t(section.teaserKey, locale),
                  style: AppTypography.caption.copyWith(
                    color: expanded
                        ? AppColors.textSecondary
                        : AppColors.textTertiary,
                    height: 1.35,
                  ),
                  maxLines: expanded ? null : 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              children: [
                Divider(
                  height: 1,
                  thickness: 1,
                  color: AppColors.glassBorderBright.withValues(alpha: 0.35),
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  KnowQatarStrings.t(section.bodyKey, locale),
                  style: AppTypography.bodySmall.copyWith(height: 1.55),
                ),
                if (section.timelineMilestones.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.md),
                  KnowQatarHistoryTimeline(
                    milestones: section.timelineMilestones,
                    locale: locale,
                  ),
                ],
                if (section.progressMilestones.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.md),
                  KnowQatarProgressChart(
                    milestones: section.progressMilestones,
                    locale: locale,
                  ),
                ],
                if (section.legalCallouts.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.md),
                  ...section.legalCallouts.map(
                    (c) => KnowQatarLegalCalloutCard(
                      callout: c,
                      locale: locale,
                    ),
                  ),
                ],
                if (section.showNationalityHighlight) ...[
                  const SizedBox(height: AppSpacing.md),
                  HomeCountrySupportSection(locale: locale),
                ],
                if (section.showCultureChips) ...[
                  const SizedBox(height: AppSpacing.md),
                  KnowQatarCultureChips(locale: locale),
                ],
                KnowQatarSourceFooter(section: section, locale: locale),
                KnowQatarActionCards(links: section.actionLinks, locale: locale),
                if (section.aiPromptKey != null)
                  Align(
                    alignment: Alignment.centerLeft,
                    child: KnowQatarAiFooterLink(
                      promptKey: section.aiPromptKey!,
                      sectionTitleKey: section.titleKey,
                      sectionTeaserKey: section.teaserKey,
                      locale: locale,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
