const express = require('express');
const axios = require('axios');

const router = express.Router();

let ratesCache = null;
const historyCache = {};
let lastFetch = 0;
const CACHE_TTL = 30 * 60 * 1000;

const TARGET_CURRENCIES = [
  'INR', 'PKR', 'BDT', 'NPR', 'PHP', 'EGP', 'KES', 'LKR',
];

const BASE_URL = 'https://open.er-api.com/v6/latest/QAR';

const FALLBACK_RATES = {
  INR: 22.80,
  PKR: 76.50,
  BDT: 30.20,
  NPR: 36.50,
  PHP: 16.30,
  EGP: 13.90,
  KES: 37.10,
  LKR: 8.50,
};

router.get('/rates', async (_req, res) => {
  try {
    const now = Date.now();

    if (ratesCache && now - lastFetch < CACHE_TTL) {
      return res.json({
        success: true,
        cached: true,
        lastUpdated: new Date(lastFetch).toISOString(),
        nextUpdate: new Date(lastFetch + CACHE_TTL).toISOString(),
        rates: ratesCache,
      });
    }

    const response = await axios.get(BASE_URL, { timeout: 8000 });

    if (response.data.result !== 'success') {
      throw new Error('API returned non-success');
    }

    const allRates = response.data.rates;
    const filtered = {};
    TARGET_CURRENCIES.forEach((code) => {
      if (allRates[code]) {
        filtered[code] = parseFloat(allRates[code].toFixed(4));
      }
    });

    ratesCache = filtered;
    lastFetch = now;

    return res.json({
      success: true,
      cached: false,
      lastUpdated: new Date(now).toISOString(),
      nextUpdate: new Date(now + CACHE_TTL).toISOString(),
      rates: filtered,
    });
  } catch (error) {
    console.error('Exchange rate fetch error:', error.message);

    if (ratesCache) {
      return res.json({
        success: true,
        cached: true,
        stale: true,
        lastUpdated: new Date(lastFetch).toISOString(),
        rates: ratesCache,
      });
    }

    return res.json({
      success: true,
      cached: false,
      fallback: true,
      lastUpdated: new Date().toISOString(),
      rates: FALLBACK_RATES,
    });
  }
});

router.get('/history/:currency', async (req, res) => {
  const currency = (req.params.currency || '').toUpperCase();

  if (!TARGET_CURRENCIES.includes(currency)) {
    return res.status(400).json({
      success: false,
      error: 'Unsupported currency',
    });
  }

  const cacheKey = `${currency}_${new Date().toDateString()}`;

  if (historyCache[cacheKey]) {
    return res.json({
      success: true,
      cached: true,
      currency,
      history: historyCache[cacheKey],
    });
  }

  try {
    const today = new Date();
    const datePromises = Array.from({ length: 7 }, (_, i) => {
      const d = new Date(today);
      d.setDate(today.getDate() - (6 - i));
      const dateStr = d.toISOString().split('T')[0];
      const url = `https://open.er-api.com/v6/${dateStr}/QAR`;
      return axios
        .get(url, { timeout: 6000 })
        .then((r) => ({
          date: dateStr,
          rate: r.data?.rates?.[currency] ?? null,
        }))
        .catch(() => ({ date: dateStr, rate: null }));
    });

    const results = await Promise.all(datePromises);

    let lastKnown = ratesCache?.[currency] ?? FALLBACK_RATES[currency] ?? null;
    const filled = results.map((r) => {
      if (r.rate !== null) {
        lastKnown = parseFloat(Number(r.rate).toFixed(4));
      }
      return {
        date: r.date,
        rate: r.rate !== null ? parseFloat(Number(r.rate).toFixed(4)) : lastKnown,
      };
    });

    historyCache[cacheKey] = filled;

    return res.json({
      success: true,
      cached: false,
      currency,
      history: filled,
    });
  } catch (error) {
    console.error('History fetch error:', error.message);

    const fallback = Array.from({ length: 7 }, (_, i) => {
      const d = new Date();
      d.setDate(d.getDate() - (6 - i));
      return {
        date: d.toISOString().split('T')[0],
        rate: FALLBACK_RATES[currency] ?? null,
      };
    });

    return res.json({
      success: true,
      cached: false,
      fallback: true,
      currency,
      history: fallback,
    });
  }
});

router.get('/compare/:currency', async (req, res) => {
  const curr = (req.params.currency || 'INR').toUpperCase();

  if (!TARGET_CURRENCIES.includes(curr)) {
    return res.status(400).json({
      success: false,
      error: 'Unsupported currency',
    });
  }

  let midRate = ratesCache?.[curr];
  if (!midRate) {
    try {
      const r = await axios.get(BASE_URL, { timeout: 6000 });
      midRate = r.data?.rates?.[curr] ?? null;
      if (midRate) {
        midRate = parseFloat(Number(midRate).toFixed(4));
      }
    } catch (_) {
      midRate = null;
    }
  }

  if (!midRate) {
    midRate = FALLBACK_RATES[curr];
  }

  if (!midRate) {
    return res.status(503).json({
      success: false,
      error: 'Rate unavailable',
    });
  }

  const spreads = {
    'Al Fardan Exchange': 0.994,
    'Lari Exchange': 0.991,
    'Al Mirqab Exchange': 0.989,
    'Western Union': 0.975,
    'Eastern Exchange': 0.992,
    'CBI Bank': 0.985,
  };

  const websites = {
    'Al Fardan Exchange': 'https://www.alfardanexchange.com.qa',
    'Lari Exchange': 'https://www.lariexchange.com',
    'Western Union': 'https://www.westernunion.com/qa',
    'Al Mirqab Exchange': 'https://almirqabexchange.com',
    'Eastern Exchange': 'https://www.easternexchangeqatar.com',
    'CBI Bank': 'https://www.cbi.com.qa',
  };

  const ratings = {
    'Al Fardan Exchange': 4.7,
    'Lari Exchange': 4.5,
    'Eastern Exchange': 4.3,
    'Al Mirqab Exchange': 4.2,
    'CBI Bank': 4.0,
    'Western Union': 3.8,
  };

  const comparison = Object.entries(spreads)
    .map(([name, spread]) => ({
      name,
      rate: parseFloat((midRate * spread).toFixed(4)),
      fee: name === 'Western Union' ? '5 QR' : 'Free',
      rating: ratings[name] ?? 4.0,
      app: ['Al Fardan Exchange', 'Lari Exchange', 'Western Union'].includes(name),
      website: websites[name] ?? null,
    }))
    .sort((a, b) => b.rate - a.rate);

  return res.json({
    success: true,
    currency: curr,
    midMarketRate: parseFloat(Number(midRate).toFixed(4)),
    lastUpdated: new Date().toISOString(),
    disclaimer:
      'Rates are indicative. Visit exchange house for final rate.',
    comparison,
  });
});

module.exports = router;
