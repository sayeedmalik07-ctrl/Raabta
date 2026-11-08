import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/features/bill_tracker/friends_family_loans/presentation/providers/loan_providers.dart';
import 'package:raabta/features/bill_tracker/friends_family_loans/presentation/widgets/loan_person_card.dart';
import 'package:raabta/features/quick_actions/bill_tracker/l10n/bill_tracker_strings.dart';
import 'package:raabta/providers/visa_providers.dart';

class LoansOverviewScreen extends ConsumerStatefulWidget {
  const LoansOverviewScreen({super.key});

  @override
  ConsumerState<LoansOverviewScreen> createState() =>
      _LoansOverviewScreenState();
}

class _LoansOverviewScreenState extends ConsumerState<LoansOverviewScreen> {
  bool _showArchive = false;

  @override
  Widget build(BuildContext context) {
    final locale = ref.watch(userLanguageProvider);
    final entriesAsync = ref.watch(loanEntriesStreamProvider);

    return entriesAsync.when(
      loading: () => const Center(
        child: CircularProgressIndicator(
          color: AppColors.sharePurple,
          strokeWidth: 2.5,
        ),
      ),
      error: (error, _) => Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Text(
            BillTrackerStrings.format(
              'loan_load_error',
              locale,
              {'error': '$error'},
            ),
            textAlign: TextAlign.center,
            style: AppTypography.subtitle.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ),
      ),
      data: (_) {
        final active = ref.watch(activePersonSummariesProvider);
        final archived = ref.watch(archivedPersonSummariesProvider);
        final list = _showArchive ? archived : active;

        if (active.isEmpty && archived.isEmpty) {
          return _EmptyLoans(
            locale: locale,
            onAdd: () => context.push('/bill-tracker/loans/add'),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md,
                AppSpacing.sm,
                AppSpacing.md,
                0,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      _showArchive
                          ? BillTrackerStrings.t('loan_archive_header', locale)
                          : BillTrackerStrings.t('loan_active_header', locale),
                      style: AppTypography.caption.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                  if (archived.isNotEmpty)
                    TextButton(
                      onPressed: () =>
                          setState(() => _showArchive = !_showArchive),
                      child: Text(
                        _showArchive
                            ? BillTrackerStrings.t('loan_tab_active', locale)
                            : BillTrackerStrings.t('loan_tab_archive', locale),
                        style: const TextStyle(color: AppColors.cyanGlow),
                      ),
                    ),
                ],
              ),
            ),
            Expanded(
              child: list.isEmpty
                  ? Center(
                      child: Text(
                        _showArchive
                            ? BillTrackerStrings.t('loan_no_archive', locale)
                            : BillTrackerStrings.t('loan_all_settled', locale),
                        style: AppTypography.subtitle.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      itemCount: list.length,
                      itemBuilder: (context, index) {
                        final summary = list[index];
                        return LoanPersonCard(
                          summary: summary,
                          locale: locale,
                          onTap: () => context.push(
                            '/bill-tracker/loans/person?personKey=${Uri.encodeComponent(summary.personKey)}',
                          ),
                        );
                      },
                    ),
            ),
          ],
        );
      },
    );
  }
}

class _EmptyLoans extends StatelessWidget {
  const _EmptyLoans({required this.locale, required this.onAdd});

  final String locale;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('🤝', style: TextStyle(fontSize: 48)),
            const SizedBox(height: AppSpacing.md),
            Text(
              BillTrackerStrings.t('loan_empty_body', locale),
              textAlign: TextAlign.center,
              style: AppTypography.subtitle.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            FilledButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.add_rounded),
              label: Text(BillTrackerStrings.t('loan_add_title', locale)),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.sharePurple,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
