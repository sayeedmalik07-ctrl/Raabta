import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:raabta/services/notifications/notification_service.dart';
import 'package:raabta/core/colors/app_colors.dart';

import '../models/recurring_split_group.dart';

class SaveRecurringSheet extends StatefulWidget {
  final double totalQar;
  final double taxPercent;
  // ✅ Accepts the existing _Person-equivalent list from the
  // caller. We use dynamic here so this widget does not
  // import or depend on the private _Person class — the
  // caller converts to SplitMember before passing.
  final List<SplitMember> members;
  final VoidCallback onSaved;

  const SaveRecurringSheet({
    super.key,
    required this.totalQar,
    required this.taxPercent,
    required this.members,
    required this.onSaved,
  });

  static Future<void> show(
    BuildContext context, {
    required double totalQar,
    required double taxPercent,
    required List<SplitMember> members,
    required VoidCallback onSaved,
  }) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.isLight
          ? AppColors.surfaceElevated
          : const Color(0xFF1A1035),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      builder: (_) => SaveRecurringSheet(
        totalQar:   totalQar,
        taxPercent: taxPercent,
        members:    members,
        onSaved:    onSaved,
      ),
    );
  }

  @override
  State<SaveRecurringSheet> createState() =>
      _SaveRecurringSheetState();
}

class _SaveRecurringSheetState
    extends State<SaveRecurringSheet> {

  final _nameController = TextEditingController();
  SplitBillType _billType = SplitBillType.rent;
  SplitRecurrence _recurrence = SplitRecurrence.monthly;
  bool _isSaving = false;

  final _billTypeLabels = {
    SplitBillType.rent:       '🏠  Rent',
    SplitBillType.utilities:  '⚡  Utilities',
    SplitBillType.groceries:  '🛒  Groceries',
    SplitBillType.internet:   '📡  Internet',
    SplitBillType.dining:     '🍽️  Dining',
    SplitBillType.other:      '📄  Other',
  };

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (widget.members.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Add at least one person first.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() { _isSaving = true; });

    try {
      final groupName = _nameController.text.trim().isEmpty
          ? '${_billType.name} split'
          : _nameController.text.trim();

      final nextCycle =
          RecurringSplitGroup.computeNextCycleDate(
        _recurrence,
      );

      final group = RecurringSplitGroup(
        id:           '',
        groupName:    groupName,
        billType:     _billType,
        recurrence:   _recurrence,
        members:      widget.members,
        totalQar:     widget.totalQar,
        taxPercent:   widget.taxPercent,
        createdAt:    DateTime.now(),
        nextCycleDate: nextCycle,
        isActive:     true,
      );

      final ref = await FirebaseFirestore.instance
          .collection(
            RecurringSplitGroup.firestoreCollection,
          )
          .add(group.toFirestore());

      // Initialize payment records for all members
      final batch = FirebaseFirestore.instance.batch();
      for (final member in widget.members) {
        final payRef = ref
            .collection(
              RecurringSplitGroup.paymentsSubcollection,
            )
            .doc();
        batch.set(payRef, {
          'memberId':   member.id,
          'memberName': member.name,
          'paid':       false,
          'paidAt':     null,
          'cycleDate':  Timestamp.fromDate(nextCycle),
          'amountQar':  member.shareQar,
        });
      }
      await batch.commit();

      await NotificationService.scheduleBillSplitReminder(
        groupId: ref.id,
        groupName: groupName,
        billTypeLabel: _billType.label,
        totalQar: widget.totalQar,
        memberCount: widget.members.length,
        nextCycleDate: nextCycle,
      );

      if (mounted) {
        Navigator.pop(context);
        widget.onSaved();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not save: $e'),
            backgroundColor: AppColors.errorBright,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() { _isSaving = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        20, 20, 20,
        MediaQuery.of(context).viewInsets.bottom + 32,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 36, height: 4,
                decoration: BoxDecoration(
                  color: AppColors.isLight
                      ? AppColors.glassBorder
                      : Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              '🔄  Save as Recurring Split',
              style: TextStyle(
                color: AppColors.isLight
                    ? AppColors.textPrimary
                    : Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 17,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${widget.members.length} people  •  '
              'QAR ${widget.totalQar.toStringAsFixed(2)}',
              style: TextStyle(
                color: AppColors.isLight
                    ? AppColors.textOnGlassMuted
                    : Colors.white.withValues(alpha: 0.4),
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 20),

            // Group name
            _Label('Group name (optional)'),
            const SizedBox(height: 6),
            TextField(
              controller: _nameController,
              style: TextStyle(
                color: AppColors.isLight
                    ? AppColors.textPrimary
                    : Colors.white,
              ),
              decoration: InputDecoration(
                hintText: 'e.g. Apartment rent, Weekly groceries',
                hintStyle: TextStyle(
                  color: AppColors.isLight
                      ? AppColors.textOnGlassMuted
                      : Colors.white.withValues(alpha: 0.25),
                  fontSize: 13,
                ),
                fillColor: AppColors.isLight
                    ? AppColors.glassSurface
                    : Colors.white.withValues(alpha: 0.06),
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: AppColors.accentGold,
                    width: 1.5,
                  ),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14, vertical: 13,
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Bill type
            _Label('Bill Type'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8, runSpacing: 8,
              children: _billTypeLabels.entries.map((e) {
                final selected = _billType == e.key;
                return GestureDetector(
                  onTap: () =>
                      setState(() => _billType = e.key),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: selected
                          ? AppColors.sharePurple
                          : AppColors.sharePurple
                              .withValues(alpha: 0.08),
                      borderRadius:
                          BorderRadius.circular(20),
                      border: Border.all(
                        color: AppColors.sharePurple
                            .withValues(
                          alpha: selected ? 1.0 : 0.25,
                        ),
                      ),
                    ),
                    child: Text(
                      e.value,
                      style: TextStyle(
                        color: selected
                            ? Colors.white
                            : AppColors.sharePurple,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 16),

            // Recurrence
            _Label('Repeat every'),
            const SizedBox(height: 8),
            Row(
              children: SplitRecurrence.values.map((r) {
                final selected = _recurrence == r;
                return Expanded(
                  child: GestureDetector(
                    onTap: () =>
                        setState(() => _recurrence = r),
                    child: Container(
                      margin: EdgeInsets.only(
                        right: r != SplitRecurrence.monthly
                            ? 8
                            : 0,
                      ),
                      padding: const EdgeInsets.symmetric(
                        vertical: 11,
                      ),
                      decoration: BoxDecoration(
                        color: selected
                            ? AppColors.accentGold
                            : AppColors.isLight
                                ? AppColors.glassSurface
                                : Colors.white.withValues(alpha: 0.05),
                        borderRadius:
                            BorderRadius.circular(10),
                        border: Border.all(
                          color: selected
                              ? AppColors.accentGold
                              : AppColors.isLight
                                  ? AppColors.glassBorder
                                  : Colors.white.withValues(alpha: 0.1),
                        ),
                      ),
                      child: Text(
                        r.shortLabel,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: selected
                              ? Colors.black
                              : AppColors.isLight
                                  ? AppColors.textOnGlassSecondary
                                  : Colors.white54,
                          fontWeight: FontWeight.w700,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isSaving ? null : _save,
                icon: _isSaving
                    ? const SizedBox(
                        width: 16, height: 16,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Icon(
                        Icons.repeat_rounded,
                        color: Colors.white, size: 18,
                      ),
                label: Text(
                  _isSaving
                      ? 'Saving...'
                      : 'Save Recurring Split',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.sharePurple,
                  disabledBackgroundColor:
                      AppColors.sharePurple.withValues(alpha: 0.4),
                  padding: const EdgeInsets.symmetric(
                    vertical: 15,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Label extends StatelessWidget {
  final String text;
  const _Label(this.text);
  @override
  Widget build(BuildContext context) => Text(
    text,
    style: TextStyle(
      color: AppColors.isLight
          ? AppColors.textOnGlassSecondary
          : Colors.white.withValues(alpha: 0.5),
      fontSize: 12,
      fontWeight: FontWeight.w600,
    ),
  );
}
