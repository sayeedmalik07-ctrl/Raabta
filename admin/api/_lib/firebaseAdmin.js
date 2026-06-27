import { createRequire } from 'module';

let admin = null;
let db = null;
let initialized = false;

const require = createRequire(import.meta.url);

export function initFirebase() {
  if (initialized) return { admin, db, ready: !!db };

  try {
    const json = process.env.FIREBASE_SERVICE_ACCOUNT_JSON;
    if (!json) {
      initialized = true;
      return { admin: null, db: null, ready: false };
    }

    // Dynamic import for ESM; fallback to createRequire for CJS
    // eslint-disable-next-line import/no-extraneous-dependencies
    const firebaseAdmin = require('firebase-admin');
    admin = firebaseAdmin;

    if (!admin.apps.length) {
      admin.initializeApp({
        credential: admin.credential.cert(JSON.parse(json)),
      });
    }

    db = admin.firestore();
    initialized = true;
    return { admin, db, ready: true };
  } catch (err) {
    console.error('Firebase Admin init failed:', err.message);
    initialized = true;
    return { admin: null, db: null, ready: false };
  }
}

export async function verifyAdminToken(req) {
  const authHeader = req.headers.authorization || req.headers.Authorization || '';
  const token = authHeader.startsWith('Bearer ') ? authHeader.slice(7) : null;
  if (!token) return { ok: false, error: 'Missing auth token', status: 401 };

  const { admin: fbAdmin, ready } = initFirebase();
  const adminEmail = process.env.ADMIN_EMAIL || 'admin@raabta.app';

  if (!ready) {
    if (process.env.NODE_ENV !== 'production' && req.headers['x-admin-dev'] === 'true') {
      return { ok: true, email: adminEmail, dev: true };
    }
    return { ok: false, error: 'Firebase Admin not configured', status: 503 };
  }

  try {
    const decoded = await fbAdmin.auth().verifyIdToken(token);
    if (decoded.email !== adminEmail) {
      return { ok: false, error: 'Unauthorized admin email', status: 403 };
    }
    return { ok: true, email: decoded.email, uid: decoded.uid };
  } catch {
    return { ok: false, error: 'Invalid token', status: 401 };
  }
}

export async function requireAdmin(req, res) {
  const result = await verifyAdminToken(req);
  if (!result.ok) {
    res.status(result.status).json({ error: result.error });
    return null;
  }
  return result;
}

export function mockStats() {
  return {
    totalUsers: 12847,
    newThisWeek: 342,
    premiumSubscribers: 891,
    activeListings: 2341,
    pendingModeration: 18,
    aiMessagesToday: 1847,
    revenueMonthly: [
      { month: 'Jan', revenue: 12400 },
      { month: 'Feb', revenue: 14200 },
      { month: 'Mar', revenue: 13800 },
      { month: 'Apr', revenue: 16500 },
      { month: 'May', revenue: 18200 },
      { month: 'Jun', revenue: 21400 },
    ],
    aiUsageDaily: [
      { day: 'Mon', messages: 1200 },
      { day: 'Tue', messages: 1450 },
      { day: 'Wed', messages: 1380 },
      { day: 'Thu', messages: 1620 },
      { day: 'Fri', messages: 1847 },
      { day: 'Sat', messages: 980 },
      { day: 'Sun', messages: 760 },
    ],
    nationalityBreakdown: [
      { name: 'Indian', value: 4200 },
      { name: 'Pakistani', value: 3100 },
      { name: 'Filipino', value: 2100 },
      { name: 'Nepali', value: 1400 },
      { name: 'Bangladeshi', value: 980 },
      { name: 'Other', value: 1067 },
    ],
  };
}

export function mockPendingListings() {
  return [
    {
      id: 'listing-p1',
      title: 'Room in Al Khor — near mall',
      photoUrl: 'https://picsum.photos/seed/r1/80/80',
      scamScore: 12,
      reportCount: 0,
      area: 'Al Khor',
      pricePerMonth: 1200,
      status: 'pending',
      createdAt: new Date().toISOString(),
    },
    {
      id: 'listing-p2',
      title: 'Studio Doha — urgent rent',
      photoUrl: 'https://picsum.photos/seed/r2/80/80',
      scamScore: 78,
      reportCount: 3,
      area: 'Doha',
      pricePerMonth: 800,
      status: 'pending',
      createdAt: new Date().toISOString(),
    },
    {
      id: 'listing-p3',
      title: 'Shared villa Al Wakrah',
      photoUrl: 'https://picsum.photos/seed/r3/80/80',
      scamScore: 45,
      reportCount: 1,
      area: 'Al Wakrah',
      pricePerMonth: 950,
      status: 'pending',
      createdAt: new Date().toISOString(),
    },
  ];
}

export function mockUsers() {
  return [
    {
      id: 'user-1',
      name: 'Ahmed Khan',
      phone: '+974 5512 3456',
      nationality: 'Pakistani',
      subscription: 'premium',
      status: 'active',
      listingsPosted: 2,
      joinedAt: '2025-01-15',
    },
    {
      id: 'user-2',
      name: 'Priya Sharma',
      phone: '+974 6678 9012',
      nationality: 'Indian',
      subscription: 'free',
      status: 'active',
      listingsPosted: 0,
      joinedAt: '2025-03-02',
    },
    {
      id: 'user-3',
      name: 'James Santos',
      phone: '+974 7789 0123',
      nationality: 'Filipino',
      subscription: 'free',
      status: 'suspended',
      listingsPosted: 5,
      joinedAt: '2024-11-20',
      banReason: 'Repeated scam reports',
    },
  ];
}

export function mockExchangeRates() {
  return [
    {
      id: 'al-ansari-inr',
      house: 'Al Ansari Exchange',
      from: 'QAR',
      to: 'INR',
      rate: 22.95,
      updatedAt: new Date().toISOString(),
    },
    {
      id: 'al-fardan-inr',
      house: 'Al Fardan Exchange',
      from: 'QAR',
      to: 'INR',
      rate: 22.88,
      updatedAt: new Date().toISOString(),
    },
    {
      id: 'al-ansari-pkr',
      house: 'Al Ansari Exchange',
      from: 'QAR',
      to: 'PKR',
      rate: 76.5,
      updatedAt: new Date().toISOString(),
    },
    {
      id: 'city-exchange-inr',
      house: 'City Exchange',
      from: 'QAR',
      to: 'INR',
      rate: 22.91,
      updatedAt: new Date().toISOString(),
    },
  ];
}

export function mockVisaGuides() {
  return [
    {
      id: 'iqama_renewal',
      title: 'Iqama Renewal Guide',
      summary: 'Step-by-step iqama renewal process in Qatar',
      content: '<p>Renew your iqama through Metrash2 or MOI portal...</p>',
      updatedAt: new Date().toISOString(),
    },
    {
      id: 'family_visa',
      title: 'Family Visa Application',
      summary: 'Bring your family to Qatar',
      content: '<p>Requirements and steps for family visa...</p>',
      updatedAt: new Date().toISOString(),
    },
  ];
}

export function mockDoctors() {
  return [
    {
      id: 'doc-1',
      name: 'Dr. Rajesh Kumar',
      specialty: 'GP',
      hospital: 'Al Khor Hospital',
      languages: ['Hindi', 'English'],
      rating: 4.8,
      area: 'Al Khor',
    },
    {
      id: 'doc-2',
      name: 'Dr. Fatima Al-Ali',
      specialty: 'Gynecologist',
      hospital: 'HMC',
      languages: ['Arabic', 'English'],
      rating: 4.9,
      area: 'Doha',
    },
  ];
}

export function mockBusinesses() {
  return [
    {
      id: 'biz-1',
      name: 'Karachi Kitchen',
      category: 'Restaurant',
      location: 'Al Sadd',
      rating: 4.6,
      phone: '+974 4444 1234',
    },
    {
      id: 'biz-2',
      name: 'Desi Mart',
      category: 'Grocery',
      location: 'Industrial Area',
      rating: 4.4,
      phone: '+974 4444 5678',
    },
  ];
}

export function mockAnnouncements() {
  return [
    {
      id: 'ann-1',
      title: 'Eid Al Adha Holiday Notice',
      body: 'Government offices closed June 16–18',
      route: '/news',
      createdAt: new Date().toISOString(),
    },
  ];
}

export function mockAiConversations() {
  return [
    {
      id: 'conv-1',
      topic: 'Iqama renewal',
      preview: 'How do I renew my iqama before expiry?',
      messages: 4,
      costUsd: 0.012,
      flagged: false,
      createdAt: new Date().toISOString(),
    },
    {
      id: 'conv-2',
      topic: 'Housing search',
      preview: 'Best areas for families under 3000 QR?',
      messages: 6,
      costUsd: 0.018,
      flagged: true,
      flagReason: 'Incorrect salary info',
      createdAt: new Date().toISOString(),
    },
  ];
}

export function mockAiStats() {
  return {
    dailyCost: [
      { day: 'Mon', cost: 4.2 },
      { day: 'Tue', cost: 5.1 },
      { day: 'Wed', cost: 4.8 },
      { day: 'Thu', cost: 6.2 },
      { day: 'Fri', cost: 7.4 },
      { day: 'Sat', cost: 3.1 },
      { day: 'Sun', cost: 2.8 },
    ],
    totalCostToday: 7.4,
    totalCostMonth: 142.5,
    commonQuestions: [
      { question: 'How to renew iqama?', count: 342 },
      { question: 'Best exchange rate for INR?', count: 218 },
      { question: 'Family visa requirements?', count: 187 },
      { question: 'Cheapest housing in Doha?', count: 156 },
      { question: 'Driving license conversion?', count: 134 },
    ],
  };
}
