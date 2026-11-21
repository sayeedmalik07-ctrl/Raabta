import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/widgets/glass_screen_scaffold.dart';
import 'package:raabta/features/prayer_mosque/presentation/l10n/prayer_strings.dart';
import 'package:raabta/features/prayer_mosque/presentation/widgets/qibla_compass_widget.dart';
import 'package:raabta/features/prayer_mosque/providers/prayer_providers.dart';
import 'package:raabta/features/prayer_mosque/services/prayer_analytics_service.dart';

class QiblaCompassScreen extends ConsumerStatefulWidget {
  const QiblaCompassScreen({super.key});

  @override
  ConsumerState<QiblaCompassScreen> createState() => _QiblaCompassScreenState();
}

class _QiblaCompassScreenState extends ConsumerState<QiblaCompassScreen> {
  double? _heading;
  double? _accuracy;
  StreamSubscription<CompassEvent>? _sub;
  bool _compassLoading = true;
  bool _compassUnavailable = false;

  @override
  void initState() {
    super.initState();
    PrayerAnalyticsService.qiblaUsage();
    _startCompass();
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted && _compassLoading) {
        setState(() {
          _compassLoading = false;
          if (_heading == null) {
            _compassUnavailable = true;
          }
        });
      }
    });
  }

  void _startCompass() {
    try {
      final events = FlutterCompass.events;
      if (events == null) {
        _compassUnavailable = true;
        _compassLoading = false;
        return;
      }
      _sub = events.listen(
        (event) {
          if (!mounted) return;
          setState(() {
            _heading = event.heading;
            _accuracy = event.accuracy;
            _compassLoading = false;
            _compassUnavailable = false;
          });
        },
        onError: (_) {
          if (!mounted) return;
          setState(() {
            _compassLoading = false;
            _compassUnavailable = true;
          });
        },
      );
    } on MissingPluginException {
      if (mounted) {
        setState(() {
          _compassLoading = false;
          _compassUnavailable = true;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _compassLoading = false;
          _compassUnavailable = true;
        });
      }
    }
  }

  @override
  void dispose() {
    try {
      _sub?.cancel();
    } on MissingPluginException {
      // Simulator / desktop — compass plugin not registered.
    } catch (_) {}
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(prayerProvider);
    final locale = state.settings.locale;
    final loc = state.location;
    final calc = ref.watch(prayerCalculationServiceProvider);

    final qibla = loc != null
        ? calc.qiblaBearing(loc.latitude, loc.longitude)
        : null;
    final distance = loc != null
        ? calc.distanceToKaabaKm(loc.latitude, loc.longitude)
        : null;

    return GlassScreenScaffold(
      title: PrayerStrings.t('prayer_qibla', locale),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => context.pop(),
      ),
      padding: const EdgeInsets.all(AppSpacing.lg),
      body: SingleChildScrollView(
        child: QiblaCompassWidget(
          heading: _heading,
          qiblaBearing: qibla,
          accuracy: _accuracy,
          locale: locale,
          distanceKm: distance,
          loading: state.isLoading && _compassLoading,
          compassUnavailable: _compassUnavailable,
        ),
      ),
    );
  }
}
