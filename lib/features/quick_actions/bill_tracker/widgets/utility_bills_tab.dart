import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/l10n/app_locale.dart';
import 'package:raabta/features/quick_actions/bill_tracker/domain/bill_entry.dart';
import 'package:raabta/features/quick_actions/bill_tracker/domain/bill_tracker_summary.dart';
import 'package:raabta/features/quick_actions/bill_tracker/l10n/bill_tracker_date_formatter.dart';
import 'package:raabta/features/quick_actions/bill_tracker/l10n/bill_tracker_strings.dart';
import 'package:raabta/features/quick_actions/bill_tracker/presentation/bill_tracker_bill_actions.dart';
import 'package:raabta/features/quick_actions/bill_tracker/presentation/providers/bill_tracker_providers.dart';
import 'package:raabta/features/quick_actions/bill_tracker/widgets/add_bill_sheet.dart';
import 'package:raabta/features/quick_actions/bill_tracker/domain/bill_anomaly_models.dart';
import 'package:raabta/features/quick_actions/bill_tracker/widgets/bill_action_bar.dart';
import 'package:raabta/features/quick_actions/bill_tracker/widgets/bill_anomaly_card.dart';
import 'package:raabta/features/quick_actions/bill_tracker/widgets/bill_dashboard_widgets.dart';
import 'package:raabta/features/quick_actions/bill_tracker/widgets/bill_provider_links_panel.dart';
import 'package:raabta/features/quick_actions/bill_tracker/widgets/bill_tracker_share_card.dart';
import 'package:raabta/features/quick_actions/bill_tracker/widgets/bill_tracker_empty_state.dart';
import 'package:raabta/features/quick_actions/bill_tracker/widgets/bill_tracker_error_state.dart';
import 'package:raabta/features/quick_actions/bill_tracker/widgets/bill_tracker_loading_state.dart';
import 'package:raabta/providers/visa_providers.dart';
import 'package:raabta/services/ai/claude_ai_service.dart';

class UtilityBillsTab extends ConsumerStatefulWidget {
  const UtilityBillsTab({super.key});

  @override
  ConsumerState<UtilityBillsTab> createState() => _UtilityBillsTabState();
}

class _UtilityBillsTabState extends ConsumerState<UtilityBillsTab> {
  bool _isAnalyzing = false;
  String? _aiAnalysis;

  String get _locale => AppLocale.normalize(ref.watch(userLanguageProvider));

  Future<void> _addBill({
    required String provider,
    required String category,
    required String emoji,
    required double amount,
    required DateTime dueDate,
    String accountNumber = '',
  }) =>
      BillTrackerBillActions.addBill(
        ref,
        context: context,
        provider: provider,
        category: category,
        emoji: emoji,
        amount: amount,
        dueDate: dueDate,
        accountNumber: accountNumber,
      );

  Future<void> _markPaid(String id, bool paid) =>
      BillTrackerBillActions.markPaid(ref, id, paid);

  Future<void> _deleteBill(String id) =>
      BillTrackerBillActions.deleteBill(ref, id);

  Future<void> _analyzeWithAI(List<BillEntry> bills) async {
    if (bills.isEmpty || _isAnalyzing) return;
    setState(() {
      _isAnalyzing = true;
      _aiAnalysis = null;
    });

    try {
      final billSummary = bills
          .map(
            (b) =>
                '${b.displayEmoji} ${b.displayProvider}: '
                'QAR ${b.amount.toStringAsFixed(2)} '
                '(due ${BillTrackerDateFormatter.formatShareShort(b.dueDate, _locale)}, '
                '${b.isPaid ? "PAID" : "UNPAID"})',
          )
          .join('\n');

      final totalUnpaid =
          bills.where((b) => !b.isPaid).fold(0.0, (s, b) => s + b.amount);

      final response = await ref.read(claudeAIServiceProvider).sendMessage(
            'You are a financial advisor for expats in Qatar. '
            'Here are the bills:\n$billSummary\n'
            'Total unpaid: QAR ${totalUnpaid.toStringAsFixed(2)}\n\n'
            'In 3-4 sentences give practical advice: '
            'Is this total typical for Qatar? '
            'Any bill that seems high? '
            'One money-saving tip. '
            'Which to pay first if budget is tight. '
            'Be conversational, friendly, and brief.',
            requestType: 'bill_tracker',
          );

      if (mounted) setState(() => _aiAnalysis = response);
    } catch (_) {
      if (mounted) {
        setState(() {
          _aiAnalysis = BillTrackerStrings.t('ai_error', _locale);
        });
      }
    } finally {
      if (mounted) setState(() => _isAnalyzing = false);
    }
  }

  void _shareSummary(BillTrackerSummary summary) {
    showBillTrackerShareCard(
      context,
      summary: summary,
      locale: _locale,
    );
  }

  void _showAddBillSheet() {
    AddBillSheet.show(
      context,
      locale: _locale,
      onSubmit: ({
        required String provider,
        required String category,
        required String emoji,
        required double amount,
        required DateTime dueDate,
        String accountNumber = '',
      }) =>
          _addBill(
            provider: provider,
            category: category,
            emoji: emoji,
            amount: amount,
            dueDate: dueDate,
            accountNumber: accountNumber,
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final billsAsync = ref.watch(billTrackerEntriesStreamProvider);
    final locale = _locale;

    return billsAsync.when(
      loading: () => BillTrackerLoadingState(locale: locale),
      error: (error, _) => BillTrackerErrorState(
        locale: locale,
        error: error,
        onRetry: () => ref.invalidate(billTrackerEntriesStreamProvider),
      ),
      data: (bills) {
        final summary = BillTrackerSummary.fromBills(bills);
        final anomalies = ref.watch(billAnomaliesProvider);
        final anomalyById = ref.watch(billAnomalyByIdProvider);
        if (summary.isEmpty) {
          return BillTrackerEmptyState(
            locale: locale,
            onAddBill: _showAddBillSheet,
          );
        }
        return _BillListContent(
          summary: summary,
          anomalies: anomalies,
          anomalyById: anomalyById,
          locale: locale,
          aiAnalysis: _aiAnalysis,
          isAnalyzing: _isAnalyzing,
          onAnalyze: () => _analyzeWithAI(summary.all),
          onShare: () => _shareSummary(summary),
          onShareOutstanding: () => _shareSummary(summary),
          onMarkPaid: _markPaid,
          onDelete: _deleteBill,
        );
      },
    );
  }
}

class _BillListContent extends StatelessWidget {
  const _BillListContent({
    required this.summary,
    required this.anomalies,
    required this.anomalyById,
    required this.locale,
    required this.aiAnalysis,
    required this.isAnalyzing,
    required this.onAnalyze,
    required this.onShare,
    required this.onShareOutstanding,
    required this.onMarkPaid,
    required this.onDelete,
  });

  final BillTrackerSummary summary;
  final List<BillAnomaly> anomalies;
  final Map<String, BillAnomaly> anomalyById;
  final String locale;
  final String? aiAnalysis;
  final bool isAnalyzing;
  final VoidCallback onAnalyze;
  final VoidCallback onShare;
  final VoidCallback onShareOutstanding;
  final Future<void> Function(String id, bool paid) onMarkPaid;
  final Future<void> Function(String id) onDelete;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          BillStatsRow(
            locale: locale,
            totalUnpaid: summary.totalUnpaid,
            overdueCount: summary.overdue.length,
            dueSoonCount: summary.dueSoon.length,
            onShareOutstanding: onShareOutstanding,
          ),
          if (anomalies.isNotEmpty) ...[
            const SizedBox(height: 14),
            BillAnomalyCard(anomalies: anomalies, locale: locale),
          ],
          const SizedBox(height: 14),
          BillActionBar(
            locale: locale,
            isAnalyzing: isAnalyzing,
            onAnalyze: onAnalyze,
            onShare: onShare,
          ),
          if (aiAnalysis != null) ...[
            const SizedBox(height: 14),
            BillAiAnalysisCard(analysis: aiAnalysis!),
          ],
          if (summary.overdue.isNotEmpty) ...[
            const SizedBox(height: 20),
            BillSectionHeader(
              title: BillTrackerStrings.t('section_overdue', locale),
              color: AppColors.errorBright,
            ),
            const SizedBox(height: 8),
            ...summary.overdue.map(
              (bill) => BillCard(
                bill: bill,
                locale: locale,
                anomaly: anomalyById[bill.id],
                onMarkPaid: () => onMarkPaid(bill.id, !bill.isPaid),
                onDelete: () => onDelete(bill.id),
              ),
            ),
          ],
          if (summary.dueSoon.isNotEmpty) ...[
            const SizedBox(height: 20),
            BillSectionHeader(
              title: BillTrackerStrings.t('section_due_soon', locale),
              color: AppColors.accentGold,
            ),
            const SizedBox(height: 8),
            ...summary.dueSoon.map(
              (bill) => BillCard(
                bill: bill,
                locale: locale,
                anomaly: anomalyById[bill.id],
                onMarkPaid: () => onMarkPaid(bill.id, !bill.isPaid),
                onDelete: () => onDelete(bill.id),
              ),
            ),
          ],
          if (summary.upcoming.isNotEmpty) ...[
            const SizedBox(height: 20),
            BillSectionHeader(
              title: BillTrackerStrings.t('section_upcoming', locale),
              color: AppColors.isLight
                  ? AppColors.textOnGlassSecondary
                  : Colors.white54,
            ),
            const SizedBox(height: 8),
            ...summary.upcoming.map(
              (bill) => BillCard(
                bill: bill,
                locale: locale,
                anomaly: anomalyById[bill.id],
                onMarkPaid: () => onMarkPaid(bill.id, !bill.isPaid),
                onDelete: () => onDelete(bill.id),
              ),
            ),
          ],
          if (summary.paid.isNotEmpty) ...[
            const SizedBox(height: 20),
            BillSectionHeader(
              title: BillTrackerStrings.t('section_paid', locale),
              color: AppColors.successBright,
            ),
            const SizedBox(height: 8),
            ...summary.paid.map(
              (bill) => BillCard(
                bill: bill,
                locale: locale,
                onMarkPaid: () => onMarkPaid(bill.id, !bill.isPaid),
                onDelete: () => onDelete(bill.id),
                dimmed: true,
              ),
            ),
          ],
          const SizedBox(height: 24),
          BillProviderLinksPanel(locale: locale),
          const SizedBox(height: 48),
        ],
      ),
    );
  }
}
