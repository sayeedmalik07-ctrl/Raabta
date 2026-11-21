import 'package:flutter/material.dart';
import 'package:raabta/core/colors/app_colors.dart';

/// Home dashboard feed models — static navigation catalogs only.
class HomeFeatureCard {
  const HomeFeatureCard({
    required this.icon,
    required this.titleKey,
    required this.subtitleKey,
    required this.accentColor,
  });

  final IconData icon;
  final String titleKey;
  final String subtitleKey;
  final Color accentColor;
}

class HomeQuickAction {
  const HomeQuickAction({
    required this.icon,
    required this.labelKey,
    required this.color,
  });

  final IconData icon;
  final String labelKey;
  final Color color;
}

const List<HomeFeatureCard> kHomeFeatureCards = [
  HomeFeatureCard(
    icon: Icons.home_outlined,
    titleKey: 'home_feat_housing',
    subtitleKey: 'home_feat_housing_sub',
    accentColor: AppColors.blueGlow,
  ),
  HomeFeatureCard(
    icon: Icons.account_balance_wallet_outlined,
    titleKey: 'home_feat_money',
    subtitleKey: 'home_feat_money_sub',
    accentColor: AppColors.amberGlow,
  ),
  HomeFeatureCard(
    icon: Icons.description_outlined,
    titleKey: 'home_feat_visa',
    subtitleKey: 'home_feat_visa_sub',
    accentColor: AppColors.emeraldGlow,
  ),
  HomeFeatureCard(
    icon: Icons.work_outline_rounded,
    titleKey: 'home_feat_jobs',
    subtitleKey: 'home_feat_jobs_sub',
    accentColor: AppColors.cyanGlow,
  ),
  HomeFeatureCard(
    icon: Icons.handyman_outlined,
    titleKey: 'home_feat_services',
    subtitleKey: 'home_feat_services_sub',
    accentColor: AppColors.purpleGlow,
  ),
  HomeFeatureCard(
    icon: Icons.storefront_outlined,
    titleKey: 'home_feat_businesses',
    subtitleKey: 'home_feat_businesses_sub',
    accentColor: AppColors.accentGold,
  ),
];

const List<HomeQuickAction> kHomeQuickActions = [
  HomeQuickAction(
    icon: Icons.work_outline_rounded,
    labelKey: 'home_qa_post_job',
    color: AppColors.quickActionBlue,
  ),
  HomeQuickAction(
    icon: Icons.home_outlined,
    labelKey: 'home_qa_post_room',
    color: AppColors.quickActionGreen,
  ),
  HomeQuickAction(
    icon: Icons.shopping_bag_outlined,
    labelKey: 'home_qa_sell_item',
    color: AppColors.quickActionYellow,
  ),
  HomeQuickAction(
    icon: Icons.handyman_outlined,
    labelKey: 'home_qa_find_service',
    color: AppColors.quickActionIndigo,
  ),
  HomeQuickAction(
    icon: Icons.campaign_outlined,
    labelKey: 'home_qa_promote_business',
    color: AppColors.quickActionCyan,
  ),
];
