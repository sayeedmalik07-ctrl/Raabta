import {
  initFirebase,
  requireAdmin,
  mockVisaGuides,
  mockDoctors,
  mockBusinesses,
  mockAnnouncements,
} from './_lib/firebaseAdmin.js';

const COLLECTIONS = {
  'visa-guides': 'visa_guides',
  doctors: 'doctors',
  businesses: 'businesses',
  announcements: 'government_announcements',
};

export default async function handler(req, res) {
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'GET, POST, PUT, DELETE, OPTIONS');
  res.setHeader('Access-Control-Allow-Headers', 'Authorization, Content-Type');

  if (req.method === 'OPTIONS') return res.status(200).end();

  const auth = await requireAdmin(req, res);
  if (!auth) return;

  const type = req.query.type;
  const collectionName = COLLECTIONS[type];
  if (!collectionName) {
    return res.status(400).json({ error: 'Invalid type. Use visa-guides, doctors, businesses, announcements' });
  }

  const { db, ready } = initFirebase();

  const mockData = {
    'visa-guides': mockVisaGuides,
    doctors: mockDoctors,
    businesses: mockBusinesses,
    announcements: mockAnnouncements,
  };

  if (req.method === 'GET') {
    if (!ready) {
      return res.status(200).json({ items: mockData[type]() });
    }

    try {
      const snap = await db.collection(collectionName).get();
      const items = snap.docs.map((doc) => ({ id: doc.id, ...doc.data() }));
      return res.status(200).json({
        items: items.length > 0 ? items : mockData[type](),
      });
    } catch (err) {
      return res.status(200).json({ items: mockData[type]() });
    }
  }

  if (req.method === 'POST') {
    const item = req.body || {};
    if (!ready) {
      return res.status(200).json({ success: true, id: `mock-${Date.now()}`, mock: true });
    }

    try {
      const ref = item.id
        ? db.collection(collectionName).doc(item.id)
        : db.collection(collectionName).doc();
      const { id: _id, ...data } = item;
      await ref.set({ ...data, updatedAt: new Date().toISOString() }, { merge: true });
      return res.status(200).json({ success: true, id: ref.id });
    } catch (err) {
      return res.status(500).json({ error: err.message });
    }
  }

  if (req.method === 'PUT') {
    const { id, ...data } = req.body || {};
    if (!id) return res.status(400).json({ error: 'id required' });

    if (!ready) {
      return res.status(200).json({ success: true, id, mock: true });
    }

    try {
      await db
        .collection(collectionName)
        .doc(id)
        .set({ ...data, updatedAt: new Date().toISOString() }, { merge: true });
      return res.status(200).json({ success: true, id });
    } catch (err) {
      return res.status(500).json({ error: err.message });
    }
  }

  if (req.method === 'DELETE') {
    const { id } = req.query;
    if (!id) return res.status(400).json({ error: 'id required' });

    if (!ready) {
      return res.status(200).json({ success: true, mock: true });
    }

    try {
      await db.collection(collectionName).doc(id).delete();
      return res.status(200).json({ success: true });
    } catch (err) {
      return res.status(500).json({ error: err.message });
    }
  }

  return res.status(405).json({ error: 'Method not allowed' });
}
