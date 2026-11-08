import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/glass/glass_card.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/core/widgets/glass_empty_state.dart';
import 'package:raabta/core/widgets/glass_primary_button.dart';
import 'package:raabta/core/widgets/glass_screen_scaffold.dart';
import 'package:raabta/core/widgets/legal_deadline_card.dart';
import 'package:raabta/features/case_timeline/presentation/providers/case_timeline_legal_deadline_provider.dart';
import 'package:raabta/features/case_timeline/domain/case_timeline_engine_type.dart';
import 'package:raabta/features/case_timeline/presentation/l10n/case_timeline_strings.dart';
import 'package:raabta/features/case_timeline/presentation/providers/case_timeline_providers.dart';
import 'package:raabta/features/case_timeline/presentation/widgets/case_timeline_add_entry_sheet.dart';
import 'package:raabta/features/case_timeline/presentation/widgets/case_timeline_entry_tile.dart';
import 'package:raabta/features/case_timeline/presentation/widgets/case_timeline_gap_panel.dart';
import 'package:raabta/features/case_timeline/services/case_timeline_service.dart';
import 'package:raabta/providers/auth_providers.dart';
import 'package:raabta/providers/visa_providers.dart';
import 'package:raabta/core/l10n/app_locale.dart';

class CaseTimelineScreen extends ConsumerStatefulWidget {
  const CaseTimelineScreen({
    super.key,
    required this.engine,
    required this.caseId,
    this.eosbIncludeSettlement = true,
  });

  final CaseTimelineEngineType engine;
  final String caseId;
  final bool eosbIncludeSettlement;

  @override
  ConsumerState<CaseTimelineScreen> createState() => _CaseTimelineScreenState();
}

class _CaseTimelineScreenState extends ConsumerState<CaseTimelineScreen> {
  String? _summary;
  bool _summarizing = false;

  CaseTimelineScope get _scope => (
        engine: widget.engine,
        caseId: widget.caseId,
      );

  Future<void> _summarize(String locale) async {
    final entries = ref.read(caseTimelineEntriesProvider(_scope)).valueOrNull;
    if (entries == null || entries.isEmpty) return;

    setState(() {
      _summarizing = true;
      _summary = null;
    });
    try {
      final text = await ref.read(caseTimelineSummaryServiceProvider).summarize(
            entries: entries,
            locale: locale,
            userId: ref.read(currentUserProvider)?.uid,
          );
      if (mounted) setState(() => _summary = text);
    } finally {
      if (mounted) setState(() => _summarizing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final locale = AppLocale.normalize(ref.watch(userLanguageProvider));
    final entriesAsync = ref.watch(caseTimelineEntriesProvider(_scope));

    return GlassScreenScaffold(
      title: CaseTimelineStrings.t('ct_title', locale),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => context.pop(),
      ),
      padding: const EdgeInsets.all(AppSpacing.lg),
      body: entriesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => GlassEmptyState(
          icon: Icons.error_outline,
          title: CaseTimelineStrings.t('ct_empty_title', locale),
          description: CaseTimelineStrings.t('ct_empty_body', locale),
        ),
        data: (entries) {
          final sorted = CaseTimelineService.sortedChronologically(entries);
          final legalDeadlines =
              ref.watch(caseTimelineLegalDeadlinesProvider(widget.engine));
          return ListView(
            children: [
              Text(
                CaseTimelineStrings.t('ct_subtitle', locale),
                style: AppTypography.bodySmall,
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                CaseTimelineStrings.t('ct_disclaimer', locale),
                style: AppTypography.caption.copyWith(
                  color: AppColors.textTertiary,
                  fontStyle: FontStyle.italic,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              GlassPrimaryButton(
                label: CaseTimelineStrings.t('ct_add_entry', locale),
                icon: Icons.add,
                expand: true,
                onPressed: () => showCaseTimelineAddEntrySheet(
                  context: context,
                  ref: ref,
                  locale: locale,
                  engine: widget.engine,
                  caseId: widget.caseId,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              if (legalDeadlines.isNotEmpty) ...[
                ...legalDeadlines.asMap().entries.map(
                      (e) => Padding(
                        padding: EdgeInsets.only(
                          bottom: e.key == legalDeadlines.length - 1
                              ? AppSpacing.md
                              : AppSpacing.sm,
                        ),
                        child: LegalDeadlineTimelineMarker(
                          result: e.value,
                          locale: locale,
                          isLast:
                              sorted.isEmpty && e.key == legalDeadlines.length - 1,
                        ),
                      ),
                    ),
              ],
              if (sorted.isEmpty)
                GlassEmptyState(
                  icon: Icons.timeline_outlined,
                  title: CaseTimelineStrings.t('ct_empty_title', locale),
                  description: CaseTimelineStrings.t('ct_empty_body', locale),
                )
              else
                ...sorted.asMap().entries.map(
                      (e) => CaseTimelineEntryTile(
                        entry: e.value,
                        locale: locale,
                        isLast: e.key == sorted.length - 1,
                      ),
                    ),
              const SizedBox(height: AppSpacing.lg),
              GlassCard(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: CaseTimelineGapPanel(
                  locale: locale,
                  engine: widget.engine,
                  entries: sorted,
                  eosbIncludeSettlement: widget.eosbIncludeSettlement,
                ),
              ),
              if (sorted.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.lg),
                GlassPrimaryButton(
                  label: _summarizing
                      ? CaseTimelineStrings.t('ct_summarize_loading', locale)
                      : CaseTimelineStrings.t('ct_summarize', locale),
                  icon: Icons.summarize_outlined,
                  expand: true,
                  onPressed: _summarizing ? null : () => _summarize(locale),
                ),
                if (_summary != null) ...[
                  const SizedBox(height: AppSpacing.md),
                  GlassCard(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(_summary!, style: AppTypography.bodySmall),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          CaseTimelineStrings.t(
                            'ct_summarize_disclaimer',
                            locale,
                          ),
                          style: AppTypography.caption.copyWith(
                            color: AppColors.textTertiary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ],
          );
        },
      ),
    );
  }
}
