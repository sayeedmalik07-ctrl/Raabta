import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/features/eosb/presentation/l10n/eosb_strings.dart';
import 'package:raabta/features/legal_sources/data/legal_sources_seed_catalog.dart';
import 'package:raabta/features/legal_sources/providers/legal_sources_providers.dart';

/// Shows when labour-law knowledge was last verified (from `legal_sources`).
class LegalFreshnessIndicator extends ConsumerWidget {
  const LegalFreshnessIndicator({super.key, required this.locale});

  final String locale;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncDate = ref.watch(lastLegalUpdateProvider);

    return asyncDate.when(
      loading: () => _chip(
        EosbStrings.t('eosb_legal_freshness_loading', locale),
      ),
      error: (_, _) => _chip(
        EosbStrings.t('eosb_legal_freshness', locale).replaceAll(
          '{date}',
          LegalSourcesSeedCatalog.seedLatestVerifiedDisplay,
        ),
      ),
      data: (date) => _chip(
        EosbStrings.t('eosb_legal_freshness', locale).replaceAll(
          '{date}',
          DateFormat.yMMMd().format(date),
        ),
      ),
    );
  }

  Widget _chip(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        children: [
          Icon(Icons.verified_outlined, size: 16, color: AppColors.cyanGlow),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              text,
              style: AppTypography.caption.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
