import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raabta/models/visa_models.dart';
import 'package:raabta/providers/visa_providers.dart';
import 'package:raabta/screens/visahelp/visa_guide_screen.dart';

class DeadlineTrackerWidget extends ConsumerWidget {
  const DeadlineTrackerWidget({super.key});

  static const Color _surfaceColor = Color(0xFF0D1520);
  static const Color _subtitleColor = Color(0xFF8A9BB0);
  static const Color _cyanColor = Color(0xFF22D3EE);

  Color _urgencyColor(DeadlineUrgency urgency) {
    switch (urgency) {
      case DeadlineUrgency.red:
        return const Color(0xFFEF4444);
      case DeadlineUrgency.amber:
        return const Color(0xFFF59E0B);
      case DeadlineUrgency.green:
        return const Color(0xFF22C55E);
    }
  }

  Future<void> _showAddDialog(BuildContext context, WidgetRef ref) async {
    final typeController = TextEditingController();
    DateTime selectedDate = DateTime.now().add(const Duration(days: 90));
    String guideCategoryId = 'iqama_renewal';

    final saved = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            backgroundColor: _surfaceColor,
            title: const Text(
              'Add Document Deadline',
              style: TextStyle(color: Colors.white),
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: typeController,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      hintText: 'Document type (e.g. Iqama)',
                      hintStyle: TextStyle(color: _subtitleColor),
                    ),
                  ),
                  const SizedBox(height: 12),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      'Expiry: ${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
                      style: const TextStyle(color: Colors.white),
                    ),
                    trailing: const Icon(Icons.calendar_today, color: _cyanColor),
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: selectedDate,
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 3650)),
                      );
                      if (picked != null) {
                        setDialogState(() => selectedDate = picked);
                      }
                    },
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    initialValue: guideCategoryId,
                    dropdownColor: _surfaceColor,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      labelText: 'Renewal guide',
                      labelStyle: TextStyle(color: _subtitleColor),
                    ),
                    items: visaCategories
                        .map(
                          (c) => DropdownMenuItem(
                            value: c.id,
                            child: Text('${c.emoji} ${c.title}'),
                          ),
                        )
                        .toList(),
                    onChanged: (v) {
                      if (v != null) setDialogState(() => guideCategoryId = v);
                    },
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(ctx, true),
                style: FilledButton.styleFrom(backgroundColor: _cyanColor),
                child: const Text('Save', style: TextStyle(color: Colors.black)),
              ),
            ],
          );
        },
      ),
    );

    if (saved != true || typeController.text.trim().isEmpty) return;

    await ref.read(documentDeadlinesProvider.notifier).addDeadline(
          documentType: typeController.text.trim(),
          expiryDate: selectedDate,
          guideCategoryId: guideCategoryId,
        );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final deadlines = ref.watch(documentDeadlinesProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Expanded(
              child: Text(
                '⏰ Deadline Tracker',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            TextButton.icon(
              onPressed: () => _showAddDialog(context, ref),
              icon: const Icon(Icons.add, color: _cyanColor, size: 18),
              label: const Text('Add', style: TextStyle(color: _cyanColor)),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (deadlines.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: _surfaceColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Column(
              children: [
                Icon(Icons.event_busy, color: _subtitleColor, size: 40),
                SizedBox(height: 8),
                Text(
                  'No deadlines added yet',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                ),
                SizedBox(height: 4),
                Text(
                  'Add your Iqama, passport, and work permit expiry dates',
                  style: TextStyle(color: _subtitleColor, fontSize: 13),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          )
        else
          ...deadlines.map((deadline) {
            final color = _urgencyColor(deadline.urgency);
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Container(
                decoration: BoxDecoration(
                  color: _surfaceColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: color.withValues(alpha: 0.4)),
                ),
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      width: 4,
                      height: 48,
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            deadline.documentType,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            deadline.expiryLabel,
                            style: TextStyle(
                              color: color,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => ref
                          .read(documentDeadlinesProvider.notifier)
                          .removeDeadline(deadline.id),
                      icon: const Icon(Icons.delete_outline, color: _subtitleColor),
                    ),
                    OutlinedButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => VisaGuideScreen(
                              categoryId: deadline.guideCategoryId,
                            ),
                          ),
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: _cyanColor,
                        side: const BorderSide(color: _cyanColor),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 8,
                        ),
                      ),
                      child: const Text(
                        'How to renew',
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
      ],
    );
  }
}
