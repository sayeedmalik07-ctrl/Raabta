import 'dart:convert';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/glass/glass_container.dart';
import 'package:raabta/core/l10n/app_locale.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/core/widgets/glass_primary_button.dart';
import 'package:raabta/core/widgets/glass_screen_scaffold.dart';
import 'package:raabta/features/home/widgets/glass_loading_card.dart';
import 'package:raabta/features/home/widgets/home_section_header.dart';
import 'package:raabta/providers/visa_providers.dart';
import 'package:raabta/services/ai/claude_ai_service.dart';
import 'package:url_launcher/url_launcher.dart';

import 'climate_navigator/l10n/climate_strings.dart';
import 'climate_navigator/models/qatar_weather.dart';
import 'climate_navigator/services/climate_heat_reminder_scheduler.dart';
import 'climate_navigator/services/climate_status_listen_session.dart';
import 'climate_navigator/services/climate_route_history_repository.dart';
import 'climate_navigator/widgets/climate_feature_empty_state.dart';
import 'climate_navigator/widgets/climate_primitives.dart';
import 'climate_navigator/widgets/cooling_resources_panel.dart';
import 'climate_navigator/widgets/climate_status_hero.dart';
import 'climate_navigator/widgets/climate_wbgt_meter_panel.dart';
import 'climate_navigator/widgets/heat_illness_guide_panel.dart';
import 'climate_navigator/widgets/acclimatization_section.dart';
import 'climate_navigator/widgets/heat_symptom_checker.dart';
import 'climate_navigator/widgets/heat_violation_rights_section.dart';
import 'climate_navigator/widgets/workload_guidance_section.dart';
import 'climate_navigator/widgets/location_search_field.dart';
import 'climate_navigator/widgets/route_map_preview.dart';
import 'package:raabta/features/concierge_90_day/presentation/providers/concierge_providers.dart';
import 'package:raabta/providers/auth_providers.dart';

// ─── Route option model ───────────────────────────────────

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
  final List<RouteOption> options;
  final List<String> generalTips;

  const ClimateAdvice({
    required this.summary,
    required this.heatAlert,
    required this.options,
    required this.generalTips,
  });
}

// ─── SCREEN ──────────────────────────────────────────────

class ClimateNavigatorScreen extends ConsumerStatefulWidget {
  const ClimateNavigatorScreen({super.key});

  @override
  ConsumerState<ClimateNavigatorScreen> createState() =>
      _ClimateNavigatorScreenState();
}

class _ClimateNavigatorScreenState
    extends ConsumerState<ClimateNavigatorScreen> {
  String _fromLocation = '';
  String _toLocation = '';
  int _fieldVersion = 0;

  bool _isLoading = false;
  ClimateAdvice? _advice;
  String? _error;
  List<ClimateRouteHistoryEntry> _recentRoutes = const [];

  final _scrollController = ScrollController();
  final _routeSectionKey = GlobalKey();

  static const _doctorFinderRoute = '/health-insurance';

  @override
  void dispose() {
    ClimateStatusListenSession.stopActiveForDispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _loadRouteHistory();
    ref.listenManual(qatarWeatherProvider, (_, next) {
      next.whenData((weather) async {
        final locale = ref.read(userLanguageProvider);
        await ClimateHeatReminderScheduler.syncFromWeather(
          weather: weather,
          locale: locale,
        );
      });
    });
  }

  Future<void> _loadRouteHistory() async {
    final entries = await ClimateRouteHistoryRepository.load();
    if (mounted) setState(() => _recentRoutes = entries);
  }

  void _applyHistoryEntry(ClimateRouteHistoryEntry entry) {
    climateSelectionHaptic();
    setState(() {
      _fromLocation = entry.from;
      _toLocation = entry.to;
      _fieldVersion++;
      _advice = null;
      _error = null;
    });
  }

  Future<void> _getRouteAdvice() async {
    final locale = AppLocale.normalize(ref.read(userLanguageProvider));

    if (_fromLocation.trim().isEmpty || _toLocation.trim().isEmpty) {
      setState(() {
        _error = ClimateStrings.t('route_error_missing', locale);
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

      QatarWeather weather;
      try {
        weather = await ref.read(qatarWeatherProvider.future);
      } catch (_) {
        weather = QatarWeather.fallback();
      }

      final prompt = '''
You are a Qatar climate and navigation expert helping expats
stay safe from extreme heat. Provide heat-safe route advice.

IMPORTANT: Respond in $locale (the user's app language).
All JSON string values (summary, heatAlert, titles, descriptions,
steps, tips, bestTime) must be written in $locale.

Journey: FROM "$_fromLocation" TO "$_toLocation" in Qatar.
Day: ${dayNames[now.weekday]}
Month: ${monthNames[now.month]}
Hour: ${now.hour}:00

${weather.toPromptContext()}

Generate 3 route options ranked from LOWEST to HIGHEST
heat exposure. Respond ONLY with valid JSON, no markdown:
{
  "summary": "<2 sentences about this journey and heat context>",
  "heatAlert": "<one line current heat warning or all-clear>",
  "options": [
    {
      "title": "<route name e.g. Metro + Indoor Route>",
      "emoji": "<single emoji>",
      "heatRisk": "<low|medium|high>",
      "heatRiskColor": "<#2DC653|#FFB627|#E63946>",
      "duration": "<estimated total time e.g. 35 mins>",
      "description": "<2 sentences why this is smart>",
      "steps": ["<step 1>", "<step 2>", "<step 3>"],
      "bestTime": "<ideal time to travel e.g. Before 9AM>",
      "mapQuery": "<Google Maps search query for this route>"
    }
  ],
  "generalTips": [
    "<Qatar-specific heat tip 1>",
    "<Qatar-specific heat tip 2>",
    "<Qatar-specific heat tip 3>"
  ]
}

Qatar-specific knowledge to apply:
- Qatar Metro: Red Line, Gold Line, Green Line — always cool
- Indoor waypoints: City Center, Villagio, Mall of Qatar
- Park & Ride: Legtaifiya, DECC, Hamad Hospital stations
- Peak heat: 11AM–4PM — always flag this window
- Kareem/Uber AC: good option when walking < 50m each end
- Labour Law: outdoor work banned 10AM–3:30PM June–Sept
- Al Khor: 45 min north of Doha — factor in longer exposure
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

      final options = (json['options'] as List? ?? []).map((o) {
        final hex = (o['heatRiskColor'] as String? ?? '#FFB627')
            .replaceAll('#', '');
        return RouteOption(
          title: o['title'] as String? ?? 'Route',
          emoji: o['emoji'] as String? ?? '🗺️',
          heatRisk: o['heatRisk'] as String? ?? 'medium',
          heatColor: Color(int.parse('FF$hex', radix: 16)),
          duration: o['duration'] as String? ?? 'N/A',
          description: o['description'] as String? ?? '',
          steps: (o['steps'] as List? ?? [])
              .map((s) => s.toString())
              .toList(),
          bestTime: o['bestTime'] as String? ?? 'Anytime',
          mapQuery: o['mapQuery'] as String? ??
              '$_fromLocation to $_toLocation Qatar',
        );
      }).toList();

      if (!mounted) return;
      climateSuccessHaptic();
      await ClimateRouteHistoryRepository.save(
        from: _fromLocation,
        to: _toLocation,
      );
      await _loadRouteHistory();
      setState(() {
        _advice = ClimateAdvice(
          summary: json['summary'] as String? ?? '',
          heatAlert: json['heatAlert'] as String? ?? '',
          options: options,
          generalTips: (json['generalTips'] as List? ?? [])
              .map((t) => t.toString())
              .toList(),
        );
      });
    } catch (_) {
      if (!mounted) return;
      final locale = AppLocale.normalize(ref.read(userLanguageProvider));
      setState(() {
        _error = ClimateStrings.t('route_error_failed', locale);
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

  void _resetRoute() {
    setState(() {
      _advice = null;
      _error = null;
      _fromLocation = '';
      _toLocation = '';
      _fieldVersion++;
    });
  }

  void _swapLocations() {
    climateSelectionHaptic();
    setState(() {
      final tmp = _fromLocation;
      _fromLocation = _toLocation;
      _toLocation = tmp;
      _fieldVersion++;
    });
  }

  void _setDestinationFromCooling(String destination) {
    setState(() {
      _toLocation = destination;
      _fieldVersion++;
      _advice = null;
      _error = null;
    });
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          ClimateStrings.t(
            'cooling_destination_set',
            AppLocale.normalize(ref.read(userLanguageProvider)),
          ),
        ),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final ctx = _routeSectionKey.currentContext;
      if (ctx != null && mounted) {
        Scrollable.ensureVisible(
          ctx,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOutCubic,
          alignment: 0.1,
        );
      }
    });
  }

  void _openHeatIllnessGuide(String locale) {
    HeatIllnessGuidePanel.showSheet(context, locale);
  }

  Future<DateTime?> _fetchConciergeArrivalForPrefill() async {
    final uid = ref.read(currentUserProvider)?.uid;
    if (uid == null) return null;
    final repo = await ref.read(conciergeRepositoryProvider.future);
    return (await repo.loadProgress(uid)).arrivalDate;
  }

  Widget _buildStatusHero(String locale, AsyncValue<QatarWeather> weatherAsync) {
    return weatherAsync.when(
      loading: () => _buildWeatherSkeleton(locale),
      error: (_, _) => ClimateStatusHero(
        weather: QatarWeather.fallback(),
        locale: locale,
        onOpenGuide: () => _openHeatIllnessGuide(locale),
      ),
      data: (weather) => ClimateStatusHero(
        weather: weather,
        locale: locale,
        onOpenGuide: () => _openHeatIllnessGuide(locale),
      ),
    );
  }

  Widget _buildMeterPanel(String locale, AsyncValue<QatarWeather> weatherAsync) {
    return weatherAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, _) => ClimateWbgtMeterPanel(
        weather: QatarWeather.fallback(),
        locale: locale,
      ),
      data: (weather) => ClimateWbgtMeterPanel(
        weather: weather,
        locale: locale,
      ),
    );
  }

  Widget _buildRoutePlannerSection(
    String locale,
    AsyncValue<QatarWeather> weatherAsync,
  ) {
    return Column(
      key: _routeSectionKey,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        HomeSectionHeader(
          overline: ClimateStrings.t('section_route_overline', locale),
          title: ClimateStrings.t('section_route_title', locale),
        ),
        const SizedBox(height: AppSpacing.md),
        if (_recentRoutes.isNotEmpty) ...[
          Text(
            ClimateStrings.t('route_history_title', locale),
            style: AppTypography.caption.copyWith(
              color: AppColors.textOnGlassSecondary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          SizedBox(
            height: 44,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _recentRoutes.length,
              separatorBuilder: (_, _) =>
                  const SizedBox(width: AppSpacing.sm),
              itemBuilder: (context, index) {
                final entry = _recentRoutes[index];
                final fromShort = entry.from.split(',').first.trim();
                final toShort = entry.to.split(',').first.trim();
                return Semantics(
                  button: true,
                  label: ClimateStrings.format(
                    'route_history_chip',
                    locale,
                    params: {'from': fromShort, 'to': toShort},
                  ),
                  child: ActionChip(
                    avatar: Icon(
                      Icons.history_rounded,
                      size: 14,
                      color: climateAccent,
                    ),
                    label: Text(
                      ClimateStrings.format(
                        'route_history_chip',
                        locale,
                        params: {'from': fromShort, 'to': toShort},
                      ),
                      style: AppTypography.caption,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    onPressed: () => _applyHistoryEntry(entry),
                    backgroundColor: climateAccent.withValues(alpha: 0.1),
                    side: BorderSide(
                      color: climateAccent.withValues(alpha: 0.25),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: AppSpacing.md),
        ],
        LocationSearchField(
          key: ValueKey('from_$_fieldVersion'),
          label: ClimateStrings.t('route_from_label', locale),
          hint: ClimateStrings.t('route_from_hint', locale),
          iconColor: AppColors.successBright,
          prefixIcon: Icons.my_location_rounded,
          initialValue: _fromLocation,
          locale: locale,
          onLocationSelected: (v) => setState(() => _fromLocation = v),
        ),
        const SizedBox(height: 14),
        Center(
          child: Semantics(
            button: true,
            label: ClimateStrings.t('route_swap_locations', locale),
            child: Material(
              color: AppColors.sharePurple.withValues(alpha: 0.15),
              shape: CircleBorder(
                side: BorderSide(
                  color: AppColors.sharePurple.withValues(alpha: 0.3),
                ),
              ),
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: _swapLocations,
                child: const SizedBox(
                  width: 44,
                  height: 44,
                  child: Icon(
                    Icons.swap_vert_rounded,
                    color: AppColors.sharePurple,
                    size: 20,
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 14),
        LocationSearchField(
          key: ValueKey('to_$_fieldVersion'),
          label: ClimateStrings.t('route_to_label', locale),
          hint: ClimateStrings.t('route_to_hint', locale),
          iconColor: AppColors.errorBright,
          prefixIcon: Icons.location_on_rounded,
          initialValue: _toLocation,
          locale: locale,
          onLocationSelected: (v) => setState(() => _toLocation = v),
        ),
        if (_error != null) ...[
          const SizedBox(height: 14),
          GlassContainer(
            padding: const EdgeInsets.all(12),
            borderRadius: 10,
            glowColor: AppColors.error,
            glowIntensity: 0.1,
            backgroundColor: AppColors.error.withValues(alpha: 0.08),
            child: Text(
              _error!,
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.errorBright,
              ),
            ),
          ),
        ],
        const SizedBox(height: AppSpacing.lg),
        if (_isLoading) ...[
          _buildInlineRouteLoading(locale),
          const SizedBox(height: AppSpacing.lg),
        ] else
          weatherAsync.when(
            loading: () => GlassPrimaryButton(
              label: ClimateStrings.t('route_loading_weather', locale),
              expand: true,
              accentColor: AppColors.sharePurple,
              icon: Icons.cloud_outlined,
              onPressed: null,
            ),
            error: (_, _) => _routeButton(locale, AppColors.accentGold),
            data: (weather) =>
                _routeButton(locale, weather.heatRiskColor),
          ),
        if (_advice == null && !_isLoading && _recentRoutes.isEmpty)
          Padding(
            padding: const EdgeInsets.only(top: AppSpacing.lg),
            child: ClimateFeatureEmptyState(
              compact: true,
              icon: Icons.route_rounded,
              title: ClimateStrings.t('empty_route_title', locale),
              description: ClimateStrings.t('empty_route_body', locale),
            ),
          ),
        if (_advice != null) ...[
          const SizedBox(height: AppSpacing.xl),
          ClimateEntranceReveal(
            child: GlassContainer(
              padding: const EdgeInsets.all(14),
              borderRadius: 12,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RouteMapPreview(
                    fromLabel: _fromLocation,
                    toLabel: _toLocation,
                    routeLabel:
                        ClimateStrings.t('route_map_preview', locale),
                    accentColor: climateAccent,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(
                        Icons.info_outline_rounded,
                        color: climateAccent,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _advice!.heatAlert,
                          style: AppTypography.caption.copyWith(
                            color: climateAccent,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _advice!.summary,
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textOnGlassMuted,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          ClimateEntranceReveal(
            delay: const Duration(milliseconds: 60),
            child: Text(
              ClimateStrings.t('route_options_heading', locale),
              style: AppTypography.title,
            ),
          ),
          const SizedBox(height: 12),
          ..._advice!.options.asMap().entries.map(
                (e) => ClimateEntranceReveal(
                  delay: Duration(milliseconds: 80 + e.key * 70),
                  child: _RouteCard(
                    option: e.value,
                    rank: e.key + 1,
                    locale: locale,
                    fromLocation: _fromLocation,
                    toLocation: _toLocation,
                    onOpenMaps: () => _openInMaps(e.value.mapQuery),
                  ),
                ),
              ),
          if (_advice!.generalTips.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.lg),
            ClimateEntranceReveal(
              delay: Duration(
                milliseconds: 80 + _advice!.options.length * 70,
              ),
              child: Text(
                ClimateStrings.t('route_tips_heading', locale),
                style: AppTypography.title,
              ),
            ),
            const SizedBox(height: 10),
            ..._advice!.generalTips.map(
              (tip) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '•  ',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.accentGold,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        tip,
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.textOnGlassMuted,
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
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final locale = AppLocale.normalize(ref.watch(userLanguageProvider));
    final isRtl = AppLocale.isRtl(locale);
    final weatherAsync = ref.watch(qatarWeatherProvider);

    return Directionality(
      textDirection: isRtl ? ui.TextDirection.rtl : ui.TextDirection.ltr,
      child: GlassScreenScaffold(
        title: ClimateStrings.t('screen_title', locale),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        actions: [
          if (_advice != null)
            TextButton(
              onPressed: () {
                climateLightHaptic();
                _resetRoute();
              },
              child: Text(
                ClimateStrings.t('route_new', locale),
                style: AppTypography.button.copyWith(color: climateAccent),
              ),
            ),
          const SizedBox(width: AppSpacing.sm),
        ],
        padding: climateScreenPadding,
        body: ListView(
          controller: _scrollController,
          children: [
            HomeSectionHeader(
              overline:
                  ClimateStrings.t('section_conditions_overline', locale),
              title: ClimateStrings.t('section_conditions_title', locale),
            ),
            const SizedBox(height: AppSpacing.md),
            _buildStatusHero(locale, weatherAsync),
            const SizedBox(height: AppSpacing.md),
            _buildMeterPanel(locale, weatherAsync),
            const SizedBox(height: AppSpacing.xl),
            _buildRoutePlannerSection(locale, weatherAsync),
            const SizedBox(height: AppSpacing.xl),
            WorkloadGuidanceSection(
              locale: locale,
              onOpenHeatGuide: () => _openHeatIllnessGuide(locale),
            ),
            const SizedBox(height: AppSpacing.xl),
            CoolingResourcesPanel(
              locale: locale,
              onSetDestination: _setDestinationFromCooling,
            ),
            const SizedBox(height: AppSpacing.xl),
            AcclimatizationSection(
              locale: locale,
              fetchConciergeArrivalDate:
                  ref.watch(currentUserProvider)?.uid != null
                      ? _fetchConciergeArrivalForPrefill
                      : null,
              onOpenHeatGuide: () => _openHeatIllnessGuide(locale),
            ),
            const SizedBox(height: AppSpacing.md),
            HeatViolationRightsSection(locale: locale),
            const SizedBox(height: AppSpacing.xl),
            HomeSectionHeader(
              overline:
                  ClimateStrings.t('section_emergency_overline', locale),
              title: ClimateStrings.t('section_emergency_title', locale),
            ),
            const SizedBox(height: AppSpacing.md),
            HeatSymptomChecker(
              doctorFinderRoute: _doctorFinderRoute,
              locale: locale,
            ),
            const SizedBox(height: AppSpacing.xxxl),
          ],
        ),
      ),
    );
  }

  Widget _buildInlineRouteLoading(String locale) {
    return GlassContainer(
      padding: const EdgeInsets.all(AppSpacing.lg),
      borderRadius: AppSpacing.radiusSm,
      glowColor: climateAccent,
      glowIntensity: 0.1,
      child: Row(
        children: [
          const SizedBox(
            width: 22,
            height: 22,
            child: CircularProgressIndicator(
              color: AppColors.accentGold,
              strokeWidth: 2.5,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  ClimateStrings.t('route_loading_inline', locale),
                  style: AppTypography.body.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  ClimateStrings.t('route_loading_subtitle', locale),
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textOnGlassMuted,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeatherSkeleton(String locale) {
    return const GlassLoadingCard(height: 220);
  }

  Widget _routeButton(String locale, Color color) {
    final label = ClimateStrings.t('route_get_cta', locale);
    return Semantics(
      button: true,
      enabled: !_isLoading,
      label: label,
      child: GlassPrimaryButton(
        label: label,
        expand: true,
        accentColor: color,
        icon: Icons.air_rounded,
        onPressed: _isLoading
            ? null
            : () {
                climateMediumHaptic();
                _getRouteAdvice();
              },
      ),
    );
  }
}

// ─── Route card ───────────────────────────────────────────

class _RouteCard extends StatefulWidget {
  final RouteOption option;
  final int rank;
  final String locale;
  final String fromLocation;
  final String toLocation;
  final VoidCallback onOpenMaps;

  const _RouteCard({
    required this.option,
    required this.rank,
    required this.locale,
    required this.fromLocation,
    required this.toLocation,
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
    final locale = widget.locale;

    return GlassContainer(
      margin: const EdgeInsets.only(bottom: 12),
      borderRadius: 16,
      glowColor: opt.heatColor,
      glowIntensity: 0.1,
      child: Column(
        children: [
          GestureDetector(
            onTap: () {
              climateSelectionHaptic();
              setState(() => _expanded = !_expanded);
            },
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 26,
                    height: 26,
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
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
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
                          style: TextStyle(
                            color: AppColors.isLight
                                ? AppColors.textPrimary
                                : Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Row(
                          children: [
                            Icon(
                              Icons.schedule_rounded,
                              color: AppColors.isLight
                                  ? AppColors.textOnGlassMuted
                                  : Colors.white.withValues(alpha: 0.35),
                              size: 12,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              opt.duration,
                              style: TextStyle(
                                color: AppColors.isLight
                                    ? AppColors.textOnGlassMuted
                                    : Colors.white.withValues(alpha: 0.45),
                                fontSize: 11,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: opt.heatColor.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                ClimateStrings.routeHeatBadge(
                                  opt.heatRisk,
                                  locale,
                                ),
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
                    color: AppColors.isLight
                        ? AppColors.textOnGlassMuted
                        : Colors.white38,
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
                  Divider(
                    color: AppColors.isLight
                        ? AppColors.glassBorder
                        : Colors.white10,
                    height: 1,
                  ),
                  const SizedBox(height: 12),
                  RouteMapPreview(
                    fromLabel: widget.fromLocation,
                    toLabel: widget.toLocation,
                    routeLabel: ClimateStrings.t('route_map_preview', locale),
                    accentColor: opt.heatColor,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    opt.description,
                    style: TextStyle(
                      color: AppColors.isLight
                          ? AppColors.textOnGlassSecondary
                          : Colors.white.withValues(alpha: 0.6),
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
                                margin: const EdgeInsets.only(top: 1),
                                decoration: BoxDecoration(
                                  color: AppColors.sharePurple.withValues(
                                    alpha: 0.2,
                                  ),
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: Text(
                                    '${e.key + 1}',
                                    style: const TextStyle(
                                      color: AppColors.sharePurple,
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
                                    color: AppColors.isLight
                                        ? AppColors.textOnGlassSecondary
                                        : Colors.white.withValues(
                                            alpha: 0.7,
                                          ),
                                    fontSize: 13,
                                    height: 1.45,
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
                        color: AppColors.accentGold,
                        size: 14,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        ClimateStrings.format(
                          'route_best_time',
                          locale,
                          params: {'time': opt.bestTime},
                        ),
                        style: const TextStyle(
                          color: AppColors.accentGold,
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
                      onPressed: () {
                        climateLightHaptic();
                        widget.onOpenMaps();
                      },
                      icon: const Icon(
                        Icons.map_rounded,
                        color: Colors.white,
                        size: 16,
                      ),
                      label: Text(
                        ClimateStrings.t('route_open_maps', locale),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.sharePurple,
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
