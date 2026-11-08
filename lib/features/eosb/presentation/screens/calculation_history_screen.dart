import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/glass/glass_card.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/core/widgets/glass_empty_state.dart';
import 'package:raabta/core/widgets/glass_screen_scaffold.dart';
import 'package:raabta/features/eosb/domain/models/eosb_result.dart';
import 'package:raabta/features/eosb/presentation/l10n/eosb_strings.dart';
import 'package:raabta/features/eosb/providers/eosb_providers.dart';
import 'package:raabta/features/home/providers/home_truth_chip_invalidation.dart';

class CalculationHistoryScreen extends ConsumerStatefulWidget {
  const CalculationHistoryScreen({
    super.key,
    this.openEntryId,
    this.legalUpdate = false,
  });

  final String? openEntryId;
  final bool legalUpdate;

  @override
  ConsumerState<CalculationHistoryScreen> createState() =>
      _CalculationHistoryScreenState();
}

class _CalculationHistoryScreenState
    extends ConsumerState<CalculationHistoryScreen> {
  bool _autoOpened = false;

  void _maybeOpenEntry(List<CalculationHistoryEntry> history) {
    final entryId = widget.openEntryId;
    if (_autoOpened || entryId == null || entryId.isEmpty) return;

    CalculationHistoryEntry? entry;
    for (final item in history) {
      if (item.id == entryId) {
        entry = item;
        break;
      }
    }
    if (entry == null) return;

    _autoOpened = true;
    ref.read(eosbProvider.notifier).restoreFromHistory(
          input: entry.input,
          result: entry.result,
        );
    if (mounted) {
      context.push(
        widget.legalUpdate ? '/eosb/result?legalUpdate=1' : '/eosb/result',
      );
    }
  }

  Future<void> _deleteEntry(String id) async {
    final repo = await ref.read(eosbRepositoryProvider.future);
    await repo.deleteHistoryEntry(id);
    ref.invalidate(eosbHistoryProvider);
    invalidateHomeTruthChips(ref);
  }

  @override
  Widget build(BuildContext context) {
    final localeAsync = ref.watch(eosbLocaleProvider);
    final historyAsync = ref.watch(eosbHistoryProvider);

    return localeAsync.when(
      loading: () => const GlassScreenScaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (_, _) => const SizedBox.shrink(),
      data: (locale) => GlassScreenScaffold(
        title: EosbStrings.t('eosb_history', locale),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        padding: const EdgeInsets.all(AppSpacing.lg),
        body: historyAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, _) => const Center(child: Text('Error')),
          data: (history) {
            if (widget.openEntryId != null && !_autoOpened) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _maybeOpenEntry(history);
              });
            }

            if (history.isEmpty) {
              return GlassEmptyState(
                icon: Icons.history,
                title: EosbStrings.t('eosb_empty_history', locale),
                description: EosbStrings.t('eosb_empty_history_desc', locale),
                actionLabel: EosbStrings.t('eosb_calculate_cta', locale),
                onAction: () => context.push('/eosb/employee-info'),
              );
            }

            final dateFormat = DateFormat.yMMMd().add_jm();

            return ListView.builder(
              itemCount: history.length,
              itemBuilder: (context, index) {
                final entry = history[index];
                final company = entry.input.companyName.trim();
                final title = company.isNotEmpty
                    ? company
                    : (entry.label ??
                        EosbStrings.t('eosb_history_unnamed', locale));

                return Dismissible(
                  key: ValueKey(entry.id),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: AppSpacing.lg),
                    margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                    decoration: BoxDecoration(
                      color: AppColors.errorBright.withValues(alpha: 0.2),
                      borderRadius:
                          BorderRadius.circular(AppSpacing.radiusSm),
                    ),
                    child: const Icon(Icons.delete_outline,
                        color: AppColors.errorBright),
                  ),
                  onDismissed: (_) => _deleteEntry(entry.id),
                  child: GlassCard(
                    onTap: () {
                      ref.read(eosbProvider.notifier).restoreFromHistory(
                            input: entry.input,
                            result: entry.result,
                          );
                      context.push('/eosb/result');
                    },
                    margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(title, style: AppTypography.title),
                              const SizedBox(height: AppSpacing.xs),
                              Text(
                                dateFormat.format(entry.savedAt.toLocal()),
                                style: AppTypography.caption,
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.sm,
                            vertical: AppSpacing.xs,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.emeraldGlow.withValues(alpha: 0.12),
                            borderRadius:
                                BorderRadius.circular(AppSpacing.radiusXs),
                            border: Border.all(
                              color: AppColors.emeraldGlow.withValues(alpha: 0.35),
                            ),
                          ),
                          child: Text(
                            formatEosbCurrency(entry.result.totalEntitlement),
                            style: AppTypography.title.copyWith(
                              color: AppColors.emeraldGlow,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline, size: 20),
                          color: AppColors.textTertiary,
                          onPressed: () => _deleteEntry(entry.id),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
