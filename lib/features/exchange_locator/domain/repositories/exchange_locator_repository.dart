import 'dart:io';

import 'package:raabta/features/exchange_locator/domain/exchange_queue_logic.dart';
import 'package:raabta/features/exchange_locator/domain/models/branch_filters.dart';
import 'package:raabta/features/exchange_locator/domain/models/exchange_branch.dart';
import 'package:raabta/features/exchange_locator/domain/models/exchange_company.dart';
import 'package:raabta/features/exchange_locator/domain/models/exchange_review.dart';

class PaginatedResult<T> {
  const PaginatedResult({
    required this.items,
    this.lastDocumentId,
    this.hasMore = false,
  });

  final List<T> items;
  final String? lastDocumentId;
  final bool hasMore;
}

abstract class ExchangeLocatorRepository {
  Future<PaginatedResult<ExchangeCompany>> fetchCompanies({
    int limit = 20,
    String? startAfterId,
    bool featuredOnly = false,
  });

  Future<ExchangeCompany?> fetchCompany(String companyId);

  Future<PaginatedResult<ExchangeBranch>> fetchBranches({
    int limit = 30,
    String? startAfterId,
    String? companyId,
    BranchFinderFilters? filters,
  });

  Future<ExchangeBranch?> fetchBranch(String branchId);

  Future<List<ExchangeBranch>> fetchAllBranchesForMap();

  Future<PaginatedResult<ExchangeReview>> fetchReviews({
    required String branchId,
    int limit = 15,
    String? startAfterId,
    ExchangeReviewSort sort = ExchangeReviewSort.recent,
  });

  Future<bool> hasUserReviewedBranch({
    required String branchId,
    required String userId,
  });

  Future<void> submitReview({
    required String branchId,
    required String userId,
    required int rating,
    required String review,
    String? userDisplayName,
  });

  Stream<Set<String>> watchFavoriteBranchIds(String userId);

  Future<void> toggleFavorite({
    required String userId,
    required String branchId,
    required ExchangeBranch branch,
  });

  Future<List<ExchangeBranch>> fetchFavoriteBranches(String userId);

  /// Recent crowd reports for accuracy nudge (last 2 hours, max 10 reads).
  Future<List<CrowdReportSample>> fetchRecentCrowdReports(String branchId);

  Future<void> submitCrowdReport({
    required String branchId,
    required String userId,
    required CrowdReportLevel level,
  });

  Future<void> recordRecentVisitRemote({
    required String userId,
    required ExchangeBranch branch,
  });

  Future<List<ExchangeBranch>> fetchRecentVisitsRemote(String userId);

  Future<void> setBranchDetailsVerified({
    required String branchId,
    required bool verified,
  });

  /// Force-refresh map branches (bypasses TTL cache).
  Future<List<ExchangeBranch>> refreshBranchesForMap();
  Future<String> upsertCompany(ExchangeCompany company);
  Future<void> deleteCompany(String companyId);
  Future<String> upsertBranch(ExchangeBranch branch);
  Future<void> deleteBranch(String branchId);
  Future<void> syncBranchServices(String branchId, List<String> services);
}

abstract class ExchangeLocatorStorage {
  Future<String> uploadCompanyLogo(File file, String companyId);
  Future<String> uploadBranchPhoto(File file, String branchId);
}

class ExchangeLocatorException implements Exception {
  ExchangeLocatorException(this.message);
  final String message;
  @override
  String toString() => message;
}
