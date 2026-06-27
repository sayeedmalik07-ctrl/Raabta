import {
  initFirebase,
  requireAdmin,
  mockExchangeRates,
} from './_lib/firebaseAdmin.js';

export default async function handler(req, res) {
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'GET, PUT, POST, OPTIONS');
  res.setHeader('Access-Control-Allow-Headers', 'Authorization, Content-Type');

  if (req.method === 'OPTIONS') return res.status(200).end();

  const auth = await requireAdmin(req, res);
  if (!auth) return;

  const { db, ready } = initFirebase();

  if (req.method === 'GET') {
    if (!ready) {
      return res.status(200).json({ rates: mockExchangeRates() });
    }

    try {
      const snap = await db.collection('exchange_rates').get();
      const rates = snap.docs.map((doc) => ({
        id: doc.id,
        ...doc.data(),
        updatedAt: doc.data().updatedAt || new Date().toISOString(),
      }));

      if (rates.length === 0) {
        return res.status(200).json({ rates: mockExchangeRates() });
      }

      return res.status(200).json({ rates });
    } catch (err) {
      return res.status(200).json({ rates: mockExchangeRates() });
    }
  }

  if (req.method === 'PUT') {
    const { id, rate } = req.body || {};
    if (!id || typeof rate !== 'number') {
      return res.status(400).json({ error: 'id and rate required' });
    }

    const payload = {
      rate,
      today: rate,
      updatedAt: new Date().toISOString(),
    };

    if (!ready) {
      return res.status(200).json({ success: true, id, rate, mock: true });
    }

    try {
      await db.collection('exchange_rates').doc(id).set(payload, { merge: true });
      return res.status(200).json({ success: true, id, rate });
    } catch (err) {
      return res.status(500).json({ error: err.message });
    }
  }

  if (req.method === 'POST') {
    const { action, currency, changePercent } = req.body || {};
    if (action !== 'notify-rate-change') {
      return res.status(400).json({ error: 'Unknown action' });
    }

    // Trigger admin announcement via backend if configured
    const backendUrl = process.env.VITE_BACKEND_URL || process.env.BACKEND_URL;
    const adminKey = process.env.ADMIN_KEY;

    if (backendUrl && adminKey) {
      try {
        const resp = await fetch(`${backendUrl}/api/notifications/admin-announcement`, {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
            'x-admin-key': adminKey,
          },
          body: JSON.stringify({
            userIds: [],
            title: 'Exchange Rate Alert',
            body: `Big rate change detected for ${currency || 'INR'} (${changePercent || '5'}%+). Check Money tab now!`,
            route: '/money',
          }),
        });
        const data = await resp.json();
        return res.status(200).json({ success: true, notified: true, data });
      } catch (err) {
        return res.status(200).json({ success: true, notified: false, mock: true });
      }
    }

    return res.status(200).json({
      success: true,
      notified: false,
      message: 'Configure BACKEND_URL and ADMIN_KEY to send push notifications',
    });
  }

  return res.status(405).json({ error: 'Method not allowed' });
}
