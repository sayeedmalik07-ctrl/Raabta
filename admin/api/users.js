import {
  initFirebase,
  requireAdmin,
  mockUsers,
} from '../_lib/firebaseAdmin.js';

export default async function handler(req, res) {
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'GET, PATCH, OPTIONS');
  res.setHeader('Access-Control-Allow-Headers', 'Authorization, Content-Type');

  if (req.method === 'OPTIONS') return res.status(200).end();

  const auth = await requireAdmin(req, res);
  if (!auth) return;

  const { db, ready } = initFirebase();

  if (req.method === 'GET') {
    const q = (req.query.q || '').toLowerCase();

    if (!ready) {
      const users = mockUsers().filter(
        (u) =>
          !q ||
          u.name.toLowerCase().includes(q) ||
          u.phone.includes(q) ||
          u.nationality.toLowerCase().includes(q),
      );
      return res.status(200).json({ users });
    }

    try {
      const snap = await db.collection('users').limit(200).get();
      let users = await Promise.all(
        snap.docs.map(async (doc) => {
          const d = doc.data();
          const listingsSnap = await db
            .collection('listings')
            .where('posterId', '==', doc.id)
            .get()
            .catch(() => ({ size: 0 }));

          return {
            id: doc.id,
            name: d.displayName || d.name || 'Unknown',
            phone: d.phone || d.phoneNumber || '',
            nationality: d.nationality || 'Unknown',
            subscription: d.subscription || (d.isPremium ? 'premium' : 'free'),
            status: d.status || (d.banned ? 'banned' : d.suspended ? 'suspended' : 'active'),
            listingsPosted: listingsSnap.size ?? d.listingsPosted ?? 0,
            joinedAt: d.createdAt?.toDate?.()?.toISOString?.()?.slice(0, 10) || d.joinedAt || '',
            banReason: d.banReason || '',
          };
        }),
      );

      if (q) {
        users = users.filter(
          (u) =>
            u.name.toLowerCase().includes(q) ||
            u.phone.includes(q) ||
            u.nationality.toLowerCase().includes(q),
        );
      }

      return res.status(200).json({ users });
    } catch (err) {
      return res.status(200).json({ users: mockUsers() });
    }
  }

  if (req.method === 'PATCH') {
    const { id, action, reason } = req.body || {};
    if (!id || !action) {
      return res.status(400).json({ error: 'id and action required' });
    }

    const updates = {};
    if (action === 'ban') {
      updates.status = 'banned';
      updates.banned = true;
      updates.banReason = reason || 'Banned by admin';
      updates.bannedAt = new Date().toISOString();
    } else if (action === 'suspend') {
      updates.status = 'suspended';
      updates.suspended = true;
      updates.suspendReason = reason || 'Suspended by admin';
    } else if (action === 'grant-premium') {
      updates.subscription = 'premium';
      updates.isPremium = true;
      updates.premiumGrantedAt = new Date().toISOString();
    } else if (action === 'revoke-premium') {
      updates.subscription = 'free';
      updates.isPremium = false;
    } else if (action === 'unban') {
      updates.status = 'active';
      updates.banned = false;
      updates.suspended = false;
    } else {
      return res.status(400).json({ error: 'Invalid action' });
    }

    if (!ready) {
      return res.status(200).json({ success: true, id, action, mock: true });
    }

    try {
      await db.collection('users').doc(id).set(updates, { merge: true });
      return res.status(200).json({ success: true, id, action });
    } catch (err) {
      return res.status(500).json({ error: err.message });
    }
  }

  return res.status(405).json({ error: 'Method not allowed' });
}
