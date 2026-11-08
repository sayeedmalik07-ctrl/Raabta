import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/glass/glass_card.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/core/widgets/glass_primary_button.dart';
import 'package:raabta/features/eosb/domain/models/eosb_result.dart';
import 'package:raabta/features/eosb/providers/eosb_providers.dart';
import 'package:raabta/features/leaving_qatar/presentation/l10n/leaving_qatar_strings.dart';
import 'package:url_launcher/url_launcher.dart';

/// Surfaces latest EOSB entitlement by reusing saved history — no duplicate math.
class LeavingQatarEosbCard extends ConsumerWidget {
  const LeavingQatarEosbCard({super.key, required this.locale});

  final String locale;

  Future<void> _openLatestResult(
    BuildContext context,
    WidgetRef ref,
    CalculationHistoryEntry entry,
  ) async {
    ref.read(eosbProvider.notifier).updateInput(entry.input);
    await ref.read(eosbProvider.notifier).calculate(saveHistory: false);
    if (context.mounted) context.push('/eosb/result');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(eosbHistoryProvider);
    final liveResult = ref.watch(eosbProvider).result;

    return historyAsync.when(
      loading: () => const SizedBox(
        height: 48,
        child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
      ),
      error: (_, __) => _buildPrompt(context, ref, null),
      data: (history) {
        CalculationHistoryEntry? latest;
        if (history.isNotEmpty) {
          latest = history.reduce(
            (a, b) => a.savedAt.isAfter(b.savedAt) ? a : b,
          );
        }
        final result = liveResult ?? latest?.result;
        if (result != null && latest != null) {
          return _buildWithResult(context, ref, latest, result);
        }
        if (result != null) {
          return _buildWithLiveOnly(context, ref, result);
        }
        return _buildPrompt(context, ref, null);
      },
    );
  }

  Widget _buildWithResult(
    BuildContext context,
    WidgetRef ref,
    CalculationHistoryEntry entry,
    EosbResult result,
  ) {
    final amount = NumberFormat('#,##0').format(result.totalEntitlement.round());
    return GlassCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      glowColor: AppColors.purpleGlow,
      glowIntensity: 0.12,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            LeavingQatarStrings.t('lq_eosb_heading', locale),
            style: AppTypography.subtitle.copyWith(color: AppColors.purpleGlow),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            LeavingQatarStrings.t('lq_eosb_body', locale),
            style: AppTypography.bodySmall,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            LeavingQatarStrings.tf('lq_eosb_has_calc', locale, {
              'amount': amount,
            }),
            style: AppTypography.subtitle,
          ),
          const SizedBox(height: AppSpacing.md),
          GlassPrimaryButton(
            label: LeavingQatarStrings.t('lq_eosb_view', locale),
            onPressed: () => _openLatestResult(context, ref, entry),
          ),
        ],
      ),
    );
  }

  Widget _buildWithLiveOnly(BuildContext context, WidgetRef ref, EosbResult result) {
    final amount = NumberFormat('#,##0').format(result.totalEntitlement.round());
    return GlassCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      glowColor: AppColors.purpleGlow,
      glowIntensity: 0.12,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            LeavingQatarStrings.t('lq_eosb_heading', locale),
            style: AppTypography.subtitle.copyWith(color: AppColors.purpleGlow),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            LeavingQatarStrings.tf('lq_eosb_has_calc', locale, {
              'amount': amount,
            }),
            style: AppTypography.subtitle,
          ),
          const SizedBox(height: AppSpacing.md),
          GlassPrimaryButton(
            label: LeavingQatarStrings.t('lq_eosb_view', locale),
            onPressed: () => context.push('/eosb/result'),
          ),
        ],
      ),
    );
  }

  Widget _buildPrompt(
    BuildContext context,
    WidgetRef ref,
    CalculationHistoryEntry? _,
  ) {
    return GlassCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      glowColor: AppColors.purpleGlow,
      glowIntensity: 0.1,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            LeavingQatarStrings.t('lq_eosb_heading', locale),
            style: AppTypography.subtitle.copyWith(color: AppColors.purpleGlow),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            LeavingQatarStrings.t('lq_eosb_none', locale),
            style: AppTypography.bodySmall,
          ),
          const SizedBox(height: AppSpacing.md),
          GlassPrimaryButton(
            label: LeavingQatarStrings.t('lq_eosb_run', locale),
            onPressed: () => context.push('/eosb/employee-info'),
          ),
        ],
      ),
    );
  }
}

Future<void> openLeavingQatarOfficialLink(String url) async {
  final uri = Uri.tryParse(url);
  if (uri == null) return;
  if (await canLaunchUrl(uri)) {
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}
