import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/glass/glass_card.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/core/widgets/glass_screen_scaffold.dart';
import 'package:raabta/features/daily_utilities/driving/domain/qatar_traffic_fees.dart';
import 'package:raabta/features/daily_utilities/driving/widgets/unpaid_fines_banner.dart';

enum _CalculatorPath { license, istimara, reference }

class DrivingFeeCalculatorScreen extends ConsumerStatefulWidget {
  const DrivingFeeCalculatorScreen({super.key});

  @override
  ConsumerState<DrivingFeeCalculatorScreen> createState() =>
      _DrivingFeeCalculatorScreenState();
}

class _DrivingFeeCalculatorScreenState
    extends ConsumerState<DrivingFeeCalculatorScreen> {
  _CalculatorPath _path = _CalculatorPath.license;
  QatarCitizenStatus _citizen = QatarCitizenStatus.expat;
  VehicleCategory _vehicle = VehicleCategory.privateCar;

  @override
  Widget build(BuildContext context) {
    return GlassScreenScaffold(
      title: 'Traffic Fee Calculator',
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const UnpaidFinesBanner(),
            Text(
              'Reference calculator only — confirm fees on MOI portal. Last verified: ${QatarTrafficFees.lastVerified}.',
              style: AppTypography.caption.copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 12),
            SegmentedButton<_CalculatorPath>(
              segments: const [
                ButtonSegment(
                  value: _CalculatorPath.license,
                  label: Text('Licence', style: TextStyle(fontSize: 11)),
                ),
                ButtonSegment(
                  value: _CalculatorPath.istimara,
                  label: Text('Istimara', style: TextStyle(fontSize: 11)),
                ),
                ButtonSegment(
                  value: _CalculatorPath.reference,
                  label: Text('Penalties', style: TextStyle(fontSize: 11)),
                ),
              ],
              selected: {_path},
              onSelectionChanged: (s) => setState(() => _path = s.first),
            ),
            const SizedBox(height: 16),
            if (_path == _CalculatorPath.license) ...[
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Qatari citizen (10-year licence)'),
                subtitle: const Text('Off for expat — QAR 250 / 5 years'),
                value: _citizen == QatarCitizenStatus.qatariCitizen,
                activeTrackColor: AppColors.sharePurple,
                onChanged: (v) => setState(
                  () => _citizen = v
                      ? QatarCitizenStatus.qatariCitizen
                      : QatarCitizenStatus.expat,
                ),
              ),
              _ResultCard(estimate: QatarTrafficFees.licenseRenewal(_citizen)),
            ] else if (_path == _CalculatorPath.istimara) ...[
              DropdownButtonFormField<VehicleCategory>(
                initialValue: _vehicle,
                dropdownColor: AppColors.surfaceElevated,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(labelText: 'Vehicle type'),
                items: VehicleCategory.values
                    .map(
                      (v) => DropdownMenuItem(value: v, child: Text(v.label)),
                    )
                    .toList(),
                onChanged: (v) {
                  if (v != null) setState(() => _vehicle = v);
                },
              ),
              const SizedBox(height: 12),
              _IstimaraCard(estimate: QatarTrafficFees.istimaraRenewal(_vehicle)),
            ] else ...[
              _InfoBlock(
                title: 'Expired Istimara',
                body: QatarTrafficFees.expiredIstimaraPenalty,
              ),
              _InfoBlock(
                title: 'No valid Istimara',
                body: QatarTrafficFees.unregisteredVehiclePenalty,
              ),
              const SizedBox(height: 8),
              Text('Black points ladder', style: AppTypography.title.copyWith(fontSize: 14)),
              const SizedBox(height: 8),
              ...QatarTrafficFees.blackPointsLadder.map(
                (line) => Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('• ', style: TextStyle(color: AppColors.accentGold)),
                      Expanded(child: Text(line, style: AppTypography.bodySmall)),
                    ],
                  ),
                ),
              ),
            ],
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => context.push('/driving/fine-status'),
              child: const Text('How to check your actual fine balance →'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ResultCard extends StatelessWidget {
  const _ResultCard({required this.estimate});

  final LicenseRenewalEstimate estimate;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      glowColor: AppColors.sharePurple,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'QAR ${estimate.feeQar.toStringAsFixed(0)}',
            style: AppTypography.headline2.copyWith(
              color: AppColors.sharePurple,
              fontSize: 36,
            ),
          ),
          Text(
            '${estimate.validityYears}-year driving licence renewal',
            style: AppTypography.title.copyWith(fontSize: 14),
          ),
          const SizedBox(height: 12),
          ...estimate.notes.map(
            (n) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text('• $n', style: AppTypography.caption),
            ),
          ),
        ],
      ),
    );
  }
}

class _IstimaraCard extends StatelessWidget {
  const _IstimaraCard({required this.estimate});

  final IstimaraRenewalEstimate estimate;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      glowColor: AppColors.cyanGlow,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (estimate.feeNeedsConfirmation)
            Container(
              padding: const EdgeInsets.all(8),
              margin: const EdgeInsets.only(bottom: 10),
              decoration: BoxDecoration(
                color: AppColors.accentGold.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Fee amount not shown — confirm tiered fee for ${estimate.category.label} on MOI/Metrash before paying.',
                style: AppTypography.caption.copyWith(color: AppColors.accentGold),
              ),
            )
          else if (estimate.feeQar != null)
            Text(
              'QAR ${estimate.feeQar!.toStringAsFixed(0)}',
              style: AppTypography.headline2.copyWith(
                color: AppColors.cyanGlow,
                fontSize: 36,
              ),
            ),
          ...estimate.notes.map(
            (n) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text('• $n', style: AppTypography.caption),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoBlock extends StatelessWidget {
  const _InfoBlock({required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: GlassCard(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: AppTypography.title.copyWith(fontSize: 14)),
            const SizedBox(height: 4),
            Text(body, style: AppTypography.bodySmall),
          ],
        ),
      ),
    );
  }
}
