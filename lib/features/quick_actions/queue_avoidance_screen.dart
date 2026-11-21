// ─────────────────────────────────────────────────────
// SETUP REQUIRED: Google Places API Key
// 1. Go to https://console.cloud.google.com
// 2. Create a project or select existing
// 3. Enable "Places API" and "Maps JavaScript API"
// 4. Create an API key under Credentials
// 5. Replace 'YOUR_GOOGLE_PLACES_API_KEY' below
// ─────────────────────────────────────────────────────

import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:raabta/core/constants/strings/common_strings.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/glass/glass_container.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/services/sharing/models/shareable_card_data.dart';
import 'package:raabta/services/sharing/widgets/share_card_sheet.dart';

import 'package:raabta/core/widgets/animated_background.dart';
import 'package:raabta/features/quick_actions/l10n/quick_actions_strings.dart';
import 'package:raabta/providers/visa_providers.dart';
import 'package:raabta/services/ai/claude_ai_service.dart';

// ─── MODELS ─────────────────────────────────────────────

class PlaceResult {
  const PlaceResult({
    required this.placeId,
    required this.name,
    required this.address,
    required this.category,
    required this.emoji,
    this.area = 'Qatar',
    this.types = const [],
  });

  final String placeId;
  final String name;
  final String address;
  final String category;
  final String emoji;
  final String area;
  final List<String> types;

  String get id => placeId;
}

class WaitPrediction {
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

  final int estimatedMinutes;
  final String confidence;
  final String reason;
  final String bestTimeToVisit;
  final String worstTimeToVisit;
  final String currentStatus;
  final Color statusColor;
  final List<String> tips;
}

// ─── GOOGLE PLACES HELPERS ──────────────────────────────

String _emojiForTypes(List<String> types) {
  if (types.any((t) => t.contains('hospital') || t.contains('doctor'))) {
    return '🏥';
  }
  if (types.any((t) =>
      t.contains('government') ||
      t.contains('embassy') ||
      t.contains('city_hall'))) {
    return '🏛️';
  }
  if (types.any((t) => t.contains('shopping') || t.contains('store'))) {
    return '🛍️';
  }
  if (types.any((t) => t.contains('restaurant') || t.contains('food'))) {
    return '🍽️';
  }
  if (types.any((t) => t.contains('bank') || t.contains('atm'))) {
    return '🏦';
  }
  if (types.any((t) => t.contains('gas_station'))) return '⛽';
  if (types.any((t) => t.contains('school') || t.contains('university'))) {
    return '🎓';
  }
  if (types.any((t) => t.contains('mosque'))) return '🕌';
  if (types.any((t) => t.contains('pharmacy'))) return '💊';
  if (types.any((t) => t.contains('post_office'))) return '📦';
  return '📍';
}

String _categoryForTypes(List<String> types) {
  if (types.any((t) => t.contains('hospital') || t.contains('doctor'))) {
    return 'Medical';
  }
  if (types.any((t) =>
      t.contains('government') ||
      t.contains('embassy') ||
      t.contains('local_government_office'))) {
    return 'Government';
  }
  if (types.any((t) => t.contains('shopping') || t.contains('store'))) {
    return 'Retail';
  }
  if (types.any((t) => t.contains('restaurant') || t.contains('food'))) {
    return 'Food';
  }
  if (types.any((t) => t.contains('bank') || t.contains('finance'))) {
    return 'Services';
  }
  if (types.any((t) => t.contains('telecom') || t.contains('electronics'))) {
    return 'Telecom';
  }
  return 'Place';
}

String _areaFromAddress(String address) {
  final parts = address.split(',').map((p) => p.trim()).toList();
  if (parts.length >= 2) {
    return parts[parts.length - 2];
  }
  return 'Qatar';
}

PlaceResult _placeFromPrediction(Map<String, dynamic> json) {
  final structured =
      json['structured_formatting'] as Map<String, dynamic>? ?? {};
  final name = structured['main_text'] as String? ??
      json['description'] as String? ??
      'Unknown place';
  final secondary = structured['secondary_text'] as String? ?? 'Qatar';
  final types =
      (json['types'] as List?)?.map((t) => t.toString()).toList() ?? [];
  return PlaceResult(
    placeId: json['place_id'] as String? ?? '',
    name: name,
    address: json['description'] as String? ?? secondary,
    category: _categoryForTypes(types),
    emoji: _emojiForTypes(types),
    area: _areaFromAddress(json['description'] as String? ?? secondary),
    types: types,
  );
}

// ─── SCREEN ─────────────────────────────────────────────

class QueueAvoidanceScreen extends ConsumerStatefulWidget {
  const QueueAvoidanceScreen({super.key});

  @override
  ConsumerState<QueueAvoidanceScreen> createState() =>
      _QueueAvoidanceScreenState();
}

class _QueueAvoidanceScreenState extends ConsumerState<QueueAvoidanceScreen> {
  static const _googleApiKey = String.fromEnvironment(
    'GOOGLE_PLACES_API_KEY',
    defaultValue: '',
  );

  static const _quickSearches = [
    ('🏥', 'Hospital'),
    ('🏛️', 'Government office'),
    ('🛂', 'Immigration'),
    ('📦', 'Qatar Post'),
    ('🛍️', 'Shopping mall'),
    ('🏦', 'Bank'),
    ('⛽', 'Petrol station'),
    ('🕌', 'Mosque'),
  ];

  final _searchController = TextEditingController();
  final _reportCommentController = TextEditingController();
  Timer? _searchDebounce;

  String _searchQuery = '';
  List<PlaceResult> _placeResults = [];
  PlaceResult? _selectedLocation;
  WaitPrediction? _prediction;

  bool _isSearchingPlaces = false;
  bool _isLoading = false;
  bool _isReporting = false;
  String? _error;
  String? _placesError;
  int _reportMinutes = 15;

  bool get _apiKeyConfigured =>
      _googleApiKey.isNotEmpty &&
      _googleApiKey != 'YOUR_GOOGLE_PLACES_API_KEY';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _reportCommentController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = _searchController.text.trim();
    if (query == _searchQuery) return;
    setState(() {
      _searchQuery = query;
      _placesError = null;
    });
    _searchDebounce?.cancel();
    if (query.length < 2) {
      setState(() {
        _placeResults = [];
        _isSearchingPlaces = false;
      });
      return;
    }
    _searchDebounce = Timer(const Duration(milliseconds: 400), () {
      _fetchPlaces(query);
    });
  }

  Future<void> _fetchPlaces(String query) async {
    if (!_apiKeyConfigured) {
      setState(() {
        _placesError =
            'Add your Google Places API key at the top of this file.';
        _placeResults = [];
        _isSearchingPlaces = false;
      });
      return;
    }

    setState(() {
      _isSearchingPlaces = true;
      _placesError = null;
    });

    try {
      final uri = Uri.https(
        'maps.googleapis.com',
        '/maps/api/place/autocomplete/json',
        {
          'input': query,
          'key': _googleApiKey,
          'components': 'country:qa',
          'language': 'en',
        },
      );

      final response = await http.get(uri).timeout(const Duration(seconds: 10));
      if (!mounted) return;

      if (response.statusCode != 200) {
        throw Exception('HTTP ${response.statusCode}');
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final status = data['status'] as String? ?? 'UNKNOWN';

      if (status != 'OK' && status != 'ZERO_RESULTS') {
        final msg = data['error_message'] as String? ?? status;
        throw Exception(msg);
      }

      final predictions = (data['predictions'] as List?) ?? [];
      setState(() {
        _placeResults = predictions
            .map((p) => _placeFromPrediction(p as Map<String, dynamic>))
            .where((p) => p.placeId.isNotEmpty)
            .toList();
        _isSearchingPlaces = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _placesError = 'Could not search places. Check API key & connection.';
        _placeResults = [];
        _isSearchingPlaces = false;
      });
    }
  }

  Future<PlaceResult> _enrichPlaceDetails(PlaceResult place) async {
    if (!_apiKeyConfigured) return place;

    try {
      final uri = Uri.https(
        'maps.googleapis.com',
        '/maps/api/place/details/json',
        {
          'place_id': place.placeId,
          'fields': 'place_id,name,formatted_address,types,vicinity',
          'key': _googleApiKey,
          'language': 'en',
        },
      );

      final response = await http.get(uri).timeout(const Duration(seconds: 10));
      if (response.statusCode != 200) return place;

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      if (data['status'] != 'OK') return place;

      final result = data['result'] as Map<String, dynamic>? ?? {};
      final types =
          (result['types'] as List?)?.map((t) => t.toString()).toList() ??
              place.types;
      final address =
          result['formatted_address'] as String? ?? place.address;
      final name = result['name'] as String? ?? place.name;

      return PlaceResult(
        placeId: place.placeId,
        name: name,
        address: address,
        category: _categoryForTypes(types),
        emoji: _emojiForTypes(types),
        area: result['vicinity'] as String? ?? _areaFromAddress(address),
        types: types,
      );
    } catch (_) {
      return place;
    }
  }

  Future<void> _quickSearch(String term) async {
    _searchController.text = term;
    _searchController.selection = TextSelection.fromPosition(
      TextPosition(offset: term.length),
    );
    setState(() => _searchQuery = term);
    await _fetchPlaces(term);
  }

  Future<void> _getPrediction(PlaceResult location) async {
    setState(() {
      _selectedLocation = location;
      _isLoading = true;
      _prediction = null;
      _error = null;
    });

    try {
      final enriched = await _enrichPlaceDetails(location);
      if (!mounted) return;
      setState(() => _selectedLocation = enriched);

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

Predict the current wait time at: ${enriched.name}
Full address: ${enriched.address}
Location area: ${enriched.area}, Qatar
Category: ${enriched.category}
Place types: ${enriched.types.join(', ')}
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
        'locationId': _selectedLocation!.placeId,
        'locationName': _selectedLocation!.name,
        'locationAddress': _selectedLocation!.address,
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
            backgroundColor: AppColors.successBright,
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
            backgroundColor: AppColors.errorBright,
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
      backgroundColor: AppColors.surfaceElevated,
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
                    color: AppColors.isLight
                        ? AppColors.textTertiary
                        : Colors.white24,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                '📍 Report Live Wait Time',
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
                _selectedLocation?.name ?? '',
                style: TextStyle(
                  color: AppColors.isLight
                      ? AppColors.textOnGlassMuted
                      : Colors.white.withValues(alpha: 0.45),
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Current wait time: $_reportMinutes minutes',
                style: TextStyle(
                  color: AppColors.isLight
                      ? AppColors.textPrimary
                      : Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
              SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  activeTrackColor: AppColors.accentGold,
                  thumbColor: AppColors.accentGold,
                  inactiveTrackColor: AppColors.isLight
                      ? AppColors.glassBorder
                      : Colors.white12,
                  trackHeight: 3,
                ),
                child: SizedBox(
                  width: double.infinity,
                  child: Slider(
                    value: _reportMinutes.toDouble(),
                    min: 0,
                    max: 120,
                    divisions: 24,
                    onChanged: (v) =>
                        setSheet(() => _reportMinutes = v.round()),
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: ['0', '30', '60', '90', '120']
                    .map(
                      (t) => Text(
                        '${t}m',
                        style: TextStyle(
                          color: AppColors.isLight
                              ? AppColors.textOnGlassMuted
                              : Colors.white.withValues(alpha: 0.3),
                          fontSize: 10,
                        ),
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _reportCommentController,
                style: TextStyle(
                  color: AppColors.isLight
                      ? AppColors.textPrimary
                      : Colors.white,
                ),
                decoration: InputDecoration(
                  hintText:
                      'Optional: add a note (e.g. Very crowded, system down)',
                  hintStyle: TextStyle(
                    color: AppColors.isLight
                        ? AppColors.textOnGlassMuted
                        : Colors.white.withValues(alpha: 0.25),
                    fontSize: 12,
                  ),
                  fillColor: AppColors.isLight
                      ? AppColors.glassBorder.withValues(alpha: 0.25)
                      : Colors.white.withValues(alpha: 0.06),
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
                  onPressed: _isReporting ? null : () => _submitReport(ctx),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.successBright,
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

  void _clearSearch() {
    _searchController.clear();
    setState(() {
      _searchQuery = '';
      _placeResults = [];
      _placesError = null;
      _isSearchingPlaces = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final locale = ref.watch(userLanguageProvider);
    return AnimatedAuroraBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          scrolledUnderElevation: 0,
          title: Text(
            QuickActionsStrings.t('tool_queue_title', locale),
            style: AppTypography.title.copyWith(color: AppColors.textPrimary),
          ),
          iconTheme: IconThemeData(color: AppColors.textPrimary),
          actions: [
            if (_selectedLocation != null && _prediction != null)
              TextButton.icon(
                onPressed: () {
                  final shareData = WaitTimeCardData(
                    locationName:         _selectedLocation!.name,
                    locationArea:         _selectedLocation!.address,
                    locationEmoji:        _selectedLocation!.emoji,
                    estimatedMinutes:     _prediction!.estimatedMinutes,
                    currentStatus:        _prediction!.currentStatus,
                    statusColor:          _prediction!.statusColor,
                    bestTimeToVisit:      _prediction!.bestTimeToVisit,
                    reportedAt:           'Just now',
                    communityReportCount: 0,
                    shareCaption:
                        '⏱ ${_selectedLocation!.name}\n'
                        'Current wait: ~${_prediction!.estimatedMinutes} min '
                        '(${_prediction!.currentStatus})\n\n'
                        'Best time: ${_prediction!.bestTimeToVisit}\n\n'
                        'Check wait times with RAABTA\n${CommonStrings.publicWebsiteHost}',
                  );
                  ShareCardSheet.show(context, shareData);
                },
                icon: const Icon(
                  Icons.share_rounded,
                  color: AppColors.accentGold,
                  size:  15,
                ),
                label: const Text(
                  'Share',
                  style: TextStyle(
                    color:      AppColors.accentGold,
                    fontWeight: FontWeight.w700,
                    fontSize:   13,
                  ),
                ),
              ),
            if (_selectedLocation != null && _prediction != null)
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: TextButton.icon(
                  onPressed: _showReportSheet,
                  icon: const Icon(
                    Icons.add_location_alt_rounded,
                    color: AppColors.accentGold,
                    size: 16,
                  ),
                  label: const Text(
                    'Report',
                    style: TextStyle(
                      color: AppColors.accentGold,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
          ],
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: TextField(
                controller: _searchController,
                style: TextStyle(
                  color: AppColors.isLight
                      ? AppColors.textPrimary
                      : Colors.white,
                  fontSize: 14,
                ),
                decoration: InputDecoration(
                  hintText: 'Search any place in Qatar — shop, hospital, office…',
                  hintStyle: TextStyle(
                    color: AppColors.isLight
                        ? AppColors.textOnGlassMuted
                        : Colors.white.withValues(alpha: 0.25),
                    fontSize: 13,
                  ),
                  prefixIcon: const Icon(
                    Icons.search_rounded,
                    color: AppColors.sharePurple,
                    size: 20,
                  ),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? GestureDetector(
                          onTap: _clearSearch,
                          child: Icon(
                            Icons.close_rounded,
                            color: AppColors.isLight
                                ? AppColors.textOnGlassMuted
                                : Colors.white38,
                            size: 18,
                          ),
                        )
                      : (_isSearchingPlaces
                          ? const Padding(
                              padding: EdgeInsets.all(12),
                              child: SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppColors.sharePurple,
                                ),
                              ),
                            )
                          : null),
                  fillColor: AppColors.isLight
                      ? AppColors.glassBorder.withValues(alpha: 0.25)
                      : Colors.white.withValues(alpha: 0.06),
                  filled: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: AppColors.sharePurple,
                      width: 1.5,
                    ),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 13,
                  ),
                ),
              ),
            ),
            if (!_apiKeyConfigured)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
                child: GlassContainer(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  borderRadius: 10,
                  glowColor: AppColors.amberGlow,
                  glowIntensity: 0.08,
                  backgroundColor: AppColors.amberGlow.withValues(alpha: 0.1),
                  child: const Text(
                    '⚠️ Add your Google Places API key in '
                    'queue_avoidance_screen.dart to enable live search.',
                    style: TextStyle(color: AppColors.accentGold, fontSize: 12),
                  ),
                ),
              ),
            const SizedBox(height: 10),
            SizedBox(
              height: 40,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _quickSearches.length,
                separatorBuilder: (_, _) => const SizedBox(width: 8),
                itemBuilder: (_, i) {
                  final item = _quickSearches[i];
                  return GestureDetector(
                    onTap: () => _quickSearch('${item.$2} Qatar'),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.sharePurple.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: AppColors.sharePurple.withValues(alpha: 0.25),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(item.$1, style: const TextStyle(fontSize: 14)),
                          const SizedBox(width: 6),
                          Text(
                            item.$2,
                            style: const TextStyle(
                              color: AppColors.sharePurple,
                              fontWeight: FontWeight.w700,
                              fontSize: 11,
                            ),
                          ),
                        ],
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
                  style: const TextStyle(color: AppColors.errorBright, fontSize: 13),
                ),
              ),
            if (_placesError != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: Text(
                  _placesError!,
                  style: const TextStyle(color: AppColors.errorBright, fontSize: 13),
                ),
              ),
            const SizedBox(height: 12),
            Expanded(
              child: _isLoading
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const CircularProgressIndicator(
                            color: AppColors.sharePurple,
                            strokeWidth: 2.5,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Predicting wait times...',
                            style: TextStyle(
                              color: AppColors.isLight
                                  ? AppColors.textOnGlassSecondary
                                  : Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    )
                  : _prediction != null
                      ? _buildPredictionView()
                      : _buildPlacesList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlacesList() {
    if (_searchQuery.length < 2) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.place_rounded,
                color: AppColors.isLight
                    ? AppColors.textTertiary
                    : Colors.white24,
                size: 52,
              ),
              const SizedBox(height: 16),
              Text(
                'Search any location in Qatar',
                style: TextStyle(
                  color: AppColors.isLight
                      ? AppColors.textPrimary
                      : Colors.white.withValues(alpha: 0.7),
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Type at least 2 characters — or tap a quick search chip above',
                style: TextStyle(
                  color: AppColors.isLight
                      ? AppColors.textOnGlassMuted
                      : Colors.white.withValues(alpha: 0.35),
                  fontSize: 13,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    if (_isSearchingPlaces) {
      return const Center(
        child: CircularProgressIndicator(
          color: AppColors.sharePurple,
          strokeWidth: 2.5,
        ),
      );
    }

    if (_placeResults.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.search_off_rounded,
                color: AppColors.isLight
                    ? AppColors.textTertiary
                    : Colors.white24,
                size: 48,
              ),
              const SizedBox(height: 14),
              Text(
                'No places found for "$_searchQuery"',
                style: TextStyle(
                  color: AppColors.isLight
                      ? AppColors.textOnGlassMuted
                      : Colors.white.withValues(alpha: 0.4),
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: _clearSearch,
                child: const Text(
                  'Clear search',
                  style: TextStyle(
                    color: AppColors.sharePurple,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
      itemCount: _placeResults.length,
      itemBuilder: (_, i) {
        final place = _placeResults[i];
        return GestureDetector(
          onTap: () => _getPrediction(place),
          child: GlassContainer(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(14),
            borderRadius: 14,
            child: Row(
              children: [
                Text(place.emoji, style: const TextStyle(fontSize: 26)),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        place.name,
                        style: TextStyle(
                          color: AppColors.isLight
                              ? AppColors.textPrimary
                              : Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        place.address,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: AppColors.isLight
                              ? AppColors.textOnGlassMuted
                              : Colors.white.withValues(alpha: 0.4),
                          fontSize: 11,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        place.category,
                        style: TextStyle(
                          color: AppColors.sharePurple.withValues(alpha: 0.8),
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.isLight
                      ? AppColors.textTertiary
                      : Colors.white24,
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
        mainAxisSize: MainAxisSize.min,
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
                  'Back to search',
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
                      style: TextStyle(
                        color: AppColors.isLight
                            ? AppColors.textPrimary
                            : Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      loc.address,
                      style: TextStyle(
                        color: AppColors.isLight
                            ? AppColors.textOnGlassMuted
                            : Colors.white.withValues(alpha: 0.4),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          GlassContainer(
            padding: const EdgeInsets.all(20),
            borderRadius: 16,
            glowColor: pred.statusColor,
            glowIntensity: 0.12,
            backgroundColor: pred.statusColor.withValues(alpha: 0.08),
            child: Column(
              mainAxisSize: MainAxisSize.min,
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
                    color: AppColors.isLight
                        ? AppColors.textOnGlassSecondary
                        : Colors.white.withValues(alpha: 0.55),
                    fontSize: 13,
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'AI confidence: ${pred.confidence}',
                  style: TextStyle(
                    color: AppColors.isLight
                        ? AppColors.textOnGlassMuted
                        : Colors.white.withValues(alpha: 0.25),
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
                    color: AppColors.successBright.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.successBright.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Row(
                        children: [
                          Icon(
                            Icons.thumb_up_rounded,
                            color: AppColors.successBright,
                            size: 14,
                          ),
                          SizedBox(width: 6),
                          Text(
                            'Best time',
                            style: TextStyle(
                              color: AppColors.successBright,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        pred.bestTimeToVisit,
                        style: TextStyle(
                          color: AppColors.isLight
                              ? AppColors.textPrimary
                              : Colors.white,
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
                    color: AppColors.errorBright.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.errorBright.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Row(
                        children: [
                          Icon(
                            Icons.warning_amber_rounded,
                            color: AppColors.errorBright,
                            size: 14,
                          ),
                          SizedBox(width: 6),
                          Text(
                            'Avoid',
                            style: TextStyle(
                              color: AppColors.errorBright,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        pred.worstTimeToVisit,
                        style: TextStyle(
                          color: AppColors.isLight
                              ? AppColors.textPrimary
                              : Colors.white,
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
            Text(
              '💡  Smart Tips',
              style: TextStyle(
                color: AppColors.isLight
                    ? AppColors.textPrimary
                    : Colors.white,
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
                        color: AppColors.accentGold,
                        fontSize: 14,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        tip,
                        style: TextStyle(
                          color: AppColors.isLight
                              ? AppColors.textOnGlassSecondary
                              : Colors.white.withValues(alpha: 0.6),
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
              Text(
                '👥  Community Reports',
                style: TextStyle(
                  color: AppColors.isLight
                      ? AppColors.textPrimary
                      : Colors.white,
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
                    color: AppColors.accentGold.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppColors.accentGold.withValues(alpha: 0.3),
                    ),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.add, color: AppColors.accentGold, size: 14),
                      SizedBox(width: 4),
                      Text(
                        'Report',
                        style: TextStyle(
                          color: AppColors.accentGold,
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
                .where('locationId', isEqualTo: _selectedLocation!.placeId)
                .orderBy('reportedAt', descending: true)
                .limit(5)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.isLight
                        ? AppColors.glassBorder.withValues(alpha: 0.25)
                        : Colors.white.withValues(alpha: 0.03),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Community reports unavailable.\n'
                    'Create the Firestore index if prompted in console.',
                    style: TextStyle(
                      color: AppColors.isLight
                          ? AppColors.textOnGlassMuted
                          : Colors.white.withValues(alpha: 0.35),
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
                    color: AppColors.isLight
                        ? AppColors.glassBorder.withValues(alpha: 0.25)
                        : Colors.white.withValues(alpha: 0.03),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.isLight
                          ? AppColors.glassBorder
                          : Colors.white.withValues(alpha: 0.06),
                    ),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('📋', style: TextStyle(fontSize: 28)),
                        const SizedBox(height: 8),
                        Text(
                          'No community reports yet',
                          style: TextStyle(
                            color: AppColors.isLight
                                ? AppColors.textOnGlassMuted
                                : Colors.white.withValues(alpha: 0.3),
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Be the first to report a wait time',
                          style: TextStyle(
                            color: AppColors.isLight
                                ? AppColors.textOnGlassMuted
                                : Colors.white.withValues(alpha: 0.2),
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              return Column(
                mainAxisSize: MainAxisSize.min,
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
                      color: AppColors.isLight
                          ? AppColors.glassBorder.withValues(alpha: 0.25)
                          : Colors.white.withValues(alpha: 0.04),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: AppColors.isLight
                            ? AppColors.glassBorder
                            : Colors.white.withValues(alpha: 0.07),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: AppColors.sharePurple
                                .withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '$mins',
                                style: const TextStyle(
                                  color: AppColors.sharePurple,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 16,
                                  height: 1,
                                ),
                              ),
                              Text(
                                'min',
                                style: TextStyle(
                                  color: AppColors.sharePurple
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
                                  style: TextStyle(
                                    color: AppColors.isLight
                                        ? AppColors.textPrimary
                                        : Colors.white,
                                    fontSize: 13,
                                  ),
                                ),
                              Text(
                                'Reported $time',
                                style: TextStyle(
                                  color: AppColors.isLight
                                      ? AppColors.textOnGlassMuted
                                      : Colors.white.withValues(alpha: 0.3),
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
