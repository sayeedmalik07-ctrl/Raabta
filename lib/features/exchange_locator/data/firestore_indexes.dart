/// Required Firestore composite indexes for Exchange Locator Pro.
///
/// Create these in Firebase Console → Firestore → Indexes before production:
///
/// **exchange_companies**
/// - Collection: `exchange_companies`
///   Fields: `isFeatured` Desc, `rating` Desc
/// - Collection: `exchange_companies`
///   Fields: `isVerified` Desc, `rating` Desc
/// - Collection: `exchange_companies`
///   Fields: `name` Asc
///
/// **exchange_branches**
/// - Collection: `exchange_branches`
///   Fields: `companyId` Asc, `rating` Desc
/// - Collection: `exchange_branches`
///   Fields: `companyId` Asc, `isOpenNow` Desc, `rating` Desc
/// - Collection: `exchange_branches`
///   Fields: `city` Asc, `area` Asc, `rating` Desc
/// - Collection: `exchange_branches`
///   Fields: `isOpenNow` Desc, `rating` Desc
/// - Collection: `exchange_branches`
///   Fields: `area` Asc, `rating` Desc
/// - Collection: `exchange_branches`
///   Fields: `queueStatus` Asc, `estimatedWaitingMinutes` Asc
///
/// **exchange_services** (top-level, branchId reference)
/// - Collection: `exchange_services`
///   Fields: `branchId` Asc, `serviceName` Asc
/// - Collection: `exchange_services`
///   Fields: `serviceName` Asc
///
/// **exchange_reviews**
/// - Collection: `exchange_reviews`
///   Fields: `branchId` Asc, `createdAt` Desc
/// - Collection: `exchange_reviews`
///   Fields: `branchId` Asc, `userId` Asc
/// - Collection: `exchange_reviews`
///   Fields: `branchId` Asc, `rating` Desc, `createdAt` Desc
///
/// **exchange_queue_reports**
/// - Collection: `exchange_queue_reports`
///   Fields: `branchId` Asc, `createdAt` Desc
///
/// **users/{uid}/exchange_recent_visits** (subcollection)
///   Fields: `visitedAt` Desc
///
/// - Collection group or subcollection: `exchange_favorites`
///   Fields: `savedAt` Desc
///
/// Note: Full-text search is not supported natively. Client-side filter on
/// paginated results + prefix queries on `name` / `area` fields only.

library;
