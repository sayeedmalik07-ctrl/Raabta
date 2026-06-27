import {
  mockStats,
  mockPendingListings,
  mockUsers,
  mockExchangeRates,
  mockVisaGuides,
  mockDoctors,
  mockBusinesses,
  mockAnnouncements,
  mockAiConversations,
  mockAiStats,
} from './mockData.js';

const USE_MOCK = import.meta.env.VITE_USE_MOCK === 'true';

async function getToken() {
  const token = window.__RAABTA_ADMIN_TOKEN__;
  return token || null;
}

async function request(path, options = {}) {
  if (USE_MOCK) {
    return mockRequest(path, options);
  }

  const token = await getToken();
  const headers = {
    'Content-Type': 'application/json',
    ...(token ? { Authorization: `Bearer ${token}` } : {}),
    ...(import.meta.env.DEV ? { 'x-admin-dev': 'true' } : {}),
    ...options.headers,
  };

  const res = await fetch(`/api${path}`, { ...options, headers });

  if (!res.ok) {
    const err = await res.json().catch(() => ({}));
    throw new Error(err.error || `Request failed: ${res.status}`);
  }

  return res.json();
}

function mockRequest(path, options = {}) {
  const method = options.method || 'GET';

  if (path.startsWith('/stats')) return Promise.resolve(mockStats());
  if (path.startsWith('/listings/moderation')) {
    if (method === 'GET') return Promise.resolve({ listings: mockPendingListings() });
    return Promise.resolve({ success: true, mock: true });
  }
  if (path.startsWith('/users')) {
    if (method === 'GET') return Promise.resolve({ users: mockUsers() });
    return Promise.resolve({ success: true, mock: true });
  }
  if (path.startsWith('/exchange-rates')) {
    if (method === 'GET') return Promise.resolve({ rates: mockExchangeRates() });
    return Promise.resolve({ success: true, mock: true });
  }
  if (path.startsWith('/content')) {
    const type = new URLSearchParams(path.split('?')[1] || '').get('type');
    const map = {
      'visa-guides': mockVisaGuides,
      doctors: mockDoctors,
      businesses: mockBusinesses,
      announcements: mockAnnouncements,
    };
    return Promise.resolve({ items: map[type]?.() || [] });
  }
  if (path.startsWith('/ai-monitor')) {
    return Promise.resolve({
      conversations: mockAiConversations(),
      stats: mockAiStats(),
    });
  }

  return Promise.resolve({});
}

export const api = {
  getStats: () => request('/stats'),
  getModerationQueue: (minScore, maxScore) =>
    request(`/listings/moderation?minScore=${minScore}&maxScore=${maxScore}`),
  moderateListing: (id, action) =>
    request('/listings/moderation', {
      method: 'PATCH',
      body: JSON.stringify({ id, action }),
    }),
  bulkApprove: (ids) =>
    request('/listings/moderation', {
      method: 'POST',
      body: JSON.stringify({ action: 'bulk-approve', ids }),
    }),
  searchUsers: (q) => request(`/users?q=${encodeURIComponent(q || '')}`),
  updateUser: (id, action, reason) =>
    request('/users', {
      method: 'PATCH',
      body: JSON.stringify({ id, action, reason }),
    }),
  getExchangeRates: () => request('/exchange-rates'),
  updateRate: (id, rate) =>
    request('/exchange-rates', {
      method: 'PUT',
      body: JSON.stringify({ id, rate }),
    }),
  notifyRateChange: (currency, changePercent) =>
    request('/exchange-rates', {
      method: 'POST',
      body: JSON.stringify({ action: 'notify-rate-change', currency, changePercent }),
    }),
  getContent: (type) => request(`/content?type=${type}`),
  saveContent: (type, item) =>
    request(`/content?type=${type}`, {
      method: item.id ? 'PUT' : 'POST',
      body: JSON.stringify(item),
    }),
  deleteContent: (type, id) =>
    request(`/content?type=${type}&id=${id}`, { method: 'DELETE' }),
  getAiMonitor: () => request('/ai-monitor'),
  flagConversation: (id, flagged, flagReason) =>
    request('/ai-monitor', {
      method: 'PATCH',
      body: JSON.stringify({ id, flagged, flagReason }),
    }),
};

export function setAdminToken(token) {
  window.__RAABTA_ADMIN_TOKEN__ = token;
}
