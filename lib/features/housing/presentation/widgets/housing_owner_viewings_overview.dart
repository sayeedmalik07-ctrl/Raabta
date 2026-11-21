import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/glass/glass_card.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/features/housing/domain/housing_viewing_request.dart';
import 'package:raabta/features/housing/presentation/l10n/housing_viewing_strings.dart';
import 'package:raabta/features/housing/providers/housing_viewing_providers.dart';
import 'package:raabta/features/housing/services/housing_viewing_reminder_service.dart';

class HousingOwnerViewingsOverview extends ConsumerWidget {
  const HousingOwnerViewingsOverview({
    super.key,
    required this.ownerId,
    required this.locale,
  });

  final String ownerId;
  final String locale;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final requestsAsync = ref.watch(housingOwnerViewingsProvider(ownerId));

    return requestsAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
      data: (requests) {
        final relevant = requests
            .where(
              (r) =>
                  r.status == HousingViewingStatus.pending ||
                  r.status == HousingViewingStatus.confirmed ||
                  r.status == HousingViewingStatus.awaitingViewer,
            )
            .toList();
        if (relevant.isEmpty) {
          return GlassCard(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Text(
              HousingViewingStrings.t('hv_owner_overview_empty', locale),
              style: AppTypography.caption,
            ),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              HousingViewingStrings.t('hv_owner_overview_title', locale),
              style: AppTypography.title,
            ),
            const SizedBox(height: AppSpacing.sm),
            for (final request in relevant)
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: GlassCard(
                  onTap: () =>
                      context.push('/housing/listing/${request.listingId}'),
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              request.status == HousingViewingStatus.confirmed
                                  ? HousingViewingReminderService.formatSlot(
                                      request.confirmedAt!,
                                      locale,
                                    )
                                  : HousingViewingReminderService.summarizeSlots(
                                      request.proposedSlots,
                                      locale,
                                    ),
                              style: AppTypography.subtitle.copyWith(
                                color: AppColors.cyanGlow,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.xs),
                            Text(
                              _statusLabel(request.status, locale),
                              style: AppTypography.caption,
                            ),
                          ],
                        ),
                      ),
                      Icon(Icons.chevron_right, color: AppColors.textTertiary),
                    ],
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  String _statusLabel(HousingViewingStatus status, String locale) {
    return switch (status) {
      HousingViewingStatus.confirmed =>
        HousingViewingStrings.t('hv_status_confirmed', locale),
      HousingViewingStatus.pending ||
      HousingViewingStatus.awaitingViewer =>
        HousingViewingStrings.t('hv_status_pending', locale),
      _ => '',
    };
  }
}
