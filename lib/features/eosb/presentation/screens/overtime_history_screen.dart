import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:raabta/core/glass/glass_card.dart';
import 'package:raabta/core/glass/glass_container.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/core/l10n/common_action_strings.dart';
import 'package:raabta/core/widgets/glass_screen_scaffold.dart';
import 'package:raabta/features/eosb/domain/models/eosb_history_load_outcome.dart';
import 'package:raabta/features/eosb/domain/models/overtime_truth_models.dart';
import 'package:raabta/features/eosb/presentation/l10n/eosb_strings.dart';
import 'package:raabta/features/eosb/presentation/widgets/eosb_history_corrupt_banner.dart';
import 'package:raabta/features/eosb/presentation/widgets/shared/eosb_shared_widgets.dart';
import 'package:raabta/features/eosb/providers/eosb_providers.dart';
import 'package:raabta/features/eosb/providers/overtime_truth_providers.dart';

class OvertimeHistoryScreen extends ConsumerWidget {
  const OvertimeHistoryScreen({super.key});

  static Widget _backButton(BuildContext context) => IconButton(
    icon: const Icon(Icons.arrow_back),
    onPressed: () => context.pop(),
  );

  static bool _isGenuinelyEmpty(OvertimeTruthState state) {
    if (state.historyStorageCorrupt) return false;
    return state.history.isEmpty &&
        (state.historyLoadStatus == EosbHistoryStorageStatus.absent ||
            state.historyLoadStatus == EosbHistoryStorageStatus.valid);
  }

  static Future<void> _runHistoryMutation(
    BuildContext context,
    WidgetRef ref,
    String locale,
    Future<void> Function() action,
  ) async {
    await action();
    if (!context.mounted) return;
    final state = ref.read(overtimeTruthProvider);
    if (state.error == null) return;
    final messageKey = state.historyStorageCorrupt
        ? eosbHistoryCorruptWriteBlockedErrorCode
        : state.error!;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(EosbStrings.t(messageKey, locale))));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localeAsync = ref.watch(eosbLocaleProvider);

    final presentationLocale = ref.watch(eosbPresentationLocaleProvider);
    final otState = ref.watch(overtimeTruthProvider);
    final history = otState.filteredHistory;

    return localeAsync.when(
      loading: () => GlassScreenScaffold(
        title: EosbStrings.t('ot_history', presentationLocale),
        titleStyle: _historyTitleStyle(context),
        leading: _backButton(context),
        body: Center(
          child: CircularProgressIndicator(
            color: EosbPresentationTokens.primaryAction,
          ),
        ),
      ),
      error: (_, _) => GlassScreenScaffold(
        title: EosbStrings.t('ot_history', presentationLocale),
        titleStyle: _historyTitleStyle(context),
        leading: _backButton(context),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: EosbEmptyState(
              icon: Icons.error_outline,
              title: EosbStrings.t('ot_locale_load_error', presentationLocale),
              description: EosbStrings.t('ot_subtitle', presentationLocale),
            ),
          ),
        ),
      ),
      data: (locale) {
        return GlassScreenScaffold(
          title: EosbStrings.t('ot_history', locale),
          titleStyle: _historyTitleStyle(context),
          leading: _backButton(context),
          padding: const EdgeInsets.all(AppSpacing.lg),
          body: Column(
            children: [
              GlassContainer(
                padding: EdgeInsets.zero,
                borderRadius: EosbPresentationTokens.cardRadius,
                child: TextField(
                  decoration: InputDecoration(
                    hintText: EosbStrings.t('ot_search', locale),
                    prefixIcon: const Icon(Icons.search),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.all(AppSpacing.md),
                  ),
                  onChanged: (q) => ref
                      .read(overtimeTruthProvider.notifier)
                      .setSearchQuery(q),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              if (otState.historyStorageCorrupt && otState.history.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.md),
                  child: EosbHistoryCorruptBanner(
                    locale: locale,
                    messageKey: 'ot_history_corrupt_banner',
                  ),
                ),
              Expanded(
                child: _HistoryBody(
                  locale: locale,
                  otState: otState,
                  filteredHistory: history,
                  onRetryHydration: () =>
                      ref.read(overtimeTruthProvider.notifier).retryHydration(),
                  onOpen: (record) {
                    ref
                        .read(overtimeTruthProvider.notifier)
                        .updateRecord(record);
                    ref.read(overtimeTruthProvider.notifier).calculate();
                    context.push('/eosb/overtime/summary');
                  },
                  onFavorite: (record) => _runHistoryMutation(
                    context,
                    ref,
                    locale,
                    () => ref
                        .read(overtimeTruthProvider.notifier)
                        .toggleFavorite(record.id),
                  ),
                  onDuplicate: (record) => _runHistoryMutation(
                    context,
                    ref,
                    locale,
                    () => ref
                        .read(overtimeTruthProvider.notifier)
                        .duplicateHistoryRecord(record),
                  ),
                  onDelete: (record) => _runHistoryMutation(
                    context,
                    ref,
                    locale,
                    () => ref
                        .read(overtimeTruthProvider.notifier)
                        .deleteFromHistory(record.id),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _HistoryBody extends StatelessWidget {
  const _HistoryBody({
    required this.locale,
    required this.otState,
    required this.filteredHistory,
    required this.onRetryHydration,
    required this.onOpen,
    required this.onFavorite,
    required this.onDuplicate,
    required this.onDelete,
  });

  final String locale;
  final OvertimeTruthState otState;
  final List<OvertimeMonthlyRecord> filteredHistory;
  final Future<void> Function() onRetryHydration;
  final void Function(OvertimeMonthlyRecord record) onOpen;
  final void Function(OvertimeMonthlyRecord record) onFavorite;
  final void Function(OvertimeMonthlyRecord record) onDuplicate;
  final void Function(OvertimeMonthlyRecord record) onDelete;

  @override
  Widget build(BuildContext context) {
    if (otState.isHydrating) {
      return Center(
        child: CircularProgressIndicator(
          color: EosbPresentationTokens.primaryAction,
        ),
      );
    }

    if (otState.error == overtimeHydrationFailedErrorCode) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: EosbEmptyState(
            icon: Icons.error_outline,
            title: EosbStrings.t('ot_history_hydration_failed', locale),
            description: EosbStrings.t(
              'ot_history_hydration_failed_desc',
              locale,
            ),
            actionLabel: CommonActionStrings.t('action_retry', locale),
            onAction: () => onRetryHydration(),
          ),
        ),
      );
    }

    if (otState.history.isEmpty) {
      if (otState.historyStorageCorrupt) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: EosbEmptyState(
              icon: Icons.error_outline,
              title: EosbStrings.t('ot_history_corrupt_empty_title', locale),
              description: EosbStrings.t(
                'ot_history_corrupt_empty_desc',
                locale,
              ),
            ),
          ),
        );
      }
      if (OvertimeHistoryScreen._isGenuinelyEmpty(otState)) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: EosbEmptyState(
              icon: Icons.history,
              title: EosbStrings.t('ot_history_empty', locale),
              description: EosbStrings.t('ot_history_empty_desc', locale),
              actionLabel: EosbStrings.t('ot_calendar_mode', locale),
              onAction: () => context.push('/eosb/overtime/calendar'),
            ),
          ),
        );
      }
    }

    if (filteredHistory.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: EosbEmptyState(
            icon: Icons.history,
            title: EosbStrings.t('ot_history_empty', locale),
            description: EosbStrings.t('ot_history_empty_desc', locale),
            actionLabel: EosbStrings.t('ot_calendar_mode', locale),
            onAction: () => context.push('/eosb/overtime/calendar'),
          ),
        ),
      );
    }

    return ListView.builder(
      itemCount: filteredHistory.length,
      itemBuilder: (context, index) {
        final record = filteredHistory[index];
        return _HistoryTile(
          record: record,
          locale: locale,
          onOpen: () => onOpen(record),
          onFavorite: () => onFavorite(record),
          onDuplicate: () => onDuplicate(record),
          onDelete: () => onDelete(record),
        );
      },
    );
  }
}

TextStyle _historyTitleStyle(BuildContext context) =>
    AppTypography.headline2.copyWith(fontSize: 17, height: 1.2);

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
    final otHours = record.days.fold<double>(0, (s, d) => s + d.totalHours);

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: GlassCard(
        onTap: onOpen,
        borderRadius: EosbPresentationTokens.cardRadius,
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(record.label, style: AppTypography.title),
                  Text(
                    record.salaryDetailsStored
                        ? (record.profile.companyName.isEmpty
                              ? EosbStrings.t('ot_no_company', locale)
                              : record.profile.companyName)
                        : EosbStrings.t('eosb_history_metadata_only', locale),
                    style: AppTypography.bodySmall,
                  ),
                  Text(
                    record.salaryDetailsStored
                        ? '${otHours.toStringAsFixed(1)}h · '
                              '${formatEosbCurrency(record.employerPaidOvertime)} paid'
                        : '${otHours.toStringAsFixed(1)}h',
                    style: AppTypography.caption,
                  ),
                ],
              ),
            ),
            IconButton(
              icon: Icon(
                record.isFavorite ? Icons.star : Icons.star_border,
                color: EosbPresentationTokens.goldAccent,
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
