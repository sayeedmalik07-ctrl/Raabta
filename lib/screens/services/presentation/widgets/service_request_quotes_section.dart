import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:raabta/config/compliance_flags_gate.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/design/app_radius.dart';
import 'package:raabta/core/glass/glass_card.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/core/widgets/glass_primary_button.dart';
import 'package:raabta/core/widgets/hub/hub_notice_banner.dart';
import 'package:raabta/screens/services/domain/service_quote.dart';
import 'package:raabta/screens/services/l10n/service_quote_strings.dart';
import 'package:raabta/screens/services/models/service_listing.dart';
import 'package:raabta/screens/services/providers/service_listings_providers.dart';
import 'package:raabta/features/scam_shield/forewarnings/forewarning_moment_id.dart';
import 'package:raabta/features/scam_shield/presentation/widgets/forewarning_slot.dart';
import 'package:raabta/screens/services/providers/service_quote_providers.dart';

class ServiceRequestQuotesSection extends ConsumerWidget {
  const ServiceRequestQuotesSection({
    super.key,
    required this.listing,
    required this.locale,
    required this.isCustomerOwner,
    required this.isProviderViewer,
  });

  final ServiceListing listing;
  final String locale;
  final bool isCustomerOwner;
  final bool isProviderViewer;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!listing.isRequest) return const SizedBox.shrink();
    if (!ComplianceFlagsGate.current.quotesEnabled) {
      return const SizedBox.shrink();
    }

    final quotesAsync = ref.watch(serviceRequestQuotesProvider(listing.id));
    return quotesAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
      data: (quotes) {
        if (isCustomerOwner) {
          return _CustomerQuotesPanel(
            listing: listing,
            quotes: quotes,
            locale: locale,
          );
        }
        if (isProviderViewer) {
          return _ProviderQuotePanel(
            listing: listing,
            quotes: quotes,
            locale: locale,
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}

class _CustomerQuotesPanel extends ConsumerWidget {
  const _CustomerQuotesPanel({
    required this.listing,
    required this.quotes,
    required this.locale,
  });

  final ServiceListing listing;
  final List<ServiceQuote> quotes;
  final String locale;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (quotes.isEmpty) return const SizedBox.shrink();

    final selectedId = listing.selectedQuoteProviderId;
    final canSelect = listing.acceptsQuotes && selectedId == null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          ServiceQuoteStrings.t('svc_quotes_section_title', locale),
          style: AppTypography.subtitle,
        ),
        if (canSelect) ...[
          const SizedBox(height: AppSpacing.sm),
          ForewarningSlot(
            momentId: ForewarningMomentId.serviceQuoteAdvance,
            locale: locale,
          ),
        ],
        const SizedBox(height: AppSpacing.xs),
        Text(
          ServiceQuoteStrings.format(
            'svc_quotes_count',
            locale,
            params: {'count': '${quotes.length}'},
          ),
          style: AppTypography.caption.copyWith(color: AppColors.textTertiary),
        ),
        const SizedBox(height: AppSpacing.sm),
        HubNoticeBanner(
          text: ServiceQuoteStrings.t('svc_quote_inflation_note', locale),
        ),
        const SizedBox(height: AppSpacing.md),
        for (final quote in quotes)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: GlassCard(
              padding: const EdgeInsets.all(AppSpacing.md),
              borderRadius: AppRadius.lg,
              glowColor: AppColors.brandFamilyMain,
              glowIntensity: 0.06,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(quote.providerName, style: AppTypography.subtitle),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    ServiceQuoteStrings.format(
                      'svc_quote_price_line',
                      locale,
                      params: {'price': quote.price.toStringAsFixed(0)},
                    ),
                    style: AppTypography.title.copyWith(
                      color: AppColors.brandFamilyMain,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    ServiceQuoteStrings.format(
                      'svc_quote_included_line',
                      locale,
                      params: {'text': quote.includedDescription},
                    ),
                    style: AppTypography.bodySmall,
                  ),
                  if (quote.priceChangeNote != null &&
                      quote.priceChangeNote!.trim().isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      ServiceQuoteStrings.format(
                        'svc_quote_caveat_line',
                        locale,
                        params: {'text': quote.priceChangeNote!.trim()},
                      ),
                      style: AppTypography.caption.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                  const SizedBox(height: AppSpacing.md),
                  if (quote.providerId == selectedId ||
                      quote.status == ServiceQuoteStatus.selected)
                    Text(
                      ServiceQuoteStrings.t('svc_quote_selected', locale),
                      style: AppTypography.button.copyWith(
                        color: AppColors.brandFamilyMain,
                      ),
                    )
                  else if (canSelect)
                    GlassPrimaryButton(
                      label: ServiceQuoteStrings.t('svc_quote_select', locale),
                      expand: true,
                      onPressed: () => _selectQuote(context, ref, quote),
                    ),
                  if (quote.providerId == selectedId ||
                      quote.status == ServiceQuoteStatus.selected) ...[
                    const SizedBox(height: AppSpacing.sm),
                    GlassPrimaryButton(
                      label: ServiceQuoteStrings.t('svc_open_chat', locale),
                      expand: true,
                      icon: Icons.chat_bubble_outline,
                      onPressed: () => context.push(
                        '/services/listing/${listing.id}/chat/${quote.providerId}',
                        extra: listing.displayTitle,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        if (!listing.acceptsQuotes && selectedId != null)
          Padding(
            padding: const EdgeInsets.only(top: AppSpacing.xs),
            child: Text(
              ServiceQuoteStrings.t('svc_quote_closed', locale),
              style: AppTypography.caption.copyWith(
                color: AppColors.textTertiary,
              ),
            ),
          ),
      ],
    );
  }

  Future<void> _selectQuote(
    BuildContext context,
    WidgetRef ref,
    ServiceQuote quote,
  ) async {
    final ok = await ref.read(serviceQuoteRepositoryProvider).selectQuote(
          requestListingId: listing.id,
          quote: quote,
          requestTitle: listing.displayTitle,
          locale: locale,
        );
    if (!context.mounted) return;
    if (ok) {
      ref.invalidate(serviceListingDetailProvider(listing.id));
    }
  }
}

class _ProviderQuotePanel extends StatelessWidget {
  const _ProviderQuotePanel({
    required this.listing,
    required this.quotes,
    required this.locale,
  });

  final ServiceListing listing;
  final List<ServiceQuote> quotes;
  final String locale;

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return const SizedBox.shrink();

    final mine = quotes.where((q) => q.providerId == uid).toList();
    if (mine.isNotEmpty) {
      final quote = mine.first;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            ServiceQuoteStrings.t('svc_already_quoted', locale),
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          GlassCard(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  ServiceQuoteStrings.format(
                    'svc_quote_price_line',
                    locale,
                    params: {'price': quote.price.toStringAsFixed(0)},
                  ),
                  style: AppTypography.title.copyWith(
                    color: AppColors.brandFamilyMain,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  ServiceQuoteStrings.format(
                    'svc_quote_included_line',
                    locale,
                    params: {'text': quote.includedDescription},
                  ),
                  style: AppTypography.bodySmall,
                ),
              ],
            ),
          ),
          if (listing.selectedQuoteProviderId == uid ||
              quote.status == ServiceQuoteStatus.selected) ...[
            const SizedBox(height: AppSpacing.sm),
            GlassPrimaryButton(
              label: ServiceQuoteStrings.t('svc_open_chat', locale),
              expand: true,
              icon: Icons.chat_bubble_outline,
              onPressed: () => context.push(
                '/services/listing/${listing.id}/chat/$uid',
                extra: listing.displayTitle,
              ),
            ),
          ],
        ],
      );
    }

    if (!listing.acceptsQuotes) {
      return Padding(
        padding: const EdgeInsets.only(bottom: AppSpacing.md),
        child: Text(
          ServiceQuoteStrings.t('svc_quote_closed', locale),
          style: AppTypography.caption.copyWith(color: AppColors.textSecondary),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Text(
        ServiceQuoteStrings.t('svc_submit_quote_hint', locale),
        style: AppTypography.bodySmall.copyWith(
          color: AppColors.textSecondary,
        ),
      ),
    );
  }
}
