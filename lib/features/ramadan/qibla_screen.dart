import 'dart:async';
import 'dart:math' as math;

import 'package:adhan/adhan.dart';
import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:geolocator/geolocator.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/glass/glass_card.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/core/widgets/animated_background.dart';
import 'package:raabta/features/ramadan/prayer_times_service.dart';

class QiblaScreen extends StatefulWidget {
  const QiblaScreen({super.key});

  @override
  State<QiblaScreen> createState() => _QiblaScreenState();
}

class _QiblaScreenState extends State<QiblaScreen> {
  double? _qiblaBearing;
  double? _heading;
  String? _statusMessage;
  bool _loading = true;
  StreamSubscription<CompassEvent>? _compassSub;

  @override
  void initState() {
    super.initState();
    _initLocationAndCompass();
  }

  Future<void> _initLocationAndCompass() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _useFallbackLocation('Location services are off — using Doha.');
        return;
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        _useFallbackLocation('Location denied — using Doha.');
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
          timeLimit: Duration(seconds: 12),
        ),
      );
      _setQiblaFromCoords(position.latitude, position.longitude);
      _statusMessage = 'Using your current location';
    } catch (_) {
      _useFallbackLocation('Could not get GPS — using Doha.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }

    _compassSub = FlutterCompass.events?.listen((event) {
      final heading = event.heading;
      if (heading == null || !mounted) return;
      setState(() => _heading = heading);
    });
  }

  void _useFallbackLocation(String message) {
    _setQiblaFromCoords(
      PrayerTimesService.defaultLatitude,
      PrayerTimesService.defaultLongitude,
    );
    _statusMessage = message;
  }

  void _setQiblaFromCoords(double lat, double lng) {
    final qibla = Qibla(Coordinates(lat, lng));
    setState(() => _qiblaBearing = qibla.direction);
  }

  @override
  void dispose() {
    _compassSub?.cancel();
    super.dispose();
  }

  double? get _needleRotation {
    if (_qiblaBearing == null || _heading == null) return null;
    return (_qiblaBearing! - _heading!) * (math.pi / 180);
  }

  bool get _isAligned {
    if (_qiblaBearing == null || _heading == null) return false;
    final delta = (_qiblaBearing! - _heading!).abs() % 360;
    final shortest = delta > 180 ? 360 - delta : delta;
    return shortest <= 5;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Qibla Direction'),
      ),
      body: AnimatedAuroraBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              children: [
                if (_statusMessage != null)
                  GlassCard(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: Text(
                      _statusMessage!,
                      style: AppTypography.bodySmall,
                      textAlign: TextAlign.center,
                    ),
                  ),
                const SizedBox(height: AppSpacing.lg),
                Expanded(
                  child: Center(
                    child: _loading
                        ? const CircularProgressIndicator(
                            color: AppColors.amberGlow,
                          )
                        : _buildCompass(),
                  ),
                ),
                if (_qiblaBearing != null)
                  GlassCard(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child: Column(
                      children: [
                        Text(
                          'Qibla bearing',
                          style: AppTypography.bodySmall,
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          '${_qiblaBearing!.toStringAsFixed(1)}° from North',
                          style: AppTypography.headline2,
                        ),
                        if (_isAligned) ...[
                          const SizedBox(height: AppSpacing.sm),
                          Text(
                            '✓ Facing Qibla',
                            style: AppTypography.title.copyWith(
                              color: AppColors.success,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCompass() {
    if (_heading == null) {
      return GlassCard(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.explore_off_rounded,
              size: 48,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Compass unavailable on this device.\n'
              'Use the bearing above with a physical compass.',
              style: AppTypography.body,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: 260,
          height: 260,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: AppColors.glassBorderBright,
              width: 2,
            ),
            gradient: RadialGradient(
              colors: [
                AppColors.background.withValues(alpha: 0.4),
                AppColors.background.withValues(alpha: 0.1),
              ],
            ),
          ),
          child: CustomPaint(
            painter: _CompassDialPainter(heading: _heading!),
          ),
        ),
        Transform.rotate(
          angle: _needleRotation ?? 0,
          child: Icon(
            Icons.navigation_rounded,
            size: 72,
            color: _isAligned ? AppColors.success : AppColors.amberGlow,
          ),
        ),
        const Positioned(
          top: 12,
          child: Text('N', style: TextStyle(fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }
}

class _CompassDialPainter extends CustomPainter {
  _CompassDialPainter({required this.heading});

  final double heading;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 8;

    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(-heading * math.pi / 180);
    canvas.translate(-center.dx, -center.dy);

    final paint = Paint()
      ..color = AppColors.textSecondary.withValues(alpha: 0.6)
      ..strokeWidth = 1;

    for (var i = 0; i < 72; i++) {
      final angle = i * 5 * math.pi / 180;
      final inner = radius - (i % 9 == 0 ? 16 : 8);
      final x1 = center.dx + radius * math.sin(angle);
      final y1 = center.dy - radius * math.cos(angle);
      final x2 = center.dx + inner * math.sin(angle);
      final y2 = center.dy - inner * math.cos(angle);
      canvas.drawLine(Offset(x1, y1), Offset(x2, y2), paint);
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _CompassDialPainter oldDelegate) =>
      oldDelegate.heading != heading;
}
