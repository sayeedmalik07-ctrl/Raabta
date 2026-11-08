import 'package:flutter/material.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/l10n/common_action_strings.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/widgets/hub/hub_detail_action_bar.dart';
import 'package:raabta/data/models/business_listing.dart';
import 'package:raabta/features/business/domain/business_contact_mode.dart';
import 'package:raabta/features/business/presentation/l10n/business_appointment_strings.dart';
import 'package:raabta/features/business/presentation/l10n/business_quote_strings.dart';
import 'package:raabta/screens/businesses/l10n/businesses_strings.dart';
/// Bottom scroll padding so content clears the sticky [HubDetailActionBar].
double businessDetailActionBarScrollInset(BuildContext context) {
  const barHeight = 48.0;
  const verticalPadding = AppSpacing.md * 2;
  return barHeight + verticalPadding + MediaQuery.paddingOf(context).bottom;
}

class BusinessListingDetailSheetHandle extends StatelessWidget {
  const BusinessListingDetailSheetHandle({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 40,
        height: 4,
        decoration: BoxDecoration(
          color: AppColors.textSecondary.withValues(alpha: 0.4),
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }
}

class BusinessListingDetailSheetScaffold extends StatelessWidget {
  const BusinessListingDetailSheetScaffold({
    super.key,
    required this.scrollController,
    required this.body,
    required this.actionBar,
  });

  final ScrollController scrollController;
  final Widget body;
  final Widget actionBar;

  static const scaffoldKey = Key('business_detail_sheet_scaffold');
  static const scrollKey = Key('business_detail_sheet_scroll');

  @override
  Widget build(BuildContext context) {
    final bottomPadding =
        16 + businessDetailActionBarScrollInset(context) + MediaQuery.viewInsetsOf(context).bottom;

    return Column(
      key: scaffoldKey,
      children: [
        Expanded(
          child: ListView(
            key: scrollKey,
            controller: scrollController,
            padding: EdgeInsets.fromLTRB(20, 16, 20, bottomPadding),
            children: [
              const BusinessListingDetailSheetHandle(),
              const SizedBox(height: 16),
              body,
            ],
          ),
        ),
        actionBar,
      ],
    );
  }
}

class BusinessListingDetailActionBar extends StatelessWidget {
  const BusinessListingDetailActionBar({
    super.key,
    required this.business,
    required this.locale,
    required this.isSaved,
    required this.isOwner,
    required this.showStructuredCta,
    required this.onSave,
    required this.onShare,
    required this.onStructuredPrimary,
    required this.onMessage,
  });

  final BusinessListing business;
  final String locale;
  final bool isSaved;
  final bool isOwner;
  final bool showStructuredCta;
  final VoidCallback onSave;
  final VoidCallback onShare;
  final VoidCallback onStructuredPrimary;
  final VoidCallback onMessage;

  static const barKey = Key('business_detail_action_bar');

  String _structuredLabel() {
    return switch (business.contactMode) {
      BusinessContactMode.appointment =>
        BusinessAppointmentStrings.t('biz_appt_cta', locale),
      BusinessContactMode.quote => BusinessQuoteStrings.t('biz_quote_cta', locale),
      BusinessContactMode.messageOnly => '',
    };
  }

  @override
  Widget build(BuildContext context) {
    final saveTooltip = isSaved
        ? CommonActionStrings.t('action_saved', locale)
        : CommonActionStrings.t('action_save', locale);
    final shareTooltip = CommonActionStrings.t('action_share', locale);

    String? primaryLabel;
    VoidCallback? onPrimary;
    String? secondaryLabel;
    VoidCallback? onSecondary;

    final messageLabel = BusinessesStrings.t('detail_message', locale);

    if (!isOwner) {
      if (showStructuredCta) {
        primaryLabel = _structuredLabel();
        onPrimary = onStructuredPrimary;
        secondaryLabel = messageLabel;
        onSecondary = onMessage;
      } else {
        primaryLabel = messageLabel;
        onPrimary = onMessage;
      }
    }

    return KeyedSubtree(
      key: barKey,
      child: HubDetailActionBar(
        primaryLabel: primaryLabel,
        onPrimary: onPrimary == null
            ? null
            : () {
                onPrimary!();
              },
        secondaryLabel: secondaryLabel,
        onSecondary: onSecondary == null
            ? null
            : () {
                onSecondary!();
              },
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
