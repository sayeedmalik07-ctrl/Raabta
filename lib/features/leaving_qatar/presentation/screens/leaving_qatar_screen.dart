import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/glass/glass_card.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/core/widgets/glass_screen_scaffold.dart';
import 'package:raabta/features/leaving_qatar/data/leaving_qatar_catalog.dart';
import 'package:raabta/features/leaving_qatar/data/models/leaving_qatar_models.dart';
import 'package:raabta/features/leaving_qatar/presentation/l10n/leaving_qatar_strings.dart';
import 'package:raabta/features/leaving_qatar/presentation/widgets/leaving_qatar_departure_plan_section.dart';
import 'package:raabta/features/leaving_qatar/presentation/widgets/leaving_qatar_marketplace_tag_hint.dart';
import 'package:raabta/features/leaving_qatar/presentation/widgets/leaving_qatar_other_closeout_section.dart';
import 'package:raabta/features/leaving_qatar/presentation/widgets/leaving_qatar_timeline_section.dart';
import 'package:raabta/features/leaving_qatar/providers/leaving_qatar_providers.dart';
import 'package:raabta/providers/visa_providers.dart';

/// Departure planning — self-assessment, official MOI links, EOSB reuse, timeline.
///
/// Raabta is a signpost only; never certifies exit or travel-ban status.
class LeavingQatarScreen extends ConsumerStatefulWidget {
  const LeavingQatarScreen({super.key});

  static const route = '/leaving-qatar';

  @override
  ConsumerState<LeavingQatarScreen> createState() => _LeavingQatarScreenState();
}

class _LeavingQatarScreenState extends ConsumerState<LeavingQatarScreen> {
  final _timelineSectionKey = GlobalKey();
  final _closeoutSectionKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await markLeavingQatarEngaged();
      ref.invalidate(leavingQatarRecentlyEngagedProvider);
      final locale = ref.read(userLanguageProvider);
      final plan =
          await ref.read(leavingQatarDeparturePlanPrefsServiceProvider).load();
      final reminders =
          await ref.read(leavingQatarDeparturePlanReminderServiceProvider.future);
      if (reminders.isEnabled) {
        await reminders.reconcile(plan: plan, locale: locale);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final locale = ref.watch(userLanguageProvider);
    final category = ref.watch(leavingQatarCategoryProvider);

    return GlassScreenScaffold(
      title: LeavingQatarStrings.t('lq_screen_title', locale),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => context.pop(),
      ),
      padding: const EdgeInsets.all(AppSpacing.lg),
      body: ListView(
        children: [
          Text(
            LeavingQatarStrings.t('lq_screen_intro', locale),
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textSecondary,
              height: 1.45,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          _DisclaimerBanner(locale: locale),
          const SizedBox(height: AppSpacing.lg),
          _SelfAssessmentSection(locale: locale, category: category),
          const SizedBox(height: AppSpacing.xl),
          LeavingQatarDeparturePlanSection(
            locale: locale,
            timelineSectionKey: _timelineSectionKey,
            closeoutSectionKey: _closeoutSectionKey,
          ),
          const SizedBox(height: AppSpacing.xl),
          LeavingQatarTimelineSection(
            key: _timelineSectionKey,
            locale: locale,
            category: category,
          ),
          const SizedBox(height: AppSpacing.lg),
          LeavingQatarOtherCloseoutSection(
            key: _closeoutSectionKey,
            locale: locale,
          ),
          const SizedBox(height: AppSpacing.lg),
          LeavingQatarMarketplaceTagHint(locale: locale),
          const SizedBox(height: AppSpacing.lg),
        ],
      ),
    );
  }
}

class _DisclaimerBanner extends StatelessWidget {
  const _DisclaimerBanner({required this.locale});

  final String locale;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.warning.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.warning.withValues(alpha: 0.35)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline, color: AppColors.warning, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              LeavingQatarStrings.t('lq_disclaimer', locale),
              style: AppTypography.caption.copyWith(height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}

class _SelfAssessmentSection extends ConsumerWidget {
  const _SelfAssessmentSection({
    required this.locale,
    required this.category,
  });

  final String locale;
  final LeavingQatarWorkerCategory? category;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          LeavingQatarStrings.t('lq_assessment_heading', locale),
          style: AppTypography.subtitle,
        ),
        const SizedBox(height: 4),
        Text(
          LeavingQatarStrings.t('lq_assessment_note', locale),
          style: AppTypography.caption.copyWith(color: AppColors.textSecondary),
        ),
        const SizedBox(height: AppSpacing.md),
        ...LeavingQatarWorkerCategory.values.map((cat) {
          final selected = category == cat;
          return Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: GlassCard(
              onTap: () =>
                  ref.read(leavingQatarCategoryProvider.notifier).state = cat,
              padding: const EdgeInsets.all(AppSpacing.md),
              glowColor: selected ? AppColors.cyanGlow : AppColors.glassBorder,
              glowIntensity: selected ? 0.16 : 0.05,
              child: Row(
                children: [
                  Icon(
                    selected
                        ? Icons.radio_button_checked
                        : Icons.radio_button_off,
                    color: selected ? AppColors.cyanGlow : AppColors.textTertiary,
                    size: 20,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      LeavingQatarStrings.t(
                        LeavingQatarCatalog.categoryLabelKey(cat),
                        locale,
                      ),
                      style: AppTypography.bodySmall,
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }
}
