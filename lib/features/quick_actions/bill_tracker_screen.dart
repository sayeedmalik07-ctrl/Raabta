import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raabta/services/ai/claude_ai_service.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

// ─── MODELS ─────────────────────────────────────────────

class BillEntry {
  final String id;
  final String provider;
  final String category;
  final String emoji;
  final double amount;
  final DateTime dueDate;
  final bool isPaid;
  final String? accountNumber;
  final String? notes;
  final DateTime createdAt;

  const BillEntry({
    required this.id,
    required this.provider,
    required this.category,
    required this.emoji,
    required this.amount,
    required this.dueDate,
    required this.isPaid,
    this.accountNumber,
    this.notes,
    required this.createdAt,
  });

  int get daysUntilDue => dueDate.difference(DateTime.now()).inDays;
  bool get isOverdue => daysUntilDue < 0 && !isPaid;
  bool get isDueSoon => daysUntilDue >= 0 && daysUntilDue <= 5 && !isPaid;

  factory BillEntry.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    final dueTs = d['dueDate'] as Timestamp?;
    final createdTs = d['createdAt'] as Timestamp?;
    return BillEntry(
      id: doc.id,
      provider: d['provider'] as String? ?? '',
      category: d['category'] as String? ?? '',
      emoji: d['emoji'] as String? ?? '📄',
      amount: (d['amount'] as num?)?.toDouble() ?? 0,
      dueDate: dueTs?.toDate() ?? DateTime.now(),
      isPaid: d['isPaid'] as bool? ?? false,
      accountNumber: d['accountNumber'] as String?,
      notes: d['notes'] as String?,
      createdAt: createdTs?.toDate() ?? DateTime.now(),
    );
  }
}

// ─── PROVIDER QUICK-ADD DATA ─────────────────────────────

const _qatarProviders = [
  {
    'name': 'Kahramaa',
    'category': 'Electricity & Water',
    'emoji': '⚡',
    'url': 'https://www.km.qa/',
  },
  {
    'name': 'Ooredoo',
    'category': 'Telecom',
    'emoji': '📱',
    'url': 'https://www.ooredoo.qa/',
  },
  {
    'name': 'Vodafone Qatar',
    'category': 'Telecom',
    'emoji': '📡',
    'url': 'https://www.vodafone.qa/',
  },
  {
    'name': 'Qatar Cool',
    'category': 'District Cooling',
    'emoji': '❄️',
    'url': 'https://www.qatarcool.com/',
  },
  {
    'name': 'beIN',
    'category': 'Entertainment',
    'emoji': '📺',
    'url': 'https://www.bein.com/',
  },
  {
    'name': 'Qatar Gas',
    'category': 'Gas',
    'emoji': '🔥',
    'url': 'https://www.qatargas.com/',
  },
  {
    'name': 'Private Rent',
    'category': 'Housing',
    'emoji': '🏠',
    'url': '',
  },
  {
    'name': 'Other',
    'category': 'Other',
    'emoji': '📄',
    'url': '',
  },
];

// ─── SCREEN ─────────────────────────────────────────────

class BillTrackerScreen extends ConsumerStatefulWidget {
  const BillTrackerScreen({super.key});

  @override
  ConsumerState<BillTrackerScreen> createState() => _BillTrackerScreenState();
}

class _BillTrackerScreenState extends ConsumerState<BillTrackerScreen> {
  bool _isAnalyzing = false;
  String? _aiAnalysis;

  final _collection =
      FirebaseFirestore.instance.collection('bill_tracker');

  Future<void> _addBill({
    required String provider,
    required String category,
    required String emoji,
    required double amount,
    required DateTime dueDate,
    String? accountNumber,
    String? notes,
  }) async {
    await _collection.add({
      'provider': provider,
      'category': category,
      'emoji': emoji,
      'amount': amount,
      'dueDate': Timestamp.fromDate(dueDate),
      'isPaid': false,
      'accountNumber': accountNumber ?? '',
      'notes': notes ?? '',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> _markPaid(String id, bool paid) async {
    await _collection.doc(id).update({'isPaid': paid});
  }

  Future<void> _deleteBill(String id) async {
    await _collection.doc(id).delete();
  }

  Future<void> _analyzeWithAI(List<BillEntry> bills) async {
    if (bills.isEmpty) return;
    setState(() {
      _isAnalyzing = true;
      _aiAnalysis = null;
    });

    final billSummary = bills
        .map(
          (b) =>
              '${b.provider}: QAR ${b.amount.toStringAsFixed(2)} '
              '(due: ${b.dueDate.day}/${b.dueDate.month}, '
              '${b.isPaid ? "PAID" : "UNPAID"})',
        )
        .join('\n');

    final total =
        bills.where((b) => !b.isPaid).fold(0.0, (acc, b) => acc + b.amount);

    try {
      final claudeService = ref.read(claudeAIServiceProvider);
      final response = await claudeService.sendMessage(
        '''
You are a financial advisor helping expats manage bills in Qatar.

Here are the user's current bills:
$billSummary

Total unpaid: QAR ${total.toStringAsFixed(2)}

Provide brief practical advice in 3-4 sentences:
1. Is the total amount typical for Qatar? 
2. Any bills that seem unusually high?
3. One specific money-saving tip for Qatar utilities.
4. Priority order for which to pay first if budget is tight.

Keep it conversational and helpful. No lists, just natural paragraphs.
''',
        requestType: 'bill_tracker',
      );
      if (!mounted) return;
      setState(() => _aiAnalysis = response);
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _aiAnalysis = 'Connect to RAABTA backend for AI bill analysis.';
      });
    } finally {
      if (mounted) setState(() => _isAnalyzing = false);
    }
  }

  void _shareSummary(List<BillEntry> bills) {
    final unpaid = bills.where((b) => !b.isPaid).toList();
    final paid = bills.where((b) => b.isPaid).toList();
    final total = unpaid.fold(0.0, (s, b) => s + b.amount);

    final lines = unpaid
        .map(
          (b) =>
              '${b.emoji} ${b.provider}: QAR ${b.amount.toStringAsFixed(2)}'
              ' (due ${b.dueDate.day}/${b.dueDate.month})',
        )
        .join('\n');

    Share.share(
      '💳 My Qatar Bills — RAABTA Tracker\n'
      '────────────────────\n'
      '$lines\n'
      '────────────────────\n'
      'Total outstanding: QAR ${total.toStringAsFixed(2)}\n'
      'Paid this month: ${paid.length} bills\n\n'
      'Track your Qatar bills with RAABTA • raabta.app',
    );
  }

  void _showAddBillSheet() {
    String selectedProvider = _qatarProviders[0]['name']!;
    String selectedCategory = _qatarProviders[0]['category']!;
    String selectedEmoji = _qatarProviders[0]['emoji']!;
    final amountCtrl = TextEditingController();
    final accountCtrl = TextEditingController();
    final notesCtrl = TextEditingController();
    DateTime dueDate = DateTime.now().add(const Duration(days: 7));

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A1035),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheet) => Padding(
          padding: EdgeInsets.fromLTRB(
            20,
            20,
            20,
            MediaQuery.of(ctx).viewInsets.bottom + 32,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Add Bill',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Provider',
                  style: TextStyle(
                    color: Colors.white54,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: selectedProvider,
                      isExpanded: true,
                      dropdownColor: const Color(0xFF1A1035),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                      ),
                      items: _qatarProviders
                          .map(
                            (p) => DropdownMenuItem(
                              value: p['name'],
                              child: Text(
                                '${p['emoji']} ${p['name']}',
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: (v) {
                        if (v == null) return;
                        final p = _qatarProviders.firstWhere(
                          (p) => p['name'] == v,
                        );
                        setSheet(() {
                          selectedProvider = v;
                          selectedCategory = p['category']!;
                          selectedEmoji = p['emoji']!;
                        });
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                const Text(
                  'Amount (QAR)',
                  style: TextStyle(
                    color: Colors.white54,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: amountCtrl,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: '0.00',
                    hintStyle: TextStyle(
                      color: Colors.white.withValues(alpha: 0.25),
                    ),
                    prefixText: 'QAR  ',
                    prefixStyle: TextStyle(
                      color: Colors.white.withValues(alpha: 0.4),
                    ),
                    fillColor: Colors.white.withValues(alpha: 0.06),
                    filled: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: Color(0xFFFFB627),
                        width: 1.5,
                      ),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 13,
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                const Text(
                  'Due Date',
                  style: TextStyle(
                    color: Colors.white54,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                GestureDetector(
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: ctx,
                      initialDate: dueDate,
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(
                        const Duration(days: 365),
                      ),
                      builder: (ctx, child) => Theme(
                        data: ThemeData.dark().copyWith(
                          colorScheme: const ColorScheme.dark(
                            primary: Color(0xFF6C3FC5),
                          ),
                        ),
                        child: child!,
                      ),
                    );
                    if (picked != null) {
                      setSheet(() => dueDate = picked);
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 13,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.06),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.calendar_today_rounded,
                          color: Color(0xFF6C3FC5),
                          size: 16,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          '${dueDate.day}/${dueDate.month}/${dueDate.year}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: accountCtrl,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Account/Contract number (optional)',
                    hintStyle: TextStyle(
                      color: Colors.white.withValues(alpha: 0.25),
                      fontSize: 13,
                    ),
                    fillColor: Colors.white.withValues(alpha: 0.06),
                    filled: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 13,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      final amount = double.tryParse(amountCtrl.text);
                      if (amount == null || amount <= 0) return;
                      await _addBill(
                        provider: selectedProvider,
                        category: selectedCategory,
                        emoji: selectedEmoji,
                        amount: amount,
                        dueDate: dueDate,
                        accountNumber: accountCtrl.text.trim(),
                        notes: notesCtrl.text.trim(),
                      );
                      if (ctx.mounted) Navigator.pop(ctx);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6C3FC5),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Add Bill',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0826),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D0826),
        elevation: 0,
        title: const Text(
          'Bill Tracker',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w800,
            fontSize: 18,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            onPressed: _showAddBillSheet,
            icon: const Icon(
              Icons.add_circle_outline,
              color: Color(0xFFFFB627),
            ),
            tooltip: 'Add Bill',
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: _collection.orderBy('dueDate', descending: false).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'Could not load bills.\n${snapshot.error}',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.5),
                    fontSize: 13,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF6C3FC5),
              ),
            );
          }

          final bills =
              snapshot.data!.docs.map(BillEntry.fromFirestore).toList();

          final unpaid = bills.where((b) => !b.isPaid).toList();
          final paid = bills.where((b) => b.isPaid).toList();
          final overdue = bills.where((b) => b.isOverdue).toList();
          final dueSoon = bills.where((b) => b.isDueSoon).toList();
          final totalUnpaid = unpaid.fold(0.0, (s, b) => s + b.amount);

          if (bills.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      '💳',
                      style: TextStyle(fontSize: 52),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'No bills tracked yet',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Add your Qatar bills to track due dates,\n'
                      'get AI analysis, and never miss a payment.',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.45),
                        fontSize: 13,
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 28),
                    ElevatedButton.icon(
                      onPressed: _showAddBillSheet,
                      icon: const Icon(
                        Icons.add,
                        color: Colors.white,
                        size: 18,
                      ),
                      label: const Text(
                        'Add Your First Bill',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6C3FC5),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 13,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _StatBox(
                      label: 'Outstanding',
                      value: 'QAR ${totalUnpaid.toStringAsFixed(0)}',
                      color: totalUnpaid > 0
                          ? const Color(0xFFE63946)
                          : const Color(0xFF2DC653),
                      large: true,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        children: [
                          _StatBox(
                            label: 'Overdue',
                            value: '${overdue.length}',
                            color: overdue.isNotEmpty
                                ? const Color(0xFFE63946)
                                : const Color(0xFF2DC653),
                          ),
                          const SizedBox(height: 10),
                          _StatBox(
                            label: 'Due Soon',
                            value: '${dueSoon.length}',
                            color: dueSoon.isNotEmpty
                                ? const Color(0xFFFFB627)
                                : const Color(0xFF2DC653),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed:
                            _isAnalyzing ? null : () => _analyzeWithAI(bills),
                        icon: _isAnalyzing
                            ? const SizedBox(
                                width: 14,
                                height: 14,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(
                                Icons.auto_awesome_rounded,
                                color: Colors.white,
                                size: 16,
                              ),
                        label: Text(
                          _isAnalyzing ? 'Analyzing...' : 'AI Analysis',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF6C3FC5),
                          padding: const EdgeInsets.symmetric(vertical: 11),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _shareSummary(bills),
                        icon: const Icon(
                          Icons.share_rounded,
                          color: Color(0xFF25D366),
                          size: 16,
                        ),
                        label: const Text(
                          'Share',
                          style: TextStyle(
                            color: Color(0xFF25D366),
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 11),
                          side: const BorderSide(
                            color: Color(0xFF25D366),
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                if (_aiAnalysis != null) ...[
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFF6C3FC5).withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xFF6C3FC5).withValues(alpha: 0.25),
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('🤖', style: TextStyle(fontSize: 16)),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            _aiAnalysis!,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.7),
                              fontSize: 13,
                              height: 1.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                if (overdue.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  const _SectionLabel('🔴  Overdue', Color(0xFFE63946)),
                  const SizedBox(height: 8),
                  ...overdue.map(
                    (b) => _BillCard(
                      bill: b,
                      onMarkPaid: () => _markPaid(b.id, !b.isPaid),
                      onDelete: () => _deleteBill(b.id),
                    ),
                  ),
                ],
                if (dueSoon.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  const _SectionLabel('🟡  Due Soon', Color(0xFFFFB627)),
                  const SizedBox(height: 8),
                  ...dueSoon.map(
                    (b) => _BillCard(
                      bill: b,
                      onMarkPaid: () => _markPaid(b.id, !b.isPaid),
                      onDelete: () => _deleteBill(b.id),
                    ),
                  ),
                ],
                if (unpaid
                    .where((b) => !b.isOverdue && !b.isDueSoon)
                    .isNotEmpty) ...[
                  const SizedBox(height: 20),
                  const _SectionLabel('📅  Upcoming', Colors.white54),
                  const SizedBox(height: 8),
                  ...unpaid
                      .where((b) => !b.isOverdue && !b.isDueSoon)
                      .map(
                        (b) => _BillCard(
                          bill: b,
                          onMarkPaid: () => _markPaid(b.id, !b.isPaid),
                          onDelete: () => _deleteBill(b.id),
                        ),
                      ),
                ],
                if (paid.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  const _SectionLabel('✅  Paid', Color(0xFF2DC653)),
                  const SizedBox(height: 8),
                  ...paid.map(
                    (b) => _BillCard(
                      bill: b,
                      onMarkPaid: () => _markPaid(b.id, !b.isPaid),
                      onDelete: () => _deleteBill(b.id),
                      dimmed: true,
                    ),
                  ),
                ],
                const SizedBox(height: 24),
                const Text(
                  '🔗  Pay Directly',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _qatarProviders
                      .where((p) => p['url']!.isNotEmpty)
                      .map(
                        (p) => GestureDetector(
                          onTap: () async {
                            final uri = Uri.parse(p['url']!);
                            if (await canLaunchUrl(uri)) {
                              await launchUrl(
                                uri,
                                mode: LaunchMode.externalApplication,
                              );
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.05),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.1),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  p['emoji']!,
                                  style: const TextStyle(fontSize: 14),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  p['name']!,
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Icon(
                                  Icons.open_in_new_rounded,
                                  color: Colors.white.withValues(alpha: 0.3),
                                  size: 11,
                                ),
                              ],
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
                const SizedBox(height: 48),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ─── BILL CARD ───────────────────────────────────────────

class _BillCard extends StatelessWidget {
  final BillEntry bill;
  final VoidCallback onMarkPaid;
  final VoidCallback onDelete;
  final bool dimmed;

  const _BillCard({
    required this.bill,
    required this.onMarkPaid,
    required this.onDelete,
    this.dimmed = false,
  });

  Color get _statusColor {
    if (bill.isPaid) return const Color(0xFF2DC653);
    if (bill.isOverdue) return const Color(0xFFE63946);
    if (bill.isDueSoon) return const Color(0xFFFFB627);
    return Colors.white24;
  }

  String get _dueLabel {
    if (bill.isPaid) return 'Paid';
    if (bill.isOverdue) return '${bill.daysUntilDue.abs()}d overdue';
    if (bill.daysUntilDue == 0) return 'Due today';
    if (bill.daysUntilDue == 1) return 'Due tomorrow';
    return 'Due in ${bill.daysUntilDue}d';
  }

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(bill.id),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: const Color(0xFFE63946).withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(14),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(
          Icons.delete_outline,
          color: Color(0xFFE63946),
        ),
      ),
      onDismissed: (_) => onDelete(),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: dimmed
              ? Colors.white.withValues(alpha: 0.02)
              : Colors.white.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: _statusColor.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            Text(
              bill.emoji,
              style: TextStyle(
                fontSize: 26,
                color: dimmed ? Colors.white.withValues(alpha: 0.4) : null,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    bill.provider,
                    style: TextStyle(
                      color: dimmed
                          ? Colors.white.withValues(alpha: 0.4)
                          : Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      decoration:
                          bill.isPaid ? TextDecoration.lineThrough : null,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: _statusColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          _dueLabel,
                          style: TextStyle(
                            color: _statusColor,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      if (bill.accountNumber?.isNotEmpty == true) ...[
                        const SizedBox(width: 8),
                        Text(
                          'Acc: ${bill.accountNumber}',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.25),
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'QAR ${bill.amount.toStringAsFixed(2)}',
                  style: TextStyle(
                    color: dimmed
                        ? Colors.white.withValues(alpha: 0.3)
                        : Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                    decoration:
                        bill.isPaid ? TextDecoration.lineThrough : null,
                  ),
                ),
                const SizedBox(height: 6),
                GestureDetector(
                  onTap: onMarkPaid,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: bill.isPaid
                          ? const Color(0xFF2DC653).withValues(alpha: 0.1)
                          : Colors.white.withValues(alpha: 0.06),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: bill.isPaid
                            ? const Color(0xFF2DC653).withValues(alpha: 0.3)
                            : Colors.white.withValues(alpha: 0.12),
                      ),
                    ),
                    child: Text(
                      bill.isPaid ? '✓ Paid' : 'Mark Paid',
                      style: TextStyle(
                        color: bill.isPaid
                            ? const Color(0xFF2DC653)
                            : Colors.white54,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─── HELPER WIDGETS ──────────────────────────────────────

class _StatBox extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final bool large;

  const _StatBox({
    required this.label,
    required this.value,
    required this.color,
    this.large = false,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: large ? 2 : 1,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.4),
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                color: color,
                fontSize: large ? 20 : 18,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  final Color color;

  const _SectionLabel(this.text, this.color);

  @override
  Widget build(BuildContext context) => Text(
        text,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w800,
          fontSize: 14,
        ),
      );
}
