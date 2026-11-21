import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/l10n/app_shell_strings.dart';
import 'package:raabta/features/home/widgets/home_glance_anchor_shell.dart';
import 'package:raabta/features/home/widgets/home_icon_badge.dart';
import 'package:raabta/features/quick_actions/quick_actions_hub.dart';
import 'package:raabta/features/scam_shield/presentation/widgets/scam_shield_risk_banner.dart';
import 'package:raabta/features/scam_shield/providers/scam_shield_providers.dart';
import 'package:raabta/providers/visa_providers.dart';

/// Compact Home ScamShield glance card — green family calm, semantic elevated.
class HomeScamShieldAnchorCard extends ConsumerWidget {
  const HomeScamShieldAnchorCard({super.key, this.compact = false});

  final bool compact;

  static Color get _calmAccent => AppColors.greenFamilyMain;

  static String _calmTitle(String calmCopy) {
    const separator = ' · ';
    final index = calmCopy.indexOf(separator);
    if (index == -1) return calmCopy;
    return calmCopy.substring(index + separator.length).trim();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(userLanguageProvider);
    final alertAsync = ref.watch(scamShieldActiveAlertProvider);

    final elevated = alertAsync.maybeWhen(
      data: (state) => state.isElevated,
      orElse: () => false,
    );
    final severity = alertAsync.maybeWhen(
      data: (state) => state.displaySeverity,
      orElse: () => null,
    );
    final unacknowledgedCount = alertAsync.maybeWhen(
      data: (state) => state.unacknowledgedCount,
      orElse: () => 0,
    );

    final calmCopy = AppShellStrings.t('home_scam_shield_status_calm', locale);
    final alertTitle =
        AppShellStrings.t('home_scam_shield_status_alert', locale);
    final reviewLabel = AppShellStrings.t('home_scam_shield_review', locale);

    final accentColor = elevated && severity != null
        ? scamShieldRiskColor(severity)
        : _calmAccent;

    final title = elevated
        ? alertTitle
        : compact
            ? AppShellStrings.t('home_scam_shield_glance_title', locale)
            : _calmTitle(calmCopy);
    final subtitle = elevated
        ? reviewLabel
        : compact
            ? (unacknowledgedCount > 0
                ? AppShellStrings.format(
                    'home_scam_shield_unacknowledged_alerts',
                    locale,
                    params: {'count': '$unacknowledgedCount'},
                  )
                : AppShellStrings.t('home_scam_shield_glance_sub', locale))
            : AppShellStrings.format(
                'home_scam_shield_unacknowledged_alerts',
                locale,
                params: {'count': '$unacknowledgedCount'},
              );

    final semanticsLabel = elevated
        ? '$alertTitle, $reviewLabel'
        : '$calmCopy, $subtitle';

    if (elevated) {
      return Semantics(
        button: true,
        label: semanticsLabel,
        child: ExcludeSemantics(
          child: HomeGlanceAnchorShell(
            familyMain: accentColor,
            icon: Icons.shield_outlined,
            iconVariant: HomeIconBadgeVariant.greenBrand,
            iconAccent: accentColor,
            title: title,
            subtitle: subtitle,
            onTap: () => QuickActionsHub.navigateTo(context, '/scam-shield'),
          ),
        ),
      );
    }

    return Semantics(
      button: true,
      label: semanticsLabel,
      child: ExcludeSemantics(
        child: HomeGlanceAnchorShell(
          familyMain: _calmAccent,
          icon: Icons.shield_outlined,
          iconVariant: HomeIconBadgeVariant.greenBrand,
          title: title,
          subtitle: subtitle,
          showLivePulse: false,
          denseSingleLine: compact,
          titleMaxLines: compact ? 1 : null,
          subtitleMaxLines: compact ? 2 : null,
          onTap: () => QuickActionsHub.navigateTo(context, '/scam-shield'),
        ),
      ),
    );
  }
}
