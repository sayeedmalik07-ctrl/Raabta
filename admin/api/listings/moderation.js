import {
  initFirebase,
  requireAdmin,
  mockPendingListings,
} from './_lib/firebaseAdmin.js';

export default async function handler(req, res) {
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'GET, PATCH, POST, OPTIONS');
  res.setHeader('Access-Control-Allow-Headers', 'Authorization, Content-Type');

  if (req.method === 'OPTIONS') return res.status(200).end();

  const auth = await requireAdmin(req, res);
  if (!auth) return;

  const { db, ready } = initFirebase();

  if (req.method === 'GET') {
    const minScore = req.query.minScore ? Number(req.query.minScore) : 0;
    const maxScore = req.query.maxScore ? Number(req.query.maxScore) : 100;

    if (!ready) {
      const filtered = mockPendingListings().filter(
        (l) => l.scamScore >= minScore && l.scamScore <= maxScore,
      );
      return res.status(200).json({ listings: filtered });
    }

    try {
      const snap = await db
        .collection('listings')
        .where('status', 'in', ['pending', 'hidden_pending_review'])
        .get();

      const listings = snap.docs
        .map((doc) => {
          const d = doc.data();
          return {
            id: doc.id,
            title: d.title || 'Untitled',
            photoUrl: d.photoUrls?.[0] || '',
            scamScore: d.scamScore ?? 0,
            reportCount: d.report_count ?? 0,
            area: d.area || '',
            pricePerMonth: d.pricePerMonth ?? 0,
            status: d.status,
            createdAt: d.createdAt || d.submittedAt || new Date().toISOString(),
          };
        })
        .filter((l) => l.scamScore >= minScore && l.scamScore <= maxScore);

      return res.status(200).json({ listings });
    } catch (err) {
      console.error('moderation GET:', err);
      return res.status(200).json({ listings: mockPendingListings() });
    }
  }

  if (req.method === 'PATCH') {
    const { id, action } = req.body || {};
    if (!id || !action) {
      return res.status(400).json({ error: 'id and action required' });
    }

    const statusMap = {
      approve: { status: 'approved', verified: true, scamFlagged: false },
      reject: { status: 'rejected', verified: false },
      flag: { status: 'hidden_pending_review', scamFlagged: true },
    };

    const updates = statusMap[action];
    if (!updates) return res.status(400).json({ error: 'Invalid action' });

    if (!ready) {
      return res.status(200).json({ success: true, id, action, mock: true });
    }

    try {
      await db.collection('listings').doc(id).set(
        { ...updates, updatedAt: new Date().toISOString() },
        { merge: true },
      );
      return res.status(200).json({ success: true, id, action });
    } catch (err) {
      return res.status(500).json({ error: err.message });
    }
  }

  if (req.method === 'POST') {
    const { action, ids } = req.body || {};
    if (action !== 'bulk-approve' || !Array.isArray(ids)) {
      return res.status(400).json({ error: 'bulk-approve requires ids array' });
    }

    if (!ready) {
      return res.status(200).json({ success: true, count: ids.length, mock: true });
    }

    try {
      const batch = db.batch();
      ids.forEach((id) => {
        batch.set(
          db.collection('listings').doc(id),
          {
            status: 'approved',
            verified: true,
            scamFlagged: false,
            updatedAt: new Date().toISOString(),
          },
          { merge: true },
        );
      });
      await batch.commit();
      return res.status(200).json({ success: true, count: ids.length });
    } catch (err) {
      return res.status(500).json({ error: err.message });
    }
  }

  return res.status(405).json({ error: 'Method not allowed' });
}
