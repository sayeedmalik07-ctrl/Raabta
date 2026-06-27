import {
  initFirebase,
  requireAdmin,
  mockStats,
} from './_lib/firebaseAdmin.js';

export default async function handler(req, res) {
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'GET, OPTIONS');
  res.setHeader('Access-Control-Allow-Headers', 'Authorization, Content-Type');

  if (req.method === 'OPTIONS') return res.status(200).end();
  if (req.method !== 'GET') return res.status(405).json({ error: 'Method not allowed' });

  const auth = await requireAdmin(req, res);
  if (!auth) return;

  const { db, ready } = initFirebase();

  if (!ready) {
    return res.status(200).json(mockStats());
  }

  try {
    const usersSnap = await db.collection('users').get();
    const listingsSnap = await db.collection('listings').get();
    const now = new Date();
    const weekAgo = new Date(now.getTime() - 7 * 24 * 60 * 60 * 1000);

    let newThisWeek = 0;
    let premiumSubscribers = 0;
    const nationalityMap = {};

    usersSnap.docs.forEach((doc) => {
      const d = doc.data();
      const created = d.createdAt?.toDate?.() || d.joinedAt ? new Date(d.joinedAt) : null;
      if (created && created >= weekAgo) newThisWeek += 1;
      if (d.subscription === 'premium' || d.isPremium) premiumSubscribers += 1;

      const nat = d.nationality || d.ai_profile?.nationality || 'Unknown';
      nationalityMap[nat] = (nationalityMap[nat] || 0) + 1;
    });

    let activeListings = 0;
    let pendingModeration = 0;
    listingsSnap.docs.forEach((doc) => {
      const d = doc.data();
      if (d.status === 'approved') activeListings += 1;
      if (d.status === 'pending' || d.status === 'hidden_pending_review') pendingModeration += 1;
    });

    const nationalityBreakdown = Object.entries(nationalityMap)
      .map(([name, value]) => ({ name, value }))
      .sort((a, b) => b.value - a.value)
      .slice(0, 8);

    const aiSnap = await db
      .collection('admin_metrics')
      .doc('ai_usage')
      .get()
      .catch(() => null);

    const aiData = aiSnap?.exists ? aiSnap.data() : null;

    return res.status(200).json({
      totalUsers: usersSnap.size,
      newThisWeek,
      premiumSubscribers,
      activeListings,
      pendingModeration,
      aiMessagesToday: aiData?.messagesToday ?? 0,
      revenueMonthly: aiData?.revenueMonthly ?? mockStats().revenueMonthly,
      aiUsageDaily: aiData?.aiUsageDaily ?? mockStats().aiUsageDaily,
      nationalityBreakdown:
        nationalityBreakdown.length > 0
          ? nationalityBreakdown
          : mockStats().nationalityBreakdown,
    });
  } catch (err) {
    console.error('stats error:', err);
    return res.status(200).json(mockStats());
  }
}
