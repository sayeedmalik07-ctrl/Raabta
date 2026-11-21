import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/core/widgets/glass_screen_scaffold.dart';
import 'package:raabta/features/bill_tracker/friends_family_loans/data/models/loan_entry_model.dart';
import 'package:raabta/features/bill_tracker/friends_family_loans/domain/loan_actions.dart';
import 'package:raabta/features/bill_tracker/friends_family_loans/presentation/providers/loan_providers.dart';
import 'package:raabta/features/quick_actions/bill_tracker/l10n/bill_tracker_strings.dart';
import 'package:raabta/providers/visa_providers.dart';
import 'package:raabta/services/raabta_notification_service.dart';

class AddLoanScreen extends ConsumerStatefulWidget {
  const AddLoanScreen({super.key});

  @override
  ConsumerState<AddLoanScreen> createState() => _AddLoanScreenState();
}

class _AddLoanScreenState extends ConsumerState<AddLoanScreen> {
  final _personCtrl = TextEditingController();
  final _amountCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  LoanDirection _direction = LoanDirection.lent;
  DateTime _loanDate = DateTime.now();
  DateTime _dueDate = DateTime.now().add(const Duration(days: 30));
  bool _saving = false;

  @override
  void dispose() {
    _personCtrl.dispose();
    _amountCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate({required bool isLoanDate}) async {
    final initial = isLoanDate ? _loanDate : _dueDate;
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
      builder: (ctx, child) => Theme(
        data: ThemeData.dark().copyWith(
          colorScheme: ColorScheme.dark(
            primary: AppColors.sharePurple,
            surface: AppColors.surfaceElevated,
          ),
        ),
        child: child!,
      ),
    );
    if (picked == null) return;
    setState(() {
      if (isLoanDate) {
        _loanDate = picked;
      } else {
        _dueDate = picked;
      }
    });
  }

  Future<void> _save() async {
    final locale = ref.read(userLanguageProvider);
    final person = _personCtrl.text.trim();
    final amount = double.tryParse(_amountCtrl.text.trim());
    if (person.isEmpty || amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            BillTrackerStrings.t('loan_validation_person_amount', locale),
          ),
        ),
      );
      return;
    }

    setState(() => _saving = true);
    try {
      final userId =
          await RaabtaNotificationService.instance.getOrCreateUserId();
      final repo = ref.read(loanRepositoryProvider);
      final loanId = await repo.addLoan(
        userId: userId,
        personName: person,
        direction: _direction,
        amount: amount,
        loanDate: _loanDate,
        dueDate: _dueDate,
        notes: _notesCtrl.text.trim(),
      );

      final entry = LoanEntryModel(
        id: loanId,
        userId: userId,
        personName: person,
        direction: _direction,
        amount: amount,
        loanDate: _loanDate,
        dueDate: _dueDate,
        notes: _notesCtrl.text.trim(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      await syncLoanReminders(entry);

      if (mounted) context.pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              BillTrackerStrings.format(
                'loan_save_failed',
                locale,
                {'error': '$e'},
              ),
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final locale = ref.watch(userLanguageProvider);
    final knownNames = ref.watch(knownLoanPersonNamesProvider);

    return GlassScreenScaffold(
      title: BillTrackerStrings.t('loan_add_title', locale),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          Autocomplete<String>(
            optionsBuilder: (textEditingValue) {
              if (textEditingValue.text.isEmpty) {
                return knownNames;
              }
              return knownNames.where(
                (n) => n.toLowerCase().contains(
                      textEditingValue.text.toLowerCase(),
                    ),
              );
            },
            onSelected: (value) => _personCtrl.text = value,
            fieldViewBuilder: (context, controller, focusNode, onSubmitted) {
              if (_personCtrl.text.isNotEmpty &&
                  controller.text != _personCtrl.text) {
                controller.text = _personCtrl.text;
              }
              controller.addListener(() => _personCtrl.text = controller.text);
              return TextField(
                controller: controller,
                focusNode: focusNode,
                decoration: InputDecoration(
                  labelText: BillTrackerStrings.t('loan_person_name', locale),
                  hintText: BillTrackerStrings.t('loan_person_hint', locale),
                ),
              );
            },
          ),
          const SizedBox(height: AppSpacing.md),
          SegmentedButton<LoanDirection>(
            segments: [
              ButtonSegment(
                value: LoanDirection.lent,
                label: Text(BillTrackerStrings.t('loan_direction_lent', locale)),
                icon: const Icon(Icons.arrow_downward_rounded),
              ),
              ButtonSegment(
                value: LoanDirection.borrowed,
                label: Text(
                  BillTrackerStrings.t('loan_direction_borrowed', locale),
                ),
                icon: const Icon(Icons.arrow_upward_rounded),
              ),
            ],
            selected: {_direction},
            onSelectionChanged: (value) =>
                setState(() => _direction = value.first),
          ),
          const SizedBox(height: AppSpacing.md),
          TextField(
            controller: _amountCtrl,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              labelText: BillTrackerStrings.t('label_amount', locale),
              prefixText: 'QAR ',
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(BillTrackerStrings.t('loan_date_label', locale)),
            subtitle: Text(
              '${_loanDate.day}/${_loanDate.month}/${_loanDate.year}',
            ),
            trailing: const Icon(Icons.calendar_today_rounded),
            onTap: () => _pickDate(isLoanDate: true),
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(BillTrackerStrings.t('loan_due_date_label', locale)),
            subtitle: Text(
              '${_dueDate.day}/${_dueDate.month}/${_dueDate.year}',
            ),
            trailing: const Icon(Icons.event_rounded),
            onTap: () => _pickDate(isLoanDate: false),
          ),
          const SizedBox(height: AppSpacing.sm),
          TextField(
            controller: _notesCtrl,
            maxLines: 3,
            decoration: InputDecoration(
              labelText: BillTrackerStrings.t('loan_notes_optional', locale),
              hintText: BillTrackerStrings.t('loan_notes_hint', locale),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          FilledButton(
            onPressed: _saving ? null : _save,
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.sharePurple,
              minimumSize: const Size.fromHeight(48),
            ),
            child: _saving
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(
                    BillTrackerStrings.t('loan_save_button', locale),
                    style: AppTypography.subtitle.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
