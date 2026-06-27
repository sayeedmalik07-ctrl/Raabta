import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raabta/services/ai/claude_ai_service.dart';
import 'package:url_launcher/url_launcher.dart';

// ─── MODELS ─────────────────────────────────────────────

class RouteOption {
  final String title;
  final String emoji;
  final String heatRisk;
  final Color heatColor;
  final String duration;
  final String description;
  final List<String> steps;
  final String bestTime;
  final String mapQuery;

  const RouteOption({
    required this.title,
    required this.emoji,
    required this.heatRisk,
    required this.heatColor,
    required this.duration,
    required this.description,
    required this.steps,
    required this.bestTime,
    required this.mapQuery,
  });
}

class ClimateAdvice {
  final String summary;
  final String heatAlert;
  final bool isPeakSummer;
  final List<RouteOption> options;
  final List<String> generalTips;

  const ClimateAdvice({
    required this.summary,
    required this.heatAlert,
    required this.isPeakSummer,
    required this.options,
    required this.generalTips,
  });
}

// ─── SCREEN ─────────────────────────────────────────────

class ClimateNavigatorScreen extends ConsumerStatefulWidget {
  const ClimateNavigatorScreen({super.key});

  @override
  ConsumerState<ClimateNavigatorScreen> createState() =>
      _ClimateNavigatorScreenState();
}

class _ClimateNavigatorScreenState extends ConsumerState<ClimateNavigatorScreen> {
  final _fromController = TextEditingController();
  final _toController = TextEditingController();
  bool _isLoading = false;
  ClimateAdvice? _advice;
  String? _error;

  bool get _isPeakSummer {
    final month = DateTime.now().month;
    return month >= 5 && month <= 9;
  }

  String get _currentHeatLabel {
    final month = DateTime.now().month;
    if (month >= 6 && month <= 8) return 'EXTREME HEAT';
    if (month >= 5 && month <= 9) return 'HIGH HEAT';
    if (month >= 10 && month <= 11) return 'WARM';
    return 'PLEASANT';
  }

  Color get _heatLabelColor {
    final month = DateTime.now().month;
    if (month >= 6 && month <= 8) return const Color(0xFFE63946);
    if (month >= 5 && month <= 9) return const Color(0xFFFF6B35);
    if (month >= 10 && month <= 11) return const Color(0xFFFFB627);
    return const Color(0xFF2DC653);
  }

  final _popularFrom = [
    'Al Khor',
    'Lusail',
    'West Bay',
    'Al Sadd',
    'Industrial Area',
    'Wakra',
  ];

  final _popularTo = [
    'Hamad Airport',
    'City Center Mall',
    'Souq Waqif',
    'The Pearl',
    'QatarEnergy HQ',
    'Hamad Medical City',
    'Education City',
    'Villagio Mall',
  ];

  @override
  void dispose() {
    _fromController.dispose();
    _toController.dispose();
    super.dispose();
  }

  Future<void> _getRouteAdvice() async {
    final from = _fromController.text.trim();
    final to = _toController.text.trim();

    if (from.isEmpty || to.isEmpty) {
      setState(() {
        _error = 'Please enter both your starting point and destination.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _advice = null;
      _error = null;
    });

    try {
      final now = DateTime.now();
      final month = now.month;
      final hour = now.hour;
      const monthNames = [
        '',
        'January',
        'February',
        'March',
        'April',
        'May',
        'June',
        'July',
        'August',
        'September',
        'October',
        'November',
        'December',
      ];

      final prompt = '''
You are a Qatar climate and navigation expert helping expats stay 
safe from extreme heat. Current month: ${monthNames[month]}, 
Current time: $hour:00.

Journey: FROM "$from" TO "$to" in Qatar.

Peak summer in Qatar is May-September with temperatures 45-48°C.
Current conditions: ${_isPeakSummer ? 'PEAK SUMMER — dangerous heat' : 'NON-SUMMER — relatively comfortable'}.

Generate heat-aware route advice. Respond ONLY with valid JSON:
{
  "summary": "<2 sentences about the journey and heat context>",
  "heatAlert": "<one line current heat warning or all-clear>",
  "isPeakSummer": $_isPeakSummer,
  "options": [
    {
      "title": "<route name e.g. Metro + Indoor Route>",
      "emoji": "<single emoji>",
      "heatRisk": "<low|medium|high>",
      "heatRiskColor": "<#2DC653|#FFB627|#E63946>",
      "duration": "<estimated total time e.g. 35 mins>",
      "description": "<2 sentences why this is the smart choice>",
      "steps": [
        "<step 1>",
        "<step 2>",
        "<step 3>"
      ],
      "bestTime": "<ideal time of day to travel e.g. Before 9AM or After 6PM>",
      "mapQuery": "<Google Maps search query for this route>"
    }
  ],
  "generalTips": [
    "<Qatar-specific heat survival tip 1>",
    "<Qatar-specific heat survival tip 2>",
    "<Qatar-specific heat survival tip 3>"
  ]
}

Provide exactly 3 route options ranked from lowest to highest heat risk.
Include Qatar-specific knowledge:
- Qatar Metro (Red Line, Gold Line, Green Line) stations
- Major indoor malls as waypoints (City Center, Villaggio, Mall of Qatar)
- Park and Ride locations
- Shaded parking at specific Qatar landmarks
- Cooling centers (mosques, malls, metro stations)
- Karwa taxi and Uber availability
- Peak heat hours: 11AM-4PM — always warn about this window
- Best routes during Ramadan if applicable
''';

      final claudeService = ref.read(claudeAIServiceProvider);
      final rawResponse = await claudeService.sendMessage(
        prompt,
        requestType: 'climate_navigator',
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

      final options = (json['options'] as List? ?? []).map((raw) {
        final o = Map<String, dynamic>.from(raw as Map);
        final hex = (o['heatRiskColor'] as String? ?? '#FFB627')
            .replaceAll('#', '');
        return RouteOption(
          title: o['title'] as String? ?? 'Route',
          emoji: o['emoji'] as String? ?? '🗺️',
          heatRisk: o['heatRisk'] as String? ?? 'medium',
          heatColor: Color(int.parse('FF$hex', radix: 16)),
          duration: o['duration'] as String? ?? 'N/A',
          description: o['description'] as String? ?? '',
          steps: (o['steps'] as List? ?? []).map((s) => s.toString()).toList(),
          bestTime: o['bestTime'] as String? ?? 'Anytime',
          mapQuery: o['mapQuery'] as String? ?? '$from to $to Qatar',
        );
      }).toList();

      if (!mounted) return;
      setState(() {
        _advice = ClimateAdvice(
          summary: json['summary'] as String? ?? '',
          heatAlert: json['heatAlert'] as String? ?? '',
          isPeakSummer: _isPeakSummer,
          options: options,
          generalTips: (json['generalTips'] as List? ?? [])
              .map((t) => t.toString())
              .toList(),
        );
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _error = 'Could not get route advice. Check connection and try again.';
      });
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _openInMaps(String query) async {
    final googleUri = Uri.parse(
      'https://www.google.com/maps/dir/?api=1'
      '&destination=${Uri.encodeComponent(query)}'
      '&travelmode=transit',
    );
    final appleUri = Uri.parse(
      'https://maps.apple.com/?daddr=${Uri.encodeComponent(query)}',
    );

    if (await canLaunchUrl(googleUri)) {
      await launchUrl(googleUri, mode: LaunchMode.externalApplication);
    } else if (await canLaunchUrl(appleUri)) {
      await launchUrl(appleUri, mode: LaunchMode.externalApplication);
    }
  }

  void _reset() {
    setState(() {
      _advice = null;
      _error = null;
      _fromController.clear();
      _toController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0826),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D0826),
        elevation: 0,
        title: const Text(
          'Climate Navigator',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w800,
            fontSize: 18,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          if (_advice != null)
            TextButton(
              onPressed: _reset,
              child: const Text(
                'New Route',
                style: TextStyle(
                  color: Color(0xFF00B4D8),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _heatLabelColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: _heatLabelColor.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  Text(
                    _isPeakSummer ? '🌡️' : '🌤️',
                    style: const TextStyle(fontSize: 28),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _currentHeatLabel,
                          style: TextStyle(
                            color: _heatLabelColor,
                            fontWeight: FontWeight.w900,
                            fontSize: 14,
                            letterSpacing: 1,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          _isPeakSummer
                              ? 'Peak summer active. AI will prioritize '
                                  'indoor and shaded routes.'
                              : 'Weather is comfortable for outdoor routes.',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.55),
                            fontSize: 12,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const _FieldLabel('From'),
            const SizedBox(height: 6),
            _LocationField(
              controller: _fromController,
              hint: 'Your location (e.g. Al Khor, Lusail)',
              icon: Icons.my_location_rounded,
              iconColor: const Color(0xFF2DC653),
            ),
            const SizedBox(height: 8),
            _ChipRow(
              chips: _popularFrom,
              onTap: (v) => setState(() => _fromController.text = v),
            ),
            const SizedBox(height: 16),
            Center(
              child: GestureDetector(
                onTap: () {
                  final temp = _fromController.text;
                  _fromController.text = _toController.text;
                  _toController.text = temp;
                },
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: const Color(0xFF6C3FC5).withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFF6C3FC5).withValues(alpha: 0.3),
                    ),
                  ),
                  child: const Icon(
                    Icons.swap_vert_rounded,
                    color: Color(0xFF6C3FC5),
                    size: 18,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const _FieldLabel('To'),
            const SizedBox(height: 6),
            _LocationField(
              controller: _toController,
              hint: 'Destination (e.g. City Center Mall)',
              icon: Icons.location_on_rounded,
              iconColor: const Color(0xFFE63946),
            ),
            const SizedBox(height: 8),
            _ChipRow(
              chips: _popularTo,
              onTap: (v) => setState(() => _toController.text = v),
            ),
            if (_error != null) ...[
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFE63946).withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: const Color(0xFFE63946).withValues(alpha: 0.3),
                  ),
                ),
                child: Text(
                  _error!,
                  style: const TextStyle(
                    color: Color(0xFFE63946),
                    fontSize: 13,
                  ),
                ),
              ),
            ],
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isLoading ? null : _getRouteAdvice,
                icon: _isLoading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Icon(
                        Icons.air_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                label: Text(
                  _isLoading
                      ? 'Calculating heat-safe routes...'
                      : 'Get Heat-Safe Route',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _heatLabelColor,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  disabledBackgroundColor: _heatLabelColor.withValues(alpha: 0.4),
                ),
              ),
            ),
            if (_advice != null) ...[
              const SizedBox(height: 28),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.04),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.08),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.info_outline_rounded,
                          color: Color(0xFF00B4D8),
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _advice!.heatAlert,
                            style: const TextStyle(
                              color: Color(0xFF00B4D8),
                              fontWeight: FontWeight.w700,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _advice!.summary,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.65),
                        fontSize: 13,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                '🗺️  Route Options',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 12),
              ..._advice!.options.asMap().entries.map((entry) {
                final i = entry.key;
                final opt = entry.value;
                return _RouteCard(
                  option: opt,
                  rank: i + 1,
                  onOpenMaps: () => _openInMaps(opt.mapQuery),
                );
              }),
              if (_advice!.generalTips.isNotEmpty) ...[
                const SizedBox(height: 20),
                const Text(
                  '💡  Qatar Heat Survival Tips',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 10),
                ..._advice!.generalTips.map(
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
            ],
            const SizedBox(height: 48),
          ],
        ),
      ),
    );
  }
}

// ─── ROUTE CARD ─────────────────────────────────────────

class _RouteCard extends StatefulWidget {
  final RouteOption option;
  final int rank;
  final VoidCallback onOpenMaps;

  const _RouteCard({
    required this.option,
    required this.rank,
    required this.onOpenMaps,
  });

  @override
  State<_RouteCard> createState() => _RouteCardState();
}

class _RouteCardState extends State<_RouteCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final opt = widget.option;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: opt.heatColor.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        children: [
          GestureDetector(
            onTap: () => setState(() => _expanded = !_expanded),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: opt.heatColor.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '${widget.rank}',
                        style: TextStyle(
                          color: opt.heatColor,
                          fontWeight: FontWeight.w900,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    opt.emoji,
                    style: const TextStyle(fontSize: 22),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          opt.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Row(
                          children: [
                            Icon(
                              Icons.schedule_rounded,
                              color: Colors.white.withValues(alpha: 0.35),
                              size: 12,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              opt.duration,
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.45),
                                fontSize: 11,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 7,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: opt.heatColor.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                '${opt.heatRisk.toUpperCase()} HEAT',
                                style: TextStyle(
                                  color: opt.heatColor,
                                  fontSize: 9,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    _expanded
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                    color: Colors.white38,
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
          if (_expanded) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Divider(color: Colors.white10),
                  const SizedBox(height: 10),
                  Text(
                    opt.description,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.6),
                      fontSize: 13,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 14),
                  ...opt.steps.asMap().entries.map(
                    (e) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 20,
                            height: 20,
                            decoration: BoxDecoration(
                              color: const Color(0xFF6C3FC5).withValues(alpha: 0.2),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                '${e.key + 1}',
                                style: const TextStyle(
                                  color: Color(0xFF6C3FC5),
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              e.value,
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.7),
                                fontSize: 13,
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Icon(
                        Icons.wb_sunny_outlined,
                        color: Color(0xFFFFB627),
                        size: 14,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Best time: ${opt.bestTime}',
                        style: const TextStyle(
                          color: Color(0xFFFFB627),
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: widget.onOpenMaps,
                      icon: const Icon(
                        Icons.map_rounded,
                        color: Colors.white,
                        size: 16,
                      ),
                      label: const Text(
                        'Open in Google Maps',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6C3FC5),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ─── HELPER WIDGETS ──────────────────────────────────────

class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);

  @override
  Widget build(BuildContext context) => Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w700,
          fontSize: 14,
        ),
      );
}

class _LocationField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final Color iconColor;

  const _LocationField({
    required this.controller,
    required this.hint,
    required this.icon,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      style: const TextStyle(color: Colors.white, fontSize: 14),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(
          color: Colors.white.withValues(alpha: 0.25),
          fontSize: 13,
        ),
        prefixIcon: Icon(icon, color: iconColor, size: 18),
        fillColor: Colors.white.withValues(alpha: 0.05),
        filled: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: iconColor, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 14,
        ),
      ),
    );
  }
}

class _ChipRow extends StatelessWidget {
  final List<String> chips;
  final void Function(String) onTap;

  const _ChipRow({required this.chips, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 30,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: chips.length,
        separatorBuilder: (context, _) => const SizedBox(width: 6),
        itemBuilder: (_, i) => GestureDetector(
          onTap: () => onTap(chips[i]),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: const Color(0xFF6C3FC5).withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0xFF6C3FC5).withValues(alpha: 0.25),
              ),
            ),
            child: Text(
              chips[i],
              style: const TextStyle(
                color: Color(0xFF6C3FC5),
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
