import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/widgets/hub/hub_filter_chip.dart';
import 'package:raabta/core/widgets/hub/hub_layout_tokens.dart';
import 'package:raabta/screens/services/l10n/services_strings.dart';
import 'package:raabta/screens/services/models/service_listing.dart';
import 'package:raabta/screens/services/providers/service_listings_providers.dart';

/// Providers | Requests segment shared by Services hub landing and category browse.
class ServicesHubBrowseSegment extends ConsumerWidget {
  const ServicesHubBrowseSegment({super.key, required this.locale});

  final String locale;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final browseType = ref.watch(servicesBrowseListingTypeProvider);
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.sm, bottom: AppSpacing.sm),
      child: SizedBox(
        height: HubLayoutTokens.filterChipHeight,
        child: ListView(
          scrollDirection: Axis.horizontal,
          children: [
            KeyedSubtree(
              key: const Key('services_hub_segment_providers'),
              child: buildHubFilterChip(
                label: Text(ServicesStrings.t('hub_segment_providers', locale)),
                selected: browseType == ServiceListingType.provider,
                onSelected: (_) {
                  ref.read(servicesBrowseListingTypeProvider.notifier).state =
                      ServiceListingType.provider;
                },
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            KeyedSubtree(
              key: const Key('services_hub_segment_requests'),
              child: buildHubFilterChip(
                label: Text(ServicesStrings.t('hub_segment_requests', locale)),
                selected: browseType == ServiceListingType.request,
                onSelected: (_) {
                  ref.read(servicesBrowseListingTypeProvider.notifier).state =
                      ServiceListingType.request;
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
