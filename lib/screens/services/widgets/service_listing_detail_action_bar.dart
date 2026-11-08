import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:raabta/config/compliance_flags_gate.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/l10n/common_action_strings.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/widgets/hub/hub_detail_action_bar.dart';
import 'package:raabta/screens/services/l10n/service_quote_strings.dart';
import 'package:raabta/screens/services/l10n/services_strings.dart';
import 'package:raabta/providers/auth_providers.dart';
import 'package:raabta/screens/services/models/service_listing.dart';
import 'package:raabta/screens/services/providers/service_quote_providers.dart';
import 'package:raabta/screens/services/utils/service_listing_contact.dart';

/// Scroll padding above the sticky [HubDetailActionBar] on service detail.
double serviceDetailActionBarScrollInset(BuildContext context) {
  const barHeight = 48.0;
  const verticalPadding = AppSpacing.md * 2;
  return barHeight + verticalPadding + MediaQuery.paddingOf(context).bottom;
}

class ServiceListingDetailActionBar extends ConsumerWidget {
  const ServiceListingDetailActionBar({
    super.key,
    required this.listing,
    required this.locale,
    required this.isSaved,
    required this.isCustomerOwner,
    required this.isProviderViewer,
    required this.onSave,
    required this.onShare,
  });

  final ServiceListing listing;
  final String locale;
  final bool isSaved;
  final bool isCustomerOwner;
  final bool isProviderViewer;
  final VoidCallback onSave;
  final VoidCallback onShare;

  static const barKey = Key('service_detail_action_bar');

  void _message() {
    contactServiceProviderWhatsApp(
      phone: listing.phone,
      serviceTitle: listing.displayTitle,
      providerName: listing.providerName,
      isServiceRequest: listing.isRequest,
    );
  }

  void _call() {
    callServiceProvider(listing.phone);
  }

  void _openSubmitQuote(BuildContext context) {
    context.push(
      '/services/listing/${listing.id}/quote',
      extra: {
        'customerId': listing.userId,
        'title': listing.displayTitle,
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final saveTooltip = isSaved
        ? CommonActionStrings.t('action_saved', locale)
        : CommonActionStrings.t('action_save', locale);
    final shareTooltip = CommonActionStrings.t('action_share', locale);

    if (isCustomerOwner) {
      return KeyedSubtree(
        key: barKey,
        child: HubDetailActionBar(
          isSaved: isSaved,
          onSave: onSave,
          onShare: onShare,
          saveTooltip: saveTooltip,
          shareTooltip: shareTooltip,
          backgroundColor: AppColors.surface,
        ),
      );
    }

    final messageLabel = ServicesStrings.t('detail_message', locale);
    final callLabel = ServicesStrings.t('detail_call', locale);

    String? primaryLabel = messageLabel;
    VoidCallback? onPrimary = _message;
    String? secondaryLabel = callLabel;
    VoidCallback? onSecondary = _call;

    String? submitQuoteLabel;
    VoidCallback? onSubmitQuote;

    final quotesEnabled = ComplianceFlagsGate.current.quotesEnabled;
    if (quotesEnabled &&
        listing.isRequest &&
        isProviderViewer &&
        listing.acceptsQuotes) {
      final uid = ref.watch(currentUserProvider)?.uid;
      final quotes =
          ref.watch(serviceRequestQuotesProvider(listing.id)).valueOrNull ??
              const [];
      final alreadyQuoted =
          uid != null && quotes.any((q) => q.providerId == uid);
      if (!alreadyQuoted) {
        submitQuoteLabel = ServiceQuoteStrings.t('svc_submit_quote', locale);
        onSubmitQuote = () => _openSubmitQuote(context);
        secondaryLabel = submitQuoteLabel;
        onSecondary = onSubmitQuote;
      }
    }

    final hasPhone = listing.phone.trim().isNotEmpty;
    if (!hasPhone) {
      if (onSubmitQuote != null) {
        primaryLabel = submitQuoteLabel;
        onPrimary = onSubmitQuote;
      } else {
        primaryLabel = null;
        onPrimary = null;
      }
      secondaryLabel = null;
      onSecondary = null;
    }

    return KeyedSubtree(
      key: barKey,
      child: HubDetailActionBar(
        primaryLabel: primaryLabel,
        onPrimary: onPrimary,
        secondaryLabel: secondaryLabel,
        onSecondary: onSecondary,
        isSaved: isSaved,
        onSave: onSave,
        onShare: onShare,
        saveTooltip: saveTooltip,
        shareTooltip: shareTooltip,
        backgroundColor: AppColors.surface,
      ),
    );
  }
}
