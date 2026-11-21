import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/glass/glass_card.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/core/widgets/glass_primary_button.dart';
import 'package:raabta/core/widgets/glass_screen_scaffold.dart';
import 'package:raabta/core/widgets/truth_confidence_banner.dart';
import 'package:raabta/features/case_timeline/domain/case_timeline_engine_type.dart';
import 'package:raabta/features/case_timeline/domain/case_timeline_entry_type.dart';
import 'package:raabta/features/case_timeline/presentation/navigation/case_timeline_navigation.dart';
import 'package:raabta/features/case_timeline/presentation/providers/case_timeline_providers.dart';
import 'package:raabta/features/eosb/domain/models/payslip_consistency_models.dart';
import 'package:raabta/features/eosb/domain/services/payslip_consistency_checker.dart';
import 'package:raabta/features/eosb/presentation/l10n/eosb_strings.dart';
import 'package:raabta/features/eosb/presentation/widgets/eosb_disclaimer_banner.dart';
import 'package:raabta/features/eosb/providers/eosb_providers.dart';
import 'package:raabta/providers/auth_providers.dart';

class _PayslipRowDraft {
  _PayslipRowDraft({
    int? year,
    this.month = 1,
    this.basicSalary = '',
    this.housing = '',
    this.transport = '',
    this.employer = '',
    this.showAllowances = false,
  }) : year = year ?? DateTime.now().year;

  int month;
  int year;
  String basicSalary;
  String housing;
  String transport;
  String employer;
  bool showAllowances;
}

/// Part B — manual payslip salary comparison against contract on file.
class PayslipConsistencyScreen extends ConsumerStatefulWidget {
  const PayslipConsistencyScreen({super.key});

  @override
  ConsumerState<PayslipConsistencyScreen> createState() =>
      _PayslipConsistencyScreenState();
}

class _PayslipConsistencyScreenState
    extends ConsumerState<PayslipConsistencyScreen> {
  final _rows = [_PayslipRowDraft(), _PayslipRowDraft()];
  PayslipConsistencyResult? _result;

  PayslipContractReference _contractFromInput() {
    final input = ref.read(eosbProvider).input;
    return PayslipContractReference(
      basicSalary: input.basicSalary,
      companyName: input.companyName,
      housingAllowance: input.housingAllowance,
      transportAllowance: input.transportAllowance,
    );
  }

  List<PayslipManualEntry> _entriesFromRows() {
    return _rows
        .map((row) {
          final basic = double.tryParse(row.basicSalary.trim()) ?? 0;
          if (basic <= 0) return null;
          final housing = row.housing.trim().isEmpty
              ? null
              : double.tryParse(row.housing.trim());
          final transport = row.transport.trim().isEmpty
              ? null
              : double.tryParse(row.transport.trim());
          return PayslipManualEntry(
            year: row.year,
            month: row.month,
            basicSalary: basic,
            housingAllowance: housing,
            transportAllowance: transport,
            employerName:
                row.employer.trim().isEmpty ? null : row.employer.trim(),
          );
        })
        .whereType<PayslipManualEntry>()
        .toList();
  }

  void _runComparison(String locale) {
    final entries = _entriesFromRows();
    setState(() {
      _result = PayslipConsistencyChecker.compare(
        entries: entries,
        contract: _contractFromInput(),
        locale: locale,
      );
    });
  }

  Future<void> _addTimelineNote(String locale) async {
    final result = _result;
    final uid = ref.read(currentUserProvider)?.uid;
    final eosbResult = ref.read(eosbProvider).result;
    if (uid == null || result == null || !result.hasDiscrepancies) return;

    final caseId = eosbResult != null
        ? CaseTimelineNavigation.eosbCaseIdFromCalculatedAt(
            eosbResult.calculatedAt,
          )
        : CaseTimelineNavigation.eosbCaseIdFromCalculatedAt(DateTime.now());

    final summary = result.discrepancies
        .map(
          (d) => EosbStrings.format(d.messageKey, locale, d.params),
        )
        .join('\n');

    await ref.read(caseTimelineServiceProvider).addEntry(
          userId: uid,
          engineType: CaseTimelineEngineType.eosb,
          caseId: caseId,
          entryDate: DateTime.now(),
          entryType: CaseTimelineEntryType.note,
          title: EosbStrings.t('eosb_payslip_timeline_title', locale),
          description: summary,
        );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(EosbStrings.t('eosb_payslip_timeline_saved', locale)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final localeAsync = ref.watch(eosbLocaleProvider);
    final contract = ref.watch(eosbProvider.select((s) => s.input));

    return localeAsync.when(
      loading: () => const GlassScreenScaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (_, _) => const SizedBox.shrink(),
      data: (locale) {
        final validCount = _entriesFromRows().length;
        final result = _result;

        return GlassScreenScaffold(
          title: EosbStrings.t('eosb_payslip_title', locale),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.pop(),
          ),
          padding: const EdgeInsets.all(AppSpacing.lg),
          body: ListView(
            children: [
              EosbDisclaimerBanner(locale: locale),
              const SizedBox(height: AppSpacing.md),
              Text(
                EosbStrings.t('eosb_payslip_subtitle', locale),
                style: AppTypography.bodySmall,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                EosbStrings.t('eosb_payslip_no_accusation', locale),
                style: AppTypography.caption.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              TruthConfidenceBanner(
                locale: locale,
                state: TruthConfidenceState.known,
                text: contract.basicSalary > 0
                    ? EosbStrings.format('eosb_payslip_contract_known', locale, {
                        'salary': contract.basicSalary
                            .toStringAsFixed(
                              contract.basicSalary.truncateToDouble() ==
                                      contract.basicSalary
                                  ? 0
                                  : 2,
                            ),
                        'employer': contract.companyName.trim().isNotEmpty
                            ? contract.companyName.trim()
                            : EosbStrings.t('eosb_payslip_not_set', locale),
                      })
                    : EosbStrings.t('eosb_payslip_no_contract', locale),
              ),
              const SizedBox(height: AppSpacing.lg),
              if (validCount < kMinPayslipEntriesForComparison)
                GlassCard(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        EosbStrings.t('eosb_payslip_need_more', locale),
                        style: AppTypography.title,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        EosbStrings.format('eosb_payslip_progress', locale, {
                          'current': validCount.toString(),
                          'required':
                              kMinPayslipEntriesForComparison.toString(),
                        }),
                        style: AppTypography.bodySmall,
                      ),
                    ],
                  ),
                ),
              for (var i = 0; i < _rows.length; i++)
                _PayslipEntryCard(
                  locale: locale,
                  index: i,
                  row: _rows[i],
                  onChanged: () => setState(() => _result = null),
                  onRemove: _rows.length > 2
                      ? () => setState(() {
                            _rows.removeAt(i);
                            _result = null;
                          })
                      : null,
                ),
              const SizedBox(height: AppSpacing.sm),
              OutlinedButton.icon(
                onPressed: () => setState(() {
                  _rows.add(_PayslipRowDraft());
                  _result = null;
                }),
                icon: const Icon(Icons.add),
                label: Text(EosbStrings.t('eosb_payslip_add_row', locale)),
              ),
              const SizedBox(height: AppSpacing.md),
              GlassPrimaryButton(
                label: EosbStrings.t('eosb_payslip_run', locale),
                icon: Icons.compare_arrows,
                expand: true,
                onPressed: validCount >= kMinPayslipEntriesForComparison
                    ? () => _runComparison(locale)
                    : null,
              ),
              if (result != null && result.hasEnoughEntries) ...[
                const SizedBox(height: AppSpacing.lg),
                Text(
                  EosbStrings.t('eosb_payslip_results_heading', locale),
                  style: AppTypography.title,
                ),
                const SizedBox(height: AppSpacing.sm),
                if (!result.hasDiscrepancies)
                  TruthConfidenceBanner(
                    locale: locale,
                    state: TruthConfidenceState.known,
                    text: EosbStrings.t('eosb_payslip_no_discrepancies', locale),
                  )
                else ...[
                  TruthConfidenceBanner(
                    locale: locale,
                    state: TruthConfidenceState.possible,
                    text: EosbStrings.t('eosb_payslip_possible_framing', locale),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  for (final d in result.discrepancies)
                    Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                      child: GlassCard(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        glowColor: AppColors.cyanGlow,
                        glowIntensity: 0.08,
                        child: Text(
                          '${EosbStrings.format(d.messageKey, locale, d.params)} ${EosbStrings.t('eosb_payslip_verify_suffix', locale)}',
                          style: AppTypography.bodySmall,
                        ),
                      ),
                    ),
                  const SizedBox(height: AppSpacing.sm),
                  TruthConfidenceBanner(
                    locale: locale,
                    state: TruthConfidenceState.action,
                    text: EosbStrings.t('eosb_payslip_action_hr', locale),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  OutlinedButton.icon(
                    onPressed: () => _addTimelineNote(locale),
                    icon: const Icon(Icons.timeline_outlined),
                    label: Text(
                      EosbStrings.t('eosb_payslip_add_timeline', locale),
                    ),
                  ),
                ],
              ],
              if (contract.basicSalary <= 0) ...[
                const SizedBox(height: AppSpacing.md),
                TextButton(
                  onPressed: () => context.push('/eosb/employee-info'),
                  child: Text(
                    EosbStrings.t('eosb_payslip_set_contract', locale),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _PayslipEntryCard extends StatelessWidget {
  const _PayslipEntryCard({
    required this.locale,
    required this.index,
    required this.row,
    required this.onChanged,
    this.onRemove,
  });

  final String locale;
  final int index;
  final _PayslipRowDraft row;
  final VoidCallback onChanged;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: GlassCard(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  '${EosbStrings.t('eosb_payslip_row_label', locale)} ${index + 1}',
                  style: AppTypography.title.copyWith(fontSize: 14),
                ),
                const Spacer(),
                if (onRemove != null)
                  IconButton(
                    icon: const Icon(Icons.close, size: 20),
                    onPressed: onRemove,
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<int>(
                    value: row.month,
                    decoration: InputDecoration(
                      labelText: EosbStrings.t('eosb_payslip_month', locale),
                    ),
                    items: List.generate(
                      12,
                      (i) => DropdownMenuItem(
                        value: i + 1,
                        child: Text('${i + 1}'),
                      ),
                    ),
                    onChanged: (v) {
                      if (v != null) {
                        row.month = v;
                        onChanged();
                      }
                    },
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: TextFormField(
                    initialValue: row.year.toString(),
                    decoration: InputDecoration(
                      labelText: EosbStrings.t('eosb_payslip_year', locale),
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    onChanged: (v) {
                      row.year = int.tryParse(v) ?? row.year;
                      onChanged();
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            TextFormField(
              initialValue: row.basicSalary,
              decoration: InputDecoration(
                labelText:
                    EosbStrings.t('eosb_payslip_basic_salary', locale),
              ),
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              onChanged: (v) {
                row.basicSalary = v;
                onChanged();
              },
            ),
            TextButton(
              onPressed: () {
                row.showAllowances = !row.showAllowances;
                onChanged();
              },
              child: Text(
                row.showAllowances
                    ? EosbStrings.t('eosb_payslip_hide_optional', locale)
                    : EosbStrings.t('eosb_payslip_show_optional', locale),
              ),
            ),
            if (row.showAllowances) ...[
              TextFormField(
                initialValue: row.housing,
                decoration: InputDecoration(
                  labelText: EosbStrings.t('eosb_payslip_housing', locale),
                ),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                onChanged: (v) {
                  row.housing = v;
                  onChanged();
                },
              ),
              TextFormField(
                initialValue: row.transport,
                decoration: InputDecoration(
                  labelText: EosbStrings.t('eosb_payslip_transport', locale),
                ),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                onChanged: (v) {
                  row.transport = v;
                  onChanged();
                },
              ),
              TextFormField(
                initialValue: row.employer,
                decoration: InputDecoration(
                  labelText: EosbStrings.t('eosb_payslip_employer', locale),
                ),
                onChanged: (v) {
                  row.employer = v;
                  onChanged();
                },
              ),
            ],
          ],
        ),
      ),
    );
  }
}
