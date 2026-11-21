import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/l10n/common_action_strings.dart';
import 'package:raabta/features/eosb/presentation/eosb_history_date_format.dart';
import 'package:raabta/core/glass/glass_card.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/core/widgets/glass_screen_scaffold.dart';
import 'package:raabta/core/widgets/hub/hub_typography.dart';
import 'package:raabta/features/eosb/domain/models/eosb_result.dart';
import 'package:raabta/features/eosb/presentation/l10n/eosb_strings.dart';
import 'package:raabta/features/eosb/presentation/widgets/eosb_history_corrupt_banner.dart';
import 'package:raabta/features/eosb/presentation/widgets/eosb_hub_tokens.dart';
import 'package:raabta/features/eosb/presentation/widgets/shared/eosb_shared_widgets.dart';
import 'package:raabta/features/home/domain/truth_chip_status.dart';
import 'package:raabta/features/eosb/providers/eosb_providers.dart';
import 'package:raabta/providers/auth_scoped_storage_providers.dart';
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

  @override
  void initState() {
    super.initState();
    EosbHistoryDateFormatter.warmUp();
  }

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
    ref
        .read(eosbProvider.notifier)
        .restoreFromHistory(input: entry.input, result: entry.result);
    if (mounted) {
      context.push(
        widget.legalUpdate ? '/eosb/result?legalUpdate=1' : '/eosb/result',
      );
    }
  }

  void _showDeleteBlockedSnack(String locale, {required bool corrupt}) {
    if (!mounted) return;
    final key = corrupt
        ? eosbHistoryCorruptDeleteBlockedErrorCode
        : eosbHistoryPersistenceFailedErrorCode;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(EosbStrings.t(key, locale))));
  }

  Future<bool> _tryDeleteEntry(String id, String locale) async {
    final repo = await ref.read(eosbRepositoryProvider.future);
    final uid = ref.read(currentAuthUidProvider);
    final outcome = await repo.deleteHistoryEntry(id, uid: uid);
    if (!outcome.saved) {
      _showDeleteBlockedSnack(locale, corrupt: outcome.blockedByCorruptStorage);
      return false;
    }
    ref.invalidate(eosbHistoryLoadProvider);
    ref.invalidate(eosbHistoryProvider);
    invalidateHomeTruthChips(ref);
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final localeAsync = ref.watch(eosbLocaleProvider);

    final presentationLocale = ref.watch(eosbPresentationLocaleProvider);
    final historyAsync = ref.watch(eosbHistoryProvider);
    final isCorrupt = ref.watch(eosbHistoryIsStorageCorruptProvider);
    final isGenuinelyEmpty = ref.watch(eosbHistoryIsGenuinelyEmptyProvider);

    return localeAsync.when(
      loading: () => GlassScreenScaffold(
        title: EosbStrings.t('eosb_history', presentationLocale),
        titleStyle: HubTypography.hubTitle,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          tooltip: CommonActionStrings.t('action_back', presentationLocale),
          onPressed: () => context.pop(),
        ),
        body: Center(
          child: CircularProgressIndicator(
            color: EosbPresentationTokens.primaryAction,
          ),
        ),
      ),
      error: (_, _) => GlassScreenScaffold(
        title: EosbStrings.t('eosb_history', presentationLocale),
        titleStyle: HubTypography.hubTitle,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          tooltip: CommonActionStrings.t('action_back', presentationLocale),
          onPressed: () => context.pop(),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: EosbEmptyState(
              icon: Icons.error_outline,
              title: EosbStrings.t('ot_locale_load_error', presentationLocale),
              description: EosbStrings.t('eosb_subtitle', presentationLocale),
            ),
          ),
        ),
      ),
      data: (locale) => GlassScreenScaffold(
        title: EosbStrings.t('eosb_history', locale),
        titleStyle: HubTypography.hubTitle,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          tooltip: CommonActionStrings.t('action_back', locale),
          onPressed: () => context.pop(),
        ),
        padding: const EdgeInsets.all(AppSpacing.lg),
        body: historyAsync.when(
          loading: () => Center(
            child: CircularProgressIndicator(
              color: EosbPresentationTokens.primaryAction,
            ),
          ),
          error: (_, _) => Center(
            child: EosbEmptyState(
              hubStyle: true,
              icon: Icons.error_outline,
              title: EosbStrings.t('eosb_history_load_error', locale),
              description: EosbStrings.t(
                'eosb_history_load_error_desc',
                locale,
              ),
            ),
          ),
          data: (history) {
            if (widget.openEntryId != null && !_autoOpened) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _maybeOpenEntry(history);
              });
            }

            if (isCorrupt && history.isEmpty) {
              return EosbEmptyState(
                hubStyle: true,
                icon: Icons.error_outline,
                title: EosbStrings.t(
                  'eosb_history_corrupt_empty_title',
                  locale,
                ),
                description: EosbStrings.t(
                  'eosb_history_corrupt_empty_desc',
                  locale,
                ),
              );
            }

            if (isGenuinelyEmpty) {
              return EosbEmptyState(
                hubStyle: true,
                icon: Icons.history,
                title: EosbStrings.t('eosb_empty_history', locale),
                description: EosbStrings.t('eosb_empty_history_desc', locale),
                actionLabel: EosbStrings.t('eosb_calculate_cta', locale),
                onAction: () => context.push('/eosb/employee-info'),
              );
            }

            final deleteLabel = EosbStrings.t('ot_delete', locale);

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (isCorrupt) ...[
                  EosbHistoryCorruptBanner(
                    locale: locale,
                    messageKey: 'eosb_history_corrupt_banner',
                  ),
                  const SizedBox(height: AppSpacing.md),
                ],
                Expanded(
                  child: ListView.builder(
                    itemCount: history.length,
                    itemBuilder: (context, index) {
                      final entry = history[index];
                      final company = entry.input.companyName.trim();
                      final title = !entry.salaryDetailsStored
                          ? EosbStrings.t('eosb_history_metadata_only', locale)
                          : company.isNotEmpty
                          ? company
                          : (entry.label ??
                                EosbStrings.t('eosb_history_unnamed', locale));

                      return Dismissible(
                        key: ValueKey(entry.id),
                        direction: DismissDirection.endToStart,
                        confirmDismiss: (_) =>
                            _tryDeleteEntry(entry.id, locale),
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: AppSpacing.lg),
                          margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                          decoration: BoxDecoration(
                            color: EosbPresentationTokens.chipTextForTone(
                              TruthChipTone.red,
                            ).withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(
                              EosbHubTokens.tileRadius,
                            ),
                          ),
                          child: Semantics(
                            label: deleteLabel,
                            button: true,
                            child: Icon(
                              Icons.delete_outline,
                              color: EosbPresentationTokens.chipTextForTone(
                                TruthChipTone.red,
                              ),
                            ),
                          ),
                        ),
                        child: GlassCard(
                          onTap: () {
                            ref
                                .read(eosbProvider.notifier)
                                .restoreFromHistory(
                                  input: entry.input,
                                  result: entry.result,
                                );
                            context.push('/eosb/result');
                          },
                          margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                          padding: const EdgeInsets.all(AppSpacing.md),
                          borderRadius: EosbHubTokens.tileRadius,
                          glowColor: EosbHubTokens.gold,
                          glowIntensity: EosbHubTokens.tileGlow(true),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(title, style: AppTypography.title),
                                    const SizedBox(height: AppSpacing.xs),
                                    Text(
                                      EosbHistoryDateFormatter.formatEntryDateTime(
                                        entry.savedAt,
                                        locale,
                                      ),
                                      style: AppTypography.caption.copyWith(
                                        color: AppColors.textSecondary,
                                      ),
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
                                  color: EosbHubTokens.gold.withValues(
                                    alpha: 0.12,
                                  ),
                                  borderRadius: BorderRadius.circular(
                                    AppSpacing.radiusXs,
                                  ),
                                  border: Border.all(
                                    color: EosbHubTokens.gold.withValues(
                                      alpha: 0.35,
                                    ),
                                  ),
                                ),
                                child: Text(
                                  entry.salaryDetailsStored
                                      ? formatEosbCurrency(
                                          entry.result.totalEntitlement,
                                        )
                                      : EosbStrings.t(
                                          'eosb_history_metadata_only',
                                          locale,
                                        ),
                                  style: AppTypography.title.copyWith(
                                    color: EosbPresentationTokens.goldText,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.delete_outline,
                                  size: 20,
                                ),
                                tooltip: deleteLabel,
                                color: AppColors.textTertiary,
                                onPressed: () =>
                                    _tryDeleteEntry(entry.id, locale),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
