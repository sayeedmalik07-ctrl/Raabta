import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:raabta/core/background/animated_aurora_background.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/glass/glass_card.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/features/admin/providers/admin_providers.dart';
import 'package:raabta/features/admin/widgets/admin_widgets.dart';
import 'package:raabta/features/global_search/data/search_provider_registration.dart';
import 'package:raabta/features/global_search/domain/global_search_provider.dart';
import 'package:raabta/features/global_search/domain/search_coverage_checker.dart';
import 'package:raabta/services/drafts/draft_coverage_checker.dart';
import 'package:raabta/services/drafts/draft_form_registry.dart';

class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(adminDashboardStatsProvider);

    return AnimatedAuroraBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: const AdminAppBar(title: 'Admin Dashboard'),
        body: RefreshIndicator(
          color: AdminAppBar.adminAccent,
          onRefresh: () async {
            ref.invalidate(adminDashboardStatsProvider);
            await ref.read(adminDashboardStatsProvider.future);
          },
          child: statsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => ListView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              children: [
                Text('Failed to load stats: $e', style: AppTypography.body),
              ],
            ),
            data: (stats) => ListView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              children: [
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: AppSpacing.sm,
                  crossAxisSpacing: AppSpacing.sm,
                  childAspectRatio: 1.25,
                  children: [
                    AdminStatCard(
                      label: 'Total Users',
                      value: '${stats.totalUsers}',
                      subtitle:
                          '+${stats.newUsersToday} today · +${stats.newUsersThisWeek} week',
                      icon: Icons.people_outline,
                      onTap: () => context.push('/admin/users'),
                    ),
                    AdminStatCard(
                      label: 'Active (24h)',
                      value: '${stats.activeUsers24h}',
                      icon: Icons.online_prediction,
                      onTap: () => context.push('/admin/users'),
                    ),
                    AdminStatCard(
                      label: 'Business Listings',
                      value: '${stats.businessApproved}',
                      subtitle: '${stats.businessPending} pending',
                      icon: Icons.storefront_outlined,
                      onTap: () => context.push('/admin/moderation'),
                    ),
                    AdminStatCard(
                      label: 'Job Postings',
                      value: '${stats.jobsActive}',
                      subtitle: '${stats.jobsExpired} expired',
                      icon: Icons.work_outline,
                      onTap: () => context.push('/admin/moderation'),
                    ),
                    AdminStatCard(
                      label: 'Housing Listings',
                      value: '${stats.housingTotal}',
                      subtitle: '${stats.housingPending} pending',
                      icon: Icons.home_outlined,
                      onTap: () => context.push('/admin/moderation'),
                    ),
                    AdminStatCard(
                      label: 'Open Reports',
                      value: '${stats.openReports}',
                      icon: Icons.flag_outlined,
                      badgeCount: stats.openReports,
                      onTap: () => context.push('/admin/moderation'),
                    ),
                    AdminStatCard(
                      label: 'Revenue Snapshot',
                      value: '${stats.revenueEstimateQr} QR',
                      subtitle:
                          'Premium ${stats.premiumSubscribers} · Pro ${stats.proSubscribers}',
                      icon: Icons.payments_outlined,
                    ),
                    AdminStatCard(
                      label: 'AI Usage Today',
                      value: stats.aiLoggingAvailable
                          ? '${stats.aiCallsToday}'
                          : '—',
                      subtitle: stats.aiLoggingAvailable
                          ? 'Claude API calls'
                          : 'Logging unavailable',
                      icon: Icons.auto_awesome,
                      onTap: () => context.push('/admin/ai-usage'),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xl),
                const _SearchCoveragePanel(),
                const SizedBox(height: AppSpacing.xl),
                const _DraftCoveragePanel(),
                const SizedBox(height: AppSpacing.xl),
                Text('Quick Links', style: AppTypography.headline2),
                const SizedBox(height: AppSpacing.md),
                Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.sm,
                  children: [
                    _QuickLink(
                      label: 'Users',
                      route: '/admin/users',
                      icon: Icons.people,
                    ),
                    _QuickLink(
                      label: 'Moderation',
                      route: '/admin/moderation',
                      icon: Icons.gavel,
                      badgeCount: stats.openReports,
                    ),
                    _QuickLink(
                      label: 'Config',
                      route: '/admin/config',
                      icon: Icons.tune,
                    ),
                    _QuickLink(
                      label: 'AI Usage',
                      route: '/admin/ai-usage',
                      icon: Icons.insights,
                    ),
                    _QuickLink(
                      label: 'Legal Sources',
                      route: '/admin/legal-sources',
                      icon: Icons.gavel_outlined,
                    ),
                    _QuickLink(
                      label: 'ScamShield freshness',
                      route: '/admin/shield-freshness',
                      icon: Icons.shield_outlined,
                    ),
                    _QuickLink(
                      label: 'Legal Monitor',
                      route: '/admin/legal-change-monitor',
                      icon: Icons.radar_outlined,
                    ),
                    _QuickLink(
                      label: 'MOPH Insurers',
                      route: '/admin/moph-insurers',
                      icon: Icons.health_and_safety_outlined,
                    ),
                    _QuickLink(
                      label: 'Exchange Locator',
                      route: '/admin/exchange-locator',
                      icon: Icons.account_balance,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SearchCoveragePanel extends StatelessWidget {
  const _SearchCoveragePanel();

  @override
  Widget build(BuildContext context) {
    registerAllSearchProviders();
    final routes = SearchCoverageChecker.findUncoveredRoutes(
      GlobalSearchProviderRegistry.providers,
    );

    return GlassCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                routes.isEmpty ? Icons.check_circle : Icons.warning_amber,
                color: routes.isEmpty
                    ? AppColors.success
                    : AdminAppBar.adminAccent,
              ),
              const SizedBox(width: AppSpacing.xs),
              Text('Global Search Coverage', style: AppTypography.title),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            routes.isEmpty
                ? 'All expected routes have a registered search provider.'
                : '${routes.length} route(s) missing search provider registration:',
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          if (routes.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sm),
            for (final route in routes)
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.xxs),
                child: Text(
                  '• $route',
                  style: AppTypography.bodySmall.copyWith(
                    fontFamily: 'monospace',
                  ),
                ),
              ),
          ],
        ],
      ),
    );
  }
}

class _DraftCoveragePanel extends StatelessWidget {
  const _DraftCoveragePanel();

  @override
  Widget build(BuildContext context) {
    registerAllDraftableForms();
    final unprotected = DraftCoverageChecker.findUnprotectedForms();

    return GlassCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                unprotected.isEmpty ? Icons.check_circle : Icons.warning_amber,
                color: unprotected.isEmpty
                    ? AppColors.success
                    : AdminAppBar.adminAccent,
              ),
              const SizedBox(width: AppSpacing.xs),
              Text('Draft Protection Coverage', style: AppTypography.title),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            unprotected.isEmpty
                ? 'All catalogued multi-field forms have draft protection.'
                : '${unprotected.length} form(s) missing draft protection:',
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          if (unprotected.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sm),
            for (final form in unprotected)
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.xxs),
                child: Text(
                  '• ${form.label} (${form.entryRoute})',
                  style: AppTypography.bodySmall,
                ),
              ),
          ],
        ],
      ),
    );
  }
}

class _QuickLink extends StatelessWidget {
  const _QuickLink({
    required this.label,
    required this.route,
    required this.icon,
    this.badgeCount,
  });

  final String label;
  final String route;
  final IconData icon;
  final int? badgeCount;

  @override
  Widget build(BuildContext context) {
    final iconWidget = Badge(
      isLabelVisible: badgeCount != null && badgeCount! > 0,
      label: Text(
        badgeCount! > 99 ? '99+' : '${badgeCount ?? 0}',
        style: const TextStyle(fontSize: 9),
      ),
      child: Icon(icon, size: 16, color: AdminAppBar.adminAccent),
    );
    return ActionChip(
      avatar: iconWidget,
      label: Text(label),
      backgroundColor: AppColors.glassSurface,
      side: BorderSide(color: AdminAppBar.adminAccent.withValues(alpha: 0.4)),
      onPressed: () => context.push(route),
    );
  }
}
