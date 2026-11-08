import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/glass/glass_container.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/core/widgets/glass_primary_button.dart';
import 'package:raabta/features/quick_actions/climate_navigator/data/wbgt_estimate_uncertainty.dart';
import 'package:raabta/features/quick_actions/climate_navigator/l10n/climate_strings.dart';
import 'package:raabta/features/quick_actions/climate_navigator/models/climate_wbgt_meter_reading.dart';
import 'package:raabta/features/quick_actions/climate_navigator/models/qatar_weather.dart';
import 'package:raabta/features/quick_actions/climate_navigator/presentation/climate_wbgt_status_presentation.dart';
import 'package:raabta/features/quick_actions/climate_navigator/services/climate_wbgt_meter_repository.dart';
import 'package:raabta/features/quick_actions/climate_navigator/widgets/climate_primitives.dart';
import 'package:share_plus/share_plus.dart';

/// Local WBGT meter log (Part 1C) — SharedPreferences only, no upload.
class ClimateWbgtMeterPanel extends StatefulWidget {
  const ClimateWbgtMeterPanel({
    super.key,
    required this.weather,
    required this.locale,
  });

  final QatarWeather weather;
  final String locale;

  @override
  State<ClimateWbgtMeterPanel> createState() => _ClimateWbgtMeterPanelState();
}

class _ClimateWbgtMeterPanelState extends State<ClimateWbgtMeterPanel> {
  final _valueController = TextEditingController();
  final _noteController = TextEditingController();
  ClimateWbgtMeterReading? _latest;
  String? _errorKey;
  var _saving = false;

  @override
  void initState() {
    super.initState();
    _refreshLatest();
  }

  @override
  void dispose() {
    _valueController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _refreshLatest() async {
    final latest = await ClimateWbgtMeterRepository.latest();
    if (mounted) setState(() => _latest = latest);
  }

  Future<void> _save() async {
    climateLightHaptic();
    setState(() {
      _errorKey = null;
      _saving = true;
    });

    final value = ClimateWbgtMeterValidation.parseWbgtInput(_valueController.text);
    final noteRaw = _noteController.text.trim();

    if (value == null) {
      setState(() {
        _errorKey = 'meter_invalid_value';
        _saving = false;
      });
      return;
    }
    if (!ClimateWbgtMeterValidation.isNoteAllowed(noteRaw)) {
      setState(() {
        _errorKey = 'meter_note_rejected';
        _saving = false;
      });
      return;
    }

    try {
      await ClimateWbgtMeterRepository.append(
        meterWbgtC: value,
        estimateWbgtC: widget.weather.wbgtEstimateC,
        estimateBandKey: widget.weather.wbgtRiskLevelKey,
        note: noteRaw.isEmpty ? null : noteRaw,
      );
      _valueController.clear();
      _noteController.clear();
      await _refreshLatest();
    } catch (_) {
      setState(() => _errorKey = 'meter_invalid_value');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _shareLatest() async {
    final reading = _latest;
    if (reading == null) return;
    climateLightHaptic();
    final text = ClimateWbgtMeterRepository.buildShareText(
      reading,
      (k) => ClimateStrings.t(k, widget.locale),
      (k, p) => ClimateStrings.format(k, widget.locale, params: p),
    );
    await Share.share(text);
  }

  @override
  Widget build(BuildContext context) {
    final locale = widget.locale;
    final estimate = widget.weather.wbgtEstimateC;
    final estimateBand = widget.weather.wbgtRiskLevelKey;
    final latest = _latest;
    final cautionKey = latest == null
        ? null
        : WbgtEstimateUncertainty.meterCautionBandKey(
            meterWbgtC: latest.meterWbgtC,
            estimateBandKey: latest.estimateBandKey,
          );

    return GlassContainer(
      padding: const EdgeInsets.all(16),
      borderRadius: 14,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            ClimateStrings.t('meter_section_title', locale),
            style: AppTypography.title.copyWith(fontSize: 16),
          ),
          const SizedBox(height: 4),
          Text(
            ClimateStrings.t('meter_section_subtitle', locale),
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          TextField(
            controller: _valueController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
            ],
            decoration: InputDecoration(
              labelText: ClimateStrings.t('meter_value_label', locale),
              hintText: ClimateStrings.format(
                'meter_value_hint',
                locale,
                params: {
                  'min': ClimateWbgtMeterValidation.minC.toStringAsFixed(0),
                  'max': ClimateWbgtMeterValidation.maxC.toStringAsFixed(0),
                },
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _noteController,
            maxLength: 120,
            decoration: InputDecoration(
              labelText: ClimateStrings.t('meter_note_label', locale),
              hintText: ClimateStrings.t('meter_note_hint', locale),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          if (_errorKey != null) ...[
            const SizedBox(height: 6),
            Text(
              ClimateStrings.t(_errorKey!, locale),
              style: AppTypography.caption.copyWith(color: AppColors.error),
            ),
          ],
          const SizedBox(height: 10),
          GlassPrimaryButton(
            label: ClimateStrings.t('meter_save', locale),
            expand: true,
            onPressed: _saving ? null : _save,
          ),
          const SizedBox(height: 8),
          Text(
            ClimateStrings.t('meter_not_legal_record', locale),
            style: AppTypography.caption.copyWith(
              color: AppColors.textTertiary,
              fontSize: 11,
            ),
          ),
          if (latest != null) ...[
            const SizedBox(height: AppSpacing.lg),
            Text(
              ClimateStrings.t('meter_latest_heading', locale),
              style: AppTypography.bodySmall.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.cyanGlow,
              ),
            ),
            const SizedBox(height: 8),
            _LatestReadingCard(
              reading: latest,
              locale: locale,
              currentEstimate: estimate,
              currentBandKey: estimateBand,
            ),
            if (cautionKey != null) ...[
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: ClimateWbgtStatusPresentation.accentForLevel(cautionKey)
                      .withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      ClimateStrings.t('meter_caution_higher_title', locale),
                      style: AppTypography.caption.copyWith(
                        fontWeight: FontWeight.w700,
                        color:
                            ClimateWbgtStatusPresentation.accentForLevel(cautionKey),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      ClimateStrings.t(
                        ClimateWbgtStatusPresentation.guidanceKeyForLevel(cautionKey),
                        locale,
                      ),
                      style: AppTypography.caption.copyWith(
                        height: 1.35,
                        color: AppColors.textOnGlassSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 8),
            Align(
              alignment: AlignmentDirectional.centerEnd,
              child: TextButton.icon(
                onPressed: _shareLatest,
                icon: const Icon(Icons.ios_share_outlined, size: 16),
                label: Text(ClimateStrings.t('meter_share_latest', locale)),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _LatestReadingCard extends StatelessWidget {
  const _LatestReadingCard({
    required this.reading,
    required this.locale,
    required this.currentEstimate,
    required this.currentBandKey,
  });

  final ClimateWbgtMeterReading reading;
  final String locale;
  final double currentEstimate;
  final String currentBandKey;

  @override
  Widget build(BuildContext context) {
    final time = DateFormat.yMMMd().add_Hm().format(reading.recordedAt.toLocal());
    final diff = reading.differenceC;
    final sign = diff >= 0 ? '+' : '';
    final snapBand = ClimateStrings.t(
      ClimateWbgtStatusPresentation.shortLabelKeyForLevel(reading.estimateBandKey),
      locale,
    );
    final liveBand = ClimateStrings.t(
      ClimateWbgtStatusPresentation.shortLabelKeyForLevel(currentBandKey),
      locale,
    );

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.textSecondary.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.glassBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            ClimateStrings.format(
              'meter_latest_value_line',
              locale,
              params: {'value': reading.meterWbgtC.toStringAsFixed(1)},
            ),
            style: AppTypography.body.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          Text(
            ClimateStrings.format(
              'meter_latest_meta',
              locale,
              params: {
                'time': time,
                'estimate': reading.estimateWbgtC.toStringAsFixed(1),
                'band': snapBand,
                'diff': '$sign${diff.toStringAsFixed(1)}',
              },
            ),
            style: AppTypography.caption.copyWith(
              color: AppColors.textSecondary,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            ClimateStrings.format(
              'meter_current_estimate_line',
              locale,
              params: {
                'estimate': currentEstimate.toStringAsFixed(1),
                'band': liveBand,
              },
            ),
            style: AppTypography.caption.copyWith(
              color: AppColors.textOnGlassMuted,
              height: 1.35,
            ),
          ),
          if (reading.note != null && reading.note!.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              reading.note!,
              style: AppTypography.caption.copyWith(
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
