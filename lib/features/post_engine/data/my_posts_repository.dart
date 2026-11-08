import 'package:raabta/data/repositories/businesses_repository.dart';
import 'package:raabta/data/repositories/jobs_repository.dart';
import 'package:raabta/features/post_engine/domain/models/my_post_item.dart';
import 'package:raabta/features/post_engine/domain/models/post_vertical.dart';
import 'package:raabta/features/post_engine/presentation/screens/post_category_picker_screen.dart';
import 'package:raabta/models/housing_models.dart';
import 'package:raabta/screens/services/data/service_listings_repository.dart';
import 'package:raabta/services/drafts/draft_service.dart';
import 'package:raabta/services/housing_firestore_service.dart';
import 'package:raabta/services/marketplace_firestore_service.dart';

/// Aggregates local drafts + Firestore user listings for My Posts hub.
class MyPostsRepository {
  MyPostsRepository({
    DraftService? drafts,
    HousingFirestoreService? housing,
    MarketplaceFirestoreService? marketplace,
    ServiceListingsRepository? services,
    JobsRepository? jobs,
    BusinessesRepository? businesses,
  })  : _drafts = drafts ?? DraftService.instance,
        _housing = housing ?? HousingFirestoreService(),
        _marketplace = marketplace ?? MarketplaceFirestoreService(),
        _services = services ?? ServiceListingsRepository(),
        _jobs = jobs ?? JobsRepository(),
        _businesses = businesses ?? BusinessesRepository();

  final DraftService _drafts;
  final HousingFirestoreService _housing;
  final MarketplaceFirestoreService _marketplace;
  final ServiceListingsRepository _services;
  final JobsRepository _jobs;
  final BusinessesRepository _businesses;

  Future<List<MyPostItem>> loadAll(String uid) async {
    if (uid.isEmpty) return const [];

    final items = <MyPostItem>[];
    items.addAll(await _loadDrafts());
    items.addAll(await _loadHousing(uid));
    items.addAll(await _loadMarketplace(uid));
    items.addAll(await _loadServices(uid));
    items.addAll(await _loadJobs(uid));
    items.addAll(await _loadBusinesses(uid));

    items.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return items;
  }

  Future<List<MyPostItem>> _loadDrafts() async {
    final records = await _drafts.listDraftsForUser(formIdPrefix: 'post_engine_');
    return records.map((entry) {
      final data = entry.record.data;
      final verticalId = data['_vertical']?.toString() ?? 'marketplace';
      final vertical = PostVertical.fromId(verticalId) ?? PostVertical.marketplace;
      final title = data['title']?.toString() ??
          data['name']?.toString() ??
          data['brand']?.toString() ??
          'Draft';
      return MyPostItem(
        id: entry.formId,
        vertical: vertical,
        title: title,
        status: 'draft',
        kind: MyPostItemKind.draft,
        updatedAt: entry.record.savedAt,
        categoryPath: data['_categoryPath']?.toString(),
        route: PostCategoryPickerScreen.postRoute(
          vertical,
          category: data['_categoryPath']?.toString(),
        ),
      );
    }).toList();
  }

  Future<List<MyPostItem>> _loadHousing(String uid) async {
    final listings = await _housing.watchUserListings(uid).first;
    return listings.map((l) {
      final kind = switch (l.status) {
        ListingStatus.pending => MyPostItemKind.pending,
        ListingStatus.approved => MyPostItemKind.published,
        ListingStatus.rejected => MyPostItemKind.rejected,
      };
      return MyPostItem(
        id: l.id,
        vertical: PostVertical.housing,
        title: l.title,
        status: l.status.name,
        kind: kind,
        updatedAt: l.createdAt,
        route: '/housing/listing/${l.id}',
      );
    }).toList();
  }

  Future<List<MyPostItem>> _loadMarketplace(String uid) async {
    final listings = await _marketplace.watchUserListings(uid).first;
    return listings.map((l) {
      final status = l['status']?.toString() ?? 'active';
      return MyPostItem(
        id: l['id'] as String,
        vertical: PostVertical.marketplace,
        title: l['title']?.toString() ?? '',
        status: status,
        kind: status == 'active'
            ? MyPostItemKind.published
            : MyPostItemKind.pending,
        updatedAt: (l['createdAt'] as DateTime?) ?? DateTime.now(),
      );
    }).toList();
  }

  Future<List<MyPostItem>> _loadServices(String uid) async {
    final listings = await _services.watchUserListings(uid).first;
    return listings.map((l) {
      return MyPostItem(
        id: l.id,
        vertical: PostVertical.services,
        title: l.displayTitle,
        status: l.status,
        kind: l.status == 'active'
            ? MyPostItemKind.published
            : MyPostItemKind.pending,
        updatedAt: l.createdAt,
        route: '/services/listing/${l.id}',
      );
    }).toList();
  }

  Future<List<MyPostItem>> _loadJobs(String uid) async {
    final jobs = await _jobs.watchUserJobs(uid).first;
    return jobs.map((j) {
      final id = j['id'] as String;
      return MyPostItem(
        id: id,
        vertical: PostVertical.jobs,
        title: j['title']?.toString() ?? '',
        status: j['status']?.toString() ?? 'active',
        kind: MyPostItemKind.published,
        updatedAt: (j['createdAt'] as DateTime?) ?? DateTime.now(),
        route: '/jobs/listing/$id/applications',
      );
    }).toList();
  }

  Future<List<MyPostItem>> _loadBusinesses(String uid) async {
    final businesses = await _businesses.watchUserBusinesses(uid).first;
    return businesses.map((b) {
      final verification = b['verificationStatus']?.toString() ?? '';
      final kind = verification == 'pending_review'
          ? MyPostItemKind.pending
          : MyPostItemKind.published;
      return MyPostItem(
        id: b['id'] as String,
        vertical: PostVertical.business,
        title: b['name']?.toString() ?? '',
        status: b['status']?.toString() ?? 'active',
        kind: kind,
        updatedAt: (b['createdAt'] as DateTime?) ?? DateTime.now(),
      );
    }).toList();
  }
}
