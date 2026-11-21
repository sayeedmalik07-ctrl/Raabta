import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/features/eosb/presentation/l10n/eosb_strings.dart';
import 'package:raabta/features/eosb/presentation/widgets/calculator_form_widgets.dart';
import 'package:raabta/features/eosb/providers/overtime_truth_providers.dart';

/// Employer-paid OT fields for calendar / employee paths.
class OvertimeEmployerComparisonFields extends ConsumerStatefulWidget {
  const OvertimeEmployerComparisonFields({super.key, required this.locale});

  final String locale;

  @override
  ConsumerState<OvertimeEmployerComparisonFields> createState() =>
      _OvertimeEmployerComparisonFieldsState();
}

class _OvertimeEmployerComparisonFieldsState
    extends ConsumerState<OvertimeEmployerComparisonFields> {
  late TextEditingController _paid;
  late TextEditingController _hours;

  @override
  void initState() {
    super.initState();
    final record = ref.read(overtimeTruthProvider).record;
    _paid = TextEditingController(
      text: record.employerPaidOvertime > 0
          ? record.employerPaidOvertime.toStringAsFixed(0)
          : '',
    );
    _hours = TextEditingController(
      text: record.employerReportedHours > 0
          ? record.employerReportedHours.toStringAsFixed(1)
          : '',
    );
  }

  @override
  void dispose() {
    _paid.dispose();
    _hours.dispose();
    super.dispose();
  }

  void _sync() {
    ref.read(overtimeTruthProvider.notifier).setEmployerComparison(
          paid: double.tryParse(_paid.text.trim()) ?? 0,
          hours: double.tryParse(_hours.text.trim()) ?? 0,
        );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const CalculatorSectionHeader(
          title: 'Employer records',
          subtitle: 'Compare payslip amounts to your legal entitlement',
          icon: Icons.receipt_long_outlined,
        ),
        CalculatorFormSection(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CalculatorTextField(
                controller: _paid,
                label: EosbStrings.t('ot_employer_paid', widget.locale),
                hint: '0',
                prefix: 'QAR ',
                icon: Icons.payments_outlined,
                keyboardType: TextInputType.number,
                onChanged: (_) => _sync(),
              ),
              const SizedBox(height: AppSpacing.lg),
              CalculatorTextField(
                controller: _hours,
                label: EosbStrings.t('ot_employer_hours', widget.locale),
                hint: '0',
                icon: Icons.timer_outlined,
                keyboardType: TextInputType.number,
                onChanged: (_) => _sync(),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
