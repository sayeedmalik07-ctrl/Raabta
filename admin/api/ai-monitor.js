import {
  initFirebase,
  requireAdmin,
  mockAiConversations,
  mockAiStats,
} from './_lib/firebaseAdmin.js';

export default async function handler(req, res) {
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'GET, PATCH, OPTIONS');
  res.setHeader('Access-Control-Allow-Headers', 'Authorization, Content-Type');

  if (req.method === 'OPTIONS') return res.status(200).end();

  const auth = await requireAdmin(req, res);
  if (!auth) return;

  const { db, ready } = initFirebase();

  if (req.method === 'GET') {
    if (!ready) {
      return res.status(200).json({
        conversations: mockAiConversations(),
        stats: mockAiStats(),
      });
    }

    try {
      const convSnap = await db
        .collection('ai_conversations')
        .orderBy('createdAt', 'desc')
        .limit(50)
        .get()
        .catch(() => null);

      const conversations = convSnap?.docs?.length
        ? convSnap.docs.map((doc) => ({ id: doc.id, ...doc.data() }))
        : mockAiConversations();

      const metricsSnap = await db.collection('admin_metrics').doc('ai_usage').get();
      const stats = metricsSnap?.exists
        ? { ...mockAiStats(), ...metricsSnap.data() }
        : mockAiStats();

      return res.status(200).json({ conversations, stats });
    } catch (err) {
      return res.status(200).json({
        conversations: mockAiConversations(),
        stats: mockAiStats(),
      });
    }
  }

  if (req.method === 'PATCH') {
    const { id, flagged, flagReason } = req.body || {};
    if (!id) return res.status(400).json({ error: 'id required' });

    if (!ready) {
      return res.status(200).json({ success: true, mock: true });
    }

    try {
      await db.collection('ai_conversations').doc(id).set(
        {
          flagged: !!flagged,
          flagReason: flagReason || '',
          flaggedAt: new Date().toISOString(),
        },
        { merge: true },
      );
      return res.status(200).json({ success: true });
    } catch (err) {
      return res.status(500).json({ error: err.message });
    }
  }

  return res.status(405).json({ error: 'Method not allowed' });
}
