import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/glass/glass_card.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/core/widgets/glass_screen_scaffold.dart';
import 'package:raabta/features/buying_car/presentation/l10n/buying_car_strings.dart';
import 'package:raabta/features/buying_car/presentation/widgets/buying_car_critical_callout.dart';
import 'package:raabta/features/consumer_protection/presentation/screens/consumer_complaint_screen.dart';
import 'package:raabta/features/consumer_protection/presentation/widgets/moci_consumer_complaint_card.dart';
import 'package:raabta/features/leaving_qatar/presentation/screens/leaving_qatar_screen.dart';
import 'package:raabta/providers/visa_providers.dart';

/// Static guide for buying a used car in Qatar — as-is private-sale warning lead.
class BuyingCarScreen extends ConsumerWidget {
  const BuyingCarScreen({super.key});

  static const route = '/buying-car-qatar';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(userLanguageProvider);

    return GlassScreenScaffold(
      title: BuyingCarStrings.t('bc_screen_title', locale),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => context.pop(),
      ),
      padding: const EdgeInsets.all(AppSpacing.lg),
      body: ListView(
        children: [
          BuyingCarCriticalCallout(locale: locale),
          const SizedBox(height: AppSpacing.md),
          GlassCard(
            padding: const EdgeInsets.all(AppSpacing.md),
            glowIntensity: 0.06,
            child: Text(
              BuyingCarStrings.t('bc_screen_intro', locale),
              style: AppTypography.bodySmall.copyWith(height: 1.45),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          _Section(
            titleKey: 'bc_dealer_title',
            locale: locale,
            children: [
              Text(
                BuyingCarStrings.t('bc_dealer_body', locale),
                style: AppTypography.bodySmall.copyWith(height: 1.45),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          _Section(
            titleKey: 'bc_before_title',
            locale: locale,
            children: [
              _Bullet(text: BuyingCarStrings.t('bc_before_metrash', locale)),
              _Bullet(text: BuyingCarStrings.t('bc_before_fines', locale)),
              const SizedBox(height: AppSpacing.sm),
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed: () => context.push(LeavingQatarScreen.route),
                  icon: const Icon(Icons.open_in_new_rounded, size: 16),
                  label: Text(
                    BuyingCarStrings.t('bc_fines_link_label', locale),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          _Section(
            titleKey: 'bc_transfer_title',
            locale: locale,
            children: [
              _Bullet(text: BuyingCarStrings.t('bc_transfer_together', locale)),
              _Bullet(text: BuyingCarStrings.t('bc_transfer_required', locale)),
              _Bullet(text: BuyingCarStrings.t('bc_transfer_fee', locale)),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          Text(
            BuyingCarStrings.t('bc_complaint_section_title', locale),
            style: AppTypography.subtitle.copyWith(color: AppColors.cyanGlow),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            BuyingCarStrings.t('bc_complaint_section_note', locale),
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textSecondary,
              height: 1.45,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          MociConsumerComplaintCard(
            locale: locale,
            showRegulatorContrast: true,
          ),
          const SizedBox(height: AppSpacing.sm),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => context.push(ConsumerComplaintScreen.route),
              icon: const Icon(Icons.open_in_new_rounded, size: 18),
              label: Text(
                BuyingCarStrings.t('bc_open_complaint_full', locale),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({
    required this.titleKey,
    required this.locale,
    required this.children,
  });

  final String titleKey;
  final String locale;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      glowIntensity: 0.06,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            BuyingCarStrings.t(titleKey, locale),
            style: AppTypography.subtitle.copyWith(fontSize: 14),
          ),
          const SizedBox(height: AppSpacing.md),
          ...children,
        ],
      ),
    );
  }
}

class _Bullet extends StatelessWidget {
  const _Bullet({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('•', style: AppTypography.bodySmall),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              text,
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textSecondary,
                height: 1.45,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
