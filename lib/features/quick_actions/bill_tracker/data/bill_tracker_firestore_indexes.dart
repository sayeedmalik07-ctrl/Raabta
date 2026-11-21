/// Required Firestore composite index for Bill Tracker.
///
/// Create in Firebase Console → Firestore → Indexes (same process as Queue Avoidance):
///
/// **bill_tracker**
/// - Collection: `bill_tracker`
///   Fields: `userId` Asc, `isPaid` Asc, `dueDate` Asc
///
/// `isPaid` Asc puts unpaid (`false`) before paid (`true`).
/// `dueDate` Asc sorts upcoming bills first within each group.
library;
