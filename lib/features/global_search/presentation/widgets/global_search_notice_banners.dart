import 'package:flutter/material.dart';
import 'package:raabta/core/l10n/app_shell_strings.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/widgets/hub/hub_notice_banner.dart';

/// Kit notice strip for Global Search connectivity / partial failures.
class GlobalSearchOfflineBanner extends StatelessWidget {
  const GlobalSearchOfflineBanner({super.key, required this.locale});

  final String locale;

  @override
  Widget build(BuildContext context) {
    final message = AppShellStrings.t('global_search_offline_banner', locale);
    return Semantics(
      liveRegion: true,
      label: message,
      child: HubNoticeBanner(text: message),
    );
  }
}

class GlobalSearchLocationUnavailableBanner extends StatelessWidget {
  const GlobalSearchLocationUnavailableBanner({super.key, required this.locale});

  final String locale;

  @override
  Widget build(BuildContext context) {
    final message =
        AppShellStrings.t('global_search_location_unavailable', locale);
    return Semantics(
      liveRegion: true,
      label: message,
      child: HubNoticeBanner(text: message),
    );
  }
}

class GlobalSearchSourcesUnavailableBanner extends StatelessWidget {
  const GlobalSearchSourcesUnavailableBanner({super.key, required this.locale});

  final String locale;

  @override
  Widget build(BuildContext context) {
    final message =
        AppShellStrings.t('global_search_sources_unavailable', locale);
    return Semantics(
      liveRegion: true,
      label: message,
      child: Padding(
        padding: const EdgeInsets.only(bottom: AppSpacing.sm),
        child: HubNoticeBanner(text: message),
      ),
    );
  }
}
