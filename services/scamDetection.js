/**
 * Raabta Housing Scam Detection
 * Rule-based pre-checks + Claude AI analysis + optional Google Vision
 */

const Anthropic = require('@anthropic-ai/sdk');

// ─── Qatar market benchmarks (monthly QR) ───────────────────────────────────
const MARKET_RATES = {
  room: {
    default: { min: 700, max: 2200 },
    'al khor': { min: 700, max: 1800 },
    'ras laffan': { min: 800, max: 2000 },
    doha: { min: 1000, max: 2500 },
    lusail: { min: 900, max: 2200 },
    'west bay': { min: 1500, max: 3500 },
    'the pearl': { min: 1800, max: 4000 },
  },
  studio: {
    default: { min: 1500, max: 4000 },
    doha: { min: 1800, max: 4500 },
    'al khor': { min: 1200, max: 2800 },
  },
  flat: {
    default: { min: 2500, max: 12000 },
    doha: { min: 3000, max: 15000 },
    'al khor': { min: 2000, max: 6000 },
    lusail: { min: 2800, max: 9000 },
  },
  sharing: {
    default: { min: 500, max: 1500 },
    doha: { min: 600, max: 1800 },
  },
};

const DEPOSIT_PATTERNS = [
  /pay\s+(?:the\s+)?deposit\s+before\s+viewing/i,
  /deposit\s+before\s+(?:you\s+)?(?:view|visit|see)/i,
  /send\s+(?:money|deposit|advance)\s+before/i,
  /wire\s+transfer\s+before\s+viewing/i,
  /pay\s+first\s+(?:then|before)/i,
  /advance\s+payment\s+(?:required|before)/i,
];

const URGENCY_PATTERNS = [
  /going\s+fast/i,
  /limited\s+time/i,
  /act\s+now/i,
  /hurry/i,
  /first\s+come\s+first\s+serve/i,
  /won'?t\s+last\s+long/i,
  /only\s+\d+\s+(?:days?|hours?)\s+left/i,
  /urgent/i,
  /must\s+decide\s+today/i,
];

const WHATSAPP_ONLY_PATTERNS = [
  /whatsapp\s+only/i,
  /no\s+calls?\s+(?:please|only)/i,
  /message\s+on\s+whatsapp\s+only/i,
  /don'?t\s+call/i,
  /text\s+only/i,
];

const SCAM_SYSTEM_PROMPT = `You are a fraud detection AI for a Qatar housing platform.
Analyze this listing and return ONLY valid JSON (no markdown) with:
{
  "scamScore": 0-100,
  "flags": ["flag_id", ...],
  "verdict": "safe" | "suspicious" | "likely_scam",
  "reason": "string",
  "recommendation": "string"
}

Flag IDs you may use:
price_too_low, deposit_before_viewing, non_qatar_phone, stolen_photos,
urgency_language, whatsapp_only, grammar_inconsistency, duplicate_phone,
vague_description, unrealistic_amenities

Base scamScore on: pricing vs Qatar market rates, language red flags,
contact info patterns, urgency signals, and description consistency.
Be conservative — only use verdict "likely_scam" if score > 70.
Use "suspicious" for scores 40-70. Use "safe" for scores below 40.`;

function normalizePhone(phone) {
  if (!phone) return '';
  return String(phone).replace(/[\s\-().]/g, '');
}

function isQatarPhone(phone) {
  const normalized = normalizePhone(phone);
  if (!normalized) return false;
  if (normalized.startsWith('+974')) return normalized.length >= 11;
  if (normalized.startsWith('974')) return normalized.length >= 10;
  if (/^\d{8}$/.test(normalized)) return true;
  return false;
}

function inferPropertyType(title, description, bedrooms) {
  const text = `${title} ${description}`.toLowerCase();
  if (/\bstudio\b/.test(text)) return 'studio';
  if (/\bsharing\b|\bbed\s*space\b|\bpartition\b/.test(text)) return 'sharing';
  if (/\broom\b/.test(text)) return 'room';
  if (bedrooms >= 2 || /\b2\s*bhk\b|\b3\s*bhk\b|\bflat\b|\bapartment\b|\bvilla\b/.test(text)) {
    return 'flat';
  }
  return 'room';
}

function getMarketRange(area, propertyType, bedrooms) {
  const areaKey = String(area || '').toLowerCase().trim();
  const typeRates = MARKET_RATES[propertyType] || MARKET_RATES.room;
  const areaRates = typeRates[areaKey] || typeRates.default;

  if (propertyType === 'flat' && bedrooms >= 3) {
    return { min: areaRates.min * 1.3, max: areaRates.max * 1.5 };
  }
  return areaRates;
}

function runRuleChecks(input, duplicatePhoneCount = 0) {
  const flags = [];
  const {
    title = '',
    description = '',
    price,
    area = '',
    contactPhone = '',
    photos = [],
  } = input;

  const fullText = `${title} ${description}`;
  const propertyType = inferPropertyType(title, description, input.bedrooms || 1);
  const numericPrice = Number(price);

  if (Number.isFinite(numericPrice) && numericPrice > 0) {
    const range = getMarketRange(area, propertyType, input.bedrooms || 1);
    const threshold = range.min * 0.65;
    if (numericPrice < threshold) {
      flags.push('price_too_low');
    }
  }

  for (const pattern of DEPOSIT_PATTERNS) {
    if (pattern.test(fullText)) {
      flags.push('deposit_before_viewing');
      break;
    }
  }

  if (contactPhone && !isQatarPhone(contactPhone)) {
    flags.push('non_qatar_phone');
  }

  for (const pattern of URGENCY_PATTERNS) {
    if (pattern.test(fullText)) {
      flags.push('urgency_language');
      break;
    }
  }

  for (const pattern of WHATSAPP_ONLY_PATTERNS) {
    if (pattern.test(fullText)) {
      flags.push('whatsapp_only');
      break;
    }
  }

  if (duplicatePhoneCount > 1) {
    flags.push('duplicate_phone');
  }

  if (!photos || photos.length === 0) {
    flags.push('no_photos');
  }

  return flags;
}

function estimateScoreFromFlags(flags) {
  const weights = {
    price_too_low: 25,
    deposit_before_viewing: 30,
    non_qatar_phone: 15,
    stolen_photos: 35,
    urgency_language: 12,
    whatsapp_only: 10,
    grammar_inconsistency: 8,
    duplicate_phone: 20,
    vague_description: 8,
    unrealistic_amenities: 10,
    no_photos: 5,
  };

  let score = 0;
  const unique = [...new Set(flags)];
  for (const flag of unique) {
    score += weights[flag] || 5;
  }
  return Math.min(100, score);
}

function verdictFromScore(score) {
  if (score > 70) return 'likely_scam';
  if (score >= 40) return 'suspicious';
  return 'safe';
}

function parseClaudeJson(text) {
  const trimmed = String(text).trim();
  const fenced = trimmed.match(/```(?:json)?\s*([\s\S]*?)```/);
  const raw = fenced ? fenced[1].trim() : trimmed;
  return JSON.parse(raw);
}

async function analyzeWithClaude(input, ruleFlags, context = {}) {
  if (!process.env.ANTHROPIC_API_KEY) {
    const score = estimateScoreFromFlags(ruleFlags);
    return {
      scamScore: score,
      flags: ruleFlags,
      verdict: verdictFromScore(score),
      reason: ruleFlags.length
        ? `Rule-based analysis detected ${ruleFlags.length} concern(s).`
        : 'No major red flags detected by automated checks.',
      recommendation: score > 70
        ? 'Do not pay any deposit before viewing in person. Verify the landlord via video call.'
        : score >= 40
          ? 'Meet in person before paying. Verify ownership documents.'
          : 'Standard precautions apply — view the property before transferring money.',
      source: 'rules_only',
    };
  }

  const anthropic = new Anthropic({ apiKey: process.env.ANTHROPIC_API_KEY });

  const userPayload = {
    listing: {
      title: input.title,
      description: input.description,
      price: input.price,
      area: input.area,
      contactPhone: input.contactPhone,
      bedrooms: input.bedrooms,
      type: input.type,
      posterNationality: input.posterNationality,
      photoCount: (input.photos || []).length,
    },
    preDetectedFlags: ruleFlags,
    duplicatePhoneListings: context.duplicatePhoneCount || 0,
    visionFlags: context.visionFlags || [],
  };

  const response = await anthropic.messages.create({
    model: process.env.ANTHROPIC_MODEL || 'claude-sonnet-4-6',
    max_tokens: 1024,
    system: SCAM_SYSTEM_PROMPT,
    messages: [
      {
        role: 'user',
        content: `Analyze this Qatar housing listing:\n${JSON.stringify(userPayload, null, 2)}`,
      },
    ],
  });

  const text = response.content
    .filter((block) => block.type === 'text')
    .map((block) => block.text)
    .join('\n');

  try {
    const parsed = parseClaudeJson(text);
    const mergedFlags = [
      ...new Set([...(parsed.flags || []), ...ruleFlags, ...(context.visionFlags || [])]),
    ];
    const score = Math.min(100, Math.max(0, Number(parsed.scamScore) || estimateScoreFromFlags(mergedFlags)));
    let verdict = parsed.verdict;
    if (!['safe', 'suspicious', 'likely_scam'].includes(verdict)) {
      verdict = verdictFromScore(score);
    }
    if (score > 70) verdict = 'likely_scam';
    else if (score >= 40 && verdict === 'safe') verdict = 'suspicious';

    return {
      scamScore: score,
      flags: mergedFlags,
      verdict,
      reason: parsed.reason || 'AI analysis complete.',
      recommendation: parsed.recommendation || 'Always view the property before paying.',
      source: 'claude',
    };
  } catch (err) {
    console.error('Claude JSON parse failed:', err.message);
    const score = estimateScoreFromFlags([...ruleFlags, ...(context.visionFlags || [])]);
    return {
      scamScore: score,
      flags: [...new Set([...ruleFlags, ...(context.visionFlags || [])])],
      verdict: verdictFromScore(score),
      reason: 'AI response could not be parsed; using rule-based fallback.',
      recommendation: 'View the property in person before any payment.',
      source: 'fallback',
    };
  }
}

async function checkPhotosWithVision(photos = []) {
  const apiKey = process.env.GOOGLE_VISION_API_KEY;
  if (!apiKey || !photos.length) {
    return { flags: [], details: [] };
  }

  const flags = [];
  const details = [];
  const urls = photos.filter((p) => typeof p === 'string' && p.startsWith('http')).slice(0, 3);

  for (const imageUrl of urls) {
    try {
      const response = await fetch(
        `https://vision.googleapis.com/v1/images:annotate?key=${apiKey}`,
        {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({
            requests: [
              {
                image: { source: { imageUri: imageUrl } },
                features: [
                  { type: 'WEB_DETECTION', maxResults: 5 },
                  { type: 'SAFE_SEARCH_DETECTION' },
                ],
              },
            ],
          }),
        },
      );

      if (!response.ok) continue;

      const data = await response.json();
      const result = data.responses?.[0];
      if (!result) continue;

      const webEntities = result.webDetection?.webEntities || [];
      const fullMatches = result.webDetection?.fullMatchingImages || [];
      const partialMatches = result.webDetection?.partialMatchingImages || [];

      const stockSites = ['unsplash', 'shutterstock', 'istockphoto', 'gettyimages', 'pexels', 'pinimg'];
      const allPages = [...(result.webDetection?.pagesWithMatchingImages || [])];
      const isStockOrReused =
        fullMatches.length > 2 ||
        partialMatches.length > 3 ||
        allPages.some((page) =>
          stockSites.some((site) => (page.url || '').toLowerCase().includes(site)),
        ) ||
        webEntities.some((e) => (e.description || '').toLowerCase().includes('stock photo'));

      if (isStockOrReused) {
        flags.push('stolen_photos');
        details.push({ imageUrl, matchCount: fullMatches.length + partialMatches.length });
        break;
      }
    } catch (err) {
      console.error('Vision API error:', err.message);
    }
  }

  return { flags: [...new Set(flags)], details };
}

async function scanListing(input, options = {}) {
  const duplicatePhoneCount = options.duplicatePhoneCount || 0;
  const ruleFlags = runRuleChecks(input, duplicatePhoneCount);
  const vision = await checkPhotosWithVision(input.photos || []);

  const analysis = await analyzeWithClaude(input, ruleFlags, {
    duplicatePhoneCount,
    visionFlags: vision.flags,
  });

  return {
    ...analysis,
    scannedAt: new Date().toISOString(),
    visionDetails: vision.details,
  };
}

module.exports = {
  scanListing,
  runRuleChecks,
  isQatarPhone,
  normalizePhone,
  verdictFromScore,
};
