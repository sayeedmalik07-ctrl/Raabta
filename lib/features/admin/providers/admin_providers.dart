import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raabta/features/admin/models/admin_app_config_snapshot.dart';
import 'package:raabta/features/admin/models/admin_config.dart';
import 'package:raabta/features/admin/models/admin_stats.dart';
import 'package:raabta/features/admin/models/legal_change_monitor_models.dart';
import 'package:raabta/features/admin/services/admin_repository.dart';

final adminRepositoryProvider = Provider<AdminRepository>((ref) {
  return AdminRepository();
});

final adminApiServiceProvider = Provider<AdminApiService>((ref) {
  return AdminApiService();
});

final adminAppConfigSnapshotProvider =
    StreamProvider<AdminAppConfigSnapshot>((ref) {
  return ref.watch(adminRepositoryProvider).watchAppConfigSnapshots();
});

final adminAppConfigProvider = StreamProvider<AdminAppConfig>((ref) {
  return ref
      .watch(adminRepositoryProvider)
      .watchAppConfigSnapshots()
      .map((snapshot) => snapshot.config);
});

final adminDashboardStatsProvider =
    FutureProvider.autoDispose<AdminDashboardStats>((ref) async {
  final repo = ref.watch(adminRepositoryProvider);
  final api = ref.watch(adminApiServiceProvider);
  final stats = await repo.fetchDashboardStats();
  final aiToday = await api.fetchAiCallsToday();
  final aiStats = await api.fetchAiUsageStats();
  return AdminDashboardStats(
    totalUsers: stats.totalUsers,
    newUsersToday: stats.newUsersToday,
    newUsersThisWeek: stats.newUsersThisWeek,
    activeUsers24h: stats.activeUsers24h,
    businessApproved: stats.businessApproved,
    businessPending: stats.businessPending,
    jobsActive: stats.jobsActive,
    jobsExpired: stats.jobsExpired,
    housingTotal: stats.housingTotal,
    housingPending: stats.housingPending,
    openReports: stats.openReports,
    premiumSubscribers: stats.premiumSubscribers,
    proSubscribers: stats.proSubscribers,
    aiCallsToday: aiToday,
    aiLoggingAvailable: aiStats.loggingAvailable,
  );
});

final aiUsageStatsProvider =
    FutureProvider.autoDispose<AiUsageStats>((ref) async {
  return ref.watch(adminApiServiceProvider).fetchAiUsageStats();
});

final legalMonitorQueueProvider =
    FutureProvider.autoDispose<List<LegalMonitorReviewItem>>((ref) async {
  return ref.watch(adminApiServiceProvider).fetchLegalMonitorQueue();
});

final legalMonitorSourcesProvider =
    FutureProvider.autoDispose<List<LegalMonitorSourceStatus>>((ref) async {
  return ref.watch(adminApiServiceProvider).fetchLegalMonitorSources();
});
