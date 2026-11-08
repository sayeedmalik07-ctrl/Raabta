import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/features/referral/presentation/providers/referral_providers.dart';

/// Banner on EOSB entry when user arrived via a referral link.
class ReferralInviteBanner extends ConsumerWidget {
  const ReferralInviteBanner({super.key, required this.referralCode});

  final String referralCode;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncReferrer = ref.watch(referrerByCodeProvider(referralCode));

    return asyncReferrer.when(
      loading: () => const SizedBox.shrink(),
      error: (_, _) => _BannerBody(message: 'You were invited to check your Qatar EOSB'),
      data: (referrer) {
        if (referrer == null) {
          return _BannerBody(
            message: 'You were invited to check your Qatar EOSB',
          );
        }
        final name = referrer.displayName?.trim();
        final message = (referrer.allowNameInShares && name != null && name.isNotEmpty)
            ? 'Invited by $name — check your Qatar labour-law entitlement'
            : 'You were invited to check your Qatar EOSB';
        return _BannerBody(message: message);
      },
    );
  }
}

class _BannerBody extends StatelessWidget {
  const _BannerBody({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.cyanGlow.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        border: Border.all(color: AppColors.cyanGlow.withValues(alpha: 0.35)),
      ),
      child: Row(
        children: [
          const Icon(Icons.card_giftcard_outlined, color: AppColors.cyanGlow),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(message, style: AppTypography.bodySmall),
          ),
        ],
      ),
    );
  }
}
