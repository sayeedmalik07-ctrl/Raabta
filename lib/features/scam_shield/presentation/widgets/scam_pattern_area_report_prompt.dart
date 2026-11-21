import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/features/scam_shield/presentation/l10n/scam_shield_strings.dart';
import 'package:raabta/features/scam_shield/providers/scam_pattern_aggregates_providers.dart';
import 'package:raabta/models/housing_models.dart';
import 'package:raabta/providers/auth_providers.dart';

/// Optional, non-blocking area capture after a location-relevant Phase 6 match.
class ScamPatternAreaReportPrompt extends ConsumerStatefulWidget {
  const ScamPatternAreaReportPrompt({
    super.key,
    required this.archetypeId,
    required this.locale,
  });

  final String archetypeId;
  final String locale;

  @override
  ConsumerState<ScamPatternAreaReportPrompt> createState() =>
      _ScamPatternAreaReportPromptState();
}

class _ScamPatternAreaReportPromptState
    extends ConsumerState<ScamPatternAreaReportPrompt> {
  String _selectedArea = qatarAreas.first;
  bool _dismissed = false;
  bool _submitting = false;
  String? _errorKey;

  Future<void> _submit() async {
    final uid = ref.read(currentUserProvider)?.uid;
    if (uid == null) {
      setState(() => _errorKey = 'ss_area_report_sign_in');
      return;
    }

    setState(() {
      _submitting = true;
      _errorKey = null;
    });

    try {
      await ref.read(scamPatternReportRepositoryProvider).submitReport(
            userId: uid,
            archetypeId: widget.archetypeId,
            area: _selectedArea,
          );
      if (mounted) {
        setState(() {
          _dismissed = true;
          _submitting = false;
        });
      }
    } on StateError catch (e) {
      if (!mounted) return;
      setState(() {
        _submitting = false;
        _errorKey = e.message == 'rate_limit_exceeded'
            ? 'ss_area_report_rate_limit'
            : 'ss_area_report_failed';
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _submitting = false;
        _errorKey = 'ss_area_report_failed';
      });
    }
  }

  void _skip() {
    setState(() => _dismissed = true);
  }

  @override
  Widget build(BuildContext context) {
    if (_dismissed) return const SizedBox.shrink();

    final locale = widget.locale;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          ScamShieldStrings.t('ss_area_report_heading', locale),
          style: AppTypography.title,
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          ScamShieldStrings.t('ss_area_report_body', locale),
          style: AppTypography.bodySmall.copyWith(
            color: AppColors.textOnGlassMuted,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        DropdownButtonFormField<String>(
          value: _selectedArea,
          decoration: InputDecoration(
            labelText: ScamShieldStrings.t('ss_area_report_selector', locale),
            border: const OutlineInputBorder(),
          ),
          items: qatarAreas
              .map(
                (area) => DropdownMenuItem(value: area, child: Text(area)),
              )
              .toList(),
          onChanged: _submitting
              ? null
              : (value) {
                  if (value != null) setState(() => _selectedArea = value);
                },
        ),
        const SizedBox(height: AppSpacing.md),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: _submitting ? null : _skip,
                child: Text(ScamShieldStrings.t('ss_area_report_skip', locale)),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: OutlinedButton(
                onPressed: _submitting ? null : _submit,
                child: _submitting
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(
                        ScamShieldStrings.t('ss_area_report_share', locale),
                      ),
              ),
            ),
          ],
        ),
        if (_errorKey != null) ...[
          const SizedBox(height: AppSpacing.sm),
          Text(
            ScamShieldStrings.t(_errorKey!, locale),
            style: AppTypography.caption.copyWith(color: AppColors.warning),
          ),
        ],
        const SizedBox(height: AppSpacing.sm),
        Text(
          ScamShieldStrings.t('ss_area_report_privacy', locale),
          style: AppTypography.caption.copyWith(
            color: AppColors.textTertiary,
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }
}
