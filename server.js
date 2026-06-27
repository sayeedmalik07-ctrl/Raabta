require('dotenv').config();

const express = require('express');
const cors = require('cors');
const Anthropic = require('@anthropic-ai/sdk');
const { scanListing, normalizePhone } = require('./services/scamDetection');
const firestoreService = require('./services/firestoreService');
const {
  sendPushNotification,
  registerFcmToken,
  runDailyNotificationJobs,
  runWeeklyDigest,
  sendCommunityReplyNotification,
  sendJobMatchNotification,
  sendAdminAnnouncement,
  NOTIFICATION_TYPES,
} = require('./services/notifications');
const { startNotificationScheduler } = require('./services/notificationScheduler');
const exchangeRatesRouter = require('./routes/exchangeRates');

const app = express();
const PORT = process.env.PORT || 3000;

const RATE_LIMIT_MAX = 10;
const RATE_LIMIT_WINDOW_MS = 60 * 60 * 1000;

const rateLimitStore = new Map();

app.use(cors());
app.use(express.json());

function getClientIp(req) {
  const forwarded = req.headers['x-forwarded-for'];
  if (typeof forwarded === 'string' && forwarded.length > 0) {
    return forwarded.split(',')[0].trim();
  }
  return req.ip || req.socket.remoteAddress || 'unknown';
}

function checkRateLimit(ip) {
  const now = Date.now();
  const entry = rateLimitStore.get(ip);

  if (!entry || now >= entry.resetAt) {
    rateLimitStore.set(ip, {
      count: 1,
      resetAt: now + RATE_LIMIT_WINDOW_MS,
    });
    return { allowed: true, remaining: RATE_LIMIT_MAX - 1 };
  }

  if (entry.count >= RATE_LIMIT_MAX) {
    const retryAfterMs = entry.resetAt - now;
    return {
      allowed: false,
      remaining: 0,
      retryAfterMinutes: Math.ceil(retryAfterMs / 60000),
    };
  }

  entry.count += 1;
  rateLimitStore.set(ip, entry);
  return { allowed: true, remaining: RATE_LIMIT_MAX - entry.count };
}

function buildSystemPrompt(language) {
  return `You are Raabta AI, the most helpful assistant for expatriates living in Qatar. You are warm, caring, and speak like a knowledgeable friend.

You specialize in:
- Qatar visa and Iqama rules and procedures
- Qatar Labour Law and worker rights
- QID (Qatar ID) application and renewal
- Housing and tenancy rights in Qatar
- Medical facilities and health insurance
- Driving license procedures in Qatar
- Traffic fines and Metrash2 app
- Money transfer and exchange rates
- Schools and education in Qatar
- Daily life tips for expats in Qatar

ALWAYS respond in ${language}.
For procedures, give clear numbered steps.
Always mention official sources (Metrash2, Hukoomi, MOI Qatar).
If unsure, say so clearly - never guess on legal matters.
For emergencies always say: call 999 immediately.
Keep responses under 250 words.
Be warm and encouraging.`;
}

function normalizeHistory(conversationHistory) {
  if (!Array.isArray(conversationHistory)) {
    return [];
  }

  return conversationHistory
    .filter(
      (item) =>
        item &&
        typeof item === 'object' &&
        (item.role === 'user' || item.role === 'assistant') &&
        typeof item.content === 'string' &&
        item.content.trim().length > 0,
    )
    .map((item) => ({
      role: item.role,
      content: item.content.trim(),
    }));
}

function countInMemoryListingsByPhone(phone, excludeId = null) {
  const normalized = normalizePhone(phone).replace(/^\+?974/, '');
  if (!normalized) return 0;
  return listingsStore.filter((l) => {
    if (excludeId && l.id === excludeId) return false;
    const listingPhone = normalizePhone(l.phone || l.whatsapp).replace(/^\+?974/, '');
    return listingPhone && listingPhone.endsWith(normalized.slice(-8));
  }).length;
}

function applyScamResultToListing(listing, scanResult) {
  listing.scamScore = scanResult.scamScore;
  listing.verdict = scanResult.verdict;
  listing.flags = scanResult.flags;
  listing.scamReason = scanResult.reason;
  listing.scamRecommendation = scanResult.recommendation;
  listing.scamFlagged = scanResult.verdict === 'likely_scam';
  listing.scamScannedAt = scanResult.scannedAt;
  return listing;
}

async function runScamScanForListing(listing, inputOverrides = {}) {
  const phone = inputOverrides.contactPhone || listing.phone || listing.whatsapp;
  const memoryCount = countInMemoryListingsByPhone(phone, listing.id);
  const firestoreCount = await firestoreService.countListingsByPhone(phone, listing.id);
  const duplicatePhoneCount = Math.max(memoryCount, firestoreCount);

  const scanInput = {
    title: inputOverrides.title ?? listing.title,
    description: inputOverrides.description ?? listing.description,
    price: inputOverrides.price ?? listing.pricePerMonth,
    area: inputOverrides.area ?? listing.area,
    contactPhone: phone,
    photos: inputOverrides.photos ?? listing.photoUrls ?? [],
    bedrooms: inputOverrides.bedrooms ?? listing.bedrooms,
    type: inputOverrides.type ?? listing.type,
    posterNationality: inputOverrides.posterNationality ?? listing.posterNationality,
  };

  const scanResult = await scanListing(scanInput, { duplicatePhoneCount });
  applyScamResultToListing(listing, scanResult);

  if (listing.id) {
    await firestoreService.saveScamScan(listing.id, scanResult);
  }

  return scanResult;
}

app.get('/health', (_req, res) => {
  res.json({ status: 'ok', service: 'Raabta AI Chat API' });
});

app.use('/api/exchange', exchangeRatesRouter);

// --- Exchange Rates (legacy) ---

const EXCHANGE_RATE_DATA = {
  INR: {
    indicativeRate: 22.8,
    houses: [
      { id: 'al-zaman', name: 'Al Zaman Exchange', logoEmoji: '🏦', rate: 22.8, fee: 5, transferTime: 'Instant', rating: 4.7, mapsUrl: 'https://maps.google.com/?q=Al+Zaman+Exchange+Qatar', phone: '+97444111444' },
      { id: 'western-union', name: 'Western Union Qatar', logoEmoji: '🌐', rate: 22.65, fee: 8, transferTime: '2 hrs', rating: 4.4, mapsUrl: 'https://maps.google.com/?q=Western+Union+Qatar', phone: '+97444111001' },
      { id: 'al-dar', name: 'Al Dar Exchange', logoEmoji: '🏛️', rate: 22.7, fee: 5, transferTime: 'Instant', rating: 4.5, mapsUrl: 'https://maps.google.com/?q=Al+Dar+Exchange+Qatar', phone: '+97444111555' },
      { id: 'lulu', name: 'LULU Exchange Al Khor', logoEmoji: '🛒', rate: 22.82, fee: 6, transferTime: 'Instant', rating: 4.8, mapsUrl: 'https://maps.google.com/?q=Lulu+Exchange+Al+Khor', phone: '+97444111222' },
      { id: 'trust', name: 'Trust Exchange Al Khor', logoEmoji: '🤝', rate: 22.78, fee: 5, transferTime: '2 hrs', rating: 4.3, mapsUrl: 'https://maps.google.com/?q=Trust+Exchange+Al+Khor', phone: '+97444111333' },
      { id: 'al-mirqab', name: 'Al Mirqab Exchange', logoEmoji: '💰', rate: 22.72, fee: 7, transferTime: 'Next Day', rating: 4.1, mapsUrl: 'https://maps.google.com/?q=Al+Mirqab+Exchange+Qatar', phone: '+97444111888' },
      { id: 'gulf', name: 'Gulf Exchange', logoEmoji: '🌍', rate: 22.68, fee: 5, transferTime: 'Instant', rating: 4.2, mapsUrl: 'https://maps.google.com/?q=Gulf+Exchange+Qatar', phone: '+97444111666' },
      { id: 'habib', name: 'Habib Qatar International Exchange', logoEmoji: '🏢', rate: 22.66, fee: 6, transferTime: '2 hrs', rating: 4.0, mapsUrl: 'https://maps.google.com/?q=Habib+Qatar+International+Exchange', phone: '+97444111777' },
      { id: 'al-amanah', name: 'Al Amanah Exchange', logoEmoji: '✅', rate: 22.75, fee: 5, transferTime: 'Instant', rating: 4.6, mapsUrl: 'https://maps.google.com/?q=Al+Amanah+Exchange+Qatar', phone: '+97444111999' },
      { id: 'baladna', name: 'Baladna Exchange', logoEmoji: '🐪', rate: 22.64, fee: 4, transferTime: 'Instant', rating: 4.2, mapsUrl: 'https://maps.google.com/?q=Baladna+Exchange+Qatar', phone: '+97444112000' },
      { id: 'moneygram', name: 'MoneyGram Qatar', logoEmoji: '📨', rate: 22.6, fee: 10, transferTime: 'Next Day', rating: 3.9, mapsUrl: 'https://maps.google.com/?q=MoneyGram+Qatar', phone: '+97444112111' },
    ],
  },
  PKR: {
    indicativeRate: 76.5,
    houses: [
      { id: 'al-zaman', name: 'Al Zaman Exchange', logoEmoji: '🏦', rate: 76.5, fee: 5, transferTime: 'Instant', rating: 4.7, mapsUrl: 'https://maps.google.com/?q=Al+Zaman+Exchange+Qatar', phone: '+97444111444' },
      { id: 'western-union', name: 'Western Union Qatar', logoEmoji: '🌐', rate: 76.2, fee: 8, transferTime: '2 hrs', rating: 4.4, mapsUrl: 'https://maps.google.com/?q=Western+Union+Qatar', phone: '+97444111001' },
      { id: 'al-dar', name: 'Al Dar Exchange', logoEmoji: '🏛️', rate: 76.35, fee: 5, transferTime: 'Instant', rating: 4.5, mapsUrl: 'https://maps.google.com/?q=Al+Dar+Exchange+Qatar', phone: '+97444111555' },
      { id: 'lulu', name: 'LULU Exchange Al Khor', logoEmoji: '🛒', rate: 76.55, fee: 6, transferTime: 'Instant', rating: 4.8, mapsUrl: 'https://maps.google.com/?q=Lulu+Exchange+Al+Khor', phone: '+97444111222' },
      { id: 'trust', name: 'Trust Exchange Al Khor', logoEmoji: '🤝', rate: 76.4, fee: 5, transferTime: '2 hrs', rating: 4.3, mapsUrl: 'https://maps.google.com/?q=Trust+Exchange+Al+Khor', phone: '+97444111333' },
      { id: 'moneygram', name: 'MoneyGram Qatar', logoEmoji: '📨', rate: 76.1, fee: 10, transferTime: 'Next Day', rating: 3.9, mapsUrl: 'https://maps.google.com/?q=MoneyGram+Qatar', phone: '+97444112111' },
    ],
  },
  BDT: {
    indicativeRate: 29.2,
    houses: [
      { id: 'al-zaman', name: 'Al Zaman Exchange', logoEmoji: '🏦', rate: 29.2, fee: 5, transferTime: 'Instant', rating: 4.7, mapsUrl: 'https://maps.google.com/?q=Al+Zaman+Exchange+Qatar', phone: '+97444111444' },
      { id: 'western-union', name: 'Western Union Qatar', logoEmoji: '🌐', rate: 29.05, fee: 8, transferTime: '2 hrs', rating: 4.4, mapsUrl: 'https://maps.google.com/?q=Western+Union+Qatar', phone: '+97444111001' },
      { id: 'al-dar', name: 'Al Dar Exchange', logoEmoji: '🏛️', rate: 29.15, fee: 5, transferTime: 'Instant', rating: 4.5, mapsUrl: 'https://maps.google.com/?q=Al+Dar+Exchange+Qatar', phone: '+97444111555' },
      { id: 'lulu', name: 'LULU Exchange Al Khor', logoEmoji: '🛒', rate: 29.25, fee: 6, transferTime: 'Instant', rating: 4.8, mapsUrl: 'https://maps.google.com/?q=Lulu+Exchange+Al+Khor', phone: '+97444111222' },
      { id: 'trust', name: 'Trust Exchange Al Khor', logoEmoji: '🤝', rate: 29.18, fee: 5, transferTime: '2 hrs', rating: 4.3, mapsUrl: 'https://maps.google.com/?q=Trust+Exchange+Al+Khor', phone: '+97444111333' },
      { id: 'moneygram', name: 'MoneyGram Qatar', logoEmoji: '📨', rate: 28.95, fee: 10, transferTime: 'Next Day', rating: 3.9, mapsUrl: 'https://maps.google.com/?q=MoneyGram+Qatar', phone: '+97444112111' },
    ],
  },
  NPR: {
    indicativeRate: 35.4,
    houses: [
      { id: 'al-zaman', name: 'Al Zaman Exchange', logoEmoji: '🏦', rate: 35.4, fee: 5, transferTime: 'Instant', rating: 4.7, mapsUrl: 'https://maps.google.com/?q=Al+Zaman+Exchange+Qatar', phone: '+97444111444' },
      { id: 'western-union', name: 'Western Union Qatar', logoEmoji: '🌐', rate: 35.2, fee: 8, transferTime: '2 hrs', rating: 4.4, mapsUrl: 'https://maps.google.com/?q=Western+Union+Qatar', phone: '+97444111001' },
      { id: 'al-dar', name: 'Al Dar Exchange', logoEmoji: '🏛️', rate: 35.35, fee: 5, transferTime: 'Instant', rating: 4.5, mapsUrl: 'https://maps.google.com/?q=Al+Dar+Exchange+Qatar', phone: '+97444111555' },
      { id: 'lulu', name: 'LULU Exchange Al Khor', logoEmoji: '🛒', rate: 35.45, fee: 6, transferTime: 'Instant', rating: 4.8, mapsUrl: 'https://maps.google.com/?q=Lulu+Exchange+Al+Khor', phone: '+97444111222' },
      { id: 'trust', name: 'Trust Exchange Al Khor', logoEmoji: '🤝', rate: 35.38, fee: 5, transferTime: '2 hrs', rating: 4.3, mapsUrl: 'https://maps.google.com/?q=Trust+Exchange+Al+Khor', phone: '+97444111333' },
      { id: 'moneygram', name: 'MoneyGram Qatar', logoEmoji: '📨', rate: 35.1, fee: 10, transferTime: 'Next Day', rating: 3.9, mapsUrl: 'https://maps.google.com/?q=MoneyGram+Qatar', phone: '+97444112111' },
    ],
  },
  PHP: {
    indicativeRate: 15.35,
    houses: [
      { id: 'al-zaman', name: 'Al Zaman Exchange', logoEmoji: '🏦', rate: 15.35, fee: 5, transferTime: 'Instant', rating: 4.7, mapsUrl: 'https://maps.google.com/?q=Al+Zaman+Exchange+Qatar', phone: '+97444111444' },
      { id: 'western-union', name: 'Western Union Qatar', logoEmoji: '🌐', rate: 15.22, fee: 8, transferTime: '2 hrs', rating: 4.4, mapsUrl: 'https://maps.google.com/?q=Western+Union+Qatar', phone: '+97444111001' },
      { id: 'al-dar', name: 'Al Dar Exchange', logoEmoji: '🏛️', rate: 15.3, fee: 5, transferTime: 'Instant', rating: 4.5, mapsUrl: 'https://maps.google.com/?q=Al+Dar+Exchange+Qatar', phone: '+97444111555' },
      { id: 'lulu', name: 'LULU Exchange Al Khor', logoEmoji: '🛒', rate: 15.38, fee: 6, transferTime: 'Instant', rating: 4.8, mapsUrl: 'https://maps.google.com/?q=Lulu+Exchange+Al+Khor', phone: '+97444111222' },
      { id: 'moneygram', name: 'MoneyGram Qatar', logoEmoji: '📨', rate: 15.15, fee: 10, transferTime: 'Next Day', rating: 3.9, mapsUrl: 'https://maps.google.com/?q=MoneyGram+Qatar', phone: '+97444112111' },
    ],
  },
  EGP: {
    indicativeRate: 13.45,
    houses: [
      { id: 'al-zaman', name: 'Al Zaman Exchange', logoEmoji: '🏦', rate: 13.45, fee: 5, transferTime: 'Instant', rating: 4.6, mapsUrl: 'https://maps.google.com/?q=Al+Zaman+Exchange+Qatar', phone: '+97444111444' },
      { id: 'western-union', name: 'Western Union Qatar', logoEmoji: '🌐', rate: 13.35, fee: 8, transferTime: '2 hrs', rating: 4.3, mapsUrl: 'https://maps.google.com/?q=Western+Union+Qatar', phone: '+97444111001' },
      { id: 'al-dar', name: 'Al Dar Exchange', logoEmoji: '🏛️', rate: 13.4, fee: 5, transferTime: 'Instant', rating: 4.4, mapsUrl: 'https://maps.google.com/?q=Al+Dar+Exchange+Qatar', phone: '+97444111555' },
      { id: 'gulf', name: 'Gulf Exchange', logoEmoji: '🌍', rate: 13.38, fee: 5, transferTime: 'Instant', rating: 4.2, mapsUrl: 'https://maps.google.com/?q=Gulf+Exchange+Qatar', phone: '+97444111666' },
      { id: 'moneygram', name: 'MoneyGram Qatar', logoEmoji: '📨', rate: 13.28, fee: 10, transferTime: 'Next Day', rating: 3.8, mapsUrl: 'https://maps.google.com/?q=MoneyGram+Qatar', phone: '+97444112111' },
    ],
  },
  LKR: {
    indicativeRate: 82.1,
    houses: [
      { id: 'al-zaman', name: 'Al Zaman Exchange', logoEmoji: '🏦', rate: 82.1, fee: 5, transferTime: 'Instant', rating: 4.6, mapsUrl: 'https://maps.google.com/?q=Al+Zaman+Exchange+Qatar', phone: '+97444111444' },
      { id: 'western-union', name: 'Western Union Qatar', logoEmoji: '🌐', rate: 81.8, fee: 8, transferTime: '2 hrs', rating: 4.3, mapsUrl: 'https://maps.google.com/?q=Western+Union+Qatar', phone: '+97444111001' },
      { id: 'al-dar', name: 'Al Dar Exchange', logoEmoji: '🏛️', rate: 82.0, fee: 5, transferTime: 'Instant', rating: 4.4, mapsUrl: 'https://maps.google.com/?q=Al+Dar+Exchange+Qatar', phone: '+97444111555' },
      { id: 'habib', name: 'Habib Qatar International Exchange', logoEmoji: '🏢', rate: 81.95, fee: 6, transferTime: '2 hrs', rating: 4.1, mapsUrl: 'https://maps.google.com/?q=Habib+Qatar+International+Exchange', phone: '+97444111777' },
      { id: 'moneygram', name: 'MoneyGram Qatar', logoEmoji: '📨', rate: 81.6, fee: 10, transferTime: 'Next Day', rating: 3.8, mapsUrl: 'https://maps.google.com/?q=MoneyGram+Qatar', phone: '+97444112111' },
    ],
  },
};

function generateRateHistory(baseRate) {
  return Array.from({ length: 7 }, (_, index) => {
    const variation = (index - 3) * 0.04;
    return {
      date: `Day ${index + 1}`,
      rate: parseFloat((baseRate + variation).toFixed(2)),
    };
  });
}

const rateAlerts = [];
const affiliateClicks = [];

app.get('/exchange-rates', (req, res) => {
  const from = (req.query.from || 'QAR').toUpperCase();
  const to = (req.query.to || 'INR').toUpperCase();

  if (from !== 'QAR') {
    return res.status(400).json({ error: 'Only QAR as source currency is supported' });
  }

  const data = EXCHANGE_RATE_DATA[to];
  if (!data) {
    return res.status(404).json({ error: `Rates not found for ${to}` });
  }

  console.log(`--- Exchange Rates Request: QAR → ${to} ---`);

  return res.json({
    from,
    to,
    lastUpdated: 'Today 9:00 AM',
    indicativeRate: data.indicativeRate,
    houses: data.houses,
    history: generateRateHistory(data.indicativeRate),
  });
});

app.post('/rate-alerts', (req, res) => {
  const { currency, targetRate, userId = 'anonymous' } = req.body;

  if (!currency || typeof targetRate !== 'number') {
    return res.status(400).json({ error: 'currency and targetRate are required' });
  }

  const alert = {
    id: `alert-${Date.now()}`,
    userId,
    currency: currency.toUpperCase(),
    targetRate,
    createdAt: new Date().toISOString(),
  };

  rateAlerts.push(alert);
  console.log('--- Rate Alert Saved ---', alert);

  return res.status(201).json({ success: true, alert });
});

app.post('/affiliate-click', (req, res) => {
  const {
    exchangeHouseId,
    exchangeHouseName,
    currency,
    amount = 0,
  } = req.body;

  const click = {
    id: `click-${Date.now()}`,
    exchangeHouseId,
    exchangeHouseName,
    currency,
    amount,
    timestamp: new Date().toISOString(),
    ip: getClientIp(req),
  };

  affiliateClicks.push(click);
  console.log('--- Affiliate Referral Click ---', click);

  return res.json({ success: true, tracked: true });
});

// --- Housing Listings ---

const listingsStore = [
  {
    id: 'listing-1',
    title: 'Spacious Room near Al Khor Mall',
    area: 'Al Khor',
    areaSlug: 'alkhor',
    pricePerMonth: 1200,
    type: 'room',
    furnished: true,
    bedrooms: 1,
    bathrooms: 1,
    photoUrls: [
      'https://images.unsplash.com/photo-1522708323590-d24dbb6b0267?w=800',
      'https://images.unsplash.com/photo-1505693416388-ac5ce068fe85?w=800',
    ],
    description: 'Clean furnished room with shared kitchen. Near bus stop and Lulu Hypermarket.',
    amenities: ['WiFi', 'AC', 'Kitchen', 'Laundry'],
    genderPreference: 'any',
    nationalityPreference: 'any',
    posterNationality: 'Indian',
    posterNationalityFlag: '🇮🇳',
    whatsapp: '97455123456',
    phone: '+97455123456',
    contactName: 'Rahul',
    verified: true,
    scamFlagged: false,
    scamScore: 18,
    verdict: 'safe',
    flags: [],
    scamReason: 'No significant red flags detected.',
    scamRecommendation: 'Standard precautions apply — view before paying.',
    report_count: 0,
    status: 'approved',
    featured: true,
    latitude: 25.6804,
    longitude: 51.4969,
    createdAt: new Date(Date.now() - 2 * 86400000).toISOString(),
    shareUrl: 'https://raabta.app/listings/listing-1',
  },
  {
    id: 'listing-2',
    title: '2BHK Flat in Al Sadd',
    area: 'Doha',
    areaSlug: 'doha',
    pricePerMonth: 3200,
    type: 'flat',
    furnished: false,
    bedrooms: 2,
    bathrooms: 2,
    photoUrls: ['https://images.unsplash.com/photo-1560448204-e02f11c3d0e2?w=800'],
    description: 'Family flat with parking. Close to metro.',
    amenities: ['WiFi', 'AC', 'Parking', 'Balcony'],
    genderPreference: 'family',
    nationalityPreference: 'any',
    posterNationality: 'Pakistani',
    posterNationalityFlag: '🇵🇰',
    whatsapp: '97455987654',
    phone: '+97455987654',
    contactName: 'Ahmed',
    verified: true,
    scamFlagged: false,
    status: 'approved',
    featured: false,
    latitude: 25.2854,
    longitude: 51.5310,
    createdAt: new Date(Date.now() - 86400000).toISOString(),
    shareUrl: 'https://raabta.app/listings/listing-2',
  },
  {
    id: 'listing-3',
    title: 'Sharing Accommodation - Female Only',
    area: 'Lusail',
    areaSlug: 'lusail',
    pricePerMonth: 900,
    type: 'sharing',
    furnished: true,
    bedrooms: 1,
    bathrooms: 1,
    photoUrls: ['https://images.unsplash.com/photo-1484154218962-a197022b5858?w=800'],
    description: 'Bed space in shared villa. Filipino roommates welcome.',
    amenities: ['WiFi', 'AC', 'Kitchen'],
    genderPreference: 'femaleOnly',
    nationalityPreference: 'filipino',
    posterNationality: 'Filipino',
    posterNationalityFlag: '🇵🇭',
    whatsapp: '97455654321',
    phone: '+97455654321',
    contactName: 'Maria',
    verified: false,
    scamFlagged: true,
    scamScore: 82,
    verdict: 'likely_scam',
    flags: ['price_too_low', 'urgency_language', 'whatsapp_only'],
    scamReason: 'Price is far below market rate for Lusail with urgency language.',
    scamRecommendation: 'Do not pay any deposit before viewing. Verify the poster in person.',
    report_count: 0,
    status: 'approved',
    featured: false,
    latitude: 25.4244,
    longitude: 51.5074,
    createdAt: new Date(Date.now() - 4 * 86400000).toISOString(),
    shareUrl: 'https://raabta.app/listings/listing-3',
  },
  {
    id: 'listing-4',
    title: 'Modern Studio near Metro',
    area: 'Lusail',
    areaSlug: 'lusail',
    pricePerMonth: 2800,
    type: 'studio',
    furnished: true,
    bedrooms: 1,
    bathrooms: 1,
    photoUrls: ['https://images.unsplash.com/photo-1502672260266-1c1ef2d93688?w=800'],
    description: 'Fully furnished studio with gym access.',
    amenities: ['WiFi', 'AC', 'Parking', 'Gym'],
    genderPreference: 'any',
    nationalityPreference: 'any',
    posterNationality: 'Arabic',
    posterNationalityFlag: '🇶🇦',
    whatsapp: '97455432109',
    phone: '+97455432109',
    contactName: 'Khalid',
    verified: true,
    scamFlagged: false,
    status: 'approved',
    featured: false,
    latitude: 25.4244,
    longitude: 51.5074,
    createdAt: new Date(Date.now() - 3 * 86400000).toISOString(),
    shareUrl: 'https://raabta.app/listings/listing-4',
  },
  {
    id: 'listing-5',
    title: 'Budget Room - Al Wakrah',
    area: 'Al Wakrah',
    areaSlug: 'alwakrah',
    pricePerMonth: 750,
    type: 'room',
    furnished: false,
    bedrooms: 1,
    bathrooms: 1,
    photoUrls: ['https://images.unsplash.com/photo-1554995207-c18c203602cb?w=800'],
    description: 'Affordable room for workers. Bus to industrial area.',
    amenities: ['AC', 'Kitchen'],
    genderPreference: 'maleOnly',
    nationalityPreference: 'indian',
    posterNationality: 'Indian',
    posterNationalityFlag: '🇮🇳',
    whatsapp: '97455345678',
    phone: '+97455345678',
    contactName: 'Sunil',
    verified: false,
    scamFlagged: false,
    status: 'pending',
    featured: false,
    latitude: 25.1659,
    longitude: 51.5976,
    createdAt: new Date(Date.now() - 5 * 86400000).toISOString(),
    shareUrl: 'https://raabta.app/listings/listing-5',
  },
];

const listingReports = [];
const moderationQueue = [];

const areaCoords = {
  'Al Khor': [25.6804, 51.4969],
  Doha: [25.2854, 51.5310],
  Lusail: [25.4244, 51.5074],
  'Al Wakrah': [25.1659, 51.5976],
  Mesaieed: [24.9924, 51.5517],
  'Al Rayyan': [25.2919, 51.4244],
  'West Bay': [25.3254, 51.5300],
  'The Pearl': [25.3680, 51.5500],
};

function slugifyArea(area) {
  return String(area).toLowerCase().replace(/\s+/g, '');
}

app.get('/listings', (req, res) => {
  const {
    area,
    type,
    minPrice = '500',
    maxPrice = '5000',
    gender,
    nationality,
    q,
  } = req.query;

  let results = listingsStore.filter((l) => l.status === 'approved');

  if (area) {
    results = results.filter((l) => l.areaSlug === String(area).toLowerCase());
  }
  if (type && type !== 'all') {
    results = results.filter((l) => l.type === type);
  }
  results = results.filter(
    (l) =>
      l.pricePerMonth >= Number(minPrice) &&
      l.pricePerMonth <= Number(maxPrice),
  );
  if (gender && gender !== 'any') {
    results = results.filter((l) => l.genderPreference === gender);
  }
  if (nationality && nationality !== 'any') {
    results = results.filter((l) => l.nationalityPreference === nationality);
  }
  if (q) {
    const query = String(q).toLowerCase();
    results = results.filter(
      (l) =>
        l.title.toLowerCase().includes(query) ||
        l.area.toLowerCase().includes(query) ||
        l.description.toLowerCase().includes(query),
    );
  }

  results.sort((a, b) => {
    if (a.featured !== b.featured) return b.featured - a.featured;
    return new Date(b.createdAt) - new Date(a.createdAt);
  });

  console.log(`--- Listings Query: ${results.length} results ---`);
  return res.json({ listings: results, count: results.length });
});

app.get('/listings/:id', (req, res) => {
  const listing = listingsStore.find((l) => l.id === req.params.id);
  if (!listing) {
    return res.status(404).json({ error: 'Listing not found' });
  }
  return res.json(listing);
});

app.post('/listings', (req, res) => {
  const body = req.body;
  const id = `listing-${Date.now()}`;
  const coords = areaCoords[body.area] || areaCoords.Doha;

  const listing = {
    id,
    title: body.title,
    area: body.area,
    areaSlug: slugifyArea(body.area),
    pricePerMonth: body.pricePerMonth,
    type: body.type,
    furnished: body.furnished ?? false,
    bedrooms: body.bedrooms ?? 1,
    bathrooms: body.bathrooms ?? 1,
    photoUrls: body.photoUrls || [],
    description: body.description || '',
    amenities: body.amenities || [],
    genderPreference: body.genderPreference || 'any',
    nationalityPreference: body.nationalityPreference || 'any',
    posterNationality: 'Expat',
    posterNationalityFlag: '🌍',
    whatsapp: body.whatsapp,
    phone: body.phone || body.whatsapp,
    contactName: body.contactName || 'Owner',
    verified: false,
    scamFlagged: false,
    status: 'pending',
    featured: Boolean(body.featured && body.isPremiumUser),
    latitude: coords[0],
    longitude: coords[1],
    createdAt: new Date().toISOString(),
    shareUrl: `https://raabta.app/listings/${id}`,
  };

  listingsStore.unshift(listing);
  moderationQueue.push({
    listingId: id,
    title: listing.title,
    status: 'pending',
    submittedAt: listing.createdAt,
  });

  console.log('--- New Listing (Pending) ---', listing.id, listing.title);

  // Async scam scan — does not block response
  runScamScanForListing(listing, req.body)
    .then((result) => {
      console.log('--- Scam Scan ---', listing.id, result.verdict, result.scamScore);
    })
    .catch((err) => console.error('Scam scan failed:', listing.id, err.message));

  return res.status(201).json(listing);
});

app.post('/listings/upload-photo', (req, res) => {
  const uploadId = Date.now();
  const url = `https://images.unsplash.com/photo-1560448204-e02f11c3d0e2?w=800&upload=${uploadId}`;
  console.log('--- Photo Upload (mock URL) ---', url);
  return res.json({ url });
});

app.post('/listings/:id/report', (req, res) => {
  const { reason, details, reporterContact } = req.body;
  const report = {
    id: `report-${Date.now()}`,
    listingId: req.params.id,
    reason: reason || 'Suspicious listing',
    details: details || '',
    reporterContact: reporterContact || '',
    submittedAt: new Date().toISOString(),
  };

  listingReports.push(report);

  const listing = listingsStore.find((l) => l.id === req.params.id);
  if (listing && String(reason).toLowerCase().includes('scam')) {
    listing.scamFlagged = true;
  }

  console.log('--- Listing Report ---', report);
  return res.status(201).json({ success: true, report });
});

app.patch('/listings/:id/verify', (req, res) => {
  const adminKey = req.headers['x-admin-key'];
  if (adminKey !== process.env.ADMIN_KEY && adminKey !== 'raabta-admin-dev') {
    return res.status(403).json({ error: 'Unauthorized' });
  }

  const listing = listingsStore.find((l) => l.id === req.params.id);
  if (!listing) {
    return res.status(404).json({ error: 'Listing not found' });
  }

  listing.verified = req.body.verified !== false;
  listing.status = req.body.status || 'approved';
  listing.scamFlagged = req.body.scamFlagged === true;

  const queueItem = moderationQueue.find((q) => q.listingId === listing.id);
  if (queueItem) queueItem.status = listing.status;

  console.log('--- Listing Verified ---', listing.id, listing.status);
  return res.json(listing);
});

// --- AI Scam Detection ---

app.post('/api/listings/scan-scam', async (req, res) => {
  try {
    const {
      listingId,
      title,
      description,
      price,
      area,
      contactPhone,
      photos = [],
      bedrooms,
      type,
      posterNationality,
    } = req.body;

    if (!title && !description && !price) {
      return res.status(400).json({
        error: 'At least title, description, or price is required',
      });
    }

    const rateLimit = checkRateLimit(getClientIp(req));
    if (!rateLimit.allowed) {
      return res.status(429).json({
        error: 'Rate limit exceeded',
        message: `Try again in ${rateLimit.retryAfterMinutes} minutes.`,
      });
    }

    let listing = null;
    if (listingId) {
      listing = listingsStore.find((l) => l.id === listingId);
    }

    const phone = contactPhone || listing?.phone || listing?.whatsapp || '';
    const memoryCount = countInMemoryListingsByPhone(phone, listingId);
    const firestoreCount = await firestoreService.countListingsByPhone(phone, listingId);
    const duplicatePhoneCount = Math.max(memoryCount, firestoreCount);

    const scanInput = {
      title: title || listing?.title || '',
      description: description || listing?.description || '',
      price: price ?? listing?.pricePerMonth,
      area: area || listing?.area || '',
      contactPhone: phone,
      photos: photos.length ? photos : listing?.photoUrls || [],
      bedrooms: bedrooms ?? listing?.bedrooms,
      type: type || listing?.type,
      posterNationality: posterNationality || listing?.posterNationality,
    };

    const scanResult = await scanListing(scanInput, { duplicatePhoneCount });

    if (listing) {
      applyScamResultToListing(listing, scanResult);
    }

    if (listingId) {
      await firestoreService.saveScamScan(listingId, scanResult);
    }

    console.log('--- Scam Scan API ---', listingId || 'new', scanResult.verdict, scanResult.scamScore);

    return res.json({
      listingId: listingId || null,
      scamScore: scanResult.scamScore,
      verdict: scanResult.verdict,
      flags: scanResult.flags,
      reason: scanResult.reason,
      recommendation: scanResult.recommendation,
      scannedAt: scanResult.scannedAt,
      source: scanResult.source,
    });
  } catch (error) {
    console.error('scan-scam error:', error);
    return res.status(500).json({
      error: 'Scam scan failed',
      message: error.message,
    });
  }
});

app.post('/api/listings/report-scam', async (req, res) => {
  try {
    const {
      listingId,
      reason = 'Scam report',
      details = '',
      reporterId = 'anonymous',
      reporterContact = '',
    } = req.body;

    if (!listingId) {
      return res.status(400).json({ error: 'listingId is required' });
    }

    const listing = listingsStore.find((l) => l.id === listingId);
    const report = {
      id: `scam-report-${Date.now()}`,
      listingId,
      reason,
      details,
      reporterId,
      reporterContact,
      submittedAt: new Date().toISOString(),
    };

    listingReports.push(report);

    let reportCount = (listing?.report_count || 0) + 1;
    let autoHidden = false;

    if (listing) {
      listing.report_count = reportCount;
      listing.lastReportAt = report.submittedAt;
      if (reportCount > 3) {
        listing.status = 'hidden_pending_review';
        listing.scamFlagged = true;
        listing.hiddenReason = 'auto_hidden_reports';
        autoHidden = true;
      }
    }

    const firestoreResult = await firestoreService.incrementReportCount(listingId, {
      reason,
      details,
      reporterId,
      reporterContact,
    });

    if (firestoreResult.saved) {
      reportCount = firestoreResult.reportCount;
      autoHidden = firestoreResult.autoHidden;
    }

    if (autoHidden) {
      await firestoreService.notifyAdmin(
        '🚨 Listing auto-hidden',
        `"${listing?.title || listingId}" received ${reportCount} scam reports`,
        { listingId, reportCount, action: 'review_required' },
      );
    } else {
      await firestoreService.notifyAdmin(
        '⚠️ New scam report',
        `Listing ${listingId} reported: ${reason}`,
        { listingId, reportCount },
      );
    }

    console.log('--- Scam Report ---', listingId, 'count:', reportCount, 'hidden:', autoHidden);

    return res.status(201).json({
      success: true,
      report,
      report_count: reportCount,
      auto_hidden: autoHidden,
      status: autoHidden ? 'hidden_pending_review' : listing?.status || 'unknown',
    });
  } catch (error) {
    console.error('report-scam error:', error);
    return res.status(500).json({
      error: 'Failed to submit scam report',
      message: error.message,
    });
  }
});

// --- Visa Guides ---

const visaGuidesStore = {
  iqama_renewal: {
    id: 'iqama_renewal',
    categoryId: 'iqama_renewal',
    title: { en: 'Iqama Renewal Guide', hi: 'इकामा नवीनीकरण गाइड', ur: 'اقامہ تجدید گائیڈ', ar: 'دليل تجديد الإقامة' },
    summary: { en: 'Renew your Qatar residence permit through Metrash2.', hi: 'Metrash2 के माध्यम से इकामा नवीनीकरण करें।' },
    officialLinks: [
      { name: 'Metrash2', url: 'https://portal.moi.gov.qa' },
      { name: 'Hukoomi', url: 'https://www.hukoomi.gov.qa' },
      { name: 'Hayya Portal', url: 'https://hayya.qa' },
    ],
    steps: [
      { stepNumber: 1, title: { en: 'Check eligibility on Metrash2' }, description: { en: 'Open Metrash2 and verify Iqama renewal eligibility. Clear any fines first.' }, documents: ['Passport', 'QID', 'Medical certificate (if due)'], cost: '100–200 QR', time: '10 mins' },
      { stepNumber: 2, title: { en: 'Complete medical check' }, description: { en: 'Visit MOI-approved medical centre if fitness certificate is expired.' }, documents: ['QID', 'Passport copy'], cost: '100–150 QR', time: '1–2 hours' },
      { stepNumber: 3, title: { en: 'Pay renewal fees' }, description: { en: 'Residency Services → Iqama Renewal → Pay online.' }, documents: ['Bank card'], cost: 'As shown in Metrash2', time: '5 mins' },
      { stepNumber: 4, title: { en: 'Sponsor approval' }, description: { en: 'Employer approves renewal in MOI system if required.' }, documents: ['Contract (if requested)'], cost: 'Free', time: '1–3 days' },
      { stepNumber: 5, title: { en: 'Collect updated Iqama' }, description: { en: 'New validity reflects in Metrash2 within a few days.' }, documents: ['Old QID'], cost: 'Free', time: '1–2 days' },
    ],
  },
  exit_permit: {
    id: 'exit_permit',
    categoryId: 'exit_permit',
    title: { en: 'Exit Permit Guide' },
    summary: { en: 'Apply for exit permit before leaving Qatar.' },
    officialLinks: [
      { name: 'Metrash2', url: 'https://portal.moi.gov.qa' },
      { name: 'Hukoomi', url: 'https://www.hukoomi.gov.qa' },
      { name: 'Hayya Portal', url: 'https://hayya.qa' },
    ],
    steps: [
      { stepNumber: 1, title: { en: 'Verify travel eligibility' }, description: { en: 'Check Metrash2 for travel bans or fines.' }, documents: ['QID', 'Passport'], cost: 'Free', time: '5 mins' },
      { stepNumber: 2, title: { en: 'Apply via Metrash2' }, description: { en: 'Select Exit Permit under Residency Services.' }, documents: ['Passport', 'QID'], cost: '50–100 QR', time: '10 mins' },
      { stepNumber: 3, title: { en: 'Sponsor approval' }, description: { en: 'Wait for employer to approve exit request.' }, documents: ['NOC (if required)'], cost: 'Free', time: '1–2 days' },
      { stepNumber: 4, title: { en: 'Travel' }, description: { en: 'Carry passport and QID when departing.' }, documents: ['Passport', 'QID'], cost: 'Free', time: '—' },
    ],
  },
  family_visa: {
    id: 'family_visa',
    categoryId: 'family_visa',
    title: { en: 'Family Visa Guide' },
    summary: { en: 'Bring spouse and children to Qatar.' },
    officialLinks: [
      { name: 'Metrash2', url: 'https://portal.moi.gov.qa' },
      { name: 'Hukoomi', url: 'https://www.hukoomi.gov.qa' },
    ],
    steps: [
      { stepNumber: 1, title: { en: 'Check salary requirements' }, description: { en: 'Confirm minimum salary for family sponsorship.' }, documents: ['Salary certificate'], cost: 'Free', time: '1 day' },
      { stepNumber: 2, title: { en: 'Apply family visa' }, description: { en: 'Submit via Metrash2 or MOI service centre.' }, documents: ['Passports', 'Marriage/birth certificates'], cost: '500+ QR', time: '1 week' },
      { stepNumber: 3, title: { en: 'Medical for dependents' }, description: { en: 'Dependents complete medical upon arrival.' }, documents: ['Passports'], cost: '100 QR each', time: '1 day' },
      { stepNumber: 4, title: { en: 'QID for family' }, description: { en: 'Apply QID after medical clearance.' }, documents: ['Photos', 'Passports'], cost: '100 QR', time: '3–5 days' },
      { stepNumber: 5, title: { en: 'Health insurance' }, description: { en: 'Register on employer health plan.' }, documents: ['QID copies'], cost: 'Varies', time: '1–3 days' },
      { stepNumber: 6, title: { en: 'School enrollment' }, description: { en: 'Contact schools for admission if applicable.' }, documents: ['QID', 'Records'], cost: 'Varies', time: '1–2 weeks' },
      { stepNumber: 7, title: { en: 'Tenancy update' }, description: { en: 'Update lease if required for family size.' }, documents: ['Lease'], cost: 'Varies', time: '1 week' },
    ],
  },
  sponsor_transfer: {
    id: 'sponsor_transfer',
    categoryId: 'sponsor_transfer',
    title: { en: 'Sponsor Transfer Guide' },
    summary: { en: 'Change employer or transfer sponsorship.' },
    officialLinks: [
      { name: 'Metrash2', url: 'https://portal.moi.gov.qa' },
      { name: 'Hukoomi', url: 'https://www.hukoomi.gov.qa' },
    ],
    steps: [
      { stepNumber: 1, title: { en: 'Obtain NOC' }, description: { en: 'Request No Objection Certificate from current sponsor.' }, documents: ['NOC letter'], cost: 'Free', time: '3–7 days' },
      { stepNumber: 2, title: { en: 'New employer submits request' }, description: { en: 'New company initiates transfer in MOI.' }, documents: ['Passport', 'QID'], cost: 'Varies', time: '2–5 days' },
      { stepNumber: 3, title: { en: 'Sign new contract' }, description: { en: 'Complete via Ministry of Labour portal.' }, documents: ['Passport', 'QID'], cost: 'Free', time: '1–2 days' },
      { stepNumber: 4, title: { en: 'Pay transfer fees' }, description: { en: 'Pay via Metrash2.' }, documents: ['Bank card'], cost: '500–1500 QR', time: '10 mins' },
      { stepNumber: 5, title: { en: 'Medical (if required)' }, description: { en: 'Complete medical if mandated.' }, documents: ['QID'], cost: '100 QR', time: '1 day' },
      { stepNumber: 6, title: { en: 'Updated QID issued' }, description: { en: 'New sponsor on QID.' }, documents: ['Old QID'], cost: 'Free', time: '3–5 days' },
    ],
  },
  medical: {
    id: 'medical',
    categoryId: 'medical',
    title: { en: 'Medical Fitness Guide' },
    summary: { en: 'Complete mandatory medical for residency.' },
    officialLinks: [
      { name: 'Hukoomi', url: 'https://www.hukoomi.gov.qa' },
      { name: 'Metrash2', url: 'https://portal.moi.gov.qa' },
    ],
    steps: [
      { stepNumber: 1, title: { en: 'Book approved centre' }, description: { en: 'Find MOI-approved medical centre via Hukoomi.' }, documents: ['QID', 'Passport'], cost: 'Free', time: '10 mins' },
      { stepNumber: 2, title: { en: 'Attend medical test' }, description: { en: 'Blood test, X-ray, general check-up.' }, documents: ['QID', 'Passport'], cost: '100–150 QR', time: '1–2 hours' },
      { stepNumber: 3, title: { en: 'Receive certificate' }, description: { en: 'Results sent to MOI electronically.' }, documents: ['Receipt'], cost: 'Free', time: '1–3 days' },
    ],
  },
  qatar_id: {
    id: 'qatar_id',
    categoryId: 'qatar_id',
    title: { en: 'Qatar ID Guide' },
    summary: { en: 'Apply for or renew Qatar ID.' },
    officialLinks: [
      { name: 'Metrash2', url: 'https://portal.moi.gov.qa' },
      { name: 'Hukoomi', url: 'https://www.hukoomi.gov.qa' },
    ],
    steps: [
      { stepNumber: 1, title: { en: 'Check application type' }, description: { en: 'New, renewal, or replacement via Metrash2.' }, documents: ['Passport'], cost: 'Free', time: '5 mins' },
      { stepNumber: 2, title: { en: 'Submit biometrics' }, description: { en: 'Visit MOI service centre.' }, documents: ['Passport', 'Photos'], cost: '100 QR', time: '30 mins' },
      { stepNumber: 3, title: { en: 'Pay fees' }, description: { en: 'Pay QID fees online or at centre.' }, documents: ['Bank card'], cost: '100–200 QR', time: '5 mins' },
      { stepNumber: 4, title: { en: 'Collect QID' }, description: { en: 'Collect from centre or authorized delivery.' }, documents: ['Receipt'], cost: 'Free', time: '5–7 days' },
    ],
  },
};

function localizeGuide(guide, langCode) {
  const pick = (field) => {
    if (!field) return '';
    if (typeof field === 'string') return field;
    return field[langCode] || field.en || Object.values(field)[0];
  };

  return {
    ...guide,
    title: pick(guide.title),
    summary: pick(guide.summary),
    steps: guide.steps.map((step) => ({
      ...step,
      title: pick(step.title),
      description: pick(step.description),
    })),
  };
}

app.get('/visa-guides/:categoryId', (req, res) => {
  const guide = visaGuidesStore[req.params.categoryId];
  if (!guide) {
    return res.status(404).json({ error: 'Guide not found' });
  }
  const lang = req.query.language || 'en';
  return res.json(localizeGuide(guide, lang));
});

// --- Document Scan ---

const documentScanStore = new Map();

function getScanMonthKey() {
  const now = new Date();
  return `${now.getFullYear()}_${String(now.getMonth() + 1).padStart(2, '0')}`;
}

function checkScanLimit(ip, isPremium) {
  if (isPremium) return { allowed: true, remaining: 999 };
  const key = `${ip}_${getScanMonthKey()}`;
  const count = documentScanStore.get(key) || 0;
  if (count >= 3) {
    return { allowed: false, remaining: 0 };
  }
  return { allowed: true, remaining: 3 - count };
}

function incrementScanCount(ip) {
  const key = `${ip}_${getScanMonthKey()}`;
  documentScanStore.set(key, (documentScanStore.get(key) || 0) + 1);
}

app.post('/api/document-scan', async (req, res) => {
  try {
    const { imageBase64, language = 'English', isPremium = false } = req.body;
    if (!imageBase64) {
      return res.status(400).json({ error: 'imageBase64 is required' });
    }

    const clientIp = getClientIp(req);
    const scanLimit = checkScanLimit(clientIp, isPremium);

    if (!scanLimit.allowed) {
      return res.status(429).json({
        error: 'Scan limit exceeded',
        message: 'Free tier allows 3 document scans per month. Upgrade to Premium for unlimited scans.',
      });
    }

    if (!isPremium) incrementScanCount(clientIp);

    if (!process.env.ANTHROPIC_API_KEY) {
      return res.json({
        documentType: 'Qatar Residence Permit (Iqama)',
        keyDates: ['Issue date: 15 Jan 2024', 'Expiry date: 15 Jan 2026'],
        importantInfo: ['Sponsor: ABC Trading W.L.L.', 'Profession: Sales Representative'],
        actionNeeded: 'Your document appears valid. Renew via Metrash2 at least 30 days before expiry.',
        summary: 'AI analysis unavailable without API key. Showing sample result.',
      });
    }

    const anthropic = new Anthropic({ apiKey: process.env.ANTHROPIC_API_KEY });

    const response = await anthropic.messages.create({
      model: 'claude-sonnet-4-6',
      max_tokens: 1024,
      messages: [
        {
          role: 'user',
          content: [
            {
              type: 'image',
              source: {
                type: 'base64',
                media_type: 'image/jpeg',
                data: imageBase64,
              },
            },
            {
              type: 'text',
              text: `You are Raabta AI helping expats in Qatar. Analyze this document image. Respond ONLY with valid JSON (no markdown) in this format:
{"documentType":"","keyDates":[],"importantInfo":[],"actionNeeded":"","summary":""}
Explain in simple ${language}. Never guess legal details — say if unclear.`,
            },
          ],
        },
      ],
    });

    const text = response.content
      .filter((b) => b.type === 'text')
      .map((b) => b.text)
      .join('\n')
      .trim();

    let parsed;
    try {
      parsed = JSON.parse(text.replace(/```json|```/g, '').trim());
    } catch {
      parsed = {
        documentType: 'Qatar Document',
        keyDates: [],
        importantInfo: [text],
        actionNeeded: 'Review the document details carefully.',
        summary: text.slice(0, 300),
      };
    }

    console.log('--- Document Scan ---', clientIp, parsed.documentType);
    return res.json(parsed);
  } catch (error) {
    console.error('Document scan error:', error);
    return res.status(500).json({ error: 'Document scan failed', message: error.message });
  }
});

app.post('/api/chat', async (req, res) => {
  try {
    const { message, language = 'English', conversationHistory = [] } = req.body;

    if (!message || typeof message !== 'string' || message.trim().length === 0) {
      return res.status(400).json({ error: 'message is required' });
    }

    if (!process.env.ANTHROPIC_API_KEY) {
      return res.status(500).json({ error: 'ANTHROPIC_API_KEY is not configured' });
    }

    const clientIp = getClientIp(req);
    const rateLimit = checkRateLimit(clientIp);

    if (!rateLimit.allowed) {
      return res.status(429).json({
        error: 'Rate limit exceeded',
        message: `Free tier allows ${RATE_LIMIT_MAX} requests per hour. Try again in ${rateLimit.retryAfterMinutes} minutes.`,
      });
    }

    const anthropic = new Anthropic({
      apiKey: process.env.ANTHROPIC_API_KEY,
    });

    const history = normalizeHistory(conversationHistory);
    const messages = [
      ...history,
      { role: 'user', content: message.trim() },
    ];

    console.log('--- Raabta Chat Request ---');
    console.log('IP:', clientIp);
    console.log('Language:', language);
    console.log('Message:', message.trim());
    console.log('History length:', history.length);
    console.log('Remaining requests:', rateLimit.remaining);

    const response = await anthropic.messages.create({
      model: 'claude-sonnet-4-6',
      max_tokens: 1024,
      system: buildSystemPrompt(language),
      messages,
    });

    const reply =
      response.content
        .filter((block) => block.type === 'text')
        .map((block) => block.text)
        .join('\n')
        .trim() || 'Sorry, I could not generate a response. Please try again.';

    console.log('Reply:', reply);
    console.log('---------------------------');

    return res.json({ reply });
  } catch (error) {
    console.error('Chat error:', error);
    return res.status(500).json({
      error: 'Failed to generate response',
      message: error.message,
    });
  }
});

// --- Push Notifications ---

app.post('/api/notifications/register-token', async (req, res) => {
  try {
    const { userId, fcmToken, platform } = req.body;
    if (!userId || !fcmToken) {
      return res.status(400).json({ error: 'userId and fcmToken are required' });
    }
    const result = await registerFcmToken(userId, fcmToken, platform);
    return res.json({ success: true, ...result });
  } catch (error) {
    console.error('register-token error:', error);
    return res.status(500).json({ error: error.message });
  }
});

app.post('/api/notifications/send', async (req, res) => {
  try {
    const adminKey = req.headers['x-admin-key'];
    if (adminKey !== process.env.ADMIN_KEY && adminKey !== 'raabta-admin-dev') {
      return res.status(403).json({ error: 'Unauthorized' });
    }

    const { userId, title, body, data, language, type } = req.body;
    if (!userId || !title || !body) {
      return res.status(400).json({ error: 'userId, title, and body are required' });
    }

    const result = await sendPushNotification({
      userId,
      title,
      body,
      data: data || {},
      language,
      type: type || NOTIFICATION_TYPES.ADMIN_ANNOUNCEMENT,
    });

    return res.json(result);
  } catch (error) {
    console.error('send notification error:', error);
    return res.status(500).json({ error: error.message });
  }
});

app.post('/api/notifications/community-reply', async (req, res) => {
  try {
    const { userId, questionTitle, replyPreview } = req.body;
    if (!userId) return res.status(400).json({ error: 'userId is required' });
    const result = await sendCommunityReplyNotification(userId, {
      questionTitle: questionTitle || 'your question',
      replyPreview: replyPreview || 'New reply',
    });
    return res.json(result);
  } catch (error) {
    return res.status(500).json({ error: error.message });
  }
});

app.post('/api/notifications/job-match', async (req, res) => {
  try {
    const { userId, jobTitle, company, matchScore } = req.body;
    if (!userId) return res.status(400).json({ error: 'userId is required' });
    const result = await sendJobMatchNotification(userId, {
      jobTitle: jobTitle || 'New job',
      company: company || 'Employer',
      matchScore: matchScore || 80,
    });
    return res.json(result);
  } catch (error) {
    return res.status(500).json({ error: error.message });
  }
});

app.post('/api/notifications/admin-announcement', async (req, res) => {
  try {
    const adminKey = req.headers['x-admin-key'];
    if (adminKey !== process.env.ADMIN_KEY && adminKey !== 'raabta-admin-dev') {
      return res.status(403).json({ error: 'Unauthorized' });
    }
    const { userIds, title, body, route } = req.body;
    const results = await sendAdminAnnouncement(userIds, { title, body, route });
    return res.json({ success: true, count: results.length, results });
  } catch (error) {
    return res.status(500).json({ error: error.message });
  }
});

app.post('/api/notifications/trigger-daily', async (req, res) => {
  try {
    const adminKey = req.headers['x-admin-key'];
    if (adminKey !== process.env.ADMIN_KEY && adminKey !== 'raabta-admin-dev') {
      return res.status(403).json({ error: 'Unauthorized' });
    }
    const result = await runDailyNotificationJobs();
    return res.json({ success: true, ...result });
  } catch (error) {
    return res.status(500).json({ error: error.message });
  }
});

app.post('/api/notifications/trigger-weekly', async (req, res) => {
  try {
    const adminKey = req.headers['x-admin-key'];
    if (adminKey !== process.env.ADMIN_KEY && adminKey !== 'raabta-admin-dev') {
      return res.status(403).json({ error: 'Unauthorized' });
    }
    const result = await runWeeklyDigest();
    return res.json({ success: true, sent: result.sent });
  } catch (error) {
    return res.status(500).json({ error: error.message });
  }
});

app.listen(PORT, () => {
  console.log(`Raabta AI server running on http://localhost:${PORT}`);
  startNotificationScheduler();
});
