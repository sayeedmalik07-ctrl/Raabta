import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raabta/services/ai/claude_ai_service.dart';

// ─── MODELS ─────────────────────────────────────────────

class ServiceLocation {
  final String id;
  final String name;
  final String category;
  final String emoji;
  final String area;
  final String address;

  const ServiceLocation({
    required this.id,
    required this.name,
    required this.category,
    required this.emoji,
    required this.area,
    required this.address,
  });
}

class WaitPrediction {
  final int estimatedMinutes;
  final String confidence;
  final String reason;
  final String bestTimeToVisit;
  final String worstTimeToVisit;
  final String currentStatus;
  final Color statusColor;
  final List<String> tips;

  const WaitPrediction({
    required this.estimatedMinutes,
    required this.confidence,
    required this.reason,
    required this.bestTimeToVisit,
    required this.worstTimeToVisit,
    required this.currentStatus,
    required this.statusColor,
    required this.tips,
  });
}

class CommunityReport {
  final String userId;
  final int waitMinutes;
  final String comment;
  final DateTime reportedAt;
  final String locationId;

  const CommunityReport({
    required this.userId,
    required this.waitMinutes,
    required this.comment,
    required this.reportedAt,
    required this.locationId,
  });
}

// ─── DATA: Qatar service locations ──────────────────────

const _qatarLocations = [
  ServiceLocation(
    id: 'metrash2_main',
    name: 'Metrash2 / MOI Services',
    category: 'Government',
    emoji: '🏛️',
    area: 'Multiple Locations',
    address: 'Ministry of Interior, Qatar',
  ),
  ServiceLocation(
    id: 'vehicle_inspection_ain_khaled',
    name: 'Vehicle Inspection — Ain Khaled',
    category: 'Government',
    emoji: '🚗',
    area: 'Ain Khaled',
    address: 'Ain Khaled, Doha',
  ),
  ServiceLocation(
    id: 'hmc_emergency',
    name: 'Hamad Medical City — ER',
    category: 'Medical',
    emoji: '🏥',
    area: 'Al Rayyan',
    address: 'Hamad Medical City, Al Rayyan Road',
  ),
  ServiceLocation(
    id: 'alkhor_hospital',
    name: 'Al Khor Hospital',
    category: 'Medical',
    emoji: '🏥',
    area: 'Al Khor',
    address: 'Al Khor Hospital, Al Khor',
  ),
  ServiceLocation(
    id: 'immigration_mesaimeer',
    name: 'Immigration — Mesaimeer',
    category: 'Government',
    emoji: '🛂',
    area: 'Mesaimeer',
    address: 'General Directorate of Passports, Mesaimeer',
  ),
  ServiceLocation(
    id: 'qatar_post_main',
    name: 'Qatar Post — Main Branch',
    category: 'Services',
    emoji: '📦',
    area: 'West Bay',
    address: 'Qatar Post HQ, West Bay',
  ),
  ServiceLocation(
    id: 'ooredoo_showroom',
    name: 'Ooredoo Showroom',
    category: 'Telecom',
    emoji: '📱',
    area: 'Multiple',
    address: 'Various locations across Qatar',
  ),
  ServiceLocation(
    id: 'city_center_doha',
    name: 'City Center Doha',
    category: 'Retail',
    emoji: '🛍️',
    area: 'Al Dafna',
    address: 'City Center, Al Dafna, Doha',
  ),
  ServiceLocation(
    id: 'carrefour_landmark',
    name: 'Carrefour — Landmark Mall',
    category: 'Retail',
    emoji: '🛒',
    area: 'Al Mansoura',
    address: 'Landmark Mall, Al Mansoura',
  ),
  ServiceLocation(
    id: 'lulu_hypermarket_alkhor',
    name: 'LuLu Hypermarket — Al Khor',
    category: 'Retail',
    emoji: '🛒',
    area: 'Al Khor',
    address: 'LuLu Hypermarket, Al Khor',
  ),
];

// ─── SCREEN ─────────────────────────────────────────────

class QueueAvoidanceScreen extends ConsumerStatefulWidget {
  const QueueAvoidanceScreen({super.key});

  @override
  ConsumerState<QueueAvoidanceScreen> createState() =>
      _QueueAvoidanceScreenState();
}

class _QueueAvoidanceScreenState extends ConsumerState<QueueAvoidanceScreen> {
  String _selectedCategory = 'All';
  ServiceLocation? _selectedLocation;
  WaitPrediction? _prediction;
  bool _isLoading = false;
  bool _isReporting = false;
  String? _error;
  int _reportMinutes = 15;
  final _reportCommentController = TextEditingController();

  final _categories = [
    'All',
    'Government',
    'Medical',
    'Services',
    'Telecom',
    'Retail',
  ];

  List<ServiceLocation> get _filteredLocations {
    if (_selectedCategory == 'All') return _qatarLocations;
    return _qatarLocations
        .where((l) => l.category == _selectedCategory)
        .toList();
  }

  @override
  void dispose() {
    _reportCommentController.dispose();
    super.dispose();
  }

  Future<void> _getPrediction(ServiceLocation location) async {
    setState(() {
      _selectedLocation = location;
      _isLoading = true;
      _prediction = null;
      _error = null;
    });

    try {
      final now = DateTime.now();
      const dayNames = [
        '',
        'Monday',
        'Tuesday',
        'Wednesday',
        'Thursday',
        'Friday',
        'Saturday',
        'Sunday',
      ];
      final day = dayNames[now.weekday];
      final hour = now.hour;
      final month = now.month;

      final prompt = '''
You are a Qatar daily life expert who knows wait time patterns at 
government services, hospitals, and commercial locations.

Predict the current wait time at: ${location.name}
Location: ${location.area}, Qatar
Category: ${location.category}
Current time: $hour:00 on $day, month $month

Consider Qatar-specific patterns:
- Government offices: very busy Sun-Thu 9AM-12PM, quiet after 2PM
- Hospitals: ER busiest Thu nights, Fri mornings (weekend injuries)
- Vehicle inspection: always busy 7AM-9AM, quiet after 2PM
- Ramadan: government hours shift, everything moves later
- Eid periods: most government services closed or skeleton staff
- Friday prayer time 12-2PM: most commercial services very quiet
- Qatar summer: people prefer indoor services, malls busier

Respond ONLY with valid JSON:
{
  "estimatedMinutes": <integer wait time in minutes>,
  "confidence": "<high|medium|low>",
  "currentStatus": "<Quiet|Moderate|Busy|Very Busy|Closed>",
  "statusColorHex": "<#2DC653|#7BC67E|#FFB627|#FF6B35|#E63946>",
  "reason": "<one sentence why it is busy or quiet right now>",
  "bestTimeToVisit": "<specific time window e.g. After 2PM weekdays>",
  "worstTimeToVisit": "<specific time to avoid>",
  "tips": [
    "<Qatar-specific tip 1 for this location>",
    "<Qatar-specific tip 2>",
    "<Qatar-specific tip 3>"
  ]
}
''';

      final claudeService = ref.read(claudeAIServiceProvider);
      final rawResponse = await claudeService.sendMessage(
        prompt,
        requestType: 'queue_avoidance',
      );

      final clean = rawResponse
          .replaceAll('```json', '')
          .replaceAll('```', '')
          .trim();

      final start = clean.indexOf('{');
      final end = clean.lastIndexOf('}');
      if (start == -1 || end == -1) {
        throw const FormatException('Invalid AI response');
      }

      final json =
          jsonDecode(clean.substring(start, end + 1)) as Map<String, dynamic>;
      final hex = (json['statusColorHex'] as String? ?? '#FFB627')
          .replaceAll('#', '');

      if (!mounted) return;
      setState(() {
        _prediction = WaitPrediction(
          estimatedMinutes: (json['estimatedMinutes'] as num?)?.toInt() ?? 20,
          confidence: json['confidence'] as String? ?? 'medium',
          reason: json['reason'] as String? ?? '',
          bestTimeToVisit: json['bestTimeToVisit'] as String? ?? '',
          worstTimeToVisit: json['worstTimeToVisit'] as String? ?? '',
          currentStatus: json['currentStatus'] as String? ?? 'Moderate',
          statusColor: Color(int.parse('FF$hex', radix: 16)),
          tips: (json['tips'] as List? ?? [])
              .map((t) => t.toString())
              .toList(),
        );
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _error = 'Could not get prediction. Check connection.';
      });
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _submitReport(BuildContext sheetContext) async {
    if (_selectedLocation == null) return;
    setState(() => _isReporting = true);
    try {
      await FirebaseFirestore.instance.collection('queue_reports').add({
        'locationId': _selectedLocation!.id,
        'locationName': _selectedLocation!.name,
        'waitMinutes': _reportMinutes,
        'comment': _reportCommentController.text.trim(),
        'reportedAt': FieldValue.serverTimestamp(),
        'dayOfWeek': DateTime.now().weekday,
        'hourOfDay': DateTime.now().hour,
      });

      _reportCommentController.clear();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              '✅ Report submitted! Thank you for helping the community.',
            ),
            backgroundColor: Color(0xFF2DC653),
            behavior: SnackBarBehavior.floating,
          ),
        );
        if (sheetContext.mounted) Navigator.pop(sheetContext);
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not submit report. Try again.'),
            backgroundColor: Color(0xFFE63946),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isReporting = false);
    }
  }

  void _showReportSheet() {
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
                '📍 Report Live Wait Time',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 17,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _selectedLocation?.name ?? '',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.45),
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Current wait time: $_reportMinutes minutes',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
              SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  activeTrackColor: const Color(0xFFFFB627),
                  thumbColor: const Color(0xFFFFB627),
                  inactiveTrackColor: Colors.white12,
                  trackHeight: 3,
                ),
                child: Slider(
                  value: _reportMinutes.toDouble(),
                  min: 0,
                  max: 120,
                  divisions: 24,
                  onChanged: (v) => setSheet(() => _reportMinutes = v.round()),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: ['0', '30', '60', '90', '120']
                    .map(
                      (t) => Text(
                        '${t}m',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.3),
                          fontSize: 10,
                        ),
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _reportCommentController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText:
                      'Optional: add a note (e.g. Very crowded, system down)',
                  hintStyle: TextStyle(
                    color: Colors.white.withValues(alpha: 0.25),
                    fontSize: 12,
                  ),
                  fillColor: Colors.white.withValues(alpha: 0.06),
                  filled: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.all(12),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed:
                      _isReporting ? null : () => _submitReport(ctx),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2DC653),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    _isReporting ? 'Submitting...' : 'Submit Report',
                    style: const TextStyle(
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
          'Queue Avoidance',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w800,
            fontSize: 18,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          if (_selectedLocation != null && _prediction != null)
            TextButton.icon(
              onPressed: _showReportSheet,
              icon: const Icon(
                Icons.add_location_alt_rounded,
                color: Color(0xFFFFB627),
                size: 16,
              ),
              label: const Text(
                'Report',
                style: TextStyle(
                  color: Color(0xFFFFB627),
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
            ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          Container(
            height: 40,
            margin: const EdgeInsets.fromLTRB(16, 12, 0, 0),
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _categories.length,
              separatorBuilder: (context, _) => const SizedBox(width: 8),
              itemBuilder: (_, i) {
                final cat = _categories[i];
                final selected = _selectedCategory == cat;
                return GestureDetector(
                  onTap: () => setState(() => _selectedCategory = cat),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: selected
                          ? const Color(0xFF6C3FC5)
                          : const Color(0xFF6C3FC5).withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: const Color(0xFF6C3FC5).withValues(
                          alpha: selected ? 1 : 0.25,
                        ),
                      ),
                    ),
                    child: Text(
                      cat,
                      style: TextStyle(
                        color: selected
                            ? Colors.white
                            : const Color(0xFF6C3FC5),
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          if (_error != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Text(
                _error!,
                style: const TextStyle(color: Color(0xFFE63946), fontSize: 13),
              ),
            ),
          const SizedBox(height: 12),
          Expanded(
            child: _isLoading
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(
                          color: Color(0xFF6C3FC5),
                          strokeWidth: 2.5,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Predicting wait times...',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  )
                : _prediction != null
                    ? _buildPredictionView()
                    : _buildLocationList(),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationList() {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
      itemCount: _filteredLocations.length,
      itemBuilder: (_, i) {
        final loc = _filteredLocations[i];
        return GestureDetector(
          onTap: () => _getPrediction(loc),
          child: Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.04),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.08),
              ),
            ),
            child: Row(
              children: [
                Text(loc.emoji, style: const TextStyle(fontSize: 26)),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        loc.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        '${loc.category}  •  ${loc.area}',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.4),
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: Colors.white24,
                  size: 20,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPredictionView() {
    final pred = _prediction!;
    final loc = _selectedLocation!;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () => setState(() {
              _selectedLocation = null;
              _prediction = null;
              _error = null;
            }),
            child: const Row(
              children: [
                Icon(
                  Icons.arrow_back_ios_rounded,
                  color: Color(0xFF00B4D8),
                  size: 14,
                ),
                SizedBox(width: 4),
                Text(
                  'Back to locations',
                  style: TextStyle(
                    color: Color(0xFF00B4D8),
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Text(loc.emoji, style: const TextStyle(fontSize: 32)),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      loc.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      loc.address,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.4),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: pred.statusColor.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: pred.statusColor.withValues(alpha: 0.3),
              ),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '~${pred.estimatedMinutes}',
                      style: TextStyle(
                        color: pred.statusColor,
                        fontSize: 56,
                        fontWeight: FontWeight.w900,
                        height: 1,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'min',
                          style: TextStyle(
                            color: pred.statusColor,
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          'wait',
                          style: TextStyle(
                            color: pred.statusColor.withValues(alpha: 0.6),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: pred.statusColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    pred.currentStatus,
                    style: TextStyle(
                      color: pred.statusColor,
                      fontWeight: FontWeight.w800,
                      fontSize: 14,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  pred.reason,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.55),
                    fontSize: 13,
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'AI confidence: ${pred.confidence}',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.25),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2DC653).withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFF2DC653).withValues(alpha: 0.2),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(
                            Icons.thumb_up_rounded,
                            color: Color(0xFF2DC653),
                            size: 14,
                          ),
                          SizedBox(width: 6),
                          Text(
                            'Best time',
                            style: TextStyle(
                              color: Color(0xFF2DC653),
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        pred.bestTimeToVisit,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE63946).withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFFE63946).withValues(alpha: 0.2),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(
                            Icons.warning_amber_rounded,
                            color: Color(0xFFE63946),
                            size: 14,
                          ),
                          SizedBox(width: 6),
                          Text(
                            'Avoid',
                            style: TextStyle(
                              color: Color(0xFFE63946),
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        pred.worstTimeToVisit,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          if (pred.tips.isNotEmpty) ...[
            const SizedBox(height: 20),
            const Text(
              '💡  Smart Tips',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 10),
            ...pred.tips.map(
              (tip) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '•  ',
                      style: TextStyle(
                        color: Color(0xFFFFB627),
                        fontSize: 14,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        tip,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.6),
                          fontSize: 13,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '👥  Community Reports',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 15,
                ),
              ),
              GestureDetector(
                onTap: _showReportSheet,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFB627).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: const Color(0xFFFFB627).withValues(alpha: 0.3),
                    ),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.add, color: Color(0xFFFFB627), size: 14),
                      SizedBox(width: 4),
                      Text(
                        'Report',
                        style: TextStyle(
                          color: Color(0xFFFFB627),
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: FirebaseFirestore.instance
                .collection('queue_reports')
                .where('locationId', isEqualTo: _selectedLocation!.id)
                .orderBy('reportedAt', descending: true)
                .limit(5)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.03),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Community reports unavailable.\n'
                    'Create the Firestore index if prompted in console.',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.35),
                      fontSize: 12,
                      height: 1.4,
                    ),
                    textAlign: TextAlign.center,
                  ),
                );
              }

              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return Container(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.03),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.06),
                    ),
                  ),
                  child: Center(
                    child: Column(
                      children: [
                        const Text(
                          '📋',
                          style: TextStyle(fontSize: 28),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'No community reports yet',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.3),
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Be the first to report a wait time',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.2),
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              return Column(
                children: snapshot.data!.docs.map((doc) {
                  final data = doc.data();
                  final mins = data['waitMinutes'] as int? ?? 0;
                  final comment = data['comment'] as String? ?? '';
                  final ts = data['reportedAt'] as Timestamp?;
                  final time =
                      ts != null ? _timeAgo(ts.toDate()) : 'recently';

                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.04),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.07),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: const Color(0xFF6C3FC5).withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '$mins',
                                style: const TextStyle(
                                  color: Color(0xFF6C3FC5),
                                  fontWeight: FontWeight.w900,
                                  fontSize: 16,
                                  height: 1,
                                ),
                              ),
                              Text(
                                'min',
                                style: TextStyle(
                                  color: const Color(0xFF6C3FC5)
                                      .withValues(alpha: 0.7),
                                  fontSize: 9,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (comment.isNotEmpty)
                                Text(
                                  comment,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 13,
                                  ),
                                ),
                              Text(
                                'Reported $time',
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.3),
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              );
            },
          ),
          const SizedBox(height: 48),
        ],
      ),
    );
  }

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}
