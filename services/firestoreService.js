/**
 * Firestore + FCM integration for listing scam data
 * Gracefully degrades when Firebase credentials are not configured.
 */

let admin = null;
let db = null;
let messaging = null;
let initialized = false;
let initAttempted = false;

function initFirebase() {
  if (initAttempted) return initialized;
  initAttempted = true;

  try {
    const serviceAccountJson = process.env.FIREBASE_SERVICE_ACCOUNT_JSON;
    if (!serviceAccountJson) {
      console.warn('Firestore: FIREBASE_SERVICE_ACCOUNT_JSON not set — using in-memory store only');
      return false;
    }

    admin = require('firebase-admin');
    const serviceAccount = JSON.parse(serviceAccountJson);

    if (!admin.apps.length) {
      admin.initializeApp({
        credential: admin.credential.cert(serviceAccount),
      });
    }

    db = admin.firestore();
    messaging = admin.messaging();
    initialized = true;
    console.log('Firestore: initialized');
    return true;
  } catch (err) {
    console.error('Firestore init failed:', err.message);
    return false;
  }
}

function isReady() {
  return initFirebase();
}

async function saveScamScan(listingId, scanResult) {
  const payload = {
    scamScore: scanResult.scamScore,
    verdict: scanResult.verdict,
    flags: scanResult.flags || [],
    scamReason: scanResult.reason,
    scamRecommendation: scanResult.recommendation,
    scamFlagged: scanResult.verdict === 'likely_scam',
    scamScannedAt: scanResult.scannedAt || new Date().toISOString(),
    updatedAt: new Date().toISOString(),
  };

  if (!isReady()) {
    return { saved: false, payload, storage: 'memory' };
  }

  await db.collection('listings').doc(listingId).set(payload, { merge: true });
  return { saved: true, payload, storage: 'firestore' };
}

async function incrementReportCount(listingId, report) {
  if (!isReady()) {
    return { saved: false, storage: 'memory' };
  }

  const docRef = db.collection('listings').doc(listingId);
  const result = await db.runTransaction(async (transaction) => {
    const snap = await transaction.get(docRef);
    const current = snap.exists ? snap.data() : {};
    const reportCount = (current.report_count || 0) + 1;
    const updates = {
      report_count: reportCount,
      lastReportAt: new Date().toISOString(),
      updatedAt: new Date().toISOString(),
    };

    if (reportCount > 3) {
      updates.status = 'hidden_pending_review';
      updates.hiddenReason = 'auto_hidden_reports';
      updates.scamFlagged = true;
    }

    transaction.set(docRef, updates, { merge: true });

    await db.collection('scam_reports').add({
      listingId,
      reason: report.reason || 'Scam report',
      details: report.details || '',
      reporterId: report.reporterId || 'anonymous',
      reporterContact: report.reporterContact || '',
      createdAt: new Date().toISOString(),
    });

    return { reportCount, autoHidden: reportCount > 3 };
  });

  return { saved: true, storage: 'firestore', ...result };
}

async function countListingsByPhone(phone, excludeId = null) {
  const normalized = String(phone || '').replace(/[\s\-().+]/g, '');

  if (isReady()) {
    try {
      const snapshot = await db.collection('listings').get();
      let count = 0;
      snapshot.forEach((doc) => {
        if (excludeId && doc.id === excludeId) return;
        const data = doc.data();
        const listingPhone = String(data.phone || data.whatsapp || data.contactPhone || '')
          .replace(/[\s\-().+]/g, '');
        if (listingPhone && listingPhone.endsWith(normalized.slice(-8))) {
          count += 1;
        }
      });
      return count;
    } catch (err) {
      console.error('Firestore phone lookup failed:', err.message);
    }
  }

  return 0;
}

async function notifyAdmin(title, body, data = {}) {
  const token = process.env.ADMIN_FCM_TOKEN;
  if (!messaging || !token) {
    console.log('FCM: admin notification skipped (no token or messaging)', title);
    return { sent: false };
  }

  try {
    const messageId = await messaging.send({
      token,
      notification: { title, body },
      data: Object.fromEntries(
        Object.entries(data).map(([k, v]) => [k, String(v)]),
      ),
      android: { priority: 'high' },
      apns: { payload: { aps: { sound: 'default' } } },
    });
    return { sent: true, messageId };
  } catch (err) {
    console.error('FCM send failed:', err.message);
    return { sent: false, error: err.message };
  }
}

module.exports = {
  isReady,
  saveScamScan,
  incrementReportCount,
  countListingsByPhone,
  notifyAdmin,
  getDb: () => {
    initFirebase();
    return db;
  },
  getMessaging: () => {
    initFirebase();
    return messaging;
  },
};
