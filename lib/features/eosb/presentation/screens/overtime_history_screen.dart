import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/glass/glass_card.dart';
import 'package:raabta/core/glass/glass_container.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/core/widgets/glass_empty_state.dart';
import 'package:raabta/core/widgets/glass_screen_scaffold.dart';
import 'package:raabta/features/eosb/domain/models/overtime_truth_models.dart';
import 'package:raabta/features/eosb/presentation/l10n/eosb_strings.dart';
import 'package:raabta/features/eosb/providers/eosb_providers.dart';
import 'package:raabta/features/eosb/providers/overtime_truth_providers.dart';

class OvertimeHistoryScreen extends ConsumerWidget {
  const OvertimeHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localeAsync = ref.watch(eosbLocaleProvider);
    final otState = ref.watch(overtimeTruthProvider);
    final history = otState.filteredHistory;

    return localeAsync.when(
      loading: () => const GlassScreenScaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (_, _) => const SizedBox.shrink(),
      data: (locale) {
        return GlassScreenScaffold(
          title: EosbStrings.t('ot_history', locale),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.pop(),
          ),
          padding: const EdgeInsets.all(AppSpacing.lg),
          body: Column(
            children: [
              GlassContainer(
                padding: EdgeInsets.zero,
                borderRadius: AppSpacing.radiusSm,
                child: TextField(
                  decoration: InputDecoration(
                    hintText: EosbStrings.t('ot_search', locale),
                    prefixIcon: const Icon(Icons.search),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.all(AppSpacing.md),
                  ),
                  onChanged: (q) =>
                      ref.read(overtimeTruthProvider.notifier).setSearchQuery(q),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Expanded(
                child: history.isEmpty
                    ? GlassEmptyState(
                        icon: Icons.history,
                        title: EosbStrings.t('ot_history_empty', locale),
                        description: EosbStrings.t('ot_history_empty_desc', locale),
                        actionLabel: EosbStrings.t('ot_calendar_mode', locale),
                        onAction: () => context.push('/eosb/overtime/calendar'),
                      )
                    : ListView.builder(
                        itemCount: history.length,
                        itemBuilder: (context, index) {
                          final record = history[index];
                          return _HistoryTile(
                            record: record,
                            locale: locale,
                            onOpen: () {
                              ref
                                  .read(overtimeTruthProvider.notifier)
                                  .updateRecord(record);
                              ref.read(overtimeTruthProvider.notifier).calculate();
                              context.push('/eosb/overtime/summary');
                            },
                            onFavorite: () => ref
                                .read(overtimeTruthProvider.notifier)
                                .toggleFavorite(record.id),
                            onDuplicate: () => ref
                                .read(overtimeTruthProvider.notifier)
                                .duplicateCurrentMonth(),
                            onDelete: () => ref
                                .read(overtimeTruthProvider.notifier)
                                .deleteFromHistory(record.id),
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _HistoryTile extends StatelessWidget {
  const _HistoryTile({
    required this.record,
    required this.locale,
    required this.onOpen,
    required this.onFavorite,
    required this.onDuplicate,
    required this.onDelete,
  });

  final OvertimeMonthlyRecord record;
  final String locale;
  final VoidCallback onOpen;
  final VoidCallback onFavorite;
  final VoidCallback onDuplicate;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final otHours = record.days.fold<double>(
      0,
      (s, d) => s + d.totalHours,
    );

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: GlassCard(
        onTap: onOpen,
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(record.label, style: AppTypography.title),
                  Text(
                    record.profile.companyName.isEmpty
                        ? EosbStrings.t('ot_no_company', locale)
                        : record.profile.companyName,
                    style: AppTypography.bodySmall,
                  ),
                  Text(
                    '${otHours.toStringAsFixed(1)}h · '
                    '${formatEosbCurrency(record.employerPaidOvertime)} paid',
                    style: AppTypography.caption,
                  ),
                ],
              ),
            ),
            IconButton(
              icon: Icon(
                record.isFavorite ? Icons.star : Icons.star_border,
                color: AppColors.accentGold,
              ),
              onPressed: onFavorite,
            ),
            PopupMenuButton<String>(
              onSelected: (v) {
                if (v == 'dup') onDuplicate();
                if (v == 'del') onDelete();
              },
              itemBuilder: (_) => [
                PopupMenuItem(
                  value: 'dup',
                  child: Text(EosbStrings.t('ot_duplicate', locale)),
                ),
                PopupMenuItem(
                  value: 'del',
                  child: Text(EosbStrings.t('ot_delete', locale)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
