import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/widgets/glass_primary_button.dart';
import 'package:raabta/features/civic_report/domain/civic_channel.dart';
import 'package:raabta/features/civic_report/presentation/l10n/civic_report_strings.dart';

/// Renders only validator-enabled contact actions for a civic channel.
class CivicReportChannelActions extends StatelessWidget {
  const CivicReportChannelActions({
    super.key,
    required this.channel,
    required this.locale,
  });

  final CivicChannel channel;
  final String locale;

  @override
  Widget build(BuildContext context) {
    final children = <Widget>[];

    final web = channel.actionableWebsiteUrl;
    if (web != null) {
      children.add(
        GlassPrimaryButton(
          label: CivicReportStrings.t('civic_action_open_website', locale),
          onPressed: () => _openHttps(web),
        ),
      );
    }

    final phone = channel.actionablePhone;
    if (phone != null) {
      children.add(
        GlassPrimaryButton(
          label: CivicReportStrings.t('civic_action_call', locale),
          onPressed: () => launchUrl(Uri.parse('tel:$phone')),
        ),
      );
    }

    final ios = channel.actionableIosStoreUrl;
    if (ios != null) {
      children.add(
        GlassPrimaryButton(
          label: CivicReportStrings.t('civic_action_open_ios_app', locale),
          onPressed: () => _openHttps(ios),
        ),
      );
    }

    final android = channel.actionableAndroidStoreUrl;
    if (android != null) {
      children.add(
        GlassPrimaryButton(
          label: CivicReportStrings.t('civic_action_open_android_app', locale),
          onPressed: () => _openHttps(android),
        ),
      );
    }

    final route = channel.actionableRaabtaRoute;
    if (route != null) {
      children.add(
        GlassPrimaryButton(
          label: CivicReportStrings.t('civic_action_continue', locale),
          onPressed: () => context.push(route),
        ),
      );
    }

    if (children.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < children.length; i++) ...[
          if (i > 0) const SizedBox(height: AppSpacing.sm),
          children[i],
        ],
      ],
    );
  }

  Future<void> _openHttps(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}
