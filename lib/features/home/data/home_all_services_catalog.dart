import 'package:flutter/material.dart';
import 'package:raabta/core/l10n/app_shell_strings.dart';
import 'package:raabta/core/l10n/raabta_capability_strings.dart';

/// Classifieds and money hubs listed on [HomeAllServicesScreen] (not Documents).
class HomeAllServiceEntry {
  const HomeAllServiceEntry({
    required this.route,
    required this.icon,
    required this.titleKey,
    required this.subtitleKey,
    this.useCapabilityName = false,
    this.useCapabilitySubtitle = false,
  });

  final String route;
  final IconData icon;
  final String titleKey;
  final String subtitleKey;
  final bool useCapabilityName;
  final bool useCapabilitySubtitle;
}

const kHomeAllServiceEntries = <HomeAllServiceEntry>[
  HomeAllServiceEntry(
    route: '/housing',
    icon: Icons.home_outlined,
    titleKey: 'home_feat_housing',
    subtitleKey: 'home_feat_housing_sub',
  ),
  HomeAllServiceEntry(
    route: '/jobs',
    icon: Icons.work_outline_rounded,
    titleKey: 'home_feat_jobs',
    subtitleKey: 'home_feat_jobs_sub',
  ),
  HomeAllServiceEntry(
    route: '/marketplace',
    icon: Icons.shopping_bag_outlined,
    titleKey: 'cap_marketplace_name',
    subtitleKey: 'cap_marketplace_desc',
    useCapabilityName: true,
    useCapabilitySubtitle: true,
  ),
  HomeAllServiceEntry(
    route: '/businesses',
    icon: Icons.storefront_outlined,
    titleKey: 'home_feat_businesses',
    subtitleKey: 'home_feat_businesses_sub',
  ),
  HomeAllServiceEntry(
    route: '/services',
    icon: Icons.handyman_outlined,
    titleKey: 'home_feat_services',
    subtitleKey: 'home_feat_services_sub',
  ),
  HomeAllServiceEntry(
    route: '/money',
    icon: Icons.account_balance_wallet_outlined,
    titleKey: 'home_feat_money',
    subtitleKey: 'home_feat_money_sub',
  ),
];

String homeAllServiceTitle(HomeAllServiceEntry entry, String locale) {
  if (entry.useCapabilityName) {
    return RaabtaCapabilityStrings.t(entry.titleKey, locale);
  }
  return AppShellStrings.t(entry.titleKey, locale);
}

String homeAllServiceSubtitle(HomeAllServiceEntry entry, String locale) {
  if (entry.useCapabilitySubtitle) {
    return RaabtaCapabilityStrings.t(entry.subtitleKey, locale);
  }
  return AppShellStrings.t(entry.subtitleKey, locale);
}