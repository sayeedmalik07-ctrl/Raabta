import 'package:flutter/material.dart';
import 'package:raabta/screens/businesses/widgets/business_moci_cr_verification_card.dart';

/// Trust guidance on Business listing detail — registration verification today;
/// Business Track Record UI can be composed here when wired (backend exists separately).
class BusinessListingTrustSection extends StatelessWidget {
  const BusinessListingTrustSection({super.key, required this.locale});

  final String locale;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        BusinessMociCrVerificationCard(locale: locale),
        // Business Track Record card (API: /api/business-track-record) — separate feature;
        // add below when Flutter UI ships; do not duplicate server aggregation here.
      ],
    );
  }
}
