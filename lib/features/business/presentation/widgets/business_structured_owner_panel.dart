import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/glass/glass_card.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/data/models/business_listing.dart';
import 'package:raabta/features/business/domain/business_appointment_request.dart';
import 'package:raabta/features/business/domain/business_contact_mode.dart';
import 'package:raabta/features/business/domain/business_quote_request.dart';
import 'package:raabta/features/business/presentation/l10n/business_appointment_strings.dart';
import 'package:raabta/features/business/presentation/l10n/business_quote_strings.dart';
import 'package:raabta/features/business/presentation/widgets/business_appointment_slot_picker.dart';
import 'package:raabta/features/business/providers/business_structured_providers.dart';
import 'package:raabta/features/business/data/business_appointment_repository.dart';
import 'package:raabta/services/qr/listing_ownership.dart';

class BusinessStructuredOwnerPanel extends ConsumerWidget {
  const BusinessStructuredOwnerPanel({
    super.key,
    required this.business,
    required this.locale,
  });

  final BusinessListing business;
  final String locale;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!isListingOwnedByCurrentUser(business.ownerUserId)) {
      return const SizedBox.shrink();
    }

    return switch (business.contactMode) {
      BusinessContactMode.appointment => _AppointmentOwnerPanel(
          business: business,
          locale: locale,
        ),
      BusinessContactMode.quote => _QuoteOwnerPanel(
          business: business,
          locale: locale,
        ),
      BusinessContactMode.messageOnly => const SizedBox.shrink(),
    };
  }
}

class _AppointmentOwnerPanel extends ConsumerWidget {
  const _AppointmentOwnerPanel({required this.business, required this.locale});

  final BusinessListing business;
  final String locale;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final requestsAsync =
        ref.watch(businessAppointmentRequestsProvider(business.id));
    return requestsAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
      data: (requests) {
        final pending = requests
            .where((r) => r.status == BusinessAppointmentStatus.pending)
            .toList();
        if (pending.isEmpty) return const SizedBox.shrink();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              BusinessAppointmentStrings.t('biz_appt_section_title', locale),
              style: AppTypography.title,
            ),
            const SizedBox(height: AppSpacing.sm),
            ...pending.map(
              (request) => _AppointmentOwnerCard(
                business: business,
                request: request,
                locale: locale,
              ),
            ),
          ],
        );
      },
    );
  }
}

class _AppointmentOwnerCard extends ConsumerStatefulWidget {
  const _AppointmentOwnerCard({
    required this.business,
    required this.request,
    required this.locale,
  });

  final BusinessListing business;
  final BusinessAppointmentRequest request;
  final String locale;

  @override
  ConsumerState<_AppointmentOwnerCard> createState() =>
      _AppointmentOwnerCardState();
}

class _AppointmentOwnerCardState extends ConsumerState<_AppointmentOwnerCard> {
  bool _busy = false;

  Future<void> _confirm(DateTime slot) async {
    setState(() => _busy = true);
    await ref.read(businessAppointmentRepositoryProvider).ownerConfirm(
          request: widget.request,
          slot: slot,
          businessName: widget.business.name,
          locale: widget.locale,
        );
    if (mounted) setState(() => _busy = false);
  }

  Future<void> _decline() async {
    setState(() => _busy = true);
    await ref.read(businessAppointmentRepositoryProvider).ownerDecline(
          request: widget.request,
          businessName: widget.business.name,
          locale: widget.locale,
        );
    if (mounted) setState(() => _busy = false);
  }

  Future<void> _counter() async {
    final controller = BusinessAppointmentSlotPickerController();
    if (!mounted) return;
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 16,
            bottom: MediaQuery.viewInsetsOf(ctx).bottom + 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              BusinessAppointmentSlotPickerList(
                controller: controller,
                locale: widget.locale,
              ),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: () async {
                  final slots = controller.collectFutureSlots();
                  if (slots.isEmpty) return;
                  Navigator.pop(ctx);
                  setState(() => _busy = true);
                  await ref
                      .read(businessAppointmentRepositoryProvider)
                      .ownerCounter(
                        request: widget.request,
                        counterSlots: slots,
                        businessName: widget.business.name,
                        locale: widget.locale,
                      );
                  if (mounted) setState(() => _busy = false);
                },
                child: Text(
                  BusinessAppointmentStrings.t('biz_appt_counter', widget.locale),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final request = widget.request;
    final slots = request.proposedSlots;

    return GlassCard(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            BusinessAppointmentStrings.t('biz_appt_status_pending', widget.locale),
            style: AppTypography.subtitle,
          ),
          if (request.note != null) ...[
            const SizedBox(height: 4),
            Text(request.note!, style: AppTypography.bodySmall),
          ],
          const SizedBox(height: AppSpacing.sm),
          ...slots.map(
            (slot) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: OutlinedButton(
                onPressed: _busy ? null : () => _confirm(slot),
                child: Text(
                  BusinessAppointmentStringsHelper.formatSlot(slot, widget.locale),
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.sm,
            children: [
              TextButton(
                onPressed: _busy ? null : _decline,
                child: Text(
                  BusinessAppointmentStrings.t('biz_appt_decline', widget.locale),
                ),
              ),
              if (!request.hasOwnerCountered)
                TextButton(
                  onPressed: _busy ? null : _counter,
                  child: Text(
                    BusinessAppointmentStrings.t('biz_appt_counter', widget.locale),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _QuoteOwnerPanel extends ConsumerWidget {
  const _QuoteOwnerPanel({required this.business, required this.locale});

  final BusinessListing business;
  final String locale;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final requestsAsync = ref.watch(businessQuoteRequestsProvider(business.id));
    return requestsAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
      data: (requests) {
        final pending =
            requests.where((r) => r.status == BusinessQuoteStatus.pending).toList();
        if (pending.isEmpty) return const SizedBox.shrink();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              BusinessQuoteStrings.t('biz_quote_section_title', locale),
              style: AppTypography.title,
            ),
            const SizedBox(height: AppSpacing.sm),
            ...pending.map(
              (request) => _QuoteOwnerCard(
                business: business,
                request: request,
                locale: locale,
              ),
            ),
          ],
        );
      },
    );
  }
}

class _QuoteOwnerCard extends ConsumerStatefulWidget {
  const _QuoteOwnerCard({
    required this.business,
    required this.request,
    required this.locale,
  });

  final BusinessListing business;
  final BusinessQuoteRequest request;
  final String locale;

  @override
  ConsumerState<_QuoteOwnerCard> createState() => _QuoteOwnerCardState();
}

class _QuoteOwnerCardState extends ConsumerState<_QuoteOwnerCard> {
  final _priceController = TextEditingController();
  final _includedController = TextEditingController();
  bool _busy = false;

  @override
  void dispose() {
    _priceController.dispose();
    _includedController.dispose();
    super.dispose();
  }

  Future<void> _submitQuote() async {
    final price =
        double.tryParse(_priceController.text.replaceAll(',', '').trim());
    if (price == null || price <= 0 || _includedController.text.trim().isEmpty) {
      return;
    }
    setState(() => _busy = true);
    await ref.read(businessQuoteRepositoryProvider).ownerSubmitQuote(
          request: widget.request,
          price: price,
          description: _includedController.text.trim(),
          businessName: widget.business.name,
          locale: widget.locale,
        );
    if (mounted) setState(() => _busy = false);
  }

  Future<void> _decline() async {
    setState(() => _busy = true);
    await ref.read(businessQuoteRepositoryProvider).ownerDecline(
          request: widget.request,
          businessName: widget.business.name,
          locale: widget.locale,
        );
    if (mounted) setState(() => _busy = false);
  }

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(widget.request.description, style: AppTypography.body),
          if (widget.request.budgetQar != null) ...[
            const SizedBox(height: 4),
            Text(
              '${widget.request.budgetQar!.toStringAsFixed(0)} QAR',
              style: AppTypography.caption.copyWith(color: AppColors.cyanGlow),
            ),
          ],
          const SizedBox(height: AppSpacing.sm),
          TextField(
            controller: _priceController,
            decoration: InputDecoration(
              labelText: BusinessQuoteStrings.t('biz_quote_price_label', widget.locale),
            ),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _includedController,
            decoration: InputDecoration(
              labelText:
                  BusinessQuoteStrings.t('biz_quote_included_label', widget.locale),
            ),
            maxLines: 3,
          ),
          const SizedBox(height: AppSpacing.sm),
          FilledButton(
            onPressed: _busy ? null : _submitQuote,
            child: Text(
              BusinessQuoteStrings.t('biz_quote_response_title', widget.locale),
            ),
          ),
          TextButton(
            onPressed: _busy ? null : _decline,
            child: Text(
              BusinessQuoteStrings.t('biz_quote_status_declined', widget.locale),
            ),
          ),
        ],
      ),
    );
  }
}
