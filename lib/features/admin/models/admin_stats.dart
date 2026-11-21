import 'package:raabta/config/monetization_config.dart';

class AdminDashboardStats {
  const AdminDashboardStats({
    this.totalUsers = 0,
    this.newUsersToday = 0,
    this.newUsersThisWeek = 0,
    this.activeUsers24h = 0,
    this.businessApproved = 0,
    this.businessPending = 0,
    this.jobsActive = 0,
    this.jobsExpired = 0,
    this.housingTotal = 0,
    this.housingPending = 0,
    this.openReports = 0,
    this.premiumSubscribers = 0,
    this.proSubscribers = 0,
    this.aiCallsToday = 0,
    this.aiLoggingAvailable = false,
  });

  final int totalUsers;
  final int newUsersToday;
  final int newUsersThisWeek;
  final int activeUsers24h;
  final int businessApproved;
  final int businessPending;
  final int jobsActive;
  final int jobsExpired;
  final int housingTotal;
  final int housingPending;
  final int openReports;
  final int premiumSubscribers;
  final int proSubscribers;
  final int aiCallsToday;
  final bool aiLoggingAvailable;

  int get revenueEstimateQr => MonetizationConfig.estimatedMonthlyRevenueQr(
        premiumSubscribers: premiumSubscribers,
        proSubscribers: proSubscribers,
      );
}

class AdminUserRow {
  const AdminUserRow({
    required this.uid,
    required this.displayName,
    required this.email,
    required this.phone,
    required this.subscriptionTier,
    required this.status,
    this.createdAt,
    this.lastActive,
    this.lastLogin,
    this.points,
    this.level,
    this.nationality,
    this.language,
    this.raw,
  });

  final String uid;
  final String displayName;
  final String email;
  final String phone;
  final String subscriptionTier;
  final String status;
  final DateTime? createdAt;
  final DateTime? lastActive;
  final DateTime? lastLogin;
  final int? points;
  final String? level;
  final String? nationality;
  final String? language;
  final Map<String, dynamic>? raw;
}

class AiUsageStats {
  const AiUsageStats({
    this.loggingAvailable = false,
    this.dailyCalls = const [],
    this.byFeature = const {},
    this.byModel = const {},
    this.topUsers = const [],
    this.costPer1kTokens = 0.05,
    this.estimatedCostQr = 0,
  });

  final bool loggingAvailable;
  final List<DailyAiUsage> dailyCalls;
  final Map<String, int> byFeature;
  final Map<String, int> byModel;
  final List<TopAiUser> topUsers;
  final double costPer1kTokens;
  final double estimatedCostQr;
}

class DailyAiUsage {
  const DailyAiUsage({required this.date, required this.count});

  final DateTime date;
  final int count;
}

class TopAiUser {
  const TopAiUser({
    required this.userId,
    required this.displayName,
    required this.count,
  });

  final String userId;
  final String displayName;
  final int count;
}
