import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/glass/glass_card.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/core/widgets/negotiation_action_chips.dart';
import 'package:raabta/features/housing/domain/housing_viewing_request.dart';
import 'package:raabta/features/housing/presentation/l10n/housing_viewing_strings.dart';
import 'package:raabta/features/housing/presentation/widgets/housing_viewing_slot_picker.dart';
import 'package:raabta/features/housing/providers/housing_viewing_providers.dart';
import 'package:raabta/features/housing/services/housing_viewing_reminder_service.dart';
import 'package:raabta/core/l10n/classifieds_compliance_strings.dart';
import 'package:raabta/models/housing_models.dart';
import 'package:raabta/features/scam_shield/forewarnings/forewarning_moment_id.dart';
import 'package:raabta/features/scam_shield/presentation/widgets/forewarning_slot.dart';
import 'package:raabta/providers/compliance_flags_provider.dart';

class HousingListingViewingsSection extends ConsumerWidget {
  const HousingListingViewingsSection({
    super.key,
    required this.listing,
    required this.locale,
    required this.isOwner,
  });

  final HousingListing listing;
  final String locale;
  final bool isOwner;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewingsEnabled = ref.watch(complianceFlagsProvider).viewingsEnabled;
    final requestsAsync =
        ref.watch(housingListingViewingsProvider(listing.id));
    return requestsAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
      data: (requests) {
        if (!viewingsEnabled) {
          if (requests.isEmpty) return const SizedBox.shrink();
          return Padding(
            padding: const EdgeInsets.only(top: AppSpacing.lg),
            child: Text(
              ClassifiedsComplianceStrings.t('feature_unavailable', locale),
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          );
        }
        if (isOwner) {
          final pending = requests
              .where((r) => r.status == HousingViewingStatus.pending)
              .toList();
          if (pending.isEmpty) return const SizedBox.shrink();
          return _OwnerPendingPanel(
            listing: listing,
            requests: pending,
            locale: locale,
          );
        }

        final uid = FirebaseAuth.instance.currentUser?.uid;
        if (uid == null) return _RequestViewingButton(listing: listing, locale: locale);

        final mine = requests.where((r) => r.viewerId == uid).toList();
        if (mine.isEmpty) {
          return _RequestViewingButton(listing: listing, locale: locale);
        }

        final active = mine.firstWhere(
          (r) => r.status.isOpen,
          orElse: () => mine.first,
        );

        if (active.status.isOpen) {
          return _ViewerActiveCard(
            listing: listing,
            request: active,
            locale: locale,
          );
        }

        return _RequestViewingButton(listing: listing, locale: locale);
      },
    );
  }
}

class _RequestViewingButton extends StatelessWidget {
  const _RequestViewingButton({required this.listing, required this.locale});

  final HousingListing listing;
  final String locale;

  @override
  Widget build(BuildContext context) {
    if (listing.ownerUserId == null || listing.ownerUserId!.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      children: [
        ForewarningSlot(
          momentId: ForewarningMomentId.housingDepositViewing,
          locale: locale,
        ),
        GlassCard(
          onTap: () => context.push(
            '/housing/listing/${listing.id}/viewing',
            extra: {
              'ownerId': listing.ownerUserId!,
              'title': listing.title,
            },
          ),
          child: Text(
            HousingViewingStrings.t('hv_request_viewing', locale),
            style: AppTypography.button.copyWith(color: AppColors.cyanGlow),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
      ],
    );
  }
}

class _OwnerPendingPanel extends ConsumerWidget {
  const _OwnerPendingPanel({
    required this.listing,
    required this.requests,
    required this.locale,
  });

  final HousingListing listing;
  final List<HousingViewingRequest> requests;
  final String locale;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          HousingViewingStrings.format(
            'hv_seller_requests_count',
            locale,
            params: {'count': '${requests.length}'},
          ),
          style: AppTypography.subtitle,
        ),
        const SizedBox(height: AppSpacing.sm),
        for (final request in requests)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: GlassCard(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    HousingViewingReminderService.summarizeSlots(
                      request.proposedSlots,
                      locale,
                    ),
                    style: AppTypography.title.copyWith(color: AppColors.cyanGlow),
                  ),
                  if (request.note != null && request.note!.trim().isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.xs),
                    Text(request.note!, style: AppTypography.caption),
                  ],
                  const SizedBox(height: AppSpacing.sm),
                  NegotiationActionChips(
                    acceptLabel:
                        HousingViewingStrings.t('hv_action_confirm', locale),
                    declineLabel:
                        HousingViewingStrings.t('hv_action_decline', locale),
                    counterLabel: HousingViewingStrings.t(
                      'hv_action_propose_time',
                      locale,
                    ),
                    onAccept: () => _confirm(context, ref, request),
                    onDecline: () => ref
                        .read(housingViewingRepositoryProvider)
                        .ownerDecline(
                          request: request,
                          listingTitle: listing.title,
                          locale: locale,
                        ),
                    onCounter: () => _counter(context, ref, request),
                  ),
                ],
              ),
            ),
          ),
        const SizedBox(height: AppSpacing.sm),
      ],
    );
  }

  Future<void> _confirm(
    BuildContext context,
    WidgetRef ref,
    HousingViewingRequest request,
  ) async {
    final slot = await showHousingViewingSlotPickerDialog(
      context: context,
      locale: locale,
      slots: request.proposedSlots,
    );
    if (slot == null) return;
    await ref.read(housingViewingRepositoryProvider).ownerConfirm(
          request: request,
          slot: slot,
          listingTitle: listing.title,
          locale: locale,
        );
  }

  Future<void> _counter(
    BuildContext context,
    WidgetRef ref,
    HousingViewingRequest request,
  ) async {
    final controller = HousingViewingSlotPickerController();
    final submitted = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: AppSpacing.lg,
          right: AppSpacing.lg,
          top: AppSpacing.lg,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + AppSpacing.lg,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              HousingViewingStrings.t('hv_action_propose_time', locale),
              style: AppTypography.title,
            ),
            const SizedBox(height: AppSpacing.md),
            HousingViewingSlotPickerList(controller: controller, locale: locale),
            const SizedBox(height: AppSpacing.md),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(HousingViewingStrings.t('hv_submit_request', locale)),
            ),
          ],
        ),
      ),
    );
    if (submitted != true) return;
    final slots = controller.collectFutureSlots();
    if (slots.isEmpty) return;
    await ref.read(housingViewingRepositoryProvider).ownerCounter(
          request: request,
          counterSlots: slots,
          listingTitle: listing.title,
          locale: locale,
        );
  }
}

class _ViewerActiveCard extends ConsumerWidget {
  const _ViewerActiveCard({
    required this.listing,
    required this.request,
    required this.locale,
  });

  final HousingListing listing;
  final HousingViewingRequest request;
  final String locale;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statusKey = request.status == HousingViewingStatus.awaitingViewer
        ? 'hv_viewer_status_counter'
        : 'hv_viewer_status_pending';

    return Column(
      children: [
        GlassCard(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                HousingViewingReminderService.summarizeSlots(
                  request.proposedSlots,
                  locale,
                ),
                style: AppTypography.title.copyWith(color: AppColors.cyanGlow),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                HousingViewingStrings.t(statusKey, locale),
                style: AppTypography.caption,
              ),
              if (request.status == HousingViewingStatus.awaitingViewer) ...[
                const SizedBox(height: AppSpacing.sm),
                NegotiationActionChips(
                  acceptLabel:
                      HousingViewingStrings.t('hv_action_confirm', locale),
                  declineLabel:
                      HousingViewingStrings.t('hv_action_decline', locale),
                  onAccept: () async {
                    final slot = await showHousingViewingSlotPickerDialog(
                      context: context,
                      locale: locale,
                      slots: request.proposedSlots,
                    );
                    if (slot == null) return;
                    await ref
                        .read(housingViewingRepositoryProvider)
                        .viewerAcceptCounter(
                          request: request,
                          slot: slot,
                          listingTitle: listing.title,
                          locale: locale,
                        );
                  },
                  onDecline: () => ref
                      .read(housingViewingRepositoryProvider)
                      .viewerDeclineCounter(
                        request: request,
                        listingTitle: listing.title,
                        locale: locale,
                      ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
      ],
    );
  }
}
